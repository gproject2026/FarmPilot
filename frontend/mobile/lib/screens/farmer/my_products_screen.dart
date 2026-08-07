import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_constants.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../providers/product_provider.dart';
import 'add_product_screen.dart';

class MyProductsScreen extends StatefulWidget {
  const MyProductsScreen({
    super.key,
  });

  @override
  State<MyProductsScreen> createState() =>
      _MyProductsScreenState();
}

class _MyProductsScreenState
    extends State<MyProductsScreen> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback(
      (_) {
        if (!mounted) {
          return;
        }

        Provider.of<ProductProvider>(
          context,
          listen: false,
        ).loadMyProducts();
      },
    );
  }

  String? _getImageUrl(
    dynamic imageUrl,
  ) {
    if (imageUrl == null) {
      return null;
    }

    final url =
        AppConstants.getImageUrl(
      imageUrl.toString(),
    );

    if (url.isEmpty) {
      return null;
    }

    return url;
  }

  String _translateProductStatus(
    String status,
    AppLocalizations l10n,
  ) {
    switch (
      status.trim().toUpperCase()
    ) {
      case 'AVAILABLE':
        return l10n.available;

      case 'OUT_OF_STOCK':
        return l10n.outOfStock;

      case 'HIDDEN':
        return l10n.hidden;

      default:
        return status;
    }
  }

  Future<void> _deleteProduct({
    required String productId,
    required String productName,
  }) async {
    final l10n =
        AppLocalizations.of(context)!;

    final productProvider =
        Provider.of<ProductProvider>(
      context,
      listen: false,
    );

    final shouldDelete =
        await showDialog<bool>(
      context: context,
      builder: (
        dialogContext,
      ) {
        return AlertDialog(
          title: Text(
            l10n.deleteProduct,
          ),
          content: Text(
            l10n.deleteProductConfirmation(
              productName,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(
                  dialogContext,
                  false,
                );
              },
              child: Text(
                l10n.cancel,
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(
                  dialogContext,
                  true,
                );
              },
              style:
                  ElevatedButton.styleFrom(
                backgroundColor:
                    Colors.red,
                foregroundColor:
                    Colors.white,
              ),
              child: Text(
                l10n.delete,
              ),
            ),
          ],
        );
      },
    );

    if (shouldDelete != true ||
        !mounted) {
      return;
    }

    try {
      await productProvider
          .deleteProduct(
        productId,
      );

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text(
            l10n
                .productDeletedSuccessfully,
          ),
        ),
      );
    } catch (e) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text(
            l10n.failedToDeleteProduct(
              e.toString(),
            ),
          ),
          backgroundColor:
              Colors.red,
        ),
      );
    }
  }

  Future<void> _openEditProduct(
    Map<String, dynamic> product,
  ) async {
    final productProvider =
        Provider.of<ProductProvider>(
      context,
      listen: false,
    );

    final updated =
        await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) =>
            AddProductScreen(
          product: product,
        ),
      ),
    );

    if (updated != true ||
        !mounted) {
      return;
    }

    await productProvider
        .loadMyProducts();

    if (!mounted) {
      return;
    }

    final l10n =
        AppLocalizations.of(context)!;

    ScaffoldMessenger.of(context)
        .showSnackBar(
      SnackBar(
        content: Text(
          l10n
              .productUpdatedSuccessfully,
        ),
      ),
    );
  }

  Future<void> _openAddProduct() async {
    final productProvider =
        Provider.of<ProductProvider>(
      context,
      listen: false,
    );

    final added =
        await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) =>
            const AddProductScreen(),
      ),
    );

    if (!mounted) {
      return;
    }

    if (added == true) {
      await productProvider
          .loadMyProducts();
    }
  }

  @override
  Widget build(
    BuildContext context,
  ) {
    final productProvider =
        Provider.of<ProductProvider>(
      context,
    );

    final l10n =
        AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          l10n.myProducts,
        ),
      ),
      floatingActionButton:
          FloatingActionButton.extended(
        onPressed:
            productProvider.isLoading
                ? null
                : _openAddProduct,
        icon: const Icon(
          Icons.add,
        ),
        label: Text(
          l10n.addProduct,
        ),
      ),
      body:
          productProvider.isLoading
              ? const Center(
                  child:
                      CircularProgressIndicator(),
                )
              : productProvider
                      .products.isEmpty
                  ? Center(
                      child: Text(
                        l10n
                            .noProductsFound,
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh:
                          productProvider
                              .loadMyProducts,
                      child:
                          ListView.builder(
                        physics:
                            const AlwaysScrollableScrollPhysics(),
                        padding:
                            const EdgeInsets.fromLTRB(
                          20,
                          20,
                          20,
                          100,
                        ),
                        itemCount:
                            productProvider
                                .products.length,
                        itemBuilder: (
                          context,
                          index,
                        ) {
                          final rawProduct =
                              productProvider
                                      .products[
                                  index];

                          final product =
                              Map<String,
                                  dynamic>.from(
                            rawProduct,
                          );

                          final productId =
                              product['id']
                                      ?.toString() ??
                                  '';

                          final productName =
                              product['name']
                                      ?.toString() ??
                                  l10n
                                      .unnamedProduct;

                          final imageUrl =
                              _getImageUrl(
                            product[
                                'imageUrl'],
                          );

                          final category =
                              product[
                                  'category'];

                          final categoryName =
                              category is Map
                                  ? category[
                                              'name']
                                          ?.toString() ??
                                      ''
                                  : '';

                          final translatedStatus =
                              _translateProductStatus(
                            product['status']
                                    ?.toString() ??
                                '',
                            l10n,
                          );

                          return Card(
                            margin:
                                const EdgeInsets.only(
                              bottom: 12,
                            ),
                            child: Padding(
                              padding:
                                  const EdgeInsets.all(
                                12,
                              ),
                              child: Row(
                                crossAxisAlignment:
                                    CrossAxisAlignment
                                        .start,
                                children: [
                                  Container(
                                    width: 90,
                                    height: 90,
                                    padding:
                                        const EdgeInsets.all(
                                      4,
                                    ),
                                    decoration:
                                        BoxDecoration(
                                      color: Colors
                                          .grey
                                          .shade100,
                                      borderRadius:
                                          BorderRadius.circular(
                                        10,
                                      ),
                                      border:
                                          Border.all(
                                        color: Colors
                                            .grey
                                            .shade300,
                                      ),
                                    ),
                                    child:
                                        ClipRRect(
                                      borderRadius:
                                          BorderRadius.circular(
                                        7,
                                      ),
                                      child:
                                          imageUrl ==
                                                  null
                                              ? const Center(
                                                  child:
                                                      Icon(
                                                    Icons.inventory_2_outlined,
                                                    size:
                                                        36,
                                                  ),
                                                )
                                              : Image.network(
                                                  imageUrl,
                                                  fit: BoxFit
                                                      .contain,
                                                  errorBuilder:
                                                      (
                                                    context,
                                                    error,
                                                    stackTrace,
                                                  ) {
                                                    return const Center(
                                                      child:
                                                          Icon(
                                                        Icons.broken_image_outlined,
                                                        size:
                                                            36,
                                                      ),
                                                    );
                                                  },
                                                ),
                                    ),
                                  ),
                                  const SizedBox(
                                    width: 14,
                                  ),
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
                                            fontSize:
                                                17,
                                          ),
                                        ),
                                        const SizedBox(
                                          height: 8,
                                        ),
                                        Text(
                                          '${l10n.price}: '
                                          '${product['price'] ?? ''}',
                                        ),
                                        Text(
                                          '${l10n.quantity}: '
                                          '${product['quantity'] ?? ''} '
                                          '${product['unit'] ?? ''}',
                                        ),
                                        Text(
                                          '${l10n.status}: '
                                          '$translatedStatus',
                                        ),
                                        if (categoryName
                                            .trim()
                                            .isNotEmpty)
                                          Text(
                                            '${l10n.category}: '
                                            '$categoryName',
                                          ),
                                      ],
                                    ),
                                  ),
                                  Column(
                                    children: [
                                      IconButton(
                                        tooltip:
                                            l10n.editProduct,
                                        icon:
                                            const Icon(
                                          Icons
                                              .edit_outlined,
                                          color:
                                              Colors.blue,
                                        ),
                                        onPressed:
                                            () {
                                          _openEditProduct(
                                            product,
                                          );
                                        },
                                      ),
                                      IconButton(
                                        tooltip:
                                            l10n.deleteProduct,
                                        icon:
                                            const Icon(
                                          Icons
                                              .delete_outline,
                                          color:
                                              Colors.red,
                                        ),
                                        onPressed:
                                            productId
                                                    .isEmpty
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