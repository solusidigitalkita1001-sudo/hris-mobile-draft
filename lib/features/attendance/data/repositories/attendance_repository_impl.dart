import 'package:hrm_app/core/errors/failure.dart';
import 'package:hrm_app/core/errors/result.dart';
import 'package:hrm_app/core/network/api_exception.dart';
import 'package:hrm_app/core/network/api_error_mapper.dart';
import 'package:hrm_app/features/attendance/data/datasources/attendance_remote_datasource.dart';
import 'package:hrm_app/features/attendance/data/dto/attendance_dto.dart';
import 'package:hrm_app/features/attendance/domain/entities/attendance_command.dart';
import 'package:hrm_app/features/attendance/domain/entities/attendance_entity.dart';
import 'package:hrm_app/features/attendance/domain/repositories/attendance_repository.dart';

class AttendanceRepositoryImpl implements AttendanceRepository {
  const AttendanceRepositoryImpl(this._remote);
  final AttendanceRemoteDataSource _remote;

  @override
  Future<Result<AttendanceEntity>> getToday() => _guard(_remote.getToday);

  @override
  Future<Result<AttendanceEntity>> clockIn(AttendanceCommand command) =>
      _guard(() => _remote.clockIn(command));

  @override
  Future<Result<AttendanceEntity>> clockOut(AttendanceCommand command) =>
      _guard(() => _remote.clockOut(command));

  Future<Result<AttendanceEntity>> _guard(
    Future<AttendanceDto> Function() operation,
  ) async {
    try {
      final dto = await operation();
      return Success(dto.toEntity());
    } on ApiException catch (error) {
      return FailureResult(mapApiException(error));
    } catch (_) {
      return const FailureResult(ServerFailure('Unexpected attendance error'));
    }
  }
}
