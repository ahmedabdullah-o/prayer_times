import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:prayer_times/app/shell/app_shell.dart';
import 'package:prayer_times/core/services/notifications/notifications_provider.dart';
import 'package:prayer_times/core/style/colors.dart' as app;
import 'package:prayer_times/features/home/presentation/screens/home_screen.dart';

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
    final notifications = ref.watch(notificationsProvider);
    notifications.init();
    return SafeArea(
      child: MaterialApp.router(
        color: app.Colors.background,
        routerConfig: _router,
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
