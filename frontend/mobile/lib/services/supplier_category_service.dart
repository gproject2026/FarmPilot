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

  Future<Map<String, dynamic>>
      createSupplierCategory({
    required String name,
    String? description,
    String? nameEn,
    String? nameAr,
    String? descriptionEn,
    String? descriptionAr,
  }) async {
    try {
      final response =
          await apiClient.dio.post(
        '/supplier-categories',
        data: {
          'name': name.trim(),
          'description':
              _cleanOptionalText(
            description,
          ),
          'nameEn': _cleanOptionalText(
            nameEn,
          ),
          'nameAr': _cleanOptionalText(
            nameAr,
          ),
          'descriptionEn':
              _cleanOptionalText(
            descriptionEn,
          ),
          'descriptionAr':
              _cleanOptionalText(
            descriptionAr,
          ),
        },
      );

      if (response.data is! Map) {
        throw Exception(
          'Invalid create supplier category response',
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
              'Failed to create supplier category',
        ),
      );
    } catch (e) {
      throw Exception(
        'Failed to create supplier category: $e',
      );
    }
  }

  Future<Map<String, dynamic>>
      updateSupplierCategory({
    required String id,
    String? name,
    String? description,
    String? nameEn,
    String? nameAr,
    String? descriptionEn,
    String? descriptionAr,
  }) async {
    try {
      final data =
          <String, dynamic>{};

      if (name != null) {
        data['name'] = name.trim();
      }

      data['description'] =
          _cleanOptionalText(
        description,
      );

      data['nameEn'] =
          _cleanOptionalText(
        nameEn,
      );

      data['nameAr'] =
          _cleanOptionalText(
        nameAr,
      );

      data['descriptionEn'] =
          _cleanOptionalText(
        descriptionEn,
      );

      data['descriptionAr'] =
          _cleanOptionalText(
        descriptionAr,
      );

      final response =
          await apiClient.dio.patch(
        '/supplier-categories/$id',
        data: data,
      );

      if (response.data is! Map) {
        throw Exception(
          'Invalid update supplier category response',
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
              'Failed to update supplier category',
        ),
      );
    } catch (e) {
      throw Exception(
        'Failed to update supplier category: $e',
      );
    }
  }

  Future<void> deleteSupplierCategory({
    required String id,
  }) async {
    try {
      await apiClient.dio.delete(
        '/supplier-categories/$id',
      );
    } on DioException catch (e) {
      throw Exception(
        _getServerMessage(
          e,
          fallback:
              'Failed to delete supplier category',
        ),
      );
    } catch (e) {
      throw Exception(
        'Failed to delete supplier category: $e',
      );
    }
  }

  String? _cleanOptionalText(
    String? value,
  ) {
    if (value == null) {
      return null;
    }

    final cleaned = value.trim();

    if (cleaned.isEmpty) {
      return null;
    }

    return cleaned;
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