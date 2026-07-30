import 'dart:convert';

import 'package:http/http.dart' as http;

import '../core/constants/app_constants.dart';
import '../models/order_model.dart';

class OrderService {
  Future<List<OrderModel>> getCustomerOrders({
    required String token,
  }) async {
    final response = await http.get(
      Uri.parse('${AppConstants.baseUrl}/orders/my'),
      headers: _headers(token),
    );

    if (response.statusCode == 200) {
      final decodedBody = jsonDecode(response.body);

      if (decodedBody is! List) {
        throw Exception('Invalid customer orders response');
      }

      return decodedBody
          .map(
            (item) => OrderModel.fromJson(
              Map<String, dynamic>.from(item),
            ),
          )
          .toList();
    }

    throw Exception(
      _readErrorMessage(
        response.body,
        'Failed to load customer orders',
      ),
    );
  }

  Future<List<OrderModel>> getFarmerOrders({
    required String token,
  }) async {
    final response = await http.get(
      Uri.parse('${AppConstants.baseUrl}/orders/farmer'),
      headers: _headers(token),
    );

    if (response.statusCode == 200) {
      final decodedBody = jsonDecode(response.body);

      if (decodedBody is! List) {
        throw Exception('Invalid farmer orders response');
      }

      return decodedBody
          .map(
            (item) => OrderModel.fromJson(
              Map<String, dynamic>.from(item),
            ),
          )
          .toList();
    }

    throw Exception(
      _readErrorMessage(
        response.body,
        'Failed to load farmer orders',
      ),
    );
  }

  Future<OrderModel> getOrderById({
    required String token,
    required String orderId,
  }) async {
    final response = await http.get(
      Uri.parse('${AppConstants.baseUrl}/orders/$orderId'),
      headers: _headers(token),
    );

    if (response.statusCode == 200) {
      return OrderModel.fromJson(
        Map<String, dynamic>.from(
          jsonDecode(response.body),
        ),
      );
    }

    throw Exception(
      _readErrorMessage(
        response.body,
        'Failed to load order',
      ),
    );
  }

  Future<OrderModel> createOrder({
    required String token,
    required List<Map<String, dynamic>> items,
  }) async {
    final response = await http.post(
      Uri.parse('${AppConstants.baseUrl}/orders'),
      headers: _headers(token),
      body: jsonEncode({
        'items': items,
      }),
    );

    if (response.statusCode == 200 ||
        response.statusCode == 201) {
      return OrderModel.fromJson(
        Map<String, dynamic>.from(
          jsonDecode(response.body),
        ),
      );
    }

    throw Exception(
      _readErrorMessage(
        response.body,
        'Failed to create order',
      ),
    );
  }

  Future<OrderModel> updateOrderStatus({
    required String token,
    required String orderId,
    required String status,
  }) async {
    final response = await http.patch(
      Uri.parse(
        '${AppConstants.baseUrl}/orders/$orderId/status',
      ),
      headers: _headers(token),
      body: jsonEncode({
        'status': status,
      }),
    );

    if (response.statusCode == 200) {
      return OrderModel.fromJson(
        Map<String, dynamic>.from(
          jsonDecode(response.body),
        ),
      );
    }

    throw Exception(
      _readErrorMessage(
        response.body,
        'Failed to update order status',
      ),
    );
  }

  Map<String, String> _headers(String token) {
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  String _readErrorMessage(
    String responseBody,
    String fallbackMessage,
  ) {
    try {
      final decodedBody = jsonDecode(responseBody);

      if (decodedBody is Map<String, dynamic>) {
        final message = decodedBody['message'];

        if (message is String) {
          return message;
        }

        if (message is List) {
          return message.join(', ');
        }
      }
    } catch (_) {
      // Use the fallback message.
    }

    return fallbackMessage;
  }
}