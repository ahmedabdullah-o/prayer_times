import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:prayer_times/core/enums/prayers_enums.dart';
import 'package:prayer_times/core/services/prayer_times/prayer_times_provider.dart';
import 'package:prayer_times/core/services/storage/hive/hive_storage_provider.dart';
import 'package:prayer_times/features/home/presentation/widgets/calendar.dart';
import 'package:prayer_times/features/home/presentation/widgets/prayer_card.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final prayerTimesRef = ref.read(prayerTimesProvider);
    final prayerEnums = PrayersEnums.values;

    final calendarOffset = ref.watch(calendarOffsetProvider);
    final todayPrayerTimes = prayerTimesRef.prayerTimes(calendarOffset);
    final nextPrayer = ref.watch(nextPrayerProvider);

    final storage = ref.watch(hiveStorageProvider);

    return storage.when(
      loading: () => CircularProgressIndicator(),
      error: (e, s) => throw Exception(e.toString()),
      data: (storage) => Column(
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
                Calendar(),
                ...List.generate(
                  prayerEnums.length,
                  (i) => FutureBuilder<bool>(
                    future: storage.getNotificationMute(prayerEnums[i]),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState !=
                          ConnectionState.done) {
                        return SizedBox(height: 48);
                      }
                      return PrayerCard(
                        prayerEnums[i],
                        todayPrayerTimes[prayerEnums[i]]!,
                        nextPrayer == prayerEnums[i] &&
                            calendarOffset == 0,
                        snapshot.data ?? false,
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}



final calendarOffsetProvider = NotifierProvider<CalendarOffset, int>(
  CalendarOffset.new,
);

class CalendarOffset extends Notifier<int> {
  @override
  int build() => 0;

  void increment() => state++;

  void decrement() => state--;
}

final nextPrayerProvider = NotifierProvider<NextPrayer, PrayersEnums>(
  NextPrayer.new,
);

class NextPrayer extends Notifier<PrayersEnums> {
  final prayerTimes = ProviderContainer().read(prayerTimesProvider);
  @override
  PrayersEnums build() => prayerTimes.nextPrayer;

  void update() => state = prayerTimes.nextPrayer;
}
