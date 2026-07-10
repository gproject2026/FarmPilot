import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../farmer/farmer_dashboard_screen.dart';



class LoginScreen extends StatefulWidget {

  const LoginScreen({super.key});


  @override
  State<LoginScreen> createState() =>
      _LoginScreenState();

}



class _LoginScreenState extends State<LoginScreen> {


  final emailController = TextEditingController();

  final passwordController = TextEditingController();




  @override
  Widget build(BuildContext context) {


    final authProvider =
        Provider.of<AuthProvider>(context);



    return Scaffold(


      appBar: AppBar(

        title: const Text(
          "FarmPilot Login",
        ),

      ),




      body: Padding(


        padding: const EdgeInsets.all(20),



        child: Column(


          mainAxisAlignment:
              MainAxisAlignment.center,



          children: [




            TextField(


              controller: emailController,


              decoration: const InputDecoration(


                labelText: "Email",


                border: OutlineInputBorder(),


              ),


            ),





            const SizedBox(height: 20),






            TextField(


              controller: passwordController,


              obscureText: true,



              decoration: const InputDecoration(


                labelText: "Password",


                border: OutlineInputBorder(),


              ),


            ),





            const SizedBox(height: 30),






            SizedBox(


              width: double.infinity,



              child: ElevatedButton(



                onPressed: authProvider.isLoading

                    ? null

                    : () async {



                        try {



                          await authProvider.login(


                            emailController.text.trim(),


                            passwordController.text.trim(),


                          );





                          if (authProvider.userRole == "FARMER") {



                            Navigator.pushReplacement(



                              context,



                              MaterialPageRoute(



                                builder: (_) =>

                                    const FarmerDashboardScreen(),



                              ),



                            );



                          }







                          else {



                            ScaffoldMessenger.of(context)

                                .showSnackBar(



                              SnackBar(



                                content: Text(

                                  "Role ${authProvider.userRole}",

                                ),



                              ),



                            );



                          }







                        } catch (e) {



                          ScaffoldMessenger.of(context)

                              .showSnackBar(



                            SnackBar(



                              content: Text(

                                e.toString(),

                              ),



                            ),



                          );



                        }




                      },





                child: authProvider.isLoading


                    ? const CircularProgressIndicator()



                    : const Text(

                        "Login",

                      ),




              ),



            )




          ],



        ),



      ),



    );


  }


}