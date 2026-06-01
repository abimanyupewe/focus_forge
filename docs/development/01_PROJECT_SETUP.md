# 🔧 01 — Project Setup & Configuration

> **Fase:** 1 (Core Foundation)  
> **Prioritas:** 🔴 Critical  
> **Estimasi:** 2-3 jam

---

## 1. Deskripsi

Dokumen ini mencakup seluruh konfigurasi awal project Flutter **FocusForge** — mulai dari dependency management, folder structure berbasis *Feature-First Architecture*, theme system (Light/Dark), hingga konfigurasi environment untuk Android & iOS.

---

## 2. Dependencies (pubspec.yaml)

### 2.1 Production Dependencies

```yaml
dependencies:
  flutter:
    sdk: flutter

  # === State Management ===
  flutter_riverpod: ^2.6.1        # Reactive state management
  riverpod_annotation: ^2.6.1     # Code generation untuk providers

  # === Database ===
  isar: ^4.0.0-dev.14             # High-performance local DB
  isar_flutter_libs: ^4.0.0-dev.14 # Flutter bindings untuk Isar
  path_provider: ^2.1.5           # Akses filesystem path

  # === Routing ===
  go_router: ^15.1.2              # Declarative routing

  # === Notification ===
  flutter_local_notifications: ^18.0.1  # Local push notification
  timezone: ^0.10.0                      # Timezone-aware scheduling

  # === Home Widget ===
  home_widget: ^0.7.0             # Native widget bridge

  # === UI Utilities ===
  google_fonts: ^6.2.1            # Typography (Inter/Nunito)
  flutter_animate: ^4.5.2         # Declarative animations
  intl: ^0.20.2                   # Date/time formatting
  uuid: ^4.5.1                    # Unique ID generation
```

### 2.2 Dev Dependencies

```yaml
dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^6.0.0
  isar_generator: ^4.0.0-dev.14   # Code gen untuk Isar schema
  build_runner: ^2.4.15           # Build runner untuk code gen
  riverpod_generator: ^2.6.4     # Code gen untuk Riverpod
  mocktail: ^1.0.4               # Mocking framework untuk testing
```

### 2.3 Instalasi

```bash
# Install semua dependencies
flutter pub get

# Jalankan code generation (Isar schema + Riverpod providers)
dart run build_runner build --delete-conflicting-outputs
```

---

## 3. Folder Structure (Feature-First Architecture)

```
lib/
├── main.dart                          # Entry point
├── app.dart                           # MaterialApp + ProviderScope wrapper
│
├── core/                              # Shared utilities & constants
│   ├── constants/
│   │   ├── app_colors.dart            # Color palette tokens
│   │   ├── app_typography.dart        # Text style definitions
│   │   ├── app_spacing.dart           # Spacing & sizing scale
│   │   └── app_strings.dart           # Static string constants
│   ├── theme/
│   │   ├── app_theme.dart             # ThemeData (light + dark)
│   │   └── theme_provider.dart        # Riverpod theme state
│   ├── router/
│   │   └── app_router.dart            # GoRouter configuration
│   ├── utils/
│   │   ├── date_utils.dart            # Date/time helper functions
│   │   └── duration_utils.dart        # Duration calculation helpers
│   └── widgets/                       # Reusable global widgets
│       ├── app_card.dart
│       ├── app_button.dart
│       └── empty_state.dart
│
├── features/                          # Feature-based modules
│   ├── schedule/                      # Modul 1: Task & Habit Management
│   │   ├── data/
│   │   │   ├── models/
│   │   │   │   └── schedule_model.dart       # Isar collection schema
│   │   │   └── repositories/
│   │   │       └── schedule_repository.dart  # CRUD operations
│   │   ├── presentation/
│   │   │   ├── providers/
│   │   │   │   └── schedule_provider.dart    # Riverpod providers
│   │   │   ├── screens/
│   │   │   │   ├── home_screen.dart          # Daftar jadwal harian
│   │   │   │   └── schedule_form_screen.dart # Create/Edit form
│   │   │   └── widgets/
│   │   │       ├── schedule_card.dart        # Individual schedule card
│   │   │       ├── schedule_list.dart        # List builder
│   │   │       └── time_range_picker.dart    # Custom time picker
│   │   └── domain/
│   │       └── schedule_service.dart         # Business logic layer
│   │
│   ├── timer/                         # Modul 3: Focus Timer
│   │   ├── data/
│   │   │   ├── models/
│   │   │   │   └── session_model.dart        # Session log schema
│   │   │   └── repositories/
│   │   │       └── session_repository.dart   # Session CRUD
│   │   ├── presentation/
│   │   │   ├── providers/
│   │   │   │   └── timer_provider.dart       # Timer state (Riverpod)
│   │   │   ├── screens/
│   │   │   │   └── focus_timer_screen.dart   # Timer UI
│   │   │   └── widgets/
│   │   │       ├── circular_timer.dart       # Animated circular progress
│   │   │       └── timer_controls.dart       # Play/Pause/Reset buttons
│   │   └── domain/
│   │       └── timer_service.dart            # Timer engine logic
│   │
│   ├── analytics/                     # Modul 4: Analytics & Heatmap
│   │   ├── presentation/
│   │   │   ├── providers/
│   │   │   │   └── analytics_provider.dart
│   │   │   ├── screens/
│   │   │   │   └── analytics_screen.dart
│   │   │   └── widgets/
│   │   │       ├── heatmap_grid.dart         # Contribution graph
│   │   │       ├── streak_counter.dart       # Daily streak display
│   │   │       └── stat_card.dart            # Individual metric card
│   │   └── domain/
│   │       └── analytics_service.dart        # Aggregation logic
│   │
│   └── notification/                  # Modul 2: Notification Engine
│       └── data/
│           └── notification_service.dart     # Local notification config
│
├── services/                          # Global services
│   ├── database_service.dart          # Isar initialization
│   └── widget_service.dart            # Home widget data sync
│
└── gen/                               # Auto-generated files
    └── ...                            # build_runner output
```

