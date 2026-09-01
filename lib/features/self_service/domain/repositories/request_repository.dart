import 'package:hrm_app/features/self_service/domain/entities/employee_request.dart';
import 'package:hrm_app/features/self_service/domain/entities/request_command.dart';

abstract interface class RequestRepository {
  List<EmployeeRequest> get current;
  Future<List<EmployeeRequest>> refresh();
  Future<EmployeeRequest> submit(SubmitRequestCommand command);
}
