import 'package:flutter/material.dart';

/// Brand palette — kept in lockstep with the website design system
/// (globals.css): navy #16294C primary, crimson #C8102E accent, pastel
/// cyan/azure surfaces, sage success, amber warm accent.
class AppColors {
  AppColors._();

  // Brand
  static const navy = Color(0xFF16294C);
  static const navyLight = Color(0xFF24487F);
  static const navyDark = Color(0xFF0D1B35);
  static const crimson = Color(0xFFC8102E);
  static const crimsonLight = Color(0xFFE63B51);
  static const crimsonDark = Color(0xFF9D0C24);
  static const sky = Color(0xFF3DD6F5);
  static const skyLight = Color(0xFFBFE9F5);
  static const azure = Color(0xFFDCEBFB);
  static const sage = Color(0xFF2F9E6F);
  static const sageLight = Color(0xFF5BB98E);
  static const amber = Color(0xFFE0A516);

  // Surfaces (light)
  static const surface = Color(0xFFFFFFFF); // card
  static const background = Color(0xFFF4F9FE); // page base
  static const mesh = Color(0xFFEAF6FD); // pastel mesh base
  static const muted = Color(0xFFEAF0F6);
  static const border = Color(0xFFE3ECF5);
  static const mutedForeground = Color(0xFF5A6B82);

  // Back-compat aliases (older references)
  static const surfaceLight = background;
  static const surfaceDark = navyDark;

  /// Pastel mesh gradient used on hero/header areas (mirrors web `bg-mesh`).
  static const meshGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFE3F4FB), Color(0xFFECF4FD), Color(0xFFF5FAFE)],
  );

  /// Deep navy gradient for high-emphasis surfaces (mirrors web `bg-footer-navy`).
  static const navyGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [navy, Color(0xFF0D1D3D), navyDark],
  );

  /// Soft card shadow (mirrors web `shadow-card`).
  static List<BoxShadow> get cardShadow => [
    BoxShadow(
      color: navy.withValues(alpha: 0.05),
      blurRadius: 6,
      offset: const Offset(0, 2),
    ),
    BoxShadow(
      color: navy.withValues(alpha: 0.10),
      blurRadius: 40,
      offset: const Offset(0, 16),
      spreadRadius: -12,
    ),
  ];

  /// Subtle shadow (mirrors web `shadow-soft`).
  static List<BoxShadow> get softShadow => [
    BoxShadow(
      color: navy.withValues(alpha: 0.06),
      blurRadius: 20,
      offset: const Offset(0, 8),
      spreadRadius: -8,
    ),
  ];

  // Light color scheme (the app is light-only).
  static const ColorScheme lightScheme = ColorScheme(
    brightness: Brightness.light,
    primary: navy,
    onPrimary: Colors.white,
    primaryContainer: azure,
    onPrimaryContainer: navyDark,
    secondary: crimson,
    onSecondary: Colors.white,
    secondaryContainer: Color(0xFFFBE0E4),
    onSecondaryContainer: crimsonDark,
    tertiary: sage,
    onTertiary: Colors.white,
    tertiaryContainer: Color(0xFFD9F0E5),
    onTertiaryContainer: Color(0xFF1B4332),
    error: crimson,
    onError: Colors.white,
    errorContainer: Color(0xFFFBE0E4),
    onErrorContainer: crimsonDark,
    surface: surface,
    onSurface: navyDark,
    surfaceContainerHighest: muted,
    onSurfaceVariant: mutedForeground,
    outline: border,
    outlineVariant: Color(0xFFD3DEEC),
    shadow: Color(0x1A16294C),
    scrim: Color(0x6616294C),
    inverseSurface: navyDark,
    onInverseSurface: Colors.white,
    inversePrimary: skyLight,
  );
}
