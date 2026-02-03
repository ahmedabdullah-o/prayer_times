import 'package:flutter_compass/flutter_compass.dart';
import 'package:prayer_times/core/services/compass/icompass.dart';

class Compass implements ICompass {
  @override
  Stream<double?> get headingStream {
    return FlutterCompass.events?.map((event) {
          // Return heading in degrees (0-360)
          // null if compass is not available
          return event.heading;
        }) ??
        Stream.value(null);
  }

  @override
  Future<bool> isAvailable() async {
    final stream = FlutterCompass.events;
    return stream != null;
  }
}
