import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hrm_app/core/errors/result.dart';
import 'package:hrm_app/core/network/request_context.dart';
import 'package:hrm_app/features/attendance/attendance_dependencies.dart';
import 'package:hrm_app/features/attendance/domain/entities/attendance_entity.dart';

class AttendanceController extends AsyncNotifier<AttendanceEntity> {
  @override
  Future<AttendanceEntity> build() async {
    final result = await ref.read(getTodayAttendanceProvider)();
    return _unwrap(result);
  }

  Future<void> toggleAttendance() async {
    final employeeId = ref.read(requestContextProvider)?.employeeId;
    if (employeeId == null) {
      state = AsyncError(
        StateError('Employee ID tidak tersedia pada session.'),
        StackTrace.current,
      );
      return;
    }
    final current =
        state.valueOrNull ??
        _unwrap(await ref.read(getTodayAttendanceProvider)());
    state = const AsyncLoading();
    final result = current.isActive
        ? await ref.read(clockOutProvider)(employeeId)
        : await ref.read(clockInProvider)(employeeId);
    state = switch (result) {
      Success(:final value) => AsyncData(value),
      FailureResult(:final failure) => AsyncError(failure, StackTrace.current),
    };
  }

  AttendanceEntity _unwrap(Result<AttendanceEntity> result) => switch (result) {
    Success(:final value) => value,
    FailureResult(:final failure) => throw failure,
  };
}
