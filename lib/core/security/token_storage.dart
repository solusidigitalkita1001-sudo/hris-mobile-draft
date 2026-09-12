import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

abstract interface class TokenStorage {
  Future<String?> readAccessToken();
  Future<String?> readRefreshToken();
  Future<String?> readCookieHeader();
  Future<String?> readCsrfToken();
  Future<Map<String, dynamic>?> readCookieState();
  Future<Map<String, dynamic>?> readSession();
  Future<void> saveSession(Map<String, dynamic> session);
  Future<void> saveTokens({required String accessToken, String? refreshToken});
  Future<void> saveCookieSession({
    required String cookieHeader,
    required String csrfToken,
  });
  Future<void> saveCookieState({
    required Map<String, dynamic> state,
    String? cookieHeader,
    String? csrfToken,
  });
  Future<void> clear();
}

final class SecureTokenStorage implements TokenStorage {
  const SecureTokenStorage(this._storage);
  final FlutterSecureStorage _storage;

  static const _accessKey = 'hrms.access_token';
  static const _refreshKey = 'hrms.refresh_token';
  static const _cookieKey = 'hrms.auth_cookie';
  static const _csrfKey = 'hrms.csrf_token';
  static const _cookieStateKey = 'hrms.cookie_state';
  static const _sessionKey = 'hrms.session';

  @override
  Future<String?> readAccessToken() => _storage.read(key: _accessKey);

  @override
  Future<String?> readRefreshToken() => _storage.read(key: _refreshKey);

  @override
  Future<String?> readCookieHeader() => _storage.read(key: _cookieKey);

  @override
  Future<String?> readCsrfToken() => _storage.read(key: _csrfKey);

  @override
  Future<Map<String, dynamic>?> readCookieState() async {
    final value = await _storage.read(key: _cookieStateKey);
    if (value == null) return null;
    final decoded = jsonDecode(value);
    return decoded is Map<String, dynamic> ? decoded : null;
  }

  @override
  Future<Map<String, dynamic>?> readSession() async {
    final value = await _storage.read(key: _sessionKey);
    if (value == null) return null;
    final decoded = jsonDecode(value);
    return decoded is Map<String, dynamic> ? decoded : null;
  }

  @override
  Future<void> saveSession(Map<String, dynamic> session) async {
    await _storage.write(key: _sessionKey, value: jsonEncode(session));
  }

  @override
  Future<void> saveTokens({
    required String accessToken,
    String? refreshToken,
  }) async {
    await _storage.write(key: _accessKey, value: accessToken);
    if (refreshToken != null) {
      await _storage.write(key: _refreshKey, value: refreshToken);
    }
  }

  @override
  Future<void> saveCookieSession({
    required String cookieHeader,
    required String csrfToken,
  }) async {
    await _storage.write(key: _cookieKey, value: cookieHeader);
    await _storage.write(key: _csrfKey, value: csrfToken);
  }

  @override
  Future<void> saveCookieState({
    required Map<String, dynamic> state,
    String? cookieHeader,
    String? csrfToken,
  }) async {
    await _storage.write(key: _cookieStateKey, value: jsonEncode(state));
    if (cookieHeader == null) {
      await _storage.delete(key: _cookieKey);
    } else {
      await _storage.write(key: _cookieKey, value: cookieHeader);
    }
    if (csrfToken == null) {
      await _storage.delete(key: _csrfKey);
    } else {
      await _storage.write(key: _csrfKey, value: csrfToken);
    }
  }

  @override
  Future<void> clear() => _storage.deleteAll();
}

final tokenStorageProvider = Provider<TokenStorage>(
  (ref) => const SecureTokenStorage(FlutterSecureStorage()),
);
