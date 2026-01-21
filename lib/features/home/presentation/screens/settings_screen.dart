import 'package:flutter/widgets.dart';
import 'package:prayer_times/core/enums/settings_enums.dart';
import 'package:prayer_times/features/home/presentation/widgets/auto_settings.dart';
import 'package:prayer_times/features/home/presentation/widgets/settings_item.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final children = [
      AutoSettings(),
      SizedBox(height: 4),
      // SettingsItem(SettingsEnums.notifications),
      SettingsItem(SettingsEnums.madhab),
      SettingsItem(SettingsEnums.calculationMethod),
      // SettingsItem(SettingsEnums.language),
      // SettingsItem(SettingsEnums.theme),
      // SettingsItem(SettingsEnums.other),
      SizedBox(height: 4),
      SettingsItem(SettingsEnums.privacyPolicy),
      SettingsItem(SettingsEnums.privacySettings),
      // SettingsItem(SettingsEnums.faqs),
      // SettingsItem(SettingsEnums.support),
    ];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      child: Column(spacing: 10, children: [...children]),
    );
  }
}
