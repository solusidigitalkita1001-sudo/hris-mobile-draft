class AttendanceCommand {
  const AttendanceCommand({
    required this.employeeId,
    required this.latitude,
    required this.longitude,
  });

  final String employeeId;
  final double latitude;
  final double longitude;
}
