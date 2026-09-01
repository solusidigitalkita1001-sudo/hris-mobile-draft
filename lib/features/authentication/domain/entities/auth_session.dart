class AuthSession {
  const AuthSession({
    required this.accessToken,
    this.refreshToken,
    this.expiresIn,
    this.userId,
    this.employeeId,
    this.companyId,
    this.companyScope = const [],
    this.groupId,
    this.roles = const [],
    this.permissions = const [],
    this.mustChangePassword = false,
    this.userName,
    this.email,
  });

  final String accessToken;
  final String? refreshToken;
  final int? expiresIn;
  final String? userId;
  final String? employeeId;
  final String? companyId;
  final List<String> companyScope;
  final String? groupId;
  final List<String> roles;
  final List<String> permissions;
  final bool mustChangePassword;
  final String? userName;
  final String? email;
}
