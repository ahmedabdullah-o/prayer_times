//ExternalPackages
import 'package:adhan_dart/adhan_dart.dart' as adhan;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:prayer_times/core/enums/notifications_enums.dart';
import 'package:prayer_times/core/services/notifications/notification_model.dart';
import 'package:prayer_times/core/services/notifications/notifications_provider.dart';
import 'package:prayer_times/core/services/prayer_times/iprayer_times.dart';

//LocalImports
import 'package:timezone/timezone.dart';

final prayerTimesNames = ["Fajr", "Dhuhr", "Asr", "Maghrib", "Isha"];

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
    for (int j = 0; j < 5; j++) {
      final scheduleAt = TZDateTime.from(
        prayerTimes[j],
        getLocation("Africa/Cairo"),
      );
      out[prayerTimesNames[j]] = scheduleAt;
    }
    return out;
  }

  @override
  Future<void> scheduleTodayPrayerNotifications() async {
    final notifications = providerContainer.read(notificationsProvider);
    notifications.init();
    notifications.cancelAll();

    final prayerTimes = todayPrayerTimes;

    for (final prayer in prayerTimesNames) {
      if (prayerTimes[prayer] != null) {
        notifications.schedule(
          NotificationModel(
            prayerTimes[prayer].hashCode,
            prayer,
            "It's time to pray $prayer: ${DateFormat(DateFormat.HOUR24_MINUTE).format(prayerTimes[prayer]!)}",
            notificationDetails: NotificationDetailsEnum.prayer,
          ),
          prayerTimes[prayer]!,
          matchDateTimeComponents: DateTimeComponents.dateAndTime,
        );
      }
    }
  }
}
