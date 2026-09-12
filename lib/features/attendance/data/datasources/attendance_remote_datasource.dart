import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:hrm_app/core/network/api_envelope.dart';
import 'package:hrm_app/core/network/api_error_mapper.dart';
import 'package:hrm_app/core/network/api_exception.dart';
import 'package:hrm_app/core/network/request_context.dart';
import 'package:hrm_app/features/attendance/data/dto/attendance_dto.dart';
import 'package:hrm_app/features/attendance/data/dto/attendance_context_dto.dart';
import 'package:hrm_app/features/attendance/domain/entities/attendance_command.dart';
import 'package:hrm_app/features/attendance/domain/entities/attendance_context.dart';

abstract interface class AttendanceRemoteDataSource {
  Future<AttendanceDto> getToday();
  Future<AttendanceContext> getContext();
  Future<AttendanceDto> clockIn(AttendanceCommand command);
  Future<AttendanceDto> clockOut(AttendanceCommand command);
}

class DioAttendanceRemoteDataSource implements AttendanceRemoteDataSource {
  const DioAttendanceRemoteDataSource(this._dio, this._context);

  final Dio _dio;
  final RequestContext? Function() _context;

  @override
  Future<AttendanceContext> getContext() async {
    final context = _requireContext();
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        '/attendance/context',
        queryParameters: {
          'employeeId': context.employeeId,
          'companyId': context.activeCompanyId,
          'date': _dateOnly(DateTime.now()),
        },
      );
      final data = ApiEnvelope.fromJson(
        response.data ?? const {},
      ).requireObjectData();
      final nested = data['context'];
      return AttendanceContextDto.fromJson(
        nested is Map<String, dynamic> ? nested : data,
      ).value;
    } on DioException catch (error) {
      throw mapDioException(error);
    }
  }

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
        checkedInAt: null,
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
    final capturedAt = command.capturedAt.toUtc();
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        '/attendance',
        data: {
          'employeeId': context.employeeId,
          'companyId': context.activeCompanyId,
          'date': _dateStartIso(command.capturedAt.toLocal()),
          'checkIn': capturedAt.toIso8601String(),
          'method': command.method.apiValue,
          'source': 'MOBILE_APP',
          'checkInLatitude': command.latitude,
          'checkInLongitude': command.longitude,
          'deviceGps': _deviceGps(command),
          if (command.selfie case final selfie?)
            'faceRecognition': {
              'selfieImage':
                  'data:${selfie.mimeType};base64,${base64Encode(selfie.bytes)}',
              'selfieFileSizeBytes': selfie.bytes.length,
              'selfieMimeType': selfie.mimeType,
            },
        },
        options: Options(headers: {'Idempotency-Key': command.idempotencyKey}),
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
        data: {
          'checkOut': command.capturedAt.toUtc().toIso8601String(),
          'method': command.method.apiValue,
          'checkOutLatitude': command.latitude,
          'checkOutLongitude': command.longitude,
        },
        options: Options(headers: {'Idempotency-Key': command.idempotencyKey}),
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

  Map<String, dynamic> _deviceGps(AttendanceCommand command) => {
    'isMockLocation': command.isMocked,
    'accuracyMeters': command.accuracyMeters,
    'altitudeMeters': ?command.altitudeMeters,
    'bearingDegrees': ?command.headingDegrees,
  };

  String _dateOnly(DateTime value) =>
      '${value.year.toString().padLeft(4, '0')}-'
      '${value.month.toString().padLeft(2, '0')}-'
      '${value.day.toString().padLeft(2, '0')}';

  String _dateStartIso(DateTime value) =>
      DateTime.utc(value.year, value.month, value.day).toIso8601String();
}
