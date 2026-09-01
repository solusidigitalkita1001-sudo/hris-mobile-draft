enum RequestStatus { approved, pending, rejected }

class EmployeeRequest {
  const EmployeeRequest({
    required this.id,
    required this.type,
    required this.dateRange,
    required this.submittedOn,
    required this.status,
  });

  final String id;
  final String type;
  final String dateRange;
  final String submittedOn;
  final RequestStatus status;
}
