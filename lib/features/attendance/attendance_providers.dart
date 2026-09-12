import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hrm_app/core/security/session_lifecycle.dart';
import 'package:hrm_app/features/attendance/domain/entities/attendance_entity.dart';
import 'package:hrm_app/features/attendance/presentation/controllers/attendance_controller.dart';

final attendanceControllerProvider = AsyncNotifierProvider.autoDispose
    .family<AttendanceController, AttendanceEntity, FeatureSession>(
      AttendanceController.new,
    );
