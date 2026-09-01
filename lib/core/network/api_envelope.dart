class ApiEnvelope {
  const ApiEnvelope({
    required this.success,
    required this.message,
    required this.data,
    this.meta,
  });

  factory ApiEnvelope.fromJson(Map<String, dynamic> json) => ApiEnvelope(
    success: json['success'] as bool? ?? false,
    message: json['message'] as String? ?? '',
    data: json['data'],
    meta: json['meta'] as Map<String, dynamic>?,
  );

  final bool success;
  final String message;
  final Object? data;
  final Map<String, dynamic>? meta;

  Map<String, dynamic> requireObjectData() {
    final value = data;
    if (!success || value is! Map<String, dynamic>) {
      throw const FormatException('Invalid API response data');
    }
    return value;
  }

  List<dynamic> requireListData() {
    final value = data;
    if (!success || value is! List<dynamic>) {
      throw const FormatException('Invalid API response data');
    }
    return value;
  }
}
