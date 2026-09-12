import '../entities/accountability_models.dart';

abstract class AccountabilityRepository {
  Future<AccountabilityOverview> fetchWorkspace();
  Future<List<ApprovalRequest>> fetchApprovalRequests();
  Future<AccountabilityGroupPreview> previewGroup(String code);
  Future<AccountabilityOverview> joinGroup(String code);
  Future<ApprovalRequest> requestApproval({
    required String deviceId,
    required String membershipId,
    required String action,
    required String reason,
    required int durationMinutes,
  });
  Future<void> cancelApproval(String requestId);
  Future<void> updateSharing(
    String membershipId,
    AccountabilitySharing sharing,
  );
  Future<void> requestLeave(
    String membershipId, {
    required String kind,
    required String reason,
  });
  Future<void> cancelLeave(String requestId);
  Future<void> applyApproval({
    required String requestId,
    required String deviceId,
  });
  Future<EmergencyRequest> requestEmergency(String deviceId);
  Future<EmergencyRequest?> currentEmergency(String deviceId);
  Future<void> applyEmergencyKey({
    required String deviceId,
    required String emergencyKey,
  });
}
