import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_constants.dart';
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

  String? _buildImageUrl(dynamic imageUrl) {
    if (imageUrl == null) {
      return null;
    }

    final value = imageUrl.toString().trim();

    if (value.isEmpty) {
      return null;
    }

    if (value.startsWith('http://') ||
        value.startsWith('https://')) {
      return value;
    }

    if (value.startsWith('/')) {
      return '${AppConstants.baseUrl}$value';
    }

    return '${AppConstants.baseUrl}/$value';
  }

  Future<void> _deleteProduct({
    required String productId,
    required String productName,
  }) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Delete Product'),
          content: Text(
            'Are you sure you want to delete "$productName"?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, false);
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(dialogContext, true);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (shouldDelete != true || !mounted) {
      return;
    }

    try {
      await Provider.of<ProductProvider>(
        context,
        listen: false,
      ).deleteProduct(productId);

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Product deleted successfully',
          ),
        ),
      );
    } catch (e) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Failed to delete product: $e',
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _openEditProduct(
    Map<String, dynamic> product,
  ) async {
    final updated = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => AddProductScreen(
          product: product,
        ),
      ),
    );

    if (updated != true || !mounted) {
      return;
    }

    await Provider.of<ProductProvider>(
      context,
      listen: false,
    ).loadMyProducts();

    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Product updated successfully',
        ),
      ),
    );
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
          final added = await Navigator.push<bool>(
            context,
            MaterialPageRoute(
              builder: (_) => const AddProductScreen(),
            ),
          );

          if (!context.mounted) {
            return;
          }

          if (added == true) {
            await Provider.of<ProductProvider>(
              context,
              listen: false,
            ).loadMyProducts();
          }
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
                  onRefresh:
                      productProvider.loadMyProducts,
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
                      final rawProduct =
                          productProvider.products[index];

                      final product =
                          Map<String, dynamic>.from(
                        rawProduct,
                      );

                      final productId =
                          product['id']?.toString() ?? '';

                      final productName =
                          product['name']?.toString() ??
                              'Unnamed Product';

                      final imageUrl = _buildImageUrl(
                        product['imageUrl'],
                      );

                      return Card(
                        margin: const EdgeInsets.only(
                          bottom: 12,
                        ),
                        child: Padding(
                          padding:
                              const EdgeInsets.all(12),
                          child: Row(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: 90,
                                height: 90,
                                padding:
                                    const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color:
                                      Colors.grey.shade100,
                                  borderRadius:
                                      BorderRadius.circular(
                                    10,
                                  ),
                                  border: Border.all(
                                    color:
                                        Colors.grey.shade300,
                                  ),
                                ),
                                child: ClipRRect(
                                  borderRadius:
                                      BorderRadius.circular(
                                    7,
                                  ),
                                  child: imageUrl == null
                                      ? const Center(
                                          child: Icon(
                                            Icons
                                                .inventory_2_outlined,
                                            size: 36,
                                          ),
                                        )
                                      : Image.network(
                                          imageUrl,
                                          fit: BoxFit.contain,
                                          errorBuilder: (
                                            context,
                                            error,
                                            stackTrace,
                                          ) {
                                            return const Center(
                                              child: Icon(
                                                Icons
                                                    .broken_image_outlined,
                                                size: 36,
                                              ),
                                            );
                                          },
                                        ),
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment
                                          .start,
                                  children: [
                                    Text(
                                      productName,
                                      style:
                                          const TextStyle(
                                        fontWeight:
                                            FontWeight.bold,
                                        fontSize: 17,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Price: ${product['price']}',
                                    ),
                                    Text(
                                      'Quantity: ${product['quantity']} ${product['unit']}',
                                    ),
                                    Text(
                                      'Status: ${product['status']}',
                                    ),
                                    if (product['category'] !=
                                        null)
                                      Text(
                                        'Category: ${product['category']['name']}',
                                      ),
                                  ],
                                ),
                              ),
                              Column(
                                children: [
                                  IconButton(
                                    tooltip:
                                        'Edit Product',
                                    icon: const Icon(
                                      Icons.edit_outlined,
                                      color: Colors.blue,
                                    ),
                                    onPressed: () {
                                      _openEditProduct(
                                        product,
                                      );
                                    },
                                  ),
                                  IconButton(
                                    tooltip:
                                        'Delete Product',
                                    icon: const Icon(
                                      Icons.delete_outline,
                                      color: Colors.red,
                                    ),
                                    onPressed:
                                        productId.isEmpty
                                            ? null
                                            : () {
                                                _deleteProduct(
                                                  productId:
                                                      productId,
                                                  productName:
                                                      productName,
                                                );
                                              },
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}