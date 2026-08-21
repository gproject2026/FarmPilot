import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_constants.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../providers/locale_provider.dart';
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

  String _getCategoryName(
    dynamic category,
    BuildContext context,
  ) {
    if (category is! Map) {
      return '';
    }

    final languageCode =
        Localizations.localeOf(
      context,
    ).languageCode;

    final name =
        category['name']
            ?.toString()
            .trim();

    final nameEn =
        category['nameEn']
            ?.toString()
            .trim();

    final nameAr =
        category['nameAr']
            ?.toString()
            .trim();

    if (languageCode == 'ar') {
      if (nameAr != null &&
          nameAr.isNotEmpty) {
        return nameAr;
      }

      if (name != null &&
          name.isNotEmpty) {
        return name;
      }

      if (nameEn != null &&
          nameEn.isNotEmpty) {
        return nameEn;
      }

      return '';
    }

    if (nameEn != null &&
        nameEn.isNotEmpty) {
      return nameEn;
    }

    if (name != null &&
        name.isNotEmpty) {
      return name;
    }

    if (nameAr != null &&
        nameAr.isNotEmpty) {
      return nameAr;
    }

    return '';
  }

  Future<void> _openImagePreview({
    required String imageUrl,
    required String productName,
  }) async {
    final l10n = AppLocalizations.of(context)!;

    await showDialog<void>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.82),
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
                        tooltip: l10n.close,
                        onPressed: () {
                          Navigator.pop(dialogContext);
                        },
                        style: IconButton.styleFrom(
                          backgroundColor:
                              Colors.white.withValues(alpha: 0.10),
                          foregroundColor: Colors.white,
                        ),
                        icon: const Icon(
                          Icons.close_rounded,
                        ),
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
                    l10n.imagePreviewZoomHint,
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

  void _changeLanguage(String languageCode) {
    Provider.of<LocaleProvider>(
      context,
      listen: false,
    ).setLocale(Locale(languageCode));
  }

  @override
  Widget build(BuildContext context) {
    final productProvider = Provider.of<ProductProvider>(context);
    final l10n = AppLocalizations.of(context)!;
    final isArabic =
        Localizations.localeOf(context).languageCode == 'ar';
    final products = productProvider.products;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAF4),
      body: Stack(
        children: [
          const Positioned.fill(child: _ProductsBackdrop()),
          Column(
            children: [
              _ProductsTopBar(
                onBack: () => Navigator.pop(context),
                onRefresh: productProvider.isLoading
                    ? null
                    : productProvider.loadMyProducts,
                onLanguage: (languageCode) {
                  _changeLanguage(
                    languageCode,
                  );
                },
              ),
              Expanded(
                child: RefreshIndicator(
                  onRefresh: productProvider.loadMyProducts,
                  color: _productsPrimary,
                  child: CustomScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    slivers: [
                      SliverToBoxAdapter(
                        child: Center(
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 1320),
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(24, 26, 24, 18),
                              child: _ProductsHero(
                                totalProducts: products.length,
                                isLoading: productProvider.isLoading,
                                addLabel: l10n.addProduct,
                                title: l10n.myProducts,
                                onAddProduct: productProvider.isLoading
                                    ? null
                                    : _openAddProduct,
                              ),
                            ),
                          ),
                        ),
                      ),
                      if (productProvider.isLoading && products.isEmpty)
                        const SliverFillRemaining(
                          hasScrollBody: false,
                          child: Center(
                            child: CircularProgressIndicator(
                              color: _productsPrimary,
                            ),
                          ),
                        )
                      else if (products.isEmpty)
                        SliverFillRemaining(
                          hasScrollBody: false,
                          child: _EmptyProducts(
                            title: l10n.noProductsFound,
                            addLabel: l10n.addProduct,
                            onAdd: _openAddProduct,
                          ),
                        )
                      else
                        SliverPadding(
                          padding: const EdgeInsets.fromLTRB(24, 0, 24, 42),
                          sliver: SliverLayoutBuilder(
                            builder: (context, constraints) {
                              final width = constraints.crossAxisExtent;
                              final crossAxisCount = width >= 1180
                                  ? 4
                                  : width >= 860
                                      ? 3
                                      : width >= 560
                                          ? 2
                                          : 1;

                              return SliverGrid(
                                delegate: SliverChildBuilderDelegate(
                                  (context, index) {
                                    final product =
                                        Map<String, dynamic>.from(
                                      products[index],
                                    );

                                    final productId =
                                        product['id']?.toString() ?? '';

                                    final productName =
                                        isArabic
                                            ? (product['nameAr']
                                                        ?.toString()
                                                        .trim()
                                                        .isNotEmpty ==
                                                    true
                                                ? product['nameAr']
                                                    .toString()
                                                : (product['name']
                                                            ?.toString()
                                                            .trim()
                                                            .isNotEmpty ==
                                                        true
                                                    ? product['name']
                                                        .toString()
                                                    : (product['nameEn']
                                                                ?.toString()
                                                                .trim()
                                                                .isNotEmpty ==
                                                            true
                                                        ? product['nameEn']
                                                            .toString()
                                                        : l10n
                                                            .unnamedProduct)))
                                            : (product['nameEn']
                                                        ?.toString()
                                                        .trim()
                                                        .isNotEmpty ==
                                                    true
                                                ? product['nameEn']
                                                    .toString()
                                                : (product['name']
                                                            ?.toString()
                                                            .trim()
                                                            .isNotEmpty ==
                                                        true
                                                    ? product['name']
                                                        .toString()
                                                    : (product['nameAr']
                                                                ?.toString()
                                                                .trim()
                                                                .isNotEmpty ==
                                                            true
                                                        ? product['nameAr']
                                                            .toString()
                                                        : l10n
                                                            .unnamedProduct)));

                                    final imageUrl =
                                        _getImageUrl(product['imageUrl']);

                                    final categoryName =
                                        _getCategoryName(
                                      product['category'],
                                      context,
                                    );

                                    final translatedStatus =
                                        _translateProductStatus(
                                      product['status']?.toString() ?? '',
                                      l10n,
                                    );

                                    return _ProductCard(
                                      product: product,
                                      imageUrl: imageUrl,
                                      productName: productName,
                                      categoryName: categoryName,
                                      translatedStatus: translatedStatus,
                                      priceLabel: l10n.price,
                                      quantityLabel: l10n.quantity,
                                      statusLabel: l10n.status,
                                      categoryLabel: l10n.category,
                                      editTooltip: l10n.editProduct,
                                      deleteTooltip: l10n.deleteProduct,
                                      onImageTap: imageUrl == null
                                          ? null
                                          : () {
                                              _openImagePreview(
                                                imageUrl: imageUrl,
                                                productName: productName,
                                              );
                                            },
                                      onEdit: () => _openEditProduct(product),
                                      onDelete: productId.isEmpty
                                          ? null
                                          : () {
                                              _deleteProduct(
                                                productId: productId,
                                                productName: productName,
                                              );
                                            },
                                    );
                                  },
                                  childCount: products.length,
                                ),
                                gridDelegate:
                                    SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: crossAxisCount,
                                  crossAxisSpacing: 16,
                                  mainAxisSpacing: 16,
                                  mainAxisExtent: 520,
                                ),
                              );
                            },
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

const _productsDark = Color(0xFF173F24);
const _productsPrimary = Color(0xFF2F743F);
const _productsLight = Color(0xFFEAF3DF);
const _productsText = Color(0xFF1D2C21);
const _productsMuted = Color(0xFF6C786E);

class _ProductsTopBar extends StatelessWidget {
  final VoidCallback onBack;
  final Future<void> Function()? onRefresh;
  final ValueChanged<String> onLanguage;

  const _ProductsTopBar({
    required this.onBack,
    required this.onRefresh,
    required this.onLanguage,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xFF123A22),
            Color(0xFF205A34),
            Color(0xFF2E6F40),
          ],
        ),
      ),
      padding: const EdgeInsets.fromLTRB(18, 12, 18, 14),
      child: SafeArea(
        bottom: false,
        child: Row(
          children: [
            _TopButton(
              icon: Icons.arrow_back_rounded,
              tooltip: l10n.back,
              onTap: onBack,
            ),
            const SizedBox(width: 12),
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: const Color(0xFFDDECB8),
                borderRadius: BorderRadius.circular(13),
              ),
              child: const Icon(
                Icons.eco_rounded,
                color: _productsDark,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.appName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 19,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  Text(
                    l10n.myProducts,
                    style: const TextStyle(
                      color: Color(0xCCFFFFFF),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            PopupMenuButton<String>(
              tooltip: l10n.changeLanguage,
              offset: const Offset(0, 48),
              position: PopupMenuPosition.under,
              color: const Color(0xFFF8FAF4),
              elevation: 8,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              onSelected: onLanguage,
              itemBuilder: (context) {
                final isArabic =
                    Localizations.localeOf(context).languageCode == 'ar';

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
                              ? _productsPrimary
                              : Colors.transparent,
                        ),
                        const SizedBox(width: 10),
                        Text(l10n.english),
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
                              ? _productsPrimary
                              : Colors.transparent,
                        ),
                        const SizedBox(width: 10),
                        Text(l10n.arabic),
                      ],
                    ),
                  ),
                ];
              },
              child: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(
                    alpha: 0.10,
                  ),
                  borderRadius: BorderRadius.circular(14),
                ),
                alignment: Alignment.center,
                child: const Icon(
                  Icons.language_rounded,
                  color: Colors.white,
                  size: 21,
                ),
              ),
            ),
            const SizedBox(width: 10),
            _TopButton(
              icon: Icons.refresh_rounded,
              tooltip: l10n.refresh,
              onTap: onRefresh,
            ),
          ],
        ),
      ),
    );
  }
}

