import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:logging/logging.dart';
import 'package:prayer_times/app/shell/app_shell.dart';
import 'package:prayer_times/core/services/notifications/notifications_provider.dart';
import 'package:prayer_times/core/services/prayer_times/prayer_times_provider.dart';
import 'package:prayer_times/core/services/storage/hive/hive_storage_provider.dart';
import 'package:prayer_times/core/style/colors.dart' as app;
import 'package:prayer_times/features/home/presentation/screens/home_screen.dart';
import 'package:workmanager/workmanager.dart';

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    final providerContainer = ProviderContainer();
    switch (task) {
      case "schedule_prayer_notifications":
        final prayerTimes = providerContainer.read(prayerTimesProvider);
        prayerTimes.scheduleTodayPrayerNotifications(
          providerContainer.read(notificationsProvider),
        );
      default:
        false;
    }
    return Future.value(true);
  });
}

final _router = GoRouter(
  routes: [
    ShellRoute(
      builder: (context, state, child) => AppShell(child: child),
      routes: [
        GoRoute(path: '/home', builder: (context, state) => HomeScreen()),
      ],
    ),
  ],
  initialLocation: '/home',
);

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

  runApp(
    ProviderScope(
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: const SystemUiOverlayStyle(
          statusBarColor: app.Colors.background,
          systemNavigationBarColor: app.Colors.foreground,
          systemNavigationBarDividerColor: app.Colors.foreground,
          systemNavigationBarContrastEnforced: true,
          systemStatusBarContrastEnforced: true,
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
    final notifications = ref.read(notificationsProvider);
    notifications.requestPermissions();
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
            return Container(
              width: double.infinity,
              height: double.infinity,
              color: app.Colors.background,
              child: SafeArea(
                child: MaterialApp.router(
                  routerConfig: _router,
                  debugShowCheckedModeBanner: false,
                ),
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
