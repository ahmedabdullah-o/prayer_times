//ExternalPackages
import 'package:adhan_dart/adhan_dart.dart' as adhan;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:prayer_times/core/enums/notifications_enums.dart';
import 'package:prayer_times/core/enums/prayers_enums.dart';
import 'package:prayer_times/core/services/notifications/inotifications.dart';
import 'package:prayer_times/core/services/notifications/notification_model.dart';
import 'package:prayer_times/core/services/prayer_times/iprayer_times.dart';
import 'package:timezone/data/latest.dart' as tz_data;

//LocalImports
import 'package:timezone/timezone.dart';

class PrayerTimes implements IPrayerTimes {
  final providerContainer = ProviderContainer();
  List<adhan.Coordinates> coords = <adhan.Coordinates>[
    adhan.Coordinates(30.0444, 31.2357), // [0] cairo
  ];
  static int selectedCoordsIndex = 0;

  //TODO: make params and notification sound customizable
  final params = adhan.CalculationMethodParameters.egyptian();
  @override
  Map<PrayersEnums, DateTime> get todayPrayerTimes {
    Map<PrayersEnums, DateTime> out = {};
    final now = DateTime.now();
    final prayerTimesNow = adhan.PrayerTimes(
          coordinates: coords[selectedCoordsIndex],
          calculationParameters: params,
          date: now,
          precision: true,
        ),
        prayerTimesTomorrow = adhan.PrayerTimes(
          coordinates: coords[selectedCoordsIndex],
          calculationParameters: params,
          date: now.add(Duration(days: 1)),
          precision: true,
        );
    final sunnahTimesNow = adhan.SunnahTimes(prayerTimesNow, precision: true),
        sunnahTimesTomorrow = adhan.SunnahTimes(
          prayerTimesTomorrow,
          precision: true,
        );
    final prayerTimes = [
      prayerTimesNow.fajr.isAfter(now)
          ? prayerTimesNow.fajr
          : prayerTimesTomorrow.fajr,
      prayerTimesNow.sunrise.isAfter(now)
          ? prayerTimesNow.sunrise
          : prayerTimesTomorrow.sunrise,
      prayerTimesNow.dhuhr.isAfter(now)
          ? prayerTimesNow.dhuhr
          : prayerTimesTomorrow.dhuhr,
      prayerTimesNow.asr.isAfter(now)
          ? prayerTimesNow.asr
          : prayerTimesTomorrow.asr,
      prayerTimesNow.maghrib.isAfter(now)
          ? prayerTimesNow.maghrib
          : prayerTimesTomorrow.maghrib,
      prayerTimesNow.isha.isAfter(now)
          ? prayerTimesNow.isha
          : prayerTimesTomorrow.isha,
      sunnahTimesNow.middleOfTheNight.isAfter(now)
          ? sunnahTimesNow.middleOfTheNight
          : sunnahTimesTomorrow.middleOfTheNight,
      sunnahTimesNow.lastThirdOfTheNight.isAfter(now)
          ? sunnahTimesNow.lastThirdOfTheNight
          : sunnahTimesTomorrow.lastThirdOfTheNight,
    ];
    tz_data.initializeTimeZones();
    for (int i = 0; i < PrayersEnums.values.length; i++) {
      final scheduleAt = TZDateTime.from(
        prayerTimes[i],
        getLocation("Africa/Cairo"),
      );
      out[PrayersEnums.values[i]] = scheduleAt;
    }
    return out;
  }

  @override
  PrayersEnums? get nextPrayer {
    final now = DateTime.now();
    final prayerTimesNow = adhan.PrayerTimes(
      coordinates: coords[selectedCoordsIndex],
      calculationParameters: params,
      date: now,
      precision: true,
    );
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
    return null;
  }

  @override
  Future<void> scheduleTodayPrayerNotifications(
    Inotifications notifications,
  ) async {
    notifications.init();
    notifications.cancelAll();

    final prayerTimes = todayPrayerTimes;

    for (final prayer in PrayersEnums.values) {
      notifications.schedule(
        NotificationModel(
          prayerTimes[prayer].hashCode,
          prayer.name,
          "It's time to pray ${prayer.name}: ${DateFormat(DateFormat.HOUR24_MINUTE).format(prayerTimes[prayer]!)}",
          notificationDetails: NotificationDetailsEnum.prayer,
        ),
        prayerTimes[prayer]!,
        matchDateTimeComponents: DateTimeComponents.dateAndTime,
      );
    }
  }
}