class _TopButton extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback? onTap;

  const _TopButton({
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
              color: onTap == null ? Colors.white54 : Colors.white,
              size: 21,
            ),
          ),
        ),
      ),
    );
  }
}

class _ProductsHero extends StatelessWidget {
  final int totalProducts;
  final bool isLoading;
  final String title;
  final String addLabel;
  final VoidCallback? onAddProduct;

  const _ProductsHero({
    required this.totalProducts,
    required this.isLoading,
    required this.title,
    required this.addLabel,
    required this.onAddProduct,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: _cardDecoration(25),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final heading = Row(
            children: [
              Container(
                width: 58,
                height: 58,
                decoration: BoxDecoration(
                  color: _productsLight,
                  borderRadius: BorderRadius.circular(17),
                ),
                child: const Icon(
                  Icons.inventory_2_outlined,
                  color: _productsPrimary,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: _productsText,
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      l10n.myProductsSubtitle,
                      style: const TextStyle(
                        color: _productsMuted,
                        fontSize: 13,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );

          final actions = Wrap(
            spacing: 10,
            runSpacing: 10,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 13,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F6E9),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Text(
                  l10n.productsCount(totalProducts),
                  style: const TextStyle(
                    color: _productsPrimary,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              ElevatedButton.icon(
                onPressed: onAddProduct,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _productsPrimary,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: const Color(0xFFD3DCCF),
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 15,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                icon: isLoading
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.add_rounded),
                label: Text(
                  addLabel,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          );

          if (constraints.maxWidth < 700) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                heading,
                const SizedBox(height: 18),
                actions,
              ],
            );
          }

          return Row(
            children: [
              Expanded(child: heading),
              const SizedBox(width: 20),
              actions,
            ],
          );
        },
      ),
    );
  }
}

class _ProductCard extends StatelessWidget {
  final Map<String, dynamic> product;
  final String? imageUrl;
  final String productName;
  final String categoryName;
  final String translatedStatus;
  final String priceLabel;
  final String quantityLabel;
  final String statusLabel;
  final String categoryLabel;
  final String editTooltip;
  final String deleteTooltip;
  final VoidCallback? onImageTap;
  final VoidCallback onEdit;
  final VoidCallback? onDelete;

