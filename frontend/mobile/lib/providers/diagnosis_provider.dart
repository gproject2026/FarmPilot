import 'package:flutter/material.dart';

import '../services/diagnosis_service.dart';

class DiagnosisProvider extends ChangeNotifier {
  final DiagnosisService diagnosisService =
      DiagnosisService();

  bool isLoading = false;

  bool isDeleting = false;

  bool isTranslating = false;

  String? deletingDiagnosisId;

  Map<String, dynamic>? diagnosisResult;

  Map<String, dynamic>? translatedDiagnosis;

  List<dynamic> diagnoses = [];

  String? errorMessage;

  Future<Map<String, dynamic>> analyzePlant({
    required String imageUrl,
    String? plantName,
    String? symptoms,
    String? cropId,
  }) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final result =
          await diagnosisService.analyzePlant(
        imageUrl: imageUrl,
        plantName: plantName,
        symptoms: symptoms,
        cropId: cropId,
      );

      diagnosisResult =
          Map<String, dynamic>.from(
        result,
      );

      return diagnosisResult!;
    } catch (error) {
      errorMessage = error
          .toString()
          .replaceFirst(
            'Exception: ',
            '',
          );

      rethrow;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadMyDiagnoses() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      diagnoses =
          await diagnosisService
              .getMyDiagnoses();
    } catch (error) {
      errorMessage = error
          .toString()
          .replaceFirst(
            'Exception: ',
            '',
          );
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<Map<String, dynamic>?>
      getDiagnosisById(
    String diagnosisId,
  ) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final diagnosis =
          await diagnosisService
              .getDiagnosisById(
        diagnosisId,
      );

      return Map<String, dynamic>.from(
        diagnosis,
      );
    } catch (error) {
      errorMessage = error
          .toString()
          .replaceFirst(
            'Exception: ',
            '',
          );

      return null;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<Map<String, dynamic>?>
      translateDiagnosisToArabic({
    required String plantName,
    required String diseaseName,
    required List<String> visibleSymptoms,
    required String description,
    required String causes,
    required String treatment,
    required String prevention,
  }) async {
    isTranslating = true;
    errorMessage = null;
    notifyListeners();

    try {
      final response =
          await diagnosisService
              .translateDiagnosisToArabic(
        plantName: plantName,
        diseaseName: diseaseName,
        visibleSymptoms:
            visibleSymptoms,
        description: description,
        causes: causes,
        treatment: treatment,
        prevention: prevention,
      );

      final translationData =
          response['translation'];

      if (translationData is Map) {
        translatedDiagnosis =
            Map<String, dynamic>.from(
          translationData,
        );

        return translatedDiagnosis;
      }

      throw Exception(
        'Invalid translation response',
      );
    } catch (error) {
      errorMessage = error
          .toString()
          .replaceFirst(
            'Exception: ',
            '',
          );

      return null;
    } finally {
      isTranslating = false;
      notifyListeners();
    }
  }

  Future<bool> deleteDiagnosis(
    String diagnosisId,
  ) async {
    isDeleting = true;
    deletingDiagnosisId = diagnosisId;
    errorMessage = null;
    notifyListeners();

    try {
      await diagnosisService
          .deleteDiagnosis(
        diagnosisId,
      );

      diagnoses.removeWhere(
        (diagnosis) {
          if (diagnosis is! Map) {
            return false;
          }

          return diagnosis['id']
                  ?.toString() ==
              diagnosisId;
        },
      );

      return true;
    } catch (error) {
      errorMessage = error
          .toString()
          .replaceFirst(
            'Exception: ',
            '',
          );

      return false;
    } finally {
      isDeleting = false;
      deletingDiagnosisId = null;
      notifyListeners();
    }
  }

  void clearTranslation() {
    translatedDiagnosis = null;
    notifyListeners();
  }

  void clearResult() {
    diagnosisResult = null;
    translatedDiagnosis = null;
    errorMessage = null;
    notifyListeners();
  }
}