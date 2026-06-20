import 'package:flutter/services.dart';

/// Thin wrapper around [HapticFeedback] so haptics can be toggled and so call
/// sites stay clean. On desktop (Windows) these are no-ops automatically.
///
/// Severity mapping mirrors UX intent:
///   - selection: light tick for toggles/segmented choices
///   - impact(light/medium): taps on cards/buttons
///   - success: a completed, positive action (save)
///   - error/heavy: a failed or destructive action
class Haptics {
  Haptics._();

  /// Globally enable/disable haptics (wired to a settings toggle).
  static bool enabled = true;

  static void selection() {
    if (enabled) HapticFeedback.selectionClick();
  }

  static void light() {
    if (enabled) HapticFeedback.lightImpact();
  }

  static void medium() {
    if (enabled) HapticFeedback.mediumImpact();
  }

  static void heavy() {
    if (enabled) HapticFeedback.heavyImpact();
  }

  static void success() {
    if (enabled) HapticFeedback.mediumImpact();
  }

  static void error() {
    if (enabled) HapticFeedback.heavyImpact();
  }
}
