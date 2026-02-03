abstract class ICompass {
  /// Stream of device heading in degrees (0-360)
  /// 0° = North, 90° = East, 180° = South, 270° = West
  Stream<double?> get headingStream;

  /// Check if compass sensor is available on device
  Future<bool> isAvailable();
}
