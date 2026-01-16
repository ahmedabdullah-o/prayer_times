import 'package:adhan_dart/adhan_dart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:prayer_times/core/enums/prayers_enums.dart';
import 'package:prayer_times/core/enums/settings_enums.dart';
import 'package:prayer_times/core/enums/svg_icon_data_enums.dart';
import 'package:prayer_times/core/extensions/string_extensions.dart';
import 'package:prayer_times/core/services/storage/hive/hive_storage_provider.dart';
import 'package:prayer_times/core/services/storage/hive/ihive_storage.dart';
import 'package:prayer_times/core/style/colors.dart' as app;
import 'package:prayer_times/core/style/fonts.dart';
import 'package:prayer_times/core/style/icons.dart';
import 'package:url_launcher/url_launcher.dart';

bool? _mainOnTap(SettingsEnums settings) {
  switch (settings) {
    case SettingsEnums.other:
      // TODO navigate to other settings page
      return true;
    case SettingsEnums.privacySettings:
      // TODO navigate to privacy settings page
      return true;
    case SettingsEnums.faqs:
      // TODO launch FAQs page on browser
      return true;
    case SettingsEnums.support:
      // TODO launch support page on browser
      _openLink("github.com/ahmedabdullah-o");
      return true;
    case SettingsEnums.notifications:
    case SettingsEnums.madhab:
    case SettingsEnums.calculationMethod:
    case SettingsEnums.language:
    case SettingsEnums.theme:
    case SettingsEnums.privacyPolicy:
      return null;
  }
}

SvgIconData _icon(SettingsEnums settings) {
  // I'm using a switch here because it forces you to include every case (if you don't include `default`).
  // That way I don't have to worry about forgetting to add an enum here.

  // Whenever a new enum is added in SettingsEnums the compiler is gonna tell you
  // that this switch doesn't cover all cases.
  switch (settings) {
    case SettingsEnums.notifications:
      return SvgIconData.notification;
    case SettingsEnums.madhab:
      return SvgIconData.book;
    case SettingsEnums.calculationMethod:
      return SvgIconData.horizon;
    case SettingsEnums.language:
      return SvgIconData.globe;
    case SettingsEnums.theme:
      return SvgIconData.crescent;
    case SettingsEnums.other:
      return SvgIconData.settings;
    case SettingsEnums.privacyPolicy:
      return SvgIconData.shield;
    case SettingsEnums.privacySettings:
      return SvgIconData.shield;
    case SettingsEnums.faqs:
      return SvgIconData.faq;
    case SettingsEnums.support:
      return SvgIconData.donation;
  }
}

Future<String> _selectedOption(
  SettingsEnums settings,
  IHiveStorage storage,
) async {
  switch (settings) {
    case SettingsEnums.madhab:
      // TODO implement madhab storage
      return "";
    case SettingsEnums.calculationMethod:
      return (await storage.savedCalculationMethod).name.camelCaseToTitleCase();
    case SettingsEnums.language:
      return (await storage.locale).languageCode.camelCaseToTitleCase();
    case SettingsEnums.theme:
      // TODO implement theme storage
      return "";
    case SettingsEnums.notifications:
    case SettingsEnums.other:
    case SettingsEnums.privacyPolicy:
    case SettingsEnums.privacySettings:
    case SettingsEnums.faqs:
    case SettingsEnums.support:
      return "";
  }
}

List<dynamic> _options(SettingsEnums settings) {
  switch (settings) {
    case SettingsEnums.notifications:
      return PrayersEnums.values;
    case SettingsEnums.madhab:
      return Madhab.values;
    case SettingsEnums.calculationMethod:
      return CalculationMethod.values;
    case SettingsEnums.language:
      // TODO implement mutliple languages with enumerization
      return [];
    case SettingsEnums.theme:
      // TODO implement dark theme, add 3 options (light, dark, system)
      return [];
    case SettingsEnums.other:
    case SettingsEnums.privacyPolicy:
    case SettingsEnums.privacySettings:
    case SettingsEnums.faqs:
    case SettingsEnums.support:
      return [];
  }
}

