import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hrm_app/features/dashboard/domain/entities/dashboard_snapshot.dart';
import 'package:hrm_app/features/dashboard/presentation/controllers/dashboard_controller.dart';

final dashboardControllerProvider =
    NotifierProvider<DashboardController, DashboardSnapshot>(
      DashboardController.new,
    );
