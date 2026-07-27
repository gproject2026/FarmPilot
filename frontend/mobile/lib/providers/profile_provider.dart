import 'package:flutter/material.dart';

import '../models/user_model.dart';
import '../services/profile_service.dart';

class ProfileProvider extends ChangeNotifier {
  final ProfileService profileService = ProfileService();

  UserModel? user;

  bool isLoading = false;
  bool isSaving = false;

  String? errorMessage;

  Future<void> loadProfile() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      user = await profileService.getProfile();
    } catch (e) {
      errorMessage = e.toString().replaceFirst('Exception: ', '');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateProfile({
    required String fullName,
    required String phone,
    required String address,
    String? profileImage,
  }) async {
    isSaving = true;
    errorMessage = null;
    notifyListeners();

    try {
      user = await profileService.updateProfile(
        fullName: fullName,
        phone: phone,
        address: address,
        profileImage: profileImage,
      );
    } catch (e) {
      errorMessage = e.toString().replaceFirst('Exception: ', '');
      rethrow;
    } finally {
      isSaving = false;
      notifyListeners();
    }
  }
}