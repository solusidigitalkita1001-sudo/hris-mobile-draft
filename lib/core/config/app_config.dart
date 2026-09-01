import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppConfig {
  static const _definedBaseUrl = String.fromEnvironment('BASE_URL');
  static const _definedConnectTimeout = String.fromEnvironment(
    'CONNECT_TIMEOUT_MS',
  );
  static const _definedReceiveTimeout = String.fromEnvironment(
    'RECEIVE_TIMEOUT_MS',
  );
  static const _definedLogging = String.fromEnvironment('ENABLE_LOGGING');

  const AppConfig({
    required this.baseUrl,
    required this.connectTimeout,
    required this.receiveTimeout,
    required this.enableNetworkLogs,
  });

  factory AppConfig.fromEnvironment() => AppConfig(
    baseUrl:
        _value(_definedBaseUrl, 'BASE_URL') ??
        'http://srv540825.hstgr.cloud:8084/api/v1',
    connectTimeout: Duration(
      milliseconds:
          int.tryParse(
            _value(_definedConnectTimeout, 'CONNECT_TIMEOUT_MS') ?? '',
          ) ??
          15000,
    ),
    receiveTimeout: Duration(
      milliseconds:
          int.tryParse(
            _value(_definedReceiveTimeout, 'RECEIVE_TIMEOUT_MS') ?? '',
          ) ??
          15000,
    ),
    enableNetworkLogs:
        (_value(_definedLogging, 'ENABLE_LOGGING') ?? 'false').toLowerCase() ==
        'true',
  );

  final String baseUrl;
  final Duration connectTimeout;
  final Duration receiveTimeout;
  final bool enableNetworkLogs;
}

String? _value(String compileTimeValue, String dotenvKey) =>
    compileTimeValue.isNotEmpty
    ? compileTimeValue
    : _environmentValue(dotenvKey);

String? _environmentValue(String key) {
  try {
    return dotenv.maybeGet(key);
  } on Object {
    return null;
  }
}
