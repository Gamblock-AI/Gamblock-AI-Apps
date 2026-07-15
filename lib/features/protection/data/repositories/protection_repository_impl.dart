import 'package:dio/dio.dart';
import '../../domain/entities/protection_status.dart';
import '../../domain/repositories/protection_repository.dart';
import '../../../dashboard/domain/entities/dashboard_summary.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_response.dart';
import '../../../../core/platform/platform_bridge.dart';

class ApprovalRequestStateModel implements ApprovalRequestState {
  @override
  final String id;
  @override
  final String action;
  @override
  final String status;
  @override
  final int durationMinutes;

  ApprovalRequestStateModel({
    required this.id,
    required this.action,
    required this.status,
    required this.durationMinutes,
  });

  factory ApprovalRequestStateModel.fromJson(Map<String, dynamic> json) {
    return ApprovalRequestStateModel(
      id: json['id'] as String? ?? '',
      action: json['action'] as String? ?? '',
      status: json['status'] as String? ?? 'pending',
      durationMinutes: json['requested_duration_minutes'] as int? ?? 0,
    );
  }
}

class ProtectionRepositoryImpl implements ProtectionRepository {
  final Dio _dio;

  ProtectionRepositoryImpl({Dio? dio}) : _dio = dio ?? ApiClient.dio;

  @override
  Future<ProtectionStatus> fetchStatus() async {
    final response = await _dio.get('/v1/client/protection-status');
    final json = ApiResponse.map(response) ?? const {};
    return ProtectionStatus.fromJson(json);
  }

  @override
  Future<DashboardSummary> fetchSummary() async {
    final response = await _dio.get('/v1/client/dashboard-summary');
    final json = ApiResponse.map(response) ?? const {};
    return DashboardSummary.fromJson(json);
  }

  @override
  Future<void> requestApproval({
    required String action,
    required String reason,
    required int durationMinutes,
  }) async {
    await _dio.post(
      '/v1/approval-requests',
      data: {
        'action': action,
        'reason': reason,
        'requested_duration_minutes': durationMinutes,
      },
    );
  }

  @override
  Future<List<ApprovalRequestState>> fetchPendingApprovals() async {
    try {
      final response = await _dio.get('/v1/approval-requests');
      final list = ApiResponse.list(response);
      return list.map((e) => ApprovalRequestStateModel.fromJson(e)).toList();
    } catch (_) {
      return [];
    }
  }

  @override
  Future<void> applyApprovedAction(ApprovalRequestState request) async {
    if (request.status != 'approved') return;
    
    if (request.action.contains('disable_protection') || 
        request.action.contains('remove_partner')) {
      await PlatformBridge.disableAntiUninstall();
    } else if (request.action.contains('pause_protection')) {
      await PlatformBridge.pauseProtection(request.durationMinutes);
    }
    
    // We should ideally call backend to mark it as applied/resolved
    try {
      await _dio.post('/v1/approval-requests/${request.id}/resolve-by-token');
    } catch (_) {}
  }
}
