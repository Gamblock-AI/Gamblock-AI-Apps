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

  // Deep ramp ends used by feature gradients/accents.
  static const skyDark = Color(0xFF0284C7);
  static const amberDark = Color(0xFFD97706);

  // Bright blue accent family (wireframe "task-dashboard-overview" accent).
  // Keeps navy as the primary brand; bright blue is the interactive accent.
  static const blueAccent = Color(0xFF48CAE4);
  static const blueAccentLight = Color(0xFF8FDEF2);
  static const blueAccentSoft = Color(0xFFE6F8FC);
  static const violetAccent = Color(0xFF9D4EDD);
  static const violetAccentSoft = Color(0xFFF3EAFB);

  // Surfaces (light) — light-gray canvas with near-white cards (wireframe).
  static const surface = Color(0xFFFFFFFF); // card
  static const background = Color(0xFFF9FAFB); // page base
  static const mesh = Color(0xFFF0F7FB); // pastel mesh base
  static const muted = Color(0xFFEAF0F6);
  static const border = Color(0xFFE8EEF5);
  static const mutedForeground = Color(0xFF5A6B82);

  // Ink ramp (wireframe text scale).
  static const ink = Color(0xFF111827);
  static const inkMuted = Color(0xFF9CA3AF);

  // Back-compat aliases (older references)
  static const surfaceLight = background;
  static const surfaceDark = navyDark;

  /// Pastel mesh gradient used on hero/header areas (mirrors web `bg-mesh`).
  static const meshGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFEAF6FC), Color(0xFFF2F7FC), Color(0xFFF9FAFB)],
  );

  /// Bright blue accent gradient (mirrors the wireframe FAB / active pill
  /// gradient, re-tinted from orange to the brand blue accent).
  static const blueAccentGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [blueAccentLight, blueAccent, Color(0xFF28A8CC)],
  );

  /// Glass fill used by floating surfaces (search bar, date track, bottom nav).
  static Color get glassFill => Colors.white.withValues(alpha: 0.85);

  /// Glass hairline border (wireframe `1px solid #FFFFFF`).
  static const glassBorder = Colors.white;

  /// Deep navy gradient for high-emphasis surfaces (mirrors web `bg-footer-navy`).
  static const navyGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [navy, Color(0xFF0D1D3D), navyDark],
  );

  /// Near-black calm backdrop reserved for the Pattern Interrupt pause.
  static const calmDarkGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF0F172A), Color(0xFF1E1B4B), Color(0xFF09090B)],
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

  /// Wireframe default surface shadow: `0 4px 20px -2px rgba(0,0,0,0.03)`.
  static List<BoxShadow> get cardSoftShadow => [
    BoxShadow(
      color: const Color(0x0D000000),
      blurRadius: 20,
      offset: const Offset(0, 4),
      spreadRadius: -2,
    ),
  ];

  /// Blue accent glow for interactive accents (active tab, arrow, FAB):
  /// mirrors the wireframe orange glow `0 4px 15px -3px rgba(...0.4)`.
  static List<BoxShadow> get accentGlow => [
    BoxShadow(
      color: blueAccent.withValues(alpha: 0.4),
      blurRadius: 15,
      offset: const Offset(0, 4),
      spreadRadius: -3,
    ),
  ];

  /// Stronger blue glow for the floating center FAB.
  static List<BoxShadow> get fabGlow => [
    BoxShadow(
      color: blueAccent.withValues(alpha: 0.5),
      blurRadius: 25,
      offset: const Offset(0, 8),
      spreadRadius: -5,
    ),
  ];

  // Light color scheme (the app is light-only).
  static const ColorScheme lightScheme = ColorScheme(
    brightness: Brightness.light,
    primary: navy,
    onPrimary: Colors.white,
    primaryContainer: azure,
    onPrimaryContainer: navyDark,
    secondary: sky,
    onSecondary: navyDark,
    secondaryContainer: skyLight,
    onSecondaryContainer: navyDark,
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
