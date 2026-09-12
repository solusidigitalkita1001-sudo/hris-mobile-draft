import 'package:hrm_app/features/self_service/domain/entities/employee_request.dart';
import 'package:hrm_app/features/self_service/domain/entities/request_command.dart';

abstract interface class RequestLocalDataSource {
  List<EmployeeRequest> readAll();
  Future<EmployeeRequest> insert(SubmitRequestCommand command);
}

class UnavailableRequestLocalDataSource implements RequestLocalDataSource {
  @override
  List<EmployeeRequest> readAll() => const [];

  @override
  Future<EmployeeRequest> insert(SubmitRequestCommand command) =>
      Future.error(UnsupportedError('Pengajuan belum terhubung ke server.'));
}

class DemoRequestLocalDataSource implements RequestLocalDataSource {
  final List<EmployeeRequest> _items = [
    const EmployeeRequest(
      id: 'R001',
      type: 'Annual Leave',
      dateRange: 'Jun 23 – Jun 25, 2025',
      submittedOn: 'Jun 12',
      status: RequestStatus.approved,
    ),
    const EmployeeRequest(
      id: 'R002',
      type: 'Overtime Claim',
      dateRange: 'Jun 18, 2025',
      submittedOn: 'Jun 19',
      status: RequestStatus.pending,
    ),
    const EmployeeRequest(
      id: 'R003',
      type: 'WFH Request',
      dateRange: 'Jun 16 – Jun 17, 2025',
      submittedOn: 'Jun 14',
      status: RequestStatus.approved,
    ),
    const EmployeeRequest(
      id: 'R004',
      type: 'Sick Leave',
      dateRange: 'May 28, 2025',
      submittedOn: 'May 28',
      status: RequestStatus.approved,
    ),
    const EmployeeRequest(
      id: 'R005',
      type: 'Business Trip',
      dateRange: 'May 12 – May 14, 2025',
      submittedOn: 'May 8',
      status: RequestStatus.rejected,
    ),
  ];

  @override
  List<EmployeeRequest> readAll() => List.unmodifiable(_items);

  @override
  Future<EmployeeRequest> insert(SubmitRequestCommand command) async {
    final request = EmployeeRequest(
      id: 'R${(_items.length + 1).toString().padLeft(3, '0')}',
      type: command.type,
      dateRange: 'Select date range',
      submittedOn: 'Today',
      status: RequestStatus.pending,
    );
    _items.insert(0, request);
    return request;
  }
}
