import 'package:dio/dio.dart';

import '../core/api/api_client.dart';

class ReviewService {
  final ApiClient apiClient = ApiClient();

  Future<List<dynamic>> getProductReviews(
    String productId,
  ) async {
    try {
      final response = await apiClient.dio.get(
        '/reviews/product/$productId',
      );

      if (response.data is! List) {
        throw Exception(
          'Invalid reviews response',
        );
      }

      return List<dynamic>.from(
        response.data,
      );
    } on DioException catch (e) {
      final message = _extractErrorMessage(
        e,
        'Failed to load reviews',
      );

      throw Exception(message);
    } catch (e) {
      throw Exception(
        'Failed to load reviews: $e',
      );
    }
  }

  Future<Map<String, dynamic>> createReview({
    required String productId,
    required int rating,
    String? comment,
  }) async {
    try {
      final response = await apiClient.dio.post(
        '/reviews',
        data: {
          'productId': productId,
          'rating': rating,
          if (comment != null && comment.trim().isNotEmpty)
            'comment': comment.trim(),
        },
      );

      if (response.data is! Map) {
        throw Exception(
          'Invalid review response',
        );
      }

      return Map<String, dynamic>.from(
        response.data,
      );
    } on DioException catch (e) {
      final message = _extractErrorMessage(
        e,
        'Failed to submit review',
      );

      throw Exception(message);
    } catch (e) {
      throw Exception(
        'Failed to submit review: $e',
      );
    }
  }

  Future<void> deleteReview(
    String reviewId,
  ) async {
    try {
      await apiClient.dio.delete(
        '/reviews/$reviewId',
      );
    } on DioException catch (e) {
      final message = _extractErrorMessage(
        e,
        'Failed to delete review',
      );

      throw Exception(message);
    } catch (e) {
      throw Exception(
        'Failed to delete review: $e',
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