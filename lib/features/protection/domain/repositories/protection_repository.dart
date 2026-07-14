import '../entities/protection_status.dart';
import '../../../dashboard/domain/entities/dashboard_summary.dart';

/// Domain contract for protection status + uninstall approval requests.
abstract class ProtectionRepository {
  Future<ProtectionStatus> fetchStatus();
  Future<DashboardSummary> fetchSummary();
  Future<void> requestApproval({
    required String action,
    required String reason,
    required int durationMinutes,
  });
}
