import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hrm_app/core/errors/result.dart';
import 'package:hrm_app/core/network/dio_client.dart';
import 'package:hrm_app/core/security/session_lifecycle.dart';
import 'package:hrm_app/core/services/location_service.dart';
import 'package:hrm_app/features/attendance/data/datasources/attendance_remote_datasource.dart';
import 'package:hrm_app/features/attendance/data/repositories/attendance_repository_impl.dart';
import 'package:hrm_app/features/attendance/domain/entities/attendance_context.dart';
import 'package:hrm_app/features/attendance/domain/repositories/attendance_repository.dart';
import 'package:hrm_app/features/attendance/domain/usecases/clock_in.dart';
import 'package:hrm_app/features/attendance/domain/usecases/clock_out.dart';
import 'package:hrm_app/features/attendance/domain/usecases/get_today_attendance.dart';

final attendanceDataSourceProvider = Provider<AttendanceRemoteDataSource>((
  ref,
) {
  final session = ref.watch(featureSessionProvider);
  return DioAttendanceRemoteDataSource(
    ref.watch(featureDioProvider),
    () => session.context,
  );
});

final attendanceRepositoryProvider = Provider<AttendanceRepository>(
  (ref) => AttendanceRepositoryImpl(ref.watch(attendanceDataSourceProvider)),
);

final getTodayAttendanceProvider = Provider<GetTodayAttendance>(
  (ref) => GetTodayAttendance(ref.watch(attendanceRepositoryProvider)),
);

final attendanceContextProvider = FutureProvider.autoDispose
    .family<AttendanceContext, FeatureSession>((ref, session) async {
      final result = await ref.watch(attendanceRepositoryProvider).getContext();
      if (!session.isCurrent) {
        throw StateError('Sesi telah berubah. Muat ulang halaman absensi.');
      }
      return switch (result) {
        Success(:final value) => value,
        FailureResult(:final failure) => throw failure,
      };
    });

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
