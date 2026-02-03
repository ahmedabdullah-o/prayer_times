import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:prayer_times/core/services/location/ilocation.dart';
import 'package:prayer_times/core/services/location/location.dart';

final locationProvider = Provider<ILocation>((ref) {
  return Location();
});
