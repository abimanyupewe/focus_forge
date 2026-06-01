# **Product Requirements Document (PRD)**

**Project Name:** FocusForge (Personal Study & Habit Tracker)  
**Platform:** Mobile App (Flutter untuk Android & iOS)  
**Versi Dokumen:** 1.1 (Revisi: Time-Boxed Scheduling)  
**Fase:** MVP (Minimum Viable Product)

## **1\. EXECUTIVE SUMMARY**

**FocusForge** adalah aplikasi produktivitas personal yang dirancang untuk membantu pengguna membangun kebiasaan belajar yang konsisten. Dengan mengusung desain *Minimalist & Clean*, aplikasi ini berfungsi 100% secara *offline* (tanpa server backend). Fitur utamanya mencakup penjadwalan harian terstruktur (*time-boxing*), *timer* fokus terintegrasi (gaya Pomodoro), notifikasi pengingat lokal ganda, dan interaksi langsung melalui *Home Screen Widget*.

## **2\. PROBLEM & SOLUTION**

### **2.1 Masalah (Pain Points)**

* Pengguna sering lupa dengan jadwal belajar mandiri mereka karena terdistraksi notifikasi media sosial.  
* Pengguna sering kehilangan jejak waktu saat belajar (lupa istirahat atau belajar melebihi porsi yang sehat).  
* Aplikasi *tracker* yang ada di pasaran seringkali terlalu rumit (*bloated*), memerlukan koneksi internet, akun *login*, atau membebankan biaya langganan untuk fitur dasar seperti metrik analitik.

### **2.2 Solusi**

* **All-in-One Offline Tool:** FocusForge menggabungkan penjadwal, alarm notifikasi, dan *timer* fokus dalam satu aplikasi ringan tanpa perlu akses internet.  
* **Time-Boxed Focus:** Pengguna menetapkan batas waktu tegas (Jam Mulai dan Jam Selesai) untuk mencegah *burnout*.  
* **Frictionless Experience:** Penggunaan desain minimalis dan integrasi *Home Screen Widget* memungkinkan pengguna melihat jadwal dan memulai sesi belajar langsung dari layar utama HP.

## **3\. USER PERSONA**

* **Nama Target:** Mahasiswa, *Self-taught Programmer*, Pekerja Profesional.  
* **Karakteristik:** Memiliki jadwal harian yang padat, sedang mencoba mempelajari *skill* baru (misal: bahasa pemrograman atau bahasa asing), sering terdistraksi oleh *smartphone*, dan menyukai antarmuka aplikasi yang estetik serta tidak membingungkan.

## **4\. FEATURE SPECIFICATIONS (MVP)**

### **4.1 Modul 1: Task & Habit Management (Time-Boxed)**

* **Create Schedule:** Pengguna dapat membuat jadwal aktivitas (Contoh: "Belajar Golang", "Membaca Buku").  
* **Target Time-Boxing:** Pengguna **wajib menetapkan "Jam Mulai" (misal: 19:00) dan "Jam Selesai" (misal: 21:00)**.  
* **Auto-Calculate Duration:** Sistem otomatis menghitung durasi target berdasarkan rentang waktu yang diisi (misal: 120 menit).  
* **Local Storage:** Data disimpan secara *real-time* di perangkat menggunakan *local database* (Isar atau Hive).

### **4.2 Modul 2: Offline Notification Engine**

* **Local Push Notification:** Sistem akan mendaftarkan jadwal ke OS Android/iOS untuk memicu notifikasi.  
* **Dual-Trigger Alarm:** \* **Start Alarm:** Notifikasi berbunyi saat "Jam Mulai" tiba (Misal: "Waktunya Belajar Golang\!").  
  * **Wrap-up Alarm (Opsional/Pengaturan):** Notifikasi lembut berbunyi 5 atau 10 menit sebelum "Jam Selesai" tiba (Misal: "Sesi hampir usai, selesaikan latihan terakhirmu.").  
* **Actionable Notification:** Saat notifikasi muncul, terdapat tombol interaktif ("Mulai Belajar Sekarang").

### **4.3 Modul 3: Integrated Focus Timer (Target Sync)**

* **Pomodoro-style Timer:** Pengguna dapat memulai sesi fokus langsung dari aplikasi.  
* **Smart Duration Sync:** Jika pengguna menekan tombol "Start" pada sebuah jadwal yang sudah memiliki rentang waktu (misal: 120 menit), durasi di dalam *Focus Timer* akan **secara otomatis diisi 120 menit** untuk hitung mundur.  
* **State Management:** Menggunakan *Riverpod* agar *timer* tetap berjalan stabil di latar belakang atau saat pengguna berpindah halaman di dalam aplikasi.  
* **Session Logging:** Setelah *timer* selesai, durasi aktual sesi tersebut akan dicatat ke dalam *database* sebagai riwayat.

