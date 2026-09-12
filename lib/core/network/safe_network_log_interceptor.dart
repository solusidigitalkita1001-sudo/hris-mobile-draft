import 'package:dio/dio.dart';

typedef NetworkLogSink = void Function(String message);

class SafeNetworkLogInterceptor extends Interceptor {
  SafeNetworkLogInterceptor(this._log);

  static const _metadataKey = 'safeNetworkLogMetadata';

  final NetworkLogSink _log;
  int _sequence = 0;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final metadata = _NetworkLogMetadata(
      id: ++_sequence,
      stopwatch: Stopwatch()..start(),
    );
    options.extra[_metadataKey] = metadata;
    _log('HTTP #${metadata.id} ${options.method.toUpperCase()} started');
    handler.next(options);
  }

  @override
  void onResponse(
    Response<dynamic> response,
    ResponseInterceptorHandler handler,
  ) {
    final request = response.requestOptions;
    final metadata = _metadata(request);
    _log(
      'HTTP #${metadata.id} ${request.method.toUpperCase()} '
      '${response.statusCode ?? 0} ${metadata.elapsedMilliseconds}ms',
    );
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final request = err.requestOptions;
    final metadata = _metadata(request);
    _log(
      'HTTP #${metadata.id} ${request.method.toUpperCase()} failed '
      'status=${err.response?.statusCode ?? 0} '
      'type=${err.type.name} ${metadata.elapsedMilliseconds}ms',
    );
    handler.next(err);
  }

  _NetworkLogMetadata _metadata(RequestOptions request) {
    final existing = request.extra[_metadataKey];
    if (existing is _NetworkLogMetadata) return existing..stop();
    return _NetworkLogMetadata(id: ++_sequence, stopwatch: Stopwatch());
  }
}

class _NetworkLogMetadata {
  _NetworkLogMetadata({required this.id, required this.stopwatch});

  final int id;
  final Stopwatch stopwatch;

  int get elapsedMilliseconds => stopwatch.elapsedMilliseconds;

  void stop() {
    if (stopwatch.isRunning) stopwatch.stop();
  }
}
