# FocusForge

FocusForge adalah aplikasi manajemen aktivitas sehari-hari yang dirancang dengan arsitektur modern (MVVM), State Management Riverpod, dan database lokal Isar untuk persistensi data berkinerja tinggi. Aplikasi ini mengintegrasikan Time-Boxing untuk penjadwalan belajar mandiri, sistem alarm pintar dengan dual-trigger (alarm mulai dan alarm wrap-up), visualisasi kontribusi berbasis Heatmap, serta sinkronisasi widget Home Screen bergaya Bento Grid.

---

## Tautan Unduhan Aplikasi

Aplikasi FocusForge siap pakai dapat diunduh melalui tautan di bawah ini:

* Tautan Unduhan APK: [Google Drive - FocusForge APK](https://drive.google.com/file/d/1kEzovvFJw5eE7BEzZI8dTeJf7dw6Lezl/view?usp=drive_link)

---

## Informasi Versi

* Versi Aplikasi: 1.0.0
* Kode Build: 1 (1.0.0+1)
* Target SDK Dart: ^3.11.1
* Target SDK Flutter: Kompatibel dengan Flutter SDK 3.16.x ke atas
* Platform Target: Android (Min SDK 21, Target SDK 34)

---

## Fitur Utama

1. Rancang Jadwal Belajar Mandiri: Memungkinkan pengguna mengatur waktu belajar menggunakan konsep Time-Boxing yang terstruktur.
2. Notifikasi Pengingat Cerdas: Sistem dual-trigger alarm menggunakan flutter_local_notifications yang andal untuk memberi peringatan saat sesi dimulai dan sesi wrap-up sebelum waktu habis.
3. Heatmap Kontribusi: Visualisasi intensitas durasi sesi belajar harian untuk memantau progres dan konsistensi belajar secara visual.
4. Bento Grid Widget: Integrasi widget layar beranda (Home Screen Widget) yang responsif dan menampilkan jadwal serta tugas aktif hari ini secara real-time.
5. Mode Gelap dan Terang: UI adaptif premium yang mendukung tema gelap (Dark Mode) dan terang (Light Mode).

---

## Struktur Folder Proyek

Proyek ini menerapkan arsitektur bersih yang memisahkan logika bisnis, presentasi, dan data secara modular. Berikut adalah bagan struktur folder utama pada direktori lib:

```text
lib/
├── core/
│   ├── constants/
│   │   ├── app_colors.dart         - Defenisi palet warna tema gelap dan terang
│   │   ├── app_spacing.dart        - Defenisi padding, margin, dan jarak antar elemen
│   │   └── app_typography.dart     - Konfigurasi tipografi teks menggunakan Google Fonts
│   ├── services/
│   │   ├── home_widget_service.dart- Penghubung dan penyedia data untuk Home Screen Widget
│   │   └── notification_service.dart- Mesin pengatur jadwal alarm dan notifikasi lokal
│   └── theme/
│       └── app_theme.dart          - Pengatur konfigurasi tema global aplikasi
│
└── features/
    ├── onboarding/
    │   └── presentation/
    │       └── pages/
    │           └── onboarding_page.dart - Halaman pengenalan fitur aplikasi pertama kali
    │
    ├── schedule/
    │   ├── data/
    │   │   ├── models/
    │   │   │   ├── schedule_model.dart  - Model data jadwal belajar terintegrasi Isar
    │   │   │   └── task_model.dart      - Model data tugas checklist terintegrasi Isar
    │   │   └── repositories/
    │   │       └── schedule_repository.dart - Penghubung operasi CRUD data jadwal ke database Isar
    │   └── presentation/
    │       ├── pages/
    │       │   ├── dashboard_page.dart  - Halaman utama dashboard Bento Grid
    │       │   └── heatmap_detail_page.dart - Halaman rincian kontribusi belajar dan riwayat sesi
    │       └── view_models/
    │           └── dashboard_view_model.dart - Pengatur state management halaman dashboard
    │
    └── timer/
        └── presentation/
            ├── pages/
            │   └── focus_timer_page.dart - Halaman hitung mundur fokus belajar
            └── view_models/
                └── timer_view_model.dart - Pengatur state timer, pause, reset, dan pencatatan sesi
```

---

## Dependensi Utama

Aplikasi ini dibangun menggunakan beberapa paket pustaka utama:

* flutter_riverpod & riverpod_annotation: Untuk manajemen state reaktif di seluruh aplikasi.
* isar_community & isar_community_flutter_libs: Database NoSQL lokal berkinerja tinggi untuk penyimpanan data offline.
* go_router: Solusi deklaratif untuk navigasi antar halaman.
* flutter_local_notifications & timezone: Mesin penjadwalan alarm presisi tinggi untuk background tasks.
* home_widget: Integrasi widget native Android untuk sinkronisasi data langsung ke layar beranda.
* flutter_animate: Menyediakan micro-animations yang halus dan dinamis di sisi antarmuka pengguna.

---

## Panduan Pemasangan Lokal

Ikuti langkah-langkah berikut untuk menjalankan proyek FocusForge di lingkungan pengembangan lokal Anda:

### Prasyarat
* Flutter SDK (Versi 3.16.x atau lebih baru) sudah terpasang.
* Android Studio / VS Code dikonfigurasi dengan ekstensi Flutter dan Dart.
* Emulator Android atau perangkat fisik Android yang terhubung dengan mode Debugging USB aktif.

### Langkah-langkah Setup

1. Klon Repositori
   Unduh atau klon repositori proyek ini ke komputer lokal Anda.

2. Masuk ke Direktori Proyek
   Buka terminal dan navigasikan ke folder proyek:
   ```bash
   cd focus_forge
   ```

3. Unduh Dependensi
   Jalankan perintah berikut untuk mengunduh semua package yang dideklarasikan di pubspec.yaml:
   ```bash
   flutter pub get
   ```

4. Jalankan Generator Kode (Build Runner)
   Proyek ini menggunakan generator kode otomatis untuk Riverpod dan Isar Database. Jalankan perintah build_runner untuk menghasilkan file generator (.g.dart):
   ```bash
   flutter pub run build_runner build --delete-conflicting-outputs
   ```
   Jika Anda sedang melakukan pengembangan aktif, Anda dapat memantau perubahan file secara real-time dengan perintah:
   ```bash
   flutter pub run build_runner watch --delete-conflicting-outputs
   ```

5. Jalankan Aplikasi
   Hubungkan perangkat Android Anda, kemudian jalankan aplikasi menggunakan perintah:
   ```bash
   flutter run
   ```

6. Menjalankan Uji Coba (Testing)
   Untuk memverifikasi fungsionalitas dan memastikan tidak ada regresi dalam aplikasi, jalankan suite pengujian menggunakan perintah:
   ```bash
   flutter test
   ```
