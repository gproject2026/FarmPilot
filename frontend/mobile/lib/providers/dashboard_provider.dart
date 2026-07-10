import 'package:flutter/material.dart';

import '../services/dashboard_service.dart';



class DashboardProvider extends ChangeNotifier {


  final DashboardService dashboardService =
      DashboardService();



  bool isLoading = false;



  Map<String, dynamic>? dashboardData;




  Future<void> loadFarmerDashboard() async {


    isLoading = true;

    notifyListeners();



    try {


      dashboardData =
          await dashboardService.getFarmerDashboard();



    } finally {


      isLoading = false;

      notifyListeners();


    }


  }



}