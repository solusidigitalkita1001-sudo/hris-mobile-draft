import 'package:dio/dio.dart';
import 'package:hrm_app/core/errors/failure.dart';
import 'package:hrm_app/core/errors/result.dart';
import 'package:hrm_app/core/network/api_error_mapper.dart';
import 'package:hrm_app/core/network/api_exception.dart';
import 'package:hrm_app/core/security/token_storage.dart';
import 'package:hrm_app/features/authentication/data/datasources/auth_remote_datasource.dart';
import 'package:hrm_app/features/authentication/data/dto/auth_session_dto.dart';
import 'package:hrm_app/features/authentication/domain/entities/auth_session.dart';
import 'package:hrm_app/features/authentication/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  const AuthRepositoryImpl(this._remote, this._tokens);
  final AuthRemoteDataSource _remote;
  final TokenStorage _tokens;

  @override
  Future<bool> hasSession() async =>
      (await _tokens.readAccessToken())?.isNotEmpty ?? false;

  @override
  Future<Result<AuthSession?>> restoreSession() async {
    try {
      final stored = await _tokens.readSession();
      if (stored == null) {
        if (await hasSession()) await _tokens.clear();
        return const Success(null);
      }
      final cached = AuthSessionDto.fromStoredJson(stored);
      final me = await _remote.me();
      final user = me['user'] is Map<String, dynamic>
          ? me['user'] as Map<String, dynamic>
          : me;
      final refreshed = cached.mergeUser(user);
      await _save(refreshed);
      return Success(refreshed.toEntity());
    } on ApiException catch (error) {
      if (error.statusCode == 401 || error.code == 'TOKEN_EXPIRED') {
        await _tokens.clear();
        return const Success(null);
      }
      return FailureResult(mapApiException(error));
    } on FormatException {
      await _tokens.clear();
      return const Success(null);
    }
  }

  @override
  Future<Result<AuthSession>> login({
    required String email,
    required String password,
  }) async {
    try {
      final dto = await _remote.login(email: email, password: password);
      final session = dto.toEntity();
      await _save(dto);
      return Success(session);
    } on ApiException catch (error) {
      return FailureResult(mapApiException(error));
    } on DioException catch (error) {
      return FailureResult(mapApiException(mapDioException(error)));
    } on FormatException catch (error) {
      return FailureResult(ServerFailure(error.message));
    } catch (_) {
      return const FailureResult(
        NetworkFailure('Tidak dapat terhubung ke server.'),
      );
    }
  }

  @override
  Future<void> logout() async {
    final refreshToken = await _tokens.readRefreshToken();
    if (refreshToken != null && refreshToken.isNotEmpty) {
      try {
        await _remote.logout(refreshToken);
      } on Object {
        // Local logout must still succeed when the server is unavailable.
      }
    }
    await _tokens.clear();
  }

  Future<void> _save(AuthSessionDto dto) async {
    await _tokens.saveTokens(
      accessToken: dto.accessToken,
      refreshToken: dto.refreshToken,
    );
    await _tokens.saveSession(dto.toStoredJson());
  }
}
