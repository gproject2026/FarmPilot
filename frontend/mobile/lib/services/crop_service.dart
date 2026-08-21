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
      final decodedBody =
          jsonDecode(response.body);

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

  Future<Map<String, dynamic>>
      createCrop({
    required String token,
    required String cropName,
    String? cropType,
    String? cropNameEn,
    String? cropNameAr,
    String? cropTypeEn,
    String? cropTypeAr,
    String? plantingDate,
    String? irrigationSchedule,
    String? irrigationScheduleEn,
    String? irrigationScheduleAr,
    String? fertilizationSchedule,
    String? fertilizationScheduleEn,
    String? fertilizationScheduleAr,
    String? notes,
    String? notesEn,
    String? notesAr,
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
        if (_hasValue(cropType))
          'cropType': cropType,
        if (_hasValue(cropNameEn))
          'cropNameEn': cropNameEn,
        if (_hasValue(cropNameAr))
          'cropNameAr': cropNameAr,
        if (_hasValue(cropTypeEn))
          'cropTypeEn': cropTypeEn,
        if (_hasValue(cropTypeAr))
          'cropTypeAr': cropTypeAr,
        if (_hasValue(plantingDate))
          'plantingDate':
              plantingDate,
        if (_hasValue(
          irrigationSchedule,
        ))
          'irrigationSchedule':
              irrigationSchedule,
        if (_hasValue(
          irrigationScheduleEn,
        ))
          'irrigationScheduleEn':
              irrigationScheduleEn,
        if (_hasValue(
          irrigationScheduleAr,
        ))
          'irrigationScheduleAr':
              irrigationScheduleAr,
        if (_hasValue(
          fertilizationSchedule,
        ))
          'fertilizationSchedule':
              fertilizationSchedule,
        if (_hasValue(
          fertilizationScheduleEn,
        ))
          'fertilizationScheduleEn':
              fertilizationScheduleEn,
        if (_hasValue(
          fertilizationScheduleAr,
        ))
          'fertilizationScheduleAr':
              fertilizationScheduleAr,
        if (_hasValue(notes))
          'notes': notes,
        if (_hasValue(notesEn))
          'notesEn': notesEn,
        if (_hasValue(notesAr))
          'notesAr': notesAr,
      }),
    );

    if (response.statusCode == 200 ||
        response.statusCode == 201) {
      final decodedBody =
          jsonDecode(response.body);

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

  Future<Map<String, dynamic>>
      updateCrop({
    required String token,
    required String cropId,
    required String cropName,
    String? cropType,
    String? cropNameEn,
    String? cropNameAr,
    String? cropTypeEn,
    String? cropTypeAr,
    String? plantingDate,
    String? irrigationSchedule,
    String? irrigationScheduleEn,
    String? irrigationScheduleAr,
    String? fertilizationSchedule,
    String? fertilizationScheduleEn,
    String? fertilizationScheduleAr,
    String? notes,
    String? notesEn,
    String? notesAr,
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
        'cropType': cropType,
        'cropNameEn': cropNameEn,
        'cropNameAr': cropNameAr,
        'cropTypeEn': cropTypeEn,
        'cropTypeAr': cropTypeAr,
        'plantingDate':
            plantingDate,
        'irrigationSchedule':
            irrigationSchedule,
        'irrigationScheduleEn':
            irrigationScheduleEn,
        'irrigationScheduleAr':
            irrigationScheduleAr,
        'fertilizationSchedule':
            fertilizationSchedule,
        'fertilizationScheduleEn':
            fertilizationScheduleEn,
        'fertilizationScheduleAr':
            fertilizationScheduleAr,
        'notes': notes,
        'notesEn': notesEn,
        'notesAr': notesAr,
      }),
    );

    if (response.statusCode == 200) {
      final decodedBody =
          jsonDecode(response.body);

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

  bool _hasValue(
    String? value,
  ) {
    return value != null &&
        value.trim().isNotEmpty;
  }

  String _readErrorMessage(
    String responseBody,
    String fallbackMessage,
  ) {
    try {
      final decodedBody =
          jsonDecode(responseBody);

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
    } catch (_) {}

    return fallbackMessage;
  }
}