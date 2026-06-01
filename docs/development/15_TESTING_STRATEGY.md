# 🧪 15 — Testing Strategy

> **Fase:** 4 (Polish & Finalization)  
> **Prioritas:** 🟡 High  
> **Estimasi:** Ongoing  
> **Dependensi:** Semua modul

---

## 1. Deskripsi

Strategi testing komprehensif untuk FocusForge — mencakup unit test, widget test, integration test, dan performance benchmarking sesuai KPI dari PRD.

---

## 2. Testing Pyramid

```
          ╱╲
         ╱  ╲         Integration Tests (3-5)
        ╱    ╲        E2E flows: create → start → complete
       ╱──────╲
      ╱        ╲      Widget Tests (10-15)
     ╱          ╲     UI components & screen renders
    ╱────────────╲
   ╱              ╲   Unit Tests (30-40)
  ╱________________╲  Services, repositories, utils
```

---

## 3. Unit Tests

### 3.1 ScheduleService

| Test Case | Expected |
|-----------|----------|
| Create dengan valid input | Success + saved to DB |
| Create dengan judul kosong | Failure: "Judul tidak boleh kosong" |
| Create dengan duration < 15 min | Failure: "Durasi minimum 15 menit" |
| Create dengan duration > 480 min | Failure: "Durasi maksimum 8 jam" |
| Create dengan endTime < startTime | Failure: "Jam Selesai harus lebih besar" |
| Update existing schedule | Success + notification re-registered |
| Delete schedule | Soft-delete + notification cancelled |

### 3.2 TimerNotifier

| Test Case | Expected |
|-----------|----------|
| start(3600) | Status = running, remaining = 3600 |
| Tick 1 detik | remaining = 3599 |
| pause() | Status = paused, ticker stopped |
| resume() | Status = running, ticker restarted |
| reset() | Status = idle, remaining = 0 |
| Complete (remaining = 0) | Status = completed, session logged |

### 3.3 AnalyticsService

| Test Case | Expected |
|-----------|----------|
| Streak: 3 hari berturut | streak = 3 |
| Streak: hari ini belum ada sesi | Cek kemarin |
| Heatmap level: 0 min | Level 0 |
| Heatmap level: 45 min | Level 2 |
| Heatmap level: 150 min | Level 4 |

### 3.4 Utility Functions

| Test Case | Expected |
|-----------|----------|
| calculateDuration(19:00, 21:00) | 120 min |
| formatDuration(120) | "2 jam 0 menit" |
| formatDuration(45) | "45 menit" |
| getHeatmapLevel(0) | 0 |
| getHeatmapLevel(7200) | 4 |

---

## 4. Widget Tests

| Screen/Component | Test Case |
|------------------|-----------|
| HomeScreen | Renders schedule list correctly |
| HomeScreen | Empty state saat tidak ada jadwal |
| HomeScreen | FAB navigasi ke form |
| ScheduleCard | Menampilkan title, time range, duration |
| ScheduleCard | Start button tap navigasi ke timer |
| ScheduleFormScreen | Validasi form fields |
| ScheduleFormScreen | Duration auto-calculate |
| FocusTimerScreen | Render circular timer |
| FocusTimerScreen | Controls sesuai state |
| AnalyticsScreen | Render heatmap grid |
| AnalyticsScreen | Streak counter display |

---

## 5. Integration Tests

| Flow | Steps |
|------|-------|
| **Create & View** | Open app → Tap FAB → Fill form → Save → Verify card in list |
| **Start Timer** | Tap "Start" on card → Timer auto-filled → Countdown running |
| **Complete Session** | Start timer → Wait completion → Verify session logged |
| **Full Cycle** | Create → Start → Complete → Check analytics updated |

---

## 6. Performance Benchmarks (KPI dari PRD)

| Metric | Target | Tool |
|--------|--------|------|
| Frame rate | Konstan 60 FPS | Flutter DevTools |
| App size (installed) | < 25 MB | `flutter build apk --analyze-size` |
| Cold start time | < 2 detik | Manual measurement |
| Notification accuracy | 100% pada waktu yang ditentukan | Manual testing |
| Battery usage (background) | Minimal | Android Battery Stats |
| Database read (100 records) | < 50ms | Stopwatch benchmark |

---

## 7. Mocking Strategy

```dart
/// Menggunakan mocktail untuk mocking dependencies
class MockScheduleRepository extends Mock implements ScheduleRepository {}
class MockSessionRepository extends Mock implements SessionRepository {}
class MockNotificationService extends Mock implements NotificationService {}

/// Setup di test:
final mockRepo = MockScheduleRepository();
when(() => mockRepo.getAllActive()).thenAnswer((_) async => [testSchedule]);
```

---

## 8. Test File Structure

```
test/
├── unit/
│   ├── schedule_service_test.dart
│   ├── timer_notifier_test.dart
│   ├── analytics_service_test.dart
│   ├── duration_utils_test.dart
│   └── notification_id_test.dart
├── widget/
│   ├── home_screen_test.dart
│   ├── schedule_card_test.dart
│   ├── schedule_form_test.dart
│   ├── focus_timer_test.dart
│   └── heatmap_grid_test.dart
└── integration/
    ├── create_schedule_flow_test.dart
    ├── timer_session_flow_test.dart
    └── full_cycle_test.dart
```

---

## 9. Acceptance Criteria

- [ ] Unit test coverage ≥ 80% untuk domain/service layer
- [ ] Widget tests passing untuk semua screen utama
- [ ] Integration test: full cycle (create → start → complete → analytics) passing
- [ ] App berjalan konstan 60 FPS (Flutter DevTools)
- [ ] Installed size < 25 MB
- [ ] Cold start < 2 detik
