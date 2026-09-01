import 'package:hrm_app/core/errors/result.dart';
import 'package:hrm_app/features/authentication/domain/entities/auth_session.dart';

abstract interface class AuthRepository {
  Future<bool> hasSession();
  Future<Result<AuthSession?>> restoreSession();
  Future<Result<AuthSession>> login({
    required String email,
    required String password,
  });
  Future<void> logout();
}
