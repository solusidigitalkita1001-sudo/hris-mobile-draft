import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hrm_app/core/network/request_context.dart';
import 'package:hrm_app/core/services/selfie_gateway.dart';
import 'package:hrm_app/features/attendance/data/datasources/attendance_remote_datasource.dart';
import 'package:hrm_app/features/attendance/domain/entities/attendance_command.dart';
import 'package:hrm_app/features/attendance/domain/entities/attendance_context.dart';

void main() {
  const context = RequestContext(
    userId: '00000000-0000-4000-8000-000000000001',
    employeeId: '00000000-0000-4000-8000-000000000002',
    activeCompanyId: '00000000-0000-4000-8000-000000000003',
    companyScope: ['00000000-0000-4000-8000-000000000003'],
  );

  test(
    'loads resolved attendance context for active employee and company',
    () async {
      final adapter = _AttendanceAdapter();
      final dio = Dio()..httpClientAdapter = adapter;
      addTearDown(dio.close);
      final remote = DioAttendanceRemoteDataSource(dio, () => context);

      final result = await remote.getContext();

      final request = adapter.requests.single;
      expect(request.method, 'GET');
      expect(request.path, '/attendance/context');
      expect(request.queryParameters['employeeId'], context.employeeId);
      expect(request.queryParameters['companyId'], context.activeCompanyId);
      expect(request.queryParameters['date'], matches(r'^\d{4}-\d{2}-\d{2}$'));
      expect(result.branchName, 'Kantor Pusat');
      expect(result.requiresLocation, isTrue);
      expect(result.requiresSelfie, isTrue);
      expect(result.supportsFaceRecognition, isTrue);
      expect(result.gpsRadiusMeters, 150);
    },
  );

  test(
    'clock in sends measured GPS and captured selfie to the server',
    () async {
      final adapter = _AttendanceAdapter();
      final dio = Dio()..httpClientAdapter = adapter;
      addTearDown(dio.close);
      final remote = DioAttendanceRemoteDataSource(dio, () => context);
      final capturedAt = DateTime.parse('2026-09-11T08:15:30+07:00');

      await remote.clockIn(
        AttendanceCommand(
          employeeId: context.employeeId!,
          latitude: -6.2088,
          longitude: 106.8456,
          accuracyMeters: 7.5,
          capturedAt: capturedAt,
          isMocked: false,
          altitudeMeters: 12,
          headingDegrees: 90,
          method: AttendanceCaptureMethod.faceRecognition,
          idempotencyKey: 'request-123',
          selfie: CapturedSelfie(
            bytes: Uint8List.fromList([1, 2, 3]),
            mimeType: 'image/jpeg',
            capturedAt: capturedAt.toUtc(),
          ),
        ),
      );

      final request = adapter.requests.single;
      final body = Map<String, dynamic>.from(request.data as Map);
      expect(request.method, 'POST');
      expect(request.path, '/attendance');
      expect(request.headers['Idempotency-Key'], 'request-123');
      expect(body['employeeId'], context.employeeId);
      expect(body['companyId'], context.activeCompanyId);
      expect(body['date'], '2026-09-11T00:00:00.000Z');
      expect(body['checkIn'], capturedAt.toUtc().toIso8601String());
      expect(body['method'], 'FACE_RECOGNITION');
      expect(body['source'], 'MOBILE_APP');
      expect(body['checkInLatitude'], -6.2088);
      expect(body['checkInLongitude'], 106.8456);
      expect(body, isNot(contains('status')));
      expect(body['deviceGps'], {
        'isMockLocation': false,
        'accuracyMeters': 7.5,
        'altitudeMeters': 12.0,
        'bearingDegrees': 90.0,
      });
      expect(body['faceRecognition'], {
        'selfieImage': 'data:image/jpeg;base64,AQID',
        'selfieFileSizeBytes': 3,
        'selfieMimeType': 'image/jpeg',
      });
    },
  );

  test(
    'clock out finds active server record and sends checkout coordinates',
    () async {
      final adapter = _AttendanceAdapter(activeRecord: true);
      final dio = Dio()..httpClientAdapter = adapter;
      addTearDown(dio.close);
      final remote = DioAttendanceRemoteDataSource(dio, () => context);
      final capturedAt = DateTime.utc(2026, 9, 11, 10, 30);

      final result = await remote.clockOut(
        AttendanceCommand(
          employeeId: context.employeeId!,
          latitude: -6.21,
          longitude: 106.84,
          accuracyMeters: 9,
          capturedAt: capturedAt,
          isMocked: false,
          method: AttendanceCaptureMethod.mobileGps,
          idempotencyKey: 'request-out',
        ),
      );

      expect(adapter.requests, hasLength(2));
      final request = adapter.requests.last;
      expect(request.method, 'PATCH');
      expect(request.path, '/attendance/attendance-1/checkout');
      expect(request.headers['Idempotency-Key'], 'request-out');
      expect(request.data, {
        'checkOut': capturedAt.toIso8601String(),
        'method': 'MOBILE_GPS',
        'checkOutLatitude': -6.21,
        'checkOutLongitude': 106.84,
      });
      expect(result.checkedOutAt, isNotNull);
    },
  );
}

class _AttendanceAdapter implements HttpClientAdapter {
  _AttendanceAdapter({this.activeRecord = false});

  final bool activeRecord;
  final List<RequestOptions> requests = [];

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    requests.add(options);
    final now = DateTime.now();
    final today =
        '${now.year.toString().padLeft(4, '0')}-'
        '${now.month.toString().padLeft(2, '0')}-'
        '${now.day.toString().padLeft(2, '0')}T01:15:30.000Z';
    final body = switch ((options.method, options.path)) {
      ('GET', '/attendance/context') => {
        'success': true,
        'data': {
          'employeeId': '00000000-0000-4000-8000-000000000002',
          'companyId': '00000000-0000-4000-8000-000000000003',
          'branch': {'name': 'Kantor Pusat', 'code': 'HQ'},
          'schedule': {
            'isWorkingDay': true,
            'dayType': 'WORKING_DAY',
            'workStart': '08:00',
            'workEnd': '17:00',
          },
          'policy': {
            'requiresLocation': true,
            'requiresSelfie': true,
            'gpsRadiusMeters': 150,
            'allowHolidayAttendance': false,
            'allowWeekendAttendance': false,
          },
          'allowedMethods': ['FACE_RECOGNITION'],
          'warnings': <String>[],
        },
      },
      ('GET', '/attendance') => {
        'success': true,
        'data': activeRecord
            ? [
                {
                  'id': 'attendance-1',
                  'employeeId': '00000000-0000-4000-8000-000000000002',
                  'date': today,
                  'checkIn': today,
                  'status': 'PRESENT',
                },
              ]
            : <Object>[],
      },
      ('POST', '/attendance') => {
        'success': true,
        'data': {
          'attendance': {
            'id': 'attendance-1',
            'employeeId': '00000000-0000-4000-8000-000000000002',
            'checkIn': today,
            'status': 'PRESENT',
          },
        },
      },
      ('PATCH', '/attendance/attendance-1/checkout') => {
        'success': true,
        'data': {
          'attendance': {
            'id': 'attendance-1',
            'employeeId': '00000000-0000-4000-8000-000000000002',
            'checkIn': today,
            'checkOut': '2026-09-11T10:30:00.000Z',
            'status': 'PRESENT',
          },
        },
      },
      _ => {'success': false, 'message': 'Unexpected request'},
    };
    return ResponseBody.fromString(
      jsonEncode(body),
      200,
      headers: {
        Headers.contentTypeHeader: ['application/json'],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}
