import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:prayer_times/core/enums/prayers_enums.dart';
import 'package:prayer_times/core/enums/svg_icon_data_enums.dart';
import 'package:prayer_times/core/extensions/string_extensions.dart';
import 'package:prayer_times/core/services/notifications/inotifications.dart';
import 'package:prayer_times/core/services/notifications/notifications_provider.dart';
import 'package:prayer_times/core/services/prayer_times/iprayer_times.dart';
import 'package:prayer_times/core/services/prayer_times/prayer_times_provider.dart';
import 'package:prayer_times/core/services/storage/hive/hive_storage_provider.dart';
import 'package:prayer_times/core/services/storage/hive/ihive_storage.dart';
import 'package:prayer_times/core/style/colors.dart' as app;
import 'package:prayer_times/core/style/fonts.dart';
import 'package:prayer_times/core/style/icons.dart';

class PrayerCard extends StatelessWidget {
  final PrayersEnums prayer;
  final DateTime dateTime;
  final bool upcoming;
  final bool mute;
  const PrayerCard(
    this.prayer,
    this.dateTime,
    this.upcoming,
    this.mute, {
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      spacing: 14,
      mainAxisSize: MainAxisSize.max,
      children: [
        Expanded(
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 24),
            height: 48,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                width: 3,
                color: upcoming ? app.Colors.primary : Colors.transparent,
              ),
              boxShadow: upcoming
                  ? [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 6,
                        blurStyle: BlurStyle.outer,
                        offset: Offset(0, 0),
                        spreadRadius: 0,
                      ),
                    ]
                  : [],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              mainAxisSize: MainAxisSize.max,
              children: [
                Text(
                  prayer.name.camelCaseToTitleCase(),
                  style: Fonts.prayerCardText(upcoming),
                ),
                Text(
                  DateFormat(DateFormat.HOUR24_MINUTE).format(dateTime),
                  style: Fonts.prayerCardText(upcoming),
                ),
              ],
            ),
          ),
        ),
        _SoundIcon(prayer, mute),
      ],
    );
  }
}

class _SoundIcon extends ConsumerStatefulWidget {
  final PrayersEnums prayer;
  final bool mute;
  const _SoundIcon(this.prayer, this.mute);

  @override
  ConsumerState<_SoundIcon> createState() => _SoundIconState();
}

class _SoundIconState extends ConsumerState<_SoundIcon> {
  late PrayersEnums _prayer;
  late bool _mute;

  Future<void> _onTap(
    IHiveStorage storage,
    Inotifications notifications,
    IPrayerTimes prayerTimes,
  ) async {
    final oldValue = await storage.getNotificationMute(_prayer);
    await storage.setNotificationMute(_prayer, oldValue ^ true);
    final newValue = await storage.getNotificationMute(_prayer);
    await prayerTimes.scheduleTodayPrayerNotifications(notifications, storage);
    setState(() {
      _mute = newValue;
    });
  }

  @override
  void initState() {
    super.initState();
    _mute = widget.mute;
    _prayer = widget.prayer;
  }

  @override
  Widget build(BuildContext context) {
    final storage = ref.watch(hiveStorageProvider);
    final prayerTimes = ref.read(prayerTimesProvider);
    final notifications = ref.read(notificationsProvider);
    return storage.when(
      loading: () => CircularProgressIndicator(),
      error: (e, s) => throw Exception(e.toString()),
      data: (storage) => GestureDetector(
        onTap: () async => await _onTap(storage, notifications, prayerTimes),
        child: SizedBox.square(
          dimension: 36,
          child: SvgIcon(
            _mute ? SvgIconData.soundOff : SvgIconData.soundOn,
            width: 36,
            height: 36,
            color: _mute ? app.Colors.textSecondary : app.Colors.text,
          ),
        ),
      ),
    );
  }
}
