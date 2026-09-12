enum AttendanceCaptureMethod {
  fingerprint('FINGERPRINT'),
  mobileGps('MOBILE_GPS'),
  manual('MANUAL'),
  faceRecognition('FACE_RECOGNITION');

  const AttendanceCaptureMethod(this.apiValue);

  final String apiValue;
}

class AttendanceContext {
  const AttendanceContext({
    required this.employeeId,
    required this.companyId,
    required this.allowedMethods,
    required this.requiresLocation,
    required this.requiresSelfie,
    required this.isWorkingDay,
    required this.allowHolidayAttendance,
    required this.allowWeekendAttendance,
    required this.warnings,
    this.branchName,
    this.branchCode,
    this.gpsRadiusMeters,
    this.dayType,
    this.workStart,
    this.workEnd,
  });

  final String employeeId;
  final String companyId;
  final String? branchName;
  final String? branchCode;
  final Set<AttendanceCaptureMethod> allowedMethods;
  final bool requiresLocation;
  final bool requiresSelfie;
  final double? gpsRadiusMeters;
  final bool isWorkingDay;
  final bool allowHolidayAttendance;
  final bool allowWeekendAttendance;
  final String? dayType;
  final String? workStart;
  final String? workEnd;
  final List<String> warnings;

  bool get supportsMobileGps =>
      allowedMethods.contains(AttendanceCaptureMethod.mobileGps);
  bool get supportsFaceRecognition =>
      allowedMethods.contains(AttendanceCaptureMethod.faceRecognition);
}
