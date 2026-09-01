import 'package:flutter_riverpod/flutter_riverpod.dart';

class RequestContext {
  const RequestContext({
    required this.userId,
    required this.employeeId,
    required this.activeCompanyId,
    required this.companyScope,
    this.displayName,
    this.email,
    this.roles = const [],
    this.permissions = const [],
  });

  final String? userId;
  final String? employeeId;
  final String? activeCompanyId;
  final List<String> companyScope;
  final String? displayName;
  final String? email;
  final List<String> roles;
  final List<String> permissions;

  RequestContext selectCompany(String companyId) {
    if (!companyScope.contains(companyId)) {
      throw ArgumentError.value(
        companyId,
        'companyId',
        'Outside company scope',
      );
    }
    return RequestContext(
      userId: userId,
      employeeId: employeeId,
      activeCompanyId: companyId,
      companyScope: companyScope,
      displayName: displayName,
      email: email,
      roles: roles,
      permissions: permissions,
    );
  }
}

final requestContextProvider = StateProvider<RequestContext?>((ref) => null);
