import 'dart:typed_data';

class CapturedSelfie {
  const CapturedSelfie({
    required this.bytes,
    required this.mimeType,
    required this.capturedAt,
  });

  final Uint8List bytes;
  final String mimeType;
  final DateTime capturedAt;
}

abstract interface class SelfieGateway {
  Future<CapturedSelfie?> capture();
}

enum SelfieIssueKind { permissionDenied, restricted, tooLarge, unavailable }

class SelfieException implements Exception {
  const SelfieException(this.kind, this.message);

  final SelfieIssueKind kind;
  final String message;

  @override
  String toString() => 'SelfieException(${kind.name}): $message';
}
