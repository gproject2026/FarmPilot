import 'package:flutter/material.dart';

import '../models/supplier_cart_model.dart';

class SupplierCartProvider extends ChangeNotifier {
  final List<SupplierCartItem> _items = [];

  List<SupplierCartItem> get items {
    return List.unmodifiable(_items);
  }

  bool get isEmpty {
    return _items.isEmpty;
  }

  int get itemCount {
    return _items.length;
  }

  String? get supplierId {
    if (_items.isEmpty) {
      return null;
    }

    return _items.first.supplierId;
  }

  int get totalQuantity {
    return _items.fold(
      0,
      (sum, item) => sum + item.quantity,
    );
  }

  double get totalPrice {
    return _items.fold(
      0,
      (sum, item) => sum + item.totalPrice,
    );
  }

  bool canAddProduct(
    String productSupplierId,
  ) {
    if (_items.isEmpty) {
      return true;
    }

    return supplierId == productSupplierId;
  }

  bool addToCart(
    SupplierCartItem item,
  ) {
    if (!canAddProduct(item.supplierId)) {
      return false;
    }

    final index = _items.indexWhere(
      (existingItem) =>
          existingItem.productId ==
          item.productId,
    );

    if (index != -1) {
      final existingItem = _items[index];

      if (!existingItem.canIncrease) {
        return false;
      }

      existingItem.quantity++;
    } else {
      if (item.availableQuantity <= 0) {
        return false;
      }

      if (item.quantity >
          item.availableQuantity) {
        return false;
      }

      _items.add(item);
    }

    notifyListeners();

    return true;
  }

  bool increaseQuantity(
    String productId,
  ) {
    final index = _items.indexWhere(
      (item) =>
          item.productId == productId,
    );

    if (index == -1) {
      return false;
    }

    final item = _items[index];

    if (!item.canIncrease) {
      return false;
    }

    item.quantity++;

    notifyListeners();

    return true;
  }

  void decreaseQuantity(
    String productId,
  ) {
    final index = _items.indexWhere(
      (item) =>
          item.productId == productId,
    );

    if (index == -1) {
      return;
    }

    if (_items[index].quantity > 1) {
      _items[index].quantity--;
    } else {
      _items.removeAt(index);
    }

    notifyListeners();
  }

  void removeItem(
    String productId,
  ) {
    _items.removeWhere(
      (item) =>
          item.productId == productId,
    );

    notifyListeners();
  }

  void clearCart() {
    _items.clear();

    notifyListeners();
  }

  List<Map<String, dynamic>>
      toOrderItems() {
    return _items
        .map(
          (item) =>
              item.toOrderItem(),
        )
        .toList();
  }
}