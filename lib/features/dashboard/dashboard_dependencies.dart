import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hrm_app/core/network/dio_client.dart';
import 'package:hrm_app/core/network/request_context.dart';
import 'package:hrm_app/features/dashboard/data/datasources/dashboard_local_datasource.dart';
import 'package:hrm_app/features/dashboard/data/datasources/dashboard_remote_datasource.dart';
import 'package:hrm_app/features/dashboard/data/repositories/dashboard_repository_impl.dart';
import 'package:hrm_app/features/dashboard/domain/repositories/dashboard_repository.dart';

final dashboardLocalDataSourceProvider = Provider<DashboardLocalDataSource>(
  (ref) => DemoDashboardLocalDataSource(),
);

final dashboardRepositoryProvider = Provider<DashboardRepository>(
  (ref) => DashboardRepositoryImpl(
    ref.watch(dashboardLocalDataSourceProvider),
    DioDashboardRemoteDataSource(ref.watch(dioProvider)),
    () => ref.read(requestContextProvider),
  ),
);
