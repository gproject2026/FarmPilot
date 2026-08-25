import 'package:dio/dio.dart';

import '../core/api/api_client.dart';
import '../core/storage/token_storage.dart';

class AuthService {
  final ApiClient apiClient = ApiClient();

  Future<Map<String, dynamic>> login(
    String email,
    String password,
  ) async {
    try {
      final response = await apiClient.dio.post(
        '/auth/login',
        data: {
          'email': email.trim(),
          'password': password,
        },
      );

      final data = Map<String, dynamic>.from(
        response.data,
      );

      final accessToken =
          data['accessToken']?.toString();

      if (accessToken == null ||
          accessToken.isEmpty) {
        throw Exception(
          'Access token was not returned',
        );
      }

      await TokenStorage.saveToken(
        accessToken,
      );

      return data;
    } on DioException catch (e) {
      throw Exception(
        _readErrorMessage(
          e,
          'Login failed',
        ),
      );
    } catch (e) {
      throw Exception(
        e.toString().replaceFirst(
              'Exception: ',
              '',
            ),
      );
    }
  }

  Future<void> register({
    required String fullName,
    required String email,
    required String password,
    required String phone,
    required String role,
    required String address,
  }) async {
    try {
      await apiClient.dio.post(
        '/auth/register',
        data: {
          'fullName': fullName.trim(),
          'email': email.trim(),
          'password': password,
          'phone': phone.trim(),
          'role': role,
          'address': address.trim(),
        },
      );
    } on DioException catch (e) {
      throw Exception(
        _readErrorMessage(
          e,
          'Register failed',
        ),
      );
    }
  }

  Future<Map<String, dynamic>>
      forgotPassword({
    required String email,
  }) async {
    try {
      final response = await apiClient.dio.post(
        '/auth/forgot-password',
        data: {
          'email': email.trim(),
        },
      );

      if (response.data is! Map) {
        throw Exception(
          'Invalid forgot password response',
        );
      }

      return Map<String, dynamic>.from(
        response.data,
      );
    } on DioException catch (e) {
      throw Exception(
        _readErrorMessage(
          e,
          'Failed to request password reset',
        ),
      );
    } catch (e) {
      throw Exception(
        e.toString().replaceFirst(
              'Exception: ',
              '',
            ),
      );
    }
  }

  Future<Map<String, dynamic>>
      resetPassword({
    required String token,
    required String password,
  }) async {
    try {
      final response = await apiClient.dio.post(
        '/auth/reset-password',
        data: {
          'token': token.trim(),
          'password': password,
        },
      );

      if (response.data is! Map) {
        throw Exception(
          'Invalid reset password response',
        );
      }

      return Map<String, dynamic>.from(
        response.data,
      );
    } on DioException catch (e) {
      throw Exception(
        _readErrorMessage(
          e,
          'Failed to reset password',
        ),
      );
    } catch (e) {
      throw Exception(
        e.toString().replaceFirst(
              'Exception: ',
              '',
            ),
      );
    }
  }

  String _readErrorMessage(
    DioException error,
    String fallbackMessage,
  ) {
    final responseData = error.response?.data;

    if (responseData is Map) {
      final message = responseData['message'];

      if (message is String &&
          message.isNotEmpty) {
        return message;
      }

      if (message is List) {
        return message.join(', ');
      }
    }

    return fallbackMessage;
  }
}