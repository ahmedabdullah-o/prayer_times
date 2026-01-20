import 'package:flutter/widgets.dart';
import 'package:prayer_times/core/enums/settings_enums.dart';
import 'package:prayer_times/features/home/presentation/widgets/settings_item.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final children = [
      AutoSettings(),
      SizedBox(height: 4),
      SettingsItem(settings: SettingsEnums.notifications),
      SettingsItem(settings: SettingsEnums.madhab),
      SettingsItem(settings: SettingsEnums.calculationMethod),
      // SettingsItem(settings: SettingsEnums.language),
      // SettingsItem(settings: SettingsEnums.theme),
      // SettingsItem(settings: SettingsEnums.other),
      // SettingsItem(settings: SettingsEnums.privacyPolicy),
      // SettingsItem(settings: SettingsEnums.privacySettings),
      // SettingsItem(settings: SettingsEnums.faqs),
      // SettingsItem(settings: SettingsEnums.support),
    ];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      child: Column(spacing: 10, children: [...children]),
    );
  }
}
