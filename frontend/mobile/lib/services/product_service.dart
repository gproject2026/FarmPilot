import 'dart:typed_data';

import 'package:dio/dio.dart';

import '../core/api/api_client.dart';

class ProductService {
  final ApiClient apiClient = ApiClient();

  Future<List> getAllProducts() async {
    try {
      final response = await apiClient.dio.get(
        '/products',
      );

      if (response.data is! List) {
        throw Exception(
          'Invalid products response',
        );
      }

      return List<dynamic>.from(
        response.data,
      );
    } catch (e) {
      throw Exception(
        'Failed to load all products: $e',
      );
    }
  }

  Future<List> getMyProducts() async {
    try {
      final response = await apiClient.dio.get(
        '/products/my',
      );

      if (response.data is! List) {
        throw Exception(
          'Invalid products response',
        );
      }

      return List<dynamic>.from(
        response.data,
      );
    } catch (e) {
      throw Exception(
        'Failed to load products: $e',
      );
    }
  }

  Future<List> getAdminProducts() async {
    try {
      final response = await apiClient.dio.get(
        '/products/admin/all',
      );

      if (response.data is! List) {
        throw Exception(
          'Invalid admin products response',
        );
      }

      return List<dynamic>.from(
        response.data,
      );
    } catch (e) {
      throw Exception(
        'Failed to load admin products: $e',
      );
    }
  }

  Future<Map<String, dynamic>>
      updateProductStatus({
    required String productId,
    required String status,
  }) async {
    try {
      final response =
          await apiClient.dio.patch(
        '/products/admin/$productId/status',
        data: {
          'status': status,
        },
      );

      if (response.data is! Map) {
        throw Exception(
          'Invalid updated product response',
        );
      }

      return Map<String, dynamic>.from(
        response.data,
      );
    } on DioException catch (e) {
      final responseData =
          e.response?.data;

      if (responseData is Map) {
        final message =
            responseData['message'];

        if (message is List) {
          throw Exception(
            message.join(', '),
          );
        }

        if (message != null &&
            message
                .toString()
                .trim()
                .isNotEmpty) {
          throw Exception(
            message.toString(),
          );
        }
      }

      throw Exception(
        'Failed to update product status',
      );
    } catch (e) {
      throw Exception(
        'Failed to update product status: $e',
      );
    }
  }

  Future uploadProductImage({
    required Uint8List imageBytes,
    required String fileName,
  }) async {
    try {
      final formData = FormData.fromMap({
        'image': MultipartFile.fromBytes(
          imageBytes,
          filename: fileName,
        ),
      });

      final response =
          await apiClient.dio.post(
        '/uploads/image',
        data: formData,
        options: Options(
          contentType:
              'multipart/form-data',
        ),
      );

      final responseData =
          response.data;

      if (responseData is! Map) {
        throw Exception(
          'Invalid image upload response',
        );
      }

      final imageUrl =
          responseData['imageUrl']
              ?.toString();

      if (imageUrl == null ||
          imageUrl.trim().isEmpty) {
        throw Exception(
          'Image URL was not returned from the server',
        );
      }

      return imageUrl.trim();
    } on DioException catch (e) {
      final serverMessage =
          e.response?.data is Map
              ? e.response?.data['message']
                  ?.toString()
              : null;

      throw Exception(
        serverMessage ??
            'Could not upload the product image',
      );
    } catch (e) {
      throw Exception(
        'Failed to upload product image: $e',
      );
    }
  }

  Future<void> createProduct({
    required String categoryId,
    required String name,
    required String description,
    required String nameEn,
    required String nameAr,
    required String descriptionEn,
    required String descriptionAr,
    required double price,
    required int quantity,
    required String unit,
    String? imageUrl,
  }) async {
    try {
      await apiClient.dio.post(
        '/products',
        data: {
          'categoryId': categoryId,

          // old fields for compatibility
          'name': name,
          'description': description,

          // bilingual fields
          'nameEn': nameEn,
          'nameAr': nameAr,
          'descriptionEn':
              descriptionEn,
          'descriptionAr':
              descriptionAr,

          'price': price,
          'quantity': quantity,
          'unit': unit,
          'imageUrl': imageUrl,
        },
      );
    } catch (e) {
      throw Exception(
        'Failed to create product: $e',
      );
    }
  }

  Future<void> updateProduct({
    required String productId,
    required String categoryId,
    required String name,
    required String description,
    required String nameEn,
    required String nameAr,
    required String descriptionEn,
    required String descriptionAr,
    required double price,
    required int quantity,
    required String unit,
    String? imageUrl,
  }) async {
    try {
      await apiClient.dio.patch(
        '/products/$productId',
        data: {
          'categoryId': categoryId,

          // old fields for compatibility
          'name': name,
          'description': description,

          // bilingual fields
          'nameEn': nameEn,
          'nameAr': nameAr,
          'descriptionEn':
              descriptionEn,
          'descriptionAr':
              descriptionAr,

          'price': price,
          'quantity': quantity,
          'unit': unit,
          'imageUrl': imageUrl,
        },
      );
    } catch (e) {
      throw Exception(
        'Failed to update product: $e',
      );
    }
  }

  Future<void> deleteProduct(
    String productId,
  ) async {
    try {
      await apiClient.dio.delete(
        '/products/$productId',
      );
    } catch (e) {
      throw Exception(
        'Failed to delete product: $e',
      );
    }
  }
}