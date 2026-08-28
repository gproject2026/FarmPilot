import 'package:flutter/material.dart';

import '../services/ai_service.dart';
import '../services/crop_service.dart';

class CropProvider extends ChangeNotifier {
  final CropService _cropService =
      CropService();

  final AiService _aiService =
      AiService();

  List<dynamic> _crops = [];
  bool _isLoading = false;
  bool _isGeneratingCare = false;
  String? _errorMessage;

  List<dynamic> get crops => _crops;
  bool get isLoading => _isLoading;
  bool get isGeneratingCare =>
      _isGeneratingCare;
  String? get errorMessage =>
      _errorMessage;

  Future<void> getMyCrops(
    String token,
  ) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _crops =
          await _cropService.getMyCrops(
        token,
      );
    } catch (error) {
      _errorMessage =
          error
              .toString()
              .replaceFirst(
                'Exception: ',
                '',
              );
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<Map<String, dynamic>?>
      generateCropCareSuggestion({
    required String cropName,
    required String cropType,
    required String language,
    required double area,
    required String areaUnit,
    String? plantingDate,
    String? notes,
  }) async {
    _isGeneratingCare = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result =
          await _aiService
              .generateCropCareSuggestion(
        cropName: cropName,
        cropType: cropType,
        language: language,
        area: area,
        areaUnit: areaUnit,
        plantingDate: plantingDate,
        notes: notes,
      );

      return result;
    } catch (error) {
      _errorMessage =
          error
              .toString()
              .replaceFirst(
                'Exception: ',
                '',
              );

      return null;
    } finally {
      _isGeneratingCare = false;
      notifyListeners();
    }
  }

  Future<bool> createCrop({
    required String token,
    required String cropName,
    String? cropType,
    String? cropNameEn,
    String? cropNameAr,
    String? cropTypeEn,
    String? cropTypeAr,
    String? plantingDate,
    double? area,
    String? areaUnit,
    double? expectedYieldMin,
    double? expectedYieldMax,
    String? yieldUnit,
    String? yieldConfidence,
    String? irrigationSchedule,
    String? irrigationScheduleEn,
    String? irrigationScheduleAr,
    String? fertilizationSchedule,
    String? fertilizationScheduleEn,
    String? fertilizationScheduleAr,
    String? sprayingSchedule,
    String? sprayingScheduleEn,
    String? sprayingScheduleAr,
    String? notes,
    String? notesEn,
    String? notesAr,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final newCrop =
          await _cropService.createCrop(
        token: token,
        cropName: cropName,
        cropType: cropType,
        cropNameEn: cropNameEn,
        cropNameAr: cropNameAr,
        cropTypeEn: cropTypeEn,
        cropTypeAr: cropTypeAr,
        plantingDate:
            plantingDate,
        area: area,
        areaUnit: areaUnit,
        expectedYieldMin:
            expectedYieldMin,
        expectedYieldMax:
            expectedYieldMax,
        yieldUnit:
            yieldUnit,
        yieldConfidence:
            yieldConfidence,
        irrigationSchedule:
            irrigationSchedule,
        irrigationScheduleEn:
            irrigationScheduleEn,
        irrigationScheduleAr:
            irrigationScheduleAr,
        fertilizationSchedule:
            fertilizationSchedule,
        fertilizationScheduleEn:
            fertilizationScheduleEn,
        fertilizationScheduleAr:
            fertilizationScheduleAr,
        sprayingSchedule:
            sprayingSchedule,
        sprayingScheduleEn:
            sprayingScheduleEn,
        sprayingScheduleAr:
            sprayingScheduleAr,
        notes: notes,
        notesEn: notesEn,
        notesAr: notesAr,
      );

      _crops.insert(
        0,
        newCrop,
      );

      return true;
    } catch (error) {
      _errorMessage =
          error
              .toString()
              .replaceFirst(
                'Exception: ',
                '',
              );

      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateCrop({
    required String token,
    required String cropId,
    required String cropName,
    String? cropType,
    String? cropNameEn,
    String? cropNameAr,
    String? cropTypeEn,
    String? cropTypeAr,
    String? plantingDate,
    double? area,
    String? areaUnit,
    double? expectedYieldMin,
    double? expectedYieldMax,
    String? yieldUnit,
    String? yieldConfidence,
    String? irrigationSchedule,
    String? irrigationScheduleEn,
    String? irrigationScheduleAr,
    String? fertilizationSchedule,
    String? fertilizationScheduleEn,
    String? fertilizationScheduleAr,
    String? sprayingSchedule,
    String? sprayingScheduleEn,
    String? sprayingScheduleAr,
    String? notes,
    String? notesEn,
    String? notesAr,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final updatedCrop =
          await _cropService.updateCrop(
        token: token,
        cropId: cropId,
        cropName: cropName,
        cropType: cropType,
        cropNameEn: cropNameEn,
        cropNameAr: cropNameAr,
        cropTypeEn: cropTypeEn,
        cropTypeAr: cropTypeAr,
        plantingDate:
            plantingDate,
        area: area,
        areaUnit: areaUnit,
        expectedYieldMin:
            expectedYieldMin,
        expectedYieldMax:
            expectedYieldMax,
        yieldUnit:
            yieldUnit,
        yieldConfidence:
            yieldConfidence,
        irrigationSchedule:
            irrigationSchedule,
        irrigationScheduleEn:
            irrigationScheduleEn,
        irrigationScheduleAr:
            irrigationScheduleAr,
        fertilizationSchedule:
            fertilizationSchedule,
        fertilizationScheduleEn:
            fertilizationScheduleEn,
        fertilizationScheduleAr:
            fertilizationScheduleAr,
        sprayingSchedule:
            sprayingSchedule,
        sprayingScheduleEn:
            sprayingScheduleEn,
        sprayingScheduleAr:
            sprayingScheduleAr,
        notes: notes,
        notesEn: notesEn,
        notesAr: notesAr,
      );

      final cropIndex =
          _crops.indexWhere(
        (crop) =>
            crop['id'] == cropId,
      );

      if (cropIndex != -1) {
        _crops[cropIndex] =
            updatedCrop;
      }

      return true;
    } catch (error) {
      _errorMessage =
          error
              .toString()
              .replaceFirst(
                'Exception: ',
                '',
              );

      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> deleteCrop({
    required String token,
    required String cropId,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _cropService.deleteCrop(
        token: token,
        cropId: cropId,
      );

      _crops.removeWhere(
        (crop) =>
            crop['id'] ==
            cropId,
      );

      return true;
    } catch (error) {
      _errorMessage =
          error
              .toString()
              .replaceFirst(
                'Exception: ',
                '',
              );

      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}