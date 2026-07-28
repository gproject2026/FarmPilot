import 'package:flutter/material.dart';

import '../services/dashboard_service.dart';

class DashboardProvider
    extends ChangeNotifier {
  final DashboardService dashboardService =
      DashboardService();

  bool isLoading = false;

  Map<String, dynamic>? dashboardData;

  String? errorMessage;

  Future<void>
      loadFarmerDashboard() async {
    isLoading = true;
    errorMessage = null;

    notifyListeners();

    try {
      dashboardData =
          await dashboardService
              .getFarmerDashboard();
    } catch (e) {
      dashboardData = null;

      errorMessage = e
          .toString()
          .replaceFirst(
            'Exception: ',
            '',
          );

      rethrow;
    } finally {
      isLoading = false;

      notifyListeners();
    }
  }

  Future<void>
      loadAdminDashboard() async {
    isLoading = true;
    errorMessage = null;

    notifyListeners();

    try {
      dashboardData =
          await dashboardService
              .getAdminDashboard();
    } catch (e) {
      dashboardData = null;

      errorMessage = e
          .toString()
          .replaceFirst(
            'Exception: ',
            '',
          );

      rethrow;
    } finally {
      isLoading = false;

      notifyListeners();
    }
  }

  void clearDashboard() {
    dashboardData = null;
    errorMessage = null;
    isLoading = false;

    notifyListeners();
  }
}