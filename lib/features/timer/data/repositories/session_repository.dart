import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar_community/isar.dart';
import '../../../../core/services/database_service.dart';
import '../models/session_model.dart';

/// CRUD operations untuk riwayat sesi focus timer.
class SessionRepository {
  final Isar _isar;

  SessionRepository(this._isar);

  /// Menyimpan log sesi baru setelah timer selesai.
  Future<void> logSession(SessionModel session) async {
    await _isar.writeTxn(() => _isar.sessionModels.put(session));
  }

  /// Menghapus sesi berdasarkan ID.
  Future<void> deleteSession(int id) async {
    await _isar.writeTxn(() => _isar.sessionModels.delete(id));
  }

  /// Memantau perubahan database Isar pada tabel sesi secara real-time.
  Stream<void> watchChanges() {
    return _isar.sessionModels.watchLazy();
  }

  /// Mengambil semua sesi dalam rentang tanggal tertentu.
  /// Digunakan oleh Analytics untuk heatmap data.
  Future<List<SessionModel>> getSessionsInRange(
    DateTime start,
    DateTime end,
  ) async {
    final utcStart = DateTime.utc(start.year, start.month, start.day);
    final utcEnd = DateTime.utc(end.year, end.month, end.day, 23, 59, 59);
    return _isar.sessionModels
        .filter()
        .sessionDateBetween(utcStart, utcEnd)
        .sortByStartedAt()
        .findAll();
  }

  /// Mengambil semua sesi pada tanggal spesifik.
  Future<List<SessionModel>> getSessionsByDate(DateTime date) async {
    final dayStart = DateTime.utc(date.year, date.month, date.day);
    final dayEnd = dayStart.add(const Duration(days: 1));
    return _isar.sessionModels
        .filter()
        .sessionDateBetween(dayStart, dayEnd)
        .findAll();
  }

  /// Menghitung total durasi belajar (dalam detik) per hari.
  /// Return: Map of DateTime (normalized) to int (totalSeconds)
  Future<Map<DateTime, int>> getDailyDurations(
    DateTime start,
    DateTime end,
  ) async {
    final sessions = await getSessionsInRange(start, end);
    final Map<DateTime, int> result = {};
    for (final s in sessions) {
      final utcDate = s.sessionDate.toUtc();
      final key = DateTime(
        utcDate.year,
        utcDate.month,
        utcDate.day,
      );
      result[key] = (result[key] ?? 0) + s.actualDurationSeconds;
    }
    return result;
  }
}

/// Provider untuk SessionRepository.
final sessionRepositoryProvider = Provider<SessionRepository>((ref) {
  return SessionRepository(ref.watch(databaseProvider));
});
