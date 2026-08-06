// ─── Models ───────────────────────────────────────────────────────────────────

class Employee {
  final String id;
  final String name;
  final String role;
  final String department;
  final String email;
  final String phone;
  final String location;
  final String joinDate;
  final int salary;
  final String initials;
  final int avatarColorIndex;

  const Employee({
    required this.id,
    required this.name,
    required this.role,
    required this.department,
    required this.email,
    required this.phone,
    required this.location,
    required this.joinDate,
    required this.salary,
    required this.initials,
    required this.avatarColorIndex,
  });
}

class AttendanceRecord {
  final String date;
  final String day;
  final String clockIn;
  final String clockOut;
  final String hours;
  final AttendanceStatus status;

  const AttendanceRecord({
    required this.date,
    required this.day,
    required this.clockIn,
    required this.clockOut,
    required this.hours,
    required this.status,
  });
}

enum AttendanceStatus { onTime, late, absent, leave }

class LeaveBalance {
  final String type;
  final int total;
  final int used;
  final int colorIndex;

  const LeaveBalance({
    required this.type,
    required this.total,
    required this.used,
    required this.colorIndex,
  });

  int get remaining => total - used;
  double get percentage => used / total;
}

class Request {
  final String id;
  final String type;
  final String dateRange;
  final String submittedOn;
  final RequestStatus status;

  const Request({
    required this.id,
    required this.type,
    required this.dateRange,
    required this.submittedOn,
    required this.status,
  });
}

enum RequestStatus { approved, pending, rejected }

class Announcement {
  final String title;
  final String body;
  final String time;
  final String category;

  const Announcement({
    required this.title,
    required this.body,
    required this.time,
    required this.category,
  });
}

// ─── Static Data ─────────────────────────────────────────────────────────────

class AppData {
  AppData._();

  static const currentEmployee = Employee(
    id: 'E011',
    name: 'Siti Rahayu',
    role: 'HR Director',
    department: 'Human Resources',
    email: 's.rahayu@acme.co.id',
    phone: '+62 811 4433 2211',
    location: 'Jakarta · Menara ACME',
    joinDate: '30 Nov 2017',
    salary: 48000000,
    initials: 'SR',
    avatarColorIndex: 2,
  );

  static const List<LeaveBalance> leaveBalances = [
    LeaveBalance(type: 'Annual Leave',   total: 12, used: 8,  colorIndex: 0),
    LeaveBalance(type: 'Sick Leave',     total: 12, used: 3,  colorIndex: 3),
    LeaveBalance(type: 'Personal Leave', total: 3,  used: 1,  colorIndex: 2),
    LeaveBalance(type: 'Carry Forward',  total: 5,  used: 0,  colorIndex: 1),
  ];

  static const List<AttendanceRecord> thisWeek = [
    AttendanceRecord(date: 'Jun 16', day: 'Mon', clockIn: '08:02', clockOut: '17:15', hours: '9h 13m', status: AttendanceStatus.onTime),
    AttendanceRecord(date: 'Jun 17', day: 'Tue', clockIn: '08:10', clockOut: '17:30', hours: '9h 20m', status: AttendanceStatus.onTime),
    AttendanceRecord(date: 'Jun 18', day: 'Wed', clockIn: '09:05', clockOut: '18:00', hours: '8h 55m', status: AttendanceStatus.late),
    AttendanceRecord(date: 'Jun 19', day: 'Thu', clockIn: '08:00', clockOut: '17:00', hours: '9h 00m', status: AttendanceStatus.onTime),
    AttendanceRecord(date: 'Jun 20', day: 'Fri', clockIn: '08:02', clockOut: '—',     hours: '—',      status: AttendanceStatus.onTime),
  ];

  static const List<Request> recentRequests = [
    Request(id: 'R001', type: 'Annual Leave',   dateRange: 'Jun 23 – Jun 25, 2025', submittedOn: 'Jun 12', status: RequestStatus.approved),
    Request(id: 'R002', type: 'Overtime Claim', dateRange: 'Jun 18, 2025',          submittedOn: 'Jun 19', status: RequestStatus.pending),
    Request(id: 'R003', type: 'WFH Request',    dateRange: 'Jun 16 – Jun 17, 2025', submittedOn: 'Jun 14', status: RequestStatus.approved),
    Request(id: 'R004', type: 'Sick Leave',     dateRange: 'May 28, 2025',          submittedOn: 'May 28', status: RequestStatus.approved),
    Request(id: 'R005', type: 'Business Trip',  dateRange: 'May 12 – May 14, 2025', submittedOn: 'May 8',  status: RequestStatus.rejected),
  ];

  static const List<Announcement> announcements = [
    Announcement(
      title: 'Q2 Performance Review Schedule Released',
      body: 'Self-evaluations due by June 27. Peer reviews to follow from July 1–5.',
      time: '2 hours ago',
      category: 'HR',
    ),
    Announcement(
      title: 'New Leave Policy Effective July 1, 2025',
      body: 'Annual leave accrual has been updated. Please review the updated policy document in the HR portal.',
      time: '1 day ago',
      category: 'Policy',
    ),
    Announcement(
      title: 'June Payroll Disbursement — Jun 25',
      body: 'June 2025 payroll will be processed and disbursed on Wednesday, June 25.',
      time: '2 days ago',
      category: 'Payroll',
    ),
  ];

  // Attendance data for the trend chart (fl_chart)
  static const List<Map<String, dynamic>> attendanceTrend = [
    {'day': 'Mon', 'present': 145.0, 'late': 8.0},
    {'day': 'Tue', 'present': 152.0, 'late': 5.0},
    {'day': 'Wed', 'present': 148.0, 'late': 10.0},
    {'day': 'Thu', 'present': 155.0, 'late': 3.0},
    {'day': 'Fri', 'present': 140.0, 'late': 7.0},
  ];
}
