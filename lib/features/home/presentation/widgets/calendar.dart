import 'package:flutter/widgets.dart';
import 'package:hijri/hijri_calendar.dart';
import 'package:intl/intl.dart';
import 'package:prayer_times/core/enums/svg_icon_data_enums.dart';
import 'package:prayer_times/core/style/colors.dart' as app;
import 'package:prayer_times/core/style/fonts.dart';
import 'package:prayer_times/core/style/icons.dart';

class Calendar extends StatefulWidget {
  /// how many days to offset from today
  ///
  /// Example:
  ///
  /// * -3 means 3 days before today
  /// * 0 means today
  /// * 3 means 3 days after today
  final int offset;
  const Calendar({this.offset = 0, super.key});

  @override
  State<Calendar> createState() => _CalendarState();
}

class _CalendarState extends State<Calendar> {
  @override
  Widget build(BuildContext context) {
    int offset = widget.offset;
    final now = DateTime.now().add(Duration(days: widget.offset));
    final hijriDate = HijriCalendar.fromDate(now);
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        spacing: 4,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          GestureDetector(
            onTap: () => setState(() => offset--),
            child: SvgIcon(
              SvgIconData.arrowLeft,
              width: 24,
              height: 24,
              color: app.Colors.primary,
            ),
          ),
          Expanded(
            child: Container(
              height: 40,
              decoration: BoxDecoration(
                color: app.Colors.foreground,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [
                  Text(
                    hijriDate.toFormat("MMMM dd yyyy"),
                    style: Fonts.calendarHijri,
                  ),
                  Text(
                    DateFormat(DateFormat.MONTH_WEEKDAY_DAY).format(now),
                    style: Fonts.calendarGreg,
                  ),
                ],
              ),
            ),
          ),
          GestureDetector(
            onTap: () => setState(() => offset++),
            child: SvgIcon(
              SvgIconData.arrowRight,
              width: 24,
              height: 24,
              color: app.Colors.primary,
            ),
          ),
        ],
      ),
    );
  }
}
