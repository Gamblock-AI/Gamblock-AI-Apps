import 'package:dio/dio.dart';
import '../../domain/entities/reflection_entry.dart';
import '../../domain/repositories/recovery_repository.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_response.dart';

class RecoveryRepositoryImpl implements RecoveryRepository {
  final Dio _dio;

  RecoveryRepositoryImpl({Dio? dio}) : _dio = dio ?? ApiClient.dio;

  @override
  Future<List<ReflectionEntry>> fetchReflections() async {
    final response = await _dio.get('/v1/reflections');
    return ApiResponse.list(response)
        .map((e) => ReflectionEntry.fromJson(e))
        .toList();
  }

  @override
  Future<void> submitReflection({required String text, required String mood}) async {
    await _dio.post('/v1/reflections', data: {'text': text, 'mood': mood});
  }
}
