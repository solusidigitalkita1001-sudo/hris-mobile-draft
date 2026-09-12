import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hrm_app/core/security/session_lifecycle.dart';
import 'package:hrm_app/features/dashboard/dashboard_dependencies.dart';
import 'package:hrm_app/features/dashboard/domain/entities/dashboard_snapshot.dart';

class DashboardController extends Notifier<DashboardSnapshot> {
  late FeatureSession _session;
  @override
  DashboardSnapshot build() {
    _session = ref.watch(featureSessionProvider);
    final session = _session;
    final initial = ref.watch(dashboardRepositoryProvider).current;
    Future<void>.microtask(() async {
      if (session.isCurrent) await refresh();
    });
    return initial;
  }

  Future<void> refresh() async {
    final session = _session;
    if (!session.isCurrent) return;
    final result = await ref.read(dashboardRepositoryProvider).refresh();
    if (session.isCurrent) state = result;
  }
}
