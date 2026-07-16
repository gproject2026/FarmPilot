import '../core/api/api_client.dart';

class CategoryService {
  final ApiClient apiClient = ApiClient();

  Future<List<dynamic>> getCategories() async {
    try {
      final response = await apiClient.dio.get(
        '/categories',
      );

      return response.data;
    } catch (e) {
      throw Exception(
        'Failed to load categories: $e',
      );
    }
  }
}