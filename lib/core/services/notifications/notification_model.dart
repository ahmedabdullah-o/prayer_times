import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:prayer_times/core/enums/athan_sound_enums.dart';

class NotificationModel {
  int id;
  String title;
  String body;
  NotificationDetails details;
  String? payload;

  NotificationModel(
    this.id,
    this.title,
    this.body, {
    required this.details,
    this.payload,
  });

  factory NotificationModel.general({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) {
    return NotificationModel(
      id,
      title,
      body,
      details: NotificationDetails(
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
      payload: payload,
    );
  }

  factory NotificationModel.prayer({
    required int id,
    required String title,
    required String body,
    required AthanSoundEnums sound,
    String? payload,
  }) {
    return NotificationModel(
      id,
      title,
      body,
      details: prayerNotificationDetails(sound),
      payload: payload,
    );
  }

  /// Builds notification details for a prayer notification with the given
  /// Athan [sound].
  ///
  /// Each sound gets its own Android notification channel because on Android
  /// 8+ the channel sound overrides any per-notification sound.
  /// [AthanSoundEnums.defaultSound] plays no custom Athan audio (system
  /// notification sound only).
  static NotificationDetails prayerNotificationDetails(AthanSoundEnums sound) {
    final bool withAthanSound = sound != AthanSoundEnums.defaultSound;
    return NotificationDetails(
      android: AndroidNotificationDetails(
        'prayer_channel_${sound.name}',
        'Prayer Notifications (${sound.name})',
        channelDescription:
            'Prayer time notifications using the ${sound.name} Athan sound',
        importance: Importance.max,
        priority: Priority.high,
        playSound: withAthanSound,
        enableVibration: true,
        category: AndroidNotificationCategory.alarm,
        visibility: NotificationVisibility.public,
        showWhen: false,
        sound: withAthanSound
            ? RawResourceAndroidNotificationSound(_soundResource(sound))
            : null,
      ),
    );
  }

  /// The Android raw resource name (without extension) for the given Athan
  /// [sound].
  ///
  /// A matching file must exist in `android/app/src/main/res/raw/`:
  /// `athan_<name>.mp3` (e.g. `athan_abdulbasit.mp3`).
  static String _soundResource(AthanSoundEnums sound) {
    return 'athan_${sound.name}';
  }
}
