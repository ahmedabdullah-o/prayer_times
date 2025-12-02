import 'package:flutter_local_notifications/flutter_local_notifications.dart';

enum NotificationDetailsEnum {
  general(
    NotificationDetails(
      android: AndroidNotificationDetails(
        'general_channel',
        'General Notifications',
        channelDescription: 'General Notifications',
        importance: Importance.max,
        priority: Priority.high,
        playSound: true,
        enableVibration: true,
      ),
      iOS: DarwinNotificationDetails(
        categoryIdentifier: 'general',
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      ),
    ),
  ),
  prayer(
    NotificationDetails(
      android: AndroidNotificationDetails(
        'general_channel',
        'General Notifications',
        channelDescription: 'General Notifications',
        importance: Importance.max,
        priority: Priority.high,
        playSound: true,
        enableVibration: true,
        category: AndroidNotificationCategory.alarm,
        visibility: NotificationVisibility.public,
        showWhen: false,
        sound: RawResourceAndroidNotificationSound('notification_sound'),
      ),
      iOS: DarwinNotificationDetails(
        categoryIdentifier: 'general',
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      ),
    ),
  );

  const NotificationDetailsEnum(this.details);

  final NotificationDetails details;

  // Helper methods
  AndroidNotificationDetails get android => details.android!;
  DarwinNotificationDetails get iOS => details.iOS!;

  // Get by name
  static NotificationDetailsEnum? fromName(String name) {
    try {
      return NotificationDetailsEnum.values.byName(name);
    } catch (e) {
      return null;
    }
  }
}
