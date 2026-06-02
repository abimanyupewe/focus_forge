import 'package:isar_community/isar.dart';

part 'task_model.g.dart';

/// Isar collection untuk menyimpan data tugas/task harian.
///
/// Berbeda dengan [ScheduleModel], task ini adalah to-do item sederhana
/// yang tidak wajib memiliki waktu mulai/selesai yang mengikat.
@collection
class TaskModel {
  Id id = Isar.autoIncrement;

  /// Unique identifier (UUID v4) untuk referensi cross-module
  @Index(unique: true)
  late String uid;

  /// Nama tugas / task
  late String title;

  /// Deskripsi opsional tugas
  String? description;

  /// Status apakah tugas sudah selesai atau belum
  @Index()
  bool isCompleted = false;

  /// Warna kategori untuk visualisasi estetika
  int colorValue = 0xFF2B6CB0;

  /// Tanggal pembuatan tugas
  late DateTime createdAt;

  /// Tanggal penyelesaian tugas (jika sudah selesai)
  DateTime? completedAt;

  /// Salin objek TaskModel dengan beberapa properti yang diperbarui.
  TaskModel copyWith({
    Id? id,
    String? uid,
    String? title,
    String? description,
    bool? isCompleted,
    int? colorValue,
    DateTime? createdAt,
    DateTime? completedAt,
  }) {
    final task = TaskModel()
      ..id = id ?? this.id
      ..uid = uid ?? this.uid
      ..title = title ?? this.title
      ..description = description ?? this.description
      ..isCompleted = isCompleted ?? this.isCompleted
      ..colorValue = colorValue ?? this.colorValue
      ..createdAt = createdAt ?? this.createdAt
      ..completedAt = completedAt ?? this.completedAt;
    return task;
  }
}
