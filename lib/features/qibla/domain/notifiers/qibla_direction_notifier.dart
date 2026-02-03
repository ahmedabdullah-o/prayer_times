import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:prayer_times/core/services/location/location_provider.dart';

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
    print(
      '🧭 Calculating Qibla from GPS: ${position.latitude}, ${position.longitude}',
    );
    final qibla = await location.calculateQiblaDirection(
      position.latitude,
      position.longitude,
    );
    print('🕌 Qibla direction: ${qibla.toStringAsFixed(1)}°');
    return qibla;
  }

  // Fallback to Cairo coordinates if no location available
  print('⚠️ Using Cairo fallback coordinates (30.0444, 31.2357)');
  final qibla = await location.calculateQiblaDirection(30.0444, 31.2357);
  print('🕌 Qibla direction (Cairo): ${qibla.toStringAsFixed(1)}°');
  return qibla;
});
