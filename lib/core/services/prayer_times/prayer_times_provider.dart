import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:prayer_times/core/enums/prayers_enums.dart';
import 'package:prayer_times/core/services/prayer_times/iprayer_times.dart';
import 'package:prayer_times/core/services/prayer_times/prayer_times.dart';
import 'package:prayer_times/core/services/storage/hive/hive_storage_provider.dart';

final prayerTimesProvider = Provider<IPrayerTimes>((ref) {
  return PrayerTimes();
});

/// Prayer times for the day adjacent to today by [offset] days, resolved from
/// the settings stored in Hive (coordinates, timezone, calculation method).
final prayerTimesForOffsetProvider =
    FutureProvider.family<Map<PrayersEnums, DateTime>, int>((
      ref,
      offset,
    ) async {
      final storage = await ref.watch(hiveStorageProvider.future);
      return ref.watch(prayerTimesProvider).prayerTimes(storage, offset);
    });
