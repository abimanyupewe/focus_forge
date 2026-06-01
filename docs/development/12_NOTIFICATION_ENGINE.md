# 🔔 12 — Notification Engine

> **Fase:** 3 (Notification Service)  
> **Prioritas:** 🔴 Critical  
> **Estimasi:** 5-6 jam  
> **Dependensi:** `01_PROJECT_SETUP.md`, `10_TASK_MANAGEMENT.md`

---

## 1. Deskripsi

Sistem notifikasi lokal **dual-trigger** — Start Alarm saat jam mulai dan Wrap-up Alarm sebelum jam selesai. Menggunakan `flutter_local_notifications` + `timezone` untuk scheduling yang akurat di Android & iOS.

---

## 2. NotificationService

```dart
/// lib/features/notification/data/notification_service.dart
class NotificationService {
  static final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  /// Initialize notification plugin dan channel.
  static Future<void> initialize() async {
    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    const settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );
    await _plugin.initialize(
      settings,
      onDidReceiveNotificationResponse: _onNotificationTap,
    );
  }

  /// Register dual-trigger alarms untuk sebuah schedule
  Future<void> registerScheduleAlarms(ScheduleModel schedule) async {
    for (final day in schedule.activeDays) {
      // 1. Start Alarm
      await _scheduleWeeklyNotification(
        id: _generateNotificationId(schedule.uid, day, 'start'),
        title: '⏰ Waktunya Belajar!',
        body: schedule.title,
        scheduledTime: _getNextOccurrence(day, schedule.startTime),
        payload: '/timer/${schedule.uid}',
      );

      // 2. Wrap-up Alarm (optional)
      if (schedule.wrapUpAlarmEnabled) {
        final wrapUpTime = schedule.endTime.subtract(
          Duration(minutes: schedule.wrapUpMinutesBefore),
        );
        await _scheduleWeeklyNotification(
          id: _generateNotificationId(schedule.uid, day, 'wrapup'),
          title: '⏳ Sesi Hampir Usai',
          body: 'Selesaikan latihan terakhirmu untuk "${schedule.title}"',
          scheduledTime: _getNextOccurrence(day, wrapUpTime),
          payload: '/timer',
        );
      }
    }
  }

  /// Cancel semua alarm terkait schedule tertentu
  Future<void> cancelScheduleAlarms(String scheduleUid) async {
    for (int day = 0; day < 7; day++) {
      await _plugin.cancel(
        _generateNotificationId(scheduleUid, day, 'start'),
      );
      await _plugin.cancel(
        _generateNotificationId(scheduleUid, day, 'wrapup'),
      );
    }
  }

  /// Schedule weekly repeating notification
  Future<void> _scheduleWeeklyNotification({
    required int id,
    required String title,
    required String body,
    required tz.TZDateTime scheduledTime,
    required String payload,
  }) async {
    await _plugin.zonedSchedule(
      id,
      title,
      body,
      scheduledTime,
      _notificationDetails(),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
      payload: payload,
    );
  }

  /// Handle notification tap → deep link ke timer
  static void _onNotificationTap(NotificationResponse response) {
    final payload = response.payload;
    if (payload != null) {
      // Navigate via GoRouter deep link
      // Implementasi: gunakan global navigator key atau callback
    }
  }

  /// Generate unique notification ID dari schedule uid + day + type
  int _generateNotificationId(String uid, int day, String type) {
    return '${uid}_${day}_$type'.hashCode.abs() % 2147483647;
  }

  NotificationDetails _notificationDetails() {
    return const NotificationDetails(
      android: AndroidNotificationDetails(
        'focus_forge_schedule',
        'Jadwal Belajar',
        channelDescription: 'Notifikasi pengingat jadwal belajar',
        importance: Importance.high,
        priority: Priority.high,
        playSound: true,
        enableVibration: true,
      ),
      iOS: DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      ),
    );
  }
}
```

---

## 3. Platform Configuration

### Android (`AndroidManifest.xml`)

```xml
<uses-permission android:name="android.permission.RECEIVE_BOOT_COMPLETED"/>
<uses-permission android:name="android.permission.SCHEDULE_EXACT_ALARM"/>
<uses-permission android:name="android.permission.POST_NOTIFICATIONS"/>
<uses-permission android:name="android.permission.VIBRATE"/>

<!-- Receiver untuk alarm setelah reboot -->
<receiver android:name="com.dexterous.flutterlocalnotifications.ScheduledNotificationBootReceiver"
    android:exported="false">
  <intent-filter>
    <action android:name="android.intent.action.BOOT_COMPLETED"/>
  </intent-filter>
</receiver>
```

### iOS (`Info.plist`)

```xml
<key>UIBackgroundModes</key>
<array>
  <string>fetch</string>
  <string>processing</string>
</array>
```

---

## 4. Notification Flow

```
[User membuat jadwal]
        │
        ▼
[ScheduleService.create()]
        │
        ▼
[NotificationService.registerScheduleAlarms()]
        │
        ├── scheduleWeekly(START alarm) per active day
        └── scheduleWeekly(WRAP-UP alarm) per active day (if enabled)

... Waktu berlalu ...

[OS triggers notification]
        │
        ├── User tap notification
        │         │
        │         ▼
        │   [Deep link → /timer/{uid}]
        │         │
        │         ▼
        │   [FocusTimerScreen auto-start]
        │
        └── User dismiss → nothing happens
```

---

## 5. Permission Handling

```dart
/// Request notification permission (Android 13+)
Future<bool> requestPermission() async {
  if (Platform.isAndroid) {
    final granted = await _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
    return granted ?? false;
  }
  return true; // iOS handled during initialize
}
```

---

## 6. Acceptance Criteria

- [ ] Start Alarm berbunyi tepat pada `startTime` yang ditentukan
- [ ] Wrap-up Alarm berbunyi N menit sebelum `endTime`
- [ ] Notification muncul saat HP terkunci (screen off)
- [ ] Tap notification membuka app ke FocusTimerScreen
- [ ] Alarm tetap aktif setelah device reboot
- [ ] Cancel alarm berfungsi saat jadwal dihapus/diupdate
- [ ] Permission request di Android 13+ handled gracefully
