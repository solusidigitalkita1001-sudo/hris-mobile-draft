class ApiException implements Exception {
  const ApiException(
    this.message, {
    this.statusCode,
    this.code,
    this.fieldErrors = const {},
  });

  final String message;
  final int? statusCode;
  final String? code;
  final Map<String, String> fieldErrors;

  @override
  String toString() => 'ApiException($statusCode): $message';
}
