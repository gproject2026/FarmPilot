import 'package:dio/dio.dart';

import '../core/api/api_client.dart';

class SupplierOrderService {
  final ApiClient apiClient = ApiClient();

  Future<Map<String, dynamic>> createSupplierOrder({
    required List<Map<String, dynamic>> items,
    required String deliveryMethod,
    String? deliveryAddress,
    String paymentMethod = 'CASH',
  }) async {
    try {
      final response = await apiClient.dio.post(
        '/supplier-orders',
        data: {
          'items': items,
          'deliveryMethod': deliveryMethod,
          if (deliveryAddress != null &&
              deliveryAddress.trim().isNotEmpty)
            'deliveryAddress':
                deliveryAddress.trim(),
          'paymentMethod': paymentMethod,
        },
      );

      final data = response.data;

      if (data is! Map) {
        throw Exception(
          'Invalid supplier order creation response',
        );
      }

      return Map<String, dynamic>.from(
        data,
      );
    } on DioException catch (error) {
      _throwDioMessage(
        error,
        fallback:
            'Failed to create supplier order',
      );
    }
  }

  Future<List> getMyFarmerSupplierOrders() async {
    try {
      final response = await apiClient.dio.get(
        '/supplier-orders/farmer/my',
      );

      final data = response.data;

      if (data is! List) {
        throw Exception(
          'Invalid farmer supplier orders response',
        );
      }

      return data;
    } on DioException catch (error) {
      _throwDioMessage(
        error,
        fallback:
            'Failed to load farmer supplier orders',
      );
    }
  }

  Future<List> getMySupplierOrders() async {
    try {
      final response = await apiClient.dio.get(
        '/supplier-orders/supplier/my',
      );

      final data = response.data;

      if (data is! List) {
        throw Exception(
          'Invalid supplier orders response',
        );
      }

      return data;
    } on DioException catch (error) {
      _throwDioMessage(
        error,
        fallback:
            'Failed to load supplier orders',
      );
    }
  }

  Future<Map<String, dynamic>> getSupplierOrderById(
    String orderId,
  ) async {
    try {
      final response = await apiClient.dio.get(
        '/supplier-orders/$orderId',
      );

      final data = response.data;

      if (data is! Map) {
        throw Exception(
          'Invalid supplier order response',
        );
      }

      return Map<String, dynamic>.from(
        data,
      );
    } on DioException catch (error) {
      _throwDioMessage(
        error,
        fallback:
            'Failed to load supplier order',
      );
    }
  }

  Future<Map<String, dynamic>>
      updateSupplierOrderStatus({
    required String orderId,
    required String status,
  }) async {
    try {
      final response = await apiClient.dio.patch(
        '/supplier-orders/$orderId/status',
        data: {
          'status': status,
        },
      );

      final data = response.data;

      if (data is! Map) {
        throw Exception(
          'Invalid supplier order status response',
        );
      }

      return Map<String, dynamic>.from(
        data,
      );
    } on DioException catch (error) {
      _throwDioMessage(
        error,
        fallback:
            'Failed to update supplier order status',
      );
    }
  }

  Never _throwDioMessage(
    DioException error, {
    required String fallback,
  }) {
    final responseData =
        error.response?.data;

    if (responseData is Map) {
      final message =
          responseData['message'];

      if (message is List) {
        final messages = message
            .map(
              (item) =>
                  item.toString(),
            )
            .where(
              (item) =>
                  item.trim().isNotEmpty,
            )
            .toList();

        if (messages.isNotEmpty) {
          throw Exception(
            messages.join('\n'),
          );
        }
      }

      if (message != null &&
          message
              .toString()
              .trim()
              .isNotEmpty) {
        throw Exception(
          message.toString(),
        );
      }
    }

    if (responseData is String &&
        responseData.trim().isNotEmpty) {
      throw Exception(
        responseData,
      );
    }

    throw Exception(
      fallback,
    );
  }
}