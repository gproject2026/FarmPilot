import 'package:dio/dio.dart';

import '../core/api/api_client.dart';

class AiService {
  final ApiClient apiClient = ApiClient();

  Future<Map<String, dynamic>> generateMarketingContent({
    required String productName,
    required String productDetails,
    String? productId,
    String? targetAudience,
  }) async {
    try {
      final response = await apiClient.dio.post(
        '/ai/marketing-description',
        data: {
          "productId": productId,
          "productName": productName,
          "productDetails": productDetails,
          "targetAudience": targetAudience,
        },
      );

      return Map<String, dynamic>.from(
        response.data,
      );
    } on DioException catch (e) {
      throw Exception(
        e.response?.data['message'] ??
            'Failed to generate marketing content',
      );
    }
  }
}