import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:prayer_times/core/enums/svg_icon_data_enums.dart';
import 'package:prayer_times/core/style/colors.dart' as app;
import 'package:prayer_times/core/style/fonts.dart';
import 'package:prayer_times/core/style/icons.dart';

class NavigationBar extends StatelessWidget {
  final String currentPath;
  const NavigationBar({super.key, required this.currentPath});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(color: app.Colors.foreground),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _NavItem(
            label: 'Prayers',
            iconData: SvgIconData.mosque,
            showLabel: true,
            active: currentPath == '/home',
            onTap: () => context.go('/home'),
          ),
          _NavItem(
            label: 'Qibla',
            iconData: SvgIconData.compass,
            showLabel: true,
            active: false,
            onTap: () => context.go('/home'),
          ),
          _NavItem(
            label: 'Settings',
            iconData: SvgIconData.settings,
            showLabel: true,
            active: currentPath == '/settings',
            onTap: () => context.go('/settings'),
          ),
        ],
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final String label;
  final SvgIconData iconData;
  final bool showLabel;
  final bool active;
  final VoidCallback onTap;

  const _NavItem({
    required this.label,
    required this.iconData,
    required this.showLabel,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        children: [
          active
              ? Container(
                  width: 60,
                  height: 32,
                  decoration: BoxDecoration(
                    color: app.Colors.primary50,
                    borderRadius: BorderRadius.circular(16),
                  ),
                )
              : SizedBox(width: 60, height: 32),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 60,
                height: 32,
                child: SvgIcon(
                  iconData,
                  width: 30,
                  height: 30,
                  color: Colors.black,
                ),
              ),
              Text(label, style: Fonts.navigationBarItem(active)),
            ],
          ),
        ],
      ),
    );
  }
}
