class AttendanceEntity {
  const AttendanceEntity({
    required this.id,
    required this.userId,
    required this.checkedInAt,
    this.checkedOutAt,
    required this.status,
    required this.latitude,
    required this.longitude,
  });

  final String id;
  final String userId;
  final DateTime checkedInAt;
  final DateTime? checkedOutAt;
  final AttendanceStatus status;
  final double latitude;
  final double longitude;

  bool get isActive => id.isNotEmpty && checkedOutAt == null;
}

enum AttendanceStatus { notStarted, onTime, late, completed }
