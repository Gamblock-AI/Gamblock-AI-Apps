import '../entities/dashboard_summary.dart';
import '../entities/weekly_progress.dart';

/// Domain contract for dashboard data. Implementations live in `data/`.
/// Presentation depends on this abstraction, not on Dio directly.
abstract class DashboardRepository {
  Future<DashboardSummary> fetchSummary();
  Future<WeeklyProgress> fetchProgress();
}
