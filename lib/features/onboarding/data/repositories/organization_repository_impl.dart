import 'package:dio/dio.dart';
import '../../domain/entities/organization.dart';
import '../../domain/repositories/organization_repository.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_response.dart';

class OrganizationRepositoryImpl implements OrganizationRepository {
  final Dio _dio;

  OrganizationRepositoryImpl({Dio? dio}) : _dio = dio ?? ApiClient.dio;

  @override
  Future<Organization> joinByGroupCode(String groupCode) async {
    final response = await _dio.post('/v1/organizations/join', data: {'group_code': groupCode});
    final json = ApiResponse.map(response);
    if (json == null) {
      throw Exception('Group code tidak valid');
    }
    return Organization.fromJson(json);
  }

  @override
  Future<Organization> create({required String name}) async {
    final response = await _dio.post('/v1/organizations', data: {'name': name});
    final json = ApiResponse.map(response);
    if (json == null) {
      throw Exception('Gagal membuat grup');
    }
    return Organization.fromJson(json);
  }
}
