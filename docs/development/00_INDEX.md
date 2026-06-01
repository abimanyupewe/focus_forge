# 📚 FocusForge — Development Documentation Index

> **Project:** FocusForge (Personal Study & Habit Tracker)  
> **Platform:** Flutter (Android & iOS)  
> **Architecture:** Feature-First + Clean Architecture  
> **State Management:** Riverpod  
> **Database:** Isar  
> **Versi Dokumen:** 1.0  
> **Tanggal:** 2026-06-01

---

## 📂 Struktur Dokumentasi

Setiap file dalam folder `docs/development/` merepresentasikan **satu unit kerja** yang berdiri sendiri — mulai dari setup environment hingga implementasi fitur spesifik.

### 🔧 Setup & Foundation

| # | File | Deskripsi |
|---|------|-----------|
| 01 | [`01_PROJECT_SETUP.md`](./01_PROJECT_SETUP.md) | Konfigurasi awal project Flutter, dependencies, folder structure, dan theme system |
| 02 | [`02_DATABASE_SETUP.md`](./02_DATABASE_SETUP.md) | Inisialisasi Isar Database, schema definition, dan repository pattern |
| 03 | [`03_STATE_MANAGEMENT.md`](./03_STATE_MANAGEMENT.md) | Setup Riverpod, provider architecture, dan global state conventions |
| 04 | [`04_ROUTING_NAVIGATION.md`](./04_ROUTING_NAVIGATION.md) | GoRouter / Navigator 2.0 setup, route definitions, dan deep linking |

### 🎨 UI & Design System

| # | File | Deskripsi |
|---|------|-----------|
| 05 | [`05_DESIGN_SYSTEM.md`](./05_DESIGN_SYSTEM.md) | Color palette, typography tokens, spacing scale, component library, dan dark/light mode |
| 06 | [`06_UI_HOME_SCREEN.md`](./06_UI_HOME_SCREEN.md) | Home Screen — layout jadwal harian, card components, dan empty states |
| 07 | [`07_UI_SCHEDULE_FORM.md`](./07_UI_SCHEDULE_FORM.md) | Create/Edit Schedule — form layout, time picker, validasi, dan UX flow |
| 08 | [`08_UI_FOCUS_TIMER.md`](./08_UI_FOCUS_TIMER.md) | Focus Timer Page — circular timer, controls, session state, dan animasi |
| 09 | [`09_UI_ANALYTICS.md`](./09_UI_ANALYTICS.md) | Analytics & Heatmap Page — contribution graph, streak counter, dan statistik |

### ⚙️ Feature & Logic

| # | File | Deskripsi |
|---|------|-----------|
| 10 | [`10_TASK_MANAGEMENT.md`](./10_TASK_MANAGEMENT.md) | CRUD operations untuk schedule/habit, time-boxing logic, dan data flow |
| 11 | [`11_FOCUS_TIMER_LOGIC.md`](./11_FOCUS_TIMER_LOGIC.md) | Timer engine, Pomodoro logic, background execution, dan session logging |
| 12 | [`12_NOTIFICATION_ENGINE.md`](./12_NOTIFICATION_ENGINE.md) | Local push notification, dual-trigger alarm, actionable notification, dan platform config |
| 13 | [`13_ANALYTICS_ENGINE.md`](./13_ANALYTICS_ENGINE.md) | Streak calculation, heatmap data aggregation, dan session statistics |
| 14 | [`14_HOME_WIDGET.md`](./14_HOME_WIDGET.md) | Native Home Screen Widget — Android (XML) & iOS (SwiftUI), shared storage bridge |

### 🧪 Quality & Deployment

| # | File | Deskripsi |
|---|------|-----------|
| 15 | [`15_TESTING_STRATEGY.md`](./15_TESTING_STRATEGY.md) | Unit test, widget test, integration test, dan performance benchmarking |

---

## 🗺️ Dependency Graph

```
01_PROJECT_SETUP
├── 02_DATABASE_SETUP
├── 03_STATE_MANAGEMENT
├── 04_ROUTING_NAVIGATION
└── 05_DESIGN_SYSTEM
        ├── 06_UI_HOME_SCREEN ──────► 10_TASK_MANAGEMENT
        ├── 07_UI_SCHEDULE_FORM ────► 10_TASK_MANAGEMENT
        ├── 08_UI_FOCUS_TIMER ─────► 11_FOCUS_TIMER_LOGIC
        └── 09_UI_ANALYTICS ───────► 13_ANALYTICS_ENGINE
                                        │
            12_NOTIFICATION_ENGINE ◄────┘
            14_HOME_WIDGET ◄──────── 10 + 11
            15_TESTING_STRATEGY ◄── ALL
```

---

## ⏱️ Mapping ke Roadmap (PRD Fase)

| Fase | Minggu | Dokumen Terkait |
|------|--------|-----------------|
| **Fase 1:** Core Foundation & UI | Minggu 1 | `01` `02` `03` `04` `05` `06` `07` `08` |
| **Fase 2:** The Logic Brain | Minggu 2 | `03` `10` `11` `09` `13` |
| **Fase 3:** Notification Service | Minggu 3 | `12` |
| **Fase 4:** Native Widgets & Polish | Minggu 4 | `14` `15` |
