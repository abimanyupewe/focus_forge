# 📋 10 — Task & Habit Management (Logic)

> **Fase:** 2 (The Logic Brain)  
> **Prioritas:** 🔴 Critical  
> **Estimasi:** 3-4 jam  
> **Dependensi:** `02_DATABASE_SETUP.md`, `03_STATE_MANAGEMENT.md`

---

## 1. Deskripsi

Dokumen ini mendefinisikan **business logic** untuk modul Task & Habit Management — meliputi CRUD operations, time-boxing calculation, validasi domain, dan integrasi dengan Notification Engine.

---

## 2. ScheduleService (Domain Layer)

```dart
/// lib/features/schedule/domain/schedule_service.dart
///
/// Business logic layer antara presentation dan data layer.
/// Menghandle validasi, kalkulasi, dan side-effects.
class ScheduleService {
  final ScheduleRepository _scheduleRepo;
  final NotificationService _notificationService;

  ScheduleService(this._scheduleRepo, this._notificationService);

  /// Membuat jadwal baru dengan side-effects:
  /// 1. Validasi input
  /// 2. Generate UUID
  /// 3. Auto-calculate duration
  /// 4. Simpan ke database
  /// 5. Register notification alarms
  Future<Result<ScheduleModel>> createSchedule({
    required String title,
    String? description,
    required int iconCodePoint,
    required int colorValue,
    required DateTime startTime,
    required DateTime endTime,
    required List<int> activeDays,
    bool wrapUpAlarmEnabled = true,
    int wrapUpMinutesBefore = 5,
  }) async {
    // Validasi
    final validation = _validate(title, startTime, endTime, activeDays);
    if (validation.isFailure) return Result.failure(validation.error);

    final schedule = ScheduleModel()
      ..uid = const Uuid().v4()
      ..title = title
      ..description = description
      ..iconCodePoint = iconCodePoint
      ..colorValue = colorValue
      ..startTime = startTime
      ..endTime = endTime
      ..activeDays = activeDays
      ..wrapUpAlarmEnabled = wrapUpAlarmEnabled
      ..wrapUpMinutesBefore = wrapUpMinutesBefore;

    await _scheduleRepo.create(schedule);

    // Register dual-trigger notification
    await _notificationService.registerScheduleAlarms(schedule);

    return Result.success(schedule);
  }

  /// Update jadwal — re-register notifications
  Future<Result<ScheduleModel>> updateSchedule(ScheduleModel schedule) async {
    final validation = _validate(
      schedule.title, schedule.startTime, schedule.endTime, schedule.activeDays,
    );
    if (validation.isFailure) return Result.failure(validation.error);

    await _scheduleRepo.update(schedule);

    // Cancel old alarms, register new ones
    await _notificationService.cancelScheduleAlarms(schedule.uid);
    await _notificationService.registerScheduleAlarms(schedule);

    return Result.success(schedule);
  }

  /// Delete jadwal — cancel related notifications
  Future<void> deleteSchedule(int id, String uid) async {
    await _notificationService.cancelScheduleAlarms(uid);
    await _scheduleRepo.softDelete(id);
  }

  /// Validasi domain rules
  Result<void> _validate(
    String title, DateTime start, DateTime end, List<int> days,
  ) {
    if (title.trim().isEmpty) return Result.failure('Judul tidak boleh kosong');
    if (title.length > 50) return Result.failure('Judul maksimal 50 karakter');
    if (end.isBefore(start) || end.isAtSameMomentAs(start)) {
      return Result.failure('Jam Selesai harus lebih besar dari Jam Mulai');
    }
    final duration = end.difference(start).inMinutes;
    if (duration < 15) return Result.failure('Durasi minimum 15 menit');
    if (duration > 480) return Result.failure('Durasi maksimum 8 jam');
    if (days.isEmpty) return Result.failure('Pilih minimal 1 hari aktif');
    return Result.success(null);
  }
}
```

---

## 3. Data Flow Diagram

```
┌──────────┐     ┌─────────────────┐     ┌──────────────────┐
│ UI Form  │────►│ ScheduleService │────►│ ScheduleRepository│
│ (Create) │     │  - validate()   │     │  - create()       │
└──────────┘     │  - generate uid │     │  - put to Isar    │
                 │  - calc duration│     └──────────────────┘
                 │                 │
                 │                 │────►┌──────────────────┐
                 │  - register     │     │NotificationService│
                 │    alarms       │     │ - scheduleAlarm() │
                 └─────────────────┘     └──────────────────┘
```

---

## 4. Time-Boxing Logic

```dart
/// Auto-calculate duration
/// Input:  startTime = 19:00, endTime = 21:00
/// Output: durationMinutes = 120
int calculateDuration(DateTime startTime, DateTime endTime) {
  return endTime.difference(startTime).inMinutes;
}

/// Format duration untuk display
/// Input:  120 minutes
/// Output: "2 jam 0 menit"
String formatDuration(int minutes) {
  final hours = minutes ~/ 60;
  final mins = minutes % 60;
  if (hours > 0 && mins > 0) return '$hours jam $mins menit';
  if (hours > 0) return '$hours jam';
  return '$mins menit';
}
```

---

## 5. Today's Schedule Query

```dart
/// Mengambil jadwal untuk hari ini, sorted by startTime
/// Digunakan oleh HomeScreen dan Home Widget
Future<List<ScheduleModel>> getTodaySchedules() async {
  final today = DateTime.now();
  final dayOfWeek = today.weekday - 1; // 0=Mon, 6=Sun
  return _scheduleRepo.getByDayOfWeek(dayOfWeek);
}
```

---

## 6. Acceptance Criteria

- [ ] Create schedule: validasi → simpan → register alarm → return success
- [ ] Update schedule: re-validasi → update → re-register alarm
- [ ] Delete schedule: cancel alarm → soft-delete
- [ ] Duration auto-calculate akurat
- [ ] Validasi menolak input invalid dengan pesan error yang jelas
- [ ] `getTodaySchedules()` return jadwal sesuai hari saat ini
