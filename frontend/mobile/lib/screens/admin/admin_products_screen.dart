import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_constants.dart';
import '../../providers/product_provider.dart';

class AdminProductsScreen extends StatefulWidget {
  const AdminProductsScreen({
    super.key,
  });

  @override
  State<AdminProductsScreen> createState() =>
      _AdminProductsScreenState();
}

class _AdminProductsScreenState
    extends State<AdminProductsScreen> {
  String _selectedStatus = 'ALL';

  final List<String> _statuses = const [
    'ALL',
    'AVAILABLE',
    'OUT_OF_STOCK',
    'HIDDEN',
  ];

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback(
      (_) {
        _loadProducts();
      },
    );
  }

  Future<void> _loadProducts() async {
    await Provider.of<ProductProvider>(
      context,
      listen: false,
    ).loadAdminProducts();
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

  List<dynamic> _filteredProducts(
    List<dynamic> products,
  ) {
    if (_selectedStatus == 'ALL') {
      return products;
    }

    return products.where(
      (rawProduct) {
        if (rawProduct is! Map) {
          return false;
        }

        final status =
            rawProduct['status']
                    ?.toString()
                    .toUpperCase() ??
                '';

        return status ==
            _selectedStatus;
      },
    ).toList();
  }

  Future<void> _changeStatus({
    required String productId,
    required String productName,
    required String currentStatus,
  }) async {
    String selectedStatus =
        currentStatus;

    final newStatus =
        await showDialog<String>(
      context: context,
      builder: (
        dialogContext,
      ) {
        return StatefulBuilder(
          builder: (
            context,
            setDialogState,
          ) {
            return AlertDialog(
              title: const Text(
                'Change Product Status',
              ),
              content: Column(
                mainAxisSize:
                    MainAxisSize.min,
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Text(
                    productName,
                    style:
                        const TextStyle(
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),
                  const SizedBox(
                    height: 16,
                  ),
                  DropdownButtonFormField<
                      String>(
                    initialValue:
                        selectedStatus,
                    decoration:
                        const InputDecoration(
                      labelText: 'Status',
                      border:
                          OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: 'AVAILABLE',
                        child: Text(
                          'Available',
                        ),
                      ),
                      DropdownMenuItem(
                        value:
                            'OUT_OF_STOCK',
                        child: Text(
                          'Out of Stock',
                        ),
                      ),
                      DropdownMenuItem(
                        value: 'HIDDEN',
                        child: Text(
                          'Hidden',
                        ),
                      ),
                    ],
                    onChanged: (
                      value,
                    ) {
                      if (value == null) {
                        return;
                      }

                      setDialogState(
                        () {
                          selectedStatus =
                              value;
                        },
                      );
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(
                      dialogContext,
                    );
                  },
                  child: const Text(
                    'Cancel',
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(
                      dialogContext,
                      selectedStatus,
                    );
                  },
                  style:
                      ElevatedButton.styleFrom(
                    backgroundColor:
                        Colors.green,
                    foregroundColor:
                        Colors.white,
                  ),
                  child: const Text(
                    'Save',
                  ),
                ),
              ],
            );
          },
        );
      },
    );

    if (newStatus == null ||
        newStatus == currentStatus ||
        !mounted) {
      return;
    }

    final productProvider =
        Provider.of<ProductProvider>(
      context,
      listen: false,
    );

    final success =
        await productProvider
            .updateAdminProductStatus(
      productId: productId,
      status: newStatus,
    );

    if (!mounted) {
      return;
    }

    if (success) {
      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text(
            newStatus == 'HIDDEN'
                ? 'Product hidden successfully'
                : newStatus ==
                        'AVAILABLE'
                    ? 'Product is now available'
                    : 'Product marked as out of stock',
          ),
        ),
      );

      return;
    }

    ScaffoldMessenger.of(context)
        .showSnackBar(
      SnackBar(
        content: Text(
          productProvider.errorMessage ??
              'Failed to update product status',
        ),
        backgroundColor: Colors.red,
      ),
    );
  }

  Color _statusColor(
    String status,
  ) {
    switch (status) {
      case 'AVAILABLE':
        return Colors.green;
      case 'OUT_OF_STOCK':
        return Colors.orange;
      case 'HIDDEN':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _statusLabel(
    String status,
  ) {
    switch (status) {
      case 'AVAILABLE':
        return 'AVAILABLE';
      case 'OUT_OF_STOCK':
        return 'OUT OF STOCK';
      case 'HIDDEN':
        return 'HIDDEN';
      default:
        return status;
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

    final filteredProducts =
        _filteredProducts(
      productProvider.adminProducts,
    );

    return Scaffold(
      backgroundColor:
          const Color(
        0xFFF5F7F4,
      ),
      appBar: AppBar(
        title: const Text(
          'Manage Products',
        ),
        backgroundColor:
            Colors.green,
        foregroundColor:
            Colors.white,
        actions: [
          IconButton(
            tooltip: 'Refresh',
            onPressed:
                productProvider.isLoading
                    ? null
                    : _loadProducts,
            icon: const Icon(
              Icons.refresh,
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            color: Colors.white,
            padding:
                const EdgeInsets.fromLTRB(
              16,
              14,
              16,
              14,
            ),
            child: SingleChildScrollView(
              scrollDirection:
                  Axis.horizontal,
              child: Row(
                children:
                    _statuses.map(
                  (status) {
                    final selected =
                        _selectedStatus ==
                            status;

                    return Padding(
                      padding:
                          const EdgeInsets.only(
                        right: 8,
                      ),
                      child: ChoiceChip(
                        label: Text(
                          status ==
                                  'OUT_OF_STOCK'
                              ? 'OUT OF STOCK'
                              : status,
                        ),
                        selected:
                            selected,
                        onSelected: (_) {
                          setState(
                            () {
                              _selectedStatus =
                                  status;
                            },
                          );
                        },
                        selectedColor:
                            Colors.green
                                .shade100,
                        labelStyle:
                            TextStyle(
                          color: selected
                              ? Colors.green
                                  .shade800
                              : Colors.black87,
                          fontWeight:
                              selected
                                  ? FontWeight
                                      .bold
                                  : FontWeight
                                      .normal,
                        ),
                      ),
                    );
                  },
                ).toList(),
              ),
            ),
          ),
          Expanded(
            child:
                productProvider.isLoading &&
                        productProvider
                            .adminProducts
                            .isEmpty
                    ? const Center(
                        child:
                            CircularProgressIndicator(),
                      )
                    : productProvider
                                .errorMessage !=
                            null &&
                        productProvider
                            .adminProducts
                            .isEmpty
                    ? _buildError(
                        productProvider,
                      )
                    : filteredProducts
                            .isEmpty
                        ? _buildEmpty()
                        : RefreshIndicator(
                            onRefresh:
                                _loadProducts,
                            child:
                                ListView.builder(
                              padding:
                                  const EdgeInsets.all(
                                16,
                              ),
                              itemCount:
                                  filteredProducts
                                      .length,
                              itemBuilder: (
                                context,
                                index,
                              ) {
                                final product =
                                    Map<String,
                                        dynamic>.from(
                                  filteredProducts[
                                      index],
                                );

                                return _buildProductCard(
                                  product,
                                );
                              },
                            ),
                          ),
          ),
        ],
      ),
    );
  }

  Widget _buildError(
    ProductProvider productProvider,
  ) {
    return Center(
      child: Padding(
        padding:
            const EdgeInsets.all(
          24,
        ),
        child: Column(
          mainAxisSize:
              MainAxisSize.min,
          children: [
            const Icon(
              Icons.error_outline,
              size: 55,
              color: Colors.red,
            ),
            const SizedBox(
              height: 12,
            ),
            Text(
              productProvider
                      .errorMessage ??
                  'Failed to load products',
              textAlign:
                  TextAlign.center,
            ),
            const SizedBox(
              height: 16,
            ),
            ElevatedButton.icon(
              onPressed:
                  _loadProducts,
              icon: const Icon(
                Icons.refresh,
              ),
              label: const Text(
                'Try Again',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisSize:
            MainAxisSize.min,
        children: [
          Icon(
            Icons.inventory_2_outlined,
            size: 65,
            color:
                Colors.grey.shade500,
          ),
          const SizedBox(
            height: 12,
          ),
          const Text(
            'No Products Found',
            style: TextStyle(
              fontSize: 17,
              fontWeight:
                  FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductCard(
    Map<String, dynamic> product,
  ) {
    final productId =
        product['id']
                ?.toString() ??
            '';

    final productName =
        product['name']
                ?.toString() ??
            'Unnamed Product';

    final status =
        product['status']
                ?.toString()
                .toUpperCase() ??
            'UNKNOWN';

    final imageUrl =
        _getImageUrl(
      product['imageUrl'],
    );

    final farmer =
        product['farmer'] is Map
            ? Map<String, dynamic>.from(
                product['farmer'],
              )
            : <String, dynamic>{};

    final category =
        product['category'] is Map
            ? Map<String, dynamic>.from(
                product['category'],
              )
            : <String, dynamic>{};

    final farmerName =
        farmer['fullName']
                ?.toString() ??
            'Unknown Farmer';

    final farmerEmail =
        farmer['email']
                ?.toString() ??
            '';

    final categoryName =
        category['name']
                ?.toString() ??
            'No Category';

    return Card(
      margin:
          const EdgeInsets.only(
        bottom: 14,
      ),
      elevation: 2,
      shape:
          RoundedRectangleBorder(
        borderRadius:
            BorderRadius.circular(
          14,
        ),
      ),
      child: Padding(
        padding:
            const EdgeInsets.all(
          14,
        ),
        child: Row(
          crossAxisAlignment:
              CrossAxisAlignment.start,
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
            const SizedBox(
              width: 14,
            ),
            Expanded(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Text(
                    productName,
                    style:
                        const TextStyle(
                      fontSize: 17,
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),
                  const SizedBox(
                    height: 7,
                  ),
                  Wrap(
                    spacing: 8,
                    runSpacing: 6,
                    children: [
                      Container(
                        padding:
                            const EdgeInsets.symmetric(
                          horizontal: 9,
                          vertical: 4,
                        ),
                        decoration:
                            BoxDecoration(
                          color:
                              _statusColor(
                            status,
                          ).withValues(
                            alpha: 0.12,
                          ),
                          borderRadius:
                              BorderRadius.circular(
                            20,
                          ),
                        ),
                        child: Text(
                          _statusLabel(
                            status,
                          ),
                          style:
                              TextStyle(
                            color:
                                _statusColor(
                              status,
                            ),
                            fontSize: 12,
                            fontWeight:
                                FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 8,
                  ),
                  Text(
                    'Price: ${product['price']}',
                  ),
                  Text(
                    'Quantity: ${product['quantity']} ${product['unit'] ?? ''}',
                  ),
                  Text(
                    'Category: $categoryName',
                  ),
                  const SizedBox(
                    height: 7,
                  ),
                  Text(
                    'Farmer: $farmerName',
                    style:
                        const TextStyle(
                      fontWeight:
                          FontWeight.w600,
                    ),
                  ),
                  if (farmerEmail
                      .isNotEmpty)
                    Text(
                      farmerEmail,
                      style:
                          TextStyle(
                        color: Colors
                            .grey.shade700,
                        fontSize: 13,
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(
              width: 6,
            ),
            IconButton(
              tooltip:
                  'Change Status',
              onPressed:
                  productId.isEmpty
                      ? null
                      : () {
                          _changeStatus(
                            productId:
                                productId,
                            productName:
                                productName,
                            currentStatus:
                                status,
                          );
                        },
              icon: const Icon(
                Icons
                    .edit_note_outlined,
                color: Colors.green,
                size: 28,
              ),
            ),
          ],
        ),
      ),
    );
  }
}