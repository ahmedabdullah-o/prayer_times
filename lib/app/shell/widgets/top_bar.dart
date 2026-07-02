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
    final nextPrayer = ref.watch(nextPrayerProvider);
    final nextPrayerNotifier = ref.read(nextPrayerProvider.notifier);

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
                nextPrayer.name.camelCaseToTitleCase(),
                style: Fonts.topBarTitle,
              ),
              _Location(),
            ],
          ),
          _NextPrayerTimeLeft(prayerTimes, nextPrayer, nextPrayerNotifier),
        ],
      ),
    );
  }
}

class _NextPrayerTimeLeft extends ConsumerStatefulWidget {
  final IPrayerTimes prayerTimes;
  final PrayersEnums nextPrayer;
  final NextPrayer nextPrayerNotifier;
  const _NextPrayerTimeLeft(
    this.prayerTimes,
    this.nextPrayer,
    this.nextPrayerNotifier,
  );

  @override
  ConsumerState<_NextPrayerTimeLeft> createState() =>
      _NextPrayerTimeLeftState();
}

class _NextPrayerTimeLeftState extends ConsumerState<_NextPrayerTimeLeft> {
  late final NextPrayer _nextPrayerNotifier = widget.nextPrayerNotifier;
  late final PrayersEnums _nextPrayer = widget.nextPrayer;
  late DateTime _nextPrayerTime = widget.prayerTimes.prayerTimes(
    0,
  )[_nextPrayer]!;
  late Duration _timeLeft = widget.prayerTimes
      .prayerTimes(0)[_nextPrayer]!
      .difference(DateTime.now());
  bool prayerPassed = false;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        _timeLeft = _nextPrayerTime.difference(DateTime.now());

        if (prayerPassed) {
          _nextPrayerNotifier.update();
          _nextPrayerTime = widget.prayerTimes.prayerTimes(0)[_nextPrayer]!;
          _timeLeft = _nextPrayerTime.difference(DateTime.now());

          prayerPassed = false;
        }

        if (_timeLeft.isNegative) {
          prayerPassed = true;
        }
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
    _timer?.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      "${_timeLeft.inHours.toString().padLeft(2, '0')}:${(_timeLeft.inMinutes - _timeLeft.inHours * 60).toString().padLeft(2, '0')}:${(_timeLeft.inSeconds - _timeLeft.inMinutes * 60).toString().padLeft(2, '0')}",
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
