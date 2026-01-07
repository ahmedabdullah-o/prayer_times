import 'package:prayer_times/core/enums/prayers_enums.dart';
import 'package:prayer_times/core/services/notifications/inotifications.dart';
import 'package:prayer_times/core/services/storage/hive/ihive_storage.dart';

abstract class IPrayerTimes {
  Map<PrayersEnums, DateTime> prayerTimes(int offset);
  PrayersEnums get nextPrayer;
  Future<void> scheduleTodayPrayerNotifications(
    Inotifications notifications,
    IHiveStorage storage,
  );
}
