import 'package:flutter/material.dart';

import '../models/cart_model.dart';

class CartProvider extends ChangeNotifier {
  final List<CartItem> _items = [];

  List<CartItem> get items => List.unmodifiable(_items);

  bool get isEmpty => _items.isEmpty;

  int get itemCount => _items.length;

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

  void addToCart(CartItem item) {
    final index = _items.indexWhere(
      (e) => e.productId == item.productId,
    );

    if (index != -1) {
      _items[index].quantity++;
    } else {
      _items.add(item);
    }

    notifyListeners();
  }

  void increaseQuantity(String productId) {
    final index = _items.indexWhere(
      (e) => e.productId == productId,
    );

    if (index == -1) return;

    _items[index].quantity++;

    notifyListeners();
  }

  void decreaseQuantity(String productId) {
    final index = _items.indexWhere(
      (e) => e.productId == productId,
    );

    if (index == -1) return;

    if (_items[index].quantity > 1) {
      _items[index].quantity--;
    } else {
      _items.removeAt(index);
    }

    notifyListeners();
  }

  void removeItem(String productId) {
    _items.removeWhere(
      (e) => e.productId == productId,
    );

    notifyListeners();
  }

  void clearCart() {
    _items.clear();
    notifyListeners();
  }

  List<Map<String, dynamic>> toOrderItems() {
    return _items
        .map(
          (e) => e.toOrderItem(),
        )
        .toList();
  }
}