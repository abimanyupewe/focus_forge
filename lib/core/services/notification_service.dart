import 'dart:io';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter_timezone/flutter_timezone.dart';
import '../../features/schedule/data/models/schedule_model.dart';

/// Service global untuk mengelola local push notifications (dual-trigger alarms).
class NotificationService {
  NotificationService._();

  static final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();

  /// Inisialisasi notifikasi, timezone, dan channel default.
  static Future<void> initialize() async {
    // 1. Inisialisasi database timezone
    tz.initializeTimeZones();
    try {
      final String timeZoneName = (await FlutterTimezone.getLocalTimezone()).identifier;
      tz.setLocalLocation(tz.getLocation(timeZoneName));
    } catch (_) {
      // Fallback jika terjadi kegagalan deteksi lokasi timezone
      tz.setLocalLocation(tz.getLocation('Asia/Jakarta'));
    }

    // 2. Inisialisasi plugin notifikasi
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
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
      settings: settings,
      onDidReceiveNotificationResponse: _onNotificationTap,
    );
  }

  /// Meminta izin notifikasi (Android 13+ & iOS).
  static Future<bool> requestPermission() async {
    if (Platform.isAndroid) {
      final granted = await _plugin
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
          ?.requestNotificationsPermission();
      return granted ?? false;
    } else if (Platform.isIOS) {
      final granted = await _plugin
          .resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          );
      return granted ?? false;
    }
    return true;
  }

  /// Mendaftarkan alarm dual-trigger untuk sebuah jadwal belajar.
  static Future<void> registerScheduleAlarms(ScheduleModel schedule) async {
    try {
      // Batalkan alarm lama jika ada sebelum mendaftarkan ulang
      await cancelScheduleAlarms(schedule.uid);

      if (!schedule.isActive) return;

      for (final day in schedule.activeDays) {
        // 1. Start Alarm (Waktunya Belajar)
        await _scheduleWeeklyNotification(
          id: _generateNotificationId(schedule.uid, day, 'start'),
          title: 'Waktunya Belajar!',
          body: 'Ayo mulai sesi belajar "${schedule.title}" sekarang!',
          scheduledTime: _getNextOccurrence(day, schedule.startTime),
          payload: '/timer/${schedule.uid}',
        );

        // 2. Wrap-up Alarm (Pengingat Sesi Hampir Selesai)
        if (schedule.wrapUpAlarmEnabled) {
          final wrapUpTime = schedule.endTime.subtract(
            Duration(minutes: schedule.wrapUpMinutesBefore),
          );
          // Pastikan waktu wrap-up berada setelah start time
          if (wrapUpTime.isAfter(schedule.startTime)) {
            await _scheduleWeeklyNotification(
              id: _generateNotificationId(schedule.uid, day, 'wrapup'),
              title: 'Sesi Hampir Usai',
              body: 'Selesaikan latihan terakhirmu untuk "${schedule.title}"',
              scheduledTime: _getNextOccurrence(day, wrapUpTime),
              payload: '/timer',
            );
          }
        }
      }
    } catch (e) {
      print("Gagal mendaftarkan alarm jadwal: $e");
    }
  }

  /// Membatalkan seluruh alarm notifikasi terkait suatu jadwal.
  static Future<void> cancelScheduleAlarms(String scheduleUid) async {
    try {
      for (int day = 0; day < 7; day++) {
        await _plugin.cancel(id: _generateNotificationId(scheduleUid, day, 'start'));
        await _plugin.cancel(id: _generateNotificationId(scheduleUid, day, 'wrapup'));
      }
    } catch (e) {
      print("Gagal membatalkan alarm jadwal: $e");
    }
  }

  /// Menjadwalkan notifikasi mingguan berulang.
  static Future<void> _scheduleWeeklyNotification({
    required int id,
    required String title,
    required String body,
    required tz.TZDateTime scheduledTime,
    required String payload,
  }) async {
    try {
      await _plugin.zonedSchedule(
        id: id,
        title: title,
        body: body,
        scheduledDate: scheduledTime,
        notificationDetails: _notificationDetails(),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
        payload: payload,
      );
    } catch (e) {
      print("Gagal menjadwalkan notifikasi mingguan: $e");
    }
  }

  /// Mendapatkan detail konfigurasi notifikasi tiap platform.
  static NotificationDetails _notificationDetails() {
    return const NotificationDetails(
      android: AndroidNotificationDetails(
        'focus_forge_schedule',
        'Jadwal Belajar',
        channelDescription: 'Notifikasi pengingat jadwal belajar FocusForge',
        importance: Importance.max,
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

  /// Handler ketika notifikasi di-tap oleh pengguna.
  static void _onNotificationTap(NotificationResponse response) {
    // Dapat diintegrasikan dengan routing / deep linking jika diperlukan
  }

  /// Helper untuk generate unique ID 32-bit int dari UUID dan hari.
  static int _generateNotificationId(String uid, int day, String type) {
    return '${uid}_${day}_$type'.hashCode.abs() % 2147483647;
  }

  /// Mendapatkan waktu occurrence terdekat untuk hari dan jam tertentu.
  static tz.TZDateTime _getNextOccurrence(int dayOfWeekIndex, DateTime time) {
    // dayOfWeekIndex: 0 = Senin, ..., 6 = Minggu
    // Di DateTime: 1 = Senin, ..., 7 = Minggu
    final targetDay = dayOfWeekIndex + 1;
    final now = tz.TZDateTime.now(tz.local);
    var scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      time.hour,
      time.minute,
      0,
    );
    while (scheduledDate.weekday != targetDay || scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }
    return scheduledDate;
  }

  /// Menampilkan notifikasi instan untuk status timer fokus.
  static Future<void> showTimerNotification({
    required String title,
    required String body,
    int? remainingSeconds,
    bool isPaused = false,
  }) async {
    try {
      final int? whenValue = (!isPaused && remainingSeconds != null)
          ? (DateTime.now().millisecondsSinceEpoch + remainingSeconds * 1000)
          : null;

      final androidDetails = AndroidNotificationDetails(
        'focus_forge_timer',
        'Timer Fokus',
        channelDescription: 'Notifikasi status sesi pengatur waktu fokus FocusForge',
        importance: Importance.max,
        priority: Priority.high,
        playSound: false, // Matikan suara berulang tiap detik jika di-update
        enableVibration: false,
        ongoing: !isPaused, // Membuat notifikasi tidak bisa di-swipe saat timer berjalan
        onlyAlertOnce: true, // Hanya bunyikan/getarkan sekali saja di awal
        showWhen: whenValue != null,
        when: whenValue,
        usesChronometer: whenValue != null,
        chronometerCountDown: whenValue != null,
      );
      const iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: false,
        presentSound: false,
      );
      final details = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );
      
      // Gunakan ID tetap 999 untuk notifikasi timer agar tidak menumpuk
      await _plugin.show(
        id: 999,
        title: title,
        body: body,
        notificationDetails: details,
        payload: '/timer',
      );
    } catch (e) {
      print("Gagal menampilkan notifikasi timer: $e");
    }
  }

  /// Menghapus notifikasi status timer.
  static Future<void> dismissTimerNotification() async {
    try {
      await _plugin.cancel(id: 999);
    } catch (e) {
      print("Gagal menghapus notifikasi timer: $e");
    }
  }

  /// Menampilkan notifikasi instan umum (misal saat sesi selesai).
  static Future<void> showInstantNotification({
    required int id,
    required String title,
    required String body,
  }) async {
    try {
      const androidDetails = AndroidNotificationDetails(
        'focus_forge_instant',
        'Notifikasi Instan',
        channelDescription: 'Notifikasi instan untuk pencapaian sesi FocusForge',
        importance: Importance.max,
        priority: Priority.high,
        playSound: true,
        enableVibration: true,
      );
      const iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );
      const details = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );
      await _plugin.show(
        id: id,
        title: title,
        body: body,
        notificationDetails: details,
      );
    } catch (e) {
      print("Gagal menampilkan notifikasi instan: $e");
    }
  }
}

