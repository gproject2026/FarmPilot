import 'package:flutter/material.dart';

import '../models/user_model.dart';
import '../services/user_service.dart';

class UserProvider extends ChangeNotifier {
  final UserService userService = UserService();

  bool isLoading = false;

  String? errorMessage;

  List<UserModel> users = [];

  Future<void> loadAllUsers() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      users = await userService.getAllUsers();
    } catch (e) {
      errorMessage = e
          .toString()
          .replaceFirst(
            'Exception: ',
            '',
          );
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<UserModel?> loadUserById(
    String userId,
  ) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      return await userService.getUserById(
        userId,
      );
    } catch (e) {
      errorMessage = e
          .toString()
          .replaceFirst(
            'Exception: ',
            '',
          );

      return null;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateUserStatus({
    required String userId,
    required bool isActive,
  }) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final updatedUser =
          await userService.updateUserStatus(
        userId: userId,
        isActive: isActive,
      );

      final userIndex =
          users.indexWhere(
        (user) => user.id == userId,
      );

      if (userIndex != -1) {
        users[userIndex] = updatedUser;
      }

      return true;
    } catch (e) {
      errorMessage = e
          .toString()
          .replaceFirst(
            'Exception: ',
            '',
          );

      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  void clearError() {
    errorMessage = null;
    notifyListeners();
  }
}