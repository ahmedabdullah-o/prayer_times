import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:prayer_times/core/enums/prayers_enums.dart';
import 'package:prayer_times/core/enums/svg_icon_data_enums.dart';
import 'package:prayer_times/core/extensions/string_extensions.dart';
import 'package:prayer_times/core/services/prayer_times/iprayer_times.dart';
import 'package:prayer_times/core/services/prayer_times/prayer_times_provider.dart';
import 'package:prayer_times/core/style/colors.dart' as app;
import 'package:prayer_times/core/style/fonts.dart';
import 'package:prayer_times/core/style/icons.dart';

class TopBar extends ConsumerWidget {
  final PrayersEnums nextPrayer;
  const TopBar(this.nextPrayer, {super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final prayerTimes = ref.read(prayerTimesProvider);
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
  late PrayersEnums _nextPrayer = widget.prayerTimes.nextPrayer;
  late Duration _timeLeft = widget.prayerTimes.todayPrayerTimes[_nextPrayer]!
      .difference(DateTime.now());
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        _timeLeft = widget.prayerTimes.todayPrayerTimes[_nextPrayer]!
            .difference(DateTime.now());

        if (_timeLeft.isNegative) {
          _nextPrayer = widget.prayerTimes.nextPrayer;
          _timeLeft = widget.prayerTimes.todayPrayerTimes[_nextPrayer]!
              .difference(DateTime.now());
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

class _Location extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
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
          Text('Cairo', style: Fonts.location),
        ],
      ),
    );
  }
}
