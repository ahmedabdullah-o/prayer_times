import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:prayer_times/core/services/notifications/notification_model.dart';

/// Local Notifications - implemented using `flutter_local_notifications`
///
/// Make sure to run [init] before using this service
abstract class Inotifications {
  /// Make sure to initialize the service on the isolate before using any of it's provided methods.
  ///
  /// Initialization on one isolate doesn't mean it's gonna work on the rest of the isolates.
  Future<void> init();

  /// Checks if the permission is granted on the current platform whether it's Android or iOS
  Future<bool?> isPermissionGranted();

  /// Requests permission from the user. Works on Android and iOS.
  ///
  /// Don't await this method unless you need to send a notification ASAP.
  Future<void> requestPermissions();

  /// Sends notifications instantly.
  Future<void> send(NotificationModel notificationModel);

  /// Schedules notifications to be sent on the given [scheduleAt] value
  ///
  /// [matchDateTimeComponents] is crucial if you want the same notification
  /// to be sent at the same [scheduleAt] value whether it's:
  /// * Exactly at a certain date & time (`DateTimeComponents.dateAndTime`)
  /// * Every day at the same time (`DateTimeComponents.time`)
  /// * Day of every month and time (`DateTimeComponents.dayOfMonthAndTime`)
  /// * Day of every week and time (`DateTimeComponents.dayOfWeekAndTime`)
  ///
  /// This is especially beneficial when time doesn't change like you would do
  /// in a reminders app.
  Future<void> schedule(
    NotificationModel notificationModel,
    DateTime scheduleAt, {
    DateTimeComponents? matchDateTimeComponents,
  });

  /// Cancel by notification ID. The id assigned in [NotificationModel].
  void cancel(int notificationId);
  void cancelAll();
  void cancelAllScheduled();
}
