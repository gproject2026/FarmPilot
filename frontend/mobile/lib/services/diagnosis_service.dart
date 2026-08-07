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
    try {
      final response = await _dio.post(
        '/diagnoses/analyze',
        data: {
          'imageUrl': imageUrl,
          'plantName': plantName,
          'symptoms': symptoms,
          'cropId': cropId,
        },
      );

      if (response.data
          is Map<String, dynamic>) {
        return response.data;
      }

      return Map<String, dynamic>.from(
        jsonDecode(
          jsonEncode(response.data),
        ),
      );
    } on DioException catch (error) {
      throw Exception(
        _getServerMessage(
          error,
          fallback:
              'Failed to analyze plant image',
        ),
      );
    } catch (error) {
      throw Exception(
        'Failed to analyze plant image: $error',
      );
    }
  }

  Future<List<dynamic>>
      getMyDiagnoses() async {
    try {
      final response = await _dio.get(
        '/diagnoses/my',
      );

      if (response.data is List) {
        return List<dynamic>.from(
          response.data,
        );
      }

      return List<dynamic>.from(
        jsonDecode(
          jsonEncode(response.data),
        ),
      );
    } on DioException catch (error) {
      throw Exception(
        _getServerMessage(
          error,
          fallback:
              'Failed to load diagnosis history',
        ),
      );
    } catch (error) {
      throw Exception(
        'Failed to load diagnosis history: $error',
      );
    }
  }

  Future<Map<String, dynamic>>
      getDiagnosisById(
    String diagnosisId,
  ) async {
    try {
      final response = await _dio.get(
        '/diagnoses/$diagnosisId',
      );

      if (response.data
          is Map<String, dynamic>) {
        return response.data;
      }

      return Map<String, dynamic>.from(
        jsonDecode(
          jsonEncode(response.data),
        ),
      );
    } on DioException catch (error) {
      throw Exception(
        _getServerMessage(
          error,
          fallback:
              'Failed to load diagnosis details',
        ),
      );
    } catch (error) {
      throw Exception(
        'Failed to load diagnosis details: $error',
      );
    }
  }

  Future<Map<String, dynamic>>
      translateDiagnosisToArabic({
    required String plantName,
    required String diseaseName,
    required List<String> visibleSymptoms,
    required String description,
    required String causes,
    required String treatment,
    required String prevention,
  }) async {
    try {
      final response = await _dio.post(
        '/diagnoses/translate',
        data: {
          'plantName': plantName,
          'diseaseName': diseaseName,
          'visibleSymptoms':
              visibleSymptoms,
          'description': description,
          'causes': causes,
          'treatment': treatment,
          'prevention': prevention,
        },
      );

      if (response.data
          is Map<String, dynamic>) {
        return response.data;
      }

      return Map<String, dynamic>.from(
        jsonDecode(
          jsonEncode(response.data),
        ),
      );
    } on DioException catch (error) {
      throw Exception(
        _getServerMessage(
          error,
          fallback:
              'Failed to translate diagnosis',
        ),
      );
    } catch (error) {
      throw Exception(
        'Failed to translate diagnosis: $error',
      );
    }
  }

  Future<void> deleteDiagnosis(
    String diagnosisId,
  ) async {
    try {
      await _dio.delete(
        '/diagnoses/$diagnosisId',
      );
    } on DioException catch (error) {
      throw Exception(
        _getServerMessage(
          error,
          fallback:
              'Failed to delete diagnosis',
        ),
      );
    } catch (error) {
      throw Exception(
        'Failed to delete diagnosis: $error',
      );
    }
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