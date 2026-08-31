import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_constants.dart';
import '../../models/cart_model.dart';
import '../../providers/cart_provider.dart';
import '../../providers/favorite_provider.dart';
import '../../providers/locale_provider.dart';
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

  bool get _isArabic =>
      Localizations.localeOf(context).languageCode == 'ar';

  void _changeLanguage(
    String languageCode,
  ) {
    Provider.of<LocaleProvider>(
      context,
      listen: false,
    ).setLocale(
      Locale(languageCode),
    );
  }

  String _localizedProductName(
    Map<String, dynamic> product,
  ) {
    final name =
        product['name']?.toString().trim() ?? '';
    final nameEn =
        product['nameEn']?.toString().trim() ?? '';
    final nameAr =
        product['nameAr']?.toString().trim() ?? '';

    if (_isArabic) {
      if (nameAr.isNotEmpty) return nameAr;
      if (name.isNotEmpty) return name;
      if (nameEn.isNotEmpty) return nameEn;
      return 'منتج';
    }

    if (nameEn.isNotEmpty) return nameEn;
    if (name.isNotEmpty) return name;
    if (nameAr.isNotEmpty) return nameAr;
    return 'Product';
  }

  String _localizedDescription(
    Map<String, dynamic> product,
  ) {
    final description =
        product['description']?.toString().trim() ?? '';
    final descriptionEn =
        product['descriptionEn']?.toString().trim() ?? '';
    final descriptionAr =
        product['descriptionAr']?.toString().trim() ?? '';

    if (_isArabic) {
      if (descriptionAr.isNotEmpty) return descriptionAr;
      if (description.isNotEmpty) return description;
      return descriptionEn;
    }

    if (descriptionEn.isNotEmpty) return descriptionEn;
    if (description.isNotEmpty) return description;
    return descriptionAr;
  }

  String _localizedCategoryName(
    dynamic category,
  ) {
    if (category is! Map) {
      return '';
    }

    final name =
        category['name']?.toString().trim() ?? '';
    final nameEn =
        category['nameEn']?.toString().trim() ?? '';
    final nameAr =
        category['nameAr']?.toString().trim() ?? '';

    if (_isArabic) {
      if (nameAr.isNotEmpty) return nameAr;
      if (name.isNotEmpty) return name;
      return nameEn;
    }

    if (nameEn.isNotEmpty) return nameEn;
    if (name.isNotEmpty) return name;
    return nameAr;
  }

  String _resolveImageUrl(
    String imageUrl,
  ) {
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

  Future<void> _openImagePreview({
    required String imageUrl,
    required String productName,
  }) async {
    await showDialog<void>(
      context: context,
      barrierColor:
          Colors.black.withValues(alpha: 0.82),
      builder: (dialogContext) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.all(24),
          child: Container(
            constraints: const BoxConstraints(
              maxWidth: 1100,
              maxHeight: 760,
            ),
            decoration: BoxDecoration(
              color: const Color(0xFF101410),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.35),
                  blurRadius: 30,
                  offset: const Offset(0, 12),
                ),
              ],
            ),
            clipBehavior: Clip.antiAlias,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    20,
                    16,
                    12,
                    12,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          productName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      IconButton(
                        tooltip:
                            _isArabic ? 'إغلاق' : 'Close',
                        onPressed: () {
                          Navigator.pop(dialogContext);
                        },
                        style: IconButton.styleFrom(
                          backgroundColor:
                              Colors.white.withValues(alpha: 0.10),
                          foregroundColor: Colors.white,
                        ),
                        icon: const Icon(Icons.close_rounded),
                      ),
                    ],
                  ),
                ),
                Flexible(
                  child: InteractiveViewer(
                    minScale: 1,
                    maxScale: 4,
                    child: Center(
                      child: Image.network(
                        imageUrl,
                        fit: BoxFit.contain,
                        errorBuilder: (
                          context,
                          error,
                          stackTrace,
                        ) {
                          return const Padding(
                            padding: EdgeInsets.all(48),
                            child: Icon(
                              Icons.broken_image_outlined,
                              size: 72,
                              color: Colors.white70,
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    16,
                    10,
                    16,
                    16,
                  ),
                  child: Text(
                    _isArabic
                        ? 'استخدم التكبير والسحب لمعاينة الصورة.'
                        : 'Pinch or drag to zoom and inspect the image.',
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
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
                    isArabic: _isArabic,
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
                      isArabic: _isArabic,
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
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: _EmptyFavorites(
                      isArabic: _isArabic,
                    ),
                  )
                else
                  SliverPadding(
                    padding: EdgeInsets.fromLTRB(
                      22,
                      0,
                      22,
                      40 + MediaQuery.paddingOf(context).bottom,
                    ),
                    sliver: SliverGrid(
                      gridDelegate:
                          const SliverGridDelegateWithMaxCrossAxisExtent(
                        maxCrossAxisExtent: 340,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                        mainAxisExtent: 467,
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

                          final product =
                              Map<String, dynamic>.from(
                            productData,
                          );

                          final localizedName =
                              _localizedProductName(
                            product,
                          );

                          final localizedDescription =
                              _localizedDescription(
                            product,
                          );

                          final localizedCategoryName =
                              _localizedCategoryName(
                            product['category'],
                          );

                          final rawImageUrl =
                              product['imageUrl']?.toString();

                          final resolvedImageUrl =
                              rawImageUrl != null &&
                                      rawImageUrl
                                          .trim()
                                          .isNotEmpty
                                  ? _resolveImageUrl(
                                      rawImageUrl,
                                    )
                                  : null;

                          return _FavoriteProductCard(
                            product: product,
                            isArabic: _isArabic,
                            localizedName: localizedName,
                            localizedDescription:
                                localizedDescription,
                            localizedCategoryName:
                                localizedCategoryName,
                            onImageTap:
                                resolvedImageUrl == null
                                    ? null
                                    : () {
                                        _openImagePreview(
                                          imageUrl:
                                              resolvedImageUrl,
                                          productName:
                                              localizedName,
                                        );
                                      },
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
    CartProvider cartProvider, {
    required bool isArabic,
  }) {
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
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isCompact = constraints.maxWidth < 470;

            Widget languageButton() {
              return PopupMenuButton<String>(
                tooltip:
                    isArabic
                        ? 'تغيير اللغة'
                        : 'Change Language',
                offset: const Offset(0, 48),
                position: PopupMenuPosition.under,
                color: const Color(0xFFF8FAF4),
                elevation: 8,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                onSelected: _changeLanguage,
                itemBuilder: (context) {
                  return [
                    PopupMenuItem<String>(
                      value: 'en',
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.check_rounded,
                            size: 20,
                            color: !isArabic
                                ? _primaryGreen
                                : Colors.transparent,
                          ),
                          const SizedBox(width: 10),
                          Text(
                            isArabic
                                ? 'الإنجليزية'
                                : 'English',
                          ),
                        ],
                      ),
                    ),
                    PopupMenuItem<String>(
                      value: 'ar',
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.check_rounded,
                            size: 20,
                            color: isArabic
                                ? _primaryGreen
                                : Colors.transparent,
                          ),
                          const SizedBox(width: 10),
                          Text(
                            isArabic
                                ? 'العربية'
                                : 'Arabic',
                          ),
                        ],
                      ),
                    ),
                  ];
                },
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color:
                        Colors.white.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  alignment: Alignment.center,
                  child: const Icon(
                    Icons.language_rounded,
                    color: Colors.white,
                    size: 21,
                  ),
                ),
              );
            }

            Widget cartButton() {
              return Stack(
                clipBehavior: Clip.none,
                children: [
                  _HeaderButton(
                    icon: Icons.shopping_cart_outlined,
                    tooltip: isArabic
                        ? 'سلة التسوق'
                        : 'Shopping Cart',
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
                          borderRadius:
                              BorderRadius.circular(12),
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
              );
            }

            final titleBlock = Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment:
                        AlignmentDirectional.centerStart,
                    child: Text(
                      'FarmPilot',
                      maxLines: 1,
                      softWrap: false,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 19,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    isArabic ? 'المفضلة' : 'My Favorites',
                    maxLines: 1,
                    softWrap: false,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Color(0xCCFFFFFF),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            );

            final leading = <Widget>[
              _HeaderButton(
                icon: Icons.arrow_back_rounded,
                tooltip: isArabic ? 'رجوع' : 'Back',
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
              titleBlock,
            ];

            if (!isCompact) {
              return Row(
                children: [
                  ...leading,
                  languageButton(),
                  const SizedBox(width: 8),
                  cartButton(),
                  const SizedBox(width: 8),
                  _HeaderButton(
                    icon: Icons.refresh_rounded,
                    tooltip: isArabic ? 'تحديث' : 'Refresh',
                    onTap: favoriteProvider.isLoading
                        ? null
                        : _loadFavorites,
                  ),
                ],
              );
            }

            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(children: leading),
                const SizedBox(height: 12),
                Align(
                  alignment: AlignmentDirectional.centerEnd,
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      languageButton(),
                      cartButton(),
                      _HeaderButton(
                        icon: Icons.refresh_rounded,
                        tooltip:
                            isArabic ? 'تحديث' : 'Refresh',
                        onTap: favoriteProvider.isLoading
                            ? null
                            : _loadFavorites,
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildIntroCard(
    FavoriteProvider favoriteProvider, {
    required bool isArabic,
  }) {
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
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isArabic ? 'المفضلة' : 'My Favorites',
                  style: const TextStyle(
                    color: _textPrimary,
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  isArabic
                      ? 'احتفظ بمنتجاتك الزراعية المفضلة في مكان واحد للوصول السريع.'
                      : 'Keep your favorite farm products in one place for quick access.',
                  style: const TextStyle(
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
              isArabic
                  ? '${favoriteProvider.favorites.length} محفوظ'
                  : '${favoriteProvider.favorites.length} saved',
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
  final bool isArabic;
  final String localizedName;
  final String localizedDescription;
  final String localizedCategoryName;
  final VoidCallback? onImageTap;

  const _FavoriteProductCard({
    required this.product,
    required this.isArabic,
    required this.localizedName,
    required this.localizedDescription,
    required this.localizedCategoryName,
    required this.onImageTap,
  });

  @override
  Widget build(BuildContext context) {
    final name = localizedName;
    final description =
        localizedDescription;
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
        localizedCategoryName;

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
                child: Material(
                  color: const Color(0xFFF0F5EB),
                  child: InkWell(
                    onTap: onImageTap,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        if (imageUrl != null &&
                            imageUrl.isNotEmpty)
                          Image.network(
                            _buildImageUrl(imageUrl),
                            fit: BoxFit.cover,
                            errorBuilder: (
                              context,
                              error,
                              stackTrace,
                            ) {
                              return const Center(
                                child: Icon(
                                  Icons.image_not_supported_outlined,
                                  size: 52,
                                  color: Color(0xFF9AA59B),
                                ),
                              );
                            },
                          )
                        else
                          const Center(
                            child: Icon(
                              Icons.eco_outlined,
                              size: 58,
                              color: _primaryGreen,
                            ),
                          ),
                        if (imageUrl != null &&
                            imageUrl.isNotEmpty)
                          PositionedDirectional(
                            end: 12,
                            bottom: 12,
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.black.withValues(
                                  alpha: 0.42,
                                ),
                                borderRadius:
                                    BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                Icons.zoom_out_map_rounded,
                                size: 18,
                                color: Colors.white,
                              ),
                            ),
                          ),
                      ],
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
                    tooltip: isArabic ? 'إزالة من المفضلة' : 'Remove from favorites',
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
                                        ? (isArabic
                                            ? 'تمت إزالة $name من المفضلة'
                                            : '$name removed from favorites')
                                        : provider.errorMessage ??
                                            (isArabic
                                                ? 'فشل إزالة المنتج من المفضلة'
                                                : 'Failed to remove favorite'),
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
                            '${isArabic ? 'المزارع' : 'Farmer'}: $farmerName',
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
                               ? '${isArabic ? 'متاح' : 'Available'}: $quantity'
                               : (isArabic
                                   ? 'نفد من المخزون'
                                   : 'Out of stock'),
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
                    height: 54,
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
                                      isArabic
                                          ? 'تمت إضافة $name إلى السلة'
                                          : '$name added to cart',
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
                      label: Text(
                         isArabic ? 'أضف إلى السلة' : 'Add to Cart',
                         style: const TextStyle(
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
  final bool isArabic;

  const _EmptyFavorites({
    required this.isArabic,
  });

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
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.favorite_border_rounded,
                size: 72,
                color: Color(0xFFB15B72),
              ),
              const SizedBox(height: 16),
              Text(
                isArabic
                    ? 'لا توجد منتجات مفضلة بعد'
                    : 'No favorite products yet',
                style: const TextStyle(
                  color: _textPrimary,
                  fontSize: 21,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                isArabic
                    ? 'أضف منتجات من السوق وستظهر هنا.'
                    : 'Add products from the marketplace and they will appear here.',
                textAlign: TextAlign.center,
                style: const TextStyle(
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
