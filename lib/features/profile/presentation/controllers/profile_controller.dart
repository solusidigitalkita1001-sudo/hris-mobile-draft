import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hrm_app/core/security/session_lifecycle.dart';
import 'package:hrm_app/features/profile/domain/entities/employee.dart';
import 'package:hrm_app/features/profile/profile_dependencies.dart';

class ProfileController extends Notifier<Employee> {
  late FeatureSession _session;
  @override
  Employee build() {
    _session = ref.watch(featureSessionProvider);
    final session = _session;
    final initial = ref.watch(profileRepositoryProvider).currentEmployee;
    Future<void>.microtask(() async {
      if (session.isCurrent) await refresh();
    });
    return initial;
  }

  Future<void> refresh() async {
    final session = _session;
    if (!session.isCurrent) return;
    final result = await ref.read(profileRepositoryProvider).refresh();
    if (session.isCurrent) state = result;
  }
}
