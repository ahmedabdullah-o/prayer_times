import 'package:flutter_riverpod/flutter_riverpod.dart';

final calendarOffsetProvider = NotifierProvider<CalendarOffset, int>(
  CalendarOffset.new,
);

class CalendarOffset extends Notifier<int> {
  @override
  int build() => 0;

  void increment() => state++;

  void decrement() => state--;
}
