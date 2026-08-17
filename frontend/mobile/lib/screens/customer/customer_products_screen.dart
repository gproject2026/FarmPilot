import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_constants.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../models/cart_model.dart';
import '../../providers/cart_provider.dart';
import '../../providers/favorite_provider.dart';
import '../../providers/product_provider.dart';
import 'customer_cart_screen.dart';
import 'customer_favorites_screen.dart';
import 'customer_product_details_screen.dart';

const Color _marketDarkGreen = Color(0xFF173F24);
const Color _marketPrimaryGreen = Color(0xFF2F6B3D);
const Color _marketLightGreen = Color(0xFFDDECB8);
const Color _marketBackground = Color(0xFFF8FAF4);
const Color _marketTextPrimary = Color(0xFF1D2C21);
const Color _marketTextSecondary = Color(0xFF68756B);

class CustomerProductsScreen extends StatefulWidget {
  const CustomerProductsScreen({
    super.key,
  });

  @override
  State<CustomerProductsScreen> createState() =>
      _CustomerProductsScreenState();
}

class _CustomerProductsScreenState
    extends State<CustomerProductsScreen> {
@override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback(
      (_) {
        _loadData();
      },
    );
  }

  Future<void> _loadData() async {
    try {
      await Future.wait([
        Provider.of<ProductProvider>(
          context,
          listen: false,
        ).loadAllProducts(),
        Provider.of<FavoriteProvider>(
          context,
          listen: false,
        ).loadFavorites(),
      ]);
    } catch (e) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(
              e.toString().replaceFirst(
                    'Exception: ',
                    '',
                  ),
            ),
            backgroundColor:
                Colors.red,
          ),
        );
    }
  }

  Future<void> _openFavorites() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            const CustomerFavoritesScreen(),
      ),
    );

    if (!mounted) {
      return;
    }

    await Provider.of<FavoriteProvider>(
      context,
      listen: false,
    ).loadFavorites();
  }

  void _openCart() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            const CustomerCartScreen(),
      ),
    );
  }

  @override
  Widget build(
    BuildContext context,
  ) {
    final productProvider =
        Provider.of<ProductProvider>(
      context,
    );

    final cartProvider =
        Provider.of<CartProvider>(
      context,
    );

    final l10n =
        AppLocalizations.of(context)!;

    final isArabic =
        Localizations.localeOf(context)
                .languageCode ==
            'ar';

    return Scaffold(
      backgroundColor:
          _marketBackground,
      body: Stack(
        children: [
          const Positioned.fill(
            child:
                _MarketplaceBackdrop(),
          ),
          RefreshIndicator(
            onRefresh:
                _loadData,
            color:
                _marketPrimaryGreen,
            child:
                CustomScrollView(
              physics:
                  const AlwaysScrollableScrollPhysics(),
              slivers: [
                SliverToBoxAdapter(
                  child: _buildHeader(
                    l10n:
                        l10n,
                    cartProvider:
                        cartProvider,
                    productProvider:
                        productProvider,
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding:
                        const EdgeInsets.fromLTRB(
                      22,
                      24,
                      22,
                      18,
                    ),
                    child: _buildPageIntro(
                      l10n:
                          l10n,
                      isArabic:
                          isArabic,
                    ),
                  ),
                ),
                if (productProvider.isLoading &&
                    productProvider
                        .products.isEmpty)
                  const SliverFillRemaining(
                    hasScrollBody:
                        false,
                    child: Center(
                      child:
                          CircularProgressIndicator(
                        color:
                            _marketPrimaryGreen,
                      ),
                    ),
                  )
                else if (productProvider
                    .products.isEmpty)
                  SliverFillRemaining(
                    hasScrollBody:
                        false,
                    child: _buildEmptyState(
                      l10n:
                          l10n,
                    ),
                  )
                else
                  SliverPadding(
                    padding:
                        const EdgeInsets.fromLTRB(
                      22,
                      0,
                      22,
                      36,
                    ),
                    sliver:
                        SliverGrid(
                      gridDelegate:
                          const SliverGridDelegateWithMaxCrossAxisExtent(
                        maxCrossAxisExtent:
                            340,
                        crossAxisSpacing:
                            16,
                        mainAxisSpacing:
                            16,
                        mainAxisExtent:
                            455,
                      ),
                      delegate:
                          SliverChildBuilderDelegate(
                        (
                          context,
                          index,
                        ) {
                          final product =
                              Map<String, dynamic>.from(
                            productProvider
                                .products[index],
                          );

                          return _ProductCard(
                            product:
                                product,
                            isArabic:
                                isArabic,
                          );
                        },
                        childCount:
                            productProvider
                                .products.length,
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

  Widget _buildHeader({
    required AppLocalizations l10n,
    required CartProvider cartProvider,
    required ProductProvider productProvider,
  }) {
    return Container(
      padding:
          const EdgeInsets.fromLTRB(
        20,
        16,
        20,
        18,
      ),
      decoration:
          BoxDecoration(
        gradient:
            const LinearGradient(
          begin:
              Alignment.topLeft,
          end:
              Alignment.bottomRight,
          colors: [
            Color(0xFF123A22),
            Color(0xFF205A34),
            Color(0xFF2E6F40),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color:
                _marketDarkGreen.withValues(
              alpha:
                  0.18,
            ),
            blurRadius:
                24,
            offset:
                const Offset(
              0,
              8,
            ),
          ),
        ],
      ),
      child: SafeArea(
        bottom:
            false,
        child: Row(
          children: [
            Material(
              color:
                  Colors.white.withValues(
                alpha:
                    0.10,
              ),
              borderRadius:
                  BorderRadius.circular(
                14,
              ),
              child: InkWell(
                onTap: () {
                  Navigator.pop(
                    context,
                  );
                },
                borderRadius:
                    BorderRadius.circular(
                  14,
                ),
                child:
                    const SizedBox(
                  width:
                      44,
                  height:
                      44,
                  child:
                      Icon(
                    Icons
                        .arrow_back_rounded,
                    color:
                        Colors.white,
                  ),
                ),
              ),
            ),
            const SizedBox(
              width:
                  12,
            ),
            Container(
              width:
                  44,
              height:
                  44,
              decoration:
                  BoxDecoration(
                color:
                    _marketLightGreen,
                borderRadius:
                    BorderRadius.circular(
                  13,
                ),
              ),
              child:
                  const Icon(
                Icons.eco_rounded,
                color:
                    _marketDarkGreen,
                size:
                    24,
              ),
            ),
            const SizedBox(
              width:
                  10,
            ),
            Expanded(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.appName,
                    style:
                        const TextStyle(
                      color:
                          Colors.white,
                      fontSize:
                          19,
                      fontWeight:
                          FontWeight.w800,
                    ),
                  ),
                  const SizedBox(
                    height:
                        2,
                  ),
                  Text(
                    l10n.marketplace,
                    style:
                        TextStyle(
                      color:
                          Colors.white.withValues(
                        alpha:
                            0.78,
                      ),
                      fontSize:
                          12,
                    ),
                  ),
                ],
              ),
            ),
            _HeaderActionButton(
              tooltip:
                  l10n.myFavorites,
              icon:
                  Icons.favorite_outline_rounded,
              onTap:
                  _openFavorites,
            ),
            const SizedBox(
              width:
                  8,
            ),
            Stack(
              clipBehavior:
                  Clip.none,
              children: [
                _HeaderActionButton(
                  tooltip:
                      l10n.shoppingCart,
                  icon:
                      Icons.shopping_cart_outlined,
                  onTap:
                      _openCart,
                ),
                if (cartProvider.totalQuantity >
                    0)
                  Positioned(
                    right:
                        -4,
                    top:
                        -4,
                    child:
                        Container(
                      constraints:
                          const BoxConstraints(
                        minWidth:
                            18,
                        minHeight:
                            18,
                      ),
                      padding:
                          const EdgeInsets.symmetric(
                        horizontal:
                            4,
                      ),
                      decoration:
                          BoxDecoration(
                        color:
                            const Color(
                          0xFFE35D5D,
                        ),
                        borderRadius:
                            BorderRadius.circular(
                          12,
                        ),
                        border:
                            Border.all(
                          color:
                              Colors.white,
                          width:
                              1.5,
                        ),
                      ),
                      alignment:
                          Alignment.center,
                      child:
                          Text(
                        cartProvider
                            .totalQuantity
                            .toString(),
                        style:
                            const TextStyle(
                          color:
                              Colors.white,
                          fontSize:
                              9,
                          fontWeight:
                              FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(
              width:
                  8,
            ),
            _HeaderActionButton(
              tooltip:
                  l10n.refresh,
              icon:
                  Icons.refresh_rounded,
              onTap:
                  productProvider.isLoading
                      ? null
                      : _loadData,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPageIntro({
    required AppLocalizations l10n,
    required bool isArabic,
  }) {
    return Container(
      width:
          double.infinity,
      padding:
          const EdgeInsets.symmetric(
        horizontal:
            24,
        vertical:
            20,
      ),
      decoration:
          BoxDecoration(
        gradient:
            const LinearGradient(
          begin:
              AlignmentDirectional.centerStart,
          end:
              AlignmentDirectional.centerEnd,
          colors: [
            Color(0xFFFFFFFF),
            Color(0xFFFFFEFA),
            Color(0xFFF5F9EE),
          ],
        ),
        borderRadius:
            BorderRadius.circular(
          24,
        ),
        border:
            Border.all(
          color:
              const Color(
            0xFFDDE7D8,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color:
                _marketDarkGreen.withValues(
              alpha:
                  0.045,
            ),
            blurRadius:
                18,
            offset:
                const Offset(
              0,
              6,
            ),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width:
                54,
            height:
                54,
            decoration:
                BoxDecoration(
              color:
                  const Color(
                0xFFEAF3DF,
              ),
              borderRadius:
                  BorderRadius.circular(
                17,
              ),
            ),
            child:
                const Icon(
              Icons.storefront_outlined,
              color:
                  _marketPrimaryGreen,
              size:
                  28,
            ),
          ),
          const SizedBox(
            width:
                16,
          ),
          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.marketplace,
                  style:
                      const TextStyle(
                    color:
                        _marketTextPrimary,
                    fontSize:
                        24,
                    fontWeight:
                        FontWeight.w800,
                  ),
                ),
                const SizedBox(
                  height:
                      4,
                ),
                Text(
                  isArabic
                      ? 'اكتشف المنتجات الزراعية الطازجة وأضف ما تحتاجه إلى سلتك.'
                      : 'Discover fresh farm products and add what you need to your cart.',
                  style:
                      const TextStyle(
                    color:
                        _marketTextSecondary,
                    fontSize:
                        13,
                    height:
                        1.45,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState({
    required AppLocalizations l10n,
  }) {
    return Center(
      child: Padding(
        padding:
            const EdgeInsets.all(
          30,
        ),
        child: Column(
          mainAxisSize:
              MainAxisSize.min,
          children: [
            Container(
              width:
                  92,
              height:
                  92,
              decoration:
                  BoxDecoration(
                color:
                    const Color(
                  0xFFEAF3DF,
                ),
                borderRadius:
                    BorderRadius.circular(
                  28,
                ),
              ),
              child:
                  const Icon(
                Icons.storefront_outlined,
                size:
                    46,
                color:
                    _marketPrimaryGreen,
              ),
            ),
            const SizedBox(
              height:
                  18,
            ),
            Text(
              l10n.noProductsFound,
              style:
                  const TextStyle(
                color:
                    _marketTextPrimary,
                fontSize:
                    20,
                fontWeight:
                    FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HeaderActionButton
    extends StatelessWidget {
  final String tooltip;
  final IconData icon;
  final VoidCallback? onTap;

  const _HeaderActionButton({
    required this.tooltip,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    return Tooltip(
      message:
          tooltip,
      child: Material(
        color:
            Colors.white.withValues(
          alpha:
              onTap == null
                  ? 0.05
                  : 0.10,
        ),
        borderRadius:
            BorderRadius.circular(
          14,
        ),
        child: InkWell(
          onTap:
              onTap,
          borderRadius:
              BorderRadius.circular(
            14,
          ),
          child: SizedBox(
            width:
                44,
            height:
                44,
            child:
                Icon(
              icon,
              color:
                  onTap == null
                      ? Colors.white54
                      : Colors.white,
              size:
                  21,
            ),
          ),
        ),
      ),
    );
  }
}

class _ProductCard
    extends StatelessWidget {
  final Map<String, dynamic> product;
  final bool isArabic;

  const _ProductCard({
    required this.product,
    required this.isArabic,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    final l10n =
        AppLocalizations.of(context)!;

    final name =
        product['name']?.toString() ??
            (isArabic
                ? 'منتج'
                : 'Product');

    final description =
        product['description']
                ?.toString() ??
            '';

    final unit =
        product['unit']?.toString() ??
            '';

    final imageUrl =
        product['imageUrl']
            ?.toString();

    final status =
        product['status']
                ?.toString() ??
            '';

    final quantity =
        int.tryParse(
          product['quantity']
                  ?.toString() ??
              '0',
        ) ??
            0;

    final price =
        double.tryParse(
          product['price']
                  ?.toString() ??
              '0',
        ) ??
            0.0;

    final productId =
        product['id']?.toString() ??
            '';

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

    final favoriteProvider =
        Provider.of<FavoriteProvider>(
      context,
    );

    final isFavorite =
        favoriteProvider.isFavorite(
      productId,
    );

    return Material(
      color:
          Colors.transparent,
      borderRadius:
          BorderRadius.circular(
        22,
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) =>
                  CustomerProductDetailsScreen(
                product:
                    product,
              ),
            ),
          );
        },
        borderRadius:
            BorderRadius.circular(
          22,
        ),
        child: Container(
          decoration:
              BoxDecoration(
            gradient:
                const LinearGradient(
              begin:
                  Alignment.topLeft,
              end:
                  Alignment.bottomRight,
              colors: [
                Color(
                  0xFFFFFFFF,
                ),
                Color(
                  0xFFFFFEFA,
                ),
              ],
            ),
            borderRadius:
                BorderRadius.circular(
              22,
            ),
            border:
                Border.all(
              color:
                  const Color(
                0xFFDDE6D8,
              ),
            ),
            boxShadow: [
              BoxShadow(
                color:
                    const Color(
                  0xFF173F24,
                ).withValues(
                  alpha:
                      0.055,
                ),
                blurRadius:
                    18,
                offset:
                    const Offset(
                  0,
                  7,
                ),
              ),
            ],
          ),
          clipBehavior:
              Clip.antiAlias,
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Stack(
                children: [
                  SizedBox(
                    height:
                        175,
                    width:
                        double.infinity,
                    child:
                        Container(
                      color:
                          const Color(
                        0xFFF0F5EB,
                      ),
                      child:
                          imageUrl != null &&
                                  imageUrl
                                      .isNotEmpty
                              ? Image.network(
                                  _buildImageUrl(
                                    imageUrl,
                                  ),
                                  fit:
                                      BoxFit.cover,
                                  errorBuilder:
                                      (
                                    context,
                                    error,
                                    stackTrace,
                                  ) {
                                    return const Center(
                                      child:
                                          Icon(
                                        Icons.image_not_supported_outlined,
                                        size:
                                            52,
                                        color:
                                            Color(
                                          0xFF9AA59B,
                                        ),
                                      ),
                                    );
                                  },
                                )
                              : const Center(
                                  child:
                                      Icon(
                                    Icons.eco_outlined,
                                    size:
                                        58,
                                    color:
                                        _marketPrimaryGreen,
                                  ),
                                ),
                    ),
                  ),
                  if (categoryName
                      .isNotEmpty)
                    PositionedDirectional(
                      start:
                          10,
                      bottom:
                          10,
                      child:
                          Container(
                        padding:
                            const EdgeInsets.symmetric(
                          horizontal:
                              10,
                          vertical:
                              6,
                        ),
                        decoration:
                            BoxDecoration(
                          color:
                              Colors.white.withValues(
                            alpha:
                                0.92,
                          ),
                          borderRadius:
                              BorderRadius.circular(
                            20,
                          ),
                        ),
                        child:
                            Text(
                          categoryName,
                          style:
                              const TextStyle(
                            color:
                                _marketPrimaryGreen,
                            fontSize:
                                11,
                            fontWeight:
                                FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  PositionedDirectional(
                    end:
                        10,
                    top:
                        10,
                    child:
                        Material(
                      color:
                          Colors.white.withValues(
                        alpha:
                            0.96,
                      ),
                      shape:
                          const CircleBorder(),
                      elevation:
                          2,
                      child:
                          IconButton(
                        tooltip:
                            isFavorite
                                ? (isArabic
                                    ? 'إزالة من المفضلة'
                                    : 'Remove from favorites')
                                : (isArabic
                                    ? 'إضافة إلى المفضلة'
                                    : 'Add to favorites'),
                        onPressed:
                            productId.isEmpty
                                ? null
                                : () async {
                                    final success =
                                        await Provider.of<FavoriteProvider>(
                                      context,
                                      listen:
                                          false,
                                    ).toggleFavorite(
                                      productId,
                                    );

                                    if (!context.mounted) {
                                      return;
                                    }

                                    final provider =
                                        Provider.of<FavoriteProvider>(
                                      context,
                                      listen:
                                          false,
                                    );

                                    final nowFavorite =
                                        provider.isFavorite(
                                      productId,
                                    );

                                    ScaffoldMessenger.of(
                                      context,
                                    )
                                      ..hideCurrentSnackBar()
                                      ..showSnackBar(
                                        SnackBar(
                                          content:
                                              Text(
                                            success
                                                ? nowFavorite
                                                    ? (isArabic
                                                        ? 'تمت إضافة $name إلى المفضلة'
                                                        : '$name added to favorites')
                                                    : (isArabic
                                                        ? 'تمت إزالة $name من المفضلة'
                                                        : '$name removed from favorites')
                                                : provider.errorMessage ??
                                                    (isArabic
                                                        ? 'فشلت عملية المفضلة'
                                                        : 'Favorite operation failed'),
                                          ),
                                          backgroundColor:
                                              success
                                                  ? _marketPrimaryGreen
                                                  : Colors.red,
                                        ),
                                      );
                                  },
                        icon:
                            Icon(
                          isFavorite
                              ? Icons.favorite_rounded
                              : Icons.favorite_border_rounded,
                          color:
                              isFavorite
                                  ? const Color(
                                      0xFFE65353,
                                    )
                                  : const Color(
                                      0xFF647166,
                                    ),
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
                        maxLines:
                            1,
                        overflow:
                            TextOverflow.ellipsis,
                        style:
                            const TextStyle(
                          color:
                              _marketTextPrimary,
                          fontSize:
                              17,
                          fontWeight:
                              FontWeight.w800,
                        ),
                      ),
                      if (description
                          .isNotEmpty) ...[
                        const SizedBox(
                          height:
                              7,
                        ),
                        Text(
                          description,
                          maxLines:
                              2,
                          overflow:
                              TextOverflow.ellipsis,
                          style:
                              const TextStyle(
                            color:
                                _marketTextSecondary,
                            fontSize:
                                12,
                            height:
                                1.4,
                          ),
                        ),
                      ],
                      if (farmerName
                          .isNotEmpty) ...[
                        const SizedBox(
                          height:
                              7,
                        ),
                        Row(
                          children: [
                            const Icon(
                              Icons.person_outline_rounded,
                              size:
                                  15,
                              color:
                                  Color(
                                0xFF7A867C,
                              ),
                            ),
                            const SizedBox(
                              width:
                                  5,
                            ),
                            Expanded(
                              child: Text(
                                '${isArabic ? 'المزارع' : 'Farmer'}: $farmerName',
                                maxLines:
                                    1,
                                overflow:
                                    TextOverflow.ellipsis,
                                style:
                                    const TextStyle(
                                  color:
                                      _marketTextSecondary,
                                  fontSize:
                                      11,
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
                              maxLines:
                                  1,
                              overflow:
                                  TextOverflow.ellipsis,
                              style:
                                  const TextStyle(
                                color:
                                    _marketPrimaryGreen,
                                fontSize:
                                    18,
                                fontWeight:
                                    FontWeight.w800,
                              ),
                            ),
                          ),
                          Container(
                            padding:
                                const EdgeInsets.symmetric(
                              horizontal:
                                  9,
                              vertical:
                                  5,
                            ),
                            decoration:
                                BoxDecoration(
                              color:
                                  isAvailable
                                      ? const Color(
                                          0xFFEAF3DF,
                                        )
                                      : const Color(
                                          0xFFFCE7E7,
                                        ),
                              borderRadius:
                                  BorderRadius.circular(
                                18,
                              ),
                            ),
                            child:
                                Text(
                              isAvailable
                                  ? '${l10n.available}: $quantity'
                                  : l10n.outOfStock,
                              style:
                                  TextStyle(
                                color:
                                    isAvailable
                                        ? _marketPrimaryGreen
                                        : const Color(
                                            0xFFB44F4F,
                                          ),
                                fontSize:
                                    10,
                                fontWeight:
                                    FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(
                        height:
                            12,
                      ),
                      SizedBox(
                        width:
                            double.infinity,
                        height:
                            42,
                        child:
                            ElevatedButton.icon(
                          onPressed:
                              isAvailable
                                  ? () {
                                      Provider.of<CartProvider>(
                                        context,
                                        listen:
                                            false,
                                      ).addToCart(
                                        CartItem(
                                          productId:
                                              productId,
                                          name:
                                              name,
                                          price:
                                              price,
                                          unit:
                                              unit,
                                          quantity:
                                              1,
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
                                            content:
                                                Text(
                                              isArabic
                                                  ? 'تمت إضافة $name إلى السلة'
                                                  : '$name added to cart',
                                            ),
                                            duration:
                                                const Duration(
                                              seconds:
                                                  2,
                                            ),
                                            backgroundColor:
                                                _marketPrimaryGreen,
                                          ),
                                        );
                                    }
                                  : null,
                          style:
                              ElevatedButton.styleFrom(
                            backgroundColor:
                                _marketPrimaryGreen,
                            foregroundColor:
                                Colors.white,
                            disabledBackgroundColor:
                                const Color(
                              0xFFD6DDD4,
                            ),
                            elevation:
                                0,
                            shape:
                                RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(
                                14,
                              ),
                            ),
                          ),
                          icon:
                              const Icon(
                            Icons.add_shopping_cart_rounded,
                            size:
                                18,
                          ),
                          label:
                              Text(
                            isArabic
                                ? 'أضف إلى السلة'
                                : 'Add to Cart',
                            style:
                                const TextStyle(
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
        ),
      ),
    );
  }

  String _buildImageUrl(
    String imageUrl,
  ) {
    final trimmedUrl =
        imageUrl.trim();

    if (trimmedUrl.isEmpty) {
      return '';
    }

    if (trimmedUrl.startsWith(
          'http://localhost:3000',
        ) ||
        trimmedUrl.startsWith(
          'http://127.0.0.1:3000',
        )) {
      return trimmedUrl.replaceFirst(
        RegExp(
          r'http://(localhost|127\.0\.0\.1):3000',
        ),
        AppConstants.baseUrl,
      );
    }

    if (trimmedUrl.startsWith(
          'http://',
        ) ||
        trimmedUrl.startsWith(
          'https://',
        )) {
      return trimmedUrl;
    }

    final normalizedPath =
        trimmedUrl.startsWith('/')
            ? trimmedUrl
            : '/$trimmedUrl';

    return '${AppConstants.baseUrl}$normalizedPath';
  }
}

class _MarketplaceBackdrop
    extends StatelessWidget {
  const _MarketplaceBackdrop();

  @override
  Widget build(
    BuildContext context,
  ) {
    return IgnorePointer(
      child: Stack(
        fit:
            StackFit.expand,
        children: [
          const DecoratedBox(
            decoration:
                BoxDecoration(
              gradient:
                  LinearGradient(
                begin:
                    Alignment.topCenter,
                end:
                    Alignment.bottomCenter,
                colors: [
                  Color(
                    0xFFF8FAF4,
                  ),
                  Color(
                    0xFFFFFCF5,
                  ),
                  Color(
                    0xFFF4F8ED,
                  ),
                ],
                stops: [
                  0.0,
                  0.50,
                  1.0,
                ],
              ),
            ),
          ),
          PositionedDirectional(
            end:
                -190,
            top:
                220,
            child: Container(
              width:
                  470,
              height:
                  470,
              decoration:
                  BoxDecoration(
                shape:
                    BoxShape.circle,
                gradient:
                    RadialGradient(
                  colors: [
                    const Color(
                      0xFFCFE6B4,
                    ).withValues(
                      alpha:
                          0.28,
                    ),
                    const Color(
                      0xFFCFE6B4,
                    ).withValues(
                      alpha:
                          0.0,
                    ),
                  ],
                ),
              ),
            ),
          ),
          PositionedDirectional(
            start:
                -180,
            bottom:
                -220,
            child: Container(
              width:
                  520,
              height:
                  520,
              decoration:
                  BoxDecoration(
                shape:
                    BoxShape.circle,
                gradient:
                    RadialGradient(
                  colors: [
                    const Color(
                      0xFFE7DFAF,
                    ).withValues(
                      alpha:
                          0.22,
                    ),
                    const Color(
                      0xFFE7DFAF,
                    ).withValues(
                      alpha:
                          0.0,
                    ),
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
