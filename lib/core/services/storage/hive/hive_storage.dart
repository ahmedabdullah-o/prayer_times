import 'dart:ui';

import 'package:adhan_dart/adhan_dart.dart';
import 'package:flutter_timezone/timezone_info.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:logging/logging.dart';
import 'package:prayer_times/core/enums/athan_sound_enums.dart';
import 'package:prayer_times/core/enums/prayers_enums.dart';
import 'package:prayer_times/core/extensions/enum_extentions.dart';
import 'package:prayer_times/core/services/storage/hive/ihive_storage.dart';

class HiveStorage implements IHiveStorage {
  final _logger = Logger('core - services - hive storage');

  bool _isInitialized = false;

  late final Box _notificationMuteSettingsBox;
  late final Box _notificationSoundSettingsBox;
  late final Box _generalSettingsBox;

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
    PrayersEnums.sunrise: AthanSoundEnums.defaultSound,
    PrayersEnums.dhuhr: AthanSoundEnums.abdulbasit,
    PrayersEnums.asr: AthanSoundEnums.abdulbasit,
    PrayersEnums.maghrib: AthanSoundEnums.abdulbasit,
    PrayersEnums.isha: AthanSoundEnums.abdulbasit,
    PrayersEnums.midnight: AthanSoundEnums.defaultSound,
    PrayersEnums.lastThird: AthanSoundEnums.defaultSound,
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

  @override
  Future<bool> get isInitialized async {
    _logger.info('isInitialized: checking if storage is initialized...');
    try {
      return _isInitialized;
    } catch (e, s) {
      _logger.shout('could not return storage initialization state', e, s);
      throw Exception();
    }
  }

  @override
  Future<void> init() async {
    _logger.info("init(): initializing storage");
    if (await isInitialized) {
      _logger.info('init(): cancelled reinitialization');
      return;
    } else {
      try {
        _logger.fine("init(): intializing Hive");
        await Hive.initFlutter();
        _logger.fine("init(): opening boxes...");
        _logger.finer("init(): opening box (soundMuteSettings)");
        _notificationMuteSettingsBox = await Hive.openBox("soundMuteSettings");
        _logger.finer("init(): opening box (athanSoundSettings)");
        _notificationSoundSettingsBox = await Hive.openBox(
          "athanSoundSettings",
        );
        _logger.finer("init(): opening box (general)");
        _generalSettingsBox = await Hive.openBox('general');
        _isInitialized = true;
        _logger.info("init(): initialization success");
      } catch (e, s) {
        _logger.shout("failed to initialize storage", e, s);
        throw Exception();
      }
    }
  }

  @override
  Future<void> dispose() async {
    if (!await isInitialized) {
      _logger.fine("dispose(): storage is already closed");
      return;
    } else {
      try {
        _logger.info("dispose(): closing storage...");
        await Hive.close();
        _isInitialized = false;
        _logger.info("dispose(): close storage success");
        return;
      } catch (e, s) {
        _logger.shout("dispose(): failed to close storage", e, s);
        throw Exception();
      }
    }
  }

  @override
  Future<void> clear() async {
    try {
      _logger.info("clear(): clearing storage...");
      await Hive.deleteFromDisk();
      _logger.info("clear(): clear storage success");
      return;
    } catch (e, s) {
      _logger.shout("clear(): failed to clear storage", e, s);
      throw Exception();
    }
  }

  @override
  Future<void> setSavedCalculationMethod(CalculationMethod method) async {
    try {
      _logger.info("setSavedCalculationMethod(): writing to storage...");
      await _generalSettingsBox.put("calculation_method", method.name);
      _logger.info("setSavedCalculationMethod(): write to storage success");
      return;
    } catch (e, s) {
      _logger.shout("setSavedCalculationMethod(): storage write fail", e, s);
      throw Exception();
    }
  }

  @override
  Future<CalculationMethod> get savedCalculationMethod async {
    try {
      _logger.info("savedCalculationMethod: running query...");
      final query =
          _generalSettingsBox.get(
                "calculation_method",
                defaultValue: _generalDefault["calculation_method"],
              )
              as String;
      _logger.info(
        "savedCalculationMethod: query success with value (${query.toString()})",
      );
      _logger.info("savedCalculationMethod: parsing output from query...");
      final output = CalculationMethod.values.mapEnums[query];
      _logger.info(
        "savedCalculationMethod: parse success with value of (${output.toString()})",
      );
      return output;
    } catch (e, s) {
      _logger.shout("savedCalculationMethod: storage read fail", e, s);
      throw Exception();
    }
  }

  @override
  Future<void> setNotificationMute(PrayersEnums prayer, bool muted) async {
    try {
      _logger.info("setNotificationMute(): writing to storage...");
      await _notificationMuteSettingsBox.put(prayer.name, muted);
      _logger.info("setNotificationMute(): write to storage success");
      return;
    } catch (e, s) {
      _logger.shout("setNotificationMute(): storage write fail", e, s);
      throw Exception();
    }
  }

