import 'package:dio/dio.dart';

import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_response.dart';
import '../../domain/entities/journey_snapshot.dart';
import '../../domain/repositories/journey_repository.dart';

class JourneyRepositoryImpl implements JourneyRepository {
  JourneyRepositoryImpl({Dio? dio}) : _dio = dio ?? ApiClient.dio;

  final Dio _dio;

  @override
  Future<JourneySnapshot> fetchSnapshot() async {
    final response = await _dio.get(
      '/v1/client/progress',
      queryParameters: {'days': 90},
    );
    return JourneySnapshot.fromJson(ApiResponse.map(response) ?? const {});
  }

  @override
  Future<PracticeSummary> fetchPracticeSummary() async {
    final response = await _dio.get('/v1/recovery-practices');
    final items = ApiResponse.list(response);
    final kinds = <String>{};
    var count = 0;
    for (final item in items) {
      final kind = item['practice_kind']?.toString();
      if (kind != null && kind.isNotEmpty) {
        kinds.add(kind);
        count++;
      }
    }
    return PracticeSummary(kinds: kinds, count: count);
  }

  @override
  Future<EducationSummary> fetchEducationSummary(String locale) async {
    final response = await _dio.get(
      '/v1/psychoeducation/modules',
      queryParameters: {'locale': locale},
    );
    final items = ApiResponse.list(response);
    var started = 0;
    var completed = 0;
    for (final item in items) {
      final progress = item['progress'];
      if (progress is! Map) continue;
      final percent =
          int.tryParse(progress['progress_percent']?.toString() ?? '') ?? 0;
      if (percent > 0) started++;
      if (percent >= 100) completed++;
    }
    return EducationSummary(started: started, completed: completed);
  }
}
