import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/product_provider.dart';
import 'add_product_screen.dart';

class MyProductsScreen extends StatefulWidget {
  const MyProductsScreen({super.key});

  @override
  State<MyProductsScreen> createState() =>
      _MyProductsScreenState();
}

class _MyProductsScreenState extends State<MyProductsScreen> {
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
        title: const Text('My Products'),
      ),

      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const AddProductScreen(),
            ),
          );

          if (!context.mounted) return;

          await Provider.of<ProductProvider>(
            context,
            listen: false,
          ).loadMyProducts();
        },
        icon: const Icon(Icons.add),
        label: const Text('Add Product'),
      ),

      body: productProvider.isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : productProvider.products.isEmpty
              ? const Center(
                  child: Text(
                    'No Products Found',
                  ),
                )
              : RefreshIndicator(
                  onRefresh: productProvider.loadMyProducts,
                  child: ListView.builder(
                    padding: const EdgeInsets.fromLTRB(
                      20,
                      20,
                      20,
                      100,
                    ),
                    itemCount:
                        productProvider.products.length,
                    itemBuilder: (context, index) {
                      final product =
                          productProvider.products[index];

                      return Card(
                        margin: const EdgeInsets.only(
                          bottom: 12,
                        ),
                        child: ListTile(
                          leading: const CircleAvatar(
                            child: Icon(
                              Icons.inventory_2_outlined,
                            ),
                          ),
                          title: Text(
                            product['name']?.toString() ??
                                'Unnamed Product',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          subtitle: Padding(
                            padding: const EdgeInsets.only(
                              top: 8,
                            ),
                            child: Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Price: ${product['price']}',
                                ),
                                Text(
                                  'Quantity: ${product['quantity']} ${product['unit']}',
                                ),
                                Text(
                                  'Status: ${product['status']}',
                                ),
                                if (product['category'] != null)
                                  Text(
                                    'Category: ${product['category']['name']}',
                                  ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}