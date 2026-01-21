import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:prayer_times/core/enums/svg_icon_data_enums.dart';
import 'package:prayer_times/core/services/storage/hive/hive_storage_provider.dart';
import 'package:prayer_times/core/services/storage/hive/ihive_storage.dart';
import 'package:prayer_times/core/style/colors.dart' as app;
import 'package:prayer_times/core/style/fonts.dart';
import 'package:prayer_times/core/style/icons.dart';

class AutoSettings extends StatefulWidget {
  const AutoSettings({super.key});

  @override
  State<AutoSettings> createState() => _AutoSettingsState();
}

class _AutoSettingsState extends State<AutoSettings> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      width: 400,
      height: 124,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: app.Colors.primary50,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Auto Settings", style: Fonts.prayerCardText(true)),
              SizedBox(
                width: 220,
                child: Text(
                  "Allow the app to automatically choose settings based on your current location.",
                  style: Fonts.navigationBarItem(false),
                  softWrap: true,
                ),
              ),
            ],
          ),
          _CheckBox(),
        ],
      ),
    );
  }
}

class _CheckBox extends ConsumerStatefulWidget {
  const _CheckBox();

  @override
  ConsumerState<_CheckBox> createState() => _CheckBoxState();
}

class _CheckBoxState extends ConsumerState<_CheckBox> {
  bool? checked;
  void onTap(IHiveStorage storage) {
    setState(() => checked = !(checked ?? false));
    storage.setAutoSettings(checked!);
  }

  @override
  Widget build(BuildContext context) {
    final storage = ref.read(hiveStorageProvider);
    return storage.when(
      loading: () => CircularProgressIndicator(),
      error: (e, s) => throw Exception(e.toString()),
      data: (storage) => GestureDetector(
        onTap: () => onTap(storage),
        child: FutureBuilder(
          future: storage.getAutoSettings(),
          builder: (context, snapshot) {
            final activated = snapshot.data;
            if (snapshot.connectionState == ConnectionState.done) {
              checked ??= activated!;
              return Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(6),
                  border: checked! ? null : Border.all(),
                  color: checked! ? app.Colors.text : Colors.transparent,
                ),
                child: checked!
                    ? SvgIcon(
                        SvgIconData.checkMark,
                        width: 24,
                        height: 24,
                        color: app.Colors.background,
                      )
                    : null,
              );
            } else {
              return SizedBox(width: 24, height: 24);
            }
          },
        ),
      ),
    );
  }
}
