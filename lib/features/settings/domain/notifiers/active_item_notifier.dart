import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:prayer_times/core/enums/settings_enums.dart';

final activeItemProvider = NotifierProvider<ActiveItem, SettingsEnums?>(
  ActiveItem.new,
);

class ActiveItem extends Notifier<SettingsEnums?> {
  @override
  SettingsEnums? build() => null;

  void toggle(SettingsEnums settings) {
    if (state == settings) {
      state = null;
      return;
    }
    state = settings;
  }
}
