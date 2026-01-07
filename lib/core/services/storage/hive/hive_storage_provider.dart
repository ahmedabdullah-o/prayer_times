import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:prayer_times/core/services/storage/hive/hive_storage.dart';
import 'package:prayer_times/core/services/storage/hive/ihive_storage.dart';

final hiveStorageProvider = FutureProvider<IHiveStorage>((ref) {
  return HiveStorage();
});
