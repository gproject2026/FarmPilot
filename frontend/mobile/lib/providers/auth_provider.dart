import 'package:flutter/foundation.dart';

import '../services/auth_service.dart';
import '../services/push_device_service.dart';
import '../services/push_notification_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService authService = AuthService();

  final PushDeviceService _pushDeviceService = PushDeviceService();

  bool isLoading = false;
  bool isLoggedIn = false;

  String? userRole;
  String? token;
  String? errorMessage;

  Map<String, dynamic>? userData;

  Future<void> login(String email, String password) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final response = await authService.login(email, password);

      token = response['accessToken']?.toString();

      if (response['user'] != null) {
        userData = Map<String, dynamic>.from(response['user']);

        userRole = userData?['role']?.toString();
      }

      isLoggedIn = token != null && token!.isNotEmpty;

      // Push notification permission is intentionally NOT requested here.
      // The user enables notifications explicitly from the Profile screen.
    } catch (e) {
      isLoggedIn = false;
      token = null;
      userRole = null;
      userData = null;

      errorMessage = e.toString().replaceFirst('Exception: ', '');

      rethrow;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> registerPushDevice() async {
    try {
      String? fcmToken = PushNotificationService.instance.token;

      fcmToken ??= await PushNotificationService.instance.initialize();

      if (fcmToken == null || fcmToken.isEmpty) {
        return;
      }

      await _pushDeviceService.registerDevice(
        token: fcmToken,
        platform: _getPlatform(),
      );
    } catch (e) {
      if (kDebugMode) {
        print('Failed to register push device: $e');
      }
    }
  }

  String _getPlatform() {
    if (kIsWeb) {
      return 'web';
    }

    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return 'android';

      case TargetPlatform.iOS:
        return 'ios';

      default:
        return 'web';
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
    errorMessage = null;
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
      errorMessage = e.toString().replaceFirst('Exception: ', '');

      rethrow;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<Map<String, dynamic>> forgotPassword({required String email}) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      return await authService.forgotPassword(email: email);
    } catch (e) {
      errorMessage = e.toString().replaceFirst('Exception: ', '');

      rethrow;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> resetPassword({
    required String resetToken,
    required String newPassword,
  }) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      await authService.resetPassword(token: resetToken, password: newPassword);
    } catch (e) {
      errorMessage = e.toString().replaceFirst('Exception: ', '');

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
    errorMessage = null;

    notifyListeners();
  }

  void clearError() {
    errorMessage = null;
    notifyListeners();
  }
}
