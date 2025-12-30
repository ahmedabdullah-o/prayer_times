import 'dart:ui';

import 'package:adhan_dart/adhan_dart.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_timezone/timezone_info.dart';
import 'package:logging/logging.dart';
import 'package:prayer_times/core/enums/athan_sound_enums.dart';
import 'package:prayer_times/core/enums/prayers_enums.dart';
import 'package:prayer_times/core/services/storage/hive/hive_storage_provider.dart';
import 'package:prayer_times/core/services/storage/hive/ihive_storage.dart';

void main() {
  ProviderContainer providerContainer = ProviderContainer();
  IHiveStorage? storage;

  setUpAll(() async {
    Logger.root.level = Level.ALL;
    Logger.root.onRecord.listen((record) {
      if (kDebugMode) {
        debugPrint(
          '${record.level.name}: ${record.loggerName}: ${record.message}',
        );
        if (record.error != null) {
          debugPrint('${record.error}\n${record.stackTrace}');
        }
      }
    });
  });

  setUp(() async {
    storage = await providerContainer.read(hiveStorageProvider.future);
    await storage!.init(temp: true);
  });

  tearDown(() async {
    await storage!.clear();
    await storage!.dispose();
    providerContainer.invalidate(hiveStorageProvider);
  });

  group('Hive Storage Test', () {
    group('storage returns default values', () {
      test('default calculation method returned', () async {
        final query = await storage!.savedCalculationMethod;
        expect(query, isNotNull);
      });
      test('default notification mute settings returned', () async {
        final query = await storage!.getNotificationMute(PrayersEnums.fajr);
        expect(query, isNotNull);
      });
      test('default notification sound returned', () async {
        final query = await storage!.getNotificationSound(PrayersEnums.fajr);
        expect(query, isNotNull);
      });
      test('default coordinates returned', () async {
        final query = await storage!.savedCoordinates;
        expect(query, isNotNull);
      });
      test('default location returned', () async {
        final query = await storage!.location;
        expect(query, isNotNull);
      });
      test('default locale returned', () async {
        final query = await storage!.locale;
        expect(query, isNotNull);
      });
    });
    group('storage writes values', () {
      test('storages writes calculation method', () async {
        storage!.setSavedCalculationMethod(CalculationMethod.other);
        final query = await storage!.savedCalculationMethod;
        expect(query, CalculationMethod.other);
      });
      test('storages writes notification mute', () async {
        storage!.setNotificationMute(PrayersEnums.fajr, true);
        final query = await storage!.getNotificationMute(PrayersEnums.fajr);
        expect(query, true);
      });
      test('storages writes notification sound', () async {
        storage!.setNotificationSound(
          PrayersEnums.fajr,
          AthanSoundEnums.defaultSound,
        );
        final query = await storage!.getNotificationSound(PrayersEnums.fajr);
        expect(query, AthanSoundEnums.defaultSound);
      });
      test('storages writes coordinates', () async {
        storage!.setSavedCoordinates(Coordinates(0, 0));
        final query = await storage!.savedCoordinates;
        expect(query, Coordinates(0, 0));
      });
      test('storages writes location', () async {
        storage!.setLocation(TimezoneInfo(identifier: "America/Los_Angeles"));
        final query = await storage!.location;
        expect(query, TimezoneInfo(identifier: "America/Los_Angeles"));
      });
      test('storages writes locale', () async {
        storage!.setLocale(Locale('ar', 'EG'));
        final query = await storage!.locale;
        expect(query, Locale('ar', 'EG'));
      });
    });
  });
}
