import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:prayer_times/core/enums/svg_icon_data_enums.dart';
import 'package:prayer_times/core/style/colors.dart' as app;
import 'package:prayer_times/core/style/icons.dart';
import 'package:prayer_times/features/qibla/domain/notifiers/qibla_direction_notifier.dart';

class DirectionIndicator extends ConsumerWidget {
  const DirectionIndicator({super.key});

  String _getCardinalDirection(double degrees) {
    if (degrees >= 337.5 || degrees < 22.5) return 'N';
    if (degrees >= 22.5 && degrees < 67.5) return 'NE';
    if (degrees >= 67.5 && degrees < 112.5) return 'E';
    if (degrees >= 112.5 && degrees < 157.5) return 'SE';
    if (degrees >= 157.5 && degrees < 202.5) return 'S';
    if (degrees >= 202.5 && degrees < 247.5) return 'SW';
    if (degrees >= 247.5 && degrees < 292.5) return 'W';
    if (degrees >= 292.5 && degrees < 337.5) return 'NW';
    return 'N';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final qiblaAsync = ref.watch(qiblaDirectionProvider);

    return qiblaAsync.when(
      loading: () => Container(
        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        decoration: BoxDecoration(
          color: app.Colors.foreground,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Text(
          'Calculating...',
          style: TextStyle(
            color: app.Colors.textSecondary,
            fontSize: 16,
            fontFamily: 'MPLUSRounded1c',
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      error: (error, stack) => Container(
        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        decoration: BoxDecoration(
          color: app.Colors.foreground,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Text(
          'Location required',
          style: TextStyle(
            color: app.Colors.error,
            fontSize: 16,
            fontFamily: 'MPLUSRounded1c',
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      data: (qiblaDirection) {
        final cardinalDirection = _getCardinalDirection(qiblaDirection);
        return Container(
          padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          decoration: BoxDecoration(
            color: app.Colors.foreground,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            spacing: 12,
            children: [
              SvgIcon(
                SvgIconData.compass,
                width: 24,
                height: 24,
                color: app.Colors.primary,
              ),
              Text(
                'Qibla Direction: ${qiblaDirection.toStringAsFixed(0)}° $cardinalDirection',
                style: TextStyle(
                  color: app.Colors.text,
                  fontSize: 16,
                  fontFamily: 'MPLUSRounded1c',
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
