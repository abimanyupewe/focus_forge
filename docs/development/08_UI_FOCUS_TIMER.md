# ⏱️ 08 — UI: Focus Timer

> **Fase:** 1 (Core Foundation & UI) + Fase 2 (Logic)  
> **Prioritas:** 🔴 Critical  
> **Estimasi:** 5-6 jam  
> **Dependensi:** `05_DESIGN_SYSTEM.md`, `03_STATE_MANAGEMENT.md`

---

## 1. Deskripsi

Halaman **Focus Timer** — inti interaktif FocusForge. Menampilkan countdown timer bergaya Pomodoro dengan circular progress, kontrol play/pause/reset, dan session logging otomatis.

---

## 2. Layout Structure

```
┌──────────────────────────────────┐
│  AppBar: "Sesi Fokus"            │
│                        [✕ Close] │
├──────────────────────────────────┤
│                                  │
│  ┌─ Schedule Info ─────────────┐ │
│  │ 📖 Belajar Golang           │ │
│  │ 19:00 - 21:00               │ │
│  └─────────────────────────────┘ │
│                                  │
│        ┌──────────────┐          │
│       ╱  Circular      ╲         │
│      │   Progress       │        │
│      │                  │        │
│      │    01:45:30      │        │
│      │   remaining      │        │
│       ╲                ╱         │
│        └──────────────┘          │
│                                  │
│  ┌─ Progress Bar ──────────────┐ │
│  │ ████████░░░░░░░  62.5%      │ │
│  └─────────────────────────────┘ │
│                                  │
│  ┌─ Controls ──────────────────┐ │
│  │  [⏹ Reset]  [▶ Start]  ⏭   │ │
│  └─────────────────────────────┘ │
│                                  │
│  ┌─ Session Info ──────────────┐ │
│  │ Elapsed: 00:34:30           │ │
│  │ Target:  02:00:00           │ │
│  └─────────────────────────────┘ │
│                                  │
└──────────────────────────────────┘
```

---

## 3. Timer States & UI Mapping

| State | Display | Controls | Warna Ring |
|-------|---------|----------|------------|
| `idle` | "00:00" atau pre-filled duration | [▶ Start] | `outline` (grey) |
| `running` | Countdown aktif | [⏸ Pause] [⏹ Reset] | `primary` (blue) animated |
| `paused` | Countdown frozen | [▶ Resume] [⏹ Reset] | `primary` (dimmed) |
| `completed` | "00:00" + "Sesi Selesai!" | [✓ Selesai] [🔄 Lagi] | `secondary` (green) |

---

## 4. Komponen Widget

### 4.1 CircularTimer
- `CustomPainter` dengan arc progress animation
- Stroke width: 12px, stroke cap: round
- Background ring: `outline` color
- Progress ring: gradient dari `primary` ke `primaryContainer`
- Center: waktu tersisa dalam format `HH:MM:SS` (`displayLarge`)

### 4.2 TimerControls
- 3 tombol: Reset, Play/Pause (primary/besar), Skip
- Play/Pause: CircleAvatar 64px, `primary` color, icon 32px
- Reset: outlined style, 48px
- Animasi rotate icon saat state change

### 4.3 ScheduleInfoBanner
- Compact banner menampilkan jadwal yang sedang dijalankan
- Hanya muncul jika timer dipanggil dari schedule (`scheduleUid != null`)

---

## 5. Smart Duration Sync

```dart
/// Saat FocusTimerScreen dibuka dengan scheduleUid:
/// 1. Fetch schedule dari database berdasarkan uid
/// 2. Calculate durasi dari startTime & endTime
/// 3. Set timerState.totalSeconds = durationMinutes * 60
/// 4. Set timerState.remainingSeconds = totalSeconds
///
/// Saat dibuka tanpa scheduleUid (manual):
/// → Tampilkan duration picker (default: 25 menit Pomodoro)
```

---

## 6. Animasi

| Elemen | Animasi | Detail |
|--------|---------|--------|
| Circular progress | Smooth arc sweep | `AnimationController` + `Tween<double>` |
| Timer text | Scale pulse setiap menit | `flutter_animate` `.scale()` |
| Controls | Fade + slide in | Staggered 100ms delay |
| Completion | Confetti-like particles + vibrate | `flutter_animate` custom |
| State transition | Crossfade icons | `AnimatedSwitcher` 200ms |

---

## 7. Background Behavior

- Timer **tetap berjalan** saat user pindah halaman (via `timerStateProvider` non-autoDispose)
- Timer **tetap berjalan** saat app di-minimize (menggunakan elapsed time calculation)
- Saat kembali ke timer page, UI sync dengan state terkini
- Session log disimpan otomatis saat `completed`

---

## 8. Acceptance Criteria

- [ ] Timer countdown akurat (margin error < 1 detik per jam)
- [ ] Smart Duration Sync: timer pre-filled dari schedule duration
- [ ] Circular progress animation smooth di 60 FPS
- [ ] Play/Pause/Reset berfungsi dengan state yang benar
- [ ] Timer persist saat navigasi ke halaman lain
- [ ] Session log tersimpan ke database saat completed
- [ ] Completion state menampilkan celebratory feedback
