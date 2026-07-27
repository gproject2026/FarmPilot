import 'package:dio/dio.dart';

import '../core/api/api_client.dart';
import '../models/user_model.dart';

class ProfileService {
  final ApiClient apiClient = ApiClient();

  Future<UserModel> getProfile() async {
    try {
      final response = await apiClient.dio.get('/users/profile');

      return UserModel.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception(
        e.response?.data['message'] ?? 'Failed to load profile',
      );
    }
  }

  Future<UserModel> updateProfile({
    String? fullName,
    String? phone,
    String? address,
    String? profileImage,
  }) async {
    try {
      final response = await apiClient.dio.patch(
        '/users/profile',
        data: {
          'fullName': fullName,
          'phone': phone,
          'address': address,
          'profileImage': profileImage,
        },
      );

      return UserModel.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception(
        e.response?.data['message'] ?? 'Failed to update profile',
      );
    }
  }
}