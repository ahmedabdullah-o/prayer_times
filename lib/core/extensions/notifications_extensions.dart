import 'package:flutter_local_notifications/flutter_local_notifications.dart';

extension AndroidNotificationDetailsExtensions on AndroidNotificationDetails {
  AndroidNotificationChannel get toAndroidNotificationChannel {
    return AndroidNotificationChannel(
      channelId,
      channelName,
      description: channelDescription,
      importance: importance,
      playSound: playSound,
      sound: sound,
      enableVibration: enableVibration,
      vibrationPattern: vibrationPattern,
      enableLights: enableLights,
      ledColor: ledColor,
      showBadge: channelShowBadge,
      groupId: groupKey,
    );
  }
}
