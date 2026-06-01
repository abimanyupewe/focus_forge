# 📱 14 — Home Screen Widget (Native Bridge)

> **Fase:** 4 (Native Widgets & Polish)  
> **Prioritas:** 🟡 High  
> **Estimasi:** 6-8 jam  
> **Dependensi:** `01_PROJECT_SETUP.md`, `10_TASK_MANAGEMENT.md`

---

## 1. Deskripsi

Native **Home Screen Widget** untuk Android (XML + AppWidgetProvider) dan iOS (SwiftUI + WidgetKit), terhubung ke Flutter via `home_widget` package. Menampilkan 3 jadwal teratas hari ini dengan tombol quick-action "Start".

---

## 2. Widget Variants

### 2.1 Medium Widget (4x2)

```
┌──────────────────────────────┐
│ FocusForge          📅 Senin │
├──────────────────────────────┤
│ 🔵 Belajar Golang            │
│    19:00 - 21:00     [▶]    │
├──────────────────────────────┤
│ 🟢 Membaca Buku              │
│    21:30 - 22:30     [▶]    │
├──────────────────────────────┤
│ 🟡 Review Notes              │
│    23:00 - 23:30     [▶]    │
└──────────────────────────────┘
```

---

## 3. Data Flow (Flutter ↔ Native)

```
┌─────────────┐    Shared Storage     ┌──────────────┐
│   Flutter    │ ◄══════════════════► │  Native Code  │
│  (Dart)      │   home_widget pkg    │ (XML/SwiftUI) │
│              │                      │               │
│ save data →  │   UserDefaults(iOS)  │  ← read data  │
│              │   SharedPrefs(AND)   │               │
└─────────────┘                       └──────────────┘

1. Flutter menyimpan jadwal hari ini ke shared storage (JSON)
2. Native widget membaca shared storage saat render
3. "Start" button → deep link → open Flutter app → /timer/{uid}
4. Widget di-update setiap kali data jadwal berubah
```

---

## 4. Shared Data Format

```json
{
  "today_schedules": [
    {
      "uid": "abc-123",
      "title": "Belajar Golang",
      "startTime": "19:00",
      "endTime": "21:00",
      "colorHex": "#2B6CB0"
    }
  ],
  "day_label": "Senin",
  "updated_at": "2026-06-01T19:00:00"
}
```

---

## 5. Widget Service (Flutter Side)

```dart
/// lib/services/widget_service.dart
class WidgetService {
  /// Update home widget data.
  /// Dipanggil setiap kali jadwal berubah (create/update/delete).
  static Future<void> updateWidget(
    List<ScheduleModel> todaySchedules,
  ) async {
    final data = todaySchedules.take(3).map((s) => {
      'uid': s.uid,
      'title': s.title,
      'startTime': DateFormat.Hm().format(s.startTime),
      'endTime': DateFormat.Hm().format(s.endTime),
      'colorHex': '#${s.colorValue.toRadixString(16).substring(2)}',
    }).toList();

    await HomeWidget.saveWidgetData('today_schedules', jsonEncode(data));
    await HomeWidget.saveWidgetData('day_label', _getDayLabel());
    await HomeWidget.saveWidgetData(
      'updated_at', DateTime.now().toIso8601String(),
    );
    await HomeWidget.updateWidget(
      androidName: 'FocusForgeWidgetProvider',
      iOSName: 'FocusForgeWidget',
    );
  }
}
```

---

## 6. Android Implementation

### 6.1 AppWidgetProvider

```kotlin
// android/app/src/main/.../FocusForgeWidgetProvider.kt
class FocusForgeWidgetProvider : HomeWidgetProvider() {
    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
        widgetData: SharedPreferences
    ) {
        appWidgetIds.forEach { widgetId ->
            val views = RemoteViews(context.packageName, R.layout.widget_layout)
            val schedulesJson = widgetData.getString("today_schedules", "[]")
            // Parse JSON dan populate views...
            appWidgetManager.updateAppWidget(widgetId, views)
        }
    }
}
```

### 6.2 Layout XML (`widget_layout.xml`)

```xml
<!-- android/app/src/main/res/layout/widget_layout.xml -->
<LinearLayout android:orientation="vertical" ...>
  <TextView android:id="@+id/header" ... />
  <ListView android:id="@+id/schedule_list" ... />
</LinearLayout>
```

---

## 7. iOS Implementation (WidgetKit + SwiftUI)

```swift
// ios/FocusForgeWidget/FocusForgeWidget.swift
struct FocusForgeWidgetEntryView : View {
    var entry: Provider.Entry

    var body: some View {
        VStack(alignment: .leading) {
            Text("FocusForge")
                .font(.headline)
            ForEach(entry.schedules.prefix(3)) { schedule in
                HStack {
                    Circle()
                        .fill(Color(hex: schedule.colorHex))
                        .frame(width: 8, height: 8)
                    VStack(alignment: .leading) {
                        Text(schedule.title).font(.subheadline)
                        Text("\(schedule.startTime) - \(schedule.endTime)")
                            .font(.caption).foregroundColor(.secondary)
                    }
                    Spacer()
                    // Deep link button
                    Link(destination: URL(string: "focusforge://timer/\(schedule.uid)")!) {
                        Image(systemName: "play.fill")
                    }
                }
            }
        }
        .padding()
    }
}
```

---

## 8. Widget Update Triggers

| Trigger | Aksi |
|---------|------|
| Schedule created | `WidgetService.updateWidget()` |
| Schedule updated | `WidgetService.updateWidget()` |
| Schedule deleted | `WidgetService.updateWidget()` |
| Midnight (hari berganti) | Background refresh via OS |
| App launched | `WidgetService.updateWidget()` |

---

## 9. Acceptance Criteria

- [ ] Android widget menampilkan 3 jadwal teratas hari ini
- [ ] iOS widget menampilkan 3 jadwal teratas hari ini
- [ ] "Start" button pada widget membuka app ke FocusTimerScreen
- [ ] Widget di-update secara real-time saat data jadwal berubah
- [ ] Widget menampilkan data yang benar setelah hari berganti
- [ ] Widget tetap berfungsi setelah device reboot
