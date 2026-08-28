import 'package:prayer_times/core/enums/prayers_enums.dart';
import 'package:prayer_times/core/services/notifications/inotifications.dart';
import 'package:prayer_times/core/services/storage/hive/ihive_storage.dart';

/// Prayer Times Calculation - implemented using `adhan_dart`
///
/// This service works according to data stored in local storage to determine
/// parameters for it's calculation like:
/// * Coordinates
/// * CalculationMethod
/// * Timezone
abstract class IPrayerTimes {
  /// Returns prayer times in the form of a map of the available [PrayersEnums]
  /// paired with each's time for the day adjacent to today by [offset] days,
  /// expressed in the stored timezone.
  ///
  /// example:
  /// ```dart
  /// prayerTimes(storage, 0); // prayer times today
  /// prayerTimes(storage, 1); // prayer times tomorrow
  /// prayerTimes(storage, -1); // prayer times yesterday
  /// ```
  Future<Map<PrayersEnums, DateTime>> prayerTimes(
    IHiveStorage storage,
    int offset,
  );

  /// Returns the next obligatory prayer that hasn't occurred yet.
  Future<PrayersEnums> nextPrayer(IHiveStorage storage);

  /// Schedules notifications for today's remaining prayer times, using the
  /// mute state and Athan sound stored for each prayer.
  ///
  /// Prayers that already occurred today are skipped. Make sure to
  /// initialize [storage] before using this.
  Future<void> scheduleTodayPrayerNotifications(
    Inotifications notifications,
    IHiveStorage storage,
  );
}
