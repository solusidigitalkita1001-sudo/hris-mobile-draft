import 'package:hrm_app/features/dashboard/domain/entities/dashboard_snapshot.dart';

abstract interface class DashboardRepository {
  DashboardSnapshot get current;
  Future<DashboardSnapshot> refresh();
}
