import 'package:hrm_app/core/errors/result.dart';
import 'package:hrm_app/core/services/location_gateway.dart';
import 'package:hrm_app/features/attendance/domain/entities/attendance_command.dart';
import 'package:hrm_app/features/attendance/domain/entities/attendance_entity.dart';
import 'package:hrm_app/features/attendance/domain/repositories/attendance_repository.dart';

class ClockIn {
  const ClockIn(this._repository, this._locationService);
  final AttendanceRepository _repository;
  final LocationGateway _locationService;

  Future<Result<AttendanceEntity>> call(String employeeId) async {
    final position = await _locationService.currentPosition();
    return _repository.clockIn(
      AttendanceCommand(
        employeeId: employeeId,
        latitude: position.latitude,
        longitude: position.longitude,
      ),
    );
  }
}
