import 'package:flutter/material.dart';

import '../services/product_service.dart';



class ProductProvider extends ChangeNotifier {


  final ProductService productService =
      ProductService();



  bool isLoading = false;


  List<dynamic> products = [];




  Future<void> loadMyProducts() async {


    isLoading = true;

    notifyListeners();



    try {


      products =
          await productService.getMyProducts();



    } finally {


      isLoading = false;

      notifyListeners();


    }


  }



}