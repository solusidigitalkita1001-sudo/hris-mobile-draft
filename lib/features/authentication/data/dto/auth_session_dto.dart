import 'package:hrm_app/features/authentication/domain/entities/auth_session.dart';

class AuthSessionDto {
  const AuthSessionDto({
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

  factory AuthSessionDto.fromLoginJson(Map<String, dynamic> json) {
    final tokens = json['tokens'] as Map<String, dynamic>? ?? const {};
    final user = json['user'] as Map<String, dynamic>? ?? const {};
    return AuthSessionDto._fromParts(tokens: tokens, user: user);
  }

  factory AuthSessionDto.fromStoredJson(Map<String, dynamic> json) =>
      AuthSessionDto._fromParts(tokens: json, user: json);

  factory AuthSessionDto._fromParts({
    required Map<String, dynamic> tokens,
    required Map<String, dynamic> user,
  }) {
    final accessToken = tokens['accessToken'] as String?;
    if (accessToken == null || accessToken.isEmpty) {
      throw const FormatException('Access token is missing');
    }
    return AuthSessionDto(
      accessToken: accessToken,
      refreshToken: tokens['refreshToken'] as String?,
      expiresIn: _asInt(tokens['expiresIn']),
      userId: _asId(user['id'] ?? user['userId']),
      employeeId: _asId(user['employeeId']),
      companyId: _asId(user['companyId']),
      companyScope: _asStringList(user['companyScope']),
      groupId: _asId(user['groupId']),
      roles: _asStringList(user['roles']),
      permissions: _asStringList(user['permissions']),
      mustChangePassword: user['mustChangePassword'] as bool? ?? false,
      userName: _userName(user),
      email: user['email'] as String?,
    );
  }

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

  AuthSession toEntity() => AuthSession(
    accessToken: accessToken,
    refreshToken: refreshToken,
    expiresIn: expiresIn,
    userId: userId,
    employeeId: employeeId,
    companyId: companyId,
    companyScope: companyScope,
    groupId: groupId,
    roles: roles,
    permissions: permissions,
    mustChangePassword: mustChangePassword,
    userName: userName,
    email: email,
  );

  Map<String, dynamic> toStoredJson() => {
    'accessToken': accessToken,
    if (refreshToken != null) 'refreshToken': refreshToken,
    if (expiresIn != null) 'expiresIn': expiresIn,
    if (userId != null) 'id': userId,
    if (employeeId != null) 'employeeId': employeeId,
    if (companyId != null) 'companyId': companyId,
    'companyScope': companyScope,
    if (groupId != null) 'groupId': groupId,
    'roles': roles,
    'permissions': permissions,
    'mustChangePassword': mustChangePassword,
    if (userName != null) 'name': userName,
    if (email != null) 'email': email,
  };

  AuthSessionDto mergeUser(Map<String, dynamic> user) =>
      AuthSessionDto._fromParts(
        tokens: toStoredJson(),
        user: {...toStoredJson(), ...user},
      );
}

String? _asId(Object? value) {
  if (value is String) return value;
  if (value is Map) return value['id'] as String?;
  return null;
}

int? _asInt(Object? value) => value is int ? value : int.tryParse('$value');

List<String> _asStringList(Object? value) {
  if (value is! List) return const [];
  return value
      .map((item) {
        if (item is String) return item;
        if (item is Map) return item['id'] ?? item['name'] ?? item['code'];
        return null;
      })
      .whereType<String>()
      .toList(growable: false);
}

String? _userName(Map<String, dynamic> user) {
  final name = user['name'];
  if (name is String && name.isNotEmpty) return name;
  final combined = [
    user['firstName'],
    user['lastName'],
  ].whereType<String>().join(' ').trim();
  if (combined.isNotEmpty) return combined;
  final email = user['email'] as String?;
  if (email == null || !email.contains('@')) return null;
  return email.split('@').first;
}
