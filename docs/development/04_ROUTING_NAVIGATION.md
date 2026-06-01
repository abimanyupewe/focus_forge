# 🧭 04 — Routing & Navigation

> **Fase:** 1 (Core Foundation)  
> **Prioritas:** 🟡 High  
> **Estimasi:** 1-2 jam  
> **Dependensi:** `01_PROJECT_SETUP.md`, `03_STATE_MANAGEMENT.md`

---

## 1. Deskripsi

Dokumen ini mendefinisikan konfigurasi **GoRouter** untuk navigasi deklaratif FocusForge. Mencakup route definitions, deep linking (dari notification dan home widget), dan transisi antar halaman.

---

## 2. Route Map

```
/                         → HomeScreen (Daftar Jadwal Hari Ini)
├── /schedule/create      → ScheduleFormScreen (Buat Jadwal Baru)
├── /schedule/:id/edit    → ScheduleFormScreen (Edit Jadwal)
├── /timer                → FocusTimerScreen (Timer Default)
├── /timer/:scheduleUid   → FocusTimerScreen (Timer Pre-filled dari Schedule)
└── /analytics            → AnalyticsScreen (Heatmap & Statistik)
```

---

## 3. GoRouter Configuration

```dart
/// lib/core/router/app_router.dart
///
/// Konfigurasi routing deklaratif menggunakan GoRouter.
/// Mendukung deep linking dari notification dan home widget.
final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    debugLogDiagnostics: true,
    routes: [
      GoRoute(
        path: '/',
        name: 'home',
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: '/schedule/create',
        name: 'schedule-create',
        pageBuilder: (context, state) => CustomTransitionPage(
          child: const ScheduleFormScreen(),
          transitionsBuilder: _slideUpTransition,
        ),
      ),
      GoRoute(
        path: '/schedule/:id/edit',
        name: 'schedule-edit',
        builder: (context, state) {
          final id = int.parse(state.pathParameters['id']!);
          return ScheduleFormScreen(scheduleId: id);
        },
      ),
      GoRoute(
        path: '/timer',
        name: 'timer',
        builder: (context, state) => const FocusTimerScreen(),
      ),
      GoRoute(
        path: '/timer/:scheduleUid',
        name: 'timer-schedule',
        builder: (context, state) {
          final uid = state.pathParameters['scheduleUid']!;
          return FocusTimerScreen(scheduleUid: uid);
        },
      ),
      GoRoute(
        path: '/analytics',
        name: 'analytics',
        builder: (context, state) => const AnalyticsScreen(),
      ),
    ],
  );
});

/// Animasi slide-up untuk modal-style screens (Create/Edit)
Widget _slideUpTransition(
  BuildContext context,
  Animation<double> animation,
  Animation<double> secondaryAnimation,
  Widget child,
) {
  return SlideTransition(
    position: Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: animation,
      curve: Curves.easeOutCubic,
    )),
    child: child,
  );
}
```

---

## 4. Bottom Navigation Bar

```dart
/// Navigasi utama menggunakan BottomNavigationBar dengan 3 tab:
/// 
/// [0] Home    — Daftar Jadwal (/)
/// [1] Timer   — Focus Timer (/timer)
/// [2] Stats   — Analytics (/analytics)
///
/// State index tab di-manage via Riverpod StateProvider.
final bottomNavIndexProvider = StateProvider<int>((ref) => 0);
```

### Route-to-Tab Mapping

| Index | Label | Icon | Route |
|-------|-------|------|-------|
| 0 | Jadwal | `Icons.calendar_today_rounded` | `/` |
| 1 | Fokus | `Icons.timer_rounded` | `/timer` |
| 2 | Statistik | `Icons.bar_chart_rounded` | `/analytics` |

---

## 5. Deep Linking Entry Points

| Source | URI Pattern | Target |
|--------|-------------|--------|
| Start Alarm Notification | `/timer/{scheduleUid}` | FocusTimerScreen (pre-filled) |
| Wrap-up Notification | `/timer` | FocusTimerScreen (current session) |
| Home Widget "Start" button | `/timer/{scheduleUid}` | FocusTimerScreen (pre-filled) |
| Home Widget tap | `/` | HomeScreen |

---

## 6. Page Transitions

| Route | Transition | Duration |
|-------|-----------|----------|
| Home → Timer | Fade + Scale | 300ms |
| Home → Schedule Form | Slide Up (modal) | 350ms |
| Home → Analytics | Fade | 250ms |
| Notification → Timer | Instant (no animation) | 0ms |

---

## 7. Acceptance Criteria

- [ ] Semua 6 route ter-register dan accessible tanpa error
- [ ] Deep link `/timer/{scheduleUid}` membuka FocusTimerScreen dengan durasi pre-filled
- [ ] BottomNavigationBar menampilkan 3 tab dan sinkron dengan route aktif
- [ ] Slide-up transition berjalan smooth untuk Schedule Form
- [ ] Back button behavior konsisten (Android hardware back + iOS swipe)
