import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:prayer_times/core/services/notifications/inotifications.dart';
import 'package:prayer_times/core/services/notifications/notifications.dart';

final notificationsProvider = Provider<Inotifications>((ref) {
  final flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  return Notifications(flutterLocalNotificationsPlugin);
});
