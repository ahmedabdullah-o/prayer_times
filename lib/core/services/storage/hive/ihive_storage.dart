import 'dart:ui';

import 'package:adhan_dart/adhan_dart.dart';
import 'package:flutter_timezone/timezone_info.dart';
import 'package:prayer_times/core/enums/athan_sound_enums.dart';
import 'package:prayer_times/core/enums/prayers_enums.dart';

abstract class IHiveStorage {
  Future<bool> get isInitialized;

  Future<void> init();

  Future<void> dispose();

  Future<void> clear();

  Future<void> setSavedCalculationMethod(CalculationMethod method);

  Future<CalculationMethod> get savedCalculationMethod;

  Future<void> setNotificationMute(PrayersEnums prayer, bool muted);

  Future<bool> getNotificationMute(PrayersEnums prayer);

  Future<void> setNotificationSound(PrayersEnums prayer, AthanSoundEnums sound);

  Future<AthanSoundEnums> getNotificationSound(PrayersEnums prayer);

  Future<void> setSavedCoordinates(Coordinates coordinates);

  Future<Coordinates> get savedCoordinates;

  Future<void> setLocation(TimezoneInfo location);

  Future<TimezoneInfo> get location;

  Future<void> setLocale(Locale locale);

  Future<Locale> get locale;
}
