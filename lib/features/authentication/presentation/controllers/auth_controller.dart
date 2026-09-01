import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hrm_app/core/errors/result.dart';
import 'package:hrm_app/core/network/dio_client.dart';
import 'package:hrm_app/core/network/request_context.dart';
import 'package:hrm_app/features/authentication/authentication_dependencies.dart';
import 'package:hrm_app/features/authentication/domain/entities/auth_session.dart';

class AuthController extends AsyncNotifier<AuthSession?> {
  @override
  Future<AuthSession?> build() async {
    ref.watch(sessionInvalidationProvider);
    final result = await ref.read(authRepositoryProvider).restoreSession();
    return switch (result) {
      Success(:final value) => _setContext(value),
      FailureResult(:final failure) => throw failure,
    };
  }

  Future<void> login({required String email, required String password}) async {
    state = const AsyncLoading();
    final result = await ref.read(loginUseCaseProvider)(
      email: email,
      password: password,
    );
    state = switch (result) {
      Success(:final value) => AsyncData(_setContext(value)!),
      FailureResult(:final failure) => AsyncError(failure, StackTrace.current),
    };
  }

  Future<void> logout() async {
    await ref.read(authRepositoryProvider).logout();
    ref.read(requestContextProvider.notifier).state = null;
    state = const AsyncData(null);
  }

  AuthSession? _setContext(AuthSession? session) {
    if (session == null) {
      ref.read(requestContextProvider.notifier).state = null;
      return null;
    }
    final scope = session.companyScope.isEmpty && session.companyId != null
        ? [session.companyId!]
        : session.companyScope;
    ref.read(requestContextProvider.notifier).state = RequestContext(
      userId: session.userId,
      employeeId: session.employeeId,
      activeCompanyId:
          session.companyId ?? (scope.isEmpty ? null : scope.first),
      companyScope: scope,
      displayName: session.userName,
      email: session.email,
      roles: session.roles,
      permissions: session.permissions,
    );
    return session;
  }
}
