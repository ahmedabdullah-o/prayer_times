import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:prayer_times/core/services/notifications/notification_model.dart';

abstract class Inotifications {
  void init();
  void isPermissionGranted();
  void requestPermissions();
  Future<void> send(NotificationModel notificationModel);
  Future<void> schedule(
    NotificationModel notificationModel,
    DateTime scheduleAt, {
    DateTimeComponents? matchDateTimeComponents,
  });
  void cancel(int notificationId);
  void cancelAll();
  void cancelAllScheduled();
}
