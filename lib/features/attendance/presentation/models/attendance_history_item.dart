enum AttendanceHistoryStatus { onTime, late, absent, leave }

class AttendanceHistoryItem {
  const AttendanceHistoryItem({
    required this.date,
    required this.day,
    required this.clockIn,
    required this.clockOut,
    required this.hours,
    required this.status,
  });

  final String date;
  final String day;
  final String clockIn;
  final String clockOut;
  final String hours;
  final AttendanceHistoryStatus status;
}

abstract final class AttendanceHistoryData {
  static const thisWeek = [
    AttendanceHistoryItem(
      date: 'Jun 16',
      day: 'Mon',
      clockIn: '08:02',
      clockOut: '17:15',
      hours: '9h 13m',
      status: AttendanceHistoryStatus.onTime,
    ),
    AttendanceHistoryItem(
      date: 'Jun 17',
      day: 'Tue',
      clockIn: '08:10',
      clockOut: '17:30',
      hours: '9h 20m',
      status: AttendanceHistoryStatus.onTime,
    ),
    AttendanceHistoryItem(
      date: 'Jun 18',
      day: 'Wed',
      clockIn: '09:05',
      clockOut: '18:00',
      hours: '8h 55m',
      status: AttendanceHistoryStatus.late,
    ),
    AttendanceHistoryItem(
      date: 'Jun 19',
      day: 'Thu',
      clockIn: '08:00',
      clockOut: '17:00',
      hours: '9h 00m',
      status: AttendanceHistoryStatus.onTime,
    ),
    AttendanceHistoryItem(
      date: 'Jun 20',
      day: 'Fri',
      clockIn: '08:02',
      clockOut: '—',
      hours: '—',
      status: AttendanceHistoryStatus.onTime,
    ),
  ];
}
