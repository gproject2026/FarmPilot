import 'dart:convert';

import 'package:http/http.dart' as http;

class CropService {
  static const String baseUrl = 'http://localhost:3000';

  Future<List<dynamic>> getMyCrops(String token) async {
    final response = await http.get(
      Uri.parse('$baseUrl/crops/my'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body) as List<dynamic>;
    }

    throw Exception('Failed to load crops');
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
      Uri.parse('$baseUrl/crops'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'cropName': cropName,
        if (cropType != null && cropType.isNotEmpty)
          'cropType': cropType,
        if (plantingDate != null && plantingDate.isNotEmpty)
          'plantingDate': plantingDate,
        if (irrigationSchedule != null &&
            irrigationSchedule.isNotEmpty)
          'irrigationSchedule': irrigationSchedule,
        if (fertilizationSchedule != null &&
            fertilizationSchedule.isNotEmpty)
          'fertilizationSchedule': fertilizationSchedule,
        if (notes != null && notes.isNotEmpty)
          'notes': notes,
      }),
    );

    if (response.statusCode == 201) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    }

    throw Exception('Failed to create crop');
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
      Uri.parse('$baseUrl/crops/$cropId'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'cropName': cropName,
        if (cropType != null) 'cropType': cropType,
        if (plantingDate != null) 'plantingDate': plantingDate,
        if (irrigationSchedule != null)
          'irrigationSchedule': irrigationSchedule,
        if (fertilizationSchedule != null)
          'fertilizationSchedule': fertilizationSchedule,
        if (notes != null) 'notes': notes,
      }),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    }

    throw Exception('Failed to update crop');
  }

  Future<void> deleteCrop({
    required String token,
    required String cropId,
  }) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/crops/$cropId'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to delete crop');
    }
  }
}