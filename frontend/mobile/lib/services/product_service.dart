import '../core/api/api_client.dart';

class ProductService {
  final ApiClient apiClient = ApiClient();

  Future<List<dynamic>> getMyProducts() async {
    try {
      final response = await apiClient.dio.get(
        '/products/my',
      );

      return response.data;
    } catch (e) {
      throw Exception(
        "Failed to load products: $e",
      );
    }
  }

  Future<void> createProduct({
    required String categoryId,
    required String name,
    required String description,
    required double price,
    required int quantity,
    required String unit,
    String? imageUrl,
  }) async {
    try {
      await apiClient.dio.post(
        '/products',
        data: {
          'categoryId': categoryId,
          'name': name,
          'description': description,
          'price': price,
          'quantity': quantity,
          'unit': unit,
          'imageUrl': imageUrl,
        },
      );
    } catch (e) {
      throw Exception(
        "Failed to create product: $e",
      );
    }
  }
}