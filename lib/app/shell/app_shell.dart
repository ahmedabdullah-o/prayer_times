import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:prayer_times/app/shell/widgets/navigation_bar.dart' as app;
import 'package:prayer_times/app/shell/widgets/top_bar.dart';
import 'package:prayer_times/core/services/prayer_times/prayer_times_provider.dart';

class AppShell extends ConsumerWidget {
  final Widget child;
  const AppShell({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final prayerTimes = ref.read(prayerTimesProvider);
    final currentPath = GoRouterState.of(context).uri.toString();
    return Stack(
      children: [
        // App Bar
        Positioned(left: 0, right: 0, top: 0, child: TopBar(prayerTimes.nextPrayer)),
        // Page content
        Positioned.fill(
          top: 48 + MediaQuery.of(context).padding.top,
          bottom: 80 + MediaQuery.of(context).padding.bottom,
          child: child,
        ),
        // bottom nav bar
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: app.NavigationBar(currentPath: currentPath),
        ),
      ],
    );
  }
}
