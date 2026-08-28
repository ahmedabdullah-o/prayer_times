import 'package:adhan_dart/adhan_dart.dart' as adhan;
import 'package:intl/intl.dart';
import 'package:logging/logging.dart';
import 'package:prayer_times/core/enums/prayers_enums.dart';
import 'package:prayer_times/core/extensions/string_extensions.dart';
import 'package:prayer_times/core/services/notifications/inotifications.dart';
import 'package:prayer_times/core/services/notifications/notification_model.dart';
import 'package:prayer_times/core/services/prayer_times/iprayer_times.dart';
import 'package:prayer_times/core/services/storage/hive/ihive_storage.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart';

class PrayerTimes implements IPrayerTimes {
  final _logger = Logger('core - services - prayer times');

  /// Maps the stored [adhan.CalculationMethod] to its calculation parameters.
  adhan.CalculationParameters _parameters(adhan.CalculationMethod method) {
    return switch (method) {
      adhan.CalculationMethod.dubai =>
        adhan.CalculationMethodParameters.dubai(),
      adhan.CalculationMethod.egyptian =>
        adhan.CalculationMethodParameters.egyptian(),
      adhan.CalculationMethod.karachi =>
        adhan.CalculationMethodParameters.karachi(),
      adhan.CalculationMethod.kuwait =>
        adhan.CalculationMethodParameters.kuwait(),
      adhan.CalculationMethod.moonsightingCommittee =>
        adhan.CalculationMethodParameters.moonsightingCommittee(),
      adhan.CalculationMethod.morocco =>
        adhan.CalculationMethodParameters.morocco(),
      adhan.CalculationMethod.muslimWorldLeague =>
        adhan.CalculationMethodParameters.muslimWorldLeague(),
      adhan.CalculationMethod.northAmerica =>
        adhan.CalculationMethodParameters.northAmerica(),
      adhan.CalculationMethod.other =>
        adhan.CalculationMethodParameters.other(),
      adhan.CalculationMethod.qatar =>
        adhan.CalculationMethodParameters.qatar(),
      adhan.CalculationMethod.singapore =>
        adhan.CalculationMethodParameters.singapore(),
      adhan.CalculationMethod.tehran =>
        adhan.CalculationMethodParameters.tehran(),
      adhan.CalculationMethod.turkiye =>
        adhan.CalculationMethodParameters.turkiye(),
      adhan.CalculationMethod.ummAlQura =>
        adhan.CalculationMethodParameters.ummAlQura(),
    };
  }

  /// Resolves the stored timezone. Falls back to UTC (with a warning) if the
  /// stored identifier is unknown.
  Future<Location> _location(IHiveStorage storage) async {
    tz_data.initializeTimeZones();
    final identifier = (await storage.location).identifier;
    try {
      return getLocation(identifier);
    } catch (e, s) {
      _logger.warning(
        '_location(): unknown timezone ($identifier), falling back to UTC',
        e,
        s,
      );
      return getLocation('UTC');
    }
  }

  Future<adhan.PrayerTimes> _adhanPrayerTimes(
    IHiveStorage storage,
    DateTime date,
  ) async {
    final coordinates = await storage.savedCoordinates;
    final method = await storage.savedCalculationMethod;
    return adhan.PrayerTimes(
      coordinates: adhan.Coordinates(
        coordinates.latitude,
        coordinates.longitude,
      ),
      calculationParameters: _parameters(method),
      date: date,
      precision: true,
    );
  }

  @override
  Future<Map<PrayersEnums, DateTime>> prayerTimes(
    IHiveStorage storage,
    int offset,
  ) async {
    final Map<PrayersEnums, DateTime> out = {};
    final now = DateTime.now().add(Duration(days: offset));
    final prayerTimesNow = await _adhanPrayerTimes(storage, now);
    final sunnahTimesNow = adhan.SunnahTimes(prayerTimesNow, precision: true);
    final prayerTimes = [
      prayerTimesNow.fajr,
      prayerTimesNow.sunrise,
      prayerTimesNow.dhuhr,
      prayerTimesNow.asr,
      prayerTimesNow.maghrib,
      prayerTimesNow.isha,
      sunnahTimesNow.middleOfTheNight,
      sunnahTimesNow.lastThirdOfTheNight,
    ];
    final location = await _location(storage);
    for (int i = 0; i < PrayersEnums.values.length; i++) {
      out[PrayersEnums.values[i]] = TZDateTime.from(prayerTimes[i], location);
    }
    return out;
  }

  @override
  Future<PrayersEnums> nextPrayer(IHiveStorage storage) async {
    final now = DateTime.now();
    final prayerTimesNow = await _adhanPrayerTimes(storage, now);
    final prayers = {
      prayerTimesNow.fajr: PrayersEnums.fajr,
      prayerTimesNow.dhuhr: PrayersEnums.dhuhr,
      prayerTimesNow.asr: PrayersEnums.asr,
      prayerTimesNow.maghrib: PrayersEnums.maghrib,
      prayerTimesNow.isha: PrayersEnums.isha,
    };
    final prayersTimes = prayers.keys.toList()..sort((a, b) => a.compareTo(b));
    for (final prayer in prayersTimes) {
      if (prayer.isAfter(now)) return prayers[prayer]!;
    }
    return PrayersEnums.fajr;
  }

  @override
  Future<void> scheduleTodayPrayerNotifications(
    Inotifications notifications,
    IHiveStorage storage,
  ) async {
    await notifications.init();
    await notifications.cancelAll();

    final now = DateTime.now();
    final todayPrayerTimes = await prayerTimes(storage, 0);

    for (final prayer in PrayersEnums.values) {
      if (await storage.getNotificationMute(prayer)) continue;
      final scheduleAt = todayPrayerTimes[prayer]!;
      // Skip prayers that already occurred today.
      if (!scheduleAt.isAfter(now)) continue;
      final sound = await storage.getNotificationSound(prayer);
      await notifications.schedule(
        NotificationModel.prayer(
          id: prayer.index + 1,
          title: prayer.name.camelCaseToTitleCase(),
          body:
              "It's time to pray ${prayer.name.camelCaseToTitleCase()}: "
              '${DateFormat(DateFormat.HOUR24_MINUTE).format(scheduleAt)}',
          sound: sound,
        ),
        TZDateTime.from(scheduleAt, await _location(storage)),
      );
    }
  }
}
