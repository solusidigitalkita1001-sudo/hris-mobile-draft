import 'package:hrm_app/features/profile/domain/entities/employee.dart';

abstract interface class ProfileRepository {
  Employee get currentEmployee;
  Future<Employee> refresh();
}
