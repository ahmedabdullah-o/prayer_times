import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:prayer_times/core/services/location/ilocation.dart';
import 'package:prayer_times/core/services/location/location.dart';

final notificationsProvider = Provider<Ilocation>((ref) {
  return Location();
});
