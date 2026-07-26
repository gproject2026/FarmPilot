import 'package:flutter/material.dart';

import '../services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService authService = AuthService();

  bool isLoading = false;
  bool isLoggedIn = false;

  String? userRole;
  String? token;

  Map<String, dynamic>? userData;

  Future<void> login(
    String email,
    String password,
  ) async {
    isLoading = true;
    notifyListeners();

    try {
      final response = await authService.login(
        email,
        password,
      );

      print('LOGIN RESPONSE:');
      print(response);

      token = response['accessToken'];

      if (response['user'] != null) {
        userData = Map<String, dynamic>.from(
          response['user'],
        );

        userRole = response['user']['role'];

        print('USER ROLE:');
        print(userRole);
      }

      isLoggedIn = token != null && token!.isNotEmpty;
    } catch (e) {
      print('LOGIN ERROR:');
      print(e);

      isLoggedIn = false;
      token = null;
      userRole = null;
      userData = null;

      rethrow;
    } finally {
      isLoading = false;
      notifyListeners();
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
    isLoading = true;
    notifyListeners();

    try {
      await authService.register(
        fullName: fullName,
        email: email,
        password: password,
        phone: phone,
        role: role,
        address: address,
      );
    } catch (e) {
      rethrow;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  void logout() {
    isLoggedIn = false;
    userRole = null;
    userData = null;
    token = null;

    notifyListeners();
  }
}