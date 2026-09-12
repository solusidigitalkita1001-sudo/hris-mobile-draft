import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hrm_app/core/security/session_lifecycle.dart';
import 'package:hrm_app/features/self_service/domain/entities/employee_request.dart';
import 'package:hrm_app/features/self_service/domain/entities/request_command.dart';
import 'package:hrm_app/features/self_service/self_service_dependencies.dart';

class RequestController extends Notifier<List<EmployeeRequest>> {
  late FeatureSession _session;
  @override
  List<EmployeeRequest> build() {
    _session = ref.watch(featureSessionProvider);
    return ref.watch(requestRepositoryProvider).current;
  }

  Future<void> submit(String type) async {
    final session = _session;
    if (!session.isCurrent) return;
    final repository = ref.read(requestRepositoryProvider);
    await ref.read(submitRequestProvider)(SubmitRequestCommand(type: type));
    if (session.isCurrent) state = repository.current;
  }
}
