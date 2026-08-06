import 'package:hrm_app/core/errors/failure.dart';
import 'package:hrm_app/core/utils/either.dart';
import 'package:hrm_app/features/attendance/domain/entities/attendance_entity.dart';

abstract class AttendanceRepository {
  Future<Either<Failure, AttendanceEntity>> clockIn({
    required AttendanceEntity attendance,
  });
  Future<Either<Failure, AttendanceEntity>> clockOut({
    required AttendanceEntity attendance,
  });
}
