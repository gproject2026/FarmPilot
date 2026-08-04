import 'dart:typed_data';

import 'package:dio/dio.dart';

import '../core/api/api_client.dart';

class ImageUploadService {
  final ApiClient apiClient = ApiClient();

  Future<String> uploadImage({
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
    } on DioException catch (error) {
      String? serverMessage;

      final responseData =
          error.response?.data;

      if (responseData is Map) {
        serverMessage =
            responseData['message']?.toString();
      }

      throw Exception(
        serverMessage ??
            'Could not upload the image',
      );
    } catch (error) {
      throw Exception(
        'Failed to upload image: $error',
      );
    }
  }
}