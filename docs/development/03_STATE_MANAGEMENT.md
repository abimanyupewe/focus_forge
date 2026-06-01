# ⚡ 03 — State Management (Riverpod)

> **Fase:** 1 (Core Foundation)  
> **Prioritas:** 🔴 Critical  
> **Estimasi:** 2-3 jam  
> **Dependensi:** `01_PROJECT_SETUP.md`, `02_DATABASE_SETUP.md`

---

## 1. Deskripsi

Dokumen ini mendefinisikan arsitektur **State Management** FocusForge menggunakan **Riverpod**. Mencakup konvensi provider, global state patterns, dan strategi untuk menjaga stabilitas timer di background serta reaktivitas UI.

> **Kenapa Riverpod?**  
> Riverpod memberikan *compile-time safety*, mudah di-test (dependency injection otomatis), aman dari *memory leak* (auto-dispose), dan tidak bergantung pada BuildContext — ideal untuk timer yang harus berjalan stabil lintas halaman.

---

## 2. Provider Architecture Overview

```
┌──────────────────────────────────────────────────┐
│                  UI LAYER                        │
│  (ConsumerWidget / ConsumerStatefulWidget)       │
│                                                  │
│  ref.watch(scheduleListProvider)                 │
│  ref.watch(timerStateProvider)                   │
│  ref.watch(analyticsProvider)                    │
└────────────────────┬─────────────────────────────┘
                     │ reads / watches
                     ▼
┌──────────────────────────────────────────────────┐
│              STATE PROVIDERS                     │
│                                                  │
│  StateNotifierProvider (timer)                   │
│  AsyncNotifierProvider (schedule list)           │
│  FutureProvider (analytics aggregation)          │
└────────────────────┬─────────────────────────────┘
                     │ depends on
                     ▼
┌──────────────────────────────────────────────────┐
│            REPOSITORY PROVIDERS                  │
│                                                  │
│  Provider<ScheduleRepository>                    │
│  Provider<SessionRepository>                     │
└────────────────────┬─────────────────────────────┘
                     │ depends on
                     ▼
┌──────────────────────────────────────────────────┐
│           DATABASE PROVIDER                      │
│                                                  │
│  Provider<Isar> (databaseProvider)               │
└──────────────────────────────────────────────────┘
```

---

## 3. Global / App-Wide Providers

### 3.1 Theme Mode Provider

```dart
/// lib/core/theme/theme_provider.dart
///
/// Mengontrol mode tema aplikasi (Light/Dark/System).
/// Nilai disimpan ke SharedPreferences untuk persistensi antar sesi.
final themeModeProvider = StateNotifierProvider<ThemeModeNotifier, ThemeMode>(
  (ref) => ThemeModeNotifier(),
);

class ThemeModeNotifier extends StateNotifier<ThemeMode> {
  ThemeModeNotifier() : super(ThemeMode.system) {
    _loadFromPrefs();
  }

  Future<void> _loadFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final index = prefs.getInt('theme_mode') ?? 0;
    state = ThemeMode.values[index];
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    state = mode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('theme_mode', mode.index);
  }

  void toggle() {
    setThemeMode(
      state == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark,
    );
  }
}
```

### 3.2 Current Date Provider

```dart
/// Provider untuk tanggal aktif yang sedang dilihat user.
/// Default: hari ini. Bisa diubah saat user navigasi kalender.
final selectedDateProvider = StateProvider<DateTime>((ref) {
  final now = DateTime.now();
  return DateTime(now.year, now.month, now.day);
});
```

---

## 4. Feature-Level Provider Conventions

### 4.1 Schedule Providers

