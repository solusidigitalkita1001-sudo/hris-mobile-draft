import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hrm_app/core/config/app_config.dart';
import 'package:hrm_app/core/security/token_storage.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';

final appConfigProvider = Provider<AppConfig>(
  (ref) => throw UnimplementedError(),
);

/// Incremented when a session can no longer be refreshed.
final sessionInvalidationProvider = StateProvider<int>((ref) => 0);

final dioProvider = Provider<Dio>((ref) {
  final config = ref.watch(appConfigProvider);
  final dio = Dio(
    BaseOptions(
      baseUrl: config.baseUrl,
      connectTimeout: config.connectTimeout,
      receiveTimeout: config.receiveTimeout,
      headers: const {'Accept': 'application/json'},
    ),
  );

  dio.interceptors.add(
    AuthInterceptor(
      dio: dio,
      config: config,
      storage: ref.watch(tokenStorageProvider),
      onSessionInvalidated: () =>
          ref.read(sessionInvalidationProvider.notifier).state++,
    ),
  );

  if (kDebugMode && config.enableNetworkLogs) {
    dio.interceptors.add(
      PrettyDioLogger(
        requestHeader: false,
        requestBody: false,
        responseHeader: false,
      ),
    );
  }
  ref.onDispose(dio.close);
  return dio;
});

class AuthInterceptor extends Interceptor {
  AuthInterceptor({
    required this._dio,
    required this._config,
    required this._storage,
    required this._onSessionInvalidated,
  });

  final Dio _dio;
  final AppConfig _config;
  final TokenStorage _storage;
  final void Function() _onSessionInvalidated;
  Future<String?>? _refreshing;

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await _storage.readAccessToken();
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    final request = err.requestOptions;
    final isUnauthorized = err.response?.statusCode == 401;
    final isRefresh = request.path.endsWith('/auth/refresh');
    final alreadyRetried = request.extra['authRetried'] == true;
    if (!isUnauthorized || isRefresh || alreadyRetried) {
      handler.next(err);
      return;
    }

    final token = await _refreshOnce();
    if (token == null) {
      await _storage.clear();
      _onSessionInvalidated();
      handler.next(err);
      return;
    }

    try {
      request.extra['authRetried'] = true;
      request.headers['Authorization'] = 'Bearer $token';
      handler.resolve(await _dio.fetch<dynamic>(request));
    } on DioException catch (retryError) {
      handler.next(retryError);
    }
  }

  Future<String?> _refreshOnce() {
    final active = _refreshing;
    if (active != null) return active;
    final refresh = _performRefresh();
    _refreshing = refresh;
    return refresh.whenComplete(() => _refreshing = null);
  }

  Future<String?> _performRefresh() async {
    final refreshToken = await _storage.readRefreshToken();
    if (refreshToken == null || refreshToken.isEmpty) return null;
    try {
      final refreshDio = Dio(
        BaseOptions(
          baseUrl: _config.baseUrl,
          connectTimeout: _config.connectTimeout,
          receiveTimeout: _config.receiveTimeout,
          headers: const {'Accept': 'application/json'},
        ),
      );
      final response = await refreshDio.post<Map<String, dynamic>>(
        '/auth/refresh',
        data: {'refreshToken': refreshToken},
      );
      refreshDio.close();
      final envelope = response.data;
      final data = envelope?['data'];
      if (data is! Map<String, dynamic>) return null;
      final tokens = data['tokens'] is Map<String, dynamic>
          ? data['tokens'] as Map<String, dynamic>
          : data;
      final accessToken = tokens['accessToken'] as String?;
      if (accessToken == null || accessToken.isEmpty) return null;
      final nextRefresh = tokens['refreshToken'] as String? ?? refreshToken;
      await _storage.saveTokens(
        accessToken: accessToken,
        refreshToken: nextRefresh,
      );
      final session = await _storage.readSession();
      if (session != null) {
        await _storage.saveSession({
          ...session,
          'accessToken': accessToken,
          'refreshToken': nextRefresh,
          if (tokens['expiresIn'] != null) 'expiresIn': tokens['expiresIn'],
        });
      }
      return accessToken;
    } on DioException {
      return null;
    }
  }
}
