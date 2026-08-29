import 'package:flutter/material.dart';

import '../services/supplier_category_service.dart';

class SupplierCategoryProvider
    extends ChangeNotifier {
  final SupplierCategoryService
      supplierCategoryService =
      SupplierCategoryService();

  bool isLoading = false;

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