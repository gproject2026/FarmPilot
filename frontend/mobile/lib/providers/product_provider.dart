import 'package:flutter/material.dart';

import '../services/product_service.dart';

class ProductProvider extends ChangeNotifier {
  final ProductService productService = ProductService();

  bool isLoading = false;

  List<dynamic> products = [];

  Future<void> loadMyProducts() async {
    isLoading = true;
    notifyListeners();

    try {
      products = await productService.getMyProducts();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> createProduct({
    required String categoryId,
    required String name,
    required String description,
    required double price,
    required int quantity,
    required String unit,
    String? imageUrl,
  }) async {
    isLoading = true;
    notifyListeners();

    try {
      await productService.createProduct(
        categoryId: categoryId,
        name: name,
        description: description,
        price: price,
        quantity: quantity,
        unit: unit,
        imageUrl: imageUrl,
      );

      await loadMyProducts();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}