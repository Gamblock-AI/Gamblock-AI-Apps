import '../entities/accountability_models.dart';

abstract class AccountabilityRepository {
  Future<PartnerOverview> fetchPartners();
  Future<List<ApprovalRequest>> fetchApprovalRequests();
  Future<PartnerInvitation> invitePartner(String email);
  Future<void> revokePartner(String partnerLinkId);
  Future<ApprovalRequest> requestApproval({
    required String deviceId,
    required String partnerLinkId,
    required String action,
    required String reason,
    required int durationMinutes,
  });
  Future<void> cancelApproval(String requestId);
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
