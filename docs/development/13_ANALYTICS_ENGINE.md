# 📈 13 — Analytics Engine

> **Fase:** 2 (The Logic Brain)  
> **Prioritas:** 🟡 High  
> **Estimasi:** 2-3 jam  
> **Dependensi:** `02_DATABASE_SETUP.md`

---

## 1. Deskripsi

Logic layer untuk kalkulasi data analytics — streak calculation, heatmap data aggregation, dan session statistics. Data bersumber dari `SessionModel` di Isar.

---

## 2. AnalyticsService

```dart
/// lib/features/analytics/domain/analytics_service.dart
class AnalyticsService {
  final SessionRepository _sessionRepo;

  AnalyticsService(this._sessionRepo);

  /// Mengkalkulasi semua metrik analytics dalam satu call.
  Future<AnalyticsData> getAnalytics() async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    // Heatmap: 84 hari terakhir (12 minggu)
    final heatmapStart = today.subtract(const Duration(days: 83));
    final heatmapData = await _sessionRepo.getDailyDurations(
      heatmapStart, today.add(const Duration(days: 1)),
    );

    // Streak calculation
    final streak = await _calculateStreak(today);

    // Aggregated stats (30 hari terakhir)
    final thirtyDaysAgo = today.subtract(const Duration(days: 30));
    final recentSessions = await _sessionRepo.getSessionsInRange(
      thirtyDaysAgo, today.add(const Duration(days: 1)),
    );

    final totalSeconds = recentSessions.fold<int>(
      0, (sum, s) => sum + s.actualDurationSeconds,
    );
    final completedCount = recentSessions.where((s) => s.isCompleted).length;

    // Today's sessions
    final todaySessions = await _sessionRepo.getSessionsByDate(today);

    return AnalyticsData(
      currentStreak: streak,
      totalHours: totalSeconds / 3600.0,
      totalSessions: recentSessions.length,
      avgHoursPerDay: (totalSeconds / 3600.0) / 30,
      completionRate: recentSessions.isEmpty
          ? 0.0
          : completedCount / recentSessions.length,
      heatmapData: heatmapData,
      todaySessions: todaySessions,
    );
  }

  /// Streak: hitung hari berturut-turut dari hari ini ke belakang
  /// yang memiliki minimal 1 completed session.
  Future<int> _calculateStreak(DateTime today) async {
    int streak = 0;
    DateTime checkDate = today;

    while (true) {
      final sessions = await _sessionRepo.getSessionsByDate(checkDate);
      final hasCompleted = sessions.any((s) => s.isCompleted);

      if (!hasCompleted) {
        // Jika hari ini belum ada sesi, cek kemarin dulu
        if (checkDate == today) {
          checkDate = checkDate.subtract(const Duration(days: 1));
          continue;
        }
        break;
      }

      streak++;
      checkDate = checkDate.subtract(const Duration(days: 1));
    }

    return streak;
  }
}
```

---

## 3. Heatmap Data Structure

```dart
/// Map<DateTime, int> — date (normalized midnight) → total seconds
/// Contoh:
/// {
///   2026-05-01: 3600,   // 1 jam  → Level 2
///   2026-05-02: 7200,   // 2 jam  → Level 3
///   2026-05-03: 0,      // 0      → Level 0
///   2026-05-04: 10800,  // 3 jam  → Level 4
/// }

/// Konversi seconds ke heatmap level (0-4)
int getHeatmapLevel(int totalSeconds) {
  final minutes = totalSeconds ~/ 60;
  if (minutes == 0) return 0;
  if (minutes <= 30) return 1;
  if (minutes <= 60) return 2;
  if (minutes <= 120) return 3;
  return 4;
}
```

---

## 4. AnalyticsData Model

```dart
class AnalyticsData {
  final int currentStreak;
  final double totalHours;
  final int totalSessions;
  final double avgHoursPerDay;
  final double completionRate;       // 0.0 - 1.0
  final Map<DateTime, int> heatmapData;
  final List<SessionModel> todaySessions;
}
```

---

## 5. Acceptance Criteria

- [ ] Streak calculation akurat — hari berturut-turut dengan sesi completed
- [ ] Heatmap data mencakup 84 hari terakhir
- [ ] Heatmap level mapping benar (0-4 berdasarkan durasi)
- [ ] Total hours, total sessions, avg/day akurat (30 hari terakhir)
- [ ] Completion rate dihitung dari completed / total sessions
- [ ] Today's sessions menampilkan sesi hari ini
