import 'package:flutter/foundation.dart';

import '../models/order_model.dart';
import '../services/order_service.dart';

class OrderProvider extends ChangeNotifier {
  final OrderService _orderService = OrderService();

  List<OrderModel> _customerOrders = [];
  List<OrderModel> _farmerOrders = [];
  List<OrderModel> _adminOrders = [];

  bool _isLoading = false;
  String? _errorMessage;

  List<OrderModel> get customerOrders {
    return List.unmodifiable(_customerOrders);
  }

  List<OrderModel> get farmerOrders {
    return List.unmodifiable(_farmerOrders);
  }

  List<OrderModel> get adminOrders {
    return List.unmodifiable(_adminOrders);
  }

  bool get isLoading => _isLoading;

  String? get errorMessage => _errorMessage;

  Future<void> fetchCustomerOrders({
    required String token,
  }) async {
    _setLoading(true);
    _errorMessage = null;

    try {
      final orders =
          await _orderService.getCustomerOrders(
        token: token,
      );

      _customerOrders = orders.where((order) {
        final status =
            order.status.trim().toUpperCase();

        return status != 'CANCELLED';
      }).toList();
    } catch (error) {
      _errorMessage = _cleanError(error);
    } finally {
      _setLoading(false);
    }
  }

  Future<void> fetchFarmerOrders({
    required String token,
  }) async {
    _setLoading(true);
    _errorMessage = null;

    try {
      _farmerOrders =
          await _orderService.getFarmerOrders(
        token: token,
      );
    } catch (error) {
      _errorMessage = _cleanError(error);
    } finally {
      _setLoading(false);
    }
  }

  Future<void> fetchAdminOrders({
    required String token,
  }) async {
    _setLoading(true);
    _errorMessage = null;

    try {
      _adminOrders =
          await _orderService.getAdminOrders(
        token: token,
      );
    } catch (error) {
      _errorMessage = _cleanError(error);
    } finally {
      _setLoading(false);
    }
  }

  Future<OrderModel?> getOrderById({
    required String token,
    required String orderId,
  }) async {
    _setLoading(true);
    _errorMessage = null;

    try {
      return await _orderService.getOrderById(
        token: token,
        orderId: orderId,
      );
    } catch (error) {
      _errorMessage = _cleanError(error);
      return null;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> createOrder({
    required String token,
    required List<Map<String, dynamic>> items,
    required String deliveryMethod,
    String? deliveryAddress,
    String paymentMethod = 'CASH',
  }) async {
    _setLoading(true);
    _errorMessage = null;

    try {
      final newOrder =
          await _orderService.createOrder(
        token: token,
        items: items,
        deliveryMethod: deliveryMethod,
        deliveryAddress: deliveryAddress,
        paymentMethod: paymentMethod,
      );

      _customerOrders.insert(
        0,
        newOrder,
      );

      return true;
    } catch (error) {
      _errorMessage = _cleanError(error);
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> updateOrderStatus({
    required String token,
    required String orderId,
    required String status,
  }) async {
    _setLoading(true);
    _errorMessage = null;

    try {
      final updatedOrder =
          await _orderService.updateOrderStatus(
        token: token,
        orderId: orderId,
        status: status,
      );

      _replaceOrder(
        orders: _farmerOrders,
        updatedOrder: updatedOrder,
      );

      _replaceOrder(
        orders: _customerOrders,
        updatedOrder: updatedOrder,
      );

      _replaceOrder(
        orders: _adminOrders,
        updatedOrder: updatedOrder,
      );

      return true;
    } catch (error) {
      _errorMessage = _cleanError(error);
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> confirmOrder({
    required String token,
    required String orderId,
  }) {
    return updateOrderStatus(
      token: token,
      orderId: orderId,
      status: 'CONFIRMED',
    );
  }

  Future<bool> completeOrder({
    required String token,
    required String orderId,
  }) {
    return updateOrderStatus(
      token: token,
      orderId: orderId,
      status: 'COMPLETED',
    );
  }

  Future<bool> cancelOrder({
    required String token,
    required String orderId,
  }) async {
    _setLoading(true);
    _errorMessage = null;

    try {
      final updatedOrder =
          await _orderService.updateOrderStatus(
        token: token,
        orderId: orderId,
        status: 'CANCELLED',
      );

      _customerOrders.removeWhere(
        (order) => order.id == orderId,
      );

      _replaceOrder(
        orders: _farmerOrders,
        updatedOrder: updatedOrder,
      );

      _replaceOrder(
        orders: _adminOrders,
        updatedOrder: updatedOrder,
      );

      notifyListeners();

      return true;
    } catch (error) {
      _errorMessage = _cleanError(error);
      return false;
    } finally {
      _setLoading(false);
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  void clearOrders() {
    _customerOrders = [];
    _farmerOrders = [];
    _adminOrders = [];
    _errorMessage = null;

    notifyListeners();
  }

  void _replaceOrder({
    required List<OrderModel> orders,
    required OrderModel updatedOrder,
  }) {
    final orderIndex = orders.indexWhere(
      (order) => order.id == updatedOrder.id,
    );

    if (orderIndex != -1) {
      orders[orderIndex] = updatedOrder;
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  String _cleanError(Object error) {
    return error
        .toString()
        .replaceFirst('Exception: ', '');
  }
}