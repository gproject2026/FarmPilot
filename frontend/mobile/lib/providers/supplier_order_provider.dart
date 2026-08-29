import 'package:flutter/material.dart';

import '../services/supplier_order_service.dart';

class SupplierOrderProvider
    extends ChangeNotifier {
  final SupplierOrderService
      supplierOrderService =
      SupplierOrderService();

  bool isLoading = false;

  bool isUpdatingStatus = false;

  bool isCreatingOrder = false;

  String? errorMessage;

  // Orders shown to the SUPPLIER.
  List supplierOrders = [];

  // Supply orders created by the FARMER.
  List farmerSupplierOrders = [];

  Map<String, dynamic>? selectedOrder;

  Future<void> loadSupplierOrders() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      supplierOrders =
          await supplierOrderService
              .getMySupplierOrders();
    } catch (error) {
      errorMessage = _cleanError(
        error,
      );
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void>
      loadFarmerSupplierOrders() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      farmerSupplierOrders =
          await supplierOrderService
              .getMyFarmerSupplierOrders();
    } catch (error) {
      errorMessage = _cleanError(
        error,
      );
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> createSupplierOrder({
    required List<Map<String, dynamic>>
        items,
    required String deliveryMethod,
    String? deliveryAddress,
    String paymentMethod = 'CASH',
  }) async {
    isCreatingOrder = true;
    errorMessage = null;
    notifyListeners();

    try {
      final createdOrder =
          await supplierOrderService
              .createSupplierOrder(
        items: items,
        deliveryMethod:
            deliveryMethod,
        deliveryAddress:
            deliveryAddress,
        paymentMethod:
            paymentMethod,
      );

      selectedOrder = createdOrder;

      farmerSupplierOrders.insert(
        0,
        createdOrder,
      );

      return true;
    } catch (error) {
      errorMessage = _cleanError(
        error,
      );

      return false;
    } finally {
      isCreatingOrder = false;
      notifyListeners();
    }
  }

  Future<bool> loadSupplierOrderById(
    String orderId,
  ) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      selectedOrder =
          await supplierOrderService
              .getSupplierOrderById(
        orderId,
      );

      return true;
    } catch (error) {
      errorMessage = _cleanError(
        error,
      );

      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateOrderStatus({
    required String orderId,
    required String status,
  }) async {
    isUpdatingStatus = true;
    errorMessage = null;
    notifyListeners();

    try {
      final updatedOrder =
          await supplierOrderService
              .updateSupplierOrderStatus(
        orderId: orderId,
        status: status,
      );

      selectedOrder = updatedOrder;

      _updateOrderInList(
        supplierOrders,
        orderId,
        updatedOrder,
      );

      _updateOrderInList(
        farmerSupplierOrders,
        orderId,
        updatedOrder,
      );

      return true;
    } catch (error) {
      errorMessage = _cleanError(
        error,
      );

      return false;
    } finally {
      isUpdatingStatus = false;
      notifyListeners();
    }
  }

  Future<bool> confirmOrder(
    String orderId,
  ) {
    return updateOrderStatus(
      orderId: orderId,
      status: 'CONFIRMED',
    );
  }

  Future<bool> completeOrder(
    String orderId,
  ) {
    return updateOrderStatus(
      orderId: orderId,
      status: 'COMPLETED',
    );
  }

  Future<bool> cancelOrder(
    String orderId,
  ) {
    return updateOrderStatus(
      orderId: orderId,
      status: 'CANCELLED',
    );
  }

  void _updateOrderInList(
    List orders,
    String orderId,
    Map<String, dynamic> updatedOrder,
  ) {
    final index = orders.indexWhere(
      (order) =>
          order is Map &&
          order['id']?.toString() ==
              orderId,
    );

    if (index != -1) {
      orders[index] = updatedOrder;
    }
  }

  void clearSelectedOrder() {
    selectedOrder = null;
    notifyListeners();
  }

  void clearError() {
    errorMessage = null;
    notifyListeners();
  }

  void clearOrders() {
    supplierOrders = [];
    farmerSupplierOrders = [];
    selectedOrder = null;
    errorMessage = null;
    notifyListeners();
  }

  String _cleanError(
    Object error,
  ) {
    return error
        .toString()
        .replaceFirst(
          'Exception: ',
          '',
        );
  }
}