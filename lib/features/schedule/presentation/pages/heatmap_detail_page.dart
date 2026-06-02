import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../timer/data/repositories/session_repository.dart';
import '../../../timer/data/models/session_model.dart';
import '../view_models/dashboard_view_model.dart';

class HeatmapDetailPage extends ConsumerStatefulWidget {
  final DateTime? initialSelectedDate;

  const HeatmapDetailPage({
    super.key,
    this.initialSelectedDate,
  });

  @override
  ConsumerState<HeatmapDetailPage> createState() => _HeatmapDetailPageState();
}

class _HeatmapDetailPageState extends ConsumerState<HeatmapDetailPage> {
  late DateTime _selectedDate;
  String _intensityFilter = 'Semua'; // Semua, Ringan, Sedang, Fokus, Maksimal
  String _periodFilter = 'Bulan Ini'; // Bulan Ini, 3 Bulan Terakhir, Tahun Ini
  
  List<SessionModel> _selectedDaySessions = [];
  bool _isLoadingSessions = false;

  final List<String> _monthsIndonesian = [
    'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
    'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
  ];

  final List<String> _daysIndonesian = [
    'Minggu', 'Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu'
  ];

  @override
  void initState() {
    super.initState();
    final today = DateTime.now();
    _selectedDate = widget.initialSelectedDate ?? DateTime(today.year, today.month, today.day);
    _loadSessionsForDate(_selectedDate);
  }

  Future<void> _loadSessionsForDate(DateTime date) async {
    setState(() {
      _isLoadingSessions = true;
    });

    try {
      final sessionRepo = ref.read(sessionRepositoryProvider);
      final sessions = await sessionRepo.getSessionsByDate(date);
      setState(() {
        _selectedDaySessions = sessions;
        _isLoadingSessions = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingSessions = false;
      });
    }
  }

  void _selectDate(DateTime date) {
    setState(() {
      _selectedDate = DateTime(date.year, date.month, date.day);
    });
    _loadSessionsForDate(_selectedDate);
  }

  // Format durasi detik menjadi string (misal: "1 Jam 15 Menit" atau "25 Menit")
  String _formatDuration(int seconds) {
    if (seconds <= 0) return '0 Menit';
    final minutes = (seconds > 0 && seconds < 60) ? 1 : seconds ~/ 60;
    if (minutes < 60) {
      return '$minutes Menit';
    } else {
      final hours = minutes ~/ 60;
      final remainingMinutes = minutes % 60;
      if (remainingMinutes == 0) {
        return '$hours Jam';
      }
      return '$hours Jam $remainingMinutes Menit';
    }
  }

  // Membantu menghitung total durasi dalam periode terfilter
  int _calculateTotalDuration(Map<DateTime, int> dailyDurations, List<DateTime> periodDates) {
    int total = 0;
    for (final date in periodDates) {
      final sec = dailyDurations[date] ?? 0;
      final minutes = (sec > 0 && sec < 60) ? 1 : sec ~/ 60;
      if (_passesIntensityFilter(minutes)) {
        total += sec;
      }
    }
    return total;
  }

  // Apakah sebuah intensitas menit memenuhi kriteria filter aktif
  bool _passesIntensityFilter(int minutes) {
    if (_intensityFilter == 'Semua') return true;
    if (_intensityFilter == 'Ringan' && minutes > 0 && minutes < 15) return true;
    if (_intensityFilter == 'Sedang' && minutes >= 15 && minutes < 45) return true;
    if (_intensityFilter == 'Fokus' && minutes >= 45 && minutes < 90) return true;
    if (_intensityFilter == 'Maksimal' && minutes >= 90) return true;
    return false;
  }

