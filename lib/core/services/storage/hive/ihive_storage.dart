import 'dart:ui';

import 'package:flutter_timezone/timezone_info.dart';
import 'package:prayer_times/core/enums/athan_sound_enums.dart';
import 'package:prayer_times/core/enums/prayers_enums.dart';

abstract class IHiveStorage {
  void setNotificationMute(PrayersEnums prayer, bool muted);

  bool getNotificationMute(PrayersEnums prayer);

  void setNotificationSound(PrayersEnums prayer, AthanSoundEnums sound);

  AthanSoundEnums getNotificationSound(PrayersEnums prayer);

  void setSavedCoordinates(double longitude, double latitude);

  Map<String, double> get savedCoordinates;

  void setLocation(TimezoneInfo location);

  TimezoneInfo get location;

  void setLocale(Locale locale);

  Locale get locale;
}
