import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/cart_model.dart';
import '../../providers/cart_provider.dart';
import '../../providers/favorite_provider.dart';
import 'customer_cart_screen.dart';

class CustomerFavoritesScreen
    extends StatefulWidget {
  const CustomerFavoritesScreen({
    super.key,
  });

  @override
  State<CustomerFavoritesScreen>
      createState() =>
          _CustomerFavoritesScreenState();
}

class _CustomerFavoritesScreenState
    extends State<CustomerFavoritesScreen> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback(
      (_) {
        _loadFavorites();
      },
    );
  }

  Future<void> _loadFavorites() async {
    try {
      await Provider.of<FavoriteProvider>(
        context,
        listen: false,
      ).loadFavorites();
    } catch (e) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(
              e
                  .toString()
                  .replaceFirst(
                    'Exception: ',
                    '',
                  ),
            ),
            backgroundColor: Colors.red,
          ),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final favoriteProvider =
        Provider.of<FavoriteProvider>(context);

    final cartProvider =
        Provider.of<CartProvider>(context);

    return Scaffold(
      backgroundColor:
          const Color(0xFFF5F7F4),
      appBar: AppBar(
        title: const Text(
          'My Favorites',
        ),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        actions: [
          Stack(
            alignment: Alignment.center,
            children: [
              IconButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          const CustomerCartScreen(),
                    ),
                  );
                },
                icon: const Icon(
                  Icons.shopping_cart_outlined,
                ),
              ),
              if (cartProvider.totalQuantity > 0)
                Positioned(
                  top: 6,
                  right: 5,
                  child: Container(
                    padding:
                        const EdgeInsets.all(5),
                    decoration:
                        const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      cartProvider.totalQuantity
                          .toString(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight:
                            FontWeight.bold,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          IconButton(
            onPressed:
                favoriteProvider.isLoading
                    ? null
                    : _loadFavorites,
            icon: const Icon(
              Icons.refresh,
            ),
          ),
        ],
      ),
      body: favoriteProvider.isLoading &&
              favoriteProvider
                  .favorites.isEmpty
          ? const Center(
              child:
                  CircularProgressIndicator(),
            )
          : favoriteProvider.favorites.isEmpty
              ? RefreshIndicator(
                  onRefresh: _loadFavorites,
                  child: ListView(
                    physics:
                        const AlwaysScrollableScrollPhysics(),
                    children: const [
                      SizedBox(
                        height: 180,
                      ),
                      Icon(
                        Icons.favorite_border,
                        size: 80,
                        color: Colors.grey,
                      ),
                      SizedBox(
                        height: 16,
                      ),
                      Center(
                        child: Text(
                          'No favorite products yet',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight:
                                FontWeight.bold,
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 8,
                      ),
                      Center(
                        child: Text(
                          'Add products from the marketplace',
                          style: TextStyle(
                            color: Colors.grey,
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadFavorites,
                  child: GridView.builder(
                    padding:
                        const EdgeInsets.all(16),
                    gridDelegate:
                        const SliverGridDelegateWithMaxCrossAxisExtent(
                      maxCrossAxisExtent: 320,
                      crossAxisSpacing: 14,
                      mainAxisSpacing: 14,
                      childAspectRatio: 0.70,
                    ),
                    itemCount:
                        favoriteProvider
                            .favorites.length,
                    itemBuilder: (
                      context,
                      index,
                    ) {
                      final favorite =
                          Map<String, dynamic>.from(
                        favoriteProvider
                            .favorites[index],
                      );

                      final productData =
                          favorite['product'];

                      if (productData is! Map) {
                        return const SizedBox
                            .shrink();
                      }

                      final product =
                          Map<String, dynamic>.from(
                        productData,
                      );

                      return _FavoriteProductCard(
                        product: product,
                      );
                    },
                  ),
                ),
    );
  }
}

class _FavoriteProductCard
    extends StatelessWidget {
  final Map<String, dynamic> product;

  const _FavoriteProductCard({
    required this.product,
  });

  @override
  Widget build(BuildContext context) {
    final name =
        product['name']?.toString() ??
            'Product';

    final description =
        product['description']?.toString() ??
            '';

    final unit =
        product['unit']?.toString() ?? '';

    final imageUrl =
        product['imageUrl']?.toString();

    final status =
        product['status']?.toString() ?? '';

    final productId =
        product['id']?.toString() ?? '';

    final quantity =
        int.tryParse(
          product['quantity']?.toString() ??
              '0',
        ) ??
        0;

    final price =
        double.tryParse(
          product['price']?.toString() ??
              '0',
        ) ??
        0.0;

    final categoryName =
        product['category'] is Map
            ? product['category']['name']
                    ?.toString() ??
                ''
            : '';

    final farmerName =
        product['farmer'] is Map
            ? product['farmer']['fullName']
                    ?.toString() ??
                ''
            : '';

    final isAvailable =
        productId.isNotEmpty &&
            quantity > 0 &&
            status == 'AVAILABLE';

    return Card(
      elevation: 2,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius:
            BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              SizedBox(
                height: 150,
                width: double.infinity,
                child: Container(
                  color: Colors.green.shade50,
                  child: imageUrl != null &&
                          imageUrl.isNotEmpty
                      ? Image.network(
                          _buildImageUrl(
                            imageUrl,
                          ),
                          fit: BoxFit.cover,
                          errorBuilder: (
                            context,
                            error,
                            stackTrace,
                          ) {
                            return const Icon(
                              Icons
                                  .image_not_supported_outlined,
                              size: 55,
                              color: Colors.grey,
                            );
                          },
                        )
                      : const Icon(
                          Icons.eco_outlined,
                          size: 60,
                          color: Colors.green,
                        ),
                ),
              ),
              Positioned(
                top: 8,
                right: 8,
                child: Material(
                  color: Colors.white,
                  shape: const CircleBorder(),
                  elevation: 2,
                  child: IconButton(
                    tooltip:
                        'Remove from favorites',
                    onPressed: () async {
                      final success =
                          await Provider.of<
                              FavoriteProvider>(
                        context,
                        listen: false,
                      ).removeFavorite(
                        productId,
                      );

                      if (!context.mounted) {
                        return;
                      }

                      final provider =
                          Provider.of<
                              FavoriteProvider>(
                        context,
                        listen: false,
                      );

                      ScaffoldMessenger.of(
                        context,
                      )
                        ..hideCurrentSnackBar()
                        ..showSnackBar(
                          SnackBar(
                            content: Text(
                              success
                                  ? '$name removed from favorites'
                                  : provider.errorMessage ??
                                      'Failed to remove favorite',
                            ),
                            backgroundColor:
                                success
                                    ? Colors.green
                                    : Colors.red,
                          ),
                        );
                    },
                    icon: const Icon(
                      Icons.favorite,
                      color: Colors.red,
                    ),
                  ),
                ),
              ),
            ],
          ),
          Expanded(
            child: Padding(
              padding:
                  const EdgeInsets.fromLTRB(
                12,
                10,
                12,
                12,
              ),
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    maxLines: 1,
                    overflow:
                        TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  if (categoryName.isNotEmpty)
                    Text(
                      categoryName,
                      maxLines: 1,
                      overflow:
                          TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12,
                        color:
                            Colors.green.shade700,
                        fontWeight:
                            FontWeight.w600,
                      ),
                    ),
                  if (description.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Text(
                      description,
                      maxLines: 2,
                      overflow:
                          TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12,
                        color:
                            Colors.grey.shade600,
                      ),
                    ),
                  ],
                  if (farmerName.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Text(
                      'Farmer: $farmerName',
                      maxLines: 1,
                      overflow:
                          TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 11,
                        color:
                            Colors.grey.shade700,
                      ),
                    ),
                  ],
                  const Spacer(),
                  Text(
                    '${price.toStringAsFixed(2)} ₪'
                    '${unit.isEmpty ? '' : ' / $unit'}',
                    style: const TextStyle(
                      color: Colors.green,
                      fontSize: 16,
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    isAvailable
                        ? 'Available: $quantity'
                        : 'Out of stock',
                    style: TextStyle(
                      fontSize: 12,
                      color: isAvailable
                          ? Colors.grey.shade700
                          : Colors.red,
                      fontWeight: isAvailable
                          ? FontWeight.normal
                          : FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: isAvailable
                          ? () {
                              Provider.of<
                                  CartProvider>(
                                context,
                                listen: false,
                              ).addToCart(
                                CartItem(
                                  productId:
                                      productId,
                                  name: name,
                                  price: price,
                                  unit: unit,
                                  quantity: 1,
                                  imageUrl:
                                      imageUrl,
                                ),
                              );

                              ScaffoldMessenger.of(
                                context,
                              )
                                ..hideCurrentSnackBar()
                                ..showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      '$name added to cart',
                                    ),
                                  ),
                                );
                            }
                          : null,
                      icon: const Icon(
                        Icons
                            .add_shopping_cart,
                        size: 18,
                      ),
                      label: const Text(
                        'Add to Cart',
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _buildImageUrl(
    String imageUrl,
  ) {
    if (imageUrl.startsWith('http://') ||
        imageUrl.startsWith('https://')) {
      return imageUrl;
    }

    return 'http://localhost:3000$imageUrl';
  }
}