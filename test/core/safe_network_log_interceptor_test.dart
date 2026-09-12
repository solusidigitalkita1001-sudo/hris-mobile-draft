import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hrm_app/core/network/safe_network_log_interceptor.dart';

void main() {
  test('success logs metadata without request or response data', () async {
    final logs = <String>[];
    final dio = Dio()..httpClientAdapter = _FixtureAdapter(statusCode: 200);
    addTearDown(() => dio.close(force: true));
    dio.interceptors.add(SafeNetworkLogInterceptor(logs.add));

    await dio.post<dynamic>(
      'https://api.example.test/employees/employee-secret/payroll',
      queryParameters: const {'email': 'employee@example.test'},
      data: const {'password': 'password-secret'},
      options: Options(
        headers: const {
          'Authorization': 'Bearer access-token-secret',
          'Cookie': 'at=cookie-secret; csrf=csrf-secret',
          'X-CSRF-Token': 'csrf-secret',
        },
      ),
    );

    final output = logs.join('\n');
    expect(output, contains('HTTP #1 POST started'));
    expect(output, contains('HTTP #1 POST 200'));
    _expectNoSensitiveData(output);
  });

  test('error logs status and category without error payload', () async {
    final logs = <String>[];
    final dio = Dio()..httpClientAdapter = _FixtureAdapter(statusCode: 401);
    addTearDown(() => dio.close(force: true));
    dio.interceptors.add(SafeNetworkLogInterceptor(logs.add));

    await expectLater(
      dio.get<dynamic>(
        'https://api.example.test/auth/me?token=query-token-secret',
      ),
      throwsA(isA<DioException>()),
    );

    final output = logs.join('\n');
    expect(output, contains('failed status=401 type=badResponse'));
    _expectNoSensitiveData(output);
  });
}

void _expectNoSensitiveData(String output) {
  for (final value in const [
    'employee-secret',
    'employee@example.test',
    'password-secret',
    'access-token-secret',
    'cookie-secret',
    'csrf-secret',
    'query-token-secret',
    '/auth/me',
    '/payroll',
    'set-cookie',
  ]) {
    expect(output, isNot(contains(value)), reason: 'Log leaked: $value');
  }
}

class _FixtureAdapter implements HttpClientAdapter {
  _FixtureAdapter({required this.statusCode});

  final int statusCode;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async => ResponseBody.fromString(
    '{"accessToken":"response-token-secret",'
    '"employee":{"email":"employee@example.test"}}',
    statusCode,
    headers: {
      Headers.contentTypeHeader: [Headers.jsonContentType],
      'set-cookie': ['at=response-cookie-secret; HttpOnly'],
    },
  );

  @override
  void close({bool force = false}) {}
}
