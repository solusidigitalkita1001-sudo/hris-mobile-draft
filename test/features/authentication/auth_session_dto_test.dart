import 'package:flutter_test/flutter_test.dart';
import 'package:hrm_app/features/authentication/data/dto/auth_session_dto.dart';

void main() {
  test('maps the complete documented login session', () {
    final dto = AuthSessionDto.fromLoginJson({
      'tokens': {
        'accessToken': 'access',
        'refreshToken': 'refresh',
        'expiresIn': 3600,
      },
      'user': {
        'id': 'user-1',
        'employeeId': 'employee-1',
        'companyId': 'company-1',
        'companyScope': ['company-1', 'company-2'],
        'groupId': 'group-1',
        'roles': ['EMPLOYEE'],
        'permissions': ['attendance:read'],
        'mustChangePassword': true,
        'name': 'Test Employee',
        'email': 'employee@example.com',
      },
    });

    final session = dto.toEntity();
    expect(session.accessToken, 'access');
    expect(session.refreshToken, 'refresh');
    expect(session.expiresIn, 3600);
    expect(session.employeeId, 'employee-1');
    expect(session.companyScope, ['company-1', 'company-2']);
    expect(session.roles, ['EMPLOYEE']);
    expect(session.mustChangePassword, isTrue);
  });

  test('stored session round-trips without losing context', () {
    final original = AuthSessionDto.fromLoginJson({
      'tokens': {'accessToken': 'access', 'refreshToken': 'refresh'},
      'user': {
        'id': 'user-1',
        'employeeId': 'employee-1',
        'companyId': 'company-1',
        'companyScope': ['company-1'],
      },
    });

    final restored = AuthSessionDto.fromStoredJson(original.toStoredJson());
    expect(restored.toStoredJson(), original.toStoredJson());
  });

  test('maps a cookie and CSRF login session without a bearer token', () {
    final dto = AuthSessionDto.fromLoginJson({
      'tokens': {'expiresIn': 900},
      'csrfToken': 'csrf-token',
      'user': {
        'id': 'user-1',
        'email': 'admin@hrms.com',
        'roles': ['SUPER_ADMIN'],
      },
    }, authCookie: 'at=jwt; rt=refresh');

    expect(dto.accessToken, isNull);
    expect(dto.authCookie, 'at=jwt; rt=refresh');
    expect(dto.csrfToken, 'csrf-token');
    expect(dto.usesCookieAuth, isTrue);
    expect(dto.expiresIn, 900);
    expect(dto.toEntity().email, 'admin@hrms.com');
    expect(
      AuthSessionDto.fromStoredJson(dto.toStoredJson()).usesCookieAuth,
      isTrue,
    );
  });

  test('rejects a login response without bearer or cookie credentials', () {
    expect(
      () => AuthSessionDto.fromLoginJson({
        'tokens': {'expiresIn': 900},
        'csrfToken': 'csrf-token',
        'user': {'id': 'user-1'},
      }),
      throwsFormatException,
    );
  });
}
