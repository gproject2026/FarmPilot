import 'package:flutter/material.dart';

import '../services/category_service.dart';

class CategoryProvider extends ChangeNotifier {
  final CategoryService categoryService = CategoryService();

  bool isLoading = false;
  List<dynamic> categories = [];
  String? selectedCategoryId;

  Future<void> loadCategories() async {
    isLoading = true;
    notifyListeners();

    try {
      categories = await categoryService.getCategories();

      if (categories.isNotEmpty) {
        selectedCategoryId ??=
            categories.first['id'].toString();
      }
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  void selectCategory(String? categoryId) {
    selectedCategoryId = categoryId;
    notifyListeners();
  }
}