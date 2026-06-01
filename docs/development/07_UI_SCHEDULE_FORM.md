# 📝 07 — UI: Schedule Form

> **Fase:** 1 (Core Foundation)  
> **Prioritas:** 🔴 Critical  
> **Estimasi:** 3-4 jam  
> **Dependensi:** `05_DESIGN_SYSTEM.md`, `02_DATABASE_SETUP.md`

---

## 1. Deskripsi

Form untuk **membuat** dan **mengedit** jadwal belajar. Mendukung time-boxing dengan field Jam Mulai & Jam Selesai, pemilihan hari aktif, dan konfigurasi alarm notifikasi.

---

## 2. Layout Structure

```
┌──────────────────────────────────┐
│  AppBar: "Jadwal Baru" / "Edit"  │
│                      [✓ Simpan]  │
├──────────────────────────────────┤
│                                  │
│  ┌─ Judul Aktivitas ──────────┐  │
│  │ "Belajar Golang"           │  │
│  └────────────────────────────┘  │
│                                  │
│  ┌─ Deskripsi (Opsional) ─────┐  │
│  │ "Chapter 5 - Concurrency"  │  │
│  └────────────────────────────┘  │
│                                  │
│  === Kategori ===                │
│  ┌─ Ikon ─┐  ┌─ Warna ────────┐ │
│  │  📖    │  │ 🔵🟢🟡🔴🟣🟠  │ │
│  └────────┘  └────────────────┘  │
│                                  │
│  === Time-Boxing ===             │
│  ┌─ Jam Mulai ─┐ ┌─ Jam Selesai┐│
│  │   19:00     │ │   21:00     ││
│  └─────────────┘ └─────────────┘│
│  ┌─ Durasi (Auto) ────────────┐  │
│  │ ⏱ 120 menit (2 jam)        │  │
│  └────────────────────────────┘  │
│                                  │
│  === Hari Aktif ===              │
│  [S] [S] [R] [K] [J] [S] [M]    │
│   ●   ●   ●   ●   ●   ○   ○    │
│                                  │
│  === Notifikasi ===              │
│  ┌─ Start Alarm ──────── [ON] ┐  │
│  ├─ Wrap-up Alarm ───── [ON] ─┤  │
│  │  └─ Menit sebelum: [5▼]    │  │
│  └────────────────────────────┘  │
│                                  │
└──────────────────────────────────┘
```

---

## 3. Fields & Validation

| Field | Type | Required | Validasi |
|-------|------|----------|----------|
| `title` | TextInput | ✅ Ya | Min 1 char, max 50 char |
| `description` | TextInput | ❌ Tidak | Max 200 char |
| `iconCodePoint` | IconPicker | ✅ Ya | Default: book icon |
| `colorValue` | ColorPicker | ✅ Ya | Default: primary blue |
| `startTime` | TimePicker | ✅ Ya | Harus < endTime |
| `endTime` | TimePicker | ✅ Ya | Harus > startTime |
| `activeDays` | MultiSelect | ✅ Ya | Min 1 hari dipilih |
| `wrapUpAlarmEnabled` | Switch | ✅ Ya | Default: true |
| `wrapUpMinutesBefore` | Dropdown | Conditional | 5 / 10 / 15 menit |

### Auto-Calculate Duration

```dart
/// Durasi otomatis dihitung saat startTime atau endTime berubah.
int durationMinutes = endTime.difference(startTime).inMinutes;
// Display: "120 menit (2 jam)"
```

### Validasi Rules

1. `endTime` harus lebih besar dari `startTime`
2. Durasi minimum: 15 menit
3. Durasi maksimum: 480 menit (8 jam)
4. Minimal 1 hari aktif harus dipilih
5. Judul tidak boleh kosong

---

## 4. UX Flow

### Create Flow
1. User tap FAB (+) di Home Screen
2. Form kosong terbuka (slide-up transition)
3. User mengisi fields
4. Durasi auto-calculate saat time berubah
5. Tap "Simpan" → validasi → simpan ke Isar → kembali ke Home
6. Notification alarm di-register otomatis

### Edit Flow
1. User tap schedule card di Home Screen
2. Form terbuka dengan data pre-filled
3. User modifikasi fields
4. Tap "Simpan" → validasi → update di Isar → kembali ke Home
5. Notification alarm di-re-register

---

## 5. Komponen Khusus

### 5.1 TimeRangePicker
- Custom widget menggunakan `showTimePicker()`
- Menampilkan 2 time fields side-by-side
- Real-time duration preview di bawahnya

### 5.2 DaySelector
- 7 circular chips (S, S, R, K, J, S, M)
- Toggle on/off per hari
- Filled state: `primary` color, unfilled: `outline` border

### 5.3 CategoryColorPicker
- Horizontal row of 8 color circles
- Selected state: checkmark overlay + scale up
- Colors dari `AppColors.categoryColors`

---

## 6. Acceptance Criteria

- [ ] Form create berhasil menyimpan jadwal baru ke database
- [ ] Form edit berhasil me-load dan update data existing
- [ ] Durasi auto-calculate saat time berubah
- [ ] Validasi menampilkan error message yang jelas
- [ ] Notification alarm ter-register setelah save (lihat `12_NOTIFICATION_ENGINE.md`)
- [ ] Back button menampilkan discard confirmation jika ada unsaved changes
