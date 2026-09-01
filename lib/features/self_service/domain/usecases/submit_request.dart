import 'package:hrm_app/features/self_service/domain/entities/employee_request.dart';
import 'package:hrm_app/features/self_service/domain/entities/request_command.dart';
import 'package:hrm_app/features/self_service/domain/repositories/request_repository.dart';

class SubmitRequest {
  const SubmitRequest(this._repository);
  final RequestRepository _repository;

  Future<EmployeeRequest> call(SubmitRequestCommand command) =>
      _repository.submit(command);
}
