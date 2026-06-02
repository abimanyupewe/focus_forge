import 'package:isar_community/isar.dart';

part 'schedule_model.g.dart';

/// Isar collection untuk menyimpan data jadwal belajar/aktifitas.
///
/// Mendukung time-boxing dengan field [startTime] dan [endTime].
@collection
class ScheduleModel {
  Id id = Isar.autoIncrement;

  /// Unique identifier (UUID v4) untuk referensi cross-module
  @Index(unique: true)
  late String uid;

  /// Nama aktivitas (e.g., "Belajar Golang", "Membaca Buku")
  late String title;

  /// Deskripsi opsional untuk detail aktivitas
  String? description;

  /// Ikon kategori (stored sebagai codePoint integer)
  int iconCodePoint = 0xE0B0; // Default: book icon

  /// Warna kategori (stored sebagai hex integer, e.g., 0xFF2B6CB0)
  int colorValue = 0xFF2B6CB0;

  /// === TIME-BOXING FIELDS ===

  /// Jam mulai (format DateTime, hanya jam:menit yang relevan)
  @Index()
  late DateTime startTime;

  /// Jam selesai
  late DateTime endTime;

  /// Durasi target dalam menit (auto-calculated dari startTime & endTime)
  late int durationMinutes;

  /// === SCHEDULING FIELDS ===

  /// Hari-hari aktif dalam seminggu (0=Senin, 6=Minggu)
  /// Stored sebagai list of integers untuk fleksibilitas
  late List<int> activeDays;

  /// Tanggal pembuatan jadwal
  late DateTime createdAt;

  /// Tanggal terakhir dimodifikasi
  late DateTime updatedAt;

  /// Status aktif/non-aktif jadwal
  bool isActive = true;

  /// Apakah wrap-up alarm diaktifkan
  bool wrapUpAlarmEnabled = true;

  /// Durasi wrap-up alarm sebelum endTime (dalam menit)
  int wrapUpMinutesBefore = 5;
}
