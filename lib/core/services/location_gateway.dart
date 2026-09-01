class GeoCoordinate {
  const GeoCoordinate(this.latitude, this.longitude);

  final double latitude;
  final double longitude;
}

abstract interface class LocationGateway {
  Future<GeoCoordinate> currentPosition();
}
