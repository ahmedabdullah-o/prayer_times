import 'package:prayer_times/core/enums/prayers_enums.dart';
import 'package:prayer_times/core/services/notifications/inotifications.dart';

abstract class IPrayerTimes {
  Map<PrayersEnums, DateTime> get todayPrayerTimes;
  PrayersEnums? get nextPrayer;
  Future<void> scheduleTodayPrayerNotifications(Inotifications notifications);
}
