import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hrm_app/core/config/app_config.dart';
import 'package:hrm_app/core/network/dio_client.dart';
import 'package:hrm_app/core/security/cookie_session.dart';
import 'package:hrm_app/core/security/session_cookie_store.dart';
import 'package:hrm_app/core/security/token_storage.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('applies server cookie paths and CSRF rules', () async {
    final fixture = await _fixture();
    await fixture.store.capture(
      _headers(_cookies()),
      fixture.uri('/auth/login'),
    );

    final safe = await fixture.store.headersFor(
      fixture.uri('/employees'),
      method: 'GET',
    );
    expect(cookieValue(safe['Cookie'], 'at'), 'access');
    expect(cookieValue(safe['Cookie'], 'csrf'), 'nonce.signature');
    expect(cookieValue(safe['Cookie'], 'rt'), isNull);
    expect(safe['X-CSRF-Token'], isNull);

    final unsafe = await fixture.store.headersFor(
      fixture.uri('/employees'),
      method: 'POST',
    );
    expect(unsafe['X-CSRF-Token'], 'nonce.signature');

    final refresh = await fixture.store.headersFor(
      fixture.uri('/auth/refresh'),
      method: 'POST',
    );
    expect(cookieValue(refresh['Cookie'], 'at'), 'access');
    expect(cookieValue(refresh['Cookie'], 'rt'), 'refresh');
    expect(refresh['X-CSRF-Token'], 'nonce.signature');
  });

  test('restores scoped cookies from secure storage after restart', () async {
    final fixture = await _fixture();
    await fixture.store.capture(
      _headers(_cookies()),
      fixture.uri('/auth/login'),
    );
    final restarted = SessionCookieStore(
      storage: fixture.storage,
      baseUrl: fixture.baseUrl,
    );

    final headers = await restarted.headersFor(
      fixture.uri('/auth/refresh'),
      method: 'POST',
    );
    expect(cookieValue(headers['Cookie'], 'at'), 'access');
    expect(cookieValue(headers['Cookie'], 'rt'), 'refresh');
    expect(headers['X-CSRF-Token'], 'nonce.signature');
  });

  test('does not send credentials to another origin', () async {
    final fixture = await _fixture();
    await fixture.storage.saveTokens(
      accessToken: 'bearer-secret',
      refreshToken: 'refresh-secret',
    );
    await fixture.store.capture(
      _headers(_cookies()),
      fixture.uri('/auth/login'),
    );

    expect(
      await fixture.store.headersFor(
        Uri.parse('https://outside.example.test/api/v1/employees'),
        method: 'POST',
      ),
      isEmpty,
    );
  });

  test('does not send Secure cookies over local HTTP', () async {
    final fixture = await _fixture(baseUrl: 'http://api.example.test/api/v1');
    await fixture.store.capture(
      _headers(_cookies(secure: true)),
      fixture.uri('/auth/login'),
    );

    final headers = await fixture.store.headersFor(
      fixture.uri('/employees'),
      method: 'GET',
    );
    expect(headers['Cookie'], isNull);
    expect(await fixture.store.hasAccessCredential(), isFalse);
  });

  test('expires Max-Age cookies and keeps valid scoped cookies', () async {
    var now = DateTime.utc(2026, 9, 11, 8);
    final fixture = await _fixture(clock: () => now);
    await fixture.store.capture(
      _headers(_cookies(accessMaxAge: 1)),
      fixture.uri('/auth/login'),
    );
    expect(await fixture.store.hasAccessCredential(), isTrue);

    now = now.add(const Duration(seconds: 2));
    expect(await fixture.store.hasAccessCredential(), isFalse);
    final refresh = await fixture.store.headersFor(
      fixture.uri('/auth/refresh'),
      method: 'POST',
    );
    expect(cookieValue(refresh['Cookie'], 'at'), isNull);
    expect(cookieValue(refresh['Cookie'], 'rt'), 'refresh');
  });

  test('rotates and deletes cookies only at the contracted path', () async {
    final fixture = await _fixture();
    await fixture.store.capture(
      _headers(_cookies()),
      fixture.uri('/auth/login'),
    );
    await fixture.store.capture(
      _headers(_cookies(access: 'rotated', refresh: 'rotated-refresh')),
      fixture.uri('/auth/refresh'),
    );
    expect(
      cookieValue(
        (await fixture.store.headersFor(
          fixture.uri('/employees'),
          method: 'GET',
        ))['Cookie'],
        'at',
      ),
      'rotated',
    );

    await fixture.store.capture(
      _headers([
        'at=; Max-Age=0; Path=/; HttpOnly; Secure; SameSite=Lax',
        'rt=; Max-Age=0; Path=/api/v1/auth; HttpOnly; Secure; SameSite=Lax',
        'csrf=; Max-Age=0; Path=/; Secure; SameSite=Lax',
      ]),
      fixture.uri('/auth/logout'),
    );
    expect(await fixture.store.hasAccessCredential(), isFalse);
    expect(await fixture.storage.readCookieHeader(), isNull);
    expect(await fixture.storage.readCsrfToken(), isNull);
  });

  test('rejects non-auth and malformed authentication cookies', () async {
    final fixture = await _fixture();
    await fixture.store.capture(
      _headers([
        'theme=dark; Path=/; SameSite=Lax',
        'at=no-http-only; Max-Age=900; Path=/; SameSite=Lax',
        'at=wrong-domain; Max-Age=900; Domain=evil.test; Path=/; HttpOnly; SameSite=Lax',
        'rt=wrong-path; Max-Age=604800; Path=/; HttpOnly; SameSite=Lax',
        'csrf=http-only; Path=/; HttpOnly; SameSite=Lax',
      ]),
      fixture.uri('/auth/login'),
    );

    expect(await fixture.store.hasAccessCredential(), isFalse);
    expect(await fixture.storage.readCookieHeader(), isNull);
    expect(await fixture.storage.readCsrfToken(), isNull);
  });

  test('ignores corrupted persisted cookie state', () async {
    FlutterSecureStorage.setMockInitialValues({'hrms.cookie_state': '{'});
    const storage = SecureTokenStorage(FlutterSecureStorage());
    final store = SessionCookieStore(
      storage: storage,
      baseUrl: 'https://api.example.test/api/v1',
    );

    expect(await store.hasAccessCredential(), isFalse);
    expect(
      await store.headersFor(
        Uri.parse('https://api.example.test/api/v1/employees'),
        method: 'GET',
      ),
      isEmpty,
    );
  });

  test(
    'authenticated redirects are not followed to another origin',
    () => HttpOverrides.runWithHttpOverrides(() async {
      FlutterSecureStorage.setMockInitialValues({});
      const storage = SecureTokenStorage(FlutterSecureStorage());
      await storage.saveTokens(
        accessToken: 'bearer-secret',
        refreshToken: 'refresh-secret',
      );
      final destination = await HttpServer.bind(
        InternetAddress.loopbackIPv4,
        0,
      );
      final source = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
      addTearDown(() => source.close(force: true));
      addTearDown(() => destination.close(force: true));
      var destinationCalls = 0;
      destination.listen((request) async {
        destinationCalls++;
        request.response.write(jsonEncode({'success': true}));
        await request.response.close();
      });
      source.listen((request) async {
        request.response.statusCode = HttpStatus.found;
        request.response.headers.set(
          HttpHeaders.locationHeader,
          'http://127.0.0.1:${destination.port}/capture',
        );
        await request.response.close();
      });
      final config = AppConfig(
        baseUrl: 'http://127.0.0.1:${source.port}',
        connectTimeout: const Duration(seconds: 2),
        receiveTimeout: const Duration(seconds: 2),
        enableNetworkLogs: false,
      );
      final dio = Dio(BaseOptions(baseUrl: config.baseUrl));
      addTearDown(dio.close);
      dio.interceptors.add(
        AuthInterceptor(
          dio: dio,
          config: config,
          storage: storage,
          onSessionInvalidated: () {},
        ),
      );

      await expectLater(
        dio.get<dynamic>('/redirect'),
        throwsA(isA<DioException>()),
      );
      expect(destinationCalls, 0);
      await storage.clear();
      await expectLater(
        dio.post<dynamic>(
          '/auth/login',
          data: {'email': 'fixture@example.test', 'password': 'secret'},
        ),
        throwsA(isA<DioException>()),
      );
      expect(destinationCalls, 0);
    }, _LocalHttpOverrides()),
  );
}