  @override
  Future<bool> getNotificationMute(PrayersEnums prayer) async {
    try {
      _logger.info("getNotificationMute(): running query...");
      final query = await _notificationMuteSettingsBox.get(
        prayer.name,
        defaultValue: _notificationMuteDefault[prayer],
      );
      _logger.info(
        "getNotificationMute(): query success with value (${query.toString()})",
      );
      return query as bool;
    } catch (e, s) {
      _logger.shout("getNotificationMute(): storage read fail", e, s);
      throw Exception();
    }
  }

  @override
  Future<void> setNotificationSound(
    PrayersEnums prayer,
    AthanSoundEnums sound,
  ) async {
    try {
      _logger.info("setNotificationSound(): writing to storage...");
      await _notificationSoundSettingsBox.put(prayer.name, sound.name);
      _logger.info("setNotificationSound(): write to storage success");
      return;
    } catch (e, s) {
      _logger.shout("setNotificationSound(): storage write fail", e, s);
      throw Exception();
    }
  }

  @override
  Future<AthanSoundEnums> getNotificationSound(PrayersEnums prayer) async {
    try {
      _logger.info("getNotificationSound(): running query...");
      final query =
          await _notificationSoundSettingsBox.get(
                prayer.name,
                defaultValue: _notificationSoundDefault[prayer]!.name,
              )
              as String;
      _logger.info(
        "getNotificationSound(): query success with value (${query.toString()})",
      );
      _logger.info("getNotificationSound(): parsing output from query...");
      final output = PrayersEnums.values.mapEnums[query];
      _logger.info(
        "getNotificationSound(): parse success with value (${output.toString()})",
      );
      return output;
    } catch (e, s) {
      _logger.shout("getNotificationSound(): storage read fail", e, s);
      throw Exception();
    }
  }

  @override
  Future<void> setSavedCoordinates(Coordinates coordinates) async {
    try {
      _logger.info("setSavedCoordinates(): writing to storage...");
      await _generalSettingsBox.putAll({
        "latitude": coordinates.latitude,
        "longitude": coordinates.longitude,
      });
      _logger.info("setSavedCoordinates(): storage write success");
    } catch (e, s) {
      _logger.shout("setSavedCoordinates(): storage write fail", e, s);
      throw Exception();
    }
  }

  @override
  Future<Coordinates> get savedCoordinates async {
    try {
      _logger.info("savedCoordinates: running query...");
      _logger.info("savedCoordinates: querying saved latitude");
      double latitude =
          _generalSettingsBox.get(
                "latitude",
                defaultValue: double.parse(_generalDefault['latitude']!),
              )
              as double;
      _logger.info("savedCoordinates: querying saved longitude");
      double longitude =
          _generalSettingsBox.get(
                "longitude",
                defaultValue: double.parse(_generalDefault['longitude']!),
              )
              as double;
      _logger.info("savedCoordinates: parsing output from query...");
      final output = Future.value(Coordinates(latitude, longitude));
      _logger.info(
        "savedCoordinates: parse success with value (${output.toString()})",
      );
      return output;
    } catch (e, s) {
      _logger.shout("savedCoordinates: storage read fail", e, s);
      throw Exception();
    }
  }

  @override
  Future<void> setLocation(TimezoneInfo location) async {
    try {
      _logger.info("setLocation(): writing to storage...");
      await _generalSettingsBox.put("location", location.identifier);
      _logger.info("setLocation(): storage write success");
      return;
    } catch (e, s) {
      _logger.shout("setLocation(): storage write fail", e, s);
      throw Exception();
    }
  }

  @override
  Future<TimezoneInfo> get location async {
    try {
      _logger.info("location: running query...");
      final query =
          _generalSettingsBox.get(
                "location",
                defaultValue: _generalDefault["location"]!,
              )
              as String;
      _logger.info("location: query success with value (${query.toString()})");
      _logger.info("location: parsing output from query...");
      final output = TimezoneInfo(identifier: query);
      _logger.info("location: parse success with value (${output.toString()})");
      return Future.value(output);
    } catch (e, s) {
      _logger.shout("location: storage read fail", e, s);
      throw Exception();
    }
  }

  @override
  Future<void> setLocale(Locale locale) async {
    try {
      _logger.info("setLocale(): writing to storage...");
      await _generalSettingsBox.put(
        "locale",
        "${locale.languageCode}-${locale.countryCode}",
      );
      _logger.info("setLocale(): storage write success");
      return;
    } catch (e, s) {
      _logger.shout("setLocale(): storage write fail", e, s);
      throw Exception();
    }
  }

  @override
  Future<Locale> get locale async {
    try {
      _logger.info("locale: running query...");
      final query =
          _generalSettingsBox.get("locale", defaultValue: "en-US") as String;
      _logger.info("locale: query success with value (${query.toString()})");
      _logger.info("locale: parsing output from query...");
      final output = Locale(query.substring(0, 2), query.substring(3));
      _logger.info("locale: parse success with value (${output.toString()})");
      return Future.value(output);
    } catch (e, s) {
      _logger.shout("locale: storage read fail", e, s);
      throw Exception();
    }
  }
}
