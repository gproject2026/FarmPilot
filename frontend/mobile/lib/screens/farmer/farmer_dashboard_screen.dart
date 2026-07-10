import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/dashboard_provider.dart';
import 'my_products_screen.dart';



class FarmerDashboardScreen extends StatefulWidget {


  const FarmerDashboardScreen({super.key});



  @override
  State<FarmerDashboardScreen> createState() =>
      _FarmerDashboardScreenState();


}





class _FarmerDashboardScreenState
    extends State<FarmerDashboardScreen> {



  @override
  void initState() {

    super.initState();


    Future.microtask(() {

      Provider.of<DashboardProvider>(
        context,
        listen: false,
      ).loadFarmerDashboard();


    });


  }






  @override
  Widget build(BuildContext context) {



    final dashboardProvider =
        Provider.of<DashboardProvider>(context);



    return Scaffold(



      appBar: AppBar(

        title: const Text(
          "Farmer Dashboard",
        ),

      ),





      body: dashboardProvider.isLoading


          ? const Center(

              child: CircularProgressIndicator(),

            )



          : dashboardProvider.dashboardData == null


              ? const Center(

                  child: Text(
                    "No Data",
                  ),

                )



              : Padding(

                  padding: const EdgeInsets.all(20),



                  child: Column(


                    children: [



                      const Text(

                        "Welcome Farmer 🌱",

                        style: TextStyle(

                          fontSize: 28,

                          fontWeight: FontWeight.bold,

                        ),

                      ),



                      const SizedBox(height: 30),




                      // My Products Button

                      SizedBox(

                        width: double.infinity,


                        child: ElevatedButton(


                          onPressed: () {


                            Navigator.push(


                              context,


                              MaterialPageRoute(


                                builder: (_) =>
                                    const MyProductsScreen(),


                              ),


                            );


                          },


                          child: const Text(

                            "My Products",

                          ),


                        ),


                      ),





                      const SizedBox(height: 20),






                      dashboardCard(

                        "Products",

                        dashboardProvider.dashboardData!['productsCount']

                            .toString(),

                      ),





                      dashboardCard(

                        "Crops",

                        dashboardProvider.dashboardData!['cropsCount']

                            .toString(),

                      ),





                      dashboardCard(

                        "AI Diagnoses",

                        dashboardProvider.dashboardData!['diagnosesCount']

                            .toString(),

                      ),





                      dashboardCard(

                        "Orders",

                        dashboardProvider.dashboardData!['ordersCount']

                            .toString(),

                      ),





                      dashboardCard(

                        "Total Sales",

                        dashboardProvider.dashboardData!['totalSales']

                            .toString(),

                      ),




                    ],


                  ),


                ),


    );


  }






  Widget dashboardCard(
    String title,
    String value,
  ) {



    return Card(


      child: ListTile(


        title: Text(

          title,

          style: const TextStyle(

            fontSize: 18,

          ),

        ),



        trailing: Text(

          value,

          style: const TextStyle(

            fontSize: 22,

            fontWeight: FontWeight.bold,

          ),

        ),


      ),


    );


  }



}