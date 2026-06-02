import 'package:flutter/material.dart';

/// Token warna untuk aplikasi FocusForge.
///
/// Menyediakan palet warna harmonis untuk Light dan Dark Mode
/// serta warna kategori untuk jadwal (Schedule).
class AppColors {
  AppColors._();

  // === LIGHT MODE ===
  static const Color lightBackground = Color(0xFFF8F9FA);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightSurfaceVariant = Color(0xFFF1F3F5);
  static const Color lightPrimary = Color(0xFF0F766E); // Teal 700 (Hijau/Teal Gelap Mewah)
  static const Color lightPrimaryContainer = Color(0xFFE6F4F1); // Soft Teal Container
  static const Color lightSecondary = Color(0xFF0D9488); // Teal 600
  static const Color lightError = Color(0xFFE53E3E);
  static const Color lightOnBackground = Color(0xFF1A202C);
  static const Color lightOnSurfaceVariant = Color(0xFF718096);
  static const Color lightOutline = Color(0xFFE2E8F0);

  // === DARK MODE ===
  static const Color darkBackground = Color(0xFF0B0F19); // Deep Midnight Blue/Teal Black
  static const Color darkSurface = Color(0xFF131B2E); // Deep Navy/Teal Surface
  static const Color darkSurfaceVariant = Color(0xFF1E293B); // Dark Slate Grey
  static const Color darkPrimary = Color(0xFF14B8A6); // Teal 500 (Vibrant Teal)
  static const Color darkPrimaryContainer = Color(0xFF0F766E); // Deep Teal Container
  static const Color darkSecondary = Color(0xFF2DD4BF); // Teal 400
  static const Color darkError = Color(0xFFFEB2B2);
  static const Color darkOnBackground = Color(0xFFF7FAFC);
  static const Color darkOnSurfaceVariant = Color(0xFFA0AEC0);
  static const Color darkOutline = Color(0xFF334155);

  // === CATEGORY COLORS ===
  // Menggunakan gradasi hijau/teal yang konsisten agar visual bento-box selaras tanpa warna-warni yang ramai
  static const List<Color> categoryColors = [
    Color(0xFF0F766E), // Dark Teal
    Color(0xFF0D9488), // Medium Teal
    Color(0xFF14B8A6), // Teal 500
    Color(0xFF2DD4BF), // Light Teal
    Color(0xFF115E59), // Deep Teal 800
    Color(0xFF047857), // Emerald Green
    Color(0xFF065F46), // Deep Emerald
    Color(0xFF0F9F90), // Custom Teal
  ];
}
