import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

abstract interface class TokenStorage {
  Future<String?> readAccessToken();
  Future<String?> readRefreshToken();
  Future<Map<String, dynamic>?> readSession();
  Future<void> saveSession(Map<String, dynamic> session);
  Future<void> saveTokens({required String accessToken, String? refreshToken});
  Future<void> clear();
}

final class SecureTokenStorage implements TokenStorage {
  const SecureTokenStorage(this._storage);
  final FlutterSecureStorage _storage;

  static const _accessKey = 'hrms.access_token';
  static const _refreshKey = 'hrms.refresh_token';
  static const _sessionKey = 'hrms.session';

  @override
  Future<String?> readAccessToken() => _storage.read(key: _accessKey);

  @override
  Future<String?> readRefreshToken() => _storage.read(key: _refreshKey);

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
  Future<void> clear() => _storage.deleteAll();
}

final tokenStorageProvider = Provider<TokenStorage>(
  (ref) => const SecureTokenStorage(FlutterSecureStorage()),
);
