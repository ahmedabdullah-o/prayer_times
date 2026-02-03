import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:prayer_times/core/services/location/location_provider.dart';
import 'package:prayer_times/core/style/colors.dart' as app;
import 'package:prayer_times/features/qibla/domain/notifiers/qibla_direction_notifier.dart';
import 'package:prayer_times/features/qibla/presentation/widgets/direction_indicator.dart';
import 'package:prayer_times/features/qibla/presentation/widgets/location_info_card.dart';
import 'package:prayer_times/features/qibla/presentation/widgets/qibla_compass.dart';

class QiblaScreen extends ConsumerWidget {
  const QiblaScreen({super.key});

  Future<void> _refreshLocation(WidgetRef ref) async {
    final location = ref.read(locationProvider);

    // Check if we have permission
    final hasPermission = await location.hasPermission();

    if (!hasPermission) {
      // Request permission
      await location.requestPermission();
    }

    // Invalidate providers to force refresh
    ref.invalidate(currentPositionProvider);
    ref.invalidate(qiblaDirectionProvider);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Stack(
      children: [
        Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.max,
                children: [
                  SizedBox(height: 20),
                  QiblaCompass(),
                  SizedBox(height: 32),
                  LocationInfoCard(),
                  SizedBox(height: 24),
                  DirectionIndicator(),
                ],
              ),
            ),
          ],
        ),
        // Refresh button in top right
        Positioned(
          top: 20,
          right: 20,
          child: Material(
            color: app.Colors.foreground,
            borderRadius: BorderRadius.circular(12),
            child: InkWell(
              onTap: () => _refreshLocation(ref),
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: EdgeInsets.all(12),
                child: Icon(Icons.refresh, color: app.Colors.primary, size: 24),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
