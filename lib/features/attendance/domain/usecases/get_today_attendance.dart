import 'package:hrm_app/core/errors/result.dart';
import 'package:hrm_app/features/attendance/domain/entities/attendance_entity.dart';
import 'package:hrm_app/features/attendance/domain/repositories/attendance_repository.dart';

class GetTodayAttendance {
  const GetTodayAttendance(this._repository);
  final AttendanceRepository _repository;

  Future<Result<AttendanceEntity>> call() => _repository.getToday();
}
