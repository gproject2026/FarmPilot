import 'package:flutter/material.dart';

import '../services/category_service.dart';

class CategoryProvider extends ChangeNotifier {
  final CategoryService categoryService =
      CategoryService();

  bool isLoading = false;

  String? errorMessage;

  List categories = [];

  String? selectedCategoryId;

  Future<void> loadCategories() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      categories =
          await categoryService
              .getCategories();

      if (categories.isNotEmpty) {
        final selectedStillExists =
            selectedCategoryId != null &&
                categories.any(
                  (category) =>
                      category['id']
                          ?.toString() ==
                      selectedCategoryId,
                );

        if (!selectedStillExists) {
          selectedCategoryId =
              categories.first['id']
                  ?.toString();
        }
      } else {
        selectedCategoryId = null;
      }
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

  Future<bool> createCategory({
    required String name,
    required String nameEn,
    required String nameAr,
    String? description,
    String? descriptionEn,
    String? descriptionAr,
  }) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final newCategory =
          await categoryService
              .createCategory(
        name: name,
        nameEn: nameEn,
        nameAr: nameAr,
        description: description,
        descriptionEn:
            descriptionEn,
        descriptionAr:
            descriptionAr,
      );

      categories.add(
        newCategory,
      );

      _sortCategories();

      selectedCategoryId ??=
          newCategory['id']
              ?.toString();

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
      isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateCategory({
    required String categoryId,
    required String name,
    required String nameEn,
    required String nameAr,
    String? description,
    String? descriptionEn,
    String? descriptionAr,
  }) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final updatedCategory =
          await categoryService
              .updateCategory(
        categoryId: categoryId,
        name: name,
        nameEn: nameEn,
        nameAr: nameAr,
        description: description,
        descriptionEn:
            descriptionEn,
        descriptionAr:
            descriptionAr,
      );

      final index =
          categories.indexWhere(
        (category) =>
            category['id']
                ?.toString() ==
            categoryId,
      );

      if (index != -1) {
        categories[index] =
            updatedCategory;
      }

      _sortCategories();

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
      isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> deleteCategory(
    String categoryId,
  ) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      await categoryService
          .deleteCategory(
        categoryId,
      );

      categories.removeWhere(
        (category) =>
            category['id']
                ?.toString() ==
            categoryId,
      );

      if (selectedCategoryId ==
          categoryId) {
        selectedCategoryId =
            categories.isNotEmpty
                ? categories.first['id']
                    ?.toString()
                : null;
      }

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

  void clearError() {
    errorMessage = null;
    notifyListeners();
  }

  void _sortCategories() {
    categories.sort(
      (a, b) {
        final nameA =
            (a['nameEn'] ??
                    a['name'] ??
                    '')
                .toString()
                .toLowerCase();

        final nameB =
            (b['nameEn'] ??
                    b['name'] ??
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