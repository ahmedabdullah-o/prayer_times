import 'package:flutter/material.dart';
import 'package:prayer_times/core/style/colors.dart' as app;

class Fonts {
  Fonts._();

  static const TextStyle topBarTitle = TextStyle(
        inherit: false,
        color: app.Colors.text,
        fontSize: 28,
        fontWeight: FontWeight.w800,
        letterSpacing: -0.8,
        fontFamily: 'MPLUSRounded1c',
      ),
      habitWidgetTitle = TextStyle(
        inherit: false,
        color: app.Colors.text,
        fontSize: 18,
        fontWeight: FontWeight.w500,
        letterSpacing: -0.5,
        fontFamily: 'MPLUSRounded1c',
      ),
      habitWidgetCaption = TextStyle(
        inherit: false,
        color: app.Colors.textSecondary,
        fontSize: 12,
        fontWeight: FontWeight.w400,
        letterSpacing: -0.8,
        fontFamily: 'MPLUSRounded1c',
      ),
      habitWidgetTrailingText = TextStyle(
        inherit: false,
        color: app.Colors.text,
        fontSize: 12,
        fontWeight: FontWeight.w500,
        letterSpacing: -0.5,
        fontFamily: 'MPLUSRounded1c',
      );
  static TextStyle prayerCardText(bool upcoming) {
    return TextStyle(
      inherit: false,
      color: app.Colors.text,
      fontSize: 20,
      fontWeight: upcoming ? FontWeight.w800 : FontWeight.w500,
      letterSpacing: -0.5,
      fontFamily: 'MPLUSRounded1c',
      height: 1.26,
    );
  }

  static TextStyle navigationBarItem(bool active) {
    return TextStyle(
      inherit: false,
      color: app.Colors.text,
      fontSize: 14,
      fontWeight: active ? FontWeight.w800 : FontWeight.w500,
      letterSpacing: -0.5,
      fontFamily: 'MPLUSRounded1c',
      height: 1.26,
    );
  }
}
