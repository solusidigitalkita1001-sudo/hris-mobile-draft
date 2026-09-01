import 'package:dio/dio.dart';
import 'package:hrm_app/core/network/api_envelope.dart';
import 'package:hrm_app/core/network/api_error_mapper.dart';
import 'package:hrm_app/core/network/api_exception.dart';
import 'package:hrm_app/core/network/request_context.dart';
import 'package:hrm_app/features/attendance/data/dto/attendance_dto.dart';
import 'package:hrm_app/features/attendance/domain/entities/attendance_command.dart';

abstract interface class AttendanceRemoteDataSource {
  Future<AttendanceDto> getToday();
  Future<AttendanceDto> clockIn(AttendanceCommand command);
  Future<AttendanceDto> clockOut(AttendanceCommand command);
}

class DioAttendanceRemoteDataSource implements AttendanceRemoteDataSource {
  const DioAttendanceRemoteDataSource(this._dio, this._context);

  final Dio _dio;
  final RequestContext? Function() _context;

  @override
  Future<AttendanceDto> getToday() async {
    final context = _requireContext();
    try {
      final now = DateTime.now();
      final response = await _dio.get<Map<String, dynamic>>(
        '/attendance',
        queryParameters: {
          'companyId': context.activeCompanyId,
          'employeeId': context.employeeId,
          'month': now.month,
        },
      );
      final envelope = ApiEnvelope.fromJson(response.data ?? const {});
      final records = _records(envelope.data);
      final today = records.cast<Map<String, dynamic>?>().firstWhere(
        (record) => record != null && _isToday(record, now),
        orElse: () => null,
      );
      if (today != null) return AttendanceDto.fromJson(today);
      return AttendanceDto(
        id: '',
        employeeId: context.employeeId!,
        checkedInAt: DateTime(now.year, now.month, now.day),
        status: 'notStarted',
        latitude: 0,
        longitude: 0,
      );
    } on DioException catch (error) {
      throw mapDioException(error);
    }
  }

  @override
  Future<AttendanceDto> clockIn(AttendanceCommand command) async {
    final context = _requireContext();
    final now = DateTime.now().toUtc();
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        '/attendance',
        data: {
          'employeeId': context.employeeId,
          'companyId': context.activeCompanyId,
          'date': DateTime.utc(now.year, now.month, now.day).toIso8601String(),
          'checkIn': now.toIso8601String(),
          'status': 'PRESENT',
          'notes': 'Mobile check-in',
        },
      );
      return AttendanceDto.fromJson(
        _attendanceObject(
          ApiEnvelope.fromJson(response.data ?? const {}).requireObjectData(),
        ),
      );
    } on DioException catch (error) {
      throw mapDioException(error);
    }
  }

  @override
  Future<AttendanceDto> clockOut(AttendanceCommand command) async {
    final current = await getToday();
    if (!current.toEntity().isActive) {
      throw const ApiException('Tidak ada attendance aktif.', statusCode: 409);
    }
    try {
      final response = await _dio.patch<Map<String, dynamic>>(
        '/attendance/${current.id}/checkout',
        data: {'checkOut': DateTime.now().toUtc().toIso8601String()},
      );
      return AttendanceDto.fromJson(
        _attendanceObject(
          ApiEnvelope.fromJson(response.data ?? const {}).requireObjectData(),
        ),
      );
    } on DioException catch (error) {
      throw mapDioException(error);
    }
  }

  RequestContext _requireContext() {
    final value = _context();
    if (value?.employeeId == null || value?.activeCompanyId == null) {
      throw const ApiException('Session employee/company belum tersedia.');
    }
    return value!;
  }

  List<Map<String, dynamic>> _records(Object? data) {
    final raw = data is List
        ? data
        : data is Map<String, dynamic>
        ? (data['items'] ?? data['records'] ?? data['attendances'])
        : null;
    if (raw is! List) return const [];
    return raw.whereType<Map<String, dynamic>>().toList(growable: false);
  }

  bool _isToday(Map<String, dynamic> record, DateTime now) {
    final raw = record['date'] ?? record['checkIn'] ?? record['checkedInAt'];
    final date = raw is String ? DateTime.tryParse(raw)?.toLocal() : null;
    return date != null &&
        date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  Map<String, dynamic> _attendanceObject(Map<String, dynamic> data) {
    final nested = data['attendance'];
    return nested is Map<String, dynamic> ? nested : data;
  }
}

/// In-memory adapter used while the HRMS endpoint is not connected.
/// A Dio adapter can replace it without changing domain or presentation code.
class DemoAttendanceRemoteDataSource implements AttendanceRemoteDataSource {
  DemoAttendanceRemoteDataSource(this._clock);

  final DateTime Function() _clock;
  AttendanceDto? _today;

  @override
  Future<AttendanceDto> getToday() async {
    await Future<void>.delayed(const Duration(milliseconds: 200));
    return _today ??= AttendanceDto(
      id: 'demo-attendance',
      employeeId: 'E011',
      checkedInAt: DateTime(_clock().year, _clock().month, _clock().day, 8, 2),
      status: 'onTime',
      latitude: -6.2088,
      longitude: 106.8456,
    );
  }

  @override
  Future<AttendanceDto> clockIn(AttendanceCommand command) async {
    if (_today?.checkedOutAt == null && _today != null) {
      throw const ApiException(
        'Employee is already clocked in',
        statusCode: 409,
      );
    }
    await Future<void>.delayed(const Duration(milliseconds: 350));
    return _today = AttendanceDto(
      id: 'attendance-${_clock().millisecondsSinceEpoch}',
      employeeId: command.employeeId,
      checkedInAt: _clock(),
      status: 'onTime',
      latitude: command.latitude,
      longitude: command.longitude,
    );
  }

  @override
  Future<AttendanceDto> clockOut(AttendanceCommand command) async {
    final active = _today;
    if (active == null || active.checkedOutAt != null) {
      throw const ApiException('No active attendance', statusCode: 409);
    }
    await Future<void>.delayed(const Duration(milliseconds: 350));
    return _today = AttendanceDto(
      id: active.id,
      employeeId: active.employeeId,
      checkedInAt: active.checkedInAt,
      checkedOutAt: _clock(),
      status: 'completed',
      latitude: command.latitude,
      longitude: command.longitude,
    );
  }
}
