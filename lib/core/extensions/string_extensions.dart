import 'package:flutter/material.dart' show TimeOfDay;

extension StringExtensions on String {
  bool _validateTimeOfDay() {
    final codeunit = codeUnits;

    if (codeunit.length != 5 || codeunit[2] != 58) {
      return false;
    }

    for (int i = 0; i < 5; i++) {
      if (codeunit[i] > 57 || codeunit[i] < 48) {
        return false;
      }
      i == 1 ? i++ : 0;
    }
    return true;
  }

  TimeOfDay toTimeOfDay() {
    if (!_validateTimeOfDay()) {
      throw Exception("invalid format. Try formatting the string as: `HH:mm`");
    }

    int hours = 0;
    hours += (codeUnitAt(0) - 48) * 10;
    hours += codeUnitAt(1) - 48;
    int minutes = 0;
    minutes += (codeUnitAt(3) - 48) * 10;
    minutes += codeUnitAt(4) - 48;

    return TimeOfDay(hour: hours, minute: minutes);
  }

  String camelCaseToTitleCase() {
    if (isEmpty) return this;

    final spaced = replaceAllMapped(
      RegExp(r'([a-z0-9])([A-Z])'),
      (m) => '${m[1]} ${m[2]}',
    );

    return spaced
        .split(RegExp(r'\s+'))
        .map((word) => word[0].toUpperCase() + word.substring(1).toLowerCase())
        .join(' ');
  }
}
