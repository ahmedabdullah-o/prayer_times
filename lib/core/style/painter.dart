import 'package:flutter/material.dart';

class Painter {
  const Painter._();

  static CustomPainter tiledPainter(Size tileSize, CustomPainter pattern) =>
      _TiledPainter(tileSize: tileSize, pattern: pattern);

  static CustomPainter gradientPainter(List<Color> colors) =>
      _GradientPainter(colors);
}

class _TiledPainter extends CustomPainter {
  final Size tileSize;
  final CustomPainter pattern;

  _TiledPainter({required this.tileSize, required this.pattern});

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
        pattern.paint(canvas, tileSize);
        canvas.restore();
      }
    }
  }

  @override
  bool shouldRepaint(_) => false;
}

class _GradientPainter extends CustomPainter {
  List<Color> colors;
  _GradientPainter(this.colors);

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;

    final paint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: colors,
      ).createShader(rect);

    canvas.drawRect(rect, paint);
  }

  @override
  bool shouldRepaint(_) => false;
}
