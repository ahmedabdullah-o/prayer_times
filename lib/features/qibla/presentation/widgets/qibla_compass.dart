import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:prayer_times/core/services/compass/compass_provider.dart';
import 'package:prayer_times/core/style/colors.dart' as app;
import 'package:prayer_times/core/style/fonts.dart';
import 'package:prayer_times/features/qibla/domain/notifiers/qibla_direction_notifier.dart';

class QiblaCompass extends ConsumerWidget {
  const QiblaCompass({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final qiblaAsync = ref.watch(qiblaDirectionProvider);
    final compass = ref.read(compassProvider);
    final size = MediaQuery.of(context).size.width * 0.7;

    return qiblaAsync.when(
      loading: () => SizedBox(
        width: size,
        height: size,
        child: Center(
          child: CircularProgressIndicator(color: app.Colors.primary),
        ),
      ),
      error: (error, stack) => SizedBox(
        width: size,
        height: size,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.location_off, size: 48, color: app.Colors.error),
              SizedBox(height: 8),
              Text(
                'Location access required',
                style: TextStyle(
                  color: app.Colors.textSecondary,
                  fontFamily: 'MPLUSRounded1c',
                ),
              ),
            ],
          ),
        ),
      ),
      data: (qiblaDirection) => StreamBuilder<double?>(
        stream: compass.headingStream,
        builder: (context, snapshot) {
          if (!snapshot.hasData || snapshot.data == null) {
            // No compass data, show static compass
            return _buildStaticCompass(size, qiblaDirection);
          }

          final heading = snapshot.data!;
          final rotation = (qiblaDirection - heading) * pi / 180;
          final rotationDegrees = rotation * 180 / pi;
          final isFacingQibla = rotationDegrees.abs() < 5; // Within 5 degrees

          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: size,
                height: size,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Compass background (rotates with device heading)
                    Transform.rotate(
                      angle: -heading * pi / 180,
                      child: CustomPaint(
                        size: Size(size, size),
                        painter: _CompassPainter(),
                      ),
                    ),
                    // Qibla indicator with degree (points to Qibla direction)
                    Transform.rotate(
                      angle: rotation,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.navigation,
                            size: 60,
                            color: app.Colors.primary,
                          ),
                          SizedBox(height: 4),
                          Text(
                            '${qiblaDirection.toStringAsFixed(0)}°',
                            style: Fonts.prayerCardText(true),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              // "Facing Qibla" indicator
              if (isFacingQibla) ...[
                SizedBox(height: 16),
                Material(
                  color: Colors.transparent,
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    decoration: BoxDecoration(
                      color: app.Colors.primary,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      spacing: 8,
                      children: [
                        Icon(Icons.check_circle, color: Colors.white, size: 20),
                        Text(
                          'Facing Qibla',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontFamily: 'MPLUSRounded1c',
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          );
        },
      ),
    );
  }

  Widget _buildStaticCompass(double size, double qiblaDirection) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _CompassPainter(),
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
  bool shouldRepaint(_CompassPainter oldDelegate) => false;
}
