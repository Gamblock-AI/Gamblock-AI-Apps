import 'package:dio/dio.dart';

import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_response.dart';
import '../../domain/entities/daily_mission.dart';
import '../../domain/repositories/missions_repository.dart';

class MissionsRepositoryImpl implements MissionsRepository {
  MissionsRepositoryImpl({Dio? dio}) : _dio = dio ?? ApiClient.dio;

  final Dio _dio;

  @override
  Future<DailyMission> fetchToday() async {
    final response = await _dio.get('/v1/missions/today');
    return DailyMission.fromJson(ApiResponse.map(response) ?? const {});
  }

  @override
  Future<DailyMission> claim(int missionNumber) async {
    final response = await _dio.post(
      '/v1/missions/claim',
      data: {'mission_number': missionNumber},
    );
    return DailyMission.fromJson(ApiResponse.map(response) ?? const {});
  }
}
