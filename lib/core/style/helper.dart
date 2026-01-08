import 'dart:math';
import 'dart:ui';

class Helper {
  const Helper._();

  static Path regularPolygon({
    required int sides,
    required double radius,
    Offset center = Offset.zero,
    double rotation = 0,
  }) => _regularPolygon(
    sides: sides,
    radius: radius,
    center: center,
    rotation: rotation,
  );
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
