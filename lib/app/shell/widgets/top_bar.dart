import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logging/logging.dart';
import 'package:prayer_times/core/enums/prayers_enums.dart';
import 'package:prayer_times/core/enums/svg_icon_data_enums.dart';
import 'package:prayer_times/core/extensions/string_extensions.dart';
import 'package:prayer_times/core/services/location/location_provider.dart';
import 'package:prayer_times/core/services/prayer_times/iprayer_times.dart';
import 'package:prayer_times/core/services/prayer_times/prayer_times_provider.dart';
import 'package:prayer_times/core/services/storage/hive/hive_storage_provider.dart';
import 'package:prayer_times/features/home/domain/notifiers/next_prayer_notifier.dart';
import 'package:prayer_times/core/style/colors.dart' as app;
import 'package:prayer_times/core/style/fonts.dart';
import 'package:prayer_times/core/style/icons.dart';

final _logger = Logger('widgets - appshell - topbar');

class TopBar extends ConsumerWidget {
  const TopBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final prayerTimes = ref.read(prayerTimesProvider);
    final nextPrayer = ref.watch(nextPrayerProvider).value;

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                nextPrayer != null
                    ? nextPrayer.name.camelCaseToTitleCase()
                    : '...',
                style: Fonts.topBarTitle,
              ),
              _Location(),
            ],
          ),
          _NextPrayerTimeLeft(prayerTimes),
        ],
      ),
    );
  }
}

class _NextPrayerTimeLeft extends ConsumerStatefulWidget {
  final IPrayerTimes prayerTimes;
  const _NextPrayerTimeLeft(this.prayerTimes);

  @override
  ConsumerState<_NextPrayerTimeLeft> createState() =>
      _NextPrayerTimeLeftState();
}

class _NextPrayerTimeLeftState extends ConsumerState<_NextPrayerTimeLeft> {
  PrayersEnums? _loadedFor;
  DateTime? _nextPrayerTime;
  Duration _timeLeft = Duration.zero;
  bool _passed = false;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(Duration(seconds: 1), (timer) => _tick());
  }

  void _tick() {
    final nextPrayerTime = _nextPrayerTime;
    if (nextPrayerTime == null) return;
    final timeLeft = nextPrayerTime.difference(DateTime.now());
    if (timeLeft.isNegative && !_passed) {
      _passed = true;
      // Advance to the next prayer once its time has passed.
      ref.read(nextPrayerProvider.notifier).advance();
    }
    setState(() => _timeLeft = timeLeft);
  }

  Future<void> _load(PrayersEnums next) async {
    final storage = await ref.read(hiveStorageProvider.future);
    final times = await widget.prayerTimes.prayerTimes(storage, 0);
    if (!mounted) return;
    setState(() {
      _nextPrayerTime = times[next];
      _timeLeft = _nextPrayerTime?.difference(DateTime.now()) ?? Duration.zero;
      _passed = false;
    });
  }

  String _format(Duration d) {
    if (d.isNegative) d = Duration.zero;
    return "${d.inHours.toString().padLeft(2, '0')}:${(d.inMinutes - d.inHours * 60).toString().padLeft(2, '0')}:${(d.inSeconds - d.inMinutes * 60).toString().padLeft(2, '0')}";
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final nextPrayerAsync = ref.watch(nextPrayerProvider);
    nextPrayerAsync.whenData((next) {
      if (_loadedFor != next) {
        _loadedFor = next;
        _load(next);
      }
    });
    return Text(
      _nextPrayerTime == null ? '--:--:--' : _format(_timeLeft),
      style: Fonts.topBarTimeLeft,
    );
  }
}

class _Location extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    _logger.info('_Location: build...');
    final location = ref.watch(locationProvider);
    return GestureDetector(
      onTap: () {}, // TODO: Open location settings screen
      child: Row(
        spacing: 8,
        children: [
          SvgIcon(
            SvgIconData.location,
            width: 18,
            height: 18,
            color: app.Colors.text,
          ),
          FutureBuilder(
            future: location.placeName,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                if (snapshot.data!.name == null) {
                  _logger.warning(
                    '_Location: using fallback value for location',
                  );
                  return Text('Cairo', style: Fonts.location);
                } else {
                  _logger.info('_Location: using data for location');
                  return Text(
                    snapshot.data!.subAdministrativeArea ?? 'Cairo',
                    style: Fonts.location,
                  );
                }
              }
              return Text('Loading...', style: Fonts.location);
            },
          ),
        ],
      ),
    );
  }
}
