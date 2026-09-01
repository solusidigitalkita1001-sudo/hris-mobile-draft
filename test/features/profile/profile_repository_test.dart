import 'package:flutter_test/flutter_test.dart';
import 'package:hrm_app/core/network/request_context.dart';
import 'package:hrm_app/features/profile/data/datasources/profile_local_datasource.dart';
import 'package:hrm_app/features/profile/data/datasources/profile_remote_datasource.dart';
import 'package:hrm_app/features/profile/data/repositories/profile_repository_impl.dart';
import 'package:hrm_app/features/profile/domain/entities/employee.dart';

void main() {
  test('returns the current employee', () {
    final repository = ProfileRepositoryImpl(DemoProfileLocalDataSource());

    expect(repository.currentEmployee.id, 'E011');
    expect(repository.currentEmployee.department, 'Human Resources');
  });

  test('projects session identity before remote profile arrives', () async {
    const context = RequestContext(
      userId: 'user-1',
      employeeId: 'employee-1',
      activeCompanyId: 'company-1',
      companyScope: ['company-1'],
      displayName: 'Budi Santoso',
      email: 'budi@example.com',
    );
    final repository = ProfileRepositoryImpl(
      DemoProfileLocalDataSource(),
      _ProfileRemote(),
      () => context,
    );

    expect(repository.currentEmployee.name, 'Budi Santoso');
    expect(repository.currentEmployee.email, 'budi@example.com');
    expect((await repository.refresh()).department, 'Engineering');
  });

  test('never falls back to demo employee for a non-employee admin', () {
    const context = RequestContext(
      userId: 'admin-user-id',
      employeeId: null,
      activeCompanyId: null,
      companyScope: [],
      email: 'admin@hrms.com',
      roles: ['SUPER_ADMIN'],
    );
    final repository = ProfileRepositoryImpl(
      DemoProfileLocalDataSource(),
      null,
      () => context,
    );

    expect(repository.currentEmployee.name, 'admin');
    expect(repository.currentEmployee.id, 'admin-user-id');
    expect(repository.currentEmployee.role, 'Super Admin');
    expect(repository.currentEmployee.name, isNot('Siti Rahayu'));
  });
}

class _ProfileRemote implements ProfileRemoteDataSource {
  @override
  Future<Employee> fetch(RequestContext context, Employee fallback) async =>
      Employee(
        id: fallback.id,
        name: fallback.name,
        role: 'Software Engineer',
        department: 'Engineering',
        email: fallback.email,
        phone: '',
        location: 'Jakarta',
        joinDate: '',
        salary: 0,
        initials: fallback.initials,
        avatarColorIndex: fallback.avatarColorIndex,
      );
}
