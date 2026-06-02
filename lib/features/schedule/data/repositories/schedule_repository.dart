import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar_community/isar.dart';
import '../../../../core/services/database_service.dart';
import '../models/schedule_model.dart';

/// Abstraksi CRUD operations untuk [ScheduleModel].
///
/// Semua operasi database di-encapsulate di sini agar mudah di-test
/// dan tidak bocor ke presentation layer.
class ScheduleRepository {
  final Isar _isar;

  ScheduleRepository(this._isar);

  /// Mengambil semua jadwal aktif, sorted by startTime ascending.
  Future<List<ScheduleModel>> getAllActive() async {
    return _isar.scheduleModels
        .filter()
        .isActiveEqualTo(true)
        .sortByStartTime()
        .findAll();
  }

  /// Mengambil jadwal yang aktif pada hari tertentu.
  /// [dayOfWeek] — 0=Senin, 6=Minggu
  Future<List<ScheduleModel>> getByDayOfWeek(int dayOfWeek) async {
    return _isar.scheduleModels
        .filter()
        .isActiveEqualTo(true)
        .activeDaysElementEqualTo(dayOfWeek)
        .sortByStartTime()
        .findAll();
  }

  /// Membuat jadwal baru. Auto-calculate [durationMinutes].
  Future<void> create(ScheduleModel schedule) async {
    schedule.durationMinutes =
        schedule.endTime.difference(schedule.startTime).inMinutes;
    schedule.createdAt = DateTime.now();
    schedule.updatedAt = DateTime.now();
    await _isar.writeTxn(() => _isar.scheduleModels.put(schedule));
  }

  /// Update jadwal existing. Recalculate duration.
  Future<void> update(ScheduleModel schedule) async {
    schedule.durationMinutes =
        schedule.endTime.difference(schedule.startTime).inMinutes;
    schedule.updatedAt = DateTime.now();
    
    try {
      final _ = schedule.createdAt;
    } catch (_) {
      final existing = await _isar.scheduleModels.get(schedule.id);
      if (existing != null) {
        schedule.createdAt = existing.createdAt;
      } else {
        schedule.createdAt = DateTime.now();
      }
    }
    
    await _isar.writeTxn(() => _isar.scheduleModels.put(schedule));
  }

  /// Soft-delete: set isActive = false (data tetap tersimpan untuk analytics)
  Future<void> softDelete(int id) async {
    await _isar.writeTxn(() async {
      final schedule = await _isar.scheduleModels.get(id);
      if (schedule != null) {
        schedule.isActive = false;
        schedule.updatedAt = DateTime.now();
        await _isar.scheduleModels.put(schedule);
      }
    });
  }

  /// Hard-delete: menghapus data permanen dari database
  Future<bool> hardDelete(int id) async {
    return _isar.writeTxn(() => _isar.scheduleModels.delete(id));
  }

  /// Stream perubahan data untuk reactive UI updates
  Stream<void> watchChanges() {
    return _isar.scheduleModels.watchLazy();
  }
}

/// Provider untuk ScheduleRepository.
final scheduleRepositoryProvider = Provider<ScheduleRepository>((ref) {
  return ScheduleRepository(ref.watch(databaseProvider));
});
