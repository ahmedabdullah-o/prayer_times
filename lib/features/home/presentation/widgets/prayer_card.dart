import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:prayer_times/core/enums/svg_icon_data_enums.dart';
import 'package:prayer_times/core/style/colors.dart' as app;
import 'package:prayer_times/core/style/fonts.dart';
import 'package:prayer_times/core/style/icons.dart';

class PrayerCard extends StatelessWidget {
  final String name;
  final DateTime dateTime;
  final bool upcoming;
  final bool soundOn;
  const PrayerCard(
    this.name,
    this.dateTime,
    this.upcoming,
    this.soundOn, {
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
                Text(name, style: Fonts.prayerCardText(upcoming)),
                Text(
                  DateFormat(DateFormat.HOUR24_MINUTE).format(dateTime),
                  style: Fonts.prayerCardText(upcoming),
                ),
              ],
            ),
          ),
        ),
        _SoundIcon(soundOn),
      ],
    );
  }
}

class _SoundIcon extends StatefulWidget {
  final bool soundOn;
  const _SoundIcon(this.soundOn);

  @override
  State<_SoundIcon> createState() => __SoundIconState();
}

class __SoundIconState extends State<_SoundIcon> {
  late bool _soundOn;

  void _onTap() {
    setState(() {
      _soundOn ^= true;
    });
  }

  @override
  void initState() {
    super.initState();
    _soundOn = widget.soundOn;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _onTap,
      child: SizedBox.square(
        dimension: 36,
        child: SvgIcon(
          _soundOn ? SvgIconData.soundOn : SvgIconData.soundOff,
          width: 36,
          height: 36,
          color: _soundOn ? app.Colors.text : app.Colors.textSecondary,
        ),
      ),
    );
  }
}
