import 'dart:ui';

import 'package:adhan_dart/adhan_dart.dart';
import 'package:flutter_timezone/timezone_info.dart';
import 'package:prayer_times/core/enums/athan_sound_enums.dart';
import 'package:prayer_times/core/enums/prayers_enums.dart';

/// Storage Service - implemented using Hive.
///
/// The service uses default values when `null` is saved in the storage. You don't
/// have to insert values before selecting them.
abstract class IHiveStorage {
  /// Checks if the service is ready to use whether it's initializing HiveFlutter
  /// or opening boxes.
  Future<bool> get isInitialized;

  /// initialize storage.
  ///
  /// set [temp] to `true` when testing. this makes sure the service is using
  /// system temp directory. However, it's still important to clear the storage
  /// when finished with testing.
  ///
  /// Unfortunately Hive doesn't support in-memory storage so it actually creates
  /// the storage on system disk.
  Future<void> init({bool temp = false});

  Future<void> dispose();

  /// Permanently clear app storage.
  Future<void> clear();

  Future<void> setAutoSettings(bool activated);

  Future<bool> get autoSettings;

  Future<void> setSavedMadhab(Madhab madhab);

  Future<Madhab> get savedMadhab;

  Future<void> setSavedCalculationMethod(CalculationMethod method);

  Future<CalculationMethod> get savedCalculationMethod;

  Future<void> setNotificationMute(PrayersEnums prayer, bool muted);

  Future<bool> getNotificationMute(PrayersEnums prayer);

  Future<void> setNotificationSound(PrayersEnums prayer, AthanSoundEnums sound);

  Future<AthanSoundEnums> getNotificationSound(PrayersEnums prayer);

  Future<void> setSavedCoordinates(Coordinates coordinates);

  Future<Coordinates> get savedCoordinates;

  /// This is only general location/timezone (e.g: `Africa/Cairo`)
  Future<void> setLocation(TimezoneInfo location);

  /// This is only general location/timezone (e.g: `Africa/Cairo`)
  Future<TimezoneInfo> get location;

  Future<void> setLocale(Locale locale);

  Future<Locale> get locale;
}
