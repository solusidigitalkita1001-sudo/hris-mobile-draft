import 'package:hrm_app/features/profile/domain/entities/employee.dart';

abstract interface class ProfileLocalDataSource {
  Employee readCurrentEmployee();
}

class DemoProfileLocalDataSource implements ProfileLocalDataSource {
  @override
  Employee readCurrentEmployee() => const Employee(
    id: 'E011',
    name: 'Siti Rahayu',
    role: 'HR Director',
    department: 'Human Resources',
    email: 's.rahayu@acme.co.id',
    phone: '+62 811 4433 2211',
    location: 'Jakarta · Menara ACME',
    joinDate: '30 Nov 2017',
    salary: 48000000,
    initials: 'SR',
    avatarColorIndex: 2,
  );
}
