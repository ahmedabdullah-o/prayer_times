abstract class IPrayerTimes {
  Map<String, DateTime> get todayPrayerTimes;
  Future<void> scheduleTodayPrayerNotifications();
}
