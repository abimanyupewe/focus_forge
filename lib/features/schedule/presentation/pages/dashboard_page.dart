import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../timer/presentation/pages/focus_timer_page.dart';
import '../../../timer/presentation/view_models/timer_view_model.dart';
import '../../data/models/schedule_model.dart';
import '../../data/models/task_model.dart';
import '../view_models/dashboard_view_model.dart';
import 'heatmap_detail_page.dart';
import '../../../../core/theme/theme_provider.dart';
class DashboardPage extends ConsumerWidget {
  const DashboardPage({super.key});

  /// Format asisten untuk merender waktu HH:MM
  String _formatTime(DateTime dateTime) {
    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');
    return "$hour:$minute";
  }

  /// Generator representasi hari belajar lokalisasi manual
  String _getFormattedDate() {
    final now = DateTime.now();
    final days = ['Minggu', 'Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu'];
    final months = [
      'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
      'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
    ];
    return "${days[now.weekday % 7]}, ${now.day} ${months[now.month - 1]} ${now.year}";
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Listen themeMode changes to instantly refresh Home Widget colors
    ref.listen<ThemeMode>(themeModeProvider, (previous, next) {
      ref.read(dashboardViewModelProvider.notifier).loadData();
    });

    final dashboardState = ref.watch(dashboardViewModelProvider);
    final dashboardNotifier = ref.read(dashboardViewModelProvider.notifier);
    final themeMode = ref.watch(themeModeProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () => dashboardNotifier.loadData(),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.xl,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // === HEADER SECTION ===
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'FocusForge',
                          style: AppTypography.displayLarge.copyWith(
                            fontWeight: FontWeight.bold,
                            letterSpacing: -1,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          _getFormattedDate(),
                          style: AppTypography.bodyMedium.copyWith(
                            color: isDark ? AppColors.darkOnSurfaceVariant : AppColors.lightOnSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        // PopUp Menu Pilihan Tema
                        PopupMenuButton<ThemeMode>(
                          icon: Icon(
                            themeMode == ThemeMode.light
                                ? Icons.light_mode_outlined
                                : themeMode == ThemeMode.dark
                                    ? Icons.dark_mode_outlined
                                    : Icons.settings_brightness_outlined,
                            color: isDark ? AppColors.darkPrimary : AppColors.lightPrimary,
                            size: 24,
                          ),
                          tooltip: 'Ubah Tema',
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                            side: BorderSide(
                              color: isDark ? Colors.grey[850]! : Colors.grey[300]!,
                              width: 1,
                            ),
                          ),
                          onSelected: (mode) {
                            ref.read(themeModeProvider.notifier).setTheme(mode);
                          },
                           itemBuilder: (context) => [
                            PopupMenuItem(
                              value: ThemeMode.light,
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.light_mode_outlined,
                                    size: 18,
                                    color: isDark ? AppColors.darkPrimary : AppColors.lightPrimary,
                                  ),
                                  const SizedBox(width: 10),
                                  Text(
                                    'Terang',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: isDark ? Colors.white : Colors.black87,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            PopupMenuItem(
                              value: ThemeMode.dark,
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.dark_mode_outlined,
                                    size: 18,
                                    color: isDark ? AppColors.darkPrimary : AppColors.lightPrimary,
                                  ),
                                  const SizedBox(width: 10),
                                  Text(
                                    'Gelap',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: isDark ? Colors.white : Colors.black87,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            PopupMenuItem(
                              value: ThemeMode.system,
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.settings_brightness_outlined,
                                    size: 18,
                                    color: isDark ? AppColors.darkPrimary : AppColors.lightPrimary,
                                  ),
                                  const SizedBox(width: 10),
                                  Text(
                                    'Sistem',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: isDark ? Colors.white : Colors.black87,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(width: AppSpacing.xs),
                        // Streak Badge
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.md,
                            vertical: AppSpacing.sm,
                          ),
                          decoration: BoxDecoration(
                            color: (isDark ? AppColors.darkPrimary : AppColors.lightPrimary).withValues(alpha: 0.1),
                            borderRadius: AppSpacing.borderLg,
                            border: Border.all(
                              color: (isDark ? AppColors.darkPrimary : AppColors.lightPrimary).withValues(alpha: 0.3),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              const Text('🔥 ', style: TextStyle(fontSize: 16)),
                              Text(
                                '${dashboardState.streakDays} Hari',
                                style: AppTypography.labelLarge.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: isDark ? AppColors.darkPrimary : AppColors.lightPrimary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ).animate().scale(delay: 200.ms, curve: Curves.elasticOut),
                  ],
                ),

                const SizedBox(height: AppSpacing.xl),

                // === ANALYTICS / CONTRIBUTIONS GRAPH (HEATMAP) ===
                Text('Analitik Belajar Mandiri', style: AppTypography.titleMedium.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: AppSpacing.md),
                _buildHeatmapCard(context, dashboardState.dailyDurations),

                const SizedBox(height: AppSpacing.xl),

                // === TODAY'S SCHEDULES ===
                if (dashboardState.schedules.isNotEmpty || dashboardState.isLoading) ...[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Jadwal Belajar Hari Ini',
                        style: AppTypography.titleMedium.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (dashboardState.schedules.isNotEmpty)
                        Text(
                          '${dashboardState.schedules.length} Jadwal',
                          style: AppTypography.bodySmall.copyWith(
                            color: isDark ? AppColors.darkOnSurfaceVariant : AppColors.lightOnSurfaceVariant,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),

                  if (dashboardState.isLoading)
                    Column(
                      children: List.generate(2, (_) => Padding(
                        padding: const EdgeInsets.only(bottom: AppSpacing.md),
                        child: _buildSkeletonCard(context, isDark),
                      )),
                    )
                  else
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: dashboardState.schedules.length,
                      separatorBuilder: (context, index) => const SizedBox(height: AppSpacing.md),
                      itemBuilder: (context, index) {
                        final schedule = dashboardState.schedules[index];
                        return _buildScheduleCard(context, ref, schedule, dashboardNotifier);
                      },
                    ),
                  const SizedBox(height: AppSpacing.xl),
                ],

                // === DAFTAR TUGAS / TASKS ===
                if (dashboardState.tasks.isNotEmpty || dashboardState.isLoading) ...[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Daftar Tugas / Tasks',
                        style: AppTypography.titleMedium.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (dashboardState.tasks.isNotEmpty)
                        Text(
                          '${dashboardState.tasks.where((t) => t.isCompleted).length}/${dashboardState.tasks.length} Selesai',
                          style: AppTypography.bodySmall.copyWith(
                            color: isDark ? AppColors.darkOnSurfaceVariant : AppColors.lightOnSurfaceVariant,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),

                  if (dashboardState.isLoading)
                    Column(
                      children: List.generate(2, (_) => Padding(
                        padding: const EdgeInsets.only(bottom: AppSpacing.md),
                        child: _buildSkeletonCard(context, isDark),
                      )),
                    )
                  else
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: dashboardState.tasks.length,
                      separatorBuilder: (context, index) => const SizedBox(height: AppSpacing.md),
                      itemBuilder: (context, index) {
                        final task = dashboardState.tasks[index];
                        return _buildTaskCard(context, ref, task, dashboardNotifier);
                      },
                    ),
                  const SizedBox(height: AppSpacing.xl),
                ],
                if (dashboardState.schedules.isEmpty && dashboardState.tasks.isEmpty && !dashboardState.isLoading) ...[
                  const SizedBox(height: AppSpacing.lg),
                  Center(
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(AppSpacing.xl),
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: isDark ? Colors.white10 : Colors.black12,
                          width: 1,
                        ),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.calendar_today_rounded,
                            size: 40,
                            color: isDark ? AppColors.darkPrimary.withValues(alpha: 0.5) : AppColors.lightPrimary.withValues(alpha: 0.5),
                          ),
                          const SizedBox(height: AppSpacing.md),
                          Text(
                            'Tidak ada jadwal atau tugas hari ini.',
                            textAlign: TextAlign.center,
                            style: AppTypography.bodyLarge.copyWith(
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Outfit',
                            ),
                          ),
                          const SizedBox(height: AppSpacing.xs),
                          Text(
                            'Gunakan tombol + di bawah untuk membuat agenda baru.',
                            textAlign: TextAlign.center,
                            style: AppTypography.bodySmall.copyWith(
                              color: isDark ? AppColors.darkOnSurfaceVariant : AppColors.lightOnSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: ModernFabMenu(
        notifier: dashboardNotifier,
        onAddSchedule: () => _showScheduleBottomSheet(context, dashboardNotifier),
        onAddTask: () => _showTaskBottomSheet(context, dashboardNotifier),
      ),
    );
  }

  /// Widget untuk merender Heatmap kontribusi (Bulan saat ini, real-time)
  Widget _buildHeatmapCard(BuildContext context, Map<DateTime, int> dailyDurations) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final today = DateTime.now();
    final year = today.year;
    final month = today.month;
    final firstDayOfMonth = DateTime(year, month, 1);
    final totalDaysInMonth = DateTime(year, month + 1, 0).day;
    final startOffset = firstDayOfMonth.weekday % 7; // Sunday=0, Monday=1...

    final monthsIndonesian = [
      'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
      'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
    ];
    final currentMonthName = monthsIndonesian[month - 1];

    final primaryColor = isDark ? AppColors.darkPrimary : AppColors.lightPrimary;

    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: isDark ? Colors.white10 : Colors.black12, width: 0.5),
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => HeatmapDetailPage(initialSelectedDate: today),
            ),
          );
        },
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(Icons.calendar_month_rounded, color: primaryColor, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'Heatmap Kontribusi',
                        style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  Text(
                    '$currentMonthName $year',
                    style: AppTypography.bodySmall.copyWith(
                      fontWeight: FontWeight.bold,
                      color: primaryColor,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              
              // Header Hari
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: ['Min', 'Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab'].map((day) {
                  return Expanded(
                    child: Center(
                      child: Text(
                        day,
                        style: AppTypography.bodySmall.copyWith(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[500],
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 6),

              // Grid Hari Kalender Bulan Ini
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: startOffset + totalDaysInMonth,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 7,
                  mainAxisSpacing: 6,
                  crossAxisSpacing: 6,
                  childAspectRatio: 1.0,
                ),
                itemBuilder: (context, index) {
                  if (index < startOffset) {
                    return const SizedBox.shrink();
                  }

                  final day = index - startOffset + 1;
                  final date = DateTime(year, month, day);
                  final seconds = dailyDurations[date] ?? 0;
                  final minutes = (seconds > 0 && seconds < 60) ? 1 : seconds ~/ 60;

                  // Tentukan warna berdasarkan intensitas durasi
                  Color cellColor;
                  if (minutes == 0) {
                    cellColor = isDark ? Colors.grey[900]! : Colors.grey[100]!;
                  } else if (minutes < 15) {
                    cellColor = primaryColor.withValues(alpha: 0.2);
                  } else if (minutes < 45) {
                    cellColor = primaryColor.withValues(alpha: 0.5);
                  } else if (minutes < 90) {
                    cellColor = primaryColor.withValues(alpha: 0.8);
                  } else {
                    cellColor = primaryColor;
                  }

                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => HeatmapDetailPage(initialSelectedDate: date),
                        ),
                      );
                    },
                    child: Tooltip(
                      message: "$day $currentMonthName — $minutes Menit Belajar",
                      child: Container(
                        decoration: BoxDecoration(
                          color: cellColor,
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(
                            color: isDark ? Colors.grey[850]! : Colors.grey[300]!,
                            width: 0.5,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            '$day',
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                              color: minutes == 0
                                  ? (isDark ? Colors.grey[600] : Colors.grey[500])
                                  : Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: AppSpacing.sm),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Tap kotak untuk detail sesi',
                    style: AppTypography.bodySmall.copyWith(fontSize: 10, color: Colors.grey),
                  ),
                  Row(
                    children: [
                      Text('Min', style: AppTypography.bodySmall.copyWith(fontSize: 10)),
                      const SizedBox(width: 4),
                      Container(width: 8, height: 8, decoration: BoxDecoration(color: isDark ? Colors.grey[900]! : Colors.grey[100]!, borderRadius: BorderRadius.circular(2))),
                      const SizedBox(width: 2),
                      Container(width: 8, height: 8, decoration: BoxDecoration(color: primaryColor.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(2))),
                      const SizedBox(width: 2),
                      Container(width: 8, height: 8, decoration: BoxDecoration(color: primaryColor.withValues(alpha: 0.5), borderRadius: BorderRadius.circular(2))),
                      const SizedBox(width: 2),
                      Container(width: 8, height: 8, decoration: BoxDecoration(color: primaryColor.withValues(alpha: 0.8), borderRadius: BorderRadius.circular(2))),
                      const SizedBox(width: 2),
                      Container(width: 8, height: 8, decoration: BoxDecoration(color: primaryColor, borderRadius: BorderRadius.circular(2))),
                      const SizedBox(width: 4),
                      Text('Max', style: AppTypography.bodySmall.copyWith(fontSize: 10)),
                    ],
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    ).animate().fade(delay: 100.ms).slideY(begin: 0.1);
  }

  /// Widget Skeleton Loader premium untuk menggantikan CircularProgressIndicator
  Widget _buildSkeletonCard(BuildContext context, bool isDark) {
    final baseColor = isDark ? Colors.grey[900]! : Colors.grey[100]!;
    final highlightColor = isDark ? Colors.grey[850]! : Colors.grey[200]!;
    final borderColor = isDark ? Colors.grey[850]! : Colors.grey[300]!;
    final accentColor = isDark ? AppColors.darkPrimary.withOpacity(0.15) : AppColors.lightPrimary.withOpacity(0.15);

    return Card(
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: borderColor, width: 1),
      ),
      child: Container(
        height: 72,
        decoration: BoxDecoration(
          color: baseColor,
          borderRadius: BorderRadius.circular(8),
        ),
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.md),
        child: Row(
          children: [
            // Left Accent Bar (Teal Soft)
            Container(
              width: 4,
              height: 40,
              decoration: BoxDecoration(
                color: accentColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            // Title & Subtitle placeholders
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 140,
                    height: 12,
                    decoration: BoxDecoration(
                      color: highlightColor,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Container(
                    width: 85,
                    height: 8,
                    decoration: BoxDecoration(
                      color: highlightColor.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ],
              ),
            ),
            // Right-side badge placeholder
            Container(
              width: 48,
              height: 20,
              decoration: BoxDecoration(
                color: highlightColor,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ],
        ),
      ),
    ).animate(onPlay: (controller) => controller.repeat(reverse: true))
     .fade(begin: 0.6, end: 1.0, duration: 800.ms);
  }

  /// Widget untuk merender kartu jadwal belajar mandiri (Bento-Grid style)
  Widget _buildScheduleCard(
    BuildContext context,
    WidgetRef ref,
    ScheduleModel schedule,
    DashboardNotifier notifier,
  ) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final color = isDark ? AppColors.darkPrimary : AppColors.lightPrimary;
    
    final dashboardState = ref.watch(dashboardViewModelProvider);
    final isCompleted = dashboardState.completedScheduleUids.contains(schedule.uid);

    return Dismissible(
      key: Key(schedule.uid),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: AppSpacing.xl),
        decoration: BoxDecoration(
          color: AppColors.lightError.withValues(alpha: 0.8),
          borderRadius: AppSpacing.borderMd,
        ),
        child: const Icon(Icons.delete_sweep_rounded, color: Colors.white, size: 28),
      ),
      onDismissed: (_) {
        notifier.deleteSchedule(schedule.id);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Jadwal "${schedule.title}" dihapus.'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      },
      child: Card(
        clipBehavior: Clip.antiAlias,
        elevation: isCompleted ? 0 : 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: BorderSide(
            color: isDark ? Colors.grey[850]! : Colors.grey[300]!,
            width: 1,
          ),
        ),
        child: InkWell(
          onTap: () => _showScheduleDetailBottomSheet(context, ref, notifier, schedule),
          child: Container(
            decoration: BoxDecoration(
              color: isCompleted
                  ? (isDark ? Colors.grey[900]!.withValues(alpha: 0.3) : Colors.grey[100]!.withValues(alpha: 0.5))
                  : (isDark ? AppColors.darkSurface : AppColors.lightSurface),
              border: Border(
                left: BorderSide(
                  color: isCompleted ? Colors.grey.withValues(alpha: 0.5) : color,
                  width: 6,
                ),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.md),
              child: Row(
                children: [
                  // Checklist Kotak Kurang Bulat Premium (Indikator Status Selesai)
                  GestureDetector(
                    onTap: () {
                      ScaffoldMessenger.of(context).clearSnackBars();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Row(
                            children: [
                              Icon(
                                Icons.timer_outlined,
                                color: isDark ? AppColors.darkPrimary : AppColors.lightPrimary,
                              ),
                              const SizedBox(width: AppSpacing.md),
                              Expanded(
                                child: Text(
                                  'Jadwal ini diselesaikan otomatis dengan menjalankan sesi timer belajar Anda.',
                                  style: TextStyle(
                                    fontFamily: 'Outfit',
                                    fontWeight: FontWeight.bold,
                                    color: isDark ? Colors.white : Colors.black87,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                            side: BorderSide(
                              color: isDark ? Colors.grey[850]! : Colors.grey[300]!,
                              width: 1,
                            ),
                          ),
                          backgroundColor: isDark ? AppColors.darkSurface : AppColors.lightSurface,
                          duration: const Duration(seconds: 3),
                        ),
                      );
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      margin: const EdgeInsets.only(right: AppSpacing.sm),
                      width: 26,
                      height: 26,
                      decoration: BoxDecoration(
                        color: isCompleted ? color : Colors.transparent,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: isCompleted ? color : color.withValues(alpha: 0.6),
                          width: 2,
                        ),
                        boxShadow: isCompleted
                            ? [
                                BoxShadow(
                                  color: color.withValues(alpha: 0.3),
                                  blurRadius: 6,
                                  offset: const Offset(0, 2),
                                )
                              ]
                            : null,
                      ),
                      child: isCompleted
                          ? const Icon(
                              Icons.check_rounded,
                              size: 16,
                              color: Colors.white,
                            )
                          : null,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          schedule.title,
                          style: AppTypography.titleMedium.copyWith(
                            fontWeight: FontWeight.bold,
                            decoration: isCompleted ? TextDecoration.lineThrough : null,
                            color: isCompleted
                                ? (isDark ? Colors.white38 : Colors.black38)
                                : (isDark ? Colors.white : Colors.black87),
                          ),
                        ),
                        if (schedule.description != null && schedule.description!.isNotEmpty) ...[
                          const SizedBox(height: 2),
                          Text(
                            schedule.description!,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTypography.bodyMedium.copyWith(
                              decoration: isCompleted ? TextDecoration.lineThrough : null,
                              color: isCompleted
                                  ? (isDark ? Colors.white24 : Colors.black26)
                                  : (isDark ? AppColors.darkOnSurfaceVariant : AppColors.lightOnSurfaceVariant),
                            ),
                          ),
                        ],
                        const SizedBox(height: AppSpacing.sm),
                        Row(
                          children: [
                            Icon(
                              Icons.schedule_rounded,
                              size: 14,
                              color: isCompleted
                                  ? (isDark ? Colors.white24 : Colors.black26)
                                  : (isDark ? AppColors.darkOnSurfaceVariant : AppColors.lightOnSurfaceVariant),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${_formatTime(schedule.startTime)} - ${_formatTime(schedule.endTime)} (${schedule.durationMinutes} mnt)',
                              style: AppTypography.bodySmall.copyWith(
                                fontWeight: FontWeight.w600,
                                decoration: isCompleted ? TextDecoration.lineThrough : null,
                                color: isCompleted
                                    ? (isDark ? Colors.white24 : Colors.black26)
                                    : (isDark ? AppColors.darkOnSurfaceVariant : AppColors.lightOnSurfaceVariant),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  // Sisi Kanan: Status Selesai / Tombol Sesi Fokus
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: isCompleted
                        ? Container(
                            key: const ValueKey('completed'),
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: color.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: color.withValues(alpha: 0.3),
                                width: 1,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.check_circle_rounded, color: color, size: 14),
                                const SizedBox(width: 4),
                                Text(
                                  'Selesai',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: color,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : Row(
                            key: const ValueKey('active'),
                            children: [
                              // Tombol Start Sesi (Bulat Premium)
                              Material(
                                color: color.withValues(alpha: 0.12),
                                shape: const CircleBorder(),
                                child: InkWell(
                                  customBorder: const CircleBorder(),
                                  onTap: () {
                                    ref.read(timerViewModelProvider.notifier).setDuration(
                                          schedule.durationMinutes * 60,
                                          schedule: schedule,
                                        );
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (context) => const FocusTimerPage(),
                                      ),
                                    );
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Icon(Icons.play_arrow_rounded, color: color, size: 22),
                                  ),
                                ),
                              ),
                            ],
                          ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    ).animate().fade().slideX(begin: 0.1);
  }

  /// Tampilkan Bottom Sheet Detail Jadwal yang Sangat Mewah & Informatif
  void _showScheduleDetailBottomSheet(
    BuildContext context,
    WidgetRef ref,
    DashboardNotifier notifier,
    ScheduleModel schedule,
  ) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final color = Color(schedule.colorValue);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            final daysOfWeek = ['M', 'S', 'S', 'R', 'K', 'J', 'S'];
            final daysFull = [
              'Minggu',
              'Senin',
              'Selasa',
              'Rabu',
              'Kamis',
              'Jumat',
              'Sabtu'
            ];
            
            final activeDaysList = schedule.activeDays;
            final isEveryDay = activeDaysList.length == 7;
            String repeatText = "";
            if (isEveryDay) {
              repeatText = "Setiap hari";
            } else if (activeDaysList.isEmpty) {
              repeatText = "Tidak berulang";
            } else {
              repeatText = "Berulang pada: ${activeDaysList.map((d) => daysFull[d]).join(', ')}";
            }

            return Container(
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 20,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Container(
                          width: 40,
                          height: 5,
                          decoration: BoxDecoration(
                            color: isDark ? Colors.white24 : Colors.black12,
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      Row(
                        children: [
                          Container(
                            width: 12,
                            height: 12,
                            decoration: BoxDecoration(
                              color: color,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            "DETAIL JADWAL BELAJAR",
                            style: AppTypography.labelLarge.copyWith(
                              color: color,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.1,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      Text(
                        schedule.title,
                        style: AppTypography.headlineMedium.copyWith(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 8),

                      if (schedule.description != null && schedule.description!.isNotEmpty) ...[
                        Text(
                          schedule.description!,
                          style: AppTypography.bodyLarge.copyWith(
                            color: isDark ? AppColors.darkOnSurfaceVariant : AppColors.lightOnSurfaceVariant,
                            height: 1.4,
                          ),
                        ),
                      ] else ...[
                        Text(
                          "Tidak ada deskripsi tambahan.",
                          style: AppTypography.bodyLarge.copyWith(
                            fontStyle: FontStyle.italic,
                            color: isDark ? Colors.white38 : Colors.black38,
                          ),
                        ),
                      ],
                      const SizedBox(height: 20),

                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: isDark ? Colors.white.withOpacity(0.04) : Colors.black.withOpacity(0.03),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isDark ? Colors.white10 : Colors.black12,
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Column(
                              children: [
                                Text(
                                  "Mulai",
                                  style: AppTypography.bodySmall.copyWith(
                                    color: isDark ? Colors.white38 : Colors.black45,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  _formatTime(schedule.startTime),
                                  style: AppTypography.titleLarge.copyWith(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: isDark ? Colors.white : Colors.black87,
                                  ),
                                ),
                              ],
                            ),
                            Container(
                              height: 30,
                              width: 1,
                              color: isDark ? Colors.white12 : Colors.black12,
                            ),
                            Column(
                              children: [
                                Text(
                                  "Durasi",
                                  style: AppTypography.bodySmall.copyWith(
                                    color: isDark ? Colors.white38 : Colors.black45,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: color.withOpacity(0.15),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    "${schedule.durationMinutes} Menit",
                                    style: AppTypography.bodyMedium.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: color,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            Container(
                              height: 30,
                              width: 1,
                              color: isDark ? Colors.white12 : Colors.black12,
                            ),
                            Column(
                              children: [
                                Text(
                                  "Selesai",
                                  style: AppTypography.bodySmall.copyWith(
                                    color: isDark ? Colors.white38 : Colors.black45,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  _formatTime(schedule.endTime),
                                  style: AppTypography.titleLarge.copyWith(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: isDark ? Colors.white : Colors.black87,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      Text(
                        "Hari Aktif",
                        style: AppTypography.titleMedium.copyWith(
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white70 : Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: List.generate(7, (idx) {
                          final isActive = activeDaysList.contains(idx);
                          return Container(
                            width: 38,
                            height: 38,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: isActive
                                  ? color
                                  : (isDark ? Colors.white10 : Colors.black.withOpacity(0.05)),
                              border: isActive
                                  ? null
                                  : Border.all(
                                      color: isDark ? Colors.white10 : Colors.black12,
                                    ),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              daysOfWeek[idx],
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: isActive
                                    ? Colors.white
                                    : (isDark ? Colors.white38 : Colors.black45),
                              ),
                            ),
                          );
                        }),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        repeatText,
                        style: AppTypography.bodySmall.copyWith(
                          color: isDark ? Colors.white38 : Colors.black45,
                        ),
                      ),
                      const SizedBox(height: 20),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.notifications_active_rounded,
                                size: 20,
                                color: isDark ? Colors.white70 : Colors.black87,
                              ),
                              const SizedBox(width: 8),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Notifikasi & Alarm Aktif",
                                    style: AppTypography.bodyMedium.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: isDark ? Colors.white : Colors.black87,
                                    ),
                                  ),
                                  Text(
                                    schedule.isActive ? "Aktif" : "Nonaktif",
                                    style: AppTypography.bodySmall.copyWith(
                                      color: isDark ? Colors.white38 : Colors.black45,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          Switch(
                            value: schedule.isActive,
                            activeThumbColor: isDark ? AppColors.darkPrimary : AppColors.lightPrimary,
                            onChanged: (val) {
                              notifier.toggleSchedule(schedule);
                              setState(() {});
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Icon(
                            Icons.timer_rounded,
                            size: 20,
                            color: schedule.wrapUpAlarmEnabled
                                ? color
                                : (isDark ? Colors.white38 : Colors.black38),
                          ),
                          const SizedBox(width: 8),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Alarm Wrap-Up Sebelum Selesai",
                                style: AppTypography.bodyMedium.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: schedule.wrapUpAlarmEnabled
                                      ? (isDark ? Colors.white : Colors.black87)
                                      : (isDark ? Colors.white38 : Colors.black38),
                                ),
                              ),
                              Text(
                                schedule.wrapUpAlarmEnabled
                                    ? "Berbunyi ${schedule.wrapUpMinutesBefore} menit sebelum selesai"
                                    : "Nonaktif",
                                style: AppTypography.bodySmall.copyWith(
                                  color: isDark ? Colors.white38 : Colors.black45,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 28),

                      Row(
                        children: [
                          OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(
                                color: isDark ? Colors.red[900]! : Colors.red[200]!,
                              ),
                              foregroundColor: Colors.red[400],
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            onPressed: () {
                              notifier.deleteSchedule(schedule.id);
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Jadwal "${schedule.title}" dihapus.'),
                                  behavior: SnackBarBehavior.floating,
                                ),
                              );
                            },
                            child: const Icon(Icons.delete_forever_rounded, color: Colors.redAccent),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: OutlinedButton.icon(
                              style: OutlinedButton.styleFrom(
                                side: BorderSide(
                                  color: isDark ? Colors.white24 : Colors.black12,
                                ),
                                foregroundColor: isDark ? Colors.white : Colors.black87,
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                              onPressed: () {
                                Navigator.pop(context);
                                _showScheduleBottomSheet(context, notifier, schedule: schedule);
                              },
                              icon: const Icon(Icons.edit_rounded, size: 18),
                              label: const Text(
                                "Edit",
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            flex: 2,
                            child: ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: color,
                                foregroundColor: Colors.white,
                                elevation: 0,
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                              onPressed: () {
                                Navigator.pop(context);
                                ref.read(timerViewModelProvider.notifier).setDuration(
                                      schedule.durationMinutes * 60,
                                      schedule: schedule,
                                    );
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) => const FocusTimerPage(),
                                  ),
                                );
                              },
                              icon: const Icon(Icons.play_arrow_rounded),
                              label: const Text(
                                "Mulai Sesi",
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  /// Tampilkan Bottom Sheet Formulir Jadwal yang Mewah & Estetik
  void _showScheduleBottomSheet(BuildContext context, DashboardNotifier notifier, {ScheduleModel? schedule}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _ScheduleForm(notifier: notifier, schedule: schedule),
    );
  }

  /// Tampilkan Bottom Sheet Formulir Tugas/Task yang Mewah & Estetik
  void _showTaskBottomSheet(BuildContext context, DashboardNotifier notifier, {TaskModel? task}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _TaskForm(notifier: notifier, task: task),
    );
  }

  /// Widget untuk merender satu item kartu tugas harian
  Widget _buildTaskCard(
    BuildContext context,
    WidgetRef ref,
    TaskModel task,
    DashboardNotifier notifier,
  ) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final color = isDark ? AppColors.darkPrimary : AppColors.lightPrimary;

    return Dismissible(
      key: Key('task_${task.uid}'),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: AppSpacing.xl),
        decoration: BoxDecoration(
          color: AppColors.lightError.withValues(alpha: 0.8),
          borderRadius: AppSpacing.borderMd,
        ),
        child: const Icon(Icons.delete_sweep_rounded, color: Colors.white, size: 28),
      ),
      onDismissed: (_) {
        notifier.deleteTask(task.id);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Tugas "${task.title}" dihapus.'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      },
      child: Card(
        clipBehavior: Clip.antiAlias,
        elevation: task.isCompleted ? 0 : 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: BorderSide(
            color: isDark ? Colors.grey[850]! : Colors.grey[300]!,
            width: 1,
          ),
        ),
        child: Container(
          decoration: BoxDecoration(
            color: task.isCompleted
                ? (isDark ? Colors.grey[900]!.withValues(alpha: 0.3) : Colors.grey[100]!.withValues(alpha: 0.5))
                : (isDark ? AppColors.darkSurface : AppColors.lightSurface),
            border: Border(
              left: BorderSide(
                color: task.isCompleted ? Colors.grey.withValues(alpha: 0.5) : color,
                width: 6,
              ),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.md),
            child: Row(
              children: [
                // Checklist Kotak Kurang Bulat Premium & Interaktif
                GestureDetector(
                  onTap: () async {
                    if (!task.isCompleted) {
                      // Tampilkan dialog konfirmasi penyelesaian tugas
                      final confirm = await showDialog<bool>(
                        context: context,
                        builder: (context) => AlertDialog(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                            side: BorderSide(
                              color: isDark ? Colors.grey[850]! : Colors.grey[300]!,
                              width: 1,
                            ),
                          ),
                          backgroundColor: isDark ? AppColors.darkSurface : AppColors.lightSurface,
                          title: Row(
                            children: [
                              Icon(
                                Icons.offline_pin_rounded,
                                color: color,
                                size: 28,
                              ),
                              const SizedBox(width: 12),
                              Text(
                                'Selesaikan Tugas?',
                                style: TextStyle(
                                  fontFamily: 'Outfit',
                                  fontWeight: FontWeight.bold,
                                  color: isDark ? Colors.white : Colors.black87,
                                ),
                              ),
                            ],
                          ),
                          content: Text(
                            'Apakah Anda yakin ingin menandai tugas "${task.title}" sebagai selesai?',
                            style: TextStyle(
                              fontFamily: 'Outfit',
                              color: isDark ? Colors.white70 : Colors.black87,
                            ),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context, false),
                              child: Text(
                                'Batal',
                                style: TextStyle(
                                  fontFamily: 'Outfit',
                                  color: isDark ? Colors.grey[400] : Colors.grey[600],
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: color,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                elevation: 0,
                              ),
                              onPressed: () => Navigator.pop(context, true),
                              child: const Text(
                                'Ya, Selesaikan',
                                style: TextStyle(
                                  fontFamily: 'Outfit',
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                      if (confirm == true) {
                        notifier.toggleCompleteTask(task);
                      }
                    } else {
                      // Jika membatalkan penyelesaian, toggle langsung tanpa konfirmasi
                      notifier.toggleCompleteTask(task);
                    }
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    margin: const EdgeInsets.only(right: AppSpacing.sm),
                    width: 26,
                    height: 26,
                    decoration: BoxDecoration(
                      color: task.isCompleted ? color : Colors.transparent,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: task.isCompleted ? color : color.withValues(alpha: 0.6),
                        width: 2,
                      ),
                      boxShadow: task.isCompleted
                          ? [
                              BoxShadow(
                                color: color.withValues(alpha: 0.4),
                                blurRadius: 8,
                                spreadRadius: 1,
                              )
                            ]
                          : null,
                    ),
                    child: task.isCompleted
                        ? const Icon(
                            Icons.check_rounded,
                            color: Colors.white,
                            size: 16,
                          ).animate().scale(curve: Curves.elasticOut)
                        : null,
                  ),
                ),
                const SizedBox(width: AppSpacing.xs),
                // Text Detail
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        task.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTypography.bodyLarge.copyWith(
                          fontWeight: FontWeight.bold,
                          decoration: task.isCompleted ? TextDecoration.lineThrough : null,
                          color: task.isCompleted
                              ? (isDark ? AppColors.darkOnSurfaceVariant : AppColors.lightOnSurfaceVariant)
                              : (isDark ? AppColors.darkOnBackground : AppColors.lightOnBackground),
                        ),
                      ),
                      if (task.description != null && task.description!.trim().isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Text(
                          task.description!,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: AppTypography.bodyMedium.copyWith(
                            decoration: task.isCompleted ? TextDecoration.lineThrough : null,
                            color: isDark ? AppColors.darkOnSurfaceVariant : AppColors.lightOnSurfaceVariant,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                // Edit Button
                IconButton(
                  icon: Icon(
                    Icons.edit_rounded,
                    size: 20,
                    color: isDark ? AppColors.darkOnSurfaceVariant : AppColors.lightOnSurfaceVariant,
                  ),
                  onPressed: () => _showTaskBottomSheet(context, notifier, task: task),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

}

class _ScheduleForm extends StatefulWidget {
  final DashboardNotifier notifier;
  final ScheduleModel? schedule;
  const _ScheduleForm({required this.notifier, this.schedule});

  @override
  State<_ScheduleForm> createState() => _ScheduleFormState();
}

class _ScheduleFormState extends State<_ScheduleForm> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _descController;
  
  late DateTime _selectedDate;
  late TimeOfDay _startTime;
  late TimeOfDay _endTime;
  
  late Color _selectedColor;
  late List<int> _selectedDays;
  late bool _wrapUpAlarmEnabled;
  late int _wrapUpMinutesBefore;

  @override
  void initState() {
    super.initState();
    final schedule = widget.schedule;
    _titleController = TextEditingController(text: schedule?.title ?? '');
    _descController = TextEditingController(text: schedule?.description ?? '');
    
    if (schedule != null) {
      _startTime = TimeOfDay(hour: schedule.startTime.hour, minute: schedule.startTime.minute);
      _endTime = TimeOfDay(hour: schedule.endTime.hour, minute: schedule.endTime.minute);
      _selectedColor = Color(schedule.colorValue);
      _selectedDays = List.from(schedule.activeDays);
      _wrapUpAlarmEnabled = schedule.wrapUpAlarmEnabled;
      _wrapUpMinutesBefore = schedule.wrapUpMinutesBefore;
      _selectedDate = schedule.startTime;
    } else {
      final now = DateTime.now();
      _startTime = TimeOfDay(hour: now.hour, minute: now.minute);
      final oneHourLater = now.add(const Duration(hours: 1));
      _endTime = TimeOfDay(hour: oneHourLater.hour, minute: oneHourLater.minute);
      _selectedColor = AppColors.categoryColors[0];
      _selectedDays = [now.weekday - 1];
      _wrapUpAlarmEnabled = true;
      _wrapUpMinutesBefore = 5;
      _selectedDate = now;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.fromSeed(
              seedColor: _selectedColor,
              brightness: Theme.of(context).brightness,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
        _selectedDays = [picked.weekday - 1];
      });
    }
  }

  Future<void> _selectTime(BuildContext context, bool isStart) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: isStart ? _startTime : _endTime,
      initialEntryMode: TimePickerEntryMode.input,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.fromSeed(
              seedColor: _selectedColor,
              brightness: Theme.of(context).brightness,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          _startTime = picked;
        } else {
          _endTime = picked;
        }
      });
    }
  }

  String _formatSelectedDate(DateTime date) {
    final days = ['Minggu', 'Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu'];
    final months = [
      'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
      'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
    ];
    return "${days[date.weekday % 7]}, ${date.day} ${months[date.month - 1]} ${date.year}";
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 20,
            spreadRadius: 5,
          ),
        ],
      ),
      padding: EdgeInsets.only(
        top: AppSpacing.xl,
        left: AppSpacing.xl,
        right: AppSpacing.xl,
        bottom: MediaQuery.of(context).viewInsets.bottom + AppSpacing.xl,
      ),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Indicator bar
              Center(
                child: Container(
                  width: 50,
                  height: 5,
                  decoration: BoxDecoration(
                    color: isDark ? Colors.grey[800] : Colors.grey[300],
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                widget.schedule != null ? 'Edit Jadwal Belajar' : 'Tambah Jadwal Baru',
                style: AppTypography.headlineMedium.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: AppSpacing.lg),

              // Task Title
              TextFormField(
                controller: _titleController,
                style: AppTypography.bodyLarge,
                decoration: const InputDecoration(
                  labelText: 'Aktivitas Belajar (misal: Belajar Rust)',
                  prefixIcon: Icon(Icons.title_rounded),
                ),
                validator: (val) => val == null || val.trim().isEmpty ? 'Nama aktivitas wajib diisi' : null,
              ),
              const SizedBox(height: AppSpacing.md),

              // Description
              TextFormField(
                controller: _descController,
                style: AppTypography.bodyMedium,
                decoration: const InputDecoration(
                  labelText: 'Deskripsi / Rencana Target (Opsional)',
                  prefixIcon: Icon(Icons.description_rounded),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),

              // Unified Date & Time Bento Card
              Text('Tanggal & Waktu Belajar', style: AppTypography.bodyLarge.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: AppSpacing.sm),
              Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(
                    color: _selectedColor.withValues(alpha: 0.25),
                    width: 1.5,
                  ),
                ),
                child: Column(
                  children: [
                    // Tap target for Date Selection
                    InkWell(
                      onTap: () => _selectDate(context),
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(16),
                        topRight: Radius.circular(16),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(AppSpacing.md),
                        child: Row(
                          children: [
                            Icon(Icons.calendar_month_rounded, color: _selectedColor, size: 24),
                            const SizedBox(width: AppSpacing.md),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'TANGGAL BELAJAR',
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 1.2,
                                      color: isDark ? Colors.white54 : Colors.black54,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    _formatSelectedDate(_selectedDate),
                                    style: AppTypography.titleMedium.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Icon(
                              Icons.keyboard_arrow_right_rounded,
                              color: isDark ? Colors.white38 : Colors.black38,
                            ),
                          ],
                        ),
                      ),
                    ),
                    Divider(color: _selectedColor.withValues(alpha: 0.15), height: 1),
                    // Start & End Time select row
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                      child: Row(
                        children: [
                          Expanded(
                            child: InkWell(
                              onTap: () => _selectTime(context, true),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                                child: Column(
                                  children: [
                                    Text(
                                      'JAM MULAI',
                                      style: TextStyle(
                                        fontSize: 9,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 1.0,
                                        color: isDark ? Colors.white54 : Colors.black54,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      _startTime.format(context),
                                      style: AppTypography.headlineMedium.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: _selectedColor,
                                        fontFamily: 'monospace',
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          Container(
                            height: 45,
                            width: 1,
                            color: _selectedColor.withValues(alpha: 0.15),
                          ),
                          Expanded(
                            child: InkWell(
                              onTap: () => _selectTime(context, false),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                                child: Column(
                                  children: [
                                    Text(
                                      'JAM SELESAI',
                                      style: TextStyle(
                                        fontSize: 9,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 1.0,
                                        color: isDark ? Colors.white54 : Colors.black54,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      _endTime.format(context),
                                      style: AppTypography.headlineMedium.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: _selectedColor,
                                        fontFamily: 'monospace',
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.lg),

              // Wrap-up Alarm settings
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Wrap-up Alarm', style: AppTypography.bodyLarge.copyWith(fontWeight: FontWeight.bold)),
                      Text('Pengingat 5 menit sebelum selesai', style: AppTypography.bodySmall.copyWith(color: isDark ? Colors.white38 : Colors.black38)),
                    ],
                  ),
                  Switch(
                    value: _wrapUpAlarmEnabled,
                    activeThumbColor: isDark ? AppColors.darkPrimary : AppColors.lightPrimary,
                    onChanged: (val) {
                      setState(() {
                        _wrapUpAlarmEnabled = val;
                      });
                    },
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),

              const SizedBox(height: AppSpacing.xl),

              // Submit Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                    shape: RoundedRectangleBorder(borderRadius: AppSpacing.borderMd),
                  ),
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      // Konversi tanggal terpilih dan waktu menjadi DateTime
                      final startDateTime = DateTime(
                        _selectedDate.year, _selectedDate.month, _selectedDate.day,
                        _startTime.hour, _startTime.minute,
                      );
                      
                      var endDateTime = DateTime(
                        _selectedDate.year, _selectedDate.month, _selectedDate.day,
                        _endTime.hour, _endTime.minute,
                      );

                      // Jika jam selesai mendahului jam mulai, asumsikan melewati tengah malam
                      if (endDateTime.isBefore(startDateTime)) {
                        endDateTime = endDateTime.add(const Duration(days: 1));
                      }

                      if (widget.schedule != null) {
                        widget.notifier.updateSchedule(
                          id: widget.schedule!.id,
                          uid: widget.schedule!.uid,
                          title: _titleController.text.trim(),
                          description: _descController.text.trim(),
                          startTime: startDateTime,
                          endTime: endDateTime,
                          activeDays: _selectedDays,
                          colorValue: _selectedColor.toARGB32(),
                          isActive: widget.schedule!.isActive,
                          wrapUpAlarmEnabled: _wrapUpAlarmEnabled,
                          wrapUpMinutesBefore: _wrapUpMinutesBefore,
                        );
                      } else {
                        widget.notifier.createSchedule(
                          title: _titleController.text.trim(),
                          description: _descController.text.trim(),
                          startTime: startDateTime,
                          endTime: endDateTime,
                          activeDays: _selectedDays,
                          colorValue: _selectedColor.toARGB32(),
                        );
                      }

                      Navigator.of(context).pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(widget.schedule != null
                              ? 'Jadwal berhasil diperbarui!'
                              : 'Jadwal baru berhasil dibuat!'),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    }
                  },
                  child: Text(
                    widget.schedule != null ? 'Simpan Perubahan' : 'Simpan Jadwal',
                    style: AppTypography.titleMedium.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ModernFabMenu extends StatefulWidget {
  final DashboardNotifier notifier;
  final VoidCallback onAddSchedule;
  final VoidCallback onAddTask;

  const ModernFabMenu({
    super.key,
    required this.notifier,
    required this.onAddSchedule,
    required this.onAddTask,
  });

  @override
  State<ModernFabMenu> createState() => _ModernFabMenuState();
}

class _ModernFabMenuState extends State<ModernFabMenu> with SingleTickerProviderStateMixin {
  bool _isExpanded = false;

  void _toggleMenu() {
    setState(() {
      _isExpanded = !_isExpanded;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Stack(
      alignment: Alignment.bottomRight,
      clipBehavior: Clip.none,
      children: [
        // Backdrop click handler to close menu
        if (_isExpanded)
          GestureDetector(
            onTap: _toggleMenu,
            child: Container(
              color: Colors.transparent,
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
            ),
          ),

        // Dropdown Menu Container (Floating above the FAB)
        AnimatedPositioned(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOutBack,
          bottom: _isExpanded ? 70 : 30,
          right: 0,
          child: AnimatedScale(
            duration: const Duration(milliseconds: 200),
            scale: _isExpanded ? 1.0 : 0.0,
            alignment: Alignment.bottomRight,
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 150),
              opacity: _isExpanded ? 1.0 : 0.0,
              child: Container(
                width: 200,
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E1E2E).withValues(alpha: 0.95) : Colors.white.withValues(alpha: 0.95),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isDark ? Colors.white12 : Colors.black12,
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.15),
                      blurRadius: 15,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Item: Tambah Jadwal
                      Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () {
                            _toggleMenu();
                            widget.onAddSchedule();
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: theme.primaryColor.withValues(alpha: 0.15),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    Icons.calendar_today_rounded,
                                    size: 18,
                                    color: theme.primaryColor,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    'Tambah Jadwal',
                                    style: AppTypography.bodyMedium.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: isDark ? Colors.white : Colors.black87,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Divider(
                        height: 1,
                        thickness: 1,
                        color: isDark ? Colors.white10 : Colors.black12,
                      ),
                      // Item: Tambah Tugas
                      Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () {
                            _toggleMenu();
                            widget.onAddTask();
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.teal.withValues(alpha: 0.15),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.checklist_rounded,
                                    size: 18,
                                    color: Colors.teal,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    'Tambah Tugas',
                                    style: AppTypography.bodyMedium.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: isDark ? Colors.white : Colors.black87,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),

        // Main FAB
        GestureDetector(
          onTap: _toggleMenu,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: _isExpanded ? (isDark ? Colors.grey[850] : Colors.grey[300]) : theme.primaryColor,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: (_isExpanded ? Colors.black : theme.primaryColor).withValues(alpha: 0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Center(
              child: AnimatedRotation(
                duration: const Duration(milliseconds: 250),
                turns: _isExpanded ? 0.125 : 0.0, // 45 degrees rotation for X shape
                child: Icon(
                  Icons.add_rounded,
                  color: _isExpanded ? (isDark ? Colors.white : Colors.black87) : Colors.white,
                  size: 28,
                ),
              ),
            ),
          ),
        ).animate().scale(delay: 400.ms, curve: Curves.elasticOut),
      ],
    );
  }
}

class _TaskForm extends StatefulWidget {
  final DashboardNotifier notifier;
  final TaskModel? task;

  const _TaskForm({
    required this.notifier,
    this.task,
  });

  @override
  State<_TaskForm> createState() => _TaskFormState();
}

class _TaskFormState extends State<_TaskForm> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _descController;
  late Color _selectedColor;
  late DateTime _selectedDate;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.task?.title ?? '');
    _descController = TextEditingController(text: widget.task?.description ?? '');
    _selectedColor = AppColors.categoryColors[0];
    _selectedDate = widget.task?.createdAt ?? DateTime.now();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        final color = isDark ? AppColors.darkPrimary : AppColors.lightPrimary;
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.fromSeed(
              seedColor: color,
              brightness: Theme.of(context).brightness,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  String _formatSelectedDate(DateTime date) {
    final days = ['Minggu', 'Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu'];
    final months = [
      'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
      'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
    ];
    return "${days[date.weekday % 7]}, ${date.day} ${months[date.month - 1]} ${date.year}";
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkBackground : AppColors.lightBackground,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(28),
          topRight: Radius.circular(28),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 20,
            spreadRadius: 2,
          ),
        ],
      ),
      padding: EdgeInsets.only(
        left: AppSpacing.lg,
        right: AppSpacing.lg,
        top: AppSpacing.md,
        bottom: MediaQuery.of(context).viewInsets.bottom + AppSpacing.lg,
      ),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Decorative pill at top
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: isDark ? Colors.white24 : Colors.black12,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.md),

              // Title
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    widget.task != null ? 'Edit Tugas' : 'Buat Tugas Baru',
                    style: AppTypography.titleLarge.copyWith(fontWeight: FontWeight.bold),
                  ),
                  if (widget.task != null)
                    IconButton(
                      icon: const Icon(Icons.delete_forever_rounded, color: AppColors.lightError),
                      onPressed: () {
                        widget.notifier.deleteTask(widget.task!.id);
                        Navigator.of(context).pop();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Tugas berhasil dihapus!'),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      },
                    ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),

              // Input Title
              Text(
                'Nama Tugas',
                style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: AppSpacing.xs),
              TextFormField(
                controller: _titleController,
                style: AppTypography.bodyLarge,
                decoration: InputDecoration(
                  hintText: 'Misal: Belajar Kalkulus Bab 3',
                  prefixIcon: const Icon(Icons.edit_note_rounded),
                  filled: true,
                  fillColor: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.03),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(color: _selectedColor, width: 2),
                  ),
                ),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return 'Judul tugas tidak boleh kosong!';
                  }
                  return null;
                },
              ),
              const SizedBox(height: AppSpacing.md),

              // Input Description
              Text(
                'Deskripsi / Catatan (Opsional)',
                style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: AppSpacing.xs),
              TextFormField(
                controller: _descController,
                style: AppTypography.bodyLarge,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: 'Tambahkan detail tugas atau langkah-langkah belajar...',
                  prefixIcon: const Icon(Icons.description_rounded),
                  filled: true,
                  fillColor: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.03),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(color: _selectedColor, width: 2),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.md),

              // Bento-Style Date Picker Card for Task
              Text('Tanggal Pelaksanaan', style: AppTypography.bodyLarge.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: AppSpacing.sm),
              Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(
                    color: _selectedColor.withValues(alpha: 0.25),
                    width: 1.5,
                  ),
                ),
                child: InkWell(
                  onTap: () => _selectDate(context),
                  borderRadius: BorderRadius.circular(16),
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    child: Row(
                      children: [
                        Icon(Icons.calendar_month_rounded, color: _selectedColor, size: 24),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'TANGGAL TUGAS',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1.2,
                                  color: isDark ? Colors.white54 : Colors.black54,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                _formatSelectedDate(_selectedDate),
                                style: AppTypography.titleMedium.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Icon(
                          Icons.keyboard_arrow_right_rounded,
                          color: isDark ? Colors.white38 : Colors.black38,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.xl),

              // Actions Buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Batal'),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _selectedColor,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          if (widget.task != null) {
                            // Update
                            widget.notifier.updateTask(
                              widget.task!.copyWith(
                                title: _titleController.text.trim(),
                                description: _descController.text.trim(),
                                colorValue: _selectedColor.toARGB32(),
                                createdAt: _selectedDate,
                              ),
                            );
                          } else {
                            // Create
                            widget.notifier.createTask(
                              title: _titleController.text.trim(),
                              description: _descController.text.trim(),
                              colorValue: _selectedColor.toARGB32(),
                              createdAt: _selectedDate,
                            );
                          }

                          Navigator.of(context).pop();
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(widget.task != null
                                  ? 'Tugas berhasil diperbarui!'
                                  : 'Tugas baru berhasil dibuat!'),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        }
                      },
                      child: Text(
                        widget.task != null ? 'Simpan Perubahan' : 'Buat Tugas',
                        style: AppTypography.titleMedium.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

