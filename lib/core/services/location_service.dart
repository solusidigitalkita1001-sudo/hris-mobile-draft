import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hrm_app/core/services/location_gateway.dart';

/// Development implementation. Replace this provider in bootstrap with the
/// geolocator-backed implementation when the production API is connected.
final class DemoLocationService implements LocationGateway {
  @override
  Future<GeoCoordinate> currentPosition() async {
    await Future<void>.delayed(const Duration(milliseconds: 150));
    return const GeoCoordinate(-6.2088, 106.8456);
  }
}

final locationServiceProvider = Provider<LocationGateway>(
  (ref) => DemoLocationService(),
);
