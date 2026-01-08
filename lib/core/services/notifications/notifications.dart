import 'dart:async';
import 'dart:io';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/standalone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:prayer_times/core/enums/notifications_enums.dart';
import 'package:prayer_times/core/extensions/notifications_extensions.dart';
import 'package:prayer_times/core/services/notifications/inotifications.dart';
import 'package:prayer_times/core/services/notifications/notification_model.dart';

/// Streams are created so that app can respond to notification-related events
/// since the plugin is initialized in the `main` function
final StreamController<NotificationResponse> selectNotificationStream =
    StreamController<NotificationResponse>.broadcast();

@pragma('vm:entry-point')
void notificationTapBackground(NotificationResponse notificationResponse) {}

class Notifications implements Inotifications {
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

  Notifications(this.flutterLocalNotificationsPlugin);

  Future<bool> _isAndroidNotificationsEnabled() async {
    final bool? isEnabled = await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.areNotificationsEnabled();
    return isEnabled ?? false;
  }

  Future<bool> _isDarwinNotificationsEnabled() async {
    final checkEnabled =
        await flutterLocalNotificationsPlugin
            .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin
            >()
            ?.requestPermissions(
              alert: true,
              badge: true,
              critical: true,
              sound: true,
            ) ??
        await flutterLocalNotificationsPlugin
            .resolvePlatformSpecificImplementation<
              MacOSFlutterLocalNotificationsPlugin
            >()
            ?.requestPermissions(
              alert: true,
              badge: true,
              critical: true,
              sound: true,
            );
    final bool isEnabled = checkEnabled ?? false;
    return isEnabled;
  }

  @override
  Future<void> init() async {
    //Init timezone database
    tz_data.initializeTimeZones();
    final initializationSettings = InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      iOS: DarwinInitializationSettings(
        notificationCategories: [
          // General Notifications
          DarwinNotificationCategory('general'),
          // Normal habit notification
          DarwinNotificationCategory(
            'habit',
            actions: [
              DarwinNotificationAction.plain('habit_snooze', 'snooze'),
              DarwinNotificationAction.plain('habit_done', 'done'),
            ],
          ),
        ],
      ),
    );
    //Initialize Plugin
    flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: selectNotificationStream.add,
      onDidReceiveBackgroundNotificationResponse: notificationTapBackground,
    );
    //Create channels
    final androidImplementation = flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();

    for (var value in NotificationDetailsEnum.values) {
      final notificationChannel = value.android.toAndroidNotificationChannel;
      androidImplementation?.createNotificationChannel(notificationChannel);
    }

    //Request permissions is done here because it's considered a thing that you need for the service to work properly.
    await requestPermissions();
  }

  @override
  Future<bool?> isPermissionGranted() async {
    if (Platform.isAndroid) {
      return _isAndroidNotificationsEnabled();
    } else if (Platform.isIOS) {
      return _isDarwinNotificationsEnabled();
    }
    return false;
  }

  @override
  Future<void> requestPermissions() async {
    if (Platform.isIOS || Platform.isMacOS) {
      await flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin
          >()
          ?.requestPermissions(alert: true, badge: true, sound: true);
      await flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
            MacOSFlutterLocalNotificationsPlugin
          >()
          ?.requestPermissions(alert: true, badge: true, sound: true);
    } else if (Platform.isAndroid) {
      flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >()
          ?.requestNotificationsPermission();
    }
  }

  @override
  Future<void> send(NotificationModel notificationModel) async {
    bool? isAndroidNotificationsEnabled =
        await _isAndroidNotificationsEnabled();
    bool? isDarwinNotificationsEnabled = await _isDarwinNotificationsEnabled();
    if ((isAndroidNotificationsEnabled) || (isDarwinNotificationsEnabled)) {
      flutterLocalNotificationsPlugin.show(
        notificationModel.id,
        notificationModel.title,
        notificationModel.body,
        notificationModel.notificationDetails.details,
        payload: notificationModel.payload,
      );
    }
  }

  @override
  Future<void> schedule(
    NotificationModel notificationModel,
    DateTime scheduleAt, {
    DateTimeComponents? matchDateTimeComponents,
  }) async {
    final locationName = "Africa/Cairo";
    final location = tz.getLocation(locationName);
    final tzDateTime = tz.TZDateTime.from(scheduleAt, location);
    await flutterLocalNotificationsPlugin.zonedSchedule(
      notificationModel.id,
      notificationModel.title,
      notificationModel.body,
      tzDateTime,
      notificationModel.notificationDetails.details,
      payload: notificationModel.payload,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: matchDateTimeComponents,
    );
  }

  @override
  void cancel(int notificationId) {
    flutterLocalNotificationsPlugin.cancel(notificationId);
  }

  @override
  void cancelAll() {
    flutterLocalNotificationsPlugin.cancelAll();
  }

  @override
  void cancelAllScheduled() async {
    for (var notification
        in (await flutterLocalNotificationsPlugin
            .pendingNotificationRequests())) {
      cancel(notification.id);
    }
  }
}
