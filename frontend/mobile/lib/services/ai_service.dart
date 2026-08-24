import 'package:dio/dio.dart';

import '../core/api/api_client.dart';

class AiService {
  final ApiClient apiClient = ApiClient();

  Future<Map<String, dynamic>>
      generateMarketingContent({
    required String productName,
    required String productDetails,
    required String language,
    String? productId,
    String? targetAudience,
  }) async {
    try {
      final response =
          await apiClient.dio.post(
        '/ai/marketing-description',
        data: {
          'productId': productId,
          'productName': productName,
          'productDetails':
              productDetails,
          'targetAudience':
              targetAudience,
          'language': language,
        },
      );

      return Map<String, dynamic>.from(
        response.data,
      );
    } on DioException catch (e) {
      final responseData =
          e.response?.data;

      String? serverMessage;

      if (responseData is Map) {
        final message =
            responseData['message'];

        if (message is List) {
          serverMessage =
              message.join(', ');
        } else if (message != null) {
          serverMessage =
              message.toString();
        }
      }

      throw Exception(
        serverMessage ??
            'Failed to generate marketing content',
      );
    }
  }

  Future<Map<String, dynamic>>
      generateCropCareSuggestion({
    required String cropName,
    required String cropType,
    required String language,
    required double area,
    required String areaUnit,
    String? plantingDate,
    String? notes,
  }) async {
    try {
      final response =
          await apiClient.dio.post(
        '/ai/crop-care-suggestion',
        data: {
          'cropName': cropName,
          'cropType': cropType,
          'plantingDate':
              plantingDate,
          'notes': notes,
          'language': language,
          'area': area,
          'areaUnit': areaUnit,
        },
      );

      if (response.data is! Map) {
        throw Exception(
          'Invalid crop care response',
        );
      }

      return Map<String, dynamic>.from(
        response.data,
      );
    } on DioException catch (e) {
      final responseData =
          e.response?.data;

      String? serverMessage;

      if (responseData is Map) {
        final message =
            responseData['message'];

        if (message is List) {
          serverMessage =
              message.join(', ');
        } else if (message != null) {
          serverMessage =
              message.toString();
        }
      }

      throw Exception(
        serverMessage ??
            'Failed to generate crop care suggestions',
      );
    } catch (e) {
      throw Exception(
        'Failed to generate crop care suggestions: $e',
      );
    }
  }
}