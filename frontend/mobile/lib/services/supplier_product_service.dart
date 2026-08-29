import 'dart:typed_data';

import 'package:dio/dio.dart';

import '../core/api/api_client.dart';

class SupplierProductService {
  final ApiClient apiClient = ApiClient();

  Future<List> getAllSupplierProducts({
    String? categoryId,
  }) async {
    try {
      final response = await apiClient.dio.get(
        '/supplier-products',
        queryParameters: {
          if (categoryId != null &&
              categoryId.trim().isNotEmpty)
            'categoryId': categoryId.trim(),
        },
      );

      if (response.data is! List) {
        throw Exception(
          'Invalid supplier products response',
        );
      }

      return List<dynamic>.from(
        response.data,
      );
    } catch (e) {
      throw Exception(
        'Failed to load supplier products: $e',
      );
    }
  }

  Future<List> getMySupplierProducts() async {
    try {
      final response = await apiClient.dio.get(
        '/supplier-products/my',
      );

      if (response.data is! List) {
        throw Exception(
          'Invalid supplier products response',
        );
      }

      return List<dynamic>.from(
        response.data,
      );
    } catch (e) {
      throw Exception(
        'Failed to load my supplier products: $e',
      );
    }
  }

  Future<String> uploadSupplierProductImage({
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
        '/supplier-products/upload-image',
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
      _throwDioMessage(
        e,
        fallback:
            'Could not upload the supplier product image',
      );
    } catch (e) {
      throw Exception(
        'Failed to upload supplier product image: $e',
      );
    }
  }

  Future<void> createSupplierProduct({
    required String categoryId,
    required String name,
    required String description,
    required String nameEn,
    required String nameAr,
    required String descriptionEn,
    required String descriptionAr,
    required String plantingInstructions,
    required String plantingInstructionsEn,
    required String plantingInstructionsAr,
    required String irrigationInstructions,
    required String irrigationInstructionsEn,
    required String irrigationInstructionsAr,
    required String usageInstructions,
    required String usageInstructionsEn,
    required String usageInstructionsAr,
    required double price,
    required int quantity,
    required String unit,
    String? imageUrl,
  }) async {
    try {
      final data = <String, dynamic>{
        'categoryId': categoryId.trim(),
        'name': name.trim(),
        if (description.trim().isNotEmpty)
          'description': description.trim(),
        if (nameEn.trim().isNotEmpty)
          'nameEn': nameEn.trim(),
        if (nameAr.trim().isNotEmpty)
          'nameAr': nameAr.trim(),
        if (descriptionEn.trim().isNotEmpty)
          'descriptionEn':
              descriptionEn.trim(),
        if (descriptionAr.trim().isNotEmpty)
          'descriptionAr':
              descriptionAr.trim(),
        if (plantingInstructions
            .trim()
            .isNotEmpty)
          'plantingInstructions':
              plantingInstructions.trim(),
        if (plantingInstructionsEn
            .trim()
            .isNotEmpty)
          'plantingInstructionsEn':
              plantingInstructionsEn.trim(),
        if (plantingInstructionsAr
            .trim()
            .isNotEmpty)
          'plantingInstructionsAr':
              plantingInstructionsAr.trim(),
        if (irrigationInstructions
            .trim()
            .isNotEmpty)
          'irrigationInstructions':
              irrigationInstructions.trim(),
        if (irrigationInstructionsEn
            .trim()
            .isNotEmpty)
          'irrigationInstructionsEn':
              irrigationInstructionsEn.trim(),
        if (irrigationInstructionsAr
            .trim()
            .isNotEmpty)
          'irrigationInstructionsAr':
              irrigationInstructionsAr.trim(),
        if (usageInstructions
            .trim()
            .isNotEmpty)
          'usageInstructions':
              usageInstructions.trim(),
        if (usageInstructionsEn
            .trim()
            .isNotEmpty)
          'usageInstructionsEn':
              usageInstructionsEn.trim(),
        if (usageInstructionsAr
            .trim()
            .isNotEmpty)
          'usageInstructionsAr':
              usageInstructionsAr.trim(),
        'price': price,
        'quantity': quantity,
        'unit': unit.trim(),
        if (imageUrl != null &&
            imageUrl.trim().isNotEmpty)
          'imageUrl': imageUrl.trim(),
      };

      await apiClient.dio.post(
        '/supplier-products',
        data: data,
      );
    } on DioException catch (e) {
      _throwDioMessage(
        e,
        fallback:
            'Failed to create supplier product',
      );
    } catch (e) {
      throw Exception(
        'Failed to create supplier product: $e',
      );
    }
  }

  Future<void> updateSupplierProduct({
    required String productId,
    required String categoryId,
    required String name,
    required String description,
    required String nameEn,
    required String nameAr,
    required String descriptionEn,
    required String descriptionAr,
    required String plantingInstructions,
    required String plantingInstructionsEn,
    required String plantingInstructionsAr,
    required String irrigationInstructions,
    required String irrigationInstructionsEn,
    required String irrigationInstructionsAr,
    required String usageInstructions,
    required String usageInstructionsEn,
    required String usageInstructionsAr,
    required double price,
    required int quantity,
    required String unit,
    String? imageUrl,
    String? status,
  }) async {
    try {
      final data = <String, dynamic>{
        'categoryId': categoryId.trim(),
        'name': name.trim(),
        'description': description.trim(),
        'nameEn': nameEn.trim(),
        'nameAr': nameAr.trim(),
        'descriptionEn':
            descriptionEn.trim(),
        'descriptionAr':
            descriptionAr.trim(),
        'plantingInstructions':
            plantingInstructions.trim(),
        'plantingInstructionsEn':
            plantingInstructionsEn.trim(),
        'plantingInstructionsAr':
            plantingInstructionsAr.trim(),
        'irrigationInstructions':
            irrigationInstructions.trim(),
        'irrigationInstructionsEn':
            irrigationInstructionsEn.trim(),
        'irrigationInstructionsAr':
            irrigationInstructionsAr.trim(),
        'usageInstructions':
            usageInstructions.trim(),
        'usageInstructionsEn':
            usageInstructionsEn.trim(),
        'usageInstructionsAr':
            usageInstructionsAr.trim(),
        'price': price,
        'quantity': quantity,
        'unit': unit.trim(),
        if (imageUrl != null &&
            imageUrl.trim().isNotEmpty)
          'imageUrl': imageUrl.trim(),
        if (status != null &&
            status.trim().isNotEmpty)
          'status': status.trim(),
      };

      await apiClient.dio.patch(
        '/supplier-products/$productId',
        data: data,
      );
    } on DioException catch (e) {
      _throwDioMessage(
        e,
        fallback:
            'Failed to update supplier product',
      );
    } catch (e) {
      throw Exception(
        'Failed to update supplier product: $e',
      );
    }
  }

  Future<void> deleteSupplierProduct(
    String productId,
  ) async {
    try {
      await apiClient.dio.delete(
        '/supplier-products/$productId',
      );
    } on DioException catch (e) {
      _throwDioMessage(
        e,
        fallback:
            'Failed to delete supplier product',
      );
    } catch (e) {
      throw Exception(
        'Failed to delete supplier product: $e',
      );
    }
  }

  Never _throwDioMessage(
    DioException error, {
    required String fallback,
  }) {
    final responseData =
        error.response?.data;

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
      fallback,
    );
  }
}