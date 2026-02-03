import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geocoding/geocoding.dart';
import 'package:logging/logging.dart';
import 'package:prayer_times/core/services/location/location_provider.dart';
import 'package:prayer_times/core/style/colors.dart' as app;
import 'package:prayer_times/features/qibla/domain/notifiers/qibla_direction_notifier.dart';

final _logger = Logger('LocationInfoCard');

// Provider to get city name from coordinates
final cityNameProvider = FutureProvider<String>((ref) async {
  final position = await ref.watch(currentPositionProvider.future);

  if (position == null) {
    return 'Cairo, Egypt';
  }

  try {
    List<Placemark> placemarks = await placemarkFromCoordinates(
      position.latitude,
      position.longitude,
    );

    if (placemarks.isNotEmpty) {
      final place = placemarks.first;
      final city = place.locality ?? place.subAdministrativeArea ?? 'Unknown';
      final country = place.country ?? '';
      return country.isNotEmpty ? '$city, $country' : city;
    }
  } catch (e) {
    _logger.warning('Error getting city name: $e');
  }

  return 'Current Location';
});

class LocationInfoCard extends ConsumerWidget {
  const LocationInfoCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final positionAsync = ref.watch(currentPositionProvider);
    final cityAsync = ref.watch(cityNameProvider);
    final location = ref.read(locationProvider);

    return positionAsync.when(
      loading: () => _buildCard('Loading...', '...', '...'),
      error: (error, stack) =>
          _buildCard('Location Unavailable', 'Permission required', 'N/A'),
      data: (position) {
        if (position == null) {
          // Fallback to Cairo
          return _buildCard('Cairo, Egypt', '30.04° N, 31.24° E', '1,235 km');
        }

        final distance = location.calculateDistanceToMecca(
          position.latitude,
          position.longitude,
        );

        final coordinates =
            '${position.latitude.toStringAsFixed(2)}° ${position.latitude >= 0 ? 'N' : 'S'}, ${position.longitude.toStringAsFixed(2)}° ${position.longitude >= 0 ? 'E' : 'W'}';

        // Get city name from async provider
        return cityAsync.when(
          loading: () => _buildCard(
            'Loading...',
            coordinates,
            '${distance.toStringAsFixed(0)} km',
          ),
          error: (error, stack) => _buildCard(
            'Current Location',
            coordinates,
            '${distance.toStringAsFixed(0)} km',
          ),
          data: (cityName) => _buildCard(
            cityName,
            coordinates,
            '${distance.toStringAsFixed(0)} km',
          ),
        );
      },
    );
  }

  Widget _buildCard(String location, String coordinates, String distance) {
    return Material(
      color: Colors.transparent,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        decoration: BoxDecoration(
          color: app.Colors.foreground,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 6,
              blurStyle: BlurStyle.outer,
              offset: Offset(0, 0),
              spreadRadius: 0,
            ),
          ],
        ),
        child: Column(
          children: [
            _InfoRow(label: 'Location', value: location),
            SizedBox(height: 12),
            _InfoRow(label: 'Coordinates', value: coordinates),
            SizedBox(height: 12),
            _InfoRow(label: 'Distance to Mecca', value: distance),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            color: app.Colors.textSecondary,
            fontSize: 14,
            fontFamily: 'MPLUSRounded1c',
            fontWeight: FontWeight.w400,
          ),
        ),
        Flexible(
          child: Text(
            value,
            style: TextStyle(
              color: app.Colors.text,
              fontSize: 16,
              fontFamily: 'MPLUSRounded1c',
              fontWeight: FontWeight.w700,
            ),
            textAlign: TextAlign.right,
          ),
        ),
      ],
    );
  }
}
