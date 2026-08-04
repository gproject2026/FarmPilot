import 'dart:convert';

import 'package:dio/dio.dart';

import '../core/api/api_client.dart';

class DiagnosisService {
  final Dio _dio = ApiClient().dio;

  Future<Map<String, dynamic>> analyzePlant({
    required String imageUrl,
    String? plantName,
    String? symptoms,
    String? cropId,
  }) async {
    final response = await _dio.post(
      '/diagnoses/analyze',
      data: {
        'imageUrl': imageUrl,
        'plantName': plantName,
        'symptoms': symptoms,
        'cropId': cropId,
      },
    );

    if (response.data is Map<String, dynamic>) {
      return response.data;
    }

    return jsonDecode(
      jsonEncode(response.data),
    );
  }
}