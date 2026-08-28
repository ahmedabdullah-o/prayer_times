import 'dart:io';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:logging/logging.dart';
import 'package:prayer_times/core/enums/athan_sound_enums.dart';
import 'package:prayer_times/core/enums/notifications_enums.dart';
import 'package:prayer_times/core/extensions/notifications_extensions.dart';
import 'package:prayer_times/core/services/notifications/inotifications.dart';
import 'package:prayer_times/core/services/notifications/notification_model.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

class Notifications implements Inotifications {
  final _logger = Logger('core - services - notifications');

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

  Notifications(this.flutterLocalNotificationsPlugin);

  AndroidFlutterLocalNotificationsPlugin? get _androidImplementation {
    return flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
  }

  Future<bool> _isAndroidNotificationsEnabled() async {
    final bool? isEnabled = await _androidImplementation
        ?.areNotificationsEnabled();
    return isEnabled ?? false;
  }

  @override
  Future<void> init() async {
    //Init timezone database
    tz_data.initializeTimeZones();
    final initializationSettings = InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
    );
    //Initialize Plugin
    // Notification taps rely on Android's default launch behavior (opens the app).
    flutterLocalNotificationsPlugin.initialize(initializationSettings);

    //Create channels: one general channel + one prayer channel per Athan sound.
    final androidImplementation = _androidImplementation;
    for (var value in NotificationDetailsEnum.values) {
      final notificationChannel = value.android.toAndroidNotificationChannel;
      await androidImplementation?.createNotificationChannel(
        notificationChannel,
      );
    }
    for (var sound in AthanSoundEnums.values) {
      final notificationChannel = NotificationModel.prayerNotificationDetails(
        sound,
      ).android!.toAndroidNotificationChannel;
      await androidImplementation?.createNotificationChannel(
        notificationChannel,
      );
    }

    //Request permissions is done here because it's considered a thing that you need for the service to work properly.
    await requestPermissions();
  }

  @override
  Future<bool?> isPermissionGranted() async {
    if (Platform.isAndroid) {
      return _isAndroidNotificationsEnabled();
    }
    return false;
  }

  @override
  Future<void> requestPermissions() async {
    if (Platform.isAndroid) {
      await _androidImplementation?.requestNotificationsPermission();
    }
  }

  @override
  Future<void> send(NotificationModel notificationModel) async {
    if (!await _isAndroidNotificationsEnabled()) {
      _logger.warning(
        'send(): notifications are not enabled, skipping notification',
      );
      return;
    }
    await flutterLocalNotificationsPlugin.show(
      notificationModel.id,
      notificationModel.title,
      notificationModel.body,
      notificationModel.details,
      payload: notificationModel.payload,
    );
  }

  @override
  Future<void> schedule(
    NotificationModel notificationModel,
    tz.TZDateTime scheduleAt,
  ) async {
    // Exact alarms are denied by default on Android 14+; fall back to inexact.
    final bool canScheduleExact =
        await _androidImplementation?.canScheduleExactNotifications() ?? false;
    if (!canScheduleExact) {
      _logger.warning(
        'schedule(): exact alarms not permitted, falling back to inexact scheduling',
      );
    }
    await flutterLocalNotificationsPlugin.zonedSchedule(
      notificationModel.id,
      notificationModel.title,
      notificationModel.body,
      scheduleAt,
      notificationModel.details,
      payload: notificationModel.payload,
      androidScheduleMode: canScheduleExact
          ? AndroidScheduleMode.exactAllowWhileIdle
          : AndroidScheduleMode.inexactAllowWhileIdle,
    );
  }

  @override
  Future<void> cancel(int notificationId) {
    return flutterLocalNotificationsPlugin.cancel(notificationId);
  }

  @override
  Future<void> cancelAll() {
    return flutterLocalNotificationsPlugin.cancelAll();
  }

  @override
  Future<void> cancelAllScheduled() async {
    final pending = await flutterLocalNotificationsPlugin
        .pendingNotificationRequests();
    for (var notification in pending) {
      await flutterLocalNotificationsPlugin.cancel(notification.id);
    }
  }
}
