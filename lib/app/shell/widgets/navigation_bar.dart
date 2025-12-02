import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class NavigationBar extends StatelessWidget {
  final String currentPath;
  const NavigationBar({super.key, required this.currentPath});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(color: Colors.grey[200]),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _NavItem(
            label: 'today',
            iconData: Icons.checklist,
            showLabel: true,
            active: currentPath == '/home',
            onTap: () => context.go('/home'),
          ),
          _AddButton(),
          _NavItem(
            label: 'habits',
            iconData: Icons.loop,
            showLabel: true,
            active: currentPath == '/habits',
            onTap: () => context.go('/habits'),
          ),
        ],
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final String label;
  final IconData iconData;
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
                    color: Colors.blue[50],
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
                child: Icon(iconData, size: 30, color: Colors.black),
              ),
              Text(
                label,
                style: TextStyle(color: active ? Colors.blue : Colors.black),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _AddButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {},
      child: Stack(
        children: [
          Container(
            width: 80,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.blue[50],
              border: Border.all(
                width: 2,
                color: Colors.blue[50]!,
                strokeAlign: BorderSide.strokeAlignInside,
              ),
              borderRadius: BorderRadius.circular(24),
            ),
          ),
          SizedBox(
            width: 80,
            height: 48,
            child: Center(
              child: Icon(Icons.add, size: 28, color: Colors.black),
            ),
          ),
        ],
      ),
    );
  }
}