### **4.4 Modul 4: Analytics & Heatmap**

* **Daily Streak:** Melacak jumlah hari berturut-turut pengguna berhasil menyelesaikan setidaknya satu sesi belajar.  
* **Contribution Graph:** Menampilkan visualisasi kotak-kotak (seperti *Github Heatmap*) di mana kotak akan berwarna lebih gelap jika durasi belajar di hari tersebut semakin lama.

### **4.5 Modul 5: Home Screen Widgets (Native Bridge)**

* Menggunakan paket home\_widget untuk menghubungkan data Flutter dengan komponen *Native* (XML/SwiftUI).  
* **Widget Medium:** Menampilkan 3 jadwal teratas untuk hari ini (menampilkan Jam Mulai & Jam Selesai).  
* **Widget Quick-Action:** Memiliki tombol "Start" yang langsung membuka aplikasi dan menjalankan *Focus Timer*.

## **5\. TECHNICAL ARCHITECTURE**

### **5.1 Tech Stack**

* **UI/Framework:** Flutter (Dart).  
* **Design Pattern:** Feature-First Architecture.  
* **State Management:** Riverpod (Reaktif dan aman dari *memory leak*).  
* **Database Lokal:** Isar Database (Sangat cepat, mendukung relasi, dan *query* berbasis waktu).  
* **Notification Engine:** flutter\_local\_notifications dan timezone (untuk menangani zona waktu lokal perangkat).  
* **Widget Bridge:** home\_widget (Flutter) dipadukan dengan *AppWidgetProvider* (Android) dan *WidgetKit* (iOS).

### **5.2 UI/UX Design Guidelines**

* **Gaya Visual:** Minimalist, Clean, *Whitespace-heavy*.  
* **Palet Warna:** \* Background: \#F8F9FA (Off-white) atau \#121212 (Dark Mode).  
  * Primary Accent: \#2B6CB0 (Calm Blue) atau \#38A169 (Success Green).  
  * Typography: Abu-abu gelap (untuk teks utama) dan abu-abu terang (untuk *subtitle/hint*).  
* **Tipografi:** Sans-serif modern yang bulat (seperti *SF Pro*, *Inter*, atau *Nunito*).

## **6\. DEVELOPMENT PHASES (ROADMAP)**

### **Fase 1: Core Foundation & UI (Minggu 1\)**

* *Setup project*, *routing*, dan tema minimalis.  
* Inisialisasi Isar Database dan *repository pattern* untuk operasi CRUD jadwal (termasuk *Start Time* dan *End Time*).  
* Membangun UI halaman utama (Daftar Jadwal) dan halaman *Focus Timer*.

### **Fase 2: The Logic Brain (Minggu 2\)**

* Integrasi *State Management* (Riverpod) untuk mengontrol jalannya *Focus Timer*.  
* Membangun logika sinkronisasi perhitungan durasi otomatis dari rentang jam ke *timer*.  
* Memastikan riwayat sesi belajar berhasil tersimpan setelah *timer* selesai.  
* Membangun komponen UI *Heatmap/Analytics* berdasarkan data riwayat.

### **Fase 3: Notification Service (Minggu 3\)**

* Konfigurasi *Android Manifest* dan *iOS Info.plist* untuk perizinan *background task*.  
* Membangun NotificationService *class* menggunakan flutter\_local\_notifications.  
* Menyambungkan logika *database*: Setiap kali jadwal baru dibuat, fungsi pendaftaran alarm ganda (Mulai & Pengingat Selesai) otomatis dipanggil.

### **Fase 4: Native Widgets & Polish (Minggu 4\)**

* Membangun struktur *Native* (XML untuk Android, SwiftUI untuk iOS).  
* Menghubungkan *Shared Storage* antara Flutter dan komponen *Native* menggunakan home\_widget.  
* *Debugging* akhir, pengujian coba notifikasi di keadaan HP terkunci (*Screen Off*), dan optimasi performa.

## **7\. SUCCESS METRICS (KPIs)**

* **Teknis:** Aplikasi berjalan konstan di 60 FPS, ukuran instalasi di bawah 25 MB, dan penggunaan baterai minimal saat berada di latar belakang.  
* **Fungsional:** Notifikasi lokal (Mulai dan Selesai) terpicu dengan akurasi 100% pada waktu yang ditentukan, durasi *timer* sinkron dengan rentang waktu jadwal, dan *Widget* diperbarui secara *real-time* ketika data di aplikasi berubah.