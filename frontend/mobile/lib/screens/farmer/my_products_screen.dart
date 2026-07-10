import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/product_provider.dart';



class MyProductsScreen extends StatefulWidget {


  const MyProductsScreen({super.key});



  @override
  State<MyProductsScreen> createState() =>
      _MyProductsScreenState();


}





class _MyProductsScreenState
    extends State<MyProductsScreen> {



  @override
  void initState() {

    super.initState();


    Future.microtask(() {


      Provider.of<ProductProvider>(
        context,
        listen: false,
      ).loadMyProducts();


    });


  }






  @override
  Widget build(BuildContext context) {



    final productProvider =
        Provider.of<ProductProvider>(context);



    return Scaffold(



      appBar: AppBar(

        title: const Text(
          "My Products",
        ),

      ),





      body: productProvider.isLoading



          ? const Center(

              child: CircularProgressIndicator(),

            )



          : productProvider.products.isEmpty



              ? const Center(

                  child: Text(
                    "No Products Found",
                  ),

                )



              : ListView.builder(



                  padding: const EdgeInsets.all(20),



                  itemCount:
                      productProvider.products.length,



                  itemBuilder: (context, index) {



                    final product =
                        productProvider.products[index];



                    return Card(



                      child: ListTile(



                        title: Text(

                          product['name'],

                          style: const TextStyle(

                            fontWeight: FontWeight.bold,

                          ),

                        ),



                        subtitle: Column(


                          crossAxisAlignment:
                              CrossAxisAlignment.start,


                          children: [



                            Text(

                              "Price: ${product['price']}",

                            ),



                            Text(

                              "Quantity: ${product['quantity']} ${product['unit']}",

                            ),



                            Text(

                              "Status: ${product['status']}",

                            ),



                          ],


                        ),




                      ),



                    );



                  },


                ),


    );


  }


}