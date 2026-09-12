class AuthSession {
  const AuthSession({
    this.accessToken,
    this.refreshToken,
    this.expiresIn,
    this.userId,
    this.employeeId,
    this.companyId,
    this.companyScope = const [],
    this.groupId,
    this.roles = const [],
    this.permissions = const [],
    this.hasGlobalRole = false,
    this.maxRolePriority = 0,
    this.mustChangePassword = false,
    this.userName,
    this.email,
  });

  final String? accessToken;
  final String? refreshToken;
  final int? expiresIn;
  final String? userId;
  final String? employeeId;
  final String? companyId;
  final List<String> companyScope;
  final String? groupId;
  final List<String> roles;
  final List<String> permissions;
  final bool hasGlobalRole;
  final int maxRolePriority;
  final bool mustChangePassword;
  final String? userName;
  final String? email;

  bool get hasEmployeeAccess =>
      employeeId != null && (companyId != null || companyScope.isNotEmpty);
}
