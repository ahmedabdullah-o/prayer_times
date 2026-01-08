import 'dart:math';

import 'package:flutter/material.dart';
import 'package:prayer_times/core/style/helper.dart';

class BackgroundPattern {
  const BackgroundPattern._();
  static CustomPainter islamicPatternPainter(Color color) =>
      _IslamicPatternPainter(color);
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
      Helper.regularPolygon(
        sides: 5,
        radius: min(w, h) * 0.3,
        center: Offset(w / 2, h / 2),
        rotation: 0.5 * pi,
      ),
      paintLight,
    );

    // PENTAGON flipped
    canvas.drawPath(
      Helper.regularPolygon(
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
