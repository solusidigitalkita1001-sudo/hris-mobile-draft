import 'package:hrm_app/features/profile/data/datasources/profile_local_datasource.dart';
import 'package:hrm_app/core/network/request_context.dart';
import 'package:hrm_app/features/profile/data/datasources/profile_remote_datasource.dart';
import 'package:hrm_app/features/profile/domain/entities/employee.dart';
import 'package:hrm_app/features/profile/domain/repositories/profile_repository.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  ProfileRepositoryImpl(this._local, [this._remote, this._context]);
  final ProfileLocalDataSource _local;
  final ProfileRemoteDataSource? _remote;
  final RequestContext? Function()? _context;

  @override
  Employee get currentEmployee {
    final local = _local.readCurrentEmployee();
    final context = _context?.call();
    if (context == null) return local;
    final displayName = context.displayName?.trim();
    final emailName = context.email?.split('@').first.trim();
    final name = displayName != null && displayName.isNotEmpty
        ? displayName
        : emailName != null && emailName.isNotEmpty
        ? emailName
        : 'User';
    final initials = name
        .split(RegExp(r'\s+'))
        .where((word) => word.isNotEmpty)
        .take(2)
        .map((word) => word[0].toUpperCase())
        .join();
    return Employee(
      id: context.employeeId ?? context.userId ?? '',
      name: name,
      role: context.roles.map(_formatRole).join(', '),
      department: '',
      email: context.email ?? '',
      phone: '',
      location: '',
      joinDate: '',
      salary: 0,
      initials: initials,
      avatarColorIndex: name.hashCode.abs() % 4,
    );
  }

  @override
  Future<Employee> refresh() async {
    final local = currentEmployee;
    final context = _context?.call();
    final remote = _remote;
    return context == null || remote == null
        ? local
        : remote.fetch(context, local);
  }
}

String _formatRole(String value) => value
    .toLowerCase()
    .split('_')
    .where((part) => part.isNotEmpty)
    .map((part) => '${part[0].toUpperCase()}${part.substring(1)}')
    .join(' ');
