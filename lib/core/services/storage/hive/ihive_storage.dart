import 'package:prayer_times/core/enums/settings_category_enums.dart';

abstract class IHiveStorage {
  /// This initializes default values in the database.
  ///
  /// The package itself `hive` doesn't need initialization.
  void init();

  void set(String key, String value);

  dynamic getSettings(SettingsCategoryEnums category, Enum key);
}
