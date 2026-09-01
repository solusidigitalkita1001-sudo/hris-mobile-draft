import 'package:hrm_app/core/errors/result.dart';
import 'package:hrm_app/features/attendance/domain/entities/attendance_command.dart';
import 'package:hrm_app/features/attendance/domain/entities/attendance_entity.dart';

abstract class AttendanceRepository {
  Future<Result<AttendanceEntity>> getToday();
  Future<Result<AttendanceEntity>> clockIn(AttendanceCommand command);
  Future<Result<AttendanceEntity>> clockOut(AttendanceCommand command);
}
