import 'package:hrm_app/features/dashboard/data/datasources/dashboard_local_datasource.dart';
import 'package:hrm_app/core/network/request_context.dart';
import 'package:hrm_app/features/dashboard/data/datasources/dashboard_remote_datasource.dart';
import 'package:hrm_app/features/dashboard/domain/entities/dashboard_snapshot.dart';
import 'package:hrm_app/features/dashboard/domain/repositories/dashboard_repository.dart';

class DashboardRepositoryImpl implements DashboardRepository {
  DashboardRepositoryImpl(this._local, [this._remote, this._context]);
  final DashboardLocalDataSource _local;
  final DashboardRemoteDataSource? _remote;
  final RequestContext? Function()? _context;

  @override
  DashboardSnapshot get current {
    final local = _local.read();
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
    return DashboardSnapshot(
      employee: DashboardEmployee(
        name: name,
        initials: initials,
        avatarColorIndex: name.hashCode.abs() % 4,
      ),
      leaveBalances: const [],
      announcements: const [],
    );
  }

  @override
  Future<DashboardSnapshot> refresh() async {
    final local = current;
    final context = _context?.call();
    final remote = _remote;
    return context == null || remote == null
        ? local
        : remote.fetch(context, local);
  }
}
