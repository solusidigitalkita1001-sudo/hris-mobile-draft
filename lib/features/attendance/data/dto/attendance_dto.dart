import 'package:hrm_app/features/attendance/domain/entities/attendance_entity.dart';

class AttendanceDto {
  const AttendanceDto({
    required this.id,
    required this.employeeId,
    required this.checkedInAt,
    this.checkedOutAt,
    required this.status,
    required this.latitude,
    required this.longitude,
  });

  factory AttendanceDto.fromJson(Map<String, dynamic> json) => AttendanceDto(
    id: json['id'] as String? ?? '',
    employeeId: (json['employeeId'] ?? json['employee_id']) as String? ?? '',
    checkedInAt: DateTime.parse(
      (json['checkIn'] ??
              json['checkedInAt'] ??
              json['checked_in_at'] ??
              json['date'])
          as String,
    ),
    checkedOutAt:
        (json['checkOut'] ?? json['checkedOutAt'] ?? json['checked_out_at']) ==
            null
        ? null
        : DateTime.parse(
            (json['checkOut'] ?? json['checkedOutAt'] ?? json['checked_out_at'])
                as String,
          ),
    status: json['status'] as String? ?? 'PRESENT',
    latitude: (json['latitude'] as num?)?.toDouble() ?? 0,
    longitude: (json['longitude'] as num?)?.toDouble() ?? 0,
  );

  final String id;
  final String employeeId;
  final DateTime checkedInAt;
  final DateTime? checkedOutAt;
  final String status;
  final double latitude;
  final double longitude;

  AttendanceEntity toEntity() => AttendanceEntity(
    id: id,
    userId: employeeId,
    checkedInAt: checkedInAt,
    checkedOutAt: checkedOutAt,
    status: _parseStatus(status),
    latitude: latitude,
    longitude: longitude,
  );
}

AttendanceStatus _parseStatus(String value) {
  final normalized = value.replaceAll('_', '').toLowerCase();
  if (normalized == 'present' || normalized == 'ontime') {
    return AttendanceStatus.onTime;
  }
  if (normalized == 'completed') return AttendanceStatus.completed;
  if (normalized == 'late') return AttendanceStatus.late;
  for (final status in AttendanceStatus.values) {
    if (status.name.toLowerCase() == normalized) return status;
  }
  throw FormatException('Unknown attendance status: $value');
}
