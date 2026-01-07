import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:prayer_times/app/shell/widgets/navigation_bar.dart' as app;
import 'package:prayer_times/app/shell/widgets/top_bar.dart';
import 'package:prayer_times/core/style/colors.dart' as app;

class AppShell extends ConsumerWidget {
  final Widget child;
  const AppShell({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentPath = GoRouterState.of(context).uri.toString();
    return Stack(
      children: [
        // Page content
        Positioned.fill(
          top: MediaQuery.of(context).padding.top,
          bottom: MediaQuery.of(context).padding.bottom,
          child: Stack(
            children: [
              Container(
                height: double.infinity,
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [app.Colors.foreground, app.Colors.background],
                    // stops: [.3, .85],
                    transform: GradientRotation(pi * 1.5),
                  ),
                ),
                child: _PatternBackground(),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(0, 48, 0, 80),
                child: child,
              ),
            ],
          ),
        ),
        // App Bar
        Positioned(left: 0, right: 0, top: 0, child: TopBar()),
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

Path _regularPolygon({
  required int sides,
  required double radius,
  Offset center = Offset.zero,
  double rotation = 0, // radians
}) {
  assert(sides >= 3);

  final path = Path();
  final angleStep = 2 * pi / sides;

  for (int i = 0; i < sides; i++) {
    final angle = rotation + i * angleStep;
    final point = Offset(
      center.dx + radius * cos(angle),
      center.dy + radius * sin(angle),
    );

    if (i == 0) {
      path.moveTo(point.dx, point.dy);
    } else {
      path.lineTo(point.dx, point.dy);
    }
  }

  path.close();
  return path;
}

class _IslamicPatternPainter extends CustomPainter {
  final Color color;

  _IslamicPatternPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final paintBold = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    final paintLight = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    final double w = size.width;
    final double h = size.height;

    // PENTAGON
    canvas.drawPath(
      _regularPolygon(
        sides: 5,
        radius: min(w, h) * 0.3,
        center: Offset(w / 2, h / 2),
        rotation: 0.5 * pi,
      ),
      paintLight,
    );

    // PENTAGON flipped
    canvas.drawPath(
      _regularPolygon(
        sides: 5,
        radius: min(w, h) * 0.3,
        center: Offset(w / 2, h / 2),
        rotation: 1.5 * pi,
      ),
      paintLight,
    );

    final rect = Rect.fromCircle(
      center: Offset(w / 2, h / 2),
      radius: (min(w, h)) / 2 - 1,
    );

    // SQUARE
    canvas.drawRect(rect, paintBold);

    // DIAMOND
    canvas.save();
    // 1. Move origin to rect center
    canvas.translate(rect.center.dx, rect.center.dy);
    // 2. Rotate
    canvas.rotate(pi * .25);
    // 3. Draw rect centered at origin
    canvas.drawRect(
      Rect.fromCenter(
        center: Offset.zero,
        width: rect.width,
        height: rect.height,
      ),
      paintBold,
    );
    // 4. Restore canvas
    canvas.restore();
  }

  @override
  bool shouldRepaint(_) => false;
}

class _TiledPainter extends CustomPainter {
  final Size tileSize;
  final CustomPainter painter;

  _TiledPainter({required this.tileSize, required this.painter});

  @override
  void paint(Canvas canvas, Size size) {
    for (
      double x = -tileSize.width;
      x < size.width + tileSize.width;
      x += tileSize.width
    ) {
      for (
        double y = -tileSize.height;
        y < size.height + tileSize.height;
        y += tileSize.height
      ) {
        canvas.save();
        canvas.translate(x, y);
        painter.paint(canvas, tileSize);
        canvas.restore();
      }
    }
  }

  @override
  bool shouldRepaint(_) => false;
}

class _PatternBackground extends StatelessWidget {
  const _PatternBackground();

  @override
  Widget build(BuildContext context) {
    final contextWidth = MediaQuery.widthOf(context);
    final size = contextWidth / 9;
    return CustomPaint(
      painter: _TiledPainter(
        tileSize: Size(size, size),
        painter: _IslamicPatternPainter(app.Colors.foreground50),
      ),
    );
  }
}
