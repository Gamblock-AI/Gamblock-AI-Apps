import 'package:dio/dio.dart';

import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_response.dart';
import '../../../../core/platform/platform_bridge.dart';
import '../../domain/entities/accountability_models.dart';
import '../../domain/repositories/accountability_repository.dart';

class AccountabilityRepositoryImpl implements AccountabilityRepository {
  AccountabilityRepositoryImpl({Dio? dio}) : _dio = dio ?? ApiClient.dio;

  final Dio _dio;

  @override
  Future<PartnerOverview> fetchPartners() async {
    final response = await _dio.get('/v1/partners');
    final data = ApiResponse.map(response) ?? const {};
    final items = (data['items'] as List? ?? const [])
        .whereType<Map>()
        .map((item) => PartnerLink.fromJson(Map<String, dynamic>.from(item)))
        .toList();
    final active = data['active_partner'];
    return PartnerOverview(
      activePartner: active is Map
          ? PartnerLink.fromJson(Map<String, dynamic>.from(active))
          : items.where((item) => item.isActive).firstOrNull,
      items: items,
    );
  }

  @override
  Future<List<ApprovalRequest>> fetchApprovalRequests() async {
    final response = await _dio.get('/v1/approval-requests');
    return ApiResponse.list(response).map(ApprovalRequest.fromJson).toList();
  }

  @override
  Future<PartnerInvitation> invitePartner(String email) async {
    final response = await _dio.post(
      '/v1/partners/invitations',
      data: {'email': email.trim()},
    );
    final data = ApiResponse.map(response) ?? const {};
    return PartnerInvitation(
      id: data['id']?.toString() ?? '',
      status: data['status']?.toString() ?? 'invited',
      inviteUrl: data['invite_url']?.toString() ?? '',
    );
  }

  @override
  Future<void> revokePartner(String partnerLinkId) async {
    await _dio.post('/v1/partners/$partnerLinkId/revoke');
  }

  @override
  Future<ApprovalRequest> requestApproval({
    required String deviceId,
    required String partnerLinkId,
    required String action,
    required String reason,
    required int durationMinutes,
  }) async {
    final response = await _dio.post(
      '/v1/approval-requests',
      data: {
        'device_id': deviceId,
        'partner_link_id': partnerLinkId,
        'action': action,
        'reason': reason.trim(),
        'requested_duration_minutes': durationMinutes,
      },
    );
    return ApprovalRequest.fromJson(ApiResponse.map(response) ?? const {});
  }

  @override
  Future<void> cancelApproval(String requestId) async {
    await _dio.post('/v1/approval-requests/$requestId/cancel');
  }

  @override
  Future<void> applyApproval({
    required String requestId,
    required String deviceId,
  }) async {
    final response = await _dio.post(
      '/v1/approval-requests/$requestId/apply',
      data: {'device_id': deviceId},
    );
    final grant = ApiResponse.map(response) ?? const {};
    if (!await PlatformBridge.storeProtectionGrant(grant)) {
      throw StateError('Native protection service did not accept the grant');
    }
  }

  @override
  Future<EmergencyRequest> requestEmergency(String deviceId) async {
    final response = await _dio.post(
      '/v1/emergency-key-requests',
      data: {'device_id': deviceId},
    );
    return EmergencyRequest.fromJson(ApiResponse.map(response) ?? const {});
  }

  @override
  Future<EmergencyRequest?> currentEmergency(String deviceId) async {
    try {
      final response = await _dio.get(
        '/v1/emergency-key-requests/current',
        queryParameters: {'device_id': deviceId},
      );
      return EmergencyRequest.fromJson(ApiResponse.map(response) ?? const {});
    } on DioException catch (error) {
      if (error.response?.statusCode == 404) return null;
      rethrow;
    }
  }

  @override
  Future<void> applyEmergencyKey({
    required String deviceId,
    required String emergencyKey,
  }) async {
    final response = await _dio.post(
      '/v1/devices/unlock',
      data: {'emergency_key': emergencyKey.trim(), 'device_id': deviceId},
    );
    final grant = <String, dynamic>{
      ...?ApiResponse.map(response),
      'action': 'emergency_access',
    };
    if (!await PlatformBridge.storeProtectionGrant(grant)) {
      throw StateError('Native protection service did not accept the grant');
    }
  }
}