---

## 4. Entry Point (`main.dart`)

```dart
/// Entry point FocusForge application.
///
/// Menginisialisasi database, notification, dan timezone
/// sebelum menjalankan widget tree.
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. Initialize timezone data untuk notification scheduling
  tz.initializeTimeZones();

  // 2. Initialize Isar database
  final isar = await DatabaseService.initialize();

  // 3. Initialize notification service
  await NotificationService.initialize();

  runApp(
    ProviderScope(
      overrides: [
        // Inject Isar instance ke seluruh app
        databaseProvider.overrideWithValue(isar),
      ],
      child: const FocusForgeApp(),
    ),
  );
}
```

---

## 5. App Shell (`app.dart`)

```dart
/// Root widget FocusForge.
///
/// Mengkonsumsi theme provider untuk reactive Light/Dark mode switching,
/// dan GoRouter untuk deklaratif navigation.
class FocusForgeApp extends ConsumerWidget {
  const FocusForgeApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: 'FocusForge',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: themeMode,
      routerConfig: router,
    );
  }
}
```

---

## 6. Platform Configuration

### 6.1 Android (`android/app/build.gradle`)

```groovy
android {
    compileSdk = 35
    defaultConfig {
        minSdk = 24          // Minimum Android 7.0 (Notification Channels)
        targetSdk = 35
    }
}
```

### 6.2 Android Manifest — Permissions

```xml
<!-- android/app/src/main/AndroidManifest.xml -->
<manifest>
  <!-- Notification & alarm permissions -->
  <uses-permission android:name="android.permission.RECEIVE_BOOT_COMPLETED"/>
  <uses-permission android:name="android.permission.SCHEDULE_EXACT_ALARM"/>
  <uses-permission android:name="android.permission.POST_NOTIFICATIONS"/>
  <uses-permission android:name="android.permission.VIBRATE"/>

  <!-- Background/foreground service untuk timer -->
  <uses-permission android:name="android.permission.FOREGROUND_SERVICE"/>
</manifest>
```

### 6.3 iOS (`ios/Runner/Info.plist`)

```xml
<!-- Request notification permission -->
<key>UIBackgroundModes</key>
<array>
  <string>fetch</string>
  <string>processing</string>
</array>
```

---

## 7. Acceptance Criteria

- [ ] `flutter run` berhasil tanpa error di Android Emulator & iOS Simulator
- [ ] `build_runner` menghasilkan file `.g.dart` tanpa conflict
- [ ] Folder structure sesuai diagram di Section 3
- [ ] Theme switching (Light ↔ Dark) berfungsi dari `themeModeProvider`
- [ ] `minSdk` Android = 24, iOS deployment target = 15.0
