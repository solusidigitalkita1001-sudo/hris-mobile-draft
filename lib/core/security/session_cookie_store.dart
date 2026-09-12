import 'package:dio/dio.dart';
import 'package:hrm_app/core/network/platform_http.dart';
import 'package:hrm_app/core/security/cookie_session.dart';
import 'package:hrm_app/core/security/token_storage.dart';
import 'package:intl/intl.dart';

class SessionCookieStore {
  SessionCookieStore({
    required this.storage,
    required String baseUrl,
    DateTime Function()? clock,
  }) : baseUri = Uri.parse(baseUrl),
       _clock = clock ?? DateTime.now;

  final TokenStorage storage;
  final Uri baseUri;
  final DateTime Function() _clock;

  bool get usesBrowserCookies => usesBrowserCookieStore;

  Future<Map<String, String>> headersFor(
    Uri uri, {
    required String method,
  }) async {
    if (!_sameOrigin(uri, baseUri)) return const {};
    if (usesBrowserCookies) {
      final csrf = cookieValue(readBrowserCookieHeader(), 'csrf');
      return {if (_requiresCsrf(method) && csrf != null) 'X-CSRF-Token': csrf};
    }
    final cookies = await _readValidCookies(uri);
    final header = cookies.isEmpty
        ? null
        : cookies.map((cookie) => '${cookie.name}=${cookie.value}').join('; ');
    final access = await storage.readAccessToken();
    final hasCookieAuth = cookies.any(
      (cookie) => cookie.name == 'at' || cookie.name == 'rt',
    );
    final csrf = cookies
        .where((cookie) => cookie.name == 'csrf')
        .map((cookie) => cookie.decodedValue)
        .firstOrNull;
    return {
      if (access != null && access.isNotEmpty)
        'Authorization': 'Bearer $access',
      'Cookie': ?header,
      if (_requiresCsrf(method) && hasCookieAuth && csrf != null)
        'X-CSRF-Token': csrf,
    };
  }

  Future<Set<String>> capture(
    Headers headers,
    Uri responseUri, {
    bool requireAuthBundle = false,
  }) async {
    if (usesBrowserCookies || !_sameOrigin(responseUri, baseUri)) {
      return const {};
    }
    final values = headers['set-cookie'] ?? const <String>[];
    if (values.isEmpty) return const {};
    final updates = values
        .map((value) => _parse(value, responseUri))
        .whereType<_StoredCookie>()
        .toList(growable: false);
    final updatedNames = updates.map((cookie) => cookie.name).toSet();
    if (requireAuthBundle &&
        !updatedNames.containsAll(const {'at', 'rt', 'csrf'})) {
      return const {};
    }
    final state = await _readState();
    final cookies = state.cookies.toList();
    for (final update in updates) {
      cookies.removeWhere(
        (cookie) =>
            cookie.name == update.name &&
            cookie.origin == update.origin &&
            cookie.path == update.path,
      );
      if (!update.expired(_clock().toUtc())) cookies.add(update);
    }
    await _save(cookies);
    return updatedNames;
  }

  Future<bool> hasAccessCredential() async {
    final bearer = await storage.readAccessToken();
    if (bearer != null && bearer.isNotEmpty) return true;
    if (usesBrowserCookies) return (await storage.readSession()) != null;
    return (await _readValidCookies(
      baseUri,
    )).any((cookie) => cookie.name == 'at');
  }

  Future<void> _save(List<_StoredCookie> cookies) async {
    final now = _clock().toUtc();
    final valid = cookies.where((cookie) => !cookie.expired(now)).toList();
    final allHeader = valid.isEmpty
        ? null
        : valid.map((cookie) => '${cookie.name}=${cookie.value}').join('; ');
    final csrf = valid
        .where((cookie) => cookie.name == 'csrf')
        .map((cookie) => cookie.decodedValue)
        .firstOrNull;
    await storage.saveCookieState(
      state: {
        'version': 1,
        'cookies': valid.map((cookie) => cookie.toJson()).toList(),
      },
      cookieHeader: allHeader,
      csrfToken: csrf,
    );
  }

  Future<List<_StoredCookie>> _readValidCookies(Uri uri) async {
    final state = await _readState();
    final now = _clock().toUtc();
    final valid = state.cookies
        .where((cookie) => !cookie.expired(now))
        .toList(growable: false);
    if (valid.length != state.cookies.length) await _save(valid);
    return valid.where((cookie) => cookie.matches(uri)).toList(growable: false);
  }

  Future<({List<_StoredCookie> cookies})> _readState() async {
    Map<String, dynamic>? json;
    try {
      json = await storage.readCookieState();
    } on FormatException {
      return (cookies: const <_StoredCookie>[]);
    }
    final raw = json?['cookies'];
    if (json?['version'] != 1 || raw is! List) {
      return (cookies: const <_StoredCookie>[]);
    }
    return (
      cookies: raw
          .whereType<Map>()
          .map(
            (item) => _StoredCookie.fromJson(Map<String, dynamic>.from(item)),
          )
          .whereType<_StoredCookie>()
          .where(_validStoredCookie)
          .toList(),
    );
  }

  bool _validStoredCookie(_StoredCookie cookie) {
    final authCookie = cookie.name == 'at' || cookie.name == 'rt';
    return cookie.origin == _origin(baseUri) &&
        cookie.path == (cookie.name == 'rt' ? _refreshPath : '/') &&
        cookie.httpOnly == authCookie &&
        (baseUri.scheme != 'https' || cookie.secure) &&
        (!authCookie || cookie.expiresAt != null);
  }

  _StoredCookie? _parse(String header, Uri responseUri) {
    final parts = header.split(';').map((part) => part.trim()).toList();
    if (parts.isEmpty) return null;
    final separator = parts.first.indexOf('=');
    if (separator <= 0) return null;
    final name = parts.first.substring(0, separator);
    if (!const {'at', 'rt', 'csrf'}.contains(name)) return null;
    final value = parts.first.substring(separator + 1);
    final attributes = <String, String?>{};
    for (final part in parts.skip(1)) {
      final index = part.indexOf('=');
      attributes[index < 0
          ? part.toLowerCase()
          : part.substring(0, index).toLowerCase()] = index < 0
          ? null
          : part.substring(index + 1);
    }
    final expectedPath = name == 'rt' ? _refreshPath : '/';
    final path = attributes['path'] ?? _defaultPath(responseUri.path);
    final domain = attributes['domain']?.toLowerCase().replaceFirst(
      RegExp(r'^\.'),
      '',
    );
    final secure = attributes.containsKey('secure');
    final httpOnly = attributes.containsKey('httponly');
    final sameSite = attributes['samesite']?.toLowerCase();
    if (path != expectedPath ||
        (domain != null && domain != baseUri.host.toLowerCase()) ||
        (baseUri.scheme == 'https' && !secure) ||
        ((name == 'at' || name == 'rt') && !httpOnly) ||
        (name == 'csrf' && httpOnly) ||
        sameSite != 'lax') {
      return null;
    }
    DateTime? expiresAt;
    final maxAge = int.tryParse(attributes['max-age'] ?? '');
    if (maxAge != null) {
      expiresAt = _clock().toUtc().add(Duration(seconds: maxAge));
    } else if (attributes['expires'] case final raw?) {
      expiresAt = _parseHttpDate(raw);
    }
    if ((name == 'at' || name == 'rt') && expiresAt == null) return null;
    return _StoredCookie(
      name: name,
      value: value,
      origin: _origin(baseUri),
      path: path,
      secure: secure,
      httpOnly: httpOnly,
      sameSite: sameSite!,
      expiresAt: expiresAt,
    );
  }

  String get _refreshPath {
    final basePath = baseUri.path.endsWith('/')
        ? baseUri.path.substring(0, baseUri.path.length - 1)
        : baseUri.path;
    return '$basePath/auth';
  }
}

class _StoredCookie {
  const _StoredCookie({
    required this.name,
    required this.value,
    required this.origin,
    required this.path,
    required this.secure,
    required this.httpOnly,
    required this.sameSite,
    this.expiresAt,
  });

  static _StoredCookie? fromJson(Map<String, dynamic> json) {
    final name = json['name'];
    final value = json['value'];
    final origin = json['origin'];
    final path = json['path'];
    final secure = json['secure'];
    final httpOnly = json['httpOnly'];
    final sameSite = json['sameSite'];
    if (name is! String ||
        !const {'at', 'rt', 'csrf'}.contains(name) ||
        value is! String ||
        origin is! String ||
        path is! String ||
        secure is! bool ||
        httpOnly is! bool ||
        sameSite != 'lax') {
      return null;
    }
    final expires = json['expiresAt'];
    if (expires != null &&
        (expires is! String || DateTime.tryParse(expires) == null)) {
      return null;
    }
    return _StoredCookie(
      name: name,
      value: value,
      origin: origin,
      path: path,
      secure: secure,
      httpOnly: httpOnly,
      sameSite: sameSite,
      expiresAt: expires is String ? DateTime.parse(expires).toUtc() : null,
    );
  }

  final String name;
  final String value;
  final String origin;
  final String path;
  final bool secure;
  final bool httpOnly;
  final String sameSite;
  final DateTime? expiresAt;
  String? get decodedValue => cookieValue('$name=$value', name);

  bool expired(DateTime now) =>
      value.isEmpty || (expiresAt?.isAfter(now) == false);
  bool matches(Uri uri) =>
      _origin(uri) == origin &&
      (!secure || uri.scheme == 'https') &&
      (uri.path == path ||
          uri.path.startsWith(path.endsWith('/') ? path : '$path/'));

  Map<String, dynamic> toJson() => {
    'name': name,
    'value': value,
    'origin': origin,
    'path': path,
    'secure': secure,
    'httpOnly': httpOnly,
    'sameSite': sameSite,
    if (expiresAt != null) 'expiresAt': expiresAt!.toIso8601String(),
  };
}

bool _requiresCsrf(String method) =>
    !const {'GET', 'HEAD', 'OPTIONS'}.contains(method.toUpperCase());
bool _sameOrigin(Uri left, Uri right) => _origin(left) == _origin(right);
String _origin(Uri uri) =>
    '${uri.scheme.toLowerCase()}://${uri.host.toLowerCase()}:${uri.hasPort
        ? uri.port
        : uri.scheme == 'https'
        ? 443
        : 80}';
String _defaultPath(String path) {
  if (!path.startsWith('/') || path == '/') return '/';
  return path.substring(0, path.lastIndexOf('/') + 1);
}

DateTime? _parseHttpDate(String value) {
  try {
    return DateFormat(
      "EEE, dd MMM yyyy HH:mm:ss 'GMT'",
      'en_US',
    ).parseUtc(value);
  } on FormatException {
    return null;
  }
}
