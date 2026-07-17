import 'dart:typed_data';

import 'package:dio/dio.dart';

import '../core/api/api_client.dart';

class ProductService {
  final ApiClient apiClient = ApiClient();

  Future<List<dynamic>> getMyProducts() async {
    try {
      final response = await apiClient.dio.get(
        '/products/my',
      );

      return response.data;
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
        '/products/upload-image',
        data: formData,
        options: Options(
          contentType: 'multipart/form-data',
        ),
      );

      final imageUrl =
          response.data['imageUrl']?.toString();

      if (imageUrl == null || imageUrl.isEmpty) {
        throw Exception(
          'Image URL was not returned from the server',
        );
      }

      return imageUrl;
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