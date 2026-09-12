import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hrm_app/core/errors/result.dart';
import 'package:hrm_app/core/network/request_context.dart';
import 'package:hrm_app/core/security/session_lifecycle.dart';
import 'package:hrm_app/core/services/selfie_gateway.dart';
import 'package:hrm_app/features/attendance/attendance_dependencies.dart';
import 'package:hrm_app/features/attendance/domain/entities/attendance_entity.dart';

class AttendanceController
    extends AutoDisposeFamilyAsyncNotifier<AttendanceEntity, FeatureSession> {
  late FeatureSession _session;
  bool _active = false;
  bool _submitting = false;
  @override
  Future<AttendanceEntity> build(FeatureSession session) async {
    _session = session;
    _active = true;
    ref.onDispose(() => _active = false);
    final result = await ref.watch(getTodayAttendanceProvider)();
    return _unwrap(result);
  }

  Future<bool> toggleAttendance({CapturedSelfie? selfie}) async {
    final session = _session;
    if (!_active || !session.isCurrent || _submitting) return false;
    final clockIn = ref.read(clockInProvider);
    final clockOut = ref.read(clockOutProvider);
    final employeeId = ref.read(requestContextProvider)?.employeeId;
    if (employeeId == null) {
      state = AsyncError(
        StateError('Employee ID tidak tersedia pada session.'),
        StackTrace.current,
      );
      return false;
    }
    final current =
        state.valueOrNull ??
        _unwrap(await ref.read(getTodayAttendanceProvider)());
    if (!_active || !session.isCurrent) return false;
    _submitting = true;
    state = const AsyncLoading<AttendanceEntity>().copyWithPrevious(state);
    late final Result<AttendanceEntity> result;
    try {
      result = current.isActive
          ? await clockOut(employeeId)
          : await clockIn(employeeId, selfie: selfie);
    } catch (error, stackTrace) {
      if (_active && session.isCurrent) {
        state = AsyncError<AttendanceEntity>(
          error,
          stackTrace,
        ).copyWithPrevious(AsyncData(current));
      }
      _submitting = false;
      return false;
    }
    _submitting = false;
    if (!_active || !session.isCurrent) return false;
    state = switch (result) {
      Success(:final value) => AsyncData(value),
      FailureResult(:final failure) => AsyncError<AttendanceEntity>(
        failure,
        StackTrace.current,
      ).copyWithPrevious(AsyncData(current)),
    };
    return result is Success<AttendanceEntity>;
  }

  AttendanceEntity _unwrap(Result<AttendanceEntity> result) => switch (result) {
    Success(:final value) => value,
    FailureResult(:final failure) => throw failure,
  };
}
