import 'package:adhan_dart/adhan_dart.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:go_router/go_router.dart';
import 'package:logging/logging.dart';
import 'package:prayer_times/app/shell/app_shell.dart';
import 'package:prayer_times/core/services/location/location_provider.dart';
import 'package:prayer_times/core/services/notifications/notifications_provider.dart';
import 'package:prayer_times/core/services/prayer_times/prayer_times_provider.dart';
import 'package:prayer_times/core/services/storage/hive/hive_storage_provider.dart';
import 'package:prayer_times/core/services/storage/hive/ihive_storage.dart';
import 'package:prayer_times/core/style/colors.dart' as app;
import 'package:prayer_times/features/home/domain/notifiers/next_prayer_notifier.dart';
import 'package:prayer_times/features/home/presentation/screens/home_screen.dart';
import 'package:prayer_times/features/qibla/presentation/screens/qibla_screen.dart';
import 'package:workmanager/workmanager.dart';

final _logger = Logger('main');

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    final providerContainer = ProviderContainer();
    IHiveStorage? storage;
    try {
      switch (task) {
        case 'schedule_prayer_notifications':
          final prayerTimes = providerContainer.read(prayerTimesProvider);
          final taskStorage = await providerContainer.read(
            hiveStorageProvider.future,
          );
          storage = taskStorage;
          await prayerTimes.scheduleTodayPrayerNotifications(
            providerContainer.read(notificationsProvider),
            taskStorage,
          );
        default:
          break;
      }
      return Future.value(true);
    } catch (e, s) {
      _logger.shout('callbackDispatcher: task ($task) failed', e, s);
      return Future.value(false);
    } finally {
      // Hive doesn't support concurrent isolate access: close the boxes as
      // soon as the background task is done.
      try {
        await storage?.dispose();
      } catch (e, s) {
        _logger.warning('callbackDispatcher: failed to close storage', e, s);
      }
      providerContainer.dispose();
    }
  });
}

final _router = GoRouter(
  routes: [
    ShellRoute(
      builder: (context, state, child) => AppShell(child: child),
      routes: [
        GoRoute(path: '/home', builder: (context, state) => HomeScreen()),
        GoRoute(path: '/qibla', builder: (context, state) => QiblaScreen()),
      ],
    ),
  ],
  initialLocation: '/home',
);

bool _servicesStarted = false;

/// Runs once after storage is ready: initializes the notifications plugin and
/// refreshes the stored location (GPS coordinates + device timezone).
///
/// If location permission is denied or GPS is unavailable, previously stored
/// values are kept (Cairo defaults on first run).
void _startServices(WidgetRef ref, IHiveStorage storage) {
  if (_servicesStarted) return;
  _servicesStarted = true;

  () async {
    try {
      await ref.read(notificationsProvider).init();
    } catch (e, s) {
      _logger.shout('failed to initialize notifications', e, s);
    }
  }();

  () async {
    try {
      final locationService = ref.read(locationProvider);
      final position = await locationService.currentPosition;
      if (position != null) {
        await storage.setSavedCoordinates(
          Coordinates(position.latitude, position.longitude),
        );
        _logger.info(
          'stored GPS coordinates: ${position.latitude}, ${position.longitude}',
        );
      }
      await storage.setLocation(await FlutterTimezone.getLocalTimezone());
      // Recompute prayer times & next prayer with the refreshed settings.
      ref.invalidate(prayerTimesForOffsetProvider);
      ref.invalidate(nextPrayerProvider);
    } catch (e, s) {
      _logger.warning('failed to refresh location', e, s);
    }
  }();
}

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  Logger.root.level = Level.ALL;
  Logger.root.onRecord.listen((record) {
    if (kDebugMode) {
      debugPrint(
        '${record.level.name}: ${record.loggerName}: ${record.message}',
      );
      if (record.error != null) {
        debugPrint('${record.error}\n${record.stackTrace}');
      }
    }
  });
  Workmanager().initialize(callbackDispatcher);
  Workmanager().registerPeriodicTask(
    "schedule_prayer_notifications",
    "schedule_prayer_notifications",
    frequency: Duration(hours: 24),
    existingWorkPolicy: ExistingPeriodicWorkPolicy.keep,
  );

  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

  final themeBackgroundBrightness =
      WidgetsBinding.instance.platformDispatcher.platformBrightness;

  runApp(
    ProviderScope(
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarBrightness: Brightness.dark,
          statusBarIconBrightness: Brightness.dark,
          systemNavigationBarColor: Colors.transparent,
          systemNavigationBarDividerColor: app.Colors.foreground,
          systemNavigationBarContrastEnforced: false,
          systemStatusBarContrastEnforced: false,
          systemNavigationBarIconBrightness:
              switch (themeBackgroundBrightness) {
                Brightness.light => Brightness.dark,
                Brightness.dark => Brightness.light,
              },
        ),
        child: const MainApp(),
      ),
    ),
  );
}

class MainApp extends ConsumerWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final storage = ref.watch(hiveStorageProvider);
    return storage.when(
      data: (storage) {
        return FutureBuilder(
          future: storage.init(),
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return Container(
                width: double.infinity,
                height: double.infinity,
                color: app.Colors.background,
                child: const SizedBox(),
              );
            }
            _startServices(ref, storage);
            return Container(
              width: double.infinity,
              height: double.infinity,
              color: app.Colors.background,
              child: MaterialApp.router(
                routerConfig: _router,
                debugShowCheckedModeBanner: false,
              ),
            );
          },
        );
      },
      loading: () => const SizedBox(),
      error: (error, stack) => const SizedBox(),
    );
  }
}
