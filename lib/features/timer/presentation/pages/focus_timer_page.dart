import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_typography.dart';
import '../view_models/timer_view_model.dart';

class FocusTimerPage extends ConsumerWidget {
  const FocusTimerPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final timerState = ref.watch(timerViewModelProvider);
    final timerNotifier = ref.read(timerViewModelProvider.notifier);

    // Konversi detik tersisa menjadi format MM:SS
    final minutes = (timerState.remainingSeconds ~/ 60).toString().padLeft(2, '0');
    final seconds = (timerState.remainingSeconds % 60).toString().padLeft(2, '0');
    
    // Hitung persentase progress
    final progress = timerState.totalSeconds > 0
        ? timerState.remainingSeconds / timerState.totalSeconds
        : 0.0;

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () async {
            if (timerState.status == TimerStatus.running) {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  backgroundColor: isDark ? AppColors.darkSurface : AppColors.lightSurface,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                    side: BorderSide(
                      color: isDark ? AppColors.darkOutline : AppColors.lightOutline,
                      width: 0.8,
                    ),
                  ),
                  title: Text('Batalkan Sesi?', style: AppTypography.titleLarge),
                  content: const Text('Kemajuan sesi belajar saat ini tidak akan disimpan secara penuh.'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      child: const Text('Batal'),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.lightError,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed: () => Navigator.of(context).pop(true),
                      child: const Text('Ya, Keluar', style: TextStyle(color: Colors.white)),
                    ),
                  ],
                ),
              );
              if (confirm != true) return;
            }
            await timerNotifier.completeTimer();
            if (context.mounted) {
              Navigator.of(context).pop();
            }
          },
        ),
        title: Text('Focus Timer', style: AppTypography.titleLarge),
        centerTitle: true,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Info Jadwal / Aktivitas
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.lg,
                  vertical: AppSpacing.md,
                ),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkSurfaceVariant : AppColors.lightSurfaceVariant,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isDark ? AppColors.darkOutline : AppColors.lightOutline,
                    width: 0.8,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.menu_book_rounded,
                      color: timerState.status == TimerStatus.running
                          ? (isDark ? AppColors.darkPrimary : AppColors.lightPrimary)
                          : (isDark ? AppColors.darkOnSurfaceVariant : AppColors.lightOnSurfaceVariant),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Text(
                      timerState.currentSchedule?.title ?? 'Sesi Fokus Mandiri',
                      style: AppTypography.titleMedium.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ).animate().fade().slideY(begin: -0.2, curve: Curves.easeOutQuad),
              
              const SizedBox(height: AppSpacing.xxl),

              // Visualisasi Timer Bulat Premium
              Stack(
                alignment: Alignment.center,
                children: [
                  // Outer Glow / Ring Bayangan
                  Container(
                    width: 280,
                    height: 280,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: (isDark ? AppColors.darkPrimary : AppColors.lightPrimary)
                              .withOpacity(timerState.status == TimerStatus.running ? 0.06 : 0.01),
                          blurRadius: 40,
                          spreadRadius: 10,
                        ),
                      ],
                    ),
                  ),
                  // Progress Indicator Melingkar Lebih Tipis & Modern
                  SizedBox(
                    width: 260,
                    height: 260,
                    child: CircularProgressIndicator(
                      value: progress,
                      strokeWidth: 6,
                      backgroundColor: (isDark ? AppColors.darkOutline : AppColors.lightOutline).withOpacity(0.3),
                      valueColor: AlwaysStoppedAnimation<Color>(
                        isDark ? AppColors.darkPrimary : AppColors.lightPrimary,
                      ),
                    ),
                  ),
                  // Angka Hitung Mundur & Status
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '$minutes:$seconds',
                        style: AppTypography.displayLarge.copyWith(
                          fontWeight: FontWeight.w200,
                          fontSize: 64,
                          letterSpacing: 2,
                          color: timerState.status == TimerStatus.running
                              ? (isDark ? AppColors.darkPrimary : AppColors.lightPrimary)
                              : null,
                        ),
                      ).animate(
                        target: timerState.status == TimerStatus.running ? 1 : 0,
                        onPlay: (controller) => controller.repeat(reverse: true),
                      ).scale(
                        begin: const Offset(1, 1),
                        end: const Offset(1.02, 1.02),
                        duration: const Duration(seconds: 2),
                        curve: Curves.easeInOut,
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        timerState.status == TimerStatus.running
                            ? 'FOKUS'
                            : timerState.status == TimerStatus.paused
                                ? 'PAUSED'
                                : 'READY',
                        style: AppTypography.labelLarge.copyWith(
                          letterSpacing: 3,
                          fontWeight: FontWeight.bold,
                          color: isDark ? AppColors.darkOnSurfaceVariant : AppColors.lightOnSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ],
              ).animate().scale(delay: const Duration(milliseconds: 100), curve: Curves.elasticOut, duration: 800.ms),

              const SizedBox(height: AppSpacing.xxl),

              // Tombol-Tombol Aksi Utama
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Tombol Reset (Bento Style)
                  if (timerState.status != TimerStatus.idle) ...[
                    IconButton.filledTonal(
                      style: IconButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.all(AppSpacing.md),
                      ),
                      icon: const Icon(Icons.replay_rounded, size: 28),
                      onPressed: () {
                        timerNotifier.resetTimer();
                      },
                    ).animate().fade().scale(),
                    const SizedBox(width: AppSpacing.lg),
                  ],

                  // Tombol Utama (Play / Pause)
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      elevation: 2,
                      backgroundColor: isDark ? AppColors.darkPrimary : AppColors.lightPrimary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.xl * 1.5,
                        vertical: AppSpacing.lg,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: () {
                      if (timerState.status == TimerStatus.running) {
                        timerNotifier.pauseTimer();
                      } else {
                        timerNotifier.startTimer();
                      }
                    },
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          timerState.status == TimerStatus.running
                              ? Icons.pause_rounded
                              : Icons.play_arrow_rounded,
                          size: 28,
                          color: Colors.white,
                        ),
                        const SizedBox(width: AppSpacing.xs),
                        Text(
                          timerState.status == TimerStatus.running ? 'Pause' : 'Mulai',
                          style: AppTypography.titleMedium.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Tombol Selesai Lebih Cepat / Skip (Bento Style)
                  if (timerState.status != TimerStatus.idle) ...[
                    const SizedBox(width: AppSpacing.lg),
                    IconButton.filledTonal(
                      style: IconButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.all(AppSpacing.md),
                      ),
                      icon: const Icon(Icons.done_rounded, size: 28),
                      onPressed: () async {
                        final confirm = await showDialog<bool>(
                          context: context,
                          builder: (context) => AlertDialog(
                            backgroundColor: isDark ? AppColors.darkSurface : AppColors.lightSurface,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                              side: BorderSide(
                                color: isDark ? AppColors.darkOutline : AppColors.lightOutline,
                                width: 0.8,
                              ),
                            ),
                            title: Text('Selesaikan Sesi?', style: AppTypography.titleLarge),
                            content: const Text('Apakah Anda ingin menyelesaikan sesi belajar ini sekarang? Durasi belajar aktual Anda tetap akan disimpan.'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.of(context).pop(false),
                                child: const Text('Batal'),
                              ),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: isDark ? AppColors.darkPrimary : AppColors.lightPrimary,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                onPressed: () => Navigator.of(context).pop(true),
                                child: const Text('Selesai', style: TextStyle(color: Colors.white)),
                              ),
                            ],
                          ),
                        );
                        if (confirm == true) {
                          await timerNotifier.completeTimer();
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Sesi belajar berhasil disimpan! 🎉'),
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                            Navigator.of(context).pop();
                          }
                        }
                      },
                    ).animate().fade().scale(),
                  ],
                ],
              ).animate().fade(delay: 200.ms).slideY(begin: 0.2, curve: Curves.easeOutQuad),
            ],
          ),
        ),
      ),
    );

  }
}
