import 'package:flutter/material.dart';

import '../services/supplier_category_service.dart';

class SupplierCategoryProvider
    extends ChangeNotifier {
  final SupplierCategoryService
      supplierCategoryService =
      SupplierCategoryService();

  bool isLoading = false;
  bool isSaving = false;
  bool isDeleting = false;

  String? errorMessage;

  List supplierCategories = [];

  String? selectedCategoryId;

  Future<void>
      loadSupplierCategories() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      supplierCategories =
          await supplierCategoryService
              .getSupplierCategories();

      if (supplierCategories.isNotEmpty) {
        final selectedStillExists =
            selectedCategoryId != null &&
                supplierCategories.any(
                  (category) =>
                      category['id']
                          ?.toString() ==
                      selectedCategoryId,
                );

        if (!selectedStillExists) {
          selectedCategoryId =
              supplierCategories
                  .first['id']
                  ?.toString();
        }
      } else {
        selectedCategoryId = null;
      }

      _sortCategories();
    } catch (error) {
      errorMessage = error
          .toString()
          .replaceFirst(
            'Exception: ',
            '',
          );

      supplierCategories = [];
      selectedCategoryId = null;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> createSupplierCategory({
    required String name,
    String? description,
    String? nameEn,
    String? nameAr,
    String? descriptionEn,
    String? descriptionAr,
  }) async {
    isSaving = true;
    errorMessage = null;
    notifyListeners();

    try {
      await supplierCategoryService
          .createSupplierCategory(
        name: name,
        description: description,
        nameEn: nameEn,
        nameAr: nameAr,
        descriptionEn:
            descriptionEn,
        descriptionAr:
            descriptionAr,
      );

      await loadSupplierCategories();

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
      isSaving = false;
      notifyListeners();
    }
  }

  Future<bool> updateSupplierCategory({
    required String id,
    required String name,
    String? description,
    String? nameEn,
    String? nameAr,
    String? descriptionEn,
    String? descriptionAr,
  }) async {
    isSaving = true;
    errorMessage = null;
    notifyListeners();

    try {
      await supplierCategoryService
          .updateSupplierCategory(
        id: id,
        name: name,
        description: description,
        nameEn: nameEn,
        nameAr: nameAr,
        descriptionEn:
            descriptionEn,
        descriptionAr:
            descriptionAr,
      );

      await loadSupplierCategories();

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
      isSaving = false;
      notifyListeners();
    }
  }

  Future<bool> deleteSupplierCategory({
    required String id,
  }) async {
    isDeleting = true;
    errorMessage = null;
    notifyListeners();

    try {
      await supplierCategoryService
          .deleteSupplierCategory(
        id: id,
      );

      await loadSupplierCategories();

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
      notifyListeners();
    }
  }

  void selectCategory(
    String? categoryId,
  ) {
    selectedCategoryId =
        categoryId;

    notifyListeners();
  }

  void clearSelection() {
    selectedCategoryId = null;

    notifyListeners();
  }

  void clearError() {
    errorMessage = null;

    notifyListeners();
  }

  void clearCategories() {
    supplierCategories = [];
    selectedCategoryId = null;
    errorMessage = null;

    notifyListeners();
  }

  void _sortCategories() {
    supplierCategories.sort(
      (a, b) {
        final nameA =
            (a['nameEn'] ??
                    a['name'] ??
                    a['nameAr'] ??
                    '')
                .toString()
                .toLowerCase();

        final nameB =
            (b['nameEn'] ??
                    b['name'] ??
                    b['nameAr'] ??
                    '')
                .toString()
                .toLowerCase();

        return nameA.compareTo(
          nameB,
        );
      },
    );
  }
}