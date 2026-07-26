import 'package:flutter/material.dart';

import '../services/crop_service.dart';

class CropProvider extends ChangeNotifier {
  final CropService _cropService = CropService();

  List<dynamic> _crops = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<dynamic> get crops => _crops;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> getMyCrops(String token) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _crops = await _cropService.getMyCrops(token);
    } catch (error) {
      _errorMessage = error.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> createCrop({
    required String token,
    required String cropName,
    String? cropType,
    String? plantingDate,
    String? irrigationSchedule,
    String? fertilizationSchedule,
    String? notes,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final newCrop = await _cropService.createCrop(
        token: token,
        cropName: cropName,
        cropType: cropType,
        plantingDate: plantingDate,
        irrigationSchedule: irrigationSchedule,
        fertilizationSchedule: fertilizationSchedule,
        notes: notes,
      );

      _crops.insert(0, newCrop);
      return true;
    } catch (error) {
      _errorMessage = error.toString();
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
    String? plantingDate,
    String? irrigationSchedule,
    String? fertilizationSchedule,
    String? notes,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final updatedCrop = await _cropService.updateCrop(
        token: token,
        cropId: cropId,
        cropName: cropName,
        cropType: cropType,
        plantingDate: plantingDate,
        irrigationSchedule: irrigationSchedule,
        fertilizationSchedule: fertilizationSchedule,
        notes: notes,
      );

      final cropIndex = _crops.indexWhere(
        (crop) => crop['id'] == cropId,
      );

      if (cropIndex != -1) {
        _crops[cropIndex] = updatedCrop;
      }

      return true;
    } catch (error) {
      _errorMessage = error.toString();
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
        (crop) => crop['id'] == cropId,
      );

      return true;
    } catch (error) {
      _errorMessage = error.toString();
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