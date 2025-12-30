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
  final bool mute;
  const PrayerCard(
    this.name,
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
                Text(name, style: Fonts.prayerCardText(upcoming)),
                Text(
                  DateFormat(DateFormat.HOUR24_MINUTE).format(dateTime),
                  style: Fonts.prayerCardText(upcoming),
                ),
              ],
            ),
          ),
        ),
        _SoundIcon(mute),
      ],
    );
  }
}

class _SoundIcon extends StatefulWidget {
  final bool mute;
  const _SoundIcon(this.mute);

  @override
  State<_SoundIcon> createState() => _SoundIconState();
}

class _SoundIconState extends State<_SoundIcon> {
  late bool _mute;

  void _onTap() {
    setState(() {
      _mute ^= true;
    });
  }

  @override
  void initState() {
    super.initState();
    _mute = widget.mute;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _onTap,
      child: SizedBox.square(
        dimension: 36,
        child: SvgIcon(
          _mute ? SvgIconData.soundOff : SvgIconData.soundOn,
          width: 36,
          height: 36,
          color: _mute ? app.Colors.textSecondary : app.Colors.text,
        ),
      ),
    );
  }
}
