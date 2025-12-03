//ExternalPackages
import 'package:adhan_dart/adhan_dart.dart' as adhan;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:prayer_times/core/enums/notifications_enums.dart';
import 'package:prayer_times/core/enums/prayers_enums.dart';
import 'package:prayer_times/core/services/notifications/notification_model.dart';
import 'package:prayer_times/core/services/notifications/notifications_provider.dart';
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
  Map<String, DateTime> get todayPrayerTimes {
    Map<String, DateTime> out = {};
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
    final prayerTimes = [
      prayerTimesNow.fajr.isAfter(now)
          ? prayerTimesNow.fajr
          : prayerTimesTomorrow.fajr,
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
    ];
    tz_data.initializeTimeZones();
    for (int j = 0; j < 5; j++) {
      final scheduleAt = TZDateTime.from(
        prayerTimes[j],
        getLocation("Africa/Cairo"),
      );
      out[PrayersEnums.values[j].name] = scheduleAt;
    }
    return out;
  }

  @override
  Future<void> scheduleTodayPrayerNotifications() async {
    final notifications = providerContainer.read(notificationsProvider);
    notifications.init();
    notifications.cancelAll();

    final prayerTimes = todayPrayerTimes;

    for (final prayer in PrayersEnums.values) {
      if (prayerTimes[prayer.name] != null) {
        notifications.schedule(
          NotificationModel(
            prayerTimes[prayer.name].hashCode,
            prayer.name,
            "It's time to pray ${prayer.name}: ${DateFormat(DateFormat.HOUR24_MINUTE).format(prayerTimes[prayer.name]!)}",
            notificationDetails: NotificationDetailsEnum.prayer,
          ),
          prayerTimes[prayer.name]!,
          matchDateTimeComponents: DateTimeComponents.dateAndTime,
        );
      }
    }
  }
}
