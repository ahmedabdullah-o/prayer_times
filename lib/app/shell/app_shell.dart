import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:prayer_times/app/shell/widgets/navigation_bar.dart' as app;
import 'package:prayer_times/app/shell/widgets/top_bar.dart';
import 'package:prayer_times/core/style/background_pattern.dart';
import 'package:prayer_times/core/style/colors.dart' as app;
import 'package:prayer_times/core/style/painter.dart';

class AppShell extends ConsumerWidget {
  final Widget child;
  const AppShell({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final contextWidth = MediaQuery.widthOf(context);
    final size = contextWidth / 9;
    final currentPath = GoRouterState.of(context).uri.toString();
    return Stack(
      children: [
        // Page content
        Positioned.fill(
          top: MediaQuery.of(context).padding.top,
          bottom: MediaQuery.of(context).padding.bottom,
          child: CustomPaint(
            painter: Painter.gradientPainter([
              app.Colors.background,
              app.Colors.foreground,
            ]),
            child: CustomPaint(
              painter: Painter.tiledPainter(
                Size(size, size),
                BackgroundPattern.islamicPatternPainter(
                  app.Colors.foreground50,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(0, 48, 0, 80),
                child: child,
              ),
            ),
          ),
        ),
        // App Bar
        Positioned(left: 0, right: 0, top: 0, child: TopBar(currentPath)),
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
