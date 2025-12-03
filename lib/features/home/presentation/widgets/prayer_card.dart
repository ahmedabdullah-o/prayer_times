import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:prayer_times/core/style/colors.dart' as app;

class PrayerCard extends StatelessWidget {
  final String name;
  final DateTime dateTime;
  const PrayerCard(this.name, this.dateTime, {super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 8),
      height: 48,
      decoration: BoxDecoration(
        color: app.Colors.surface,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Text(name),
          Text(DateFormat(DateFormat.HOUR24_MINUTE).format(dateTime)),
        ],
      ),
    );
  }
}
