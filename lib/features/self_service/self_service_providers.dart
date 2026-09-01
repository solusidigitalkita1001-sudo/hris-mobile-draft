import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hrm_app/features/self_service/domain/entities/employee_request.dart';
import 'package:hrm_app/features/self_service/presentation/controllers/request_controller.dart';

final requestControllerProvider =
    NotifierProvider<RequestController, List<EmployeeRequest>>(
      RequestController.new,
    );
