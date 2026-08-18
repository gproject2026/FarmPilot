import 'dart:convert';

import 'package:http/http.dart' as http;

import '../core/constants/app_constants.dart';

class CropService {
  Future<List<dynamic>> getMyCrops(
    String token,
  ) async {
    final response = await http.get(
      Uri.parse(
        '${AppConstants.baseUrl}/crops/my',
      ),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final decodedBody = jsonDecode(
        response.body,
      );

      if (decodedBody is! List) {
        throw Exception(
          'Invalid crops response',
        );
      }

      return List<dynamic>.from(
        decodedBody,
      );
    }

    throw Exception(
      _readErrorMessage(
        response.body,
        'Failed to load crops',
      ),
    );
  }

  Future<Map<String, dynamic>> createCrop({
    required String token,
    required String cropName,
    String? cropType,
    String? plantingDate,
    String? irrigationSchedule,
    String? fertilizationSchedule,
    String? notes,
  }) async {
    final response = await http.post(
      Uri.parse(
        '${AppConstants.baseUrl}/crops',
      ),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'cropName': cropName,
        if (cropType != null &&
            cropType.isNotEmpty)
          'cropType': cropType,
        if (plantingDate != null &&
            plantingDate.isNotEmpty)
          'plantingDate': plantingDate,
        if (irrigationSchedule != null &&
            irrigationSchedule.isNotEmpty)
          'irrigationSchedule':
              irrigationSchedule,
        if (fertilizationSchedule != null &&
            fertilizationSchedule.isNotEmpty)
          'fertilizationSchedule':
              fertilizationSchedule,
        if (notes != null &&
            notes.isNotEmpty)
          'notes': notes,
      }),
    );

    if (response.statusCode == 200 ||
        response.statusCode == 201) {
      final decodedBody = jsonDecode(
        response.body,
      );

      if (decodedBody
          is! Map<String, dynamic>) {
        throw Exception(
          'Invalid crop response',
        );
      }

      return decodedBody;
    }

    throw Exception(
      _readErrorMessage(
        response.body,
        'Failed to create crop',
      ),
    );
  }

  Future<Map<String, dynamic>> updateCrop({
    required String token,
    required String cropId,
    required String cropName,
    String? cropType,
    String? plantingDate,
    String? irrigationSchedule,
    String? fertilizationSchedule,
    String? notes,
  }) async {
    final response = await http.patch(
      Uri.parse(
        '${AppConstants.baseUrl}/crops/$cropId',
      ),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'cropName': cropName,
        'cropType': ?cropType,
        'plantingDate': ?plantingDate,
        'irrigationSchedule':
            ?irrigationSchedule,
        'fertilizationSchedule':
            ?fertilizationSchedule,
        'notes': ?notes,
      }),
    );

    if (response.statusCode == 200) {
      final decodedBody = jsonDecode(
        response.body,
      );

      if (decodedBody
          is! Map<String, dynamic>) {
        throw Exception(
          'Invalid crop response',
        );
      }

      return decodedBody;
    }

    throw Exception(
      _readErrorMessage(
        response.body,
        'Failed to update crop',
      ),
    );
  }

  Future<void> deleteCrop({
    required String token,
    required String cropId,
  }) async {
    final response = await http.delete(
      Uri.parse(
        '${AppConstants.baseUrl}/crops/$cropId',
      ),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode != 200 &&
        response.statusCode != 204) {
      throw Exception(
        _readErrorMessage(
          response.body,
          'Failed to delete crop',
        ),
      );
    }
  }

  String _readErrorMessage(
    String responseBody,
    String fallbackMessage,
  ) {
    try {
      final decodedBody = jsonDecode(
        responseBody,
      );

      if (decodedBody
          is Map<String, dynamic>) {
        final message =
            decodedBody['message'];

        if (message is String) {
          return message;
        }

        if (message is List) {
          return message.join(', ');
        }
      }
    } catch (_) {
      // Use the fallback message.
    }

    return fallbackMessage;
  }
}