import 'package:dio/dio.dart';
import '../../domain/entities/protection_status.dart';
import '../../domain/repositories/protection_repository.dart';
import '../../../dashboard/domain/entities/dashboard_summary.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_response.dart';

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
}
