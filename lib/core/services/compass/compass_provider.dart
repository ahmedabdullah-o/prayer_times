import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:prayer_times/core/services/compass/icompass.dart';
import 'package:prayer_times/core/services/compass/compass.dart';

final compassProvider = Provider<ICompass>((ref) {
  return Compass();
});
