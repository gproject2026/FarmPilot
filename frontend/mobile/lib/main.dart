import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'providers/auth_provider.dart';
import 'providers/dashboard_provider.dart';
import 'providers/product_provider.dart';

import 'screens/auth/login_screen.dart';
import 'providers/category_provider.dart';



void main() {

  runApp(
    const FarmPilotApp(),
  );

}





class FarmPilotApp extends StatelessWidget {


  const FarmPilotApp({super.key});



  @override
  Widget build(BuildContext context) {



    return MultiProvider(


      providers: [



        ChangeNotifierProvider(

          create: (_) => AuthProvider(),

        ),
        ChangeNotifierProvider(
  create: (_) => CategoryProvider(),
),


        ChangeNotifierProvider(
  create: (_) => ProductProvider(),
),




        ChangeNotifierProvider(

          create: (_) => DashboardProvider(),

        ),



      ],





      child: MaterialApp(


        debugShowCheckedModeBanner: false,


        title: 'FarmPilot',



        theme: ThemeData(

          primarySwatch: Colors.green,

        ),




        home: const LoginScreen(),



      ),



    );


  }


}