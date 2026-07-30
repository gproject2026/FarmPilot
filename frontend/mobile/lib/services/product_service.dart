import 'dart:typed_data';

import 'package:dio/dio.dart';

import '../core/api/api_client.dart';

class ProductService {
  final ApiClient apiClient = ApiClient();

  Future<List<dynamic>> getAllProducts() async {
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

  Future<List<dynamic>> getMyProducts() async {
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

  Future<String> uploadProductImage({
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

      final response = await apiClient.dio.post(
        '/uploads/image',
        data: formData,
        options: Options(
          contentType: 'multipart/form-data',
        ),
      );

      final responseData = response.data;

      if (responseData is! Map) {
        throw Exception(
          'Invalid image upload response',
        );
      }

      final imageUrl =
          responseData['imageUrl']?.toString();

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
              ? e.response?.data['message']?.toString()
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
          'name': name,
          'description': description,
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
          'name': name,
          'description': description,
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