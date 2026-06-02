import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar_community/isar.dart';
import '../../../../core/services/database_service.dart';
import '../models/task_model.dart';

/// Abstraksi CRUD operations untuk [TaskModel].
class TaskRepository {
  final Isar _isar;

  TaskRepository(this._isar);

  /// Mengambil semua task yang belum selesai dan sudah selesai, sorted by isCompleted asc, kemudian createdAt desc.
  Future<List<TaskModel>> getAll() async {
    return _isar.taskModels
        .filter()
        .idGreaterThan(0)
        .sortByIsCompleted()
        .thenByCreatedAtDesc()
        .findAll();
  }

  /// Membuat task baru.
  Future<void> create(TaskModel task) async {
    task.createdAt = DateTime.now();
    await _isar.writeTxn(() => _isar.taskModels.put(task));
  }

  /// Update task existing.
  Future<void> update(TaskModel task) async {
    await _isar.writeTxn(() => _isar.taskModels.put(task));
  }

  /// Menghapus task permanen.
  Future<bool> delete(int id) async {
    return _isar.writeTxn(() => _isar.taskModels.delete(id));
  }

  /// Stream perubahan data untuk reactive UI updates
  Stream<void> watchChanges() {
    return _isar.taskModels.watchLazy();
  }
}

/// Provider untuk TaskRepository.
final taskRepositoryProvider = Provider<TaskRepository>((ref) {
  return TaskRepository(ref.watch(databaseProvider));
});
