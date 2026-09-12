import 'package:hrm_app/features/dashboard/domain/entities/dashboard_snapshot.dart';

abstract interface class DashboardLocalDataSource {
  DashboardSnapshot read();
}

class EmptyDashboardLocalDataSource implements DashboardLocalDataSource {
  @override
  DashboardSnapshot read() => const DashboardSnapshot(
    employee: DashboardEmployee(
      name: 'User',
      initials: 'U',
      avatarColorIndex: 0,
    ),
    leaveBalances: [],
    announcements: [],
  );
}

class DemoDashboardLocalDataSource implements DashboardLocalDataSource {
  @override
  DashboardSnapshot read() => const DashboardSnapshot(
    employee: DashboardEmployee(
      name: 'Siti Rahayu',
      initials: 'SR',
      avatarColorIndex: 2,
    ),
    leaveBalances: [
      LeaveBalance(type: 'Annual Leave', total: 12, used: 8, colorIndex: 0),
      LeaveBalance(type: 'Sick Leave', total: 12, used: 3, colorIndex: 3),
      LeaveBalance(type: 'Personal Leave', total: 3, used: 1, colorIndex: 2),
      LeaveBalance(type: 'Carry Forward', total: 5, used: 0, colorIndex: 1),
    ],
    announcements: [
      Announcement(
        title: 'Q2 Performance Review Schedule Released',
        body:
            'Self-evaluations due by June 27. Peer reviews to follow from July 1–5.',
        time: '2 hours ago',
        category: 'HR',
      ),
      Announcement(
        title: 'New Leave Policy Effective July 1, 2025',
        body:
            'Annual leave accrual has been updated. Please review the updated policy document in the HR portal.',
        time: '1 day ago',
        category: 'Policy',
      ),
      Announcement(
        title: 'June Payroll Disbursement: Jun 25',
        body:
            'June 2025 payroll will be processed and disbursed on Wednesday, June 25.',
        time: '2 days ago',
        category: 'Payroll',
      ),
    ],
  );
}
