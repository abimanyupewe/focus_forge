# 🗄️ 02 — Database Setup (Isar)

> **Fase:** 1 (Core Foundation)  
> **Prioritas:** 🔴 Critical  
> **Estimasi:** 3-4 jam  
> **Dependensi:** `01_PROJECT_SETUP.md`

---

## 1. Deskripsi

Dokumen ini mendefinisikan seluruh aspek *persistence layer* FocusForge menggunakan **Isar Database** — dari inisialisasi instance, schema definitions (collections), hingga implementasi **Repository Pattern** untuk operasi CRUD.

> **Kenapa Isar?**  
> Isar dipilih karena performanya yang sangat cepat pada operasi read/write lokal, dukungan query berbasis waktu (krusial untuk scheduling), full-text search index, serta zero-config tanpa server backend.

---

## 2. Database Service (Singleton)

```dart
/// lib/services/database_service.dart
///
/// Singleton service untuk menginisialisasi dan mengekspos
/// instance Isar Database ke seluruh aplikasi.
class DatabaseService {
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
      ],
      directory: dir.path,
      name: 'focus_forge_db',
    );
    return _instance;
  }

  static Isar get instance => _instance;
}
```

### Riverpod Provider

```dart
/// Global provider yang mengekspos Isar instance.
/// Di-override di ProviderScope (main.dart) dengan instance aktual.
final databaseProvider = Provider<Isar>((ref) {
  throw UnimplementedError('Isar must be initialized in main()');
});
```

---

## 3. Schema Definitions

### 3.1 ScheduleModel (Jadwal Aktivitas)

```dart
/// lib/features/schedule/data/models/schedule_model.dart
///
/// Isar collection untuk menyimpan data jadwal belajar.
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
```

### 3.2 SessionModel (Riwayat Sesi Belajar)

```dart
/// lib/features/timer/data/models/session_model.dart
///
/// Isar collection untuk menyimpan riwayat sesi focus timer.
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
```

---

## 4. Repository Pattern

### 4.1 ScheduleRepository

```dart
/// lib/features/schedule/data/repositories/schedule_repository.dart
///
/// Abstraksi CRUD operations untuk [ScheduleModel].
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
```

### 4.2 SessionRepository

```dart
/// lib/features/timer/data/repositories/session_repository.dart
///
/// CRUD operations untuk riwayat sesi focus timer.
class SessionRepository {
  final Isar _isar;

  SessionRepository(this._isar);

  /// Menyimpan log sesi baru setelah timer selesai.
  Future<void> logSession(SessionModel session) async {
    await _isar.writeTxn(() => _isar.sessionModels.put(session));
  }

  /// Mengambil semua sesi dalam rentang tanggal tertentu.
  /// Digunakan oleh Analytics untuk heatmap data.
  Future<List<SessionModel>> getSessionsInRange(
    DateTime start,
    DateTime end,
  ) async {
    return _isar.sessionModels
        .filter()
        .sessionDateBetween(start, end)
        .sortByStartedAt()
        .findAll();
  }

  /// Mengambil semua sesi pada tanggal spesifik.
  Future<List<SessionModel>> getSessionsByDate(DateTime date) async {
    final dayStart = DateTime(date.year, date.month, date.day);
    final dayEnd = dayStart.add(const Duration(days: 1));
    return _isar.sessionModels
        .filter()
        .sessionDateBetween(dayStart, dayEnd)
        .findAll();
  }

  /// Menghitung total durasi belajar (dalam detik) per hari.
  /// Return: Map<DateTime(normalized), int(totalSeconds)>
  Future<Map<DateTime, int>> getDailyDurations(
    DateTime start,
    DateTime end,
  ) async {
    final sessions = await getSessionsInRange(start, end);
    final Map<DateTime, int> result = {};
    for (final s in sessions) {
      final key = DateTime(
        s.sessionDate.year,
        s.sessionDate.month,
        s.sessionDate.day,
      );
      result[key] = (result[key] ?? 0) + s.actualDurationSeconds;
    }
    return result;
  }
}
```

---

## 5. Riverpod Providers (Database Layer)

```dart
/// Repository providers — inject Isar instance dari databaseProvider
final scheduleRepositoryProvider = Provider<ScheduleRepository>((ref) {
  return ScheduleRepository(ref.watch(databaseProvider));
});

final sessionRepositoryProvider = Provider<SessionRepository>((ref) {
  return SessionRepository(ref.watch(databaseProvider));
});
```

---

## 6. Code Generation

Setelah schema didefinisikan, jalankan:

```bash
dart run build_runner build --delete-conflicting-outputs
```

Output yang dihasilkan:
- `schedule_model.g.dart` — Isar schema adapter
- `session_model.g.dart` — Isar schema adapter

---

## 7. Acceptance Criteria

- [ ] `DatabaseService.initialize()` berhasil membuka Isar instance tanpa exception
- [ ] `ScheduleModel` dan `SessionModel` ter-generate schema tanpa error
- [ ] `ScheduleRepository.create()` berhasil menyimpan dan `getAllActive()` mengembalikan data
- [ ] `SessionRepository.logSession()` berhasil menyimpan riwayat sesi
- [ ] `getDailyDurations()` mengembalikan aggregasi yang akurat
- [ ] `watchChanges()` stream mem-fire event saat data berubah
