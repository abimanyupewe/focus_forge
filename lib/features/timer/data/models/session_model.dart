import 'package:isar_community/isar.dart';

part 'session_model.g.dart';

/// Isar collection untuk menyimpan riwayat sesi focus timer.
///
/// Data ini digunakan oleh Analytics module untuk heatmap & streak.
@collection
class SessionModel {
  Id id = Isar.autoIncrement;

  /// Reference ke ScheduleModel.uid
  @Index()
  late String scheduleUid;

  /// Judul schedule (denormalized untuk performa query)
  late String scheduleTitle;

  /// Waktu sesi dimulai
  @Index()
  late DateTime startedAt;

  /// Waktu sesi berakhir
  late DateTime endedAt;

  /// Durasi aktual sesi dalam detik
  late int actualDurationSeconds;

  /// Durasi target awal dalam detik
  late int targetDurationSeconds;

  /// Persentase penyelesaian (0.0 - 1.0)
  late double completionRate;

  /// Apakah sesi diselesaikan secara penuh (tanpa cancel)
  bool isCompleted = false;

  /// Tanggal sesi (normalized ke midnight, untuk grouping heatmap)
  @Index()
  late DateTime sessionDate;
}
