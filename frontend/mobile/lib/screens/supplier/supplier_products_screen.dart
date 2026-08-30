import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_constants.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../providers/supplier_product_provider.dart';
import 'add_supplier_product_screen.dart';

class SupplierProductsScreen extends StatefulWidget {
  const SupplierProductsScreen({
    super.key,
  });

  @override
  State<SupplierProductsScreen> createState() =>
      _SupplierProductsScreenState();
}

class _SupplierProductsScreenState
    extends State<SupplierProductsScreen> {
  static const Color _primary =
      Color(0xFF2F6B3D);

  static const Color _darkGreen =
      Color(0xFF173F24);

  static const Color _lightGreen =
      Color(0xFFEAF3E7);

  static const Color _background =
      Color(0xFFF7F9F4);

  static const Color _text =
      Color(0xFF1D2A20);

  static const Color _muted =
      Color(0xFF6D786F);

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback(
      (_) {
        if (!mounted) {
          return;
        }

        _loadProducts();
      },
    );
  }

  Future<void> _loadProducts() async {
    final provider =
        Provider.of<SupplierProductProvider>(
      context,
      listen: false,
    );

    await provider.loadMySupplierProducts();
  }

  String _firstNonEmpty(
    List<dynamic> values,
  ) {
    for (final value in values) {
      final text =
          value?.toString().trim() ?? '';

      if (text.isNotEmpty) {
        return text;
      }
    }

    return '';
  }

  String _localizedProductName(
    BuildContext context,
    dynamic product,
  ) {
    final languageCode =
        Localizations.localeOf(
      context,
    ).languageCode;

    if (languageCode == 'ar') {
      return _firstNonEmpty(
        [
          product['nameAr'],
          product['name'],
          product['nameEn'],
        ],
      );
    }

    return _firstNonEmpty(
      [
        product['nameEn'],
        product['name'],
        product['nameAr'],
      ],
    );
  }

  String _localizedDescription(
    BuildContext context,
    dynamic product,
  ) {
    final languageCode =
        Localizations.localeOf(
      context,
    ).languageCode;

    if (languageCode == 'ar') {
      return _firstNonEmpty(
        [
          product['descriptionAr'],
          product['description'],
          product['descriptionEn'],
        ],
      );
    }

    return _firstNonEmpty(
      [
        product['descriptionEn'],
        product['description'],
        product['descriptionAr'],
      ],
    );
  }

  String _localizedCategoryName(
    BuildContext context,
    dynamic product,
  ) {
    final category =
        product['category'];

    if (category is! Map) {
      return '-';
    }

    final languageCode =
        Localizations.localeOf(
      context,
    ).languageCode;

    if (languageCode == 'ar') {
      return _firstNonEmpty(
        [
          category['nameAr'],
          category['name'],
          category['nameEn'],
        ],
      );
    }

    return _firstNonEmpty(
      [
        category['nameEn'],
        category['name'],
        category['nameAr'],
      ],
    );
  }

  String _statusLabel(
    AppLocalizations l10n,
    dynamic status,
  ) {
    switch (
        status?.toString().toUpperCase()) {
      case 'AVAILABLE':
        return l10n.available;

      case 'OUT_OF_STOCK':
        return l10n.outOfStock;

      case 'HIDDEN':
        return l10n.hidden;

      default:
        return status?.toString() ??
            l10n.unknown;
    }
  }

  Color _statusColor(
    dynamic status,
  ) {
    switch (
        status?.toString().toUpperCase()) {
      case 'AVAILABLE':
        return const Color(
          0xFF2F6B3D,
        );

      case 'OUT_OF_STOCK':
        return const Color(
          0xFFB26A00,
        );

      case 'HIDDEN':
        return const Color(
          0xFF68716A,
        );

      default:
        return const Color(
          0xFF68716A,
        );
    }
  }

  Color _statusBackground(
    dynamic status,
  ) {
    switch (
        status?.toString().toUpperCase()) {
      case 'AVAILABLE':
        return const Color(
          0xFFE7F4E6,
        );

      case 'OUT_OF_STOCK':
        return const Color(
          0xFFFFF2D9,
        );

      case 'HIDDEN':
        return const Color(
          0xFFEEF0EE,
        );

      default:
        return const Color(
          0xFFEEF0EE,
        );
    }
  }

  String _priceText(
    dynamic value,
  ) {
    final number =
        double.tryParse(
      value?.toString() ?? '',
    );

    if (number == null) {
      return value?.toString() ?? '0';
    }

    if (number ==
        number.truncateToDouble()) {
      return number
          .toStringAsFixed(0);
    }

    return number.toStringAsFixed(2);
  }

  String _quantityText(
    dynamic value,
  ) {
    if (value == null) {
      return '0';
    }

    return value.toString();
  }

  Future<void> _openAddProduct() async {
    final result =
        await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) =>
            const AddSupplierProductScreen(),
      ),
    );

    if (!mounted) {
      return;
    }

    if (result == true) {
      await _loadProducts();
    }
  }

  Future<void> _openEditProduct(
    Map<String, dynamic> product,
  ) async {
    final result =
        await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) =>
            AddSupplierProductScreen(
          product: product,
        ),
      ),
    );

    if (!mounted) {
      return;
    }

    if (result == true) {
      await _loadProducts();
    }
  }

  Future<void> _confirmDelete(
    Map<String, dynamic> product,
  ) async {
    final l10n =
        AppLocalizations.of(
      context,
    )!;

    final productName =
        _localizedProductName(
      context,
      product,
    );

    final confirmed =
        await showDialog<bool>(
      context: context,
      builder: (
        dialogContext,
      ) {
        return AlertDialog(
          backgroundColor:
              Colors.white,
          shape:
              RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(
              20,
            ),
          ),
          title: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration:
                    BoxDecoration(
                  color:
                      const Color(
                    0xFFFFECEA,
                  ),
                  borderRadius:
                      BorderRadius
                          .circular(
                    12,
                  ),
                ),
                child: const Icon(
                  Icons
                      .delete_outline_rounded,
                  color:
                      Color(
                    0xFFC8433A,
                  ),
                ),
              ),
              const SizedBox(
                width: 12,
              ),
              Expanded(
                child: Text(
                  l10n.deleteProduct,
                  style:
                      const TextStyle(
                    fontWeight:
                        FontWeight.w800,
                    color: _text,
                  ),
                ),
              ),
            ],
          ),
          content: Text(
            l10n.deleteProductConfirmation(
              productName.isEmpty
                  ? l10n.unnamedProduct
                  : productName,
            ),
            style:
                const TextStyle(
              color: _muted,
              height: 1.45,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(
                  dialogContext,
                ).pop(
                  false,
                );
              },
              child: Text(
                l10n.cancel,
              ),
            ),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.of(
                  dialogContext,
                ).pop(
                  true,
                );
              },
              icon: const Icon(
                Icons
                    .delete_outline_rounded,
                size: 19,
              ),
              label: Text(
                l10n.delete,
              ),
              style:
                  ElevatedButton.styleFrom(
                backgroundColor:
                    const Color(
                  0xFFC8433A,
                ),
                foregroundColor:
                    Colors.white,
                elevation: 0,
              ),
            ),
          ],
        );
      },
    );

    if (confirmed != true ||
        !mounted) {
      return;
    }

    final productId =
        product['id']?.toString();

    if (productId == null ||
        productId.trim().isEmpty) {
      _showMessage(
        l10n.supplierProductIdNotFound,
        isError: true,
      );

      return;
    }

    final provider =
        Provider.of<SupplierProductProvider>(
      context,
      listen: false,
    );

    final success =
        await provider.deleteSupplierProduct(
      productId,
    );

    if (!mounted) {
      return;
    }

    if (success) {
      _showMessage(
        l10n.productDeletedSuccessfully,
      );

      return;
    }

    _showMessage(
      provider.errorMessage ??
          l10n.failedToDeleteProduct(
            l10n.unknown,
          ),
      isError: true,
    );
  }

  void _showMessage(
    String message, {
    bool isError = false,
  }) {
    final messenger =
        ScaffoldMessenger.of(
      context,
    );

    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            message,
          ),
          behavior:
              SnackBarBehavior.floating,
          backgroundColor:
              isError
                  ? Colors.red.shade700
                  : _darkGreen,
        ),
      );
  }

  @override
  Widget build(
    BuildContext context,
  ) {
    final l10n =
        AppLocalizations.of(
      context,
    )!;

    return Scaffold(
      backgroundColor:
          _background,
      appBar: AppBar(
        backgroundColor:
            Colors.white,
        surfaceTintColor:
            Colors.white,
        elevation: 0,
        foregroundColor:
            _darkGreen,
        title: Text(
          l10n.mySupplierProducts,
          style:
              const TextStyle(
            fontWeight:
                FontWeight.w800,
          ),
        ),
        actions: [
          IconButton(
            tooltip: l10n.refresh,
            onPressed:
                _loadProducts,
            icon: const Icon(
              Icons.refresh_rounded,
            ),
          ),
          const SizedBox(
            width: 6,
          ),
        ],
      ),
      floatingActionButton:
          FloatingActionButton.extended(
        onPressed:
            _openAddProduct,
        backgroundColor:
            _primary,
        foregroundColor:
            Colors.white,
        icon: const Icon(
          Icons.add_rounded,
        ),
        label: Text(
          l10n.addSupplierProduct,
          style:
              const TextStyle(
            fontWeight:
                FontWeight.w700,
          ),
        ),
      ),
      body:
          SafeArea(
        child:
            RefreshIndicator(
          color: _primary,
          onRefresh:
              _loadProducts,
          child: Consumer<
              SupplierProductProvider>(
            builder: (
              context,
              provider,
              child,
            ) {
              if (provider.isLoading &&
                  provider.supplierProducts
                      .isEmpty) {
                return const Center(
                  child:
                      CircularProgressIndicator(
                    color: _primary,
                  ),
                );
              }

              if (provider.errorMessage !=
                      null &&
                  provider.supplierProducts
                      .isEmpty) {
                return _buildErrorState(
                  l10n,
                  provider.errorMessage!,
                );
              }

              if (provider.supplierProducts
                  .isEmpty) {
                return _buildEmptyState(
                  l10n,
                );
              }

              return _buildProductsContent(
                l10n,
                provider.supplierProducts,
                provider.isLoading,
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildProductsContent(
    AppLocalizations l10n,
    List products,
    bool isRefreshing,
  ) {
    return LayoutBuilder(
      builder: (
        context,
        constraints,
      ) {
        final width =
            constraints.maxWidth;

        int columns = 1;

        if (width >= 1200) {
          columns = 3;
        } else if (width >= 760) {
          columns = 2;
        }

        final horizontalPadding =
            width >= 1000
                ? 28.0
                : 16.0;

        return CustomScrollView(
          physics:
              const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverPadding(
              padding:
                  EdgeInsets.fromLTRB(
                horizontalPadding,
                20,
                horizontalPadding,
                0,
              ),
              sliver:
                  SliverToBoxAdapter(
                child:
                    _buildHeaderCard(
                  l10n,
                  products.length,
                  isRefreshing,
                ),
              ),
            ),
            SliverPadding(
              padding:
                  EdgeInsets.fromLTRB(
                horizontalPadding,
                18,
                horizontalPadding,
                110,
              ),
              sliver:
                  SliverGrid(
                delegate:
                    SliverChildBuilderDelegate(
                  (
                    context,
                    index,
                  ) {
                    final rawProduct =
                        products[index];

                    if (rawProduct
                        is! Map) {
                      return const SizedBox
                          .shrink();
                    }

                    final product =
                        Map<String,
                                dynamic>.from(
                      rawProduct,
                    );

                    return _buildProductCard(
                      l10n,
                      product,
                    );
                  },
                  childCount:
                      products.length,
                ),
                gridDelegate:
                    SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount:
                      columns,
                  crossAxisSpacing:
                      16,
                  mainAxisSpacing:
                      16,
                  mainAxisExtent:
                      530,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildHeaderCard(
    AppLocalizations l10n,
    int productCount,
    bool isRefreshing,
  ) {
    return Container(
      padding:
          const EdgeInsets.all(
        22,
      ),
      decoration:
          BoxDecoration(
        gradient:
            const LinearGradient(
          colors: [
            Color(
              0xFF173F24,
            ),
            Color(
              0xFF2F6B3D,
            ),
          ],
          begin:
              Alignment.topLeft,
          end:
              Alignment.bottomRight,
        ),
        borderRadius:
            BorderRadius.circular(
          24,
        ),
        boxShadow: const [
          BoxShadow(
            color:
                Color(
              0x18000000,
            ),
            blurRadius: 20,
            offset:
                Offset(
              0,
              8,
            ),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration:
                BoxDecoration(
              color:
                  Colors.white
                      .withValues(
                alpha: 0.14,
              ),
              borderRadius:
                  BorderRadius.circular(
                18,
              ),
            ),
            child: const Icon(
              Icons
                  .inventory_2_outlined,
              color: Colors.white,
              size: 31,
            ),
          ),
          const SizedBox(
            width: 16,
          ),
          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment
                      .start,
              children: [
                Text(
                  l10n.mySupplierProducts,
                  style:
                      const TextStyle(
                    color:
                        Colors.white,
                    fontSize: 23,
                    fontWeight:
                        FontWeight.w800,
                  ),
                ),
                const SizedBox(
                  height: 5,
                ),
                Text(
                  l10n
                      .manageSupplierProducts,
                  style:
                      TextStyle(
                    color:
                        Colors.white
                            .withValues(
                      alpha: 0.82,
                    ),
                    fontSize: 13,
                    height: 1.4,
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                Container(
                  padding:
                      const EdgeInsets
                          .symmetric(
                    horizontal: 11,
                    vertical: 6,
                  ),
                  decoration:
                      BoxDecoration(
                    color:
                        Colors.white
                            .withValues(
                      alpha: 0.13,
                    ),
                    borderRadius:
                        BorderRadius
                            .circular(
                      20,
                    ),
                  ),
                  child: Text(
                    l10n.productsCount(
                      productCount,
                    ),
                    style:
                        const TextStyle(
                      color:
                          Colors.white,
                      fontSize: 12,
                      fontWeight:
                          FontWeight
                              .w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (isRefreshing)
            const Padding(
              padding:
                  EdgeInsets.only(
                left: 12,
              ),
              child: SizedBox(
                width: 22,
                height: 22,
                child:
                    CircularProgressIndicator(
                  strokeWidth: 2.2,
                  color:
                      Colors.white,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildProductCard(
    AppLocalizations l10n,
    Map<String, dynamic> product,
  ) {
    final name =
        _localizedProductName(
      context,
      product,
    );

    final description =
        _localizedDescription(
      context,
      product,
    );

    final category =
        _localizedCategoryName(
      context,
      product,
    );

    final rawImageUrl =
        product['imageUrl']
            ?.toString()
            .trim();

    final imageUrl =
        rawImageUrl == null ||
                rawImageUrl.isEmpty
            ? null
            : AppConstants.getImageUrl(
                rawImageUrl,
              );

    final status =
        product['status'];

    final price =
        _priceText(
      product['price'],
    );

    final quantity =
        _quantityText(
      product['quantity'],
    );

    final unit =
        product['unit']
                ?.toString()
                .trim() ??
            '';

    return Container(
      decoration:
          BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(
          22,
        ),
        border: Border.all(
          color:
              const Color(
            0xFFE1E8DE,
          ),
        ),
        boxShadow: const [
          BoxShadow(
            color:
                Color(
              0x0A000000,
            ),
            blurRadius: 16,
            offset:
                Offset(
              0,
              6,
            ),
          ),
        ],
      ),
      clipBehavior:
          Clip.antiAlias,
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment
                .stretch,
        children: [
          Stack(
            children: [
              SizedBox(
                height: 190,
                width:
                    double.infinity,
                child:
                    _buildProductImage(
                  imageUrl,
                ),
              ),
              PositionedDirectional(
                top: 12,
                start: 12,
                child:
                    _buildStatusBadge(
                  l10n,
                  status,
                ),
              ),
              PositionedDirectional(
                top: 10,
                end: 10,
                child: Material(
                  color:
                      Colors.white
                          .withValues(
                    alpha: 0.94,
                  ),
                  borderRadius:
                      BorderRadius
                          .circular(
                    12,
                  ),
                  child:
                      PopupMenuButton<
                          String>(
                    tooltip:
                        l10n.settings,
                    icon:
                        const Icon(
                      Icons
                          .more_vert_rounded,
                      color:
                          _darkGreen,
                    ),
                    onSelected:
                        (
                      value,
                    ) {
                      if (value ==
                          'edit') {
                        _openEditProduct(
                          product,
                        );
                      } else if (value ==
                          'delete') {
                        _confirmDelete(
                          product,
                        );
                      }
                    },
                    itemBuilder:
                        (
                      context,
                    ) =>
                            [
                      PopupMenuItem<
                          String>(
                        value:
                            'edit',
                        child: Row(
                          children: [
                            const Icon(
                              Icons
                                  .edit_outlined,
                              size: 20,
                              color:
                                  _primary,
                            ),
                            const SizedBox(
                              width:
                                  10,
                            ),
                            Text(
                              l10n
                                  .editProduct,
                            ),
                          ],
                        ),
                      ),
                      PopupMenuItem<
                          String>(
                        value:
                            'delete',
                        child: Row(
                          children: [
                            const Icon(
                              Icons
                                  .delete_outline_rounded,
                              size: 20,
                              color:
                                  Color(
                                0xFFC8433A,
                              ),
                            ),
                            const SizedBox(
                              width:
                                  10,
                            ),
                            Text(
                              l10n
                                  .deleteProduct,
                              style:
                                  const TextStyle(
                                color:
                                    Color(
                                  0xFFC8433A,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          Expanded(
            child: Padding(
              padding:
                  const EdgeInsets.all(
                18,
              ),
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment
                        .start,
                children: [
                  Text(
                    name.isEmpty
                        ? l10n
                            .unnamedProduct
                        : name,
                    maxLines: 1,
                    overflow:
                        TextOverflow
                            .ellipsis,
                    style:
                        const TextStyle(
                      color: _text,
                      fontSize: 19,
                      fontWeight:
                          FontWeight
                              .w800,
                    ),
                  ),
                  const SizedBox(
                    height: 7,
                  ),
                  Row(
                    children: [
                      const Icon(
                        Icons
                            .category_outlined,
                        size: 17,
                        color:
                            _primary,
                      ),
                      const SizedBox(
                        width: 6,
                      ),
                      Expanded(
                        child: Text(
                          category.isEmpty
                              ? '-'
                              : category,
                          maxLines: 1,
                          overflow:
                              TextOverflow
                                  .ellipsis,
                          style:
                              const TextStyle(
                            color:
                                _muted,
                            fontSize:
                                12.5,
                            fontWeight:
                                FontWeight
                                    .w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 11,
                  ),
                  Text(
                    description.isEmpty
                        ? l10n
                            .supplierProductNoDescription
                        : description,
                    maxLines: 2,
                    overflow:
                        TextOverflow
                            .ellipsis,
                    style:
                        const TextStyle(
                      color: _muted,
                      fontSize: 13,
                      height: 1.45,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding:
                        const EdgeInsets
                            .all(
                      13,
                    ),
                    decoration:
                        BoxDecoration(
                      color:
                          const Color(
                        0xFFF5F8F2,
                      ),
                      borderRadius:
                          BorderRadius
                              .circular(
                        14,
                      ),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child:
                              _InfoItem(
                            icon: Icons
                                .payments_outlined,
                            label:
                                l10n.price,
                            value:
                                price,
                          ),
                        ),
                        Container(
                          width: 1,
                          height: 38,
                          color:
                              const Color(
                            0xFFDDE5D9,
                          ),
                        ),
                        Expanded(
                          child:
                              _InfoItem(
                            icon: Icons
                                .inventory_outlined,
                            label:
                                l10n.quantity,
                            value:
                                unit.isEmpty
                                    ? quantity
                                    : '$quantity $unit',
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(
                    height: 14,
                  ),
                  Row(
                    children: [
                      Expanded(
                        child:
                            OutlinedButton.icon(
                          onPressed: () {
                            _openEditProduct(
                              product,
                            );
                          },
                          icon:
                              const Icon(
                            Icons
                                .edit_outlined,
                            size: 18,
                          ),
                          label: Text(
                            l10n
                                .editProduct,
                          ),
                          style:
                              OutlinedButton
                                  .styleFrom(
                            foregroundColor:
                                _primary,
                            side:
                                const BorderSide(
                              color:
                                  _primary,
                            ),
                            minimumSize:
                                const Size(
                              0,
                              46,
                            ),
                            shape:
                                RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius
                                      .circular(
                                12,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                      SizedBox(
                        width: 48,
                        height: 46,
                        child:
                            OutlinedButton(
                          onPressed: () {
                            _confirmDelete(
                              product,
                            );
                          },
                          style:
                              OutlinedButton
                                  .styleFrom(
                            padding:
                                EdgeInsets
                                    .zero,
                            foregroundColor:
                                const Color(
                              0xFFC8433A,
                            ),
                            side:
                                const BorderSide(
                              color:
                                  Color(
                                0xFFE6B8B4,
                              ),
                            ),
                            shape:
                                RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius
                                      .circular(
                                12,
                              ),
                            ),
                          ),
                          child:
                              const Icon(
                            Icons
                                .delete_outline_rounded,
                            size: 20,
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

  Widget _buildProductImage(
    String? imageUrl,
  ) {
    if (imageUrl == null ||
        imageUrl.isEmpty) {
      return Container(
        color:
            const Color(
          0xFFEAF3E7,
        ),
        child: const Center(
          child: Icon(
            Icons
                .inventory_2_outlined,
            size: 62,
            color: _primary,
          ),
        ),
      );
    }

    return Image.network(
      imageUrl,
      fit: BoxFit.contain,
      errorBuilder: (
        context,
        error,
        stackTrace,
      ) {
        return Container(
          color:
              const Color(
            0xFFEAF3E7,
          ),
          child: const Center(
            child: Icon(
              Icons
                  .broken_image_outlined,
              size: 52,
              color: _muted,
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatusBadge(
    AppLocalizations l10n,
    dynamic status,
  ) {
    return Container(
      padding:
          const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 6,
      ),
      decoration:
          BoxDecoration(
        color:
            _statusBackground(
          status,
        ),
        borderRadius:
            BorderRadius.circular(
          20,
        ),
      ),
      child: Row(
        mainAxisSize:
            MainAxisSize.min,
        children: [
          Container(
            width: 7,
            height: 7,
            decoration:
                BoxDecoration(
              color:
                  _statusColor(
                status,
              ),
              shape:
                  BoxShape.circle,
            ),
          ),
          const SizedBox(
            width: 6,
          ),
          Text(
            _statusLabel(
              l10n,
              status,
            ),
            style:
                TextStyle(
              color:
                  _statusColor(
                status,
              ),
              fontSize: 11.5,
              fontWeight:
                  FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(
    AppLocalizations l10n,
  ) {
    return ListView(
      physics:
          const AlwaysScrollableScrollPhysics(),
      padding:
          const EdgeInsets.all(
        24,
      ),
      children: [
        const SizedBox(
          height: 80,
        ),
        Center(
          child:
              ConstrainedBox(
            constraints:
                const BoxConstraints(
              maxWidth: 480,
            ),
            child: Container(
              padding:
                  const EdgeInsets
                      .all(
                30,
              ),
              decoration:
                  BoxDecoration(
                color:
                    Colors.white,
                borderRadius:
                    BorderRadius
                        .circular(
                  24,
                ),
                border:
                    Border.all(
                  color:
                      const Color(
                    0xFFE1E8DE,
                  ),
                ),
              ),
              child: Column(
                children: [
                  Container(
                    width: 84,
                    height: 84,
                    decoration:
                        BoxDecoration(
                      color:
                          _lightGreen,
                      borderRadius:
                          BorderRadius
                              .circular(
                        24,
                      ),
                    ),
                    child:
                        const Icon(
                      Icons
                          .inventory_2_outlined,
                      size: 42,
                      color:
                          _primary,
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Text(
                    l10n
                        .noSupplierProductsFound,
                    textAlign:
                        TextAlign.center,
                    style:
                        const TextStyle(
                      color: _text,
                      fontSize: 20,
                      fontWeight:
                          FontWeight
                              .w800,
                    ),
                  ),
                  const SizedBox(
                    height: 8,
                  ),
                  Text(
                    l10n
                        .createFirstSupplierProduct,
                    textAlign:
                        TextAlign.center,
                    style:
                        const TextStyle(
                      color:
                          _muted,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(
                    height: 22,
                  ),
                  ElevatedButton.icon(
                    onPressed:
                        _openAddProduct,
                    icon:
                        const Icon(
                      Icons.add_rounded,
                    ),
                    label: Text(
                      l10n
                          .addSupplierProduct,
                    ),
                    style:
                        ElevatedButton
                            .styleFrom(
                      backgroundColor:
                          _primary,
                      foregroundColor:
                          Colors.white,
                      elevation: 0,
                      minimumSize:
                          const Size(
                        190,
                        50,
                      ),
                      shape:
                          RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius
                                .circular(
                          14,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildErrorState(
    AppLocalizations l10n,
    String message,
  ) {
    return ListView(
      physics:
          const AlwaysScrollableScrollPhysics(),
      padding:
          const EdgeInsets.all(
        24,
      ),
      children: [
        const SizedBox(
          height: 90,
        ),
        Center(
          child:
              ConstrainedBox(
            constraints:
                const BoxConstraints(
              maxWidth: 480,
            ),
            child: Container(
              padding:
                  const EdgeInsets
                      .all(
                28,
              ),
              decoration:
                  BoxDecoration(
                color:
                    Colors.white,
                borderRadius:
                    BorderRadius
                        .circular(
                  22,
                ),
                border:
                    Border.all(
                  color:
                      const Color(
                    0xFFE1E8DE,
                  ),
                ),
              ),
              child: Column(
                children: [
                  const Icon(
                    Icons
                        .error_outline_rounded,
                    size: 50,
                    color:
                        Color(
                      0xFFC8433A,
                    ),
                  ),
                  const SizedBox(
                    height: 16,
                  ),
                  Text(
                    message,
                    textAlign:
                        TextAlign.center,
                    style:
                        const TextStyle(
                      color:
                          _muted,
                      height: 1.45,
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  ElevatedButton.icon(
                    onPressed:
                        _loadProducts,
                    icon:
                        const Icon(
                      Icons
                          .refresh_rounded,
                    ),
                    label: Text(
                      l10n.tryAgain,
                    ),
                    style:
                        ElevatedButton
                            .styleFrom(
                      backgroundColor:
                          _primary,
                      foregroundColor:
                          Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _InfoItem
    extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoItem({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    return Padding(
      padding:
          const EdgeInsets.symmetric(
        horizontal: 8,
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                size: 15,
                color:
                    const Color(
                  0xFF2F6B3D,
                ),
              ),
              const SizedBox(
                width: 5,
              ),
              Expanded(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow:
                      TextOverflow
                          .ellipsis,
                  style:
                      const TextStyle(
                    color:
                        Color(
                      0xFF6D786F,
                    ),
                    fontSize: 10.5,
                    fontWeight:
                        FontWeight
                            .w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(
            height: 4,
          ),
          Text(
            value,
            maxLines: 1,
            overflow:
                TextOverflow.ellipsis,
            style:
                const TextStyle(
              color:
                  Color(
                0xFF1D2A20,
              ),
              fontSize: 13,
              fontWeight:
                  FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}