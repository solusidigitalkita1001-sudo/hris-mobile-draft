import 'package:flutter_test/flutter_test.dart';
import 'package:hrm_app/core/network/request_context.dart';
import 'package:hrm_app/features/dashboard/data/datasources/dashboard_local_datasource.dart';
import 'package:hrm_app/features/dashboard/data/datasources/dashboard_remote_datasource.dart';
import 'package:hrm_app/features/dashboard/data/repositories/dashboard_repository_impl.dart';
import 'package:hrm_app/features/dashboard/domain/entities/dashboard_snapshot.dart';

void main() {
  test(
    'exposes the dashboard projection without presentation dependencies',
    () {
      final repository = DashboardRepositoryImpl(
        DemoDashboardLocalDataSource(),
      );

      expect(repository.current.employee.name, 'Siti Rahayu');
      expect(repository.current.leaveBalances, hasLength(4));
      expect(repository.current.announcements, hasLength(3));
    },
  );

  test('uses authenticated identity and refreshes API projection', () async {
    const context = RequestContext(
      userId: 'user-1',
      employeeId: 'employee-1',
      activeCompanyId: 'company-1',
      companyScope: ['company-1'],
      displayName: 'Budi Santoso',
      email: 'budi@example.com',
    );
    final repository = DashboardRepositoryImpl(
      DemoDashboardLocalDataSource(),
      _DashboardRemote(),
      () => context,
    );

    expect(repository.current.employee.name, 'Budi Santoso');
    expect(repository.current.leaveBalances, isEmpty);
    final refreshed = await repository.refresh();
    expect(refreshed.leaveBalances.single.total, 12);
  });
}

class _DashboardRemote implements DashboardRemoteDataSource {
  @override
  Future<DashboardSnapshot> fetch(
    RequestContext context,
    DashboardSnapshot fallback,
  ) async => DashboardSnapshot(
    employee: fallback.employee,
    leaveBalances: const [
      LeaveBalance(type: 'Annual Leave', total: 12, used: 2, colorIndex: 0),
    ],
    announcements: const [],
  );
}