Future<void> _optionOnTap(
  dynamic option,
  SettingsEnums settings,
  IHiveStorage storage,
) async {
  switch (settings) {
    case SettingsEnums.madhab:
    // TODO madhab storage implementation
    case SettingsEnums.calculationMethod:
      await storage.setSavedCalculationMethod(option);
      break;
    case SettingsEnums.language:
    // TODO implement after implementing multiple language support
    case SettingsEnums.theme:
    // TODO implement after implementing dark theme support
    case SettingsEnums.notifications:
    case SettingsEnums.other:
    case SettingsEnums.privacyPolicy:
    case SettingsEnums.privacySettings:
    case SettingsEnums.faqs:
    case SettingsEnums.support:
      break;
  }
}

Future<void> _openLink(String url) async {
  final uri = Uri.parse(url);

  if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
    throw 'Could not launch $url';
  }
}

class SettingsItem extends StatefulWidget {
  final SettingsEnums settings;
  const SettingsItem({super.key, required this.settings});

  @override
  State<SettingsItem> createState() => _SettingsItemState();
}

class _SettingsItemState extends State<SettingsItem>
    with SingleTickerProviderStateMixin {
  bool expanded = false;
  late final SettingsEnums settings;

  void toggleExpand() => setState(() => expanded ^= true);
  @override
  void initState() {
    super.initState();
    settings = widget.settings;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GestureDetector(
          onTap: () => _mainOnTap(settings) ?? () => toggleExpand(),
          child: _Main(settings),
        ),
        expanded ? _OptionsList(settings) : SizedBox(),
      ],
    );
  }
}

class _Main extends ConsumerWidget {
  final SettingsEnums settings;
  const _Main(this.settings);
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final storage = ref.read(hiveStorageProvider);
    return storage.when(
      loading: () => CircularProgressIndicator(),
      error: (e, s) => throw Exception(e.toString()),
      data: (storage) => Container(
        width: double.infinity,
        height: 56,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28),
          color: app.Colors.foreground,
          boxShadow: [
            BoxShadow(
              color: app.Colors.textSecondary,
              offset: Offset(0, -2),
              blurRadius: 12,
            ),
          ],
        ),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            spacing: 10,
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              SvgIcon(
                _icon(settings),
                width: 30,
                height: 30,
                color: app.Colors.text,
              ),
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Text(
                      settings.name.camelCaseToTitleCase(),
                      style: Fonts.navigationBarItem(true),
                    ),
                    SizedBox(
                      width: 100,
                      child: FutureBuilder(
                        future: _selectedOption(settings, storage),
                        builder: (context, asyncSnapshot) {
                          if (asyncSnapshot.connectionState ==
                              ConnectionState.done) {
                            return Text(
                              asyncSnapshot.data ?? "",
                              style: Fonts.navigationBarItem(false),
                              textAlign: TextAlign.center,
                            );
                          } else {
                            return SizedBox(width: 100);
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OptionsList extends StatelessWidget {
  final SettingsEnums settings;
  const _OptionsList(this.settings);

  void onTap(String optionOnTap) {}

  @override
  Widget build(BuildContext context) {
    final optionsWidgets = _options(settings).map((item) {
      return _Option(item, settings);
    }).toList();
    return Container(
      width: double.infinity,
      height: 148,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        color: app.Colors.foreground,
        boxShadow: [
          BoxShadow(
            color: app.Colors.textSecondary,
            offset: Offset(0, -2),
            blurRadius: 12,
          ),
        ],
      ),
      child: ListView(children: optionsWidgets),
    );
  }
}

class _Option extends ConsumerWidget {
  final Enum option;
  final SettingsEnums settings;
  const _Option(this.option, this.settings);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final storageProvider = ref.read(hiveStorageProvider);
    return storageProvider.when(
      loading: () => CircularProgressIndicator(),
      error: (e, s) => throw Exception(e.toString()),
      data: (storage) {
        return GestureDetector(
          onTap: () => _optionOnTap(option, settings, storage),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Text(option.name.camelCaseToTitleCase()),
          ),
        );
      },
    );
  }
}
