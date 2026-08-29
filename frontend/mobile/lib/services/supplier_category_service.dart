import 'package:dio/dio.dart';

import '../core/api/api_client.dart';

class SupplierCategoryService {
  final ApiClient apiClient = ApiClient();

  Future<List> getSupplierCategories() async {
    try {
      final response =
          await apiClient.dio.get(
        '/supplier-categories',
      );

      if (response.data is! List) {
        throw Exception(
          'Invalid supplier categories response',
        );
      }

      return List<dynamic>.from(
        response.data,
      );
    } on DioException catch (e) {
      throw Exception(
        _getServerMessage(
          e,
          fallback:
              'Failed to load supplier categories',
        ),
      );
    } catch (e) {
      throw Exception(
        'Failed to load supplier categories: $e',
      );
    }
  }

  String _getServerMessage(
    DioException error, {
    required String fallback,
  }) {
    final responseData =
        error.response?.data;

    if (responseData is Map) {
      final message =
          responseData['message'];

      if (message is List) {
        return message.join(', ');
      }

      if (message != null &&
          message
              .toString()
              .trim()
              .isNotEmpty) {
        return message.toString();
      }
    }

    return fallback;
  }
}