class GeoCoordinate {
  const GeoCoordinate(
    this.latitude,
    this.longitude, {
    required this.accuracyMeters,
    required this.capturedAt,
    this.isMocked = false,
    this.altitudeMeters,
    this.headingDegrees,
  });

  final double latitude;
  final double longitude;
  final double accuracyMeters;
  final DateTime capturedAt;
  final bool isMocked;
  final double? altitudeMeters;
  final double? headingDegrees;
}

abstract interface class LocationGateway {
  Future<GeoCoordinate> currentPosition();
  Future<bool> openAppSettings();
  Future<bool> openLocationSettings();
}

enum LocationIssueKind {
  serviceDisabled,
  permissionDenied,
  permissionDeniedForever,
  restricted,
  inaccurate,
  mocked,
  timeout,
  unavailable,
}

class LocationException implements Exception {
  const LocationException(this.kind, this.message);

  final LocationIssueKind kind;
  final String message;

  @override
  String toString() => 'LocationException(${kind.name}): $message';
}
