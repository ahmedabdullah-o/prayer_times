import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hijri/hijri_calendar.dart';
import 'package:intl/intl.dart';
import 'package:prayer_times/core/enums/svg_icon_data_enums.dart';
import 'package:prayer_times/core/style/colors.dart' as app;
import 'package:prayer_times/core/style/fonts.dart';
import 'package:prayer_times/core/style/icons.dart';
import 'package:prayer_times/features/home/domain/notifiers/calendar_offset_notifier.dart';

class Calendar extends ConsumerStatefulWidget {
  const Calendar({super.key});

  @override
  ConsumerState<Calendar> createState() => _CalendarState();
}

class _CalendarState extends ConsumerState<Calendar> {
  @override
  Widget build(BuildContext context) {
    final offset = ref.watch(calendarOffsetProvider);
    final now = DateTime.now().add(Duration(days: offset));
    final hijriDate = HijriCalendar.fromDate(now);
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        spacing: 4,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          GestureDetector(
            onTap: () => ref.read(calendarOffsetProvider.notifier).decrement(),
            child: SizedBox(
              width: 24,
              height: 24,
              child: SvgIcon(
                SvgIconData.arrowLeft,
                width: 24,
                height: 24,
                color: app.Colors.primary,
              ),
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
            onTap: () => ref.read(calendarOffsetProvider.notifier).increment(),
            child: SizedBox(
              width: 24,
              height: 24,
              child: SvgIcon(
                SvgIconData.arrowRight,
                width: 24,
                height: 24,
                color: app.Colors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
