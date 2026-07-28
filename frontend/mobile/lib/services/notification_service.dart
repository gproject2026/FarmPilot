import 'package:dio/dio.dart';

import '../core/api/api_client.dart';

class NotificationService {
  final ApiClient apiClient = ApiClient();

  Future<List<dynamic>> getMyNotifications() async {
    try {
      final response = await apiClient.dio.get(
        '/notifications/my',
      );

      if (response.data is! List) {
        throw Exception(
          'Invalid notifications response',
        );
      }

      return List<dynamic>.from(
        response.data,
      );
    } on DioException catch (e) {
      throw Exception(
        _extractErrorMessage(
          e,
          'Failed to load notifications',
        ),
      );
    } catch (e) {
      throw Exception(
        'Failed to load notifications: $e',
      );
    }
  }

  Future<Map<String, dynamic>> markAsRead(
    String notificationId,
  ) async {
    try {
      final response = await apiClient.dio.patch(
        '/notifications/$notificationId/read',
      );

      if (response.data is! Map) {
        throw Exception(
          'Invalid notification response',
        );
      }

      return Map<String, dynamic>.from(
        response.data,
      );
    } on DioException catch (e) {
      throw Exception(
        _extractErrorMessage(
          e,
          'Failed to mark notification as read',
        ),
      );
    } catch (e) {
      throw Exception(
        'Failed to mark notification as read: $e',
      );
    }
  }

  String _extractErrorMessage(
    DioException error,
    String fallbackMessage,
  ) {
    final responseData = error.response?.data;

    if (responseData is Map) {
      final message = responseData['message'];

      if (message is List) {
        return message.join(', ');
      }

      if (message != null) {
        return message.toString();
      }
    }

    return fallbackMessage;
  }
}