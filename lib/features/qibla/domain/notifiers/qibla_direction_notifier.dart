import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:logging/logging.dart';
import 'package:prayer_times/core/services/location/location_provider.dart';

final _logger = Logger('QiblaDirection');

// Provider for current GPS position
final currentPositionProvider = FutureProvider<Position?>((ref) async {
  final location = ref.read(locationProvider);
  return await location.getCurrentPosition();
});

// Provider for Qibla direction based on current location
final qiblaDirectionProvider = FutureProvider<double>((ref) async {
  final location = ref.read(locationProvider);
  final position = await ref.watch(currentPositionProvider.future);

  if (position != null) {
    _logger.info(
      'Calculating Qibla from GPS: ${position.latitude.toStringAsFixed(4)}, ${position.longitude.toStringAsFixed(4)}',
    );
    final qibla = await location.calculateQiblaDirection(
      position.latitude,
      position.longitude,
    );
    _logger.info('Qibla direction: ${qibla.toStringAsFixed(1)}°');
    return qibla;
  }

  // Fallback to Cairo coordinates if no location available
  _logger.warning('Using Cairo fallback coordinates (30.0444, 31.2357)');
  final qibla = await location.calculateQiblaDirection(30.0444, 31.2357);
  _logger.info('Qibla direction (Cairo): ${qibla.toStringAsFixed(1)}°');
  return qibla;
});
