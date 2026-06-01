# 📊 09 — UI: Analytics & Heatmap

> **Fase:** 2 (The Logic Brain)  
> **Prioritas:** 🟡 High  
> **Estimasi:** 4-5 jam  
> **Dependensi:** `05_DESIGN_SYSTEM.md`, `02_DATABASE_SETUP.md`

---

## 1. Deskripsi

Halaman **Analytics** menampilkan visualisasi progress belajar user — *GitHub-style Contribution Heatmap*, daily streak counter, dan statistik ringkas. Data bersumber dari `SessionModel` di Isar database.

---

## 2. Layout Structure

```
┌──────────────────────────────────┐
│  AppBar: "Statistik"             │
├──────────────────────────────────┤
│                                  │
│  ┌─ Streak Card ───────────────┐ │
│  │ 🔥 7 Hari Berturut-turut    │ │
│  │ "Pertahankan momentummu!"   │ │
│  └─────────────────────────────┘ │
│                                  │
│  ┌─ Stat Cards Row ───────────┐  │
│  │ ┌────────┐ ┌────────┐      │  │
│  │ │ 42.5h  │ │ 28     │      │  │
│  │ │ Total  │ │ Sesi   │      │  │
│  │ └────────┘ └────────┘      │  │
│  │ ┌────────┐ ┌────────┐      │  │
│  │ │ 1.5h   │ │ 85%    │      │  │
│  │ │ Avg/hr │ │ Rate   │      │  │
│  │ └────────┘ └────────┘      │  │
│  └────────────────────────────┘  │
│                                  │
│  ┌─ Contribution Heatmap ─────┐  │
│  │ Title: "Aktivitas Belajar"  │  │
│  │ ┌─┬─┬─┬─┬─┬─┬─┐ ...x 12w  │  │
│  │ │░│░│█│▓│░│ │ │            │  │
│  │ │░│▓│█│█│▓│░│ │  Mon       │  │
│  │ │ │░│▓│█│░│ │ │  Wed       │  │
│  │ │░│░│▓│▓│▓│░│ │  Fri       │  │
│  │ └─┴─┴─┴─┴─┴─┴─┘            │  │
│  │ Legend: [ ] <1h [░] 1-2h    │  │
│  │         [▓] 2-3h [█] >3h   │  │
│  └─────────────────────────────┘  │
│                                  │
│  ┌─ Recent Sessions ──────────┐  │
│  │ Hari ini:                   │  │
│  │ • Belajar Golang  (45 min)  │  │
│  │ • Membaca Buku    (30 min)  │  │
│  └─────────────────────────────┘  │
│                                  │
└──────────────────────────────────┘
```

---

## 3. Komponen Widget

### 3.1 StreakCounter
- Menampilkan jumlah hari berturut-turut dengan sesi completed
- Ikon 🔥 dengan animasi pulse
- Motivational message dinamis berdasarkan streak length

### 3.2 StatCard (Grid 2x2)
- **Total Hours:** Kumulatif durasi seluruh sesi
- **Total Sessions:** Jumlah sesi completed
- **Avg/Day:** Rata-rata durasi per hari (30 hari terakhir)
- **Completion Rate:** Persentase sesi yang diselesaikan penuh

### 3.3 HeatmapGrid (Contribution Graph)
- Grid 7 rows (hari) x 12 columns (minggu) = **84 hari terakhir**
- Cell size: 14x14px, gap: 3px
- 5 level intensitas warna berdasarkan durasi harian:

| Level | Durasi | Light Mode Color | Dark Mode Color |
|-------|--------|------------------|-----------------|
| 0 | 0 min | `#EBEDF0` | `#2D2D2D` |
| 1 | 1-30 min | `#C6E5FF` | `#1A365D` |
| 2 | 31-60 min | `#7CB8F0` | `#2B6CB0` |
| 3 | 61-120 min | `#3B82C4` | `#4299E1` |
| 4 | >120 min | `#1E4D7B` | `#63B3ED` |

### 3.4 RecentSessionsList
- Daftar sesi hari ini dengan judul schedule dan durasi
- Tap item → navigasi ke timer dengan schedule tersebut

---

## 4. Data Flow

```dart
/// Providers untuk Analytics screen
final analyticsProvider = FutureProvider.autoDispose<AnalyticsData>((ref) {
  final sessionRepo = ref.watch(sessionRepositoryProvider);
  return AnalyticsService(sessionRepo).getAnalytics();
});

/// AnalyticsData model
class AnalyticsData {
  final int currentStreak;
  final double totalHours;
  final int totalSessions;
  final double avgHoursPerDay;
  final double completionRate;
  final Map<DateTime, int> heatmapData; // date → totalSeconds
  final List<SessionModel> todaySessions;
}
```

---

## 5. Animasi

| Elemen | Animasi |
|--------|---------|
| Stat cards | Counter animation (0 → value) saat pertama load |
| Heatmap cells | Staggered fade-in dari kiri ke kanan |
| Streak counter | Scale bounce + glow pulse |

---

## 6. Acceptance Criteria

- [ ] Heatmap menampilkan 84 hari terakhir dengan intensitas warna yang benar
- [ ] Streak counter akurat (hari berturut-turut dengan minimal 1 sesi completed)
- [ ] Stat cards menampilkan data aggregasi yang akurat
- [ ] Recent sessions menampilkan sesi hari ini
- [ ] Animasi counter berjalan smooth
- [ ] Dark mode compatible dengan color mapping yang sesuai
