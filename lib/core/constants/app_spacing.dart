import 'package:flutter/material.dart';

/// Skala Spasi (Base 4px) dan Radius Bentuk untuk FocusForge.
class AppSpacing {
  AppSpacing._();

  // === SPACING SCALE ===
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 12.0;
  static const double base = 16.0;
  static const double lg = 20.0;
  static const double xl = 24.0;
  static const double xxl = 32.0;
  static const double xxxl = 48.0;

  // === RADII ===
  static const double radiusSm = 8.0;
  static const double radiusMd = 12.0;
  static const double radiusLg = 16.0;
  static const double radiusXl = 24.0;
  static const double radiusFull = 999.0;

  // === SHAPES ===
  static const BorderRadius borderSm = BorderRadius.all(Radius.circular(radiusSm));
  static const BorderRadius borderMd = BorderRadius.all(Radius.circular(radiusMd));
  static const BorderRadius borderLg = BorderRadius.all(Radius.circular(radiusLg));
  static const BorderRadius borderXl = BorderRadius.all(Radius.circular(radiusXl));
  static const BorderRadius borderFull = BorderRadius.all(Radius.circular(radiusFull));

  // === EDGES (Paddings/Margins) ===
  static const EdgeInsets edgeAllXs = EdgeInsets.all(xs);
  static const EdgeInsets edgeAllSm = EdgeInsets.all(sm);
  static const EdgeInsets edgeAllMd = EdgeInsets.all(md);
  static const EdgeInsets edgeAllBase = EdgeInsets.all(base);
  static const EdgeInsets edgeAllLg = EdgeInsets.all(lg);
  static const EdgeInsets edgeAllXl = EdgeInsets.all(xl);

  static const EdgeInsets edgeHorizontalSm = EdgeInsets.symmetric(horizontal: sm);
  static const EdgeInsets edgeHorizontalBase = EdgeInsets.symmetric(horizontal: base);
  static const EdgeInsets edgeHorizontalLg = EdgeInsets.symmetric(horizontal: lg);

  static const EdgeInsets edgeVerticalSm = EdgeInsets.symmetric(vertical: sm);
  static const EdgeInsets edgeVerticalBase = EdgeInsets.symmetric(vertical: base);
  static const EdgeInsets edgeVerticalLg = EdgeInsets.symmetric(vertical: lg);
}
