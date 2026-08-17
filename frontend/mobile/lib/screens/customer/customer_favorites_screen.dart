import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_constants.dart';
import '../../models/cart_model.dart';
import '../../providers/cart_provider.dart';
import '../../providers/favorite_provider.dart';
import 'customer_cart_screen.dart';

const _darkGreen = Color(0xFF173F24);
const _primaryGreen = Color(0xFF2F6B3D);
const _lightGreen = Color(0xFFDDECB8);
const _background = Color(0xFFF8FAF4);
const _textPrimary = Color(0xFF1D2C21);
const _textSecondary = Color(0xFF68756B);

class CustomerFavoritesScreen extends StatefulWidget {
  const CustomerFavoritesScreen({super.key});

  @override
  State<CustomerFavoritesScreen> createState() =>
      _CustomerFavoritesScreenState();
}

class _CustomerFavoritesScreenState
    extends State<CustomerFavoritesScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadFavorites();
    });
  }

  Future<void> _loadFavorites() async {
    try {
      await Provider.of<FavoriteProvider>(
        context,
        listen: false,
      ).loadFavorites();
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(
              e.toString().replaceFirst('Exception: ', ''),
            ),
            backgroundColor: Colors.red,
          ),
        );
    }
  }

  void _openCart() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const CustomerCartScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final favoriteProvider =
        Provider.of<FavoriteProvider>(context);
    final cartProvider =
        Provider.of<CartProvider>(context);

    return Scaffold(
      backgroundColor: _background,
      body: Stack(
        children: [
          const Positioned.fill(
            child: _FavoritesBackdrop(),
          ),
          RefreshIndicator(
            onRefresh: _loadFavorites,
            color: _primaryGreen,
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                SliverToBoxAdapter(
                  child: _buildHeader(
                    favoriteProvider,
                    cartProvider,
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(
                      22,
                      24,
                      22,
                      18,
                    ),
                    child: _buildIntroCard(
                      favoriteProvider,
                    ),
                  ),
                ),
                if (favoriteProvider.isLoading &&
                    favoriteProvider.favorites.isEmpty)
                  const SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(
                      child: CircularProgressIndicator(
                        color: _primaryGreen,
                      ),
                    ),
                  )
                else if (favoriteProvider.favorites.isEmpty)
                  const SliverFillRemaining(
                    hasScrollBody: false,
                    child: _EmptyFavorites(),
                  )
                else
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(
                      22,
                      0,
                      22,
                      40,
                    ),
                    sliver: SliverGrid(
                      gridDelegate:
                          const SliverGridDelegateWithMaxCrossAxisExtent(
                        maxCrossAxisExtent: 340,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                        mainAxisExtent: 455,
                      ),
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final favorite =
                              Map<String, dynamic>.from(
                            favoriteProvider.favorites[index],
                          );

                          final productData = favorite['product'];

                          if (productData is! Map) {
                            return const SizedBox.shrink();
                          }

                          return _FavoriteProductCard(
                            product:
                                Map<String, dynamic>.from(
                              productData,
                            ),
                          );
                        },
                        childCount:
                            favoriteProvider.favorites.length,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(
    FavoriteProvider favoriteProvider,
    CartProvider cartProvider,
  ) {
    return Container(
      padding: const EdgeInsets.fromLTRB(
        20,
        16,
        20,
        18,
      ),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF123A22),
            Color(0xFF205A34),
            Color(0xFF2E6F40),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: _darkGreen.withValues(alpha: 0.18),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: SafeArea(
        bottom: false,
        child: Row(
          children: [
            _HeaderButton(
              icon: Icons.arrow_back_rounded,
              tooltip: 'Back',
              onTap: () => Navigator.pop(context),
            ),
            const SizedBox(width: 12),
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: _lightGreen,
                borderRadius: BorderRadius.circular(13),
              ),
              child: const Icon(
                Icons.eco_rounded,
                color: _darkGreen,
                size: 24,
              ),
            ),
            const SizedBox(width: 10),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'FarmPilot',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 19,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    'My Favorites',
                    style: TextStyle(
                      color: Color(0xCCFFFFFF),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            Stack(
              clipBehavior: Clip.none,
              children: [
                _HeaderButton(
                  icon: Icons.shopping_cart_outlined,
                  tooltip: 'Shopping Cart',
                  onTap: _openCart,
                ),
                if (cartProvider.totalQuantity > 0)
                  Positioned(
                    right: -4,
                    top: -4,
                    child: Container(
                      constraints: const BoxConstraints(
                        minWidth: 18,
                        minHeight: 18,
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 4,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE35D5D),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.white,
                          width: 1.5,
                        ),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        cartProvider.totalQuantity.toString(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 8),
            _HeaderButton(
              icon: Icons.refresh_rounded,
              tooltip: 'Refresh',
              onTap: favoriteProvider.isLoading
                  ? null
                  : _loadFavorites,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIntroCard(
    FavoriteProvider favoriteProvider,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: 24,
        vertical: 22,
      ),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: AlignmentDirectional.centerStart,
          end: AlignmentDirectional.centerEnd,
          colors: [
            Colors.white,
            Color(0xFFFFFEFA),
            Color(0xFFF5F9EE),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: const Color(0xFFDDE7D8),
        ),
        boxShadow: [
          BoxShadow(
            color: _darkGreen.withValues(alpha: 0.045),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              color: const Color(0xFFF8E8EC),
              borderRadius: BorderRadius.circular(17),
            ),
            child: const Icon(
              Icons.favorite_rounded,
              color: Color(0xFFB15B72),
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'My Favorites',
                  style: TextStyle(
                    color: _textPrimary,
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Keep your favorite farm products in one place for quick access.',
                  style: TextStyle(
                    color: _textSecondary,
                    fontSize: 13,
                    height: 1.45,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 13,
              vertical: 9,
            ),
            decoration: BoxDecoration(
              color: const Color(0xFFEAF3DF),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Text(
              '${favoriteProvider.favorites.length} saved',
              style: const TextStyle(
                color: _primaryGreen,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HeaderButton extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback? onTap;

  const _HeaderButton({
    required this.icon,
    required this.tooltip,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: Colors.white.withValues(
          alpha: onTap == null ? 0.05 : 0.10,
        ),
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: SizedBox(
            width: 44,
            height: 44,
            child: Icon(
              icon,
              color:
                  onTap == null ? Colors.white54 : Colors.white,
              size: 21,
            ),
          ),
        ),
      ),
    );
  }
}

class _FavoriteProductCard extends StatelessWidget {
  final Map<String, dynamic> product;

  const _FavoriteProductCard({
    required this.product,
  });

  @override
  Widget build(BuildContext context) {
    final name =
        product['name']?.toString() ?? 'Product';
    final description =
        product['description']?.toString() ?? '';
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
          product['quantity']?.toString() ?? '0',
        ) ??
            0;

    final price =
        double.tryParse(
          product['price']?.toString() ?? '0',
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

    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white,
            Color(0xFFFFFEFA),
          ],
        ),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: const Color(0xFFDDE6D8),
        ),
        boxShadow: [
          BoxShadow(
            color: _darkGreen.withValues(alpha: 0.055),
            blurRadius: 18,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              SizedBox(
                height: 175,
                width: double.infinity,
                child: Container(
                  color: const Color(0xFFF0F5EB),
                  child: imageUrl != null &&
                          imageUrl.isNotEmpty
                      ? Image.network(
                          _buildImageUrl(imageUrl),
                          fit: BoxFit.cover,
                          errorBuilder: (
                            context,
                            error,
                            stackTrace,
                          ) {
                            return const Center(
                              child: Icon(
                                Icons
                                    .image_not_supported_outlined,
                                size: 52,
                                color: Color(0xFF9AA59B),
                              ),
                            );
                          },
                        )
                      : const Center(
                          child: Icon(
                            Icons.eco_outlined,
                            size: 58,
                            color: _primaryGreen,
                          ),
                        ),
                ),
              ),
              if (categoryName.isNotEmpty)
                PositionedDirectional(
                  start: 10,
                  bottom: 10,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(
                        alpha: 0.92,
                      ),
                      borderRadius:
                          BorderRadius.circular(20),
                    ),
                    child: Text(
                      categoryName,
                      style: const TextStyle(
                        color: _primaryGreen,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              PositionedDirectional(
                end: 10,
                top: 10,
                child: Material(
                  color: Colors.white.withValues(
                    alpha: 0.96,
                  ),
                  shape: const CircleBorder(),
                  elevation: 2,
                  child: IconButton(
                    tooltip: 'Remove from favorites',
                    onPressed: productId.isEmpty
                        ? null
                        : () async {
                            final success =
                                await Provider.of<
                                    FavoriteProvider>(
                              context,
                              listen: false,
                            ).removeFavorite(productId);

                            if (!context.mounted) {
                              return;
                            }

                            final provider =
                                Provider.of<
                                    FavoriteProvider>(
                              context,
                              listen: false,
                            );

                            ScaffoldMessenger.of(context)
                              ..hideCurrentSnackBar()
                              ..showSnackBar(
                                SnackBar(
                                  content: Text(
                                    success
                                        ? '$name removed from favorites'
                                        : provider
                                                .errorMessage ??
                                            'Failed to remove favorite',
                                  ),
                                  backgroundColor:
                                      success
                                          ? _primaryGreen
                                          : Colors.red,
                                ),
                              );
                          },
                    icon: const Icon(
                      Icons.favorite_rounded,
                      color: Color(0xFFE65353),
                    ),
                  ),
                ),
              ),
            ],
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                14,
                14,
                14,
                14,
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
                      color: _textPrimary,
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  if (description.isNotEmpty) ...[
                    const SizedBox(height: 7),
                    Text(
                      description,
                      maxLines: 2,
                      overflow:
                          TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: _textSecondary,
                        fontSize: 12,
                        height: 1.4,
                      ),
                    ),
                  ],
                  if (farmerName.isNotEmpty) ...[
                    const SizedBox(height: 7),
                    Row(
                      children: [
                        const Icon(
                          Icons.person_outline_rounded,
                          size: 15,
                          color: Color(0xFF7A867C),
                        ),
                        const SizedBox(width: 5),
                        Expanded(
                          child: Text(
                            'Farmer: $farmerName',
                            maxLines: 1,
                            overflow:
                                TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: _textSecondary,
                              fontSize: 11,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                  const Spacer(),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          '${price.toStringAsFixed(2)} ₪'
                          '${unit.isEmpty ? '' : ' / $unit'}',
                          maxLines: 1,
                          overflow:
                              TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: _primaryGreen,
                            fontSize: 18,
                            fontWeight:
                                FontWeight.w800,
                          ),
                        ),
                      ),
                      Container(
                        padding:
                            const EdgeInsets.symmetric(
                          horizontal: 9,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: isAvailable
                              ? const Color(
                                  0xFFEAF3DF,
                                )
                              : const Color(
                                  0xFFFCE7E7,
                                ),
                          borderRadius:
                              BorderRadius.circular(18),
                        ),
                        child: Text(
                          isAvailable
                              ? 'Available: $quantity'
                              : 'Out of stock',
                          style: TextStyle(
                            color: isAvailable
                                ? _primaryGreen
                                : const Color(
                                    0xFFB44F4F,
                                  ),
                            fontSize: 10,
                            fontWeight:
                                FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    height: 42,
                    child: ElevatedButton.icon(
                      onPressed: isAvailable
                          ? () {
                              Provider.of<CartProvider>(
                                context,
                                listen: false,
                              ).addToCart(
                                CartItem(
                                  productId: productId,
                                  name: name,
                                  price: price,
                                  unit: unit,
                                  quantity: 1,
                                  imageUrl: imageUrl,
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
                                    backgroundColor:
                                        _primaryGreen,
                                  ),
                                );
                            }
                          : null,
                      style:
                          ElevatedButton.styleFrom(
                        backgroundColor:
                            _primaryGreen,
                        foregroundColor:
                            Colors.white,
                        disabledBackgroundColor:
                            const Color(
                          0xFFD6DDD4,
                        ),
                        elevation: 0,
                        shape:
                            RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(
                            14,
                          ),
                        ),
                      ),
                      icon: const Icon(
                        Icons.add_shopping_cart_rounded,
                        size: 18,
                      ),
                      label: const Text(
                        'Add to Cart',
                        style: TextStyle(
                          fontWeight:
                              FontWeight.w700,
                        ),
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

  String _buildImageUrl(String imageUrl) {
    final trimmed = imageUrl.trim();

    if (trimmed.isEmpty) {
      return '';
    }

    if (trimmed.startsWith(
          'http://localhost:3000',
        ) ||
        trimmed.startsWith(
          'http://127.0.0.1:3000',
        )) {
      return trimmed.replaceFirst(
        RegExp(
          r'http://(localhost|127\.0\.0\.1):3000',
        ),
        AppConstants.baseUrl,
      );
    }

    if (trimmed.startsWith('http://') ||
        trimmed.startsWith('https://')) {
      return trimmed;
    }

    final normalized =
        trimmed.startsWith('/')
            ? trimmed
            : '/$trimmed';

    return '${AppConstants.baseUrl}$normalized';
  }
}

class _EmptyFavorites extends StatelessWidget {
  const _EmptyFavorites();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Container(
          constraints:
              const BoxConstraints(maxWidth: 470),
          padding: const EdgeInsets.all(30),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(26),
            border: Border.all(
              color: const Color(0xFFDDE6D8),
            ),
            boxShadow: [
              BoxShadow(
                color:
                    _darkGreen.withValues(alpha: 0.05),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: const Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.favorite_border_rounded,
                size: 72,
                color: Color(0xFFB15B72),
              ),
              SizedBox(height: 16),
              Text(
                'No favorite products yet',
                style: TextStyle(
                  color: _textPrimary,
                  fontSize: 21,
                  fontWeight: FontWeight.w800,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Add products from the marketplace and they will appear here.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: _textSecondary,
                  fontSize: 14,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FavoritesBackdrop extends StatelessWidget {
  const _FavoritesBackdrop();

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Stack(
        fit: StackFit.expand,
        children: [
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFFF8FAF4),
                  Color(0xFFFFFCF5),
                  Color(0xFFF4F8ED),
                ],
                stops: [0.0, 0.50, 1.0],
              ),
            ),
          ),
          PositionedDirectional(
            end: -190,
            top: 210,
            child: Container(
              width: 470,
              height: 470,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFFCFE6B4)
                        .withValues(alpha: 0.28),
                    const Color(0xFFCFE6B4)
                        .withValues(alpha: 0.0),
                  ],
                ),
              ),
            ),
          ),
          PositionedDirectional(
            start: -190,
            bottom: -220,
            child: Container(
              width: 520,
              height: 520,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFFE7DFAF)
                        .withValues(alpha: 0.22),
                    const Color(0xFFE7DFAF)
                        .withValues(alpha: 0.0),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
