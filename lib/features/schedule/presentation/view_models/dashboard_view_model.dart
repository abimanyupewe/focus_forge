import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/theme_provider.dart';
import '../../../../core/services/notification_service.dart';
import '../../../../core/services/home_widget_service.dart';
import '../../data/models/schedule_model.dart';
import '../../data/models/task_model.dart';
import '../../data/repositories/schedule_repository.dart';
import '../../data/repositories/task_repository.dart';
import '../../../timer/data/repositories/session_repository.dart';
import '../../../timer/data/models/session_model.dart';

/// State untuk halaman utama Dashboard.
class DashboardState {
  final List<ScheduleModel> schedules;
  final List<TaskModel> tasks; // List tugas harian
  final Map<DateTime, int> dailyDurations; // Data heatmap (DateTime -> totalSeconds)
  final Set<String> completedScheduleUids; // UIDs jadwal yang sudah dicentang/selesai hari ini
  final int streakDays;
  final bool isLoading;

  DashboardState({
    this.schedules = const [],
    this.tasks = const [],
    this.dailyDurations = const {},
    this.completedScheduleUids = const {},
    this.streakDays = 0,
    this.isLoading = false,
  });

  DashboardState copyWith({
    List<ScheduleModel>? schedules,
    List<TaskModel>? tasks,
    Map<DateTime, int>? dailyDurations,
    Set<String>? completedScheduleUids,
    int? streakDays,
    bool? isLoading,
  }) {
    return DashboardState(
      schedules: schedules ?? this.schedules,
      tasks: tasks ?? this.tasks,
      dailyDurations: dailyDurations ?? this.dailyDurations,
      completedScheduleUids: completedScheduleUids ?? this.completedScheduleUids,
      streakDays: streakDays ?? this.streakDays,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

/// Notifier modern Riverpod untuk menangani logika interaksi Dashboard.
class DashboardNotifier extends Notifier<DashboardState> {
  late final ScheduleRepository _scheduleRepo;
  late final SessionRepository _sessionRepo;
  late final TaskRepository _taskRepo;

  @override
  DashboardState build() {
    _scheduleRepo = ref.watch(scheduleRepositoryProvider);
    _sessionRepo = ref.watch(sessionRepositoryProvider);
    _taskRepo = ref.watch(taskRepositoryProvider);

    // Memuat data pertama kali secara asinkron menggunakan Future.microtask
    Future.microtask(() => loadData());

    final scheduleSubscription = _scheduleRepo.watchChanges().listen((_) {
      loadData();
    });

    final taskSubscription = _taskRepo.watchChanges().listen((_) {
      loadData();
    });

    final sessionSubscription = _sessionRepo.watchChanges().listen((_) {
      loadData();
    });

    ref.onDispose(() {
      scheduleSubscription.cancel();
      taskSubscription.cancel();
      sessionSubscription.cancel();
    });

    return DashboardState(isLoading: true);
  }

  /// Memuat data dari repositori lokal secara asinkron.
  Future<void> loadData() async {
    state = state.copyWith(isLoading: true);
    try {
      final today = DateTime.now();
      // Isar getByDayOfWeek: weekday mengembalikan 1=Senin...7=Minggu.
      // Di repositori: 0=Senin...6=Minggu, sehingga kita kurangi 1.
      final activeSchedules = await _scheduleRepo.getByDayOfWeek(today.weekday - 1);
      final allTasks = await _taskRepo.getAll();

      // Memfilter daftar tugas agar hanya menyertakan tugas yang dibuat hari ini saja
      final tasksToday = allTasks.where((t) {
        return t.createdAt.year == today.year &&
               t.createdAt.month == today.month &&
               t.createdAt.day == today.day;
      }).toList();

      // Memuat riwayat sesi 365 hari terakhir untuk visualisasi heatmap komprehensif & filter
      final end = DateTime(today.year, today.month, today.day, 23, 59, 59);
      final start = DateTime(today.year - 1, today.month, today.day);
      final dailyDurations = Map<DateTime, int>.from(await _sessionRepo.getDailyDurations(start, end));

      // Tambahkan kontribusi tugas (task) yang diselesaikan ke heatmap
      for (final task in allTasks) {
        if (task.isCompleted) {
          final compDate = task.completedAt ?? task.createdAt;
          if (compDate.isAfter(start) && compDate.isBefore(end)) {
            final key = DateTime(compDate.year, compDate.month, compDate.day);
            // Tambahkan 15 menit (900 detik) untuk setiap tugas yang diselesaikan agar heatmap berubah warna
            dailyDurations[key] = (dailyDurations[key] ?? 0) + 900;
          }
        }
      }

      // Memuat riwayat sesi hari ini untuk menandai status selesai
      final todaySessions = await _sessionRepo.getSessionsByDate(today);
      final completedScheduleUids = todaySessions
          .where((s) => s.isCompleted)
          .map((s) => s.scheduleUid)
          .toSet();

      // Kalkulasi streak berturut-turut
      final streak = _calculateStreak(dailyDurations);

      state = state.copyWith(
        schedules: activeSchedules,
        tasks: tasksToday,
        dailyDurations: dailyDurations,
        completedScheduleUids: completedScheduleUids,
        streakDays: streak,
        isLoading: false,
      );

      // Cari jadwal aktif berikutnya untuk ditampilkan di Home Widget
      ScheduleModel? nextSchedule;
      final now = DateTime.now();
      for (final s in activeSchedules) {
        final isAfterNow = s.startTime.hour > now.hour || 
            (s.startTime.hour == now.hour && s.startTime.minute > now.minute);
        if (s.isActive && isAfterNow) {
          nextSchedule = s;
          break;
        }
      }
      if (nextSchedule == null && activeSchedules.isNotEmpty) {
        final activeOnes = activeSchedules.where((s) => s.isActive).toList();
        if (activeOnes.isNotEmpty) {
          nextSchedule = activeOnes.first;
        }
      }

      // Perbarui Home Widget secara asinkron
      final themeMode = ref.read(themeModeProvider);
      final isDark = themeMode == ThemeMode.dark ||
          (themeMode == ThemeMode.system &&
              WidgetsBinding.instance.platformDispatcher.platformBrightness == Brightness.dark);

      HomeWidgetService.updateWidgetData(
        streak: streak,
        nextSchedule: nextSchedule,
        todayTasks: tasksToday,
        isDark: isDark,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false);
    }
  }

  /// Menghitung durasi streak harian berturut-turut pengguna.
  int _calculateStreak(Map<DateTime, int> dailyDurations) {
    int streak = 0;
    DateTime checkDate = DateTime.now();
    final todayNormalized = DateTime(checkDate.year, checkDate.month, checkDate.day);

    // Jika hari ini belum belajar, periksa mulai kemarin
    final todayDuration = dailyDurations[todayNormalized] ?? 0;
    if (todayDuration == 0) {
      checkDate = checkDate.subtract(const Duration(days: 1));
    }

    while (true) {
      final normalizedDate = DateTime(checkDate.year, checkDate.month, checkDate.day);
      final duration = dailyDurations[normalizedDate] ?? 0;

      if (duration > 0) {
        streak++;
        checkDate = checkDate.subtract(const Duration(days: 1));
      } else {
        break;
      }
    }
    return streak;
  }

  /// Mengaktifkan atau menonaktifkan status alarm jadwal.
  Future<void> toggleSchedule(ScheduleModel schedule) async {
    schedule.isActive = !schedule.isActive;
    await _scheduleRepo.update(schedule);
    
    if (schedule.isActive) {
      await NotificationService.registerScheduleAlarms(schedule);
    } else {
      await NotificationService.cancelScheduleAlarms(schedule.uid);
    }
    
    loadData();
  }

  /// Menghapus jadwal dengan metode Soft Delete (data tersimpan di DB untuk analitik).
  Future<void> deleteSchedule(int id) async {
    try {
      final schedule = state.schedules.firstWhere((element) => element.id == id);
      await NotificationService.cancelScheduleAlarms(schedule.uid);
    } catch (_) {
      // Abaikan jika jadwal tidak ditemukan di list aktif
    }
    await _scheduleRepo.softDelete(id);
    loadData();
  }

  /// Menambahkan jadwal belajar mandiri baru.
  Future<void> createSchedule({
    required String title,
    required String? description,
    required DateTime startTime,
    required DateTime endTime,
    required List<int> activeDays,
    required int colorValue,
  }) async {
    final schedule = ScheduleModel()
      ..uid = DateTime.now().millisecondsSinceEpoch.toString()
      ..title = _stripEmojis(title)
      ..description = description != null ? _stripEmojis(description) : null
      ..startTime = startTime
      ..endTime = endTime
      ..activeDays = activeDays
      ..colorValue = colorValue
      ..isActive = true
      ..wrapUpAlarmEnabled = true
      ..wrapUpMinutesBefore = 5;

    await _scheduleRepo.create(schedule);
    await NotificationService.registerScheduleAlarms(schedule);
    loadData();
  }

  /// Mengupdate jadwal belajar mandiri yang sudah ada.
  Future<void> updateSchedule({
    required int id,
    required String uid,
    required String title,
    required String? description,
    required DateTime startTime,
    required DateTime endTime,
    required List<int> activeDays,
    required int colorValue,
    required bool isActive,
    required bool wrapUpAlarmEnabled,
    required int wrapUpMinutesBefore,
  }) async {
    final schedule = ScheduleModel()
      ..id = id
      ..uid = uid
      ..title = _stripEmojis(title)
      ..description = description != null ? _stripEmojis(description) : null
      ..startTime = startTime
      ..endTime = endTime
      ..activeDays = activeDays
      ..colorValue = colorValue
      ..isActive = isActive
      ..wrapUpAlarmEnabled = wrapUpAlarmEnabled
      ..wrapUpMinutesBefore = wrapUpMinutesBefore;

    await _scheduleRepo.update(schedule);

    if (schedule.isActive) {
      await NotificationService.registerScheduleAlarms(schedule);
    } else {
      await NotificationService.cancelScheduleAlarms(schedule.uid);
    }

    loadData();
  }

  /// Centang/selesaikan jadwal sebagai task harian.
  /// Ini akan menambahkan sesi penuh ke riwayat sesi dan mengupdate heatmap.
  Future<void> toggleCompleteSchedule(ScheduleModel schedule) async {
    final now = DateTime.now();
    final todayNormalized = DateTime.utc(now.year, now.month, now.day);
    
    // Cari apakah sudah ada sesi selesai hari ini untuk schedule ini
    final todaySessions = await _sessionRepo.getSessionsByDate(todayNormalized);
    final existingSession = todaySessions.firstWhere(
      (s) => s.scheduleUid == schedule.uid && s.isCompleted,
      orElse: () => SessionModel()..id = -1,
    );

    if (existingSession.id != -1) {
      // Uncheck: Hapus sesi selesai hari ini
      await _sessionRepo.deleteSession(existingSession.id);
    } else {
      // Check: Tambahkan sesi selesai hari ini
      final durationSec = schedule.durationMinutes > 0 ? schedule.durationMinutes * 60 : 1500;
      final session = SessionModel()
        ..scheduleUid = schedule.uid
        ..scheduleTitle = schedule.title
        ..sessionDate = todayNormalized
        ..startedAt = now.subtract(Duration(seconds: durationSec))
        ..endedAt = now
        ..targetDurationSeconds = durationSec
        ..actualDurationSeconds = durationSec
        ..completionRate = 1.0
        ..isCompleted = true;
      await _sessionRepo.logSession(session);
    }
    
    // Refresh data
    await loadData();
  }

  /// Menambahkan tugas/task harian baru.
  Future<void> createTask({
    required String title,
    required String? description,
    required int colorValue,
    DateTime? createdAt,
  }) async {
    final task = TaskModel()
      ..uid = DateTime.now().millisecondsSinceEpoch.toString()
      ..title = _stripEmojis(title)
      ..description = description != null ? _stripEmojis(description) : null
      ..colorValue = colorValue
      ..isCompleted = false
      ..createdAt = createdAt ?? DateTime.now();

    await _taskRepo.create(task);
    await loadData();
  }

  /// Mengupdate detail tugas/task yang sudah ada.
  Future<void> updateTask(TaskModel task) async {
    task.title = _stripEmojis(task.title);
    if (task.description != null) {
      task.description = _stripEmojis(task.description!);
    }
    await _taskRepo.update(task);
    await loadData();
  }

  /// Menghapus tugas/task secara permanen dari Isar.
  Future<void> deleteTask(int id) async {
    await _taskRepo.delete(id);
    await loadData();
  }

  /// Menandai selesai atau membatalkan selesai suatu tugas.
  Future<void> toggleCompleteTask(TaskModel task) async {
    task.isCompleted = !task.isCompleted;
    task.completedAt = task.isCompleted ? DateTime.now() : null;
    await _taskRepo.update(task);
    await loadData();
  }

  /// Helper untuk membersihkan emoji dari judul dan deskripsi.
  String _stripEmojis(String text) {
    return text.replaceAll(
      RegExp(r'[\u{1F600}-\u{1F64F}\u{1F300}-\u{1F5FF}\u{1F680}-\u{1F6FF}\u{1F1E6}-\u{1F1FF}\u{2600}-\u{26FF}\u{2700}-\u{27BF}\u{FE0F}\u{1F900}-\u{1F9FF}\u{1FA00}-\u{1FAFF}]', unicode: true),
      '',
    ).trim();
  }
}

/// Provider global untuk mengekspos DashboardNotifier.
final dashboardViewModelProvider =
    NotifierProvider<DashboardNotifier, DashboardState>(() {
  return DashboardNotifier();
});
