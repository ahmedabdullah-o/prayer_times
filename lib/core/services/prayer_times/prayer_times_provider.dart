import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:prayer_times/core/services/prayer_times/iprayer_times.dart';
import 'package:prayer_times/core/services/prayer_times/prayer_times.dart';

final prayerTimesProvider = Provider<IPrayerTimes>((ref) {
  return PrayerTimes();
});
