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


      final response =
          await apiClient.dio.post(

        '/auth/login',

        data: {

          "email": email,

          "password": password,

        },

      );



      final data = response.data;



      final token =
          data['accessToken'];



      await TokenStorage.saveToken(token);



      return data;



    } on DioException catch (e) {


      throw Exception(

        e.response?.data['message'] ??
        "Login failed",

      );


    } catch (e) {


      throw Exception(

        "Login failed: $e",

      );


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


    try {


      await apiClient.dio.post(

        '/auth/register',

        data: {


          "fullName": fullName,

          "email": email,

          "password": password,

          "phone": phone,

          "role": role,

          "address": address,


        },

      );



    } on DioException catch (e) {


      throw Exception(

        e.response?.data['message'] ??
        "Register failed",

      );


    }


  }


}