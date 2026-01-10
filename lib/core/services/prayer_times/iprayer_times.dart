import 'package:prayer_times/core/enums/prayers_enums.dart';
import 'package:prayer_times/core/services/notifications/inotifications.dart';
import 'package:prayer_times/core/services/storage/hive/ihive_storage.dart';

/// Prayer Times Calculation - implemented using `adhan_dart`
///
/// This service works according to data stored in local storage to determine
/// parameters for it's calculation like:
/// * Coordinates
/// * Madhab
/// * CalculationMethod
abstract class IPrayerTimes {
  /// Returns prayer times in the form of a map of the available [PrayersEnums]
  /// paired with each's time according to the date adjacent to today by [offset] days.
  ///
  /// example:
  /// ```dart
  /// prayerTimes(0); // prayer times today
  /// prayerTimes(1); // prayer times tomorrow
  /// prayerTimes(-1); // prayer times yesterday
  /// ```
  Map<PrayersEnums, DateTime> prayerTimes(int offset);
  PrayersEnums get nextPrayer;

  /// Schedules today prayer times.
  ///
  /// Make sure to initialize [storage] before using this.
  Future<void> scheduleTodayPrayerNotifications(
    Inotifications notifications,
    IHiveStorage storage,
  );
}
