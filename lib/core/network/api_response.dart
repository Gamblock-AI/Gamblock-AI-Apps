import 'package:dio/dio.dart';

/// Helpers for unwrapping the backend response envelope
/// `{ "data": ..., "error": null, "request_id": "..." }`.
///
/// Centralized so feature data sources never hand-parse `response.data['data']`
/// inline. Keeps the envelope contract in one place.
class ApiResponse {
  ApiResponse._();

  /// Extract the `data` field from a Dio response as type [T].
  static T data<T>(Response response) {
    final body = response.data;
    if (body is Map<String, dynamic> && body.containsKey('data')) {
      return body['data'] as T;
    }
    return body as T;
  }

  /// Extract the `data` field as a JSON map, or null when absent.
  static Map<String, dynamic>? map(Response response) {
    final body = response.data;
    if (body is Map<String, dynamic>) {
      final d = body['data'];
      if (d is Map<String, dynamic>) return d;
    }
    return null;
  }

  /// Extract the `data` field as a list of JSON maps.
  static List<Map<String, dynamic>> list(Response response) {
    final body = response.data;
    if (body is Map<String, dynamic>) {
      final d = body['data'];
      if (d is List) {
        return d
            .map((e) => e is Map<String, dynamic> ? e : Map<String, dynamic>.from(e as Map))
            .toList();
      }
    }
    return [];
  }
}
