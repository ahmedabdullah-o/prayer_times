import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:prayer_times/core/enums/prayers_enums.dart';
import 'package:prayer_times/core/services/prayer_times/prayer_times_provider.dart';
import 'package:prayer_times/core/services/storage/hive/hive_storage_provider.dart';

final nextPrayerProvider = AsyncNotifierProvider<NextPrayer, PrayersEnums>(
  NextPrayer.new,
);

class NextPrayer extends AsyncNotifier<PrayersEnums> {
  @override
  Future<PrayersEnums> build() async {
    final storage = await ref.watch(hiveStorageProvider.future);
    return ref.watch(prayerTimesProvider).nextPrayer(storage);
  }

  Future<void> advance() async {
    final storage = await ref.read(hiveStorageProvider.future);
    state = AsyncData(await ref.read(prayerTimesProvider).nextPrayer(storage));
  }
}
