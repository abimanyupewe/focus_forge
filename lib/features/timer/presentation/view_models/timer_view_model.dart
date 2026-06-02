import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/session_model.dart';
import '../../data/repositories/session_repository.dart';
import '../../../schedule/data/models/schedule_model.dart';
import '../../../../core/services/notification_service.dart';

/// Status operasional dari Focus Timer.
enum TimerStatus { idle, running, paused }

/// State penampung data runtime Focus Timer.
class TimerState {
  final int remainingSeconds;
  final int totalSeconds;
  final TimerStatus status;
  final ScheduleModel? currentSchedule;

  TimerState({
    this.remainingSeconds = 1500, // 25 Menit Pomodoro standar
    this.totalSeconds = 1500,
    this.status = TimerStatus.idle,
    this.currentSchedule,
  });

  TimerState copyWith({
    int? remainingSeconds,
    int? totalSeconds,
    TimerStatus? status,
    ScheduleModel? currentSchedule,
  }) {
    return TimerState(
      remainingSeconds: remainingSeconds ?? this.remainingSeconds,
      totalSeconds: totalSeconds ?? this.totalSeconds,
      status: status ?? this.status,
      currentSchedule: currentSchedule ?? this.currentSchedule,
    );
  }
}

/// Notifier modern Riverpod untuk menangani status dan logika sinkronisasi hitung mundur timer.
class TimerNotifier extends Notifier<TimerState> {
  late final SessionRepository _sessionRepo;
  Timer? _ticker;

  @override
  TimerState build() {
    _sessionRepo = ref.watch(sessionRepositoryProvider);

    // Otomatis batalkan timer ketika provider dibuang (garbage collection)
    ref.onDispose(() {
      _ticker?.cancel();
      NotificationService.dismissTimerNotification();
    });

    return TimerState();
  }

  /// Mengatur target durasi timer, mensinkronkan jadwal jika tersedia.
  void setDuration(int seconds, {ScheduleModel? schedule}) {
    _ticker?.cancel();
    state = TimerState(
      remainingSeconds: seconds,
      totalSeconds: seconds,
      status: TimerStatus.idle,
      currentSchedule: schedule,
    );
  }

  /// Memulai hitung mundur timer (mendukung background stability).
  void startTimer() {
    if (state.status == TimerStatus.running) return;

    _ticker?.cancel();
    state = state.copyWith(status: TimerStatus.running);

    // Kirim notifikasi pertama kali timer dijalankan
    final initialMinutes = (state.remainingSeconds ~/ 60).toString().padLeft(2, '0');
    final initialSeconds = (state.remainingSeconds % 60).toString().padLeft(2, '0');
    NotificationService.showTimerNotification(
      title: '🚀 Sesi Fokus Aktif!',
      body: 'Sisa waktu: $initialMinutes:$initialSeconds untuk "${state.currentSchedule?.title ?? 'Sesi Fokus Mandiri'}"',
      remainingSeconds: state.remainingSeconds,
    );

    _ticker = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (state.remainingSeconds > 0) {
        state = state.copyWith(remainingSeconds: state.remainingSeconds - 1);

        // Update status notifikasi HP setiap detik agar real-time (MM:SS)
        final minutes = (state.remainingSeconds ~/ 60).toString().padLeft(2, '0');
        final seconds = (state.remainingSeconds % 60).toString().padLeft(2, '0');
        NotificationService.showTimerNotification(
          title: '⚡ Sedang Fokus...',
          body: 'Sisa waktu: $minutes:$seconds untuk "${state.currentSchedule?.title ?? 'Sesi Fokus Mandiri'}"',
          remainingSeconds: state.remainingSeconds,
        );
      } else {
        completeTimer();
      }
    });
  }

  /// Menghentikan sementara timer fokus.
  void pauseTimer() {
    _ticker?.cancel();
    state = state.copyWith(status: TimerStatus.paused);
    final minutes = (state.remainingSeconds ~/ 60).toString().padLeft(2, '0');
    final seconds = (state.remainingSeconds % 60).toString().padLeft(2, '0');
    NotificationService.showTimerNotification(
      title: '⏸️ Sesi Fokus Dijeda',
      body: 'Sesi "${state.currentSchedule?.title ?? 'Sesi Fokus Mandiri'}" ditangguhkan pada $minutes:$seconds.',
      isPaused: true,
      remainingSeconds: state.remainingSeconds,
    );
  }

  /// Melanjutkan jalannya hitung mundur timer.
  void resumeTimer() {
    startTimer();
  }

  /// Mereset timer ke durasi awal.
  void resetTimer() {
    _ticker?.cancel();
    state = state.copyWith(
      remainingSeconds: state.totalSeconds,
      status: TimerStatus.idle,
    );
    NotificationService.dismissTimerNotification();
  }

  /// Menyelesaikan sesi belajar secara asinkron dan melog data ke Isar.
  Future<void> completeTimer() async {
    _ticker?.cancel();
    
    final actualDuration = state.totalSeconds - state.remainingSeconds;
    final current = state.currentSchedule;
    if (actualDuration > 0) {
      final session = SessionModel()
        ..scheduleUid = current?.uid ?? "focus_forge_direct"
        ..scheduleTitle = current?.title ?? "Fokus Belajar"
        ..sessionDate = DateTime.utc(DateTime.now().year, DateTime.now().month, DateTime.now().day)
        ..startedAt = DateTime.now().subtract(Duration(seconds: actualDuration))
        ..endedAt = DateTime.now()
        ..targetDurationSeconds = state.totalSeconds
        ..actualDurationSeconds = actualDuration
        ..completionRate = state.totalSeconds > 0 ? actualDuration / state.totalSeconds : 0.0
        ..isCompleted = true;

      await _sessionRepo.logSession(session);
    }

    state = state.copyWith(
      remainingSeconds: 0,
      status: TimerStatus.idle,
    );

    // Hapus notifikasi timer dan tunjukkan notifikasi sukses belajar
    await NotificationService.dismissTimerNotification();
    if (actualDuration > 0) {
      await NotificationService.showInstantNotification(
        id: 1000,
        title: 'Sesi Fokus Selesai!',
        body: 'Selamat! Sesi "${current?.title ?? 'Fokus Belajar'}" berhasil diselesaikan.',
      );
    }
  }
}

/// Provider global untuk mengekspos TimerNotifier.
final timerViewModelProvider =
    NotifierProvider<TimerNotifier, TimerState>(() {
  return TimerNotifier();
});

