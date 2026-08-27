import 'package:prayer_times/core/services/notifications/notification_model.dart';
import 'package:timezone/timezone.dart' as tz;

/// Local Notifications - implemented using `flutter_local_notifications`
///
/// Make sure to run [init] before using this service
abstract class Inotifications {
  /// Make sure to initialize the service on the isolate before using any of it's provided methods.
  ///
  /// Initialization on one isolate doesn't mean it's gonna work on the rest of the isolates.
  Future<void> init();

  /// Checks if the permission is granted on Android
  Future<bool?> isPermissionGranted();

  /// Requests permission from the user. Works on Android.
  ///
  /// Don't await this method unless you need to send a notification ASAP.
  Future<void> requestPermissions();

  /// Sends notifications instantly.
  Future<void> send(NotificationModel notificationModel);

  /// Schedules notifications to be sent at the given [scheduleAt] instant.
  ///
  /// [scheduleAt] must already be converted to the desired timezone
  /// (e.g. the user's stored timezone) using `tz.TZDateTime.from(...)`.
  ///
  /// Uses exact alarm scheduling when the OS allows it, and falls back to
  /// inexact scheduling otherwise (required on Android 14+).
  Future<void> schedule(
    NotificationModel notificationModel,
    tz.TZDateTime scheduleAt,
  );

  /// Cancel by notification ID. The id assigned in [NotificationModel].
  Future<void> cancel(int notificationId);
  Future<void> cancelAll();
  Future<void> cancelAllScheduled();
}
