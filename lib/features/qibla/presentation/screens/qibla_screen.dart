import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:prayer_times/features/qibla/presentation/widgets/direction_indicator.dart';
import 'package:prayer_times/features/qibla/presentation/widgets/location_info_card.dart';
import 'package:prayer_times/features/qibla/presentation/widgets/qibla_compass.dart';

class QiblaScreen extends ConsumerWidget {
  const QiblaScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
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
    );
  }
}
