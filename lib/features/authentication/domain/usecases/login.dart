import 'package:hrm_app/core/errors/result.dart';
import 'package:hrm_app/features/authentication/domain/entities/auth_session.dart';
import 'package:hrm_app/features/authentication/domain/repositories/auth_repository.dart';

class Login {
  const Login(this._repository);
  final AuthRepository _repository;

  Future<Result<AuthSession>> call({
    required String email,
    required String password,
    String? totp,
  }) => _repository.login(
    email: email.trim(),
    password: password,
    totp: totp?.trim(),
  );
}
