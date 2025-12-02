import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AppShell extends ConsumerWidget {
  final Widget child;
  const AppShell({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Stack(
      children: [
        // App Bar
        // Positioned(left: 0, right: 0, top: 0, child: app.TopBar(currentPath)),
        // Page content
        Positioned.fill(
          top: 48 + MediaQuery.of(context).padding.top,
          bottom: 80 + MediaQuery.of(context).padding.bottom,
          child: child,
        ),
        // bottom nav bar
        // Positioned(
        //   left: 0,
        //   right: 0,
        //   bottom: 0,
        //   child: app.NavigationBar(currentPath: currentPath),
        // ),
      ],
    );
  }
}
