import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hrm_app/features/profile/domain/entities/employee.dart';
import 'package:hrm_app/features/profile/profile_dependencies.dart';

class ProfileController extends Notifier<Employee> {
  @override
  Employee build() {
    final initial = ref.read(profileRepositoryProvider).currentEmployee;
    Future<void>.microtask(refresh);
    return initial;
  }

  Future<void> refresh() async {
    state = await ref.read(profileRepositoryProvider).refresh();
  }
}
