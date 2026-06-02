import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar_community/isar.dart';
import 'package:path_provider/path_provider.dart';
import '../../features/schedule/data/models/schedule_model.dart';
import '../../features/schedule/data/models/task_model.dart';
import '../../features/timer/data/models/session_model.dart';

/// Singleton service untuk menginisialisasi dan mengekspos
/// instance Isar Database ke seluruh aplikasi.
class DatabaseService {
  DatabaseService._();

  static late Isar _instance;

  /// Menginisialisasi Isar dengan semua schema collections.
  ///
  /// Dipanggil sekali di `main.dart` sebelum `runApp()`.
  /// Returns [Isar] instance yang sudah siap digunakan.
  static Future<Isar> initialize() async {
    final dir = await getApplicationDocumentsDirectory();
    _instance = await Isar.open(
      [
        ScheduleModelSchema,
        SessionModelSchema,
        TaskModelSchema,
      ],
      directory: dir.path,
      name: 'focus_forge_db',
    );
    return _instance;
  }

  static Isar get instance => _instance;
}

/// Global provider yang mengekspos Isar instance.
/// Di-override di ProviderScope (main.dart) dengan instance aktual.
final databaseProvider = Provider<Isar>((ref) {
  throw UnimplementedError('Isar must be initialized in main()');
});
