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
        'permissions': ['attendance.read'],
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
}
