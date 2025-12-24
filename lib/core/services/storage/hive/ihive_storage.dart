import 'dart:ui';

import 'package:adhan_dart/adhan_dart.dart';
import 'package:flutter_timezone/timezone_info.dart';
import 'package:prayer_times/core/enums/athan_sound_enums.dart';
import 'package:prayer_times/core/enums/prayers_enums.dart';

abstract class IHiveStorage {
  void setSavedCalculationMethod(CalculationMethod method);

  Future<CalculationMethod> get savedCalculationMethod;

  void setNotificationMute(PrayersEnums prayer, bool muted);

  Future<bool> getNotificationMute(PrayersEnums prayer);

  void setNotificationSound(PrayersEnums prayer, AthanSoundEnums sound);

  Future<AthanSoundEnums> getNotificationSound(PrayersEnums prayer);

  void setSavedCoordinates(Coordinates coordinates);

  Coordinates get savedCoordinates;

  void setLocation(TimezoneInfo location);

  TimezoneInfo get location;

  void setLocale(Locale locale);

  Locale get locale;
}
