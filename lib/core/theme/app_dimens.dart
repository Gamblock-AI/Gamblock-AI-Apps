import 'package:flutter/widgets.dart';

/// Shared spacing scale for gaps and screen padding.
class AppSpacing {
  AppSpacing._();

  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 24;
  static const double xxl = 32;

  /// Unified scrollable-tab padding (protection/analytics/accountability/
  /// settings all share this).
  static const EdgeInsets screenPadding = EdgeInsets.fromLTRB(lg, md, lg, xxl);
}

/// Shared corner-radius scale. Cards use [lg], inputs and small panels [md],
/// inner tiles and dialog controls [sm], chips/badges [xs], buttons [pill].
class AppRadius {
  AppRadius._();

  static const double xs = 8;
  static const double sm = 12;
  static const double md = 16;
  static const double lg = 22;
  static const double xl = 28;
  static const double pill = 999;
}

/// Shared icon-size scale. Status chips use [xs], dense rows [sm], action
/// icons [md], navigation/default [lg], empty states and heroes [xl].
class AppIconSize {
  AppIconSize._();

  static const double xs = 12;
  static const double sm = 16;
  static const double md = 20;
  static const double lg = 24;
  static const double xl = 32;
}
