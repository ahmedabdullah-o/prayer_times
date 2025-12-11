import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:prayer_times/core/enums/prayers_enums.dart';
import 'package:prayer_times/core/services/prayer_times/prayer_times_provider.dart';
import 'package:prayer_times/core/style/colors.dart' as app;
import 'package:prayer_times/features/home/presentation/widgets/prayer_card.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final prayerTimes = ref.read(prayerTimesProvider);
    final prayerNames = PrayersEnums.values;
    
    final todayPrayerTimes = prayerTimes.todayPrayerTimes;
    final upcoming = prayerTimes.nextPrayer;

    return Column(
      children: [
        Placeholder(),
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [app.Colors.foreground, app.Colors.background],
              // stops: [.3, .85],
              transform: GradientRotation(pi * 1.5),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.max,
              children: List.generate(
                prayerNames.length,
                (i) => PrayerCard(
                  prayerNames[i].name,
                  todayPrayerTimes[prayerNames[i].name]!,
                  upcoming == prayerNames[i],
                  // TODO: use storage when ready to retrieve sound on/off state.
                  true, // storage not implemented yet to retrieve this preference. set to `true` temporarily.
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
