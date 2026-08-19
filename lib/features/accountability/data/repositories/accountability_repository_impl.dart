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
  Future<AccountabilityOverview> fetchWorkspace() async {
    final response = await _dio.get('/v1/accountability/workspace');
    final data = ApiResponse.map(response) ?? const {};
    final membership = data['membership'];
    final groups = data['groups'];
    final group = groups is List && groups.isNotEmpty && groups.first is Map
        ? Map<String, dynamic>.from(groups.first as Map)
        : null;
    final exits = data['exit_requests'];
    AccountabilityExitRequest? pendingExit;
    if (exits is List) {
      for (final item in exits) {
        if (item is Map && item['status'] == 'pending') {
          pendingExit = AccountabilityExitRequest.fromJson(
            Map<String, dynamic>.from(item),
          );
          break;
        }
      }
    }
    return AccountabilityOverview(
      activeMembership: membership is Map
          ? AccountabilityMembership.fromWorkspace(
              Map<String, dynamic>.from(membership),
              group,
            )
          : null,
      pendingExitRequest: pendingExit,
    );
  }

  @override
  Future<List<ApprovalRequest>> fetchApprovalRequests() async {
    final response = await _dio.get('/v1/approval-requests');
    return ApiResponse.list(response).map(ApprovalRequest.fromJson).toList();
  }

  @override
  Future<AccountabilityGroupPreview> previewGroup(String code) async {
    final response = await _dio.post(
      '/v1/accountability/groups/preview',
      data: {'code': code.trim().toUpperCase()},
    );
    return AccountabilityGroupPreview.fromJson(
      ApiResponse.map(response) ?? const {},
    );
  }

  @override
  Future<AccountabilityOverview> joinGroup(String code) async {
    await _dio.post(
      '/v1/accountability/groups/join',
      data: {'code': code.trim().toUpperCase(), 'confirmed': true},
    );
    return fetchWorkspace();
  }

  @override
  Future<ApprovalRequest> requestApproval({
    required String deviceId,
    required String membershipId,
    required String action,
    required String reason,
    required int durationMinutes,
  }) async {
    final response = await _dio.post(
      '/v1/approval-requests',
      data: {
        'device_id': deviceId,
        'membership_id': membershipId,
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
  Future<void> updateSharing(
    String membershipId,
    AccountabilitySharing sharing,
  ) async {
    await _dio.patch(
      '/v1/accountability/memberships/$membershipId/sharing',
      data: sharing.toJson(),
    );
  }

  @override
  Future<void> requestLeave(
    String membershipId, {
    required String kind,
    required String reason,
  }) async {
    await _dio.post(
      '/v1/accountability/memberships/$membershipId/leave',
      data: {'kind': kind, 'reason': reason.trim()},
    );
  }

  @override
  Future<void> cancelLeave(String requestId) async {
    await _dio.post('/v1/accountability/exit-requests/$requestId/cancel');
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
    final grantToken =
        (ApiResponse.map(response)?['grant_token']?.toString() ?? '').trim();
    if (!await PlatformBridge.storeProtectionGrant(grantToken)) {
      throw StateError('Native protection service did not accept the grant');
    }
  }

  @override
  Future<void> requestStandaloneRemoval({required String deviceId}) async {
    final response = await _dio.post(
      '/v1/devices/standalone-removal-grant',
      data: {'device_id': deviceId},
    );
    final grantToken =
        (ApiResponse.map(response)?['grant_token']?.toString() ?? '').trim();
    if (!await PlatformBridge.storeProtectionGrant(grantToken)) {
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
    final grantToken =
        (ApiResponse.map(response)?['grant_token']?.toString() ?? '').trim();
    if (!await PlatformBridge.storeProtectionGrant(grantToken)) {
      throw StateError('Native protection service did not accept the grant');
    }
  }
}