```dart
/// lib/features/schedule/presentation/providers/schedule_provider.dart

/// Provider untuk daftar jadwal berdasarkan hari yang dipilih.
/// Auto-refresh saat [selectedDateProvider] berubah.
final scheduleListProvider =
    AsyncNotifierProvider<ScheduleListNotifier, List<ScheduleModel>>(
  ScheduleListNotifier.new,
);

class ScheduleListNotifier extends AsyncNotifier<List<ScheduleModel>> {
  @override
  Future<List<ScheduleModel>> build() async {
    final selectedDate = ref.watch(selectedDateProvider);
    final repo = ref.watch(scheduleRepositoryProvider);
    // dayOfWeek: 0=Senin, 6=Minggu (ISO 8601)
    final dayOfWeek = selectedDate.weekday - 1;
    return repo.getByDayOfWeek(dayOfWeek);
  }

  /// Membuat jadwal baru dan refresh list.
  Future<void> createSchedule(ScheduleModel schedule) async {
    final repo = ref.read(scheduleRepositoryProvider);
    await repo.create(schedule);
    ref.invalidateSelf(); // Trigger rebuild
  }

  /// Update jadwal existing.
  Future<void> updateSchedule(ScheduleModel schedule) async {
    final repo = ref.read(scheduleRepositoryProvider);
    await repo.update(schedule);
    ref.invalidateSelf();
  }

  /// Soft-delete jadwal.
  Future<void> deleteSchedule(int id) async {
    final repo = ref.read(scheduleRepositoryProvider);
    await repo.softDelete(id);
    ref.invalidateSelf();
  }
}
```

### 4.2 Timer State Provider

```dart
/// lib/features/timer/presentation/providers/timer_provider.dart

/// State model untuk Focus Timer
@immutable
class TimerState {
  final TimerStatus status;        // idle, running, paused, completed
  final int totalSeconds;          // Total durasi target
  final int remainingSeconds;      // Detik yang tersisa
  final String? activeScheduleUid; // Schedule yang sedang dijalankan

  const TimerState({
    this.status = TimerStatus.idle,
    this.totalSeconds = 0,
    this.remainingSeconds = 0,
    this.activeScheduleUid,
  });

  double get progress =>
      totalSeconds > 0 ? (totalSeconds - remainingSeconds) / totalSeconds : 0;

  TimerState copyWith({...});
}

enum TimerStatus { idle, running, paused, completed }

/// StateNotifier untuk Focus Timer.
/// TIDAK menggunakan autoDispose — timer harus persist lintas halaman.
final timerStateProvider =
    StateNotifierProvider<TimerNotifier, TimerState>(
  (ref) => TimerNotifier(ref),
);
```

---

## 5. Provider Naming Conventions

| Pattern | Naming Convention | Contoh |
|---------|-------------------|--------|
| Data list | `{feature}ListProvider` | `scheduleListProvider` |
| Single item | `{feature}DetailProvider` | `scheduleDetailProvider` |
| State notifier | `{feature}StateProvider` | `timerStateProvider` |
| Repository | `{feature}RepositoryProvider` | `scheduleRepositoryProvider` |
| Service | `{feature}ServiceProvider` | `notificationServiceProvider` |
| Computed/derived | `{description}Provider` | `todayScheduleCountProvider` |

---

## 6. Auto-Dispose Strategy

| Provider | Auto-Dispose? | Alasan |
|----------|--------------|--------|
| `databaseProvider` | ❌ No | Singleton, hidup sepanjang app lifecycle |
| `themeModeProvider` | ❌ No | Global state, harus persist |
| `scheduleListProvider` | ✅ Yes | Rebuild setiap kali halaman dibuka |
| `timerStateProvider` | ❌ No | Timer harus berjalan di background lintas halaman |
| `analyticsProvider` | ✅ Yes | Data di-fetch ulang tiap kali halaman analytics dibuka |

---

## 7. Acceptance Criteria

- [ ] `ProviderScope` terkonfigurasi dengan benar di `main.dart`
- [ ] `themeModeProvider` berhasil toggle Light ↔ Dark dan persist setelah app restart
- [ ] `scheduleListProvider` me-return data yang sesuai dengan `selectedDateProvider`
- [ ] `timerStateProvider` tetap berjalan saat user navigasi ke halaman lain
- [ ] Semua providers mengikuti naming convention yang sudah ditentukan
- [ ] Tidak ada memory leak — providers auto-dispose sesuai strategi di Section 6
