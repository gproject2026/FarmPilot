import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../services/ai_service.dart';
import '../services/image_upload_service.dart';
import '../services/product_service.dart';

class ProductProvider extends ChangeNotifier {
  final ProductService productService =
      ProductService();

  final ImageUploadService imageUploadService =
      ImageUploadService();

  final AiService aiService =
      AiService();

  bool isLoading = false;

  String? errorMessage;

  List products = [];

  List adminProducts = [];

  Future<void> loadAllProducts() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      products =
          await productService
              .getAllProducts();
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

  Future<void> loadMyProducts() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      products =
          await productService
              .getMyProducts();
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

  Future<void> loadAdminProducts() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      adminProducts =
          await productService
              .getAdminProducts();
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

  Future<bool> updateAdminProductStatus({
    required String productId,
    required String status,
  }) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final updatedProduct =
          await productService
              .updateProductStatus(
        productId: productId,
        status: status,
      );

      final index =
          adminProducts.indexWhere(
        (product) =>
            product['id']
                ?.toString() ==
            productId,
      );

      if (index != -1) {
        adminProducts[index] =
            updatedProduct;
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

  Future<Map<String, dynamic>>
      generateMarketingContent({
    required String productName,
    required String productDetails,
    required String language,
    String? productId,
    String? targetAudience,
  }) async {
    isLoading = true;
    notifyListeners();

    try {
      return await aiService
          .generateMarketingContent(
        productName: productName,
        productDetails: productDetails,
        language: language,
        productId: productId,
        targetAudience: targetAudience,
      );
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future uploadProductImage({
    required Uint8List imageBytes,
    required String fileName,
  }) async {
    isLoading = true;
    notifyListeners();

    try {
      return await imageUploadService
          .uploadImage(
        imageBytes: imageBytes,
        fileName: fileName,
      );
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> createProduct({
    required String categoryId,
    required String name,
    required String description,
    required String nameEn,
    required String nameAr,
    required String descriptionEn,
    required String descriptionAr,
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
        nameEn: nameEn,
        nameAr: nameAr,
        descriptionEn:
            descriptionEn,
        descriptionAr:
            descriptionAr,
        price: price,
        quantity: quantity,
        unit: unit,
        imageUrl: imageUrl,
      );

      products =
          await productService
              .getMyProducts();
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
    required String nameEn,
    required String nameAr,
    required String descriptionEn,
    required String descriptionAr,
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
        nameEn: nameEn,
        nameAr: nameAr,
        descriptionEn:
            descriptionEn,
        descriptionAr:
            descriptionAr,
        price: price,
        quantity: quantity,
        unit: unit,
        imageUrl: imageUrl,
      );

      products =
          await productService
              .getMyProducts();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteProduct(
    String productId,
  ) async {
    isLoading = true;
    notifyListeners();

    try {
      await productService.deleteProduct(
        productId,
      );

      products.removeWhere(
        (product) =>
            product['id']
                .toString() ==
            productId,
      );
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  void clearError() {
    errorMessage = null;
    notifyListeners();
  }
}