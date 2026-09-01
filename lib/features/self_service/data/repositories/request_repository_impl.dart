import 'package:hrm_app/features/self_service/data/datasources/request_local_datasource.dart';
import 'package:hrm_app/features/self_service/domain/entities/employee_request.dart';
import 'package:hrm_app/features/self_service/domain/entities/request_command.dart';
import 'package:hrm_app/features/self_service/domain/repositories/request_repository.dart';

class RequestRepositoryImpl implements RequestRepository {
  RequestRepositoryImpl(this._local);
  final RequestLocalDataSource _local;

  @override
  List<EmployeeRequest> get current => _local.readAll();

  @override
  Future<List<EmployeeRequest>> refresh() async => _local.readAll();

  @override
  Future<EmployeeRequest> submit(SubmitRequestCommand command) =>
      _local.insert(command);
}
