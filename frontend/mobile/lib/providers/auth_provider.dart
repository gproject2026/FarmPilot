import 'package:flutter/material.dart';

import '../services/auth_service.dart';


class AuthProvider extends ChangeNotifier {


  final AuthService authService = AuthService();



  bool isLoading = false;

  bool isLoggedIn = false;


  String? userRole;


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



      print("LOGIN RESPONSE:");

      print(response);




      isLoggedIn = true;



      if (response['user'] != null) {


        userData = response['user'];



        userRole =
            response['user']['role'];



        print("USER ROLE:");

        print(userRole);


      }



    } catch (e) {


      print("LOGIN ERROR:");

      print(e);



      rethrow;



    } finally {


      isLoading = false;

      notifyListeners();


    }


  }









  Future<void> register(
    {
      required String fullName,
      required String email,
      required String password,
      required String phone,
      required String role,
      required String address,
    }
  ) async {



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




    } catch(e) {


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


    notifyListeners();


  }



}