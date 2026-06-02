import 'package:home_widget/home_widget.dart';
import '../../features/schedule/data/models/schedule_model.dart';
import '../../features/schedule/data/models/task_model.dart';

class HomeWidgetService {
  /// Memperbarui data home widget dengan statistik streak, jadwal terbaru, dan tugas hari ini.
  static Future<void> updateWidgetData({
    required int streak,
    ScheduleModel? nextSchedule,
    required List<TaskModel> todayTasks,
    required bool isDark,
  }) async {
    try {
      final streakText = "🔥 $streak Hari";
      String scheduleTitle = "Tidak Ada Jadwal";
      String scheduleTime = "Mulai buat jadwal baru!";

      if (nextSchedule != null) {
        final hourStart = nextSchedule.startTime.hour.toString().padLeft(2, '0');
        final minuteStart = nextSchedule.startTime.minute.toString().padLeft(2, '0');
        final hourEnd = nextSchedule.endTime.hour.toString().padLeft(2, '0');
        final minuteEnd = nextSchedule.endTime.minute.toString().padLeft(2, '0');
        
        scheduleTitle = nextSchedule.title;
        scheduleTime = "$hourStart:$minuteStart - $hourEnd:$minuteEnd";
      }

      // Simpan data ke SharedPreferences yang dibagikan dengan Widget Android
      await HomeWidget.saveWidgetData<String>('streak_text', streakText);
      await HomeWidget.saveWidgetData<String>('schedule_title', scheduleTitle);
      await HomeWidget.saveWidgetData<String>('schedule_time', scheduleTime);
      await HomeWidget.saveWidgetData<bool>('is_dark', isDark);

      // Simpan data tugas hari ini (maksimal 3 tugas)
      final completedCount = todayTasks.where((t) => t.isCompleted).length;
      await HomeWidget.saveWidgetData<String>('task_count_text', "TUGAS ($completedCount/${todayTasks.length})");

      for (int i = 0; i < 3; i++) {
        final keyNum = i + 1;
        if (i < todayTasks.length) {
          final task = todayTasks[i];
          await HomeWidget.saveWidgetData<String>('task_${keyNum}_title', task.title);
          await HomeWidget.saveWidgetData<bool>('task_${keyNum}_completed', task.isCompleted);
        } else {
          await HomeWidget.saveWidgetData<String>('task_${keyNum}_title', "");
          await HomeWidget.saveWidgetData<bool>('task_${keyNum}_completed', false);
        }
      }

      // Trigger update widget di Android
      await HomeWidget.updateWidget(
        name: 'FocusForgeWidgetProvider',
        androidName: 'FocusForgeWidgetProvider',
        qualifiedAndroidName: 'com.saku.focus_forge.FocusForgeWidgetProvider',
      );
    } catch (e) {
      // Tangani error secara diam-diam agar tidak merusak fungsionalitas utama aplikasi
      print("Gagal memperbarui Home Widget: $e");
    }
  }
}
