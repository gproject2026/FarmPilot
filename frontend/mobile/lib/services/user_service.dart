import '../core/api/api_client.dart';
import '../models/user_model.dart';

class UserService {
  final ApiClient apiClient = ApiClient();

  Future<List<UserModel>> getAllUsers() async {
    try {
      final response = await apiClient.dio.get(
        '/users/admin/all',
      );

      if (response.data is! List) {
        throw Exception(
          'Invalid users response',
        );
      }

      return List<dynamic>.from(
        response.data,
      ).map((user) {
        return UserModel.fromJson(
          Map<String, dynamic>.from(
            user,
          ),
        );
      }).toList();
    } catch (e) {
      throw Exception(
        'Failed to load users: $e',
      );
    }
  }

  Future<UserModel> getUserById(
    String userId,
  ) async {
    try {
      final response = await apiClient.dio.get(
        '/users/admin/$userId',
      );

      if (response.data is! Map) {
        throw Exception(
          'Invalid user response',
        );
      }

      return UserModel.fromJson(
        Map<String, dynamic>.from(
          response.data,
        ),
      );
    } catch (e) {
      throw Exception(
        'Failed to load user: $e',
      );
    }
  }

  Future<UserModel> updateUserStatus({
    required String userId,
    required bool isActive,
  }) async {
    try {
      final response =
          await apiClient.dio.patch(
        '/users/admin/$userId/status',
        data: {
          'isActive': isActive,
        },
      );

      if (response.data is! Map) {
        throw Exception(
          'Invalid updated user response',
        );
      }

      return UserModel.fromJson(
        Map<String, dynamic>.from(
          response.data,
        ),
      );
    } catch (e) {
      throw Exception(
        'Failed to update user status: $e',
      );
    }
  }
}