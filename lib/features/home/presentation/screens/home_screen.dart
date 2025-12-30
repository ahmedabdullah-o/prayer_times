import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:prayer_times/core/enums/prayers_enums.dart';
import 'package:prayer_times/core/extensions/string_extensions.dart';
import 'package:prayer_times/core/services/prayer_times/prayer_times_provider.dart';
import 'package:prayer_times/core/services/storage/hive/hive_storage_provider.dart';
import 'package:prayer_times/core/style/colors.dart' as app;
import 'package:prayer_times/features/home/presentation/widgets/calendar.dart';
import 'package:prayer_times/features/home/presentation/widgets/prayer_card.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final prayerTimes = ref.read(prayerTimesProvider);
    final prayerNames = PrayersEnums.values;

    final todayPrayerTimes = prayerTimes.todayPrayerTimes;
    final upcoming = prayerTimes.nextPrayer;

    final storage = ref.watch(hiveStorageProvider);

    return storage.when(
      loading: () => CircularProgressIndicator(),
      error: (e, s) => throw Exception(e.toString()),
      data: (storage) => Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          SizedBox(height: 20),
          Container(
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [app.Colors.foreground, app.Colors.background],
                // stops: [.3, .85],
                transform: GradientRotation(pi * 1.5),
              ),
            ),
            foregroundDecoration: BoxDecoration(),
            child: Stack(
              children: [
                Positioned.fill(
                  child: RepaintBoundary(child: _PatternBackground()),
                ),
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Calendar(),
                      ...List.generate(
                        prayerNames.length,
                        (i) => FutureBuilder<bool>(
                          future: storage.getNotificationMute(prayerNames[i]),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState !=
                                ConnectionState.done) {
                              return SizedBox();
                            }
                            return PrayerCard(
                              prayerNames[i].name.camelCaseToTitleCase(),
                              todayPrayerTimes[prayerNames[i]]!,
                              upcoming == prayerNames[i],
                              snapshot.data ?? false,
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
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
