class AttendanceEntity {
  const AttendanceEntity({
    required this.id,
    required this.userId,
    required this.checkInTime,
    required this.checkOutTime,
    required this.status,
    required this.location,
  });

  final String id;
  final String userId;
  final String checkInTime;
  final String checkOutTime;
  final String status;
  final String location;
}
