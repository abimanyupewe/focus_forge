import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../schedule/presentation/pages/dashboard_page.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<OnboardingSlideData> _slides = [
    OnboardingSlideData(
      title: 'Rancang Jadwal Belajarmu',
      description: 'FocusForge membantu Anda merancang jadwal belajar mandiri (Time-Boxing) dengan rapi, terstruktur, dan produktif.',
      icon: Icons.calendar_today_rounded,
      gradientColors: [AppColors.lightPrimary, const Color(0xFF047857)], // Teal to Emerald
    ),
    OnboardingSlideData(
      title: 'Notifikasi Pengingat Cerdas',
      description: 'Sistem alarm pintar (dual-trigger) akan berbunyi tepat waktu saat mulai belajar, serta alarm wrap-up sebelum sesi usai.',
      icon: Icons.notifications_active_rounded,
      gradientColors: [const Color(0xFF0D9488), const Color(0xFF115E59)], // Medium Teal to Deep Teal
    ),
    OnboardingSlideData(
      title: 'Pantau Progres & Streak',
      description: 'Lihat heatmap kontribusi belajar Anda dan bangun streak harian berturut-turut untuk menjaga konsistensi belajar Anda.',
      icon: Icons.workspace_premium_rounded,
      gradientColors: [const Color(0xFF14B8A6), const Color(0xFF0F766E)], // Vibrant Teal to Dark Teal
    ),
  ];

  Future<void> _completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_completed', true);
    if (mounted) {
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => const DashboardPage(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
          transitionDuration: const Duration(milliseconds: 600),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
      body: Stack(
        children: [
          // Background Glows
          Positioned(
            top: -100,
            left: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _slides[_currentPage].gradientColors[0].withValues(alpha: 0.08),
              ),
            ).animate(target: _currentPage.toDouble()).custom(
              duration: 500.ms,
              builder: (context, val, child) => Opacity(
                opacity: 0.8,
                child: child,
              ),
            ),
          ),
          
          PageView.builder(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() {
                _currentPage = index;
              });
            },
            itemCount: _slides.length,
            itemBuilder: (context, index) {
              final slide = _slides[index];
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxl),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Clean Outlined Glassmorphic Icon Token
                    Container(
                      width: 140,
                      height: 140,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            slide.gradientColors[0].withValues(alpha: 0.08),
                            slide.gradientColors[1].withValues(alpha: 0.15),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isDark ? AppColors.darkPrimary.withValues(alpha: 0.2) : AppColors.lightPrimary.withValues(alpha: 0.2),
                          width: 1,
                        ),
                      ),
                      child: Center(
                        child: Container(
                          width: 90,
                          height: 90,
                          decoration: BoxDecoration(
                            color: isDark ? AppColors.darkPrimary.withValues(alpha: 0.05) : AppColors.lightPrimary.withValues(alpha: 0.05),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            slide.icon,
                            size: 40,
                            color: isDark ? AppColors.darkPrimary : AppColors.lightPrimary,
                          ),
                        ),
                      ),
                    ).animate(key: ValueKey('icon_$index')).fade(duration: 600.ms).scale(
                          begin: const Offset(0.85, 0.85),
                          curve: Curves.easeOutBack,
                          duration: 600.ms,
                        ),
                    const SizedBox(height: AppSpacing.xxxl),
                    
                    // Title
                    Text(
                      slide.title,
                      textAlign: TextAlign.center,
                      style: AppTypography.displayLarge.copyWith(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ).animate(key: ValueKey('title_$index')).fade(duration: 400.ms).slideY(begin: 0.1, duration: 400.ms),
                    const SizedBox(height: AppSpacing.base),
                    
                    // Description
                    Text(
                      slide.description,
                      textAlign: TextAlign.center,
                      style: AppTypography.bodyLarge.copyWith(
                        color: isDark ? Colors.white70 : Colors.black54,
                        fontSize: 14,
                        height: 1.6,
                      ),
                    ).animate(key: ValueKey('desc_$index')).fade(delay: 150.ms, duration: 400.ms).slideY(begin: 0.1, duration: 400.ms),
                  ],
                ),
              );
            },
          ),
          
          // Navigation & Indicators Bottom Row
          Positioned(
            bottom: AppSpacing.xxl + MediaQuery.of(context).padding.bottom,
            left: AppSpacing.xl,
            right: AppSpacing.xl,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Skip Button
                TextButton(
                  onPressed: _completeOnboarding,
                  child: Text(
                    'Lewati',
                    style: AppTypography.titleMedium.copyWith(
                      color: isDark ? Colors.white38 : Colors.black38,
                      fontSize: 14,
                    ),
                  ),
                ),
                
                // Indicators
                Row(
                  children: List.generate(
                    _slides.length,
                    (index) => AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      width: _currentPage == index ? 20 : 6,
                      height: 6,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(3),
                        color: _currentPage == index
                            ? (isDark ? AppColors.darkPrimary : AppColors.lightPrimary)
                            : (isDark ? Colors.white24 : Colors.black12),
                      ),
                    ),
                  ),
                ),
                
                // Next / Finish Button (Less rounded, bento styled flat button)
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isDark ? AppColors.darkPrimary : AppColors.lightPrimary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl, vertical: AppSpacing.md),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    elevation: 0,
                  ),
                  onPressed: () {
                    if (_currentPage < _slides.length - 1) {
                      _pageController.nextPage(
                        duration: const Duration(milliseconds: 400),
                        curve: Curves.easeInOutCubic,
                      );
                    } else {
                      _completeOnboarding();
                    }
                  },
                  child: Text(
                    _currentPage == _slides.length - 1 ? 'Mulai' : 'Lanjut',
                    style: AppTypography.titleMedium.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class OnboardingSlideData {
  final String title;
  final String description;
  final IconData icon;
  final List<Color> gradientColors;

  OnboardingSlideData({
    required this.title,
    required this.description,
    required this.icon,
    required this.gradientColors,
  });
}
