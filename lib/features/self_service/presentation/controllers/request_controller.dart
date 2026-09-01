import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hrm_app/features/self_service/domain/entities/employee_request.dart';
import 'package:hrm_app/features/self_service/domain/entities/request_command.dart';
import 'package:hrm_app/features/self_service/self_service_dependencies.dart';

class RequestController extends Notifier<List<EmployeeRequest>> {
  @override
  List<EmployeeRequest> build() => ref.read(requestRepositoryProvider).current;

  Future<void> submit(String type) async {
    await ref.read(submitRequestProvider)(SubmitRequestCommand(type: type));
    state = ref.read(requestRepositoryProvider).current;
  }
}
