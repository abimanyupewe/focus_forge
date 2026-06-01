# ⏲️ 11 — Focus Timer Logic

> **Fase:** 2 (The Logic Brain)  
> **Prioritas:** 🔴 Critical  
> **Estimasi:** 4-5 jam  
> **Dependensi:** `02_DATABASE_SETUP.md`, `03_STATE_MANAGEMENT.md`

---

## 1. Deskripsi

Engine logic untuk **Focus Timer** — Pomodoro-style countdown yang sinkron dengan durasi jadwal, berjalan stabil di background, dan otomatis menyimpan session log setelah selesai.

---

## 2. TimerNotifier (State Engine)

```dart
/// lib/features/timer/presentation/providers/timer_provider.dart
///
/// Core timer engine menggunakan StateNotifier.
/// TIDAK auto-dispose — harus persist lintas halaman.
class TimerNotifier extends StateNotifier<TimerState> {
  final Ref _ref;
  Timer? _ticker;
  DateTime? _startedAt;

  TimerNotifier(this._ref) : super(const TimerState());

  /// Start timer dengan durasi tertentu (dalam detik).
  void start(int totalSeconds, {String? scheduleUid}) {
    _ticker?.cancel();
    _startedAt = DateTime.now();

    state = TimerState(
      status: TimerStatus.running,
      totalSeconds: totalSeconds,
      remainingSeconds: totalSeconds,
      activeScheduleUid: scheduleUid,
    );

    _ticker = Timer.periodic(const Duration(seconds: 1), (_) => _tick());
  }

  /// Sync start dari schedule — auto-fill durasi dari ScheduleModel
  Future<void> startFromSchedule(String scheduleUid) async {
    final repo = _ref.read(scheduleRepositoryProvider);
    final schedules = await repo.getAllActive();
    final schedule = schedules.firstWhere((s) => s.uid == scheduleUid);
    start(schedule.durationMinutes * 60, scheduleUid: scheduleUid);
  }

  void pause() {
    _ticker?.cancel();
    state = state.copyWith(status: TimerStatus.paused);
  }

  void resume() {
    state = state.copyWith(status: TimerStatus.running);
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) => _tick());
  }

  void reset() {
    _ticker?.cancel();
    _startedAt = null;
    state = const TimerState();
  }

  void _tick() {
    if (state.remainingSeconds <= 0) {
      _ticker?.cancel();
      state = state.copyWith(
        status: TimerStatus.completed,
        remainingSeconds: 0,
      );
      _logSession();
      return;
    }
    state = state.copyWith(
      remainingSeconds: state.remainingSeconds - 1,
    );
  }

  /// Log sesi ke database setelah timer selesai
  Future<void> _logSession() async {
    if (_startedAt == null) return;
    final now = DateTime.now();
    final actualDuration = now.difference(_startedAt!).inSeconds;

    final session = SessionModel()
      ..scheduleUid = state.activeScheduleUid ?? 'manual'
      ..scheduleTitle = 'Focus Session' // akan di-resolve dari schedule
      ..startedAt = _startedAt!
      ..endedAt = now
      ..actualDurationSeconds = actualDuration
      ..targetDurationSeconds = state.totalSeconds
      ..completionRate = actualDuration / state.totalSeconds
      ..isCompleted = true
      ..sessionDate = DateTime(now.year, now.month, now.day);

    final sessionRepo = _ref.read(sessionRepositoryProvider);
    await sessionRepo.logSession(session);
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }
}
```

---

## 3. Background Persistence Strategy

### Problem
`Timer.periodic` berhenti saat app di-minimize ke background di Android/iOS.

### Solution: Elapsed Time Calculation

```dart
/// Saat app kembali ke foreground:
/// 1. Hitung waktu yang sudah berlalu sejak _startedAt
/// 2. Update remainingSeconds = totalSeconds - elapsed
/// 3. Jika elapsed >= totalSeconds → mark as completed
///
/// Implementasi via WidgetsBindingObserver:
class _FocusTimerScreenState extends ConsumerState<FocusTimerScreen>
    with WidgetsBindingObserver {

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // Recalculate remaining time based on elapsed
      ref.read(timerStateProvider.notifier).syncWithElapsedTime();
    }
  }
}
```

---

## 4. Timer State Flow

```
      ┌─── start() ───┐
      │                ▼
   [IDLE] ──────► [RUNNING] ◄─── resume()
                    │    │
            pause() │    │ remainingSeconds == 0
                    ▼    ▼
               [PAUSED] [COMPLETED]
                    │        │
            reset() │        │ reset()
                    ▼        ▼
                  [IDLE]   [IDLE]
```

---

## 5. Smart Duration Sync

| Entry Point | Timer Duration Source |
|-------------|---------------------|
| Schedule card "Start" button | `schedule.durationMinutes * 60` |
| Notification "Mulai Belajar" | `schedule.durationMinutes * 60` |
| Home Widget "Start" button | `schedule.durationMinutes * 60` |
| Manual (Timer tab) | User input atau default 25 min |

---

## 6. Acceptance Criteria

- [ ] `start()`: timer mulai countdown dari totalSeconds
- [ ] `startFromSchedule()`: fetch schedule, auto-fill durasi
- [ ] `pause()/resume()`: freeze dan resume akurat
- [ ] `reset()`: kembali ke idle state
- [ ] Timer berjalan di background (elapsed time recalculation)
- [ ] Session log tersimpan otomatis saat `completed`
- [ ] `completionRate` dihitung akurat (actualDuration / targetDuration)
- [ ] Tidak ada memory leak — `Timer` di-cancel di `dispose()`
