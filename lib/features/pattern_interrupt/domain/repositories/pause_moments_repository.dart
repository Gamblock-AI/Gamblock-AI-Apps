import '../entities/pause_moment.dart';

abstract class PauseMomentsRepository {
  /// Records a completed pause. Must never throw — the Pattern Interrupt
  /// flow may not break because of bookkeeping.
  Future<void> record(String kind, Duration elapsed);

  /// The newest unacknowledged pause within the recent window, if any.
  Future<PauseMoment?> unacknowledgedRecent();

  Future<void> acknowledgeAll();
}
