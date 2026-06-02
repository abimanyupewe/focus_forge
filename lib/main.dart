import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'core/services/database_service.dart';
import 'core/services/notification_service.dart';
import 'core/theme/app_theme.dart';
import 'features/schedule/presentation/pages/dashboard_page.dart';
import 'features/onboarding/presentation/pages/onboarding_page.dart';

import 'core/theme/theme_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inisialisasi Isar Database di tingkat native/lokal sebelum merender UI.
  final isar = await DatabaseService.initialize();

  // Inisialisasi Notification Engine (Local timezone & channel details)
  await NotificationService.initialize();

  // Minta izin notifikasi secara proaktif
  await NotificationService.requestPermission();

  runApp(
    ProviderScope(
      overrides: [
        // Meng-override databaseProvider dengan instance database yang telah siap digunakan.
        databaseProvider.overrideWithValue(isar),
      ],
      child: const FocusForgeApp(),
    ),
  );
}

class FocusForgeApp extends ConsumerWidget {
  const FocusForgeApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);

    return MaterialApp(
      title: 'FocusForge',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: themeMode, // Menyesuaikan dengan konfigurasi tema yang aktif secara reaktif
      home: FutureBuilder<bool>(
        future: SharedPreferences.getInstance().then((prefs) => prefs.getBool('onboarding_completed') ?? false),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            );
          }
          final completed = snapshot.data ?? false;
          if (completed) {
            return const DashboardPage();
          } else {
            return const OnboardingPage();
          }
        },
      ),
    );
  }
}
