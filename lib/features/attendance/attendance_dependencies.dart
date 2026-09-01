import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hrm_app/core/network/dio_client.dart';
import 'package:hrm_app/core/network/request_context.dart';
import 'package:hrm_app/core/services/location_service.dart';
import 'package:hrm_app/features/attendance/data/datasources/attendance_remote_datasource.dart';
import 'package:hrm_app/features/attendance/data/repositories/attendance_repository_impl.dart';
import 'package:hrm_app/features/attendance/domain/repositories/attendance_repository.dart';
import 'package:hrm_app/features/attendance/domain/usecases/clock_in.dart';
import 'package:hrm_app/features/attendance/domain/usecases/clock_out.dart';
import 'package:hrm_app/features/attendance/domain/usecases/get_today_attendance.dart';

final attendanceDataSourceProvider = Provider<AttendanceRemoteDataSource>(
  (ref) => DioAttendanceRemoteDataSource(
    ref.watch(dioProvider),
    () => ref.read(requestContextProvider),
  ),
);

final attendanceRepositoryProvider = Provider<AttendanceRepository>(
  (ref) => AttendanceRepositoryImpl(ref.watch(attendanceDataSourceProvider)),
);

final getTodayAttendanceProvider = Provider<GetTodayAttendance>(
  (ref) => GetTodayAttendance(ref.watch(attendanceRepositoryProvider)),
);

final clockInProvider = Provider<ClockIn>(
  (ref) => ClockIn(
    ref.watch(attendanceRepositoryProvider),
    ref.watch(locationServiceProvider),
  ),
);

final clockOutProvider = Provider<ClockOut>(
  (ref) => ClockOut(
    ref.watch(attendanceRepositoryProvider),
    ref.watch(locationServiceProvider),
  ),
);
