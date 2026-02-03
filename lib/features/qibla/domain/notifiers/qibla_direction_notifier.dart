import 'package:flutter_riverpod/flutter_riverpod.dart';

final qiblaDirectionProvider = NotifierProvider<QiblaDirection, double>(
  QiblaDirection.new,
);

class QiblaDirection extends Notifier<double> {
  @override
  double build() {
    // Hardcoded Qibla direction for Cairo (in degrees from North)
    // This will be replaced with real calculation later
    return 135.0;
  }

  void update(double newDirection) => state = newDirection;
}
