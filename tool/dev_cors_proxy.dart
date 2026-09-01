import 'dart:async';
import 'dart:io';

const _defaultTarget = 'http://srv540825.hstgr.cloud:8084';
const _defaultPort = 8085;

Future<void> main(List<String> arguments) async {
  final target = Uri.parse(
    Platform.environment['HRMS_PROXY_TARGET'] ?? _defaultTarget,
  );
  final port =
      int.tryParse(Platform.environment['HRMS_PROXY_PORT'] ?? '') ??
      _defaultPort;
  final server = await HttpServer.bind(InternetAddress.loopbackIPv4, port);
  final client = HttpClient();

  stdout.writeln('HRMS development proxy: http://localhost:$port -> $target');
  stdout.writeln('Stop with Ctrl+C. Do not expose this proxy publicly.');

  ProcessSignal.sigint.watch().listen((_) async {
    client.close(force: true);
    await server.close(force: true);
    exit(0);
  });

  await for (final request in server) {
    unawaited(_handle(request, client, target));
  }
}

Future<void> _handle(HttpRequest request, HttpClient client, Uri target) async {
  final origin = request.headers.value('origin');
  if (!_isLocalOrigin(origin)) {
    request.response.statusCode = HttpStatus.forbidden;
    request.response.write('Only localhost origins are allowed.');
    await request.response.close();
    return;
  }

  _addCorsHeaders(request.response, origin!);
  if (request.method == 'OPTIONS') {
    request.response.statusCode = HttpStatus.noContent;
    await request.response.close();
    return;
  }

  final upstreamUri = target.replace(
    path: request.uri.path,
    query: request.uri.hasQuery ? request.uri.query : null,
  );

  try {
    final upstream = await client.openUrl(request.method, upstreamUri);
    request.headers.forEach((name, values) {
      if (!_hopByHopHeaders.contains(name.toLowerCase()) &&
          name.toLowerCase() != 'origin' &&
          name.toLowerCase() != HttpHeaders.hostHeader) {
        upstream.headers.set(name, values);
      }
    });
    await upstream.addStream(request);
    final response = await upstream.close();

    request.response.statusCode = response.statusCode;
    response.headers.forEach((name, values) {
      if (!_hopByHopHeaders.contains(name.toLowerCase()) &&
          !name.toLowerCase().startsWith('access-control-')) {
        request.response.headers.set(name, values);
      }
    });
    _addCorsHeaders(request.response, origin);
    await request.response.addStream(response);
  } on Object catch (error) {
    request.response.statusCode = HttpStatus.badGateway;
    request.response.headers.contentType = ContentType.json;
    request.response.write('{"message":"Development proxy failed"}');
    stderr.writeln('Proxy error for $upstreamUri: $error');
  } finally {
    await request.response.close();
  }
}

bool _isLocalOrigin(String? origin) {
  if (origin == null) return false;
  final uri = Uri.tryParse(origin);
  return uri != null &&
      (uri.host == 'localhost' || uri.host == '127.0.0.1') &&
      (uri.scheme == 'http' || uri.scheme == 'https');
}

void _addCorsHeaders(HttpResponse response, String origin) {
  response.headers
    ..set(HttpHeaders.accessControlAllowOriginHeader, origin)
    ..set(HttpHeaders.accessControlAllowCredentialsHeader, 'true')
    ..set(
      HttpHeaders.accessControlAllowMethodsHeader,
      'GET,POST,PUT,PATCH,DELETE,OPTIONS',
    )
    ..set(
      HttpHeaders.accessControlAllowHeadersHeader,
      'Content-Type,Authorization,X-CSRF-Token,X-Requested-With',
    )
    ..set(HttpHeaders.accessControlMaxAgeHeader, '86400')
    ..set(HttpHeaders.varyHeader, 'Origin');
}

const _hopByHopHeaders = {
  'connection',
  'content-length',
  'host',
  'keep-alive',
  'proxy-authenticate',
  'proxy-authorization',
  'te',
  'trailer',
  'transfer-encoding',
  'upgrade',
};
