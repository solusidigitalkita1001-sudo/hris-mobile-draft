import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hrm_app/features/dashboard/dashboard_dependencies.dart';
import 'package:hrm_app/features/dashboard/domain/entities/dashboard_snapshot.dart';

class DashboardController extends Notifier<DashboardSnapshot> {
  @override
  DashboardSnapshot build() {
    final initial = ref.read(dashboardRepositoryProvider).current;
    Future<void>.microtask(refresh);
    return initial;
  }

  Future<void> refresh() async {
    state = await ref.read(dashboardRepositoryProvider).refresh();
  }
}