  const _ProductCard({
    required this.product,
    required this.imageUrl,
    required this.productName,
    required this.categoryName,
    required this.translatedStatus,
    required this.priceLabel,
    required this.quantityLabel,
    required this.statusLabel,
    required this.categoryLabel,
    required this.editTooltip,
    required this.deleteTooltip,
    required this.onImageTap,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final rawStatus =
        product['status']?.toString() ?? '';
    final price =
        product['price']?.toString() ?? '';
    final quantity =
        product['quantity']?.toString() ?? '';
    final unit =
        product['unit']?.toString() ?? '';

    return Container(
      decoration: _cardDecoration(22),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              SizedBox(
                width: double.infinity,
                height: 225,
                child: Material(
                  color: const Color(0xFFF0F5EB),
                  child: InkWell(
                    onTap: onImageTap,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        if (imageUrl == null)
                          const Center(
                            child: Icon(
                              Icons.inventory_2_outlined,
                              size: 54,
                              color: _productsPrimary,
                            ),
                          )
                        else
                          Image.network(
                            imageUrl!,
                            fit: BoxFit.cover,
                            errorBuilder: (
                              context,
                              error,
                              stackTrace,
                            ) {
                              return const Center(
                                child: Icon(
                                  Icons.broken_image_outlined,
                                  size: 48,
                                  color: Color(0xFF9AA59B),
                                ),
                              );
                            },
                          ),
                        if (imageUrl != null)
                          PositionedDirectional(
                            end: 12,
                            bottom: 12,
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.black.withValues(
                                  alpha: 0.42,
                                ),
                                borderRadius: BorderRadius.circular(12),
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
              PositionedDirectional(
                start: 12,
                top: 12,
                child: _StatusBadge(
                  rawStatus: rawStatus,
                  label: translatedStatus,
                ),
              ),
            ],
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                16,
                15,
                16,
                15,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    productName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: _productsText,
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _ProductInfoRow(
                    icon: Icons.payments_outlined,
                    label: priceLabel,
                    value: '$price ₪',
                  ),
                  const SizedBox(height: 8),
                  _ProductInfoRow(
                    icon: Icons.scale_outlined,
                    label: quantityLabel,
                    value:
                        '$quantity${unit.isEmpty ? '' : ' $unit'}',
                  ),
                  const SizedBox(height: 8),
                  _ProductInfoRow(
                    icon: Icons.toggle_on_outlined,
                    label: statusLabel,
                    value: translatedStatus,
                  ),
                  if (categoryName.trim().isNotEmpty) ...[
                    const SizedBox(height: 8),
                    _ProductInfoRow(
                      icon: Icons.category_outlined,
                      label: categoryLabel,
                      value: categoryName,
                    ),
                  ],
                  const Spacer(),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: onEdit,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _productsPrimary,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(
                              vertical: 13,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(13),
                            ),
                          ),
                          icon: const Icon(
                            Icons.edit_outlined,
                            size: 18,
                          ),
                          label: Text(
                            editTooltip,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      SizedBox(
                        width: 48,
                        height: 48,
                        child: IconButton(
                          tooltip: deleteTooltip,
                          onPressed: onDelete,
                          style: IconButton.styleFrom(
                            backgroundColor: const Color(0xFFFFF3F3),
                            foregroundColor: const Color(0xFFC65353),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(13),
                            ),
                          ),
                          icon: const Icon(
                            Icons.delete_outline,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProductInfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _ProductInfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: _productsLight,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            icon,
            size: 16,
            color: _productsPrimary,
          ),
        ),
        const SizedBox(width: 9),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  color: _productsMuted,
                  fontSize: 10,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: _productsText,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String rawStatus;
  final String label;

  const _StatusBadge({
    required this.rawStatus,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    final status = rawStatus.trim().toUpperCase();

    Color foreground;
    Color background;

    switch (status) {
      case 'AVAILABLE':
        foreground = const Color(0xFF3F8A50);
        background = const Color(0xFFE8F3E7);
        break;
      case 'OUT_OF_STOCK':
        foreground = const Color(0xFFC8792C);
        background = const Color(0xFFFFF0DE);
        break;
      case 'HIDDEN':
        foreground = const Color(0xFF765D8D);
        background = const Color(0xFFF1EAF5);
        break;
      default:
        foreground = _productsMuted;
        background = const Color(0xFFF0F2EF);
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 7,
      ),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Text(
        label,
        style: TextStyle(
          color: foreground,
          fontSize: 11,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _EmptyProducts extends StatelessWidget {
  final String title;
  final String addLabel;
  final VoidCallback onAdd;

  const _EmptyProducts({
    required this.title,
    required this.addLabel,
    required this.onAdd,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Center(
      child: Container(
        constraints: const BoxConstraints(
          maxWidth: 460,
        ),
        margin: const EdgeInsets.all(24),
        padding: const EdgeInsets.all(30),
        decoration: _cardDecoration(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 82,
              height: 82,
              decoration: const BoxDecoration(
                color: _productsLight,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.inventory_2_outlined,
                size: 38,
                color: _productsPrimary,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: _productsText,
                fontSize: 20,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              l10n.createFirstProductListing,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: _productsMuted,
                fontSize: 13,
                height: 1.45,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: onAdd,
              style: ElevatedButton.styleFrom(
                backgroundColor: _productsPrimary,
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 14,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              icon: const Icon(Icons.add_rounded),
              label: Text(addLabel),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProductsBackdrop extends StatelessWidget {
  const _ProductsBackdrop();

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
                  Color(0xFFF3F8EC),
                ],
              ),
            ),
          ),
          PositionedDirectional(
            end: -180,
            top: 180,
            child: _SoftGlow(
              size: 450,
              color: const Color(0xFFCFE6B4),
            ),
          ),
          PositionedDirectional(
            start: -190,
            bottom: -220,
            child: _SoftGlow(
              size: 520,
              color: const Color(0xFFE7DFAF),
            ),
          ),
        ],
      ),
    );
  }
}

class _SoftGlow extends StatelessWidget {
  final double size;
  final Color color;

  const _SoftGlow({
    required this.size,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [
            color.withValues(alpha: 0.25),
            color.withValues(alpha: 0),
          ],
        ),
      ),
    );
  }
}

BoxDecoration _cardDecoration(double radius) {
  return BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(radius),
    border: Border.all(
      color: const Color(0xFFDCE5D8),
    ),
    boxShadow: [
      BoxShadow(
        color: _productsDark.withValues(alpha: 0.05),
        blurRadius: 20,
        offset: const Offset(0, 7),
      ),
    ],
  );
}
