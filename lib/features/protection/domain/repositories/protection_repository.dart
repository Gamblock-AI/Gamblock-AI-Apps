import '../entities/protection_status.dart';
import '../../../dashboard/domain/entities/dashboard_summary.dart';

abstract class ApprovalRequestState {
  String get id;
  String get action;
  String get status;
  int get durationMinutes;
}

/// Domain contract for protection status + uninstall approval requests.
abstract class ProtectionRepository {
  Future<ProtectionStatus> fetchStatus();
  Future<DashboardSummary> fetchSummary();
  Future<void> requestApproval({
    required String action,
    required String reason,
    required int durationMinutes,
  });
  Future<List<ApprovalRequestState>> fetchPendingApprovals();
  Future<void> applyApprovedAction(ApprovalRequestState request);
}
