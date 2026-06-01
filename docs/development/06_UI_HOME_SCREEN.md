# 🏠 06 — UI: Home Screen

> **Fase:** 1 (Core Foundation)  
> **Prioritas:** 🔴 Critical  
> **Estimasi:** 4-5 jam  
> **Dependensi:** `05_DESIGN_SYSTEM.md`, `03_STATE_MANAGEMENT.md`

---

## 1. Deskripsi

Halaman utama FocusForge — menampilkan **daftar jadwal harian** dalam format card list. Halaman ini menjadi *hub* utama yang memungkinkan user membuat jadwal baru, memulai sesi fokus, dan memonitor progress harian.

---

## 2. Layout Structure

```
┌──────────────────────────────────┐
│  AppBar                          │
│  ┌─────────────┐  ┌──────────┐  │
│  │ "FocusForge" │  │ 🌙 Toggle│  │
│  └─────────────┘  └──────────┘  │
├──────────────────────────────────┤
│  Date Selector (Horizontal)      │
│  [Sen] [Sel] [Rab★] [Kam] [Jum] │
├──────────────────────────────────┤
│  Daily Summary Card              │
│  ┌──────────────────────────┐    │
│  │ 3 Jadwal • 2h 30m total  │    │
│  │ 🔥 Streak: 7 hari        │    │
│  └──────────────────────────┘    │
├──────────────────────────────────┤
│  Schedule List                   │
│  ┌──────────────────────────┐    │
│  │ 🔵 Belajar Golang        │    │
│  │ 19:00 - 21:00 (120 min)  │    │
│  │           [▶ Start]       │    │
│  └──────────────────────────┘    │
│  ┌──────────────────────────┐    │
│  │ 🟢 Membaca Buku          │    │
│  │ 21:30 - 22:30 (60 min)   │    │
│  │           [▶ Start]       │    │
│  └──────────────────────────┘    │
│                                  │
│  --- Empty State (jika kosong) --│
│  "Belum ada jadwal hari ini"     │
│  [+ Buat Jadwal Baru]           │
├──────────────────────────────────┤
│  FAB: [+] (Create Schedule)      │
├──────────────────────────────────┤
│  BottomNav: [Jadwal] [Fokus] [📊]│
└──────────────────────────────────┘
```

---

## 3. Komponen Widget

### 3.1 DateSelectorBar

- Horizontal scrollable row menampilkan 7 hari (Mon-Sun)
- Hari aktif ditandai dengan `primary` color circle
- Tap pada hari → update `selectedDateProvider`

### 3.2 DailySummaryCard

- Menampilkan ringkasan: jumlah jadwal, total durasi, dan streak
- Warna gradient subtle dari `primaryContainer`
- Animasi counter saat data berubah (`flutter_animate`)

### 3.3 ScheduleCard

- Card individual per jadwal
- Menampilkan: ikon kategori (warna), judul, rentang waktu, durasi
- Trailing action: tombol "Start" → navigasi ke `/timer/{uid}`
- Swipe left: delete (dengan konfirmasi)
- Tap card: navigasi ke edit form
- Indikator status: upcoming (default), active (saat ini dalam rentang waktu), completed

### 3.4 EmptyState

- Ilustrasi minimalis + teks "Belum ada jadwal untuk hari ini"
- CTA button "Buat Jadwal Baru"

---

## 4. Interaksi & Animasi

| Elemen | Animasi | Library |
|--------|---------|---------|
| Schedule cards | Staggered fade-in saat list load | `flutter_animate` |
| Card tap | Scale down 0.98 + ripple | Material InkWell |
| Card swipe delete | Slide out + fade | Dismissible |
| FAB | Scale bounce on tap | `flutter_animate` |
| Date selector | Smooth scroll to selected | ScrollController |
| Empty → List | Crossfade transition | AnimatedSwitcher |

---

## 5. State Dependencies

```dart
// Providers yang di-watch oleh HomeScreen
ref.watch(selectedDateProvider);       // Tanggal aktif
ref.watch(scheduleListProvider);       // List jadwal
ref.watch(dailyStreakProvider);        // Streak counter
```

---

## 6. Acceptance Criteria

- [ ] List jadwal menampilkan data dari `scheduleListProvider` berdasarkan hari yang dipilih
- [ ] Date selector berfungsi dan mengupdate list secara reaktif
- [ ] Tombol "Start" pada card menavigasi ke FocusTimerScreen dengan durasi pre-filled
- [ ] Empty state muncul saat tidak ada jadwal
- [ ] FAB membuka ScheduleFormScreen
- [ ] Staggered animation berjalan smooth pada initial load
- [ ] Dark mode compatible
