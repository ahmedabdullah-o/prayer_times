import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
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
  Workmanager().initialize(callbackDispatcher);
  Workmanager().registerPeriodicTask(
    "schedule_prayer_notifications",
    "schedule_prayer_notifications",
    frequency: Duration(hours: 24),
    existingWorkPolicy: ExistingPeriodicWorkPolicy.keep,
  );

  SystemChrome.setSystemUIOverlayStyle(
    SystemUiOverlayStyle(
      systemNavigationBarColor: app.Colors.foreground,
      systemNavigationBarDividerColor: app.Colors.foreground,
      statusBarColor: app.Colors.background,
    ),
  );
  runApp(ProviderScope(child: const MainApp()));
}

class MainApp extends ConsumerWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifications = ref.read(notificationsProvider);
    notifications.requestPermissions();
    final storage = ref.read(hiveStorageProvider);
    storage.init();
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
  }
}
