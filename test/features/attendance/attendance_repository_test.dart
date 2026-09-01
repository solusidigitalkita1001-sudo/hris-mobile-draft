import 'package:flutter_test/flutter_test.dart';
import 'package:hrm_app/core/errors/result.dart';
import 'package:hrm_app/features/attendance/data/datasources/attendance_remote_datasource.dart';
import 'package:hrm_app/features/attendance/data/repositories/attendance_repository_impl.dart';
import 'package:hrm_app/features/attendance/domain/entities/attendance_command.dart';

void main() {
  test('clock out returns a completed attendance', () async {
    final now = DateTime(2026, 8, 30, 17);
    final repository = AttendanceRepositoryImpl(
      DemoAttendanceRemoteDataSource(() => now),
    );
    await repository.getToday();

    final result = await repository.clockOut(
      const AttendanceCommand(
        employeeId: 'E011',
        latitude: -6.2,
        longitude: 106.8,
      ),
    );

    expect(result, isA<Success>());
    final attendance = (result as Success).value;
    expect(attendance.isActive, isFalse);
    expect(attendance.checkedOutAt, now);
  });
}
