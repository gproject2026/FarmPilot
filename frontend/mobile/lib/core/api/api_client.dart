import 'package:dio/dio.dart';

import '../constants/app_constants.dart';
import '../storage/token_storage.dart';



class ApiClient {


  final Dio dio = Dio(


    BaseOptions(

      baseUrl: AppConstants.baseUrl,


      headers: {

        'Content-Type': 'application/json',

      },


    ),


  )



  ..interceptors.add(

    InterceptorsWrapper(


      onRequest: (options, handler) async {


        final token =
            await TokenStorage.getToken();



        if (token != null) {


          options.headers['Authorization'] =
              'Bearer $token';


        }



        return handler.next(options);


      },


    ),


  );


}