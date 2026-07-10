import '../core/api/api_client.dart';


class DashboardService {


  final ApiClient apiClient = ApiClient();



  Future<Map<String, dynamic>> getFarmerDashboard() async {


    try {


      final response = await apiClient.dio.get(
        '/dashboard/farmer',
      );


      return response.data;



    } catch (e) {


      throw Exception(
        "Failed to load dashboard: $e",
      );


    }


  }



}