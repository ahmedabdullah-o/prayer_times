import 'package:hive/hive.dart';
import 'package:prayer_times/core/enums/athan_sound_enums.dart';
import 'package:prayer_times/core/enums/prayers_enums.dart';
import 'package:prayer_times/core/enums/settings_category_enums.dart';
import 'package:prayer_times/core/services/storage/hive/ihive_storage.dart';

class HiveStorage implements IHiveStorage {
  final _notificationMuteSettingsBox = Hive.box("soundOnOffSettings");
  final _notificationSoundSettingsBox = Hive.box("athanSoundSettings");

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

  
}
