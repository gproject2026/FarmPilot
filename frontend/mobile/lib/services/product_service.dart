import '../core/api/api_client.dart';


class ProductService {


  final ApiClient apiClient = ApiClient();




  Future<List<dynamic>> getMyProducts() async {


    try {


      final response =
          await apiClient.dio.get(
        '/products/my',
      );


      return response.data;



    } catch (e) {


      throw Exception(
        "Failed to load products: $e",
      );


    }


  }




}