import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hrm_app/core/network/dio_client.dart';
import 'package:hrm_app/core/network/request_context.dart';
import 'package:hrm_app/features/profile/data/datasources/profile_local_datasource.dart';
import 'package:hrm_app/features/profile/data/datasources/profile_remote_datasource.dart';
import 'package:hrm_app/features/profile/data/repositories/profile_repository_impl.dart';
import 'package:hrm_app/features/profile/domain/repositories/profile_repository.dart';

final profileLocalDataSourceProvider = Provider<ProfileLocalDataSource>(
  (ref) => DemoProfileLocalDataSource(),
);

final profileRepositoryProvider = Provider<ProfileRepository>(
  (ref) => ProfileRepositoryImpl(
    ref.watch(profileLocalDataSourceProvider),
    DioProfileRemoteDataSource(ref.watch(dioProvider)),
    () => ref.read(requestContextProvider),
  ),
);
