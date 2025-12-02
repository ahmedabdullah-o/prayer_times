import 'package:prayer_times/core/enums/notifications_enums.dart';

class NotificationModel {
  int id;
  String title;
  String body;
  NotificationDetailsEnum notificationDetails;
  String? payload;

  NotificationModel(
    this.id,
    this.title,
    this.body, {
    this.notificationDetails = NotificationDetailsEnum.general,
    this.payload,
  });
}
