import 'package:geolocator/geolocator.dart';

abstract class ILocation {
  /// Check if location permission is granted
  Future<bool> hasPermission();

  /// Request location permission from user
  Future<bool> requestPermission();

  /// Get current GPS position
  Future<Position?> getCurrentPosition();

  /// Calculate Qibla direction from given coordinates
  Future<double> calculateQiblaDirection(double latitude, double longitude);

  /// Calculate distance to Mecca in kilometers
  double calculateDistanceToMecca(double latitude, double longitude);
}
