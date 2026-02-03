import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:prayer_times/core/style/colors.dart' as app;
import 'package:prayer_times/core/style/fonts.dart';
import 'package:prayer_times/features/qibla/domain/notifiers/qibla_direction_notifier.dart';

class QiblaCompass extends ConsumerWidget {
  const QiblaCompass({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final qiblaDirection = ref.watch(qiblaDirectionProvider);
    final size = MediaQuery.of(context).size.width * 0.7;

    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _CompassPainter(qiblaDirection),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.navigation, size: 60, color: app.Colors.primary),
              SizedBox(height: 8),
              Text(
                '${qiblaDirection.toStringAsFixed(0)}°',
                style: Fonts.prayerCardText(true),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CompassPainter extends CustomPainter {
  final double qiblaDirection;

  _CompassPainter(this.qiblaDirection);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // Draw outer circle
    final circlePaint = Paint()
      ..color = app.Colors.foreground
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, radius, circlePaint);

    // Draw border
    final borderPaint = Paint()
      ..color = app.Colors.primary
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;
    canvas.drawCircle(center, radius, borderPaint);

    // Draw cardinal directions
    final textPainter = TextPainter(textDirection: TextDirection.ltr);

    final directions = ['N', 'E', 'S', 'W'];
    final angles = [0, 90, 180, 270];

    for (int i = 0; i < directions.length; i++) {
      final angle = angles[i] * pi / 180;
      final x = center.dx + (radius - 30) * sin(angle);
      final y = center.dy - (radius - 30) * cos(angle);

      textPainter.text = TextSpan(
        text: directions[i],
        style: TextStyle(
          color: app.Colors.text,
          fontSize: 20,
          fontWeight: FontWeight.bold,
          fontFamily: 'MPLUSRounded1c',
        ),
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(x - textPainter.width / 2, y - textPainter.height / 2),
      );
    }

    // Draw degree markers
    final markerPaint = Paint()
      ..color = app.Colors.textSecondary
      ..strokeWidth = 2;

    for (int i = 0; i < 360; i += 30) {
      final angle = i * pi / 180;
      final startX = center.dx + (radius - 15) * sin(angle);
      final startY = center.dy - (radius - 15) * cos(angle);
      final endX = center.dx + (radius - 5) * sin(angle);
      final endY = center.dy - (radius - 5) * cos(angle);

      canvas.drawLine(Offset(startX, startY), Offset(endX, endY), markerPaint);
    }
  }

  @override
  bool shouldRepaint(_CompassPainter oldDelegate) {
    return oldDelegate.qiblaDirection != qiblaDirection;
  }
}