  // Mendapatkan warna visual kotak berdasarkan durasi menit belajar
  Color _getCellColor(int minutes, BuildContext context, bool isDark) {
    if (minutes == 0) {
      return isDark ? Colors.grey[900]! : Colors.grey[200]!;
    }
    
    // Jika tidak lolos filter intensitas, pudarkan warnanya
    if (!_passesIntensityFilter(minutes)) {
      return isDark ? Colors.grey[900]!.withValues(alpha: 0.3) : Colors.grey[200]!.withValues(alpha: 0.3);
    }

    final baseColor = isDark ? AppColors.darkPrimary : AppColors.lightPrimary;
    if (minutes < 15) {
      return baseColor.withValues(alpha: 0.2);
    } else if (minutes < 45) {
      return baseColor.withValues(alpha: 0.5);
    } else if (minutes < 90) {
      return baseColor.withValues(alpha: 0.8);
    } else {
      return baseColor;
    }
  }

  // Mendapatkan rentang tanggal untuk visualisasi berdasarkan filter periode
  List<DateTime> _getDatesForPeriod() {
    final today = DateTime.now();
    final todayNormalized = DateTime(today.year, today.month, today.day);

    if (_periodFilter == 'Bulan Ini') {
      final totalDays = DateTime(today.year, today.month + 1, 0).day;
      return List.generate(totalDays, (index) => DateTime(today.year, today.month, index + 1));
    } else if (_periodFilter == '3 Bulan Terakhir') {
      final start = todayNormalized.subtract(const Duration(days: 90));
      final difference = todayNormalized.difference(start).inDays + 1;
      return List.generate(difference, (index) => start.add(Duration(days: index)));
    } else {
      // Tahun Ini (sejak 1 Januari tahun ini hingga hari ini)
      final startOfYear = DateTime(today.year, 1, 1);
      final difference = todayNormalized.difference(startOfYear).inDays + 1;
      return List.generate(difference, (index) => startOfYear.add(Duration(days: index)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final dashboardState = ref.watch(dashboardViewModelProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final dates = _getDatesForPeriod();
    final totalSeconds = _calculateTotalDuration(dashboardState.dailyDurations, dates);
    
    // Menghitung statistik kepatuhan (completion rate) rata-rata
    int activeDaysWithSessions = 0;
    
    for (final date in dates) {
      final sec = dashboardState.dailyDurations[date] ?? 0;
      if (sec > 0) {
        activeDaysWithSessions++;
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Detail Analisis & Heatmap',
          style: AppTypography.titleMedium.copyWith(fontWeight: FontWeight.bold),
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // BENTO STATS SECTION
              _buildBentoStats(totalSeconds, activeDaysWithSessions, dashboardState.streakDays, isDark),
              const SizedBox(height: AppSpacing.lg),

              // FILTER PERIODE & INTENSITAS
              _buildFiltersSection(isDark),
              const SizedBox(height: AppSpacing.lg),

              // VISUALISASI HEATMAP UTAMA
              _buildHeatmapGridSection(dashboardState.dailyDurations, isDark),
              const SizedBox(height: AppSpacing.lg),

              // DETAIL HARIAN
              _buildDailyDetailSection(isDark),
              const SizedBox(height: AppSpacing.xl),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBentoStats(int totalSeconds, int activeDays, int streak, bool isDark) {
    final primaryColor = isDark ? AppColors.darkPrimary : AppColors.lightPrimary;

    return Row(
      children: [
        // Total Waktu Fokus
        Expanded(
          flex: 4,
          child: Card(
            elevation: 1,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.timer_rounded, color: primaryColor, size: 20),
                      const SizedBox(width: 6),
                      Text('Total Waktu', style: AppTypography.bodySmall),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    _formatDuration(totalSeconds),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.titleLarge.copyWith(
                      fontWeight: FontWeight.bold,
                      color: primaryColor,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Periode: $_periodFilter',
                    style: AppTypography.bodySmall.copyWith(fontSize: 10, color: Colors.grey),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        // Hari Aktif & Streak
        Expanded(
          flex: 3,
          child: Card(
            elevation: 1,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.workspace_premium_rounded, color: Colors.amber, size: 20),
                      const SizedBox(width: 6),
                      Text('Hari Aktif', style: AppTypography.bodySmall),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    '$activeDays Hari',
                    style: AppTypography.titleLarge.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      const Icon(Icons.local_fire_department_rounded, color: Colors.orange, size: 14),
                      const SizedBox(width: 2),
                      Text(
                        'Streak: $streak H',
                        style: AppTypography.bodySmall.copyWith(fontWeight: FontWeight.bold, color: Colors.orange),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    ).animate().fade().slideY(begin: 0.1, duration: 300.ms);
  }

  Widget _buildFiltersSection(bool isDark) {
    return Card(
      elevation: 0,
      color: isDark ? AppColors.darkSurface.withValues(alpha: 0.4) : AppColors.lightSurface.withValues(alpha: 0.4),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: isDark ? Colors.white10 : Colors.black12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Filter Periode
            Text('Rentang Periode', style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: AppSpacing.xs),
            Row(
              children: ['Bulan Ini', '3 Bulan Terakhir', 'Tahun Ini'].map((period) {
                final isSelected = _periodFilter == period;
                return Padding(
                  padding: const EdgeInsets.only(right: 6.0),
                  child: ChoiceChip(
                    label: Text(period),
                    selected: isSelected,
                    onSelected: (val) {
                      if (val) {
                        setState(() {
                          _periodFilter = period;
                        });
                      }
                    },
                    selectedColor: isDark ? AppColors.darkPrimary.withOpacity(0.12) : AppColors.lightPrimary.withOpacity(0.12),
                    backgroundColor: Colors.transparent,
                    side: BorderSide(
                      color: isSelected
                          ? (isDark ? AppColors.darkPrimary : AppColors.lightPrimary)
                          : (isDark ? Colors.grey[850]! : Colors.grey[300]!),
                      width: 0.8,
                    ),
                    labelStyle: TextStyle(
                      fontSize: 12,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      color: isSelected
                          ? (isDark ? AppColors.darkPrimary : AppColors.lightPrimary)
                          : (isDark ? Colors.grey[400] : Colors.grey[600]),
                    ),
                    showCheckmark: false,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                  ),
                );
              }).toList(),
            ),
            const Divider(height: AppSpacing.lg),
            // Filter Intensitas
            Text('Intensitas Belajar', style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: AppSpacing.xs),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: ['Semua', 'Ringan', 'Sedang', 'Fokus', 'Maksimal'].map((lvl) {
                  final isSelected = _intensityFilter == lvl;
                  return Padding(
                    padding: const EdgeInsets.only(right: 6.0),
                    child: ChoiceChip(
                      label: Text(
                        lvl == 'Semua' ? 'Semua' : '$lvl ${lvl == 'Ringan' ? '(<15m)' : lvl == 'Sedang' ? '(15m-45m)' : lvl == 'Fokus' ? '(45m-90m)' : '(>90m)'}',
                      ),
                      selected: isSelected,
                      onSelected: (val) {
                        if (val) {
                          setState(() {
                            _intensityFilter = lvl;
                          });
                        }
                      },
                      selectedColor: isDark ? AppColors.darkPrimary.withOpacity(0.12) : AppColors.lightPrimary.withOpacity(0.12),
                      backgroundColor: Colors.transparent,
                      side: BorderSide(
                        color: isSelected
                            ? (isDark ? AppColors.darkPrimary : AppColors.lightPrimary)
                            : (isDark ? Colors.grey[850]! : Colors.grey[300]!),
                        width: 0.8,
                      ),
                      labelStyle: TextStyle(
                        fontSize: 11,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        color: isSelected
                            ? (isDark ? AppColors.darkPrimary : AppColors.lightPrimary)
                            : (isDark ? Colors.grey[400] : Colors.grey[600]),
                      ),
                      showCheckmark: false,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    ).animate().fade(delay: 100.ms).slideY(begin: 0.1, duration: 300.ms);
  }

  Widget _buildHeatmapGridSection(Map<DateTime, int> dailyDurations, bool isDark) {
    if (_periodFilter == 'Tahun Ini') {
      // Menampilkan kalender komprehensif 12 bulan jika memilih Tahun Ini
      final now = DateTime.now();
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Kontribusi Kalender Tahunan (${now.year})',
            style: AppTypography.bodyLarge.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: AppSpacing.sm),
          _buildLegendRow(isDark),
          const SizedBox(height: AppSpacing.md),
          // Scroll vertikal daftar bulan
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: now.month, // Dari Januari sampai bulan saat ini
            itemBuilder: (context, idx) {
              final monthNum = idx + 1;
              return _buildSingleMonthCalendar(now.year, monthNum, dailyDurations, isDark);
            },
          ),
        ],
      ).animate().fade(delay: 200.ms);
    } else {
      // Bulan Ini atau 3 Bulan Terakhir
      return Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: BorderSide(color: isDark ? Colors.white10 : Colors.black12),
        ),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _periodFilter == 'Bulan Ini' ? 'Kalender Bulan Ini' : 'Kontribusi 90 Hari Terakhir',
                style: AppTypography.bodyLarge.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: AppSpacing.lg),
              _buildAdaptiveGrid(dailyDurations, isDark),
              const SizedBox(height: AppSpacing.md),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      'Tap kotak untuk detail sesi',
                      style: AppTypography.bodySmall.copyWith(fontSize: 10, color: Colors.grey),
                    ),
                  ),
                  _buildLegendRow(isDark),
                ],
              ),
            ],
          ),
        ),
      ).animate().fade(delay: 200.ms);
    }
  }

  Widget _buildSingleMonthCalendar(int year, int month, Map<DateTime, int> dailyDurations, bool isDark) {
    final firstDay = DateTime(year, month, 1);
    final totalDays = DateTime(year, month + 1, 0).day;
    final startOffset = firstDay.weekday % 7; // Sunday=0, Monday=1, ...
    
    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: isDark ? Colors.white10 : Colors.black12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${_monthsIndonesian[month - 1]} $year',
              style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.bold, color: isDark ? AppColors.darkPrimary : AppColors.lightPrimary),
            ),
            const SizedBox(height: AppSpacing.sm),
            // Header Hari
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: ['M', 'S', 'S', 'R', 'K', 'J', 'S'].map((day) {
                return Expanded(
                  child: Center(
                    child: Text(
                      day,
                      style: AppTypography.bodySmall.copyWith(fontWeight: FontWeight.bold, fontSize: 11, color: Colors.grey),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 6),
            // Grid Hari
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: startOffset + totalDays,
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
                final cellColor = _getCellColor(minutes, context, isDark);
                
                final isSelected = date.year == _selectedDate.year &&
                    date.month == _selectedDate.month &&
                    date.day == _selectedDate.day;

                return GestureDetector(
                  onTap: () => _selectDate(date),
                  child: Tooltip(
                    message: '$day ${_monthsIndonesian[month - 1]} — $minutes Menit Belajar',
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      decoration: BoxDecoration(
                        color: cellColor,
                        borderRadius: BorderRadius.circular(4),
                        border: isSelected
                            ? Border.all(
                                color: isDark ? AppColors.darkPrimary : AppColors.lightPrimary,
                                width: 1.0,
                              )
                            : Border.all(
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
          ],
        ),
      ),
    );
  }

  Widget _buildAdaptiveGrid(Map<DateTime, int> dailyDurations, bool isDark) {
    final today = DateTime.now();

    if (_periodFilter == 'Bulan Ini') {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: ['Min', 'Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab'].map((day) {
              return Expanded(
                child: Center(
                  child: Text(
                    day,
                    style: AppTypography.bodySmall.copyWith(fontWeight: FontWeight.bold, color: Colors.grey),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 6),
          _buildMonthGrid(today.year, today.month, dailyDurations, isDark),
        ],
      );
    } else {
      // 3 Bulan Terakhir
      final periodDates = _getDatesForPeriod();
      
      return Center(
        child: Wrap(
          spacing: 6,
          runSpacing: 6,
          children: List.generate(periodDates.length, (index) {
            final date = periodDates[index];
            final seconds = dailyDurations[date] ?? 0;
            final minutes = (seconds > 0 && seconds < 60) ? 1 : seconds ~/ 60;
            final cellColor = _getCellColor(minutes, context, isDark);
            
            final isSelected = date.year == _selectedDate.year &&
                date.month == _selectedDate.month &&
                date.day == _selectedDate.day;

            return GestureDetector(
              onTap: () => _selectDate(date),
              child: Tooltip(
                message: '${date.day} ${_monthsIndonesian[date.month - 1]} — $minutes Menit Belajar',
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  width: 22,
                  height: 22,
                  decoration: BoxDecoration(
                    color: cellColor,
                    borderRadius: BorderRadius.circular(4),
                    border: isSelected
                        ? Border.all(
                            color: isDark ? AppColors.darkPrimary : AppColors.lightPrimary,
                            width: 1.0,
                          )
                        : Border.all(
                            color: isDark ? Colors.white10 : Colors.black12,
                            width: 0.5,
                          ),
                  ),
                ),
              ),
            );
          }),
        ),
      );
    }
  }

  Widget _buildMonthGrid(int year, int month, Map<DateTime, int> dailyDurations, bool isDark) {
    final firstDay = DateTime(year, month, 1);
    final totalDays = DateTime(year, month + 1, 0).day;
    final startOffset = firstDay.weekday % 7; // Sunday = 0

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: startOffset + totalDays,
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
        final cellColor = _getCellColor(minutes, context, isDark);
        
        final isSelected = date.year == _selectedDate.year &&
            date.month == _selectedDate.month &&
            date.day == _selectedDate.day;

        return GestureDetector(
          onTap: () => _selectDate(date),
          child: Tooltip(
            message: '$day ${_monthsIndonesian[month - 1]} — $minutes Menit Belajar',
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              decoration: BoxDecoration(
                color: cellColor,
                borderRadius: BorderRadius.circular(4),
                border: isSelected
                    ? Border.all(
                        color: isDark ? AppColors.darkPrimary : AppColors.lightPrimary,
                        width: 1.0,
                      )
                    : Border.all(
                        color: isDark ? Colors.white10 : Colors.black12,
                        width: 0.5,
                      ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildLegendRow(bool isDark) {
    return Row(
      children: [
        Text('Min', style: AppTypography.bodySmall.copyWith(fontSize: 10)),
        const SizedBox(width: 4),
        Container(width: 8, height: 8, decoration: BoxDecoration(color: isDark ? Colors.grey[900]! : Colors.grey[200]!, borderRadius: BorderRadius.circular(2))),
        const SizedBox(width: 2),
        Container(width: 8, height: 8, decoration: BoxDecoration(color: (isDark ? AppColors.darkPrimary : AppColors.lightPrimary).withValues(alpha: 0.2), borderRadius: BorderRadius.circular(2))),
        const SizedBox(width: 2),
        Container(width: 8, height: 8, decoration: BoxDecoration(color: (isDark ? AppColors.darkPrimary : AppColors.lightPrimary).withValues(alpha: 0.5), borderRadius: BorderRadius.circular(2))),
        const SizedBox(width: 2),
        Container(width: 8, height: 8, decoration: BoxDecoration(color: (isDark ? AppColors.darkPrimary : AppColors.lightPrimary).withValues(alpha: 0.8), borderRadius: BorderRadius.circular(2))),
        const SizedBox(width: 2),
        Container(width: 8, height: 8, decoration: BoxDecoration(color: isDark ? AppColors.darkPrimary : AppColors.lightPrimary, borderRadius: BorderRadius.circular(2))),
        const SizedBox(width: 4),
        Text('Max', style: AppTypography.bodySmall.copyWith(fontSize: 10)),
      ],
    );
  }

  Widget _buildDailyDetailSection(bool isDark) {
    final formattedSelectedDate = '${_daysIndonesian[_selectedDate.weekday % 7]}, ${_selectedDate.day} ${_monthsIndonesian[_selectedDate.month - 1]} ${_selectedDate.year}';
    final primaryColor = isDark ? AppColors.darkPrimary : AppColors.lightPrimary;

    return Card(
      elevation: 0,
      color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: isDark ? Colors.white10 : Colors.black12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Tanggal Detail
            Row(
              children: [
                Icon(Icons.calendar_month_rounded, color: primaryColor, size: 22),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    formattedSelectedDate,
                    style: AppTypography.bodyLarge.copyWith(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const Divider(height: AppSpacing.lg),

            if (_isLoadingSessions)
              Column(
                children: List.generate(2, (_) => Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                  child: _buildSkeletonCard(context, isDark),
                )),
              )
            else if (_selectedDaySessions.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.xl),
                child: Center(
                  child: Column(
                    children: [
                      Icon(Icons.hourglass_empty_rounded, size: 48, color: Colors.grey[500]),
                      const SizedBox(height: AppSpacing.md),
                      Text(
                        'Tidak Ada Sesi Belajar',
                        style: AppTypography.bodyLarge.copyWith(fontWeight: FontWeight.bold, color: Colors.grey),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
                        child: Text(
                          'Mulai fokus dengan timer untuk mengisi kontribusi Anda!',
                          textAlign: TextAlign.center,
                          style: AppTypography.bodySmall.copyWith(color: Colors.grey[500]),
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else ...[
              Text(
                'Daftar Sesi Fokus (${_selectedDaySessions.length})',
                style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.bold, color: primaryColor),
              ),
              const SizedBox(height: AppSpacing.sm),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _selectedDaySessions.length,
                itemBuilder: (context, index) {
                  final s = _selectedDaySessions[index];
                  final durationMin = (s.actualDurationSeconds > 0 && s.actualDurationSeconds < 60) ? 1 : s.actualDurationSeconds ~/ 60;
                  final startTimeStr = '${s.startedAt.hour.toString().padLeft(2, '0')}:${s.startedAt.minute.toString().padLeft(2, '0')}';
                  
                  return Container(
                    margin: const EdgeInsets.only(bottom: AppSpacing.xs),
                    padding: const EdgeInsets.all(AppSpacing.md),
                    decoration: BoxDecoration(
                      color: isDark ? Colors.white.withValues(alpha: 0.03) : Colors.black.withValues(alpha: 0.02),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: isDark ? Colors.white10 : Colors.black12, width: 0.5),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                s.scheduleTitle,
                                style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.bold),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 2),
                              Row(
                                children: [
                                  Icon(Icons.access_time_rounded, size: 12, color: Colors.grey[500]),
                                  const SizedBox(width: 4),
                                  Text(
                                    '$startTimeStr • $durationMin Menit',
                                    style: AppTypography.bodySmall.copyWith(color: Colors.grey[500]),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        // Badge Status Selesai
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.xs),
                          decoration: BoxDecoration(
                            color: s.isCompleted
                                ? (isDark ? Colors.green[950] : Colors.green[50])
                                : (isDark ? Colors.amber[950] : Colors.amber[50]),
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(
                              color: s.isCompleted ? Colors.green.withValues(alpha: 0.3) : Colors.amber.withValues(alpha: 0.3),
                            ),
                          ),
                          child: Text(
                            s.isCompleted ? 'Selesai' : 'Batal',
                            style: AppTypography.bodySmall.copyWith(
                              fontWeight: FontWeight.bold,
                              fontSize: 10,
                              color: s.isCompleted ? Colors.green : Colors.amber,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ]
          ],
        ),
      ),
    ).animate().fade(delay: 300.ms).slideY(begin: 0.1, duration: 300.ms);
  }

  /// Widget Skeleton Loader premium untuk menggantikan CircularProgressIndicator
  Widget _buildSkeletonCard(BuildContext context, bool isDark) {
    final baseColor = isDark ? Colors.grey[900]!.withOpacity(0.5) : Colors.grey[100]!.withOpacity(0.5);
    final highlightColor = isDark ? Colors.grey[850]! : Colors.grey[200]!;
    final borderColor = isDark ? Colors.grey[850]! : Colors.grey[300]!;
    final accentColor = isDark ? AppColors.darkPrimary.withOpacity(0.15) : AppColors.lightPrimary.withOpacity(0.15);

    return Container(
      height: 60,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: baseColor,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: borderColor, width: 0.8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
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
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  width: 90,
                  height: 8,
                  decoration: BoxDecoration(
                    color: highlightColor.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 48,
            height: 18,
            decoration: BoxDecoration(
              color: highlightColor,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ],
      ),
    ).animate(onPlay: (controller) => controller.repeat(reverse: true))
     .fade(begin: 0.6, end: 1.0, duration: 800.ms);
  }
}
