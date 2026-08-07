import 'package:dio/dio.dart';

import '../core/api/api_client.dart';

class CategoryService {
  final ApiClient apiClient = ApiClient();

  Future<List> getCategories() async {
    try {
      final response =
          await apiClient.dio.get(
        '/categories',
      );

      if (response.data is! List) {
        throw Exception(
          'Invalid categories response',
        );
      }

      return List<dynamic>.from(
        response.data,
      );
    } catch (e) {
      throw Exception(
        'Failed to load categories: $e',
      );
    }
  }

  Future<Map<String, dynamic>>
      createCategory({
    required String name,
    required String nameEn,
    required String nameAr,
    String? description,
    String? descriptionEn,
    String? descriptionAr,
  }) async {
    try {
      final response =
          await apiClient.dio.post(
        '/categories',
        data: {
          'name': name,
          'nameEn': nameEn,
          'nameAr': nameAr,
          'description': description,
          'descriptionEn':
              descriptionEn,
          'descriptionAr':
              descriptionAr,
        },
      );

      if (response.data is! Map) {
        throw Exception(
          'Invalid created category response',
        );
      }

      return Map<String, dynamic>.from(
        response.data,
      );
    } on DioException catch (e) {
      throw Exception(
        _getServerMessage(
          e,
          fallback:
              'Failed to create category',
        ),
      );
    }
  }

  Future<Map<String, dynamic>>
      updateCategory({
    required String categoryId,
    required String name,
    required String nameEn,
    required String nameAr,
    String? description,
    String? descriptionEn,
    String? descriptionAr,
  }) async {
    try {
      final response =
          await apiClient.dio.patch(
        '/categories/$categoryId',
        data: {
          'name': name,
          'nameEn': nameEn,
          'nameAr': nameAr,
          'description': description,
          'descriptionEn':
              descriptionEn,
          'descriptionAr':
              descriptionAr,
        },
      );

      if (response.data is! Map) {
        throw Exception(
          'Invalid updated category response',
        );
      }

      return Map<String, dynamic>.from(
        response.data,
      );
    } on DioException catch (e) {
      throw Exception(
        _getServerMessage(
          e,
          fallback:
              'Failed to update category',
        ),
      );
    }
  }

  Future<void> deleteCategory(
    String categoryId,
  ) async {
    try {
      await apiClient.dio.delete(
        '/categories/$categoryId',
      );
    } on DioException catch (e) {
      throw Exception(
        _getServerMessage(
          e,
          fallback:
              'Failed to delete category',
        ),
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