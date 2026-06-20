import 'package:dio/dio.dart';
import '../../domain/entities/dashboard_summary.dart';
import '../../domain/entities/weekly_progress.dart';
import '../../domain/repositories/dashboard_repository.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_response.dart';

/// Dio-backed implementation of [DashboardRepository].
class DashboardRepositoryImpl implements DashboardRepository {
  final Dio _dio;

  DashboardRepositoryImpl({Dio? dio}) : _dio = dio ?? ApiClient.dio;

  @override
  Future<DashboardSummary> fetchSummary() async {
    final response = await _dio.get('/v1/client/dashboard-summary');
    final json = ApiResponse.map(response) ?? const {};
    return DashboardSummary.fromJson(json);
  }

  @override
  Future<WeeklyProgress> fetchProgress() async {
    final response = await _dio.get('/v1/client/progress');
    final json = ApiResponse.map(response) ?? const {};
    return WeeklyProgress.fromJson(json);
  }
}
