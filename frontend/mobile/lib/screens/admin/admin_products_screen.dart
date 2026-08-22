import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_constants.dart';
import '../../providers/product_provider.dart';
import '../../providers/locale_provider.dart';

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
              title: Text(
                _isArabic
                    ? 'تغيير حالة المنتج'
                    : 'Change Product Status',
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
                        InputDecoration(
                      labelText:
                          _isArabic ? 'الحالة' : 'Status',
                      border:
                          const OutlineInputBorder(),
                    ),
                    items: [
                      DropdownMenuItem(
                        value: 'AVAILABLE',
                        child: Text(
                          _isArabic ? 'متاح' : 'Available',
                        ),
                      ),
                      DropdownMenuItem(
                        value: 'OUT_OF_STOCK',
                        child: Text(
                          _isArabic
                              ? 'نفد من المخزون'
                              : 'Out of Stock',
                        ),
                      ),
                      DropdownMenuItem(
                        value: 'HIDDEN',
                        child: Text(
                          _isArabic ? 'مخفي' : 'Hidden',
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
                  child: Text(
                    _isArabic ? 'إلغاء' : 'Cancel',
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
                        const Color(0xFF2F743F),
                    foregroundColor:
                        Colors.white,
                  ),
                  child: Text(
                    _isArabic ? 'حفظ' : 'Save',
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
                ? (_isArabic
                    ? 'تم إخفاء المنتج بنجاح'
                    : 'Product hidden successfully')
                : newStatus == 'AVAILABLE'
                    ? (_isArabic
                        ? 'المنتج متاح الآن'
                        : 'Product is now available')
                    : (_isArabic
                        ? 'تم تحديد المنتج كنافد من المخزون'
                        : 'Product marked as out of stock'),
          ),
          backgroundColor: const Color(0xFF2F743F),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
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
              (_isArabic
                  ? 'فشل تحديث حالة المنتج'
                  : 'Failed to update product status'),
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
        return _isArabic ? 'متاح' : 'AVAILABLE';
      case 'OUT_OF_STOCK':
        return _isArabic
            ? 'نفد من المخزون'
            : 'OUT OF STOCK';
      case 'HIDDEN':
        return _isArabic ? 'مخفي' : 'HIDDEN';
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

    final allProducts =
        productProvider.adminProducts;

    final filteredProducts =
        _filteredProducts(
      allProducts,
    );

    int countByStatus(
      String status,
    ) {
      return allProducts.where(
        (rawProduct) {
          if (rawProduct is! Map) {
            return false;
          }

          return rawProduct['status']
                  ?.toString()
                  .toUpperCase() ==
              status;
        },
      ).length;
    }

    return Scaffold(
      backgroundColor:
          const Color(0xFFF8FAF4),
      body: Stack(
        children: [
          const Positioned.fill(
            child:
                _AdminProductsBackdrop(),
          ),
          Column(
            children: [
              _AdminProductsTopBar(
                isArabic: _isArabic,
                onChangeLanguage: _changeLanguage,
                onBack: () =>
                    Navigator.pop(context),
                onRefresh:
                    productProvider.isLoading
                        ? null
                        : _loadProducts,
              ),
              Expanded(
                child: RefreshIndicator(
                  onRefresh:
                      _loadProducts,
                  color:
                      _adminProductsPrimary,
                  child:
                      CustomScrollView(
                    physics:
                        const AlwaysScrollableScrollPhysics(),
                    slivers: [
                      SliverToBoxAdapter(
                        child: Center(
                          child:
                              ConstrainedBox(
                            constraints:
                                const BoxConstraints(
                              maxWidth:
                                  1320,
                            ),
                            child:
                                Padding(
                              padding:
                                  const EdgeInsets
                                      .fromLTRB(
                                24,
                                26,
                                24,
                                16,
                              ),
                              child:
                                  _AdminProductsHero(
                                isArabic: _isArabic,
                                totalCount:
                                    allProducts
                                        .length,
                                availableCount:
                                    countByStatus(
                                  'AVAILABLE',
                                ),
                                outOfStockCount:
                                    countByStatus(
                                  'OUT_OF_STOCK',
                                ),
                                hiddenCount:
                                    countByStatus(
                                  'HIDDEN',
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      SliverToBoxAdapter(
                        child: Center(
                          child:
                              ConstrainedBox(
                            constraints:
                                const BoxConstraints(
                              maxWidth:
                                  1320,
                            ),
                            child:
                                Padding(
                              padding:
                                  const EdgeInsets
                                      .fromLTRB(
                                24,
                                0,
                                24,
                                18,
                              ),
                              child:
                                  _AdminProductsFilter(
                                isArabic: _isArabic,
                                selectedStatus:
                                    _selectedStatus,
                                onSelected:
                                    (status) {
                                  setState(
                                    () {
                                      _selectedStatus =
                                          status;
                                    },
                                  );
                                },
                              ),
                            ),
                          ),
                        ),
                      ),
                      if (productProvider
                              .isLoading &&
                          allProducts.isEmpty)
                        const SliverFillRemaining(
                          hasScrollBody:
                              false,
                          child: Center(
                            child:
                                CircularProgressIndicator(
                              color:
                                  _adminProductsPrimary,
                            ),
                          ),
                        )
                      else if (productProvider
                                  .errorMessage !=
                              null &&
                          allProducts.isEmpty)
                        SliverFillRemaining(
                          hasScrollBody:
                              false,
                          child:
                              _AdminProductsErrorState(
                            isArabic: _isArabic,
                            message:
                                productProvider
                                        .errorMessage ??
                                    (_isArabic
                                        ? 'فشل تحميل المنتجات'
                                        : 'Failed to load products'),
                            onRetry:
                                _loadProducts,
                          ),
                        )
                      else if (filteredProducts
                          .isEmpty)
                        SliverFillRemaining(
                          hasScrollBody:
                              false,
                          child:
                              _AdminProductsEmptyState(
                            isArabic: _isArabic,
                            selectedStatus:
                                _selectedStatus,
                          ),
                        )
                      else
                        SliverPadding(
                          padding:
                              const EdgeInsets
                                  .fromLTRB(
                            24,
                            0,
                            24,
                            42,
                          ),
                          sliver:
                              SliverLayoutBuilder(
                            builder: (
                              context,
                              constraints,
                            ) {
                              final width =
                                  constraints
                                      .crossAxisExtent;

                              final crossAxisCount =
                                  width >= 1180
                                      ? 3
                                      : width >= 760
                                          ? 2
                                          : 1;

                              return SliverGrid(
                                delegate:
                                    SliverChildBuilderDelegate(
                                  (
                                    context,
                                    index,
                                  ) {
                                    final product =
                                        Map<String,
                                                dynamic>.from(
                                      filteredProducts[
                                          index] as Map,
                                    );

                                    return _AdminProductCard(
                                      isArabic: _isArabic,
                                      product:
                                          product,
                                      imageUrl:
                                          _getImageUrl(
                                        product[
                                            'imageUrl'],
                                      ),
                                      statusColor:
                                          _statusColor,
                                      statusLabel:
                                          _statusLabel,
                                      onChangeStatus:
                                          ({
                                        required String
                                            productId,
                                        required String
                                            productName,
                                        required String
                                            currentStatus,
                                      }) {
                                        _changeStatus(
                                          productId:
                                              productId,
                                          productName:
                                              productName,
                                          currentStatus:
                                              currentStatus,
                                        );
                                      },
                                    );
                                  },
                                  childCount:
                                      filteredProducts
                                          .length,
                                ),
                                gridDelegate:
                                    SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount:
                                      crossAxisCount,
                                  crossAxisSpacing:
                                      16,
                                  mainAxisSpacing:
                                      16,
                                  mainAxisExtent:
                                      485,
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
          if (productProvider.isLoading &&
              allProducts.isNotEmpty)
            const Positioned(
              top: 0,
              left: 0,
              right: 0,
              child:
                  LinearProgressIndicator(
                color:
                    _adminProductsPrimary,
              ),
            ),
        ],
      ),
    );
  }
}

const _adminProductsDark =
    Color(0xFF173F24);
const _adminProductsPrimary =
    Color(0xFF2F743F);
const _adminProductsLight =
    Color(0xFFEAF3DF);
const _adminProductsText =
    Color(0xFF1D2C21);
const _adminProductsMuted =
    Color(0xFF6C786E);

class _AdminProductsTopBar
    extends StatelessWidget {
  final bool isArabic;
  final ValueChanged<String> onChangeLanguage;
  final VoidCallback onBack;
  final Future<void> Function()?
      onRefresh;

  const _AdminProductsTopBar({
    required this.isArabic,
    required this.onChangeLanguage,
    required this.onBack,
    required this.onRefresh,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    return Container(
      decoration:
          const BoxDecoration(
        gradient:
            LinearGradient(
          colors: [
            Color(
              0xFF123A22,
            ),
            Color(
              0xFF205A34,
            ),
            Color(
              0xFF2E6F40,
            ),
          ],
        ),
      ),
      padding:
          const EdgeInsets
              .fromLTRB(
        18,
        12,
        18,
        14,
      ),
      child: SafeArea(
        bottom: false,
        child: Row(
          children: [
            _AdminProductsHeaderButton(
              icon: Icons
                  .arrow_back_rounded,
              tooltip:
                  isArabic ? 'رجوع' : 'Back',
              onTap:
                  onBack,
            ),
            const SizedBox(
              width: 12,
            ),
            Container(
              width: 44,
              height: 44,
              decoration:
                  BoxDecoration(
                color:
                    const Color(
                  0xFFDDECB8,
                ),
                borderRadius:
                    BorderRadius
                        .circular(
                  13,
                ),
              ),
              child:
                  const Icon(
                Icons.eco_rounded,
                color:
                    _adminProductsDark,
              ),
            ),
            const SizedBox(
              width: 10,
            ),
            Expanded(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment
                        .start,
                children: [
                  const Text(
                    'FarmPilot',
                    style:
                        TextStyle(
                      color:
                          Colors.white,
                      fontSize:
                          19,
                      fontWeight:
                          FontWeight
                              .w800,
                    ),
                  ),
                  Text(
                    isArabic
                        ? 'إدارة المنتجات'
                        : 'Manage Products',
                    style:
                        const TextStyle(
                      color:
                          Color(
                        0xCCFFFFFF,
                      ),
                      fontSize:
                          12,
                    ),
                  ),
                ],
              ),
            ),
            PopupMenuButton<String>(
              tooltip:
                  isArabic ? 'تغيير اللغة' : 'Change Language',
              color: Colors.white,
              onSelected: onChangeLanguage,
              icon: const Icon(
                Icons.language_rounded,
                color: Colors.white,
              ),
              itemBuilder: (context) {
                return [
                  PopupMenuItem<String>(
                    value: 'en',
                    child: Row(
                      children: [
                        Icon(
                          Icons.check_rounded,
                          color: !isArabic
                              ? _adminProductsPrimary
                              : Colors.transparent,
                        ),
                        const SizedBox(width: 8),
                        const Text('English'),
                      ],
                    ),
                  ),
                  PopupMenuItem<String>(
                    value: 'ar',
                    child: Row(
                      children: [
                        Icon(
                          Icons.check_rounded,
                          color: isArabic
                              ? _adminProductsPrimary
                              : Colors.transparent,
                        ),
                        const SizedBox(width: 8),
                        const Text('Arabic'),
                      ],
                    ),
                  ),
                ];
              },
            ),
            _AdminProductsHeaderButton(
              icon: Icons.refresh_rounded,
              tooltip:
                  isArabic ? 'تحديث' : 'Refresh',
              onTap:
                  onRefresh,
            ),
          ],
        ),
      ),
    );
  }
}

class _AdminProductsHeaderButton
    extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback? onTap;

  const _AdminProductsHeaderButton({
    required this.icon,
    required this.tooltip,
    required this.onTap,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color:
            Colors.white
                .withValues(
          alpha:
              onTap == null
                  ? 0.05
                  : 0.10,
        ),
        borderRadius:
            BorderRadius
                .circular(
          14,
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius:
              BorderRadius
                  .circular(
            14,
          ),
          child: SizedBox(
            width: 44,
            height: 44,
            child: Icon(
              icon,
              size: 21,
              color:
                  onTap == null
                      ? Colors
                          .white54
                      : Colors
                          .white,
            ),
          ),
        ),
      ),
    );
  }
}

class _AdminProductsHero
    extends StatelessWidget {
  final bool isArabic;
  final int totalCount;
  final int availableCount;
  final int outOfStockCount;
  final int hiddenCount;

  const _AdminProductsHero({
    required this.isArabic,
    required this.totalCount,
    required this.availableCount,
    required this.outOfStockCount,
    required this.hiddenCount,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    return Container(
      width:
          double.infinity,
      padding:
          const EdgeInsets
              .all(
        24,
      ),
      decoration:
          _adminProductsCardDecoration(
        24,
      ),
      child: LayoutBuilder(
        builder: (
          context,
          constraints,
        ) {
          final heading =
              Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration:
                    BoxDecoration(
                  color:
                      _adminProductsLight,
                  borderRadius:
                      BorderRadius
                          .circular(
                    18,
                  ),
                ),
                child:
                    const Icon(
                  Icons
                      .inventory_2_outlined,
                  color:
                      _adminProductsPrimary,
                  size:
                      30,
                ),
              ),
              const SizedBox(
                width: 16,
              ),
              Expanded(
                child:
                    Column(
                  crossAxisAlignment:
                      CrossAxisAlignment
                          .start,
                  children: [
                    Text(
                      isArabic
                          ? 'إدارة المنتجات'
                          : 'Manage Products',
                      style:
                          const TextStyle(
                        color:
                            _adminProductsText,
                        fontSize:
                            24,
                        fontWeight:
                            FontWeight
                                .w800,
                      ),
                    ),
                    const SizedBox(
                      height: 4,
                    ),
                    Text(
                      isArabic
                          ? 'مراجعة منتجات المتجر والتحكم في ظهورها وتوفرها.'
                          : 'Review marketplace products and control their visibility and availability.',
                      style:
                          const TextStyle(
                        color:
                            _adminProductsMuted,
                        fontSize:
                            13,
                        height:
                            1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );

          final stats =
              Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _AdminProductsStatChip(
                label:
                    isArabic ? 'الإجمالي' : 'Total',
                value:
                    totalCount,
              ),
              _AdminProductsStatChip(
                label:
                    isArabic ? 'متاح' : 'Available',
                value:
                    availableCount,
              ),
              _AdminProductsStatChip(
                label:
                    isArabic ? 'نفد من المخزون' : 'Out of Stock',
                value:
                    outOfStockCount,
              ),
              _AdminProductsStatChip(
                label:
                    isArabic ? 'مخفي' : 'Hidden',
                value:
                    hiddenCount,
              ),
            ],
          );

          if (constraints
                  .maxWidth <
              820) {
            return Column(
              crossAxisAlignment:
                  CrossAxisAlignment
                      .start,
              children: [
                heading,
                const SizedBox(
                  height: 18,
                ),
                stats,
              ],
            );
          }

          return Row(
            children: [
              Expanded(
                child:
                    heading,
              ),
              const SizedBox(
                width: 18,
              ),
              stats,
            ],
          );
        },
      ),
    );
  }
}

class _AdminProductsStatChip
    extends StatelessWidget {
  final String label;
  final int value;

  const _AdminProductsStatChip({
    required this.label,
    required this.value,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    return Container(
      padding:
          const EdgeInsets
              .symmetric(
        horizontal:
            12,
        vertical:
            9,
      ),
      decoration:
          BoxDecoration(
        color:
            const Color(
          0xFFF1F6E9,
        ),
        borderRadius:
            BorderRadius
                .circular(
          14,
        ),
      ),
      child: Text(
        '$label $value',
        style:
            const TextStyle(
          color:
              _adminProductsPrimary,
          fontSize:
              11,
          fontWeight:
              FontWeight
                  .w700,
        ),
      ),
    );
  }
}

class _AdminProductsFilter
    extends StatelessWidget {
  final bool isArabic;
  final String selectedStatus;
  final ValueChanged<String>
      onSelected;

  const _AdminProductsFilter({
    required this.isArabic,
    required this.selectedStatus,
    required this.onSelected,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    const statuses = [
      'ALL',
      'AVAILABLE',
      'OUT_OF_STOCK',
      'HIDDEN',
    ];

    return SingleChildScrollView(
      scrollDirection:
          Axis.horizontal,
      child: Row(
        children:
            statuses.map(
          (status) {
            final selected =
                selectedStatus ==
                    status;

            final label = isArabic
                ? status == 'ALL'
                    ? 'جميع المنتجات'
                    : status == 'AVAILABLE'
                        ? 'متاح'
                        : status == 'OUT_OF_STOCK'
                            ? 'نفد من المخزون'
                            : status == 'HIDDEN'
                                ? 'مخفي'
                                : status
                : status == 'ALL'
                    ? 'All Products'
                    : status == 'OUT_OF_STOCK'
                        ? 'Out of Stock'
                        : _adminProductsTitleCase(
                            status,
                          );

            return Padding(
              padding:
                  const EdgeInsets
                      .only(
                right: 8,
              ),
              child:
                  ChoiceChip(
                label:
                    Text(
                  label,
                ),
                selected:
                    selected,
                onSelected:
                    (_) {
                  onSelected(
                    status,
                  );
                },
                selectedColor:
                    _adminProductsPrimary,
                backgroundColor:
                    Colors.white,
                labelStyle:
                    TextStyle(
                  color:
                      selected
                          ? Colors
                              .white
                          : _adminProductsText,
                  fontWeight:
                      FontWeight
                          .w700,
                  fontSize:
                      12,
                ),
                side:
                    BorderSide(
                  color:
                      selected
                          ? _adminProductsPrimary
                          : const Color(
                              0xFFD8E2D4,
                            ),
                ),
                padding:
                    const EdgeInsets
                        .symmetric(
                  horizontal:
                      12,
                  vertical:
                      9,
                ),
                shape:
                    RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius
                          .circular(
                    20,
                  ),
                ),
              ),
            );
          },
        ).toList(),
      ),
    );
  }
}

typedef _ChangeProductStatus =
    void Function({
  required String productId,
  required String productName,
  required String currentStatus,
});

class _AdminProductCard
    extends StatelessWidget {
  final bool isArabic;
  final Map<String, dynamic>
      product;
  final String? imageUrl;
  final Color Function(String)
      statusColor;
  final String Function(String)
      statusLabel;
  final _ChangeProductStatus
      onChangeStatus;

  const _AdminProductCard({
    required this.isArabic,
    required this.product,
    required this.imageUrl,
    required this.statusColor,
    required this.statusLabel,
    required this.onChangeStatus,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    final productId =
        product['id']
                ?.toString() ??
            '';

    final productName = isArabic
        ? (product['nameAr']
                    ?.toString()
                    .trim()
                    .isNotEmpty ==
                true
            ? product['nameAr']
                .toString()
            : product['name']
                    ?.toString() ??
                'منتج بدون اسم')
        : (product['nameEn']
                    ?.toString()
                    .trim()
                    .isNotEmpty ==
                true
            ? product['nameEn']
                .toString()
            : product['name']
                    ?.toString() ??
                'Unnamed Product');

    final status =
        product['status']
                ?.toString()
                .toUpperCase() ??
            'UNKNOWN';

    final farmer =
        product['farmer']
                is Map
            ? Map<String,
                dynamic>.from(
                product[
                    'farmer'],
              )
            : <String,
                dynamic>{};

    final category =
        product['category']
                is Map
            ? Map<String,
                dynamic>.from(
                product[
                    'category'],
              )
            : <String,
                dynamic>{};

    final farmerName =
        farmer['fullName']
                ?.toString() ??
            (isArabic ? 'مزارع غير معروف' : 'Unknown Farmer');

    final farmerEmail =
        farmer['email']
                ?.toString() ??
            '';

    final categoryName = isArabic
        ? (category['nameAr']
                    ?.toString()
                    .trim()
                    .isNotEmpty ==
                true
            ? category['nameAr']
                .toString()
            : category['name']
                    ?.toString() ??
                'بدون تصنيف')
        : (category['nameEn']
                    ?.toString()
                    .trim()
                    .isNotEmpty ==
                true
            ? category['nameEn']
                .toString()
            : category['name']
                    ?.toString() ??
                'No Category');

    final color =
        statusColor(
      status,
    );

    return Container(
      padding:
          const EdgeInsets
              .all(
        18,
      ),
      decoration:
          _adminProductsCardDecoration(
        22,
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment
                .start,
        children: [
          Container(
            width:
                double.infinity,
            height:
                150,
            decoration:
                BoxDecoration(
              color:
                  const Color(
                0xFFF3F6F1,
              ),
              borderRadius:
                  BorderRadius
                      .circular(
                16,
              ),
              border:
                  Border.all(
                color:
                    const Color(
                  0xFFE1E8DD,
                ),
              ),
            ),
            clipBehavior:
                Clip.antiAlias,
            child:
                imageUrl ==
                        null
                    ? const Icon(
                        Icons
                            .inventory_2_outlined,
                        size:
                            48,
                        color:
                            _adminProductsMuted,
                      )
                    : Image.network(
                        imageUrl!,
                        fit:
                            BoxFit.contain,
                        errorBuilder:
                            (
                          context,
                          error,
                          stackTrace,
                        ) {
                          return const Center(
                            child:
                                Icon(
                              Icons
                                  .broken_image_outlined,
                              size:
                                  48,
                              color:
                                  _adminProductsMuted,
                            ),
                          );
                        },
                      ),
          ),
          const SizedBox(
            height: 14,
          ),
          Row(
            children: [
              Expanded(
                child: Text(
                  productName,
                  maxLines: 1,
                  overflow:
                      TextOverflow
                          .ellipsis,
                  style:
                      const TextStyle(
                    color:
                        _adminProductsText,
                    fontSize:
                        17,
                    fontWeight:
                        FontWeight
                            .w800,
                  ),
                ),
              ),
              const SizedBox(
                width: 8,
              ),
              Container(
                padding:
                    const EdgeInsets
                        .symmetric(
                  horizontal:
                      10,
                  vertical:
                      6,
                ),
                decoration:
                    BoxDecoration(
                  color:
                      color.withValues(
                    alpha:
                        0.10,
                  ),
                  borderRadius:
                      BorderRadius
                          .circular(
                    18,
                  ),
                ),
                child: Text(
                  statusLabel(
                    status,
                  ),
                  style:
                      TextStyle(
                    color:
                        color,
                    fontSize:
                        10,
                    fontWeight:
                        FontWeight
                            .w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(
            height: 12,
          ),
          _AdminProductInfoRow(
            icon: Icons
                .payments_outlined,
            label:
                isArabic ? 'السعر' : 'Price',
            value:
                '${product['price'] ?? '-'} ₪',
          ),
          _AdminProductInfoRow(
            icon: Icons
                .inventory_outlined,
            label:
                isArabic ? 'الكمية' : 'Quantity',
            value:
                '${product['quantity'] ?? '-'} ${product['unit'] ?? ''}',
          ),
          _AdminProductInfoRow(
            icon: Icons
                .category_outlined,
            label:
                isArabic ? 'التصنيف' : 'Category',
            value:
                categoryName,
          ),
          _AdminProductInfoRow(
            icon: Icons
                .agriculture_outlined,
            label:
                isArabic ? 'المزارع' : 'Farmer',
            value:
                farmerName,
          ),
          if (farmerEmail
              .isNotEmpty)
            _AdminProductInfoRow(
              icon: Icons
                  .email_outlined,
              label:
                  isArabic ? 'البريد الإلكتروني' : 'Email',
              value:
                  farmerEmail,
            ),
          const Spacer(),
          SizedBox(
            width:
                double.infinity,
            child:
                ElevatedButton.icon(
              onPressed:
                  productId.isEmpty
                      ? null
                      : () {
                          onChangeStatus(
                            productId:
                                productId,
                            productName:
                                productName,
                            currentStatus:
                                status,
                          );
                        },
              style:
                  ElevatedButton
                      .styleFrom(
                backgroundColor:
                    _adminProductsPrimary,
                foregroundColor:
                    Colors.white,
                disabledBackgroundColor:
                    const Color(
                  0xFF9FB5A4,
                ),
                disabledForegroundColor:
                    Colors.white70,
                elevation:
                    0,
                padding:
                    const EdgeInsets
                        .symmetric(
                  vertical:
                      13,
                ),
                shape:
                    RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius
                          .circular(
                    13,
                  ),
                ),
              ),
              icon:
                  const Icon(
                Icons
                    .edit_note_outlined,
              ),
              label:
                  Text(
                isArabic ? 'تغيير الحالة' : 'Change Status',
                style:
                    const TextStyle(
                  fontWeight:
                      FontWeight
                          .w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AdminProductInfoRow
    extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _AdminProductInfoRow({
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
          const EdgeInsets
              .only(
        bottom: 8,
      ),
      child: Row(
        children: [
          Container(
            width: 30,
            height: 30,
            decoration:
                BoxDecoration(
              color:
                  _adminProductsLight,
              borderRadius:
                  BorderRadius
                      .circular(
                9,
              ),
            ),
            child: Icon(
              icon,
              size: 15,
              color:
                  _adminProductsPrimary,
            ),
          ),
          const SizedBox(
            width: 8,
          ),
          SizedBox(
            width: 65,
            child: Text(
              label,
              style:
                  const TextStyle(
                color:
                    _adminProductsMuted,
                fontSize:
                    11,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              maxLines: 1,
              overflow:
                  TextOverflow
                      .ellipsis,
              style:
                  const TextStyle(
                color:
                    _adminProductsText,
                fontSize:
                    11,
                fontWeight:
                    FontWeight
                        .w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AdminProductsEmptyState
    extends StatelessWidget {
  final bool isArabic;
  final String selectedStatus;

  const _AdminProductsEmptyState({
    required this.isArabic,
    required this.selectedStatus,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    final text = isArabic
        ? selectedStatus == 'ALL'
            ? 'لا توجد منتجات'
            : selectedStatus == 'AVAILABLE'
                ? 'لا توجد منتجات متاحة'
                : selectedStatus == 'OUT_OF_STOCK'
                    ? 'لا توجد منتجات نافدة من المخزون'
                    : selectedStatus == 'HIDDEN'
                        ? 'لا توجد منتجات مخفية'
                        : 'لا توجد منتجات'
        : selectedStatus == 'ALL'
            ? 'No Products Found'
            : 'No ${selectedStatus == 'OUT_OF_STOCK' ? 'Out of Stock' : _adminProductsTitleCase(selectedStatus)} Products Found';

    return Center(
      child: Container(
        constraints:
            const BoxConstraints(
          maxWidth: 460,
        ),
        margin:
            const EdgeInsets.all(
          24,
        ),
        padding:
            const EdgeInsets.all(
          30,
        ),
        decoration:
            _adminProductsCardDecoration(
          24,
        ),
        child: Column(
          mainAxisSize:
              MainAxisSize.min,
          children: [
            Container(
              width: 82,
              height: 82,
              decoration:
                  const BoxDecoration(
                color:
                    _adminProductsLight,
                shape:
                    BoxShape.circle,
              ),
              child:
                  const Icon(
                Icons
                    .inventory_2_outlined,
                size: 38,
                color:
                    _adminProductsPrimary,
              ),
            ),
            const SizedBox(
              height: 16,
            ),
            Text(
              text,
              textAlign:
                  TextAlign.center,
              style:
                  const TextStyle(
                color:
                    _adminProductsText,
                fontSize: 19,
                fontWeight:
                    FontWeight
                        .w800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AdminProductsErrorState
    extends StatelessWidget {
  final bool isArabic;
  final String message;
  final Future<void> Function()
      onRetry;

  const _AdminProductsErrorState({
    required this.isArabic,
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    return Center(
      child: Container(
        constraints:
            const BoxConstraints(
          maxWidth: 440,
        ),
        margin:
            const EdgeInsets.all(
          24,
        ),
        padding:
            const EdgeInsets.all(
          28,
        ),
        decoration:
            _adminProductsCardDecoration(
          24,
        ),
        child: Column(
          mainAxisSize:
              MainAxisSize.min,
          children: [
            const Icon(
              Icons
                  .error_outline_rounded,
              size: 56,
              color:
                  Color(
                0xFFC65353,
              ),
            ),
            const SizedBox(
              height: 14,
            ),
            Text(
              message,
              textAlign:
                  TextAlign.center,
              style:
                  const TextStyle(
                color:
                    _adminProductsText,
                fontSize: 14,
              ),
            ),
            const SizedBox(
              height: 18,
            ),
            ElevatedButton.icon(
              onPressed:
                  onRetry,
              style:
                  ElevatedButton
                      .styleFrom(
                backgroundColor:
                    _adminProductsPrimary,
                foregroundColor:
                    Colors.white,
                elevation: 0,
              ),
              icon:
                  const Icon(
                Icons
                    .refresh_rounded,
              ),
              label:
                  Text(
                isArabic ? 'حاول مرة أخرى' : 'Try Again',
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AdminProductsBackdrop
    extends StatelessWidget {
  const _AdminProductsBackdrop();

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
                    Alignment
                        .topCenter,
                end:
                    Alignment
                        .bottomCenter,
                colors: [
                  Color(
                    0xFFF8FAF4,
                  ),
                  Color(
                    0xFFFFFCF5,
                  ),
                  Color(
                    0xFFF3F8EC,
                  ),
                ],
              ),
            ),
          ),
          PositionedDirectional(
            end: -180,
            top: 190,
            child:
                _AdminProductsGlow(
              size: 450,
              color:
                  const Color(
                0xFFCFE6B4,
              ),
            ),
          ),
          PositionedDirectional(
            start: -190,
            bottom: -220,
            child:
                _AdminProductsGlow(
              size: 520,
              color:
                  const Color(
                0xFFE7DFAF,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AdminProductsGlow
    extends StatelessWidget {
  final double size;
  final Color color;

  const _AdminProductsGlow({
    required this.size,
    required this.color,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    return Container(
      width: size,
      height: size,
      decoration:
          BoxDecoration(
        shape:
            BoxShape.circle,
        gradient:
            RadialGradient(
          colors: [
            color.withValues(
              alpha: 0.25,
            ),
            color.withValues(
              alpha: 0,
            ),
          ],
        ),
      ),
    );
  }
}

BoxDecoration
    _adminProductsCardDecoration(
  double radius,
) {
  return BoxDecoration(
    color:
        Colors.white,
    borderRadius:
        BorderRadius.circular(
      radius,
    ),
    border:
        Border.all(
      color:
          const Color(
        0xFFDCE5D8,
      ),
    ),
    boxShadow: [
      BoxShadow(
        color:
            _adminProductsDark
                .withValues(
          alpha: 0.05,
        ),
        blurRadius: 20,
        offset:
            const Offset(
          0,
          7,
        ),
      ),
    ],
  );
}

String _adminProductsTitleCase(
  String value,
) {
  if (value.isEmpty) {
    return value;
  }

  final lower =
      value.toLowerCase();

  return '${lower[0].toUpperCase()}${lower.substring(1)}';
}
