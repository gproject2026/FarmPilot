import 'dart:typed_data';

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

  Future<String> uploadProductImage({
    required Uint8List imageBytes,
    required String fileName,
  }) async {
    isLoading = true;
    notifyListeners();

    try {
      final imageUrl = await productService.uploadProductImage(
        imageBytes: imageBytes,
        fileName: fileName,
      );

      return imageUrl;
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

      products = await productService.getMyProducts();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateProduct({
    required String productId,
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
      await productService.updateProduct(
        productId: productId,
        categoryId: categoryId,
        name: name,
        description: description,
        price: price,
        quantity: quantity,
        unit: unit,
        imageUrl: imageUrl,
      );

      products = await productService.getMyProducts();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteProduct(String productId) async {
    isLoading = true;
    notifyListeners();

    try {
      await productService.deleteProduct(productId);

      products.removeWhere(
        (product) => product['id'].toString() == productId,
      );
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}