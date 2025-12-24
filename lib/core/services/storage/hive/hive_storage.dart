import 'package:hive/hive.dart';
import 'package:prayer_times/core/enums/athan_sound_enums.dart';
import 'package:prayer_times/core/enums/prayers_enums.dart';
import 'package:prayer_times/core/enums/settings_category_enums.dart';
import 'package:prayer_times/core/services/storage/hive/ihive_storage.dart';

class HiveStorage implements IHiveStorage {
  final _notificationSoundOnOffSettingsBox = Hive.box("soundOnOffSettings");
  final _notificationAthanSoundSettingsBox = Hive.box("athanSoundSettings");

  final _notificationSoundOnOffDefault = <PrayersEnums, bool>{
    PrayersEnums.fajr: true,
    PrayersEnums.dhuhr: true,
    PrayersEnums.asr: true,
    PrayersEnums.maghrib: true,
    PrayersEnums.isha: true,
  };
  final _notificationAthanSoundDefault = <PrayersEnums, AthanSoundEnums>{
    PrayersEnums.fajr: AthanSoundEnums.abdulbasit,
    PrayersEnums.dhuhr: AthanSoundEnums.abdulbasit,
    PrayersEnums.asr: AthanSoundEnums.abdulbasit,
    PrayersEnums.maghrib: AthanSoundEnums.abdulbasit,
    PrayersEnums.isha: AthanSoundEnums.abdulbasit,
  };

  final _generalSettingsBox = Hive.box('general');
  final _generalDefault = <String, String>{
    // Location Settings.
    // Cairo by default
    "latitude": "30.0444",
    "longitude": "31.2357",
    "location": "Africa/Cairo",

    // Locale Settings
    "locale": "en-US",
  };

  @override
  void init() {}

  @override
  void set(String key, String value) {
    // TODO: implement set
    throw UnimplementedError();
  }

  @override
  dynamic getSettings(SettingsCategoryEnums category, Enum key) {
    switch (category) {
      case SettingsCategoryEnums.notificationOnOff:
        return key is PrayersEnums
            ? _notificationSoundOnOffSettingsBox.get(
                key,
                defaultValue: _notificationSoundOnOffDefault[key],
              )
            : null;
      case SettingsCategoryEnums.notificationSound:
        return key is PrayersEnums
            ? _notificationAthanSoundSettingsBox.get(
                key,
                defaultValue: _notificationAthanSoundDefault[key],
              )
            : null;
    }
  }
}
