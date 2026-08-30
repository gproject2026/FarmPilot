import 'package:flutter/material.dart';

import '../models/cart_model.dart';

class CartProvider extends ChangeNotifier {
  final List<CartItem> _items = [];

  List<CartItem> get items =>
      List.unmodifiable(_items);

  bool get isEmpty => _items.isEmpty;

  int get itemCount => _items.length;

  double get totalQuantity {
    return _items.fold<double>(
      0,
      (sum, item) =>
          sum + item.quantity,
    );
  }

  double get totalPrice {
    return _items.fold<double>(
      0,
      (sum, item) =>
          sum + item.totalPrice,
    );
  }

  void addToCart(CartItem item) {
    final index = _items.indexWhere(
      (e) =>
          e.productId ==
          item.productId,
    );

    if (index == -1) {
      _items.add(item);
      notifyListeners();
      return;
    }

    final existingItem =
        _items[index];

    final incomingQuantity =
        _convertQuantity(
      quantity: item.quantity,
      fromUnit: item.selectedUnit,
      toUnit: existingItem.selectedUnit,
    );

    existingItem.quantity +=
        incomingQuantity;

    notifyListeners();
  }

  void increaseQuantity(
    String productId,
  ) {
    final index =
        _items.indexWhere(
      (e) =>
          e.productId ==
          productId,
    );

    if (index == -1) {
      return;
    }

    final item = _items[index];

    item.quantity +=
        _quantityStep(
      item.selectedUnit,
    );

    notifyListeners();
  }

  void decreaseQuantity(
    String productId,
  ) {
    final index =
        _items.indexWhere(
      (e) =>
          e.productId ==
          productId,
    );

    if (index == -1) {
      return;
    }

    final item = _items[index];

    final step =
        _quantityStep(
      item.selectedUnit,
    );

    final newQuantity =
        item.quantity - step;

    if (newQuantity > 0) {
      item.quantity =
          _roundQuantity(
        newQuantity,
      );
    } else {
      _items.removeAt(index);
    }

    notifyListeners();
  }

  void updateQuantity({
    required String productId,
    required double quantity,
  }) {
    final index =
        _items.indexWhere(
      (e) =>
          e.productId ==
          productId,
    );

    if (index == -1) {
      return;
    }

    if (quantity <= 0) {
      _items.removeAt(index);
      notifyListeners();
      return;
    }

    _items[index].quantity =
        _roundQuantity(
      quantity,
    );

    notifyListeners();
  }

  void changeUnit({
    required String productId,
    required String unit,
  }) {
    final index =
        _items.indexWhere(
      (e) =>
          e.productId ==
          productId,
    );

    if (index == -1) {
      return;
    }

    final item = _items[index];

    item.changeUnit(unit);

    item.quantity =
        _roundQuantity(
      item.quantity,
    );

    notifyListeners();
  }

  void removeItem(
    String productId,
  ) {
    _items.removeWhere(
      (e) =>
          e.productId ==
          productId,
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
          (e) =>
              e.toOrderItem(),
        )
        .toList();
  }

  double _quantityStep(
    String unit,
  ) {
    switch (
        unit.trim().toLowerCase()) {
      case 'ton':
        return 0.1;

      case 'kg':
      case 'piece':
      case 'box':
      default:
        return 1.0;
    }
  }

  double _convertQuantity({
    required double quantity,
    required String fromUnit,
    required String toUnit,
  }) {
    final from =
        fromUnit
            .trim()
            .toLowerCase();

    final to =
        toUnit
            .trim()
            .toLowerCase();

    if (from == to) {
      return quantity;
    }

    if (from == 'kg' &&
        to == 'ton') {
      return quantity / 1000.0;
    }

    if (from == 'ton' &&
        to == 'kg') {
      return quantity * 1000.0;
    }

    return quantity;
  }

  double _roundQuantity(
    double value,
  ) {
    return double.parse(
      value.toStringAsFixed(3),
    );
  }
}