/// Timing gates shared by Flutter protection surfaces.
abstract final class ProtectionTimingContract {
  static const patternInterruptSeconds = 7;
  static const patternInterruptDuration = Duration(
    seconds: patternInterruptSeconds,
  );
}
