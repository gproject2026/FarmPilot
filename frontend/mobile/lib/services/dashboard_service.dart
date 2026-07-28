import 'package:dio/dio.dart';

import '../core/api/api_client.dart';

class DashboardService {
  final ApiClient apiClient = ApiClient();

  Future<Map<String, dynamic>>
      getFarmerDashboard() async {
    try {
      final response =
          await apiClient.dio.get(
        '/dashboard/farmer',
      );

      return Map<String, dynamic>.from(
        response.data,
      );
    } on DioException catch (e) {
      throw Exception(
        e.response?.data['message'] ??
            'Failed to load farmer dashboard',
      );
    } catch (e) {
      throw Exception(
        'Failed to load farmer dashboard: $e',
      );
    }
  }

  Future<Map<String, dynamic>>
      getAdminDashboard() async {
    try {
      final response =
          await apiClient.dio.get(
        '/dashboard/admin',
      );

      return Map<String, dynamic>.from(
        response.data,
      );
    } on DioException catch (e) {
      throw Exception(
        e.response?.data['message'] ??
            'Failed to load admin dashboard',
      );
    } catch (e) {
      throw Exception(
        'Failed to load admin dashboard: $e',
      );
    }
  }
}