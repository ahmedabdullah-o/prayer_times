import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:prayer_times/core/enums/prayers_enums.dart';
import 'package:prayer_times/core/services/prayer_times/prayer_times_provider.dart';
import 'package:prayer_times/features/home/presentation/widgets/prayer_card.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final prayerTimes = ref.read(prayerTimesProvider);
    final prayerNames = PrayersEnums.values;
    final todayPrayerTimes = prayerTimes.todayPrayerTimes;

    return ListView.builder(
      itemCount: prayerNames.length,
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      itemBuilder: (context, index) {
        return PrayerCard(
          prayerNames[index].name,
          todayPrayerTimes[prayerNames[index].name]!,
        );
      },
    );
  }
}
