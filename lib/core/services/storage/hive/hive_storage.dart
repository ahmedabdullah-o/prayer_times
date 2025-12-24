import 'dart:ui';

import 'package:adhan_dart/adhan_dart.dart';
import 'package:flutter_timezone/timezone_info.dart';
import 'package:hive/hive.dart';
import 'package:prayer_times/core/enums/athan_sound_enums.dart';
import 'package:prayer_times/core/enums/prayers_enums.dart';
import 'package:prayer_times/core/enums/settings_category_enums.dart';
import 'package:prayer_times/core/extensions/enum_extentions.dart';
import 'package:prayer_times/core/services/storage/hive/ihive_storage.dart';

class HiveStorage implements IHiveStorage {
  late final LazyBox _notificationMuteSettingsBox;
  late final LazyBox _notificationSoundSettingsBox;
  late final LazyBox _generalSettingsBox;

  final _notificationMuteDefault = <PrayersEnums, bool>{
    PrayersEnums.fajr: false,
    PrayersEnums.sunrise: true,
    PrayersEnums.dhuhr: false,
    PrayersEnums.asr: false,
    PrayersEnums.maghrib: false,
    PrayersEnums.isha: false,
    PrayersEnums.midnight: true,
    PrayersEnums.lastThird: true,
  };
  final _notificationSoundDefault = <PrayersEnums, AthanSoundEnums>{
    PrayersEnums.fajr: AthanSoundEnums.abdulbasit,
    PrayersEnums.dhuhr: AthanSoundEnums.abdulbasit,
    PrayersEnums.asr: AthanSoundEnums.abdulbasit,
    PrayersEnums.maghrib: AthanSoundEnums.abdulbasit,
    PrayersEnums.isha: AthanSoundEnums.abdulbasit,
  };

  final _generalDefault = <String, String>{
    // Location Settings.
    // Cairo by default
    "latitude": "30.0444",
    "longitude": "31.2357",
    "location": "Africa/Cairo",

    // Locale Settings
    "locale": "en-US",

    // Prayer time calculation method
    "calculation_method": CalculationMethod.egyptian.name,
  };

  void _init() async {
    _notificationMuteSettingsBox = await Hive.openLazyBox("soundMuteSettings");
    _notificationSoundSettingsBox = await Hive.openLazyBox(
      "athanSoundSettings",
    );
    _generalSettingsBox = await Hive.openLazyBox('general');
  }

  @override
  void setSavedCalculationMethod(CalculationMethod method) {
    _generalSettingsBox.put("calculation_method", method.name);
  }

  @override
  Future<CalculationMethod> get savedCalculationMethod {
    final query =
        _generalSettingsBox.get(
              "calculation_method",
              defaultValue: _generalDefault["calculation_method"],
            )
            as String;
    return CalculationMethod.values.mapEnums[query];
  }

  @override
  void setNotificationMute(PrayersEnums prayer, bool muted) {
    _notificationMuteSettingsBox.put(prayer.name, muted);
  }

  @override
  Future<bool> getNotificationMute(PrayersEnums prayer) async {
    return await _notificationMuteSettingsBox.get(
      prayer.name,
      defaultValue: false,
    );
  }

  @override
  void setNotificationSound(PrayersEnums prayer, AthanSoundEnums sound) {
    _notificationSoundSettingsBox.put(prayer.name, sound.name);
  }

  @override
  Future<AthanSoundEnums> getNotificationSound(PrayersEnums prayer) async {
    final query =
        await _notificationSoundSettingsBox.get(
              prayer.name,
              defaultValue: AthanSoundEnums.abdulbasit.name,
            )
            as String;
    return PrayersEnums.values.mapEnums[query];
  }

  @override
  void setSavedCoordinates(Coordinates coordinates) {
    _generalSettingsBox.putAll({
      "latitude": coordinates.latitude,
      "longitude": coordinates.longitude,
    });
  }

  @override
  Coordinates get savedCoordinates {
    double latitude =
        _generalSettingsBox.get(
              "latitude",
              defaultValue: double.parse(_generalDefault['latitude']!),
            )
            as double;

    double longitude =
        _generalSettingsBox.get(
              "longitude",
              defaultValue: double.parse(_generalDefault['longitude']!),
            )
            as double;
    return Coordinates(latitude, longitude);
  }

  @override
  void setLocation(TimezoneInfo location) {
    _generalSettingsBox.put("location", location.identifier);
  }

  @override
  TimezoneInfo get location {
    return TimezoneInfo(
      identifier:
          _generalSettingsBox.get(
                "location",
                defaultValue: _generalDefault["location"]!,
              )
              as String,
    );
  }

  @override
  void setLocale(Locale locale) {
    _generalSettingsBox.put(
      "locale",
      "${locale.languageCode}-${locale.countryCode}",
    );
  }

  @override
  Locale get locale {
    final query =
        _generalSettingsBox.get("locale", defaultValue: "en-US") as String;
    return Locale(query.substring(0, 2), query.substring(3));
  }
}
