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
    ),
  );

  const NotificationDetailsEnum(this.details);

  final NotificationDetails details;

  // Helper methods
  AndroidNotificationDetails get android => details.android!;

  // Get by name
  static NotificationDetailsEnum? fromName(String name) {
    try {
      return NotificationDetailsEnum.values.byName(name);
    } catch (e) {
      return null;
    }
  }
}
