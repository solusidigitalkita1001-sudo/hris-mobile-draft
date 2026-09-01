import 'package:flutter_test/flutter_test.dart';
import 'package:hrm_app/core/errors/result.dart';
import 'package:hrm_app/core/security/token_storage.dart';
import 'package:hrm_app/features/authentication/data/datasources/auth_remote_datasource.dart';
import 'package:hrm_app/features/authentication/data/dto/auth_session_dto.dart';
import 'package:hrm_app/features/authentication/data/repositories/auth_repository_impl.dart';

void main() {
  test('stores access token after successful login', () async {
    final tokens = _MemoryTokenStorage();
    final repository = AuthRepositoryImpl(_SuccessfulRemote(), tokens);

    final result = await repository.login(
      email: 'user@example.com',
      password: 'secret',
    );

    expect(result, isA<Success>());
    expect(await tokens.readAccessToken(), 'access-token');
    expect(await tokens.readSession(), isNotNull);
    expect(await repository.hasSession(), isTrue);
  });
}

class _SuccessfulRemote implements AuthRemoteDataSource {
  @override
  Future<AuthSessionDto> login({
    required String email,
    required String password,
  }) async => AuthSessionDto(
    accessToken: 'access-token',
    email: email,
    userName: 'Test User',
  );

  @override
  Future<Map<String, dynamic>> me() async => {
    'id': 'user-id',
    'email': 'user@example.com',
  };

  @override
  Future<void> logout(String refreshToken) async {}
}

class _MemoryTokenStorage implements TokenStorage {
  String? _accessToken;
  String? _refreshToken;
  Map<String, dynamic>? _session;

  @override
  Future<void> clear() async {
    _accessToken = null;
    _refreshToken = null;
    _session = null;
  }

  @override
  Future<String?> readAccessToken() async => _accessToken;

  @override
  Future<String?> readRefreshToken() async => _refreshToken;

  @override
  Future<Map<String, dynamic>?> readSession() async => _session;

  @override
  Future<void> saveSession(Map<String, dynamic> session) async {
    _session = session;
  }

  @override
  Future<void> saveTokens({
    required String accessToken,
    String? refreshToken,
  }) async {
    _accessToken = accessToken;
    _refreshToken = refreshToken;
  }
}
