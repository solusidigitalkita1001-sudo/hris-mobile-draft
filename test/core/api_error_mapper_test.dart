import 'package:flutter_test/flutter_test.dart';
import 'package:hrm_app/core/errors/failure.dart';
import 'package:hrm_app/core/network/api_error_mapper.dart';
import 'package:hrm_app/core/network/api_exception.dart';

void main() {
  test('maps validation error and retains field messages', () {
    final failure = mapApiException(
      const ApiException(
        'Validation failed',
        statusCode: 422,
        code: 'VALIDATION_ERROR',
        fieldErrors: {'email': 'Invalid email format'},
      ),
    );

    expect(failure, isA<ValidationFailure>());
    expect(
      (failure as ValidationFailure).fieldErrors['email'],
      'Invalid email format',
    );
  });

  test('maps token expiry to authentication failure', () {
    final failure = mapApiException(
      const ApiException('Expired', statusCode: 401, code: 'TOKEN_EXPIRED'),
    );

    expect(failure, isA<AuthenticationFailure>());
  });
}
