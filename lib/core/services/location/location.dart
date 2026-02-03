import 'dart:math';
import 'package:geolocator/geolocator.dart';
import 'package:logging/logging.dart';
import 'package:prayer_times/core/services/location/ilocation.dart';

class Location implements ILocation {
  final _logger = Logger('Location');

  // Kaaba coordinates in Mecca
  static const double meccaLat = 21.4224779;
  static const double meccaLng = 39.8251832;

  @override
  Future<bool> hasPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();
    return permission == LocationPermission.always ||
        permission == LocationPermission.whileInUse;
  }

  @override
  Future<bool> requestPermission() async {
    LocationPermission permission = await Geolocator.requestPermission();
    return permission == LocationPermission.always ||
        permission == LocationPermission.whileInUse;
  }

  @override
  Future<Position?> getCurrentPosition() async {
    try {
      // Check if location services are enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        _logger.warning('Location services are disabled');
        return null;
      }

      // Check permission
      if (!await hasPermission()) {
        _logger.info('Location permission not granted, requesting...');
        if (!await requestPermission()) {
          _logger.warning('Location permission denied by user');
          return null;
        }
        _logger.info('Location permission granted');
      }

      // Get current position
      _logger.fine('Fetching GPS position...');
      final position = await Geolocator.getCurrentPosition(
        locationSettings: LocationSettings(accuracy: LocationAccuracy.high),
      );
      _logger.info(
        'GPS position acquired: ${position.latitude.toStringAsFixed(4)}, ${position.longitude.toStringAsFixed(4)}',
      );
      return position;
    } catch (e) {
      _logger.severe('Error getting location: $e');
      return null;
    }
  }

  @override
  Future<double> calculateQiblaDirection(
    double latitude,
    double longitude,
  ) async {
    // Convert degrees to radians
    double latRad = latitude * pi / 180;
    double lonRad = longitude * pi / 180;
    double meccaLatRad = meccaLat * pi / 180;
    double meccaLonRad = meccaLng * pi / 180;

    // Qibla calculation formula using spherical trigonometry
    // q = atan2(sin(λK - λP), cos(φP) * tan(φK) - sin(φP) * cos(λK - λP))
    double y = sin(meccaLonRad - lonRad);
    double x =
        cos(latRad) * tan(meccaLatRad) -
        sin(latRad) * cos(meccaLonRad - lonRad);
    double qibla = atan2(y, x);

    // Convert to degrees (0-360)
    double qiblaDegrees = (qibla * 180 / pi + 360) % 360;
    return qiblaDegrees;
  }

  @override
  double calculateDistanceToMecca(double latitude, double longitude) {
    // Calculate distance using Haversine formula (provided by geolocator)
    double distanceInMeters = Geolocator.distanceBetween(
      latitude,
      longitude,
      meccaLat,
      meccaLng,
    );

    // Convert to kilometers
    return distanceInMeters / 1000;
  }
}
