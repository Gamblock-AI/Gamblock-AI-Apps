import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Brand
  static const navy = Color(0xFF0D2C54);
  static const navyLight = Color(0xFF1A3D6D);
  static const navyDark = Color(0xFF081E3D);
  static const crimson = Color(0xFFC8102E);
  static const crimsonLight = Color(0xFFE8354A);
  static const sage = Color(0xFF4A7C59);
  static const sageLight = Color(0xFF6B9E7A);
  static const amber = Color(0xFFD4A017);

  // Surfaces
  static const surfaceLight = Color(0xFFFAFAF9);
  static const surfaceDark = Color(0xFF0F1729);

  // Navy-based color scheme
  static const ColorScheme lightScheme = ColorScheme(
    brightness: Brightness.light,
    primary: navy,
    onPrimary: Colors.white,
    primaryContainer: Color(0xFFD6E4FF),
    onPrimaryContainer: navyDark,
    secondary: sage,
    onSecondary: Colors.white,
    secondaryContainer: Color(0xFFD4EDDA),
    onSecondaryContainer: Color(0xFF1B4332),
    tertiary: amber,
    onTertiary: Colors.white,
    tertiaryContainer: Color(0xFFFFF3CD),
    onTertiaryContainer: Color(0xFF664D03),
    error: crimson,
    onError: Colors.white,
    errorContainer: Color(0xFFF8D7DA),
    onErrorContainer: Color(0xFF721C24),
    surface: surfaceLight,
    onSurface: navyDark,
    surfaceContainerHighest: Color(0xFFF1F5F9),
    onSurfaceVariant: Color(0xFF64748B),
    outline: Color(0xFFE2E8F0),
    outlineVariant: Color(0xFFCBD5E1),
    shadow: Color(0x1A000000),
    scrim: Color(0x66000000),
    inverseSurface: navyDark,
    onInverseSurface: Colors.white,
    inversePrimary: Color(0xFF93C5FD),
  );

  static const ColorScheme darkScheme = ColorScheme(
    brightness: Brightness.dark,
    primary: Color(0xFF93C5FD),
    onPrimary: navyDark,
    primaryContainer: navy,
    onPrimaryContainer: Color(0xFFD6E4FF),
    secondary: sageLight,
    onSecondary: Color(0xFF1B4332),
    secondaryContainer: sage,
    onSecondaryContainer: Color(0xFFD4EDDA),
    tertiary: amber,
    onTertiary: Color(0xFF664D03),
    tertiaryContainer: Color(0xFF856404),
    onTertiaryContainer: Color(0xFFFFF3CD),
    error: crimsonLight,
    onError: Color(0xFF721C24),
    errorContainer: crimson,
    onErrorContainer: Color(0xFFF8D7DA),
    surface: surfaceDark,
    onSurface: Color(0xFFF8FAFC),
    surfaceContainerHighest: Color(0xFF1E293B),
    onSurfaceVariant: Color(0xFF94A3B8),
    outline: Color(0xFF334155),
    outlineVariant: Color(0xFF475569),
    shadow: Color(0x33000000),
    scrim: Color(0x99000000),
    inverseSurface: Color(0xFFF8FAFC),
    onInverseSurface: navyDark,
    inversePrimary: navy,
  );
}
