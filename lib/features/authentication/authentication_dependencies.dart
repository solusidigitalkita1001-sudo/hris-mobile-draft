import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hrm_app/core/network/dio_client.dart';
import 'package:hrm_app/core/security/token_storage.dart';
import 'package:hrm_app/core/security/session_lifecycle.dart';
import 'package:hrm_app/features/authentication/data/datasources/auth_remote_datasource.dart';
import 'package:hrm_app/features/authentication/data/repositories/auth_repository_impl.dart';
import 'package:hrm_app/features/authentication/domain/repositories/auth_repository.dart';
import 'package:hrm_app/features/authentication/domain/usecases/login.dart';

final authRemoteDataSourceProvider = Provider<AuthRemoteDataSource>(
  (ref) => DioAuthRemoteDataSource(
    ref.watch(dioProvider),
    lifecycle: ref.read(sessionLifecycleProvider),
  ),
);

final authRepositoryProvider = Provider<AuthRepository>(
  (ref) => AuthRepositoryImpl(
    ref.watch(authRemoteDataSourceProvider),
    ref.watch(tokenStorageProvider),
    lifecycle: ref.read(sessionLifecycleProvider),
    cookieStore: ref.watch(sessionCookieStoreProvider),
  ),
);

final loginUseCaseProvider = Provider<Login>(
  (ref) => Login(ref.watch(authRepositoryProvider)),
);
