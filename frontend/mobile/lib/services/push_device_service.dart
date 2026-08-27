import 'package:dio/dio.dart';

import '../core/api/api_client.dart';

class PushDeviceService {
  final ApiClient apiClient = ApiClient();

  Future<void> registerDevice({
    required String token,
    required String platform,
  }) async {
    try {
      await apiClient.dio.post(
        '/push-devices/register',
        data: {'token': token, 'platform': platform},
      );
    } on DioException catch (e) {
      final responseData = e.response?.data;

      if (responseData is Map) {
        final message = responseData['message'];

        if (message is List) {
          throw Exception(message.join(', '));
        }

        if (message != null) {
          throw Exception(message.toString());
        }
      }

      throw Exception('Failed to register push device');
    }
  }

  Future<void> unregisterDevice({
    required String token,
    required String platform,
  }) async {
    try {
      await apiClient.dio.delete(
        '/push-devices/unregister',
        data: {'token': token, 'platform': platform},
      );
    } on DioException catch (e) {
      final responseData = e.response?.data;

      if (responseData is Map) {
        final message = responseData['message'];

        if (message is List) {
          throw Exception(message.join(', '));
        }

        if (message != null) {
          throw Exception(message.toString());
        }
      }

      throw Exception('Failed to unregister push device');
    }
  }
}
