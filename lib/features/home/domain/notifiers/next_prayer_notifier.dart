import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:prayer_times/core/enums/prayers_enums.dart';
import 'package:prayer_times/core/services/prayer_times/prayer_times_provider.dart';

final nextPrayerProvider = NotifierProvider<NextPrayer, PrayersEnums>(
  NextPrayer.new,
);

class NextPrayer extends Notifier<PrayersEnums> {
  final prayerTimes = ProviderContainer().read(prayerTimesProvider);
  @override
  PrayersEnums build() => prayerTimes.nextPrayer;

  void update() => state = prayerTimes.nextPrayer;
}