class _LocalHttpOverrides extends HttpOverrides {}

Future<
  ({
    String baseUrl,
    SecureTokenStorage storage,
    SessionCookieStore store,
    Uri Function(String path) uri,
  })
>
_fixture({
  String baseUrl = 'https://api.example.test/api/v1',
  DateTime Function()? clock,
}) async {
  FlutterSecureStorage.setMockInitialValues({});
  const storage = SecureTokenStorage(FlutterSecureStorage());
  final store = SessionCookieStore(
    storage: storage,
    baseUrl: baseUrl,
    clock: clock,
  );
  return (
    baseUrl: baseUrl,
    storage: storage,
    store: store,
    uri: (path) => Uri.parse('$baseUrl$path'),
  );
}

Headers _headers(List<String> cookies) =>
    Headers.fromMap({'set-cookie': cookies});

List<String> _cookies({
  String access = 'access',
  String refresh = 'refresh',
  String csrf = 'nonce.signature',
  int accessMaxAge = 900,
  bool secure = true,
}) {
  final secureAttribute = secure ? '; Secure' : '';
  return [
    'at=$access; Max-Age=$accessMaxAge; Path=/; HttpOnly$secureAttribute; SameSite=Lax',
    'rt=$refresh; Max-Age=604800; Path=/api/v1/auth; HttpOnly$secureAttribute; SameSite=Lax',
    'csrf=$csrf; Path=/$secureAttribute; SameSite=Lax',
  ];
}
