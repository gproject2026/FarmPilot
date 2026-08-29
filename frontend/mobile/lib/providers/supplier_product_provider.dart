import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../services/supplier_product_service.dart';

class SupplierProductProvider extends ChangeNotifier {
  final SupplierProductService supplierProductService =
      SupplierProductService();

  bool isLoading = false;

  String? errorMessage;

  List supplierProducts = [];

  Future<void> loadAllSupplierProducts({
    String? categoryId,
  }) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      supplierProducts =
          await supplierProductService
              .getAllSupplierProducts(
        categoryId: categoryId,
      );
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

  Future<void> loadMySupplierProducts() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      supplierProducts =
          await supplierProductService
              .getMySupplierProducts();
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

  Future<String?> uploadSupplierProductImage({
    required Uint8List imageBytes,
    required String fileName,
  }) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      return await supplierProductService
          .uploadSupplierProductImage(
        imageBytes: imageBytes,
        fileName: fileName,
      );
    } catch (error) {
      errorMessage = error
          .toString()
          .replaceFirst(
            'Exception: ',
            '',
          );

      return null;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> createSupplierProduct({
    required String categoryId,
    required String name,
    required String description,
    required String nameEn,
    required String nameAr,
    required String descriptionEn,
    required String descriptionAr,
    required String plantingInstructions,
    required String plantingInstructionsEn,
    required String plantingInstructionsAr,
    required String irrigationInstructions,
    required String irrigationInstructionsEn,
    required String irrigationInstructionsAr,
    required String usageInstructions,
    required String usageInstructionsEn,
    required String usageInstructionsAr,
    required double price,
    required int quantity,
    required String unit,
    String? imageUrl,
  }) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      await supplierProductService
          .createSupplierProduct(
        categoryId: categoryId,
        name: name,
        description: description,
        nameEn: nameEn,
        nameAr: nameAr,
        descriptionEn: descriptionEn,
        descriptionAr: descriptionAr,
        plantingInstructions:
            plantingInstructions,
        plantingInstructionsEn:
            plantingInstructionsEn,
        plantingInstructionsAr:
            plantingInstructionsAr,
        irrigationInstructions:
            irrigationInstructions,
        irrigationInstructionsEn:
            irrigationInstructionsEn,
        irrigationInstructionsAr:
            irrigationInstructionsAr,
        usageInstructions:
            usageInstructions,
        usageInstructionsEn:
            usageInstructionsEn,
        usageInstructionsAr:
            usageInstructionsAr,
        price: price,
        quantity: quantity,
        unit: unit,
        imageUrl: imageUrl,
      );

      supplierProducts =
          await supplierProductService
              .getMySupplierProducts();

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

  Future<bool> updateSupplierProduct({
    required String productId,
    required String categoryId,
    required String name,
    required String description,
    required String nameEn,
    required String nameAr,
    required String descriptionEn,
    required String descriptionAr,
    required String plantingInstructions,
    required String plantingInstructionsEn,
    required String plantingInstructionsAr,
    required String irrigationInstructions,
    required String irrigationInstructionsEn,
    required String irrigationInstructionsAr,
    required String usageInstructions,
    required String usageInstructionsEn,
    required String usageInstructionsAr,
    required double price,
    required int quantity,
    required String unit,
    String? imageUrl,
    String? status,
  }) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      await supplierProductService
          .updateSupplierProduct(
        productId: productId,
        categoryId: categoryId,
        name: name,
        description: description,
        nameEn: nameEn,
        nameAr: nameAr,
        descriptionEn: descriptionEn,
        descriptionAr: descriptionAr,
        plantingInstructions:
            plantingInstructions,
        plantingInstructionsEn:
            plantingInstructionsEn,
        plantingInstructionsAr:
            plantingInstructionsAr,
        irrigationInstructions:
            irrigationInstructions,
        irrigationInstructionsEn:
            irrigationInstructionsEn,
        irrigationInstructionsAr:
            irrigationInstructionsAr,
        usageInstructions:
            usageInstructions,
        usageInstructionsEn:
            usageInstructionsEn,
        usageInstructionsAr:
            usageInstructionsAr,
        price: price,
        quantity: quantity,
        unit: unit,
        imageUrl: imageUrl,
        status: status,
      );

      supplierProducts =
          await supplierProductService
              .getMySupplierProducts();

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

  Future<bool> deleteSupplierProduct(
    String productId,
  ) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      await supplierProductService
          .deleteSupplierProduct(
        productId,
      );

      supplierProducts.removeWhere(
        (product) =>
            product['id']
                ?.toString() ==
            productId,
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
      isLoading = false;
      notifyListeners();
    }
  }

  void clearError() {
    errorMessage = null;
    notifyListeners();
  }

  void clearProducts() {
    supplierProducts = [];
    errorMessage = null;
    notifyListeners();
  }
}