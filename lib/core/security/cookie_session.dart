import 'package:dio/dio.dart';

String? cookieValue(String? header, String name) {
  final value = _decodeCookies(header)[name];
  if (value == null || value.isEmpty) return null;
  try {
    return Uri.decodeComponent(value);
  } on FormatException {
    return null;
  } on ArgumentError {
    return null;
  }
}

String? cookieHeaderFromResponse(Headers headers) {
  final cookies = <String, String>{};
  for (final header in headers['set-cookie'] ?? const <String>[]) {
    final pair = header.split(';').first.trim();
    final separator = pair.indexOf('=');
    if (separator <= 0) continue;
    cookies[pair.substring(0, separator)] = pair.substring(separator + 1);
  }
  return _encodeCookies(cookies);
}

List<String> setCookieHeadersFromResponse(Headers headers) =>
    List.unmodifiable(headers['set-cookie'] ?? const <String>[]);

String? mergeCookieHeaders(String? current, String? update) {
  final cookies = <String, String>{
    ..._decodeCookies(current),
    ..._decodeCookies(update),
  };
  cookies.removeWhere((_, value) => value.isEmpty);
  return _encodeCookies(cookies);
}

Map<String, String> _decodeCookies(String? header) {
  if (header == null || header.isEmpty) return const {};
  final cookies = <String, String>{};
  for (final pair in header.split(';')) {
    final trimmed = pair.trim();
    final separator = trimmed.indexOf('=');
    if (separator <= 0) continue;
    cookies[trimmed.substring(0, separator)] = trimmed.substring(separator + 1);
  }
  return cookies;
}

String? _encodeCookies(Map<String, String> cookies) => cookies.isEmpty
    ? null
    : cookies.entries.map((entry) => '${entry.key}=${entry.value}').join('; ');
