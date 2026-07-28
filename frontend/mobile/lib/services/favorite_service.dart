import 'package:dio/dio.dart';

import '../core/api/api_client.dart';

class FavoriteService {
  final ApiClient apiClient = ApiClient();

  Future<List<dynamic>> getFavorites() async {
    try {
      final response = await apiClient.dio.get(
        '/favorites',
      );

      if (response.data is! List) {
        throw Exception(
          'Invalid favorites response',
        );
      }

      return List<dynamic>.from(
        response.data,
      );
    } on DioException catch (e) {
      final message = _extractErrorMessage(
        e,
        'Failed to load favorites',
      );

      throw Exception(message);
    } catch (e) {
      throw Exception(
        'Failed to load favorites: $e',
      );
    }
  }

  Future<Map<String, dynamic>> addFavorite(
    String productId,
  ) async {
    try {
      final response = await apiClient.dio.post(
        '/favorites',
        data: {
          'productId': productId,
        },
      );

      if (response.data is! Map) {
        throw Exception(
          'Invalid favorite response',
        );
      }

      return Map<String, dynamic>.from(
        response.data,
      );
    } on DioException catch (e) {
      final message = _extractErrorMessage(
        e,
        'Failed to add product to favorites',
      );

      throw Exception(message);
    } catch (e) {
      throw Exception(
        'Failed to add product to favorites: $e',
      );
    }
  }

  Future<void> removeFavorite(
    String productId,
  ) async {
    try {
      await apiClient.dio.delete(
        '/favorites/$productId',
      );
    } on DioException catch (e) {
      final message = _extractErrorMessage(
        e,
        'Failed to remove product from favorites',
      );

      throw Exception(message);
    } catch (e) {
      throw Exception(
        'Failed to remove product from favorites: $e',
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