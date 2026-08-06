import 'package:flutter/material.dart';

import '../services/diagnosis_service.dart';

class DiagnosisProvider extends ChangeNotifier {
  final DiagnosisService diagnosisService =
      DiagnosisService();

  bool isLoading = false;

  bool isDeleting = false;

  String? deletingDiagnosisId;

  Map<String, dynamic>? diagnosisResult;

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

  void clearResult() {
    diagnosisResult = null;
    errorMessage = null;
    notifyListeners();
  }
}