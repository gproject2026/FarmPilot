import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_constants.dart';
import '../../models/supplier_cart_model.dart';
import '../../providers/locale_provider.dart';
import '../../providers/supplier_cart_provider.dart';
import '../../providers/supplier_category_provider.dart';
import '../../providers/supplier_product_provider.dart';
import 'supplier_cart_screen.dart';
import 'supplier_product_details_screen.dart';

const Color _suppliesDarkGreen = Color(0xFF173F24);
const Color _suppliesPrimaryGreen = Color(0xFF2F6B3D);
const Color _suppliesLightGreen = Color(0xFFDDECB8);
const Color _suppliesBackground = Color(0xFFF8FAF4);
const Color _suppliesTextPrimary = Color(0xFF1D2C21);
const Color _suppliesTextSecondary = Color(0xFF68756B);

class AgriculturalSuppliesScreen extends StatefulWidget {
  const AgriculturalSuppliesScreen({
    super.key,
  });

  @override
  State<AgriculturalSuppliesScreen> createState() =>
      _AgriculturalSuppliesScreenState();
}

class _AgriculturalSuppliesScreenState
    extends State<AgriculturalSuppliesScreen> {
  String _selectedCategoryId = 'ALL';
  String _searchQuery = '';

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
    final categoryProvider =
        Provider.of<SupplierCategoryProvider>(
      context,
      listen: false,
    );

    final productProvider =
        Provider.of<SupplierProductProvider>(
      context,
      listen: false,
    );

    await Future.wait([
      categoryProvider.loadSupplierCategories(),
      productProvider.loadAllSupplierProducts(),
    ]);
  }

  bool get _isArabic =>
      Localizations.localeOf(context).languageCode == 'ar';

  String _t(
    String en,
    String ar,
  ) {
    return _isArabic ? ar : en;
  }

  List<Map<String, dynamic>> _filteredProducts(
    List rawProducts,
  ) {
    final products = rawProducts
        .whereType<Map>()
        .map(
          (product) => Map<String, dynamic>.from(
            product,
          ),
        )
        .where(
          (product) {
            final status =
                product['status']?.toString().toUpperCase() ?? '';

            final quantity =
                int.tryParse(
                  product['quantity']?.toString() ?? '0',
                ) ??
                0;

            if (status == 'HIDDEN') {
              return false;
            }

            final categoryId =
                _extractCategoryId(product);

            if (_selectedCategoryId != 'ALL' &&
                categoryId != _selectedCategoryId) {
              return false;
            }

            final query = _searchQuery.trim().toLowerCase();

            if (query.isEmpty) {
              return true;
            }

            final searchable = [
              _localizedValue(
                product,
                'name',
                '',
              ),
              _localizedValue(
                product,
                'description',
                '',
              ),
              _localizedCategoryName(
                product,
              ),
              _supplierName(
                product,
              ),
              quantity.toString(),
            ].join(' ').toLowerCase();

            return searchable.contains(query);
          },
        )
        .toList();

    products.sort(
      (a, b) {
        final aAvailable = _isAvailable(a);
        final bAvailable = _isAvailable(b);

        if (aAvailable != bAvailable) {
          return aAvailable ? -1 : 1;
        }

        return _localizedValue(
          a,
          'name',
          '',
        ).toLowerCase().compareTo(
              _localizedValue(
                b,
                'name',
                '',
              ).toLowerCase(),
            );
      },
    );

    return products;
  }

  bool _isAvailable(
    Map<String, dynamic> product,
  ) {
    final status =
        product['status']?.toString().toUpperCase() ?? '';

    final quantity =
        int.tryParse(
          product['quantity']?.toString() ?? '0',
        ) ??
        0;

    return status == 'AVAILABLE' && quantity > 0;
  }

  String _extractCategoryId(
    Map<String, dynamic> product,
  ) {
    final direct =
        product['categoryId']?.toString() ?? '';

    if (direct.isNotEmpty) {
      return direct;
    }

    final category = product['category'];

    if (category is Map) {
      return category['id']?.toString() ?? '';
    }

    return '';
  }

  String _localizedCategoryName(
    Map<String, dynamic> product,
  ) {
    final category = product['category'];

    if (category is! Map) {
      return _t(
        'Uncategorized',
        'بدون تصنيف',
      );
    }

    return _localizedValue(
      Map<String, dynamic>.from(category),
      'name',
      _t(
        'Uncategorized',
        'بدون تصنيف',
      ),
    );
  }

  String _supplierName(
    Map<String, dynamic> product,
  ) {
    final supplier = product['supplier'];

    if (supplier is! Map) {
      return '';
    }

    return supplier['fullName']?.toString().trim() ?? '';
  }

  String _localizedValue(
    Map<String, dynamic> source,
    String baseKey,
    String fallback,
  ) {
    final base =
        source[baseKey]?.toString().trim() ?? '';

    final en =
        source['${baseKey}En']?.toString().trim() ?? '';

    final ar =
        source['${baseKey}Ar']?.toString().trim() ?? '';

    if (_isArabic) {
      if (ar.isNotEmpty) {
        return ar;
      }

      if (base.isNotEmpty) {
        return base;
      }

      if (en.isNotEmpty) {
        return en;
      }

      return fallback;
    }

    if (en.isNotEmpty) {
      return en;
    }

    if (base.isNotEmpty) {
      return base;
    }

    if (ar.isNotEmpty) {
      return ar;
    }

    return fallback;
  }

  Future<void> _openProductDetails(
    Map<String, dynamic> product,
  ) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => SupplierProductDetailsScreen(
          product: product,
        ),
      ),
    );

    if (!mounted) {
      return;
    }

    setState(() {});
  }

  void _openCart() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const SupplierCartScreen(),
      ),
    );
  }

  void _addToCart(
    Map<String, dynamic> product,
  ) {
    final cartProvider =
        Provider.of<SupplierCartProvider>(
      context,
      listen: false,
    );

    final supplier = product['supplier'];

    final supplierId =
        supplier is Map
            ? supplier['id']?.toString() ?? ''
            : product['supplierId']?.toString() ?? '';

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
        0;

    final unit =
        product['unit']?.toString() ?? '';

    if (productId.isEmpty ||
        supplierId.isEmpty ||
        !_isAvailable(product)) {
      _showSnack(
        _t(
          'This product is not available right now.',
          'هذا المنتج غير متوفر حاليًا.',
        ),
        isError: true,
      );

      return;
    }

    if (!cartProvider.canAddProduct(supplierId)) {
      _showSnack(
        _t(
          'Your supply cart can contain products from one supplier only. Clear the cart or finish the current order first.',
          'سلة المستلزمات يمكن أن تحتوي على منتجات من مورد واحد فقط. أفرغ السلة أو أكمل الطلب الحالي أولًا.',
        ),
        isError: true,
      );

      return;
    }

    final added = cartProvider.addToCart(
      SupplierCartItem(
        productId: productId,
        supplierId: supplierId,
        name: _localizedValue(
          product,
          'name',
          _t(
            'Product',
            'منتج',
          ),
        ),
        price: price,
        unit: unit,
        imageUrl: product['imageUrl']?.toString(),
        availableQuantity: quantity,
        quantity: 1,
      ),
    );

    if (!added) {
      _showSnack(
        _t(
          'The available stock limit has been reached.',
          'تم الوصول إلى الحد المتوفر في المخزون.',
        ),
        isError: true,
      );

      return;
    }

    _showSnack(
      _t(
        'Added to supply cart.',
        'تمت الإضافة إلى سلة المستلزمات.',
      ),
    );
  }

  void _showSnack(
    String message, {
    bool isError = false,
  }) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor:
              isError ? Colors.red : _suppliesPrimaryGreen,
        ),
      );
  }

  @override
  Widget build(
    BuildContext context,
  ) {
    return Scaffold(
      backgroundColor: _suppliesBackground,
      body: Stack(
        children: [
          const Positioned.fill(
            child: _SuppliesBackdrop(),
          ),
          Consumer3<
              SupplierProductProvider,
              SupplierCategoryProvider,
              SupplierCartProvider>(
            builder: (
              context,
              productProvider,
              categoryProvider,
              cartProvider,
              child,
            ) {
              final products = _filteredProducts(
                productProvider.supplierProducts,
              );

              return RefreshIndicator(
                onRefresh: _loadData,
                color: _suppliesPrimaryGreen,
                child: CustomScrollView(
                  physics:
                      const AlwaysScrollableScrollPhysics(),
                  slivers: [
                    SliverToBoxAdapter(
                      child: _buildHeader(
                        context,
                        cartProvider,
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: _buildHero(
                        cartProvider,
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: _buildControls(
                        categoryProvider,
                      ),
                    ),
                    if (productProvider.isLoading &&
                        productProvider.supplierProducts.isEmpty)
                      const SliverFillRemaining(
                        hasScrollBody: false,
                        child: Center(
                          child: CircularProgressIndicator(
                            color: _suppliesPrimaryGreen,
                          ),
                        ),
                      )
                    else if (productProvider.errorMessage != null &&
                        productProvider.supplierProducts.isEmpty)
                      SliverFillRemaining(
                        hasScrollBody: false,
                        child: _buildErrorState(
                          productProvider.errorMessage!,
                        ),
                      )
                    else if (products.isEmpty)
                      SliverFillRemaining(
                        hasScrollBody: false,
                        child: _buildEmptyState(),
                      )
                    else
                      SliverPadding(
                        padding:
                            const EdgeInsets.fromLTRB(
                          18,
                          0,
                          18,
                          44,
                        ),
                        sliver: SliverLayoutBuilder(
                          builder: (
                            context,
                            constraints,
                          ) {
                            final width =
                                constraints.crossAxisExtent;

                            final crossAxisCount =
                                width >= 1400
                                    ? 4
                                    : width >= 980
                                    ? 3
                                    : width >= 620
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
                                      products[index];

                                  return _SupplierProductCard(
                                    product: product,
                                    isArabic: _isArabic,
                                    name: _localizedValue(
                                      product,
                                      'name',
                                      _t(
                                        'Product',
                                        'منتج',
                                      ),
                                    ),
                                    description: _localizedValue(
                                      product,
                                      'description',
                                      _t(
                                        'No description is available.',
                                        'لا يوجد وصف متاح.',
                                      ),
                                    ),
                                    categoryName:
                                        _localizedCategoryName(
                                          product,
                                        ),
                                    supplierName:
                                        _supplierName(
                                          product,
                                        ),
                                    available:
                                        _isAvailable(
                                          product,
                                        ),
                                    onOpen: () {
                                      _openProductDetails(
                                        product,
                                      );
                                    },
                                    onAddToCart: () {
                                      _addToCart(
                                        product,
                                      );
                                    },
                                  );
                                },
                                childCount: products.length,
                              ),
                              gridDelegate:
                                  SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount:
                                    crossAxisCount,
                                crossAxisSpacing: 16,
                                mainAxisSpacing: 16,
                                mainAxisExtent: 510,
                              ),
                            );
                          },
                        ),
                      ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(
    BuildContext context,
    SupplierCartProvider cartProvider,
  ) {
    return Container(
      padding:
          const EdgeInsets.fromLTRB(
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
            color: _suppliesDarkGreen.withValues(
              alpha: 0.18,
            ),
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
              tooltip: _t(
                'Back',
                'رجوع',
              ),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            const SizedBox(width: 12),
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: _suppliesLightGreen,
                borderRadius: BorderRadius.circular(13),
              ),
              child: const Icon(
                Icons.eco_outlined,
                color: _suppliesDarkGreen,
                size: 24,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  const Text(
                    'FarmPilot',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 19,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _t(
                      'Agricultural Supplies',
                      'المستلزمات الزراعية',
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Color(0xCCFFFFFF),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            PopupMenuButton<String>(
              tooltip: _t(
                'Change Language',
                'تغيير اللغة',
              ),
              offset: const Offset(0, 48),
              position: PopupMenuPosition.under,
              color: const Color(0xFFF8FAF4),
              elevation: 8,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              onSelected: (
                languageCode,
              ) {
                Provider.of<LocaleProvider>(
                  context,
                  listen: false,
                ).setLocale(
                  Locale(languageCode),
                );
              },
              itemBuilder: (
                context,
              ) {
                return [
                  PopupMenuItem<String>(
                    value: 'en',
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.check_rounded,
                          size: 20,
                          color:
                              !_isArabic
                                  ? _suppliesPrimaryGreen
                                  : Colors.transparent,
                        ),
                        const SizedBox(width: 10),
                        Text(
                          _t(
                            'English',
                            'الإنجليزية',
                          ),
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
                          color:
                              _isArabic
                                  ? _suppliesPrimaryGreen
                                  : Colors.transparent,
                        ),
                        const SizedBox(width: 10),
                        Text(
                          _t(
                            'Arabic',
                            'العربية',
                          ),
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
            const SizedBox(width: 8),
            _CartHeaderButton(
              count: cartProvider.totalQuantity,
              tooltip: _t(
                'Supply Cart',
                'سلة المستلزمات',
              ),
              onTap: _openCart,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHero(
    SupplierCartProvider cartProvider,
  ) {
    return Padding(
      padding:
          const EdgeInsets.fromLTRB(
        18,
        24,
        18,
        18,
      ),
      child: Container(
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFFFFFFF),
              Color(0xFFF9FBF5),
            ],
          ),
          borderRadius: BorderRadius.circular(26),
          border: Border.all(
            color: const Color(0xFFDDE6D8),
          ),
          boxShadow: [
            BoxShadow(
              color: _suppliesDarkGreen.withValues(
                alpha: 0.05,
              ),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: LayoutBuilder(
          builder: (
            context,
            constraints,
          ) {
            final compact =
                constraints.maxWidth < 650;

            final intro = Row(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Container(
                  width: 54,
                  height: 54,
                  decoration: BoxDecoration(
                    color: const Color(0xFFEAF3DF),
                    borderRadius: BorderRadius.circular(17),
                  ),
                  child: const Icon(
                    Icons.agriculture_outlined,
                    color: _suppliesPrimaryGreen,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Text(
                        _t(
                          'Agricultural Supplies',
                          'المستلزمات الزراعية',
                        ),
                        style: const TextStyle(
                          color: _suppliesTextPrimary,
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        _t(
                          'Browse seeds, fertilizers, pesticides, irrigation supplies, tools and more from registered suppliers.',
                          'تصفح البذور والأسمدة والمبيدات ومستلزمات الري والأدوات وغيرها من الموردين المسجلين.',
                        ),
                        style: const TextStyle(
                          color: _suppliesTextSecondary,
                          fontSize: 13,
                          height: 1.45,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );

            final cartSummary = Container(
              padding:
                  const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 12,
              ),
              decoration: BoxDecoration(
                color: const Color(0xFFF5F8F0),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: const Color(0xFFE1E8DD),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.shopping_cart_outlined,
                    color: _suppliesPrimaryGreen,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${_t('Cart', 'السلة')}: '
                    '${cartProvider.totalQuantity}',
                    style: const TextStyle(
                      color: _suppliesTextPrimary,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            );

            if (compact) {
              return Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  intro,
                  const SizedBox(height: 18),
                  cartSummary,
                ],
              );
            }

            return Row(
              crossAxisAlignment:
                  CrossAxisAlignment.center,
              children: [
                Expanded(child: intro),
                const SizedBox(width: 20),
                cartSummary,
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildControls(
    SupplierCategoryProvider categoryProvider,
  ) {
    final rawCategories =
        categoryProvider.supplierCategories;

    final categories = rawCategories
        .whereType<Map>()
        .map(
          (category) =>
              Map<String, dynamic>.from(category),
        )
        .toList();

    return Padding(
      padding:
          const EdgeInsets.fromLTRB(
        18,
        0,
        18,
        18,
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          TextField(
            onChanged: (
              value,
            ) {
              setState(
                () {
                  _searchQuery = value;
                },
              );
            },
            decoration: InputDecoration(
              hintText: _t(
                'Search agricultural supplies...',
                'ابحث في المستلزمات الزراعية...',
              ),
              prefixIcon: const Icon(
                Icons.search_rounded,
                color: _suppliesPrimaryGreen,
              ),
              filled: true,
              fillColor: Colors.white,
              contentPadding:
                  const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(
                  color: Color(0xFFDDE6D8),
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(
                  color: Color(0xFFDDE6D8),
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(
                  color: _suppliesPrimaryGreen,
                  width: 1.5,
                ),
              ),
            ),
          ),
          const SizedBox(height: 14),
          if (categoryProvider.isLoading &&
              categories.isEmpty)
            const SizedBox(
              height: 40,
              child: Center(
                child: LinearProgressIndicator(
                  color: _suppliesPrimaryGreen,
                ),
              ),
            )
          else
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _CategoryChip(
                    label: _t(
                      'All',
                      'الكل',
                    ),
                    selected:
                        _selectedCategoryId == 'ALL',
                    onTap: () {
                      setState(
                        () {
                          _selectedCategoryId = 'ALL';
                        },
                      );
                    },
                  ),
                  ...categories.map(
                    (category) {
                      final id =
                          category['id']?.toString() ?? '';

                      final label = _localizedValue(
                        category,
                        'name',
                        _t(
                          'Category',
                          'تصنيف',
                        ),
                      );

                      return Padding(
                        padding:
                            const EdgeInsetsDirectional.only(
                          start: 9,
                        ),
                        child: _CategoryChip(
                          label: label,
                          selected:
                              _selectedCategoryId == id,
                          onTap:
                              id.isEmpty
                                  ? null
                                  : () {
                                    setState(
                                      () {
                                        _selectedCategoryId = id;
                                      },
                                    );
                                  },
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildErrorState(
    String message,
  ) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Container(
          constraints:
              const BoxConstraints(maxWidth: 500),
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: const Color(0xFFE8CACA),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.error_outline_rounded,
                size: 48,
                color: Color(0xFFB44F4F),
              ),
              const SizedBox(height: 12),
              Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: _suppliesTextPrimary,
                  height: 1.45,
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: _loadData,
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      _suppliesPrimaryGreen,
                  foregroundColor: Colors.white,
                  elevation: 0,
                ),
                icon: const Icon(
                  Icons.refresh_rounded,
                ),
                label: Text(
                  _t(
                    'Try Again',
                    'حاول مرة أخرى',
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Container(
          constraints:
              const BoxConstraints(maxWidth: 500),
          padding: const EdgeInsets.all(30),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(26),
            border: Border.all(
              color: const Color(0xFFDDE6D8),
            ),
            boxShadow: [
              BoxShadow(
                color: _suppliesDarkGreen.withValues(
                  alpha: 0.05,
                ),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 92,
                height: 92,
                decoration: BoxDecoration(
                  color: const Color(0xFFEAF3DF),
                  borderRadius: BorderRadius.circular(28),
                ),
                child: const Icon(
                  Icons.agriculture_outlined,
                  size: 46,
                  color: _suppliesPrimaryGreen,
                ),
              ),
              const SizedBox(height: 18),
              Text(
                _searchQuery.trim().isNotEmpty ||
                        _selectedCategoryId != 'ALL'
                    ? _t(
                        'No Matching Supplies',
                        'لا توجد مستلزمات مطابقة',
                      )
                    : _t(
                        'No Agricultural Supplies Yet',
                        'لا توجد مستلزمات زراعية بعد',
                      ),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: _suppliesTextPrimary,
                  fontSize: 21,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _searchQuery.trim().isNotEmpty ||
                        _selectedCategoryId != 'ALL'
                    ? _t(
                        'Try a different search term or category.',
                        'جرّب كلمة بحث أو تصنيفًا مختلفًا.',
                      )
                    : _t(
                        'Supplier products will appear here when they are added.',
                        'ستظهر منتجات الموردين هنا عند إضافتها.',
                      ),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: _suppliesTextSecondary,
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

class _SupplierProductCard
    extends StatelessWidget {
  final Map<String, dynamic> product;
  final bool isArabic;
  final String name;
  final String description;
  final String categoryName;
  final String supplierName;
  final bool available;
  final VoidCallback onOpen;
  final VoidCallback onAddToCart;

  const _SupplierProductCard({
    required this.product,
    required this.isArabic,
    required this.name,
    required this.description,
    required this.categoryName,
    required this.supplierName,
    required this.available,
    required this.onOpen,
    required this.onAddToCart,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    final price =
        double.tryParse(
          product['price']?.toString() ?? '0',
        ) ??
        0;

    final quantity =
        int.tryParse(
          product['quantity']?.toString() ?? '0',
        ) ??
        0;

    final unit =
        product['unit']?.toString().trim() ?? '';

    final status =
        product['status']?.toString().toUpperCase() ?? '';

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onOpen,
        borderRadius: BorderRadius.circular(24),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: const Color(0xFFDDE6D8),
            ),
            boxShadow: [
              BoxShadow(
                color: _suppliesDarkGreen.withValues(
                  alpha: 0.05,
                ),
                blurRadius: 18,
                offset: const Offset(0, 7),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Stack(
                children: [
                  ClipRRect(
                    borderRadius:
                        const BorderRadius.vertical(
                      top: Radius.circular(23),
                    ),
                    child: _ProductImage(
                      imageUrl:
                          product['imageUrl']?.toString(),
                    ),
                  ),
                  PositionedDirectional(
                    top: 12,
                    end: 12,
                    child: _AvailabilityBadge(
                      available: available,
                      status: status,
                      isArabic: isArabic,
                    ),
                  ),
                ],
              ),
              Expanded(
                child: Padding(
                  padding:
                      const EdgeInsets.fromLTRB(
                    16,
                    14,
                    16,
                    16,
                  ),
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Text(
                        categoryName,
                        maxLines: 1,
                        overflow:
                            TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: _suppliesPrimaryGreen,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        name,
                        maxLines: 2,
                        overflow:
                            TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: _suppliesTextPrimary,
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: 7),
                      Text(
                        description,
                        maxLines: 3,
                        overflow:
                            TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: _suppliesTextSecondary,
                          fontSize: 12,
                          height: 1.4,
                        ),
                      ),
                      const Spacer(),
                      if (supplierName.isNotEmpty)
                        Row(
                          children: [
                            const Icon(
                              Icons.storefront_outlined,
                              size: 16,
                              color: _suppliesPrimaryGreen,
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                supplierName,
                                maxLines: 1,
                                overflow:
                                    TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color:
                                      _suppliesTextSecondary,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                      if (supplierName.isNotEmpty)
                        const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              '${price.toStringAsFixed(2)} ₪'
                              '${unit.isEmpty ? '' : ' / $unit'}',
                              style: const TextStyle(
                                color:
                                    _suppliesPrimaryGreen,
                                fontSize: 18,
                                fontWeight:
                                    FontWeight.w800,
                              ),
                            ),
                          ),
                          Text(
                            '${isArabic ? 'المتوفر' : 'Stock'}: $quantity',
                            style: TextStyle(
                              color:
                                  available
                                      ? _suppliesTextSecondary
                                      : const Color(
                                          0xFFB44F4F,
                                        ),
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        height: 44,
                        child: ElevatedButton.icon(
                          onPressed:
                              available
                                  ? onAddToCart
                                  : null,
                          style:
                              ElevatedButton.styleFrom(
                            backgroundColor:
                                _suppliesPrimaryGreen,
                            foregroundColor: Colors.white,
                            disabledBackgroundColor:
                                const Color(0xFFD8DDD5),
                            disabledForegroundColor:
                                const Color(0xFF858D86),
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(
                                13,
                              ),
                            ),
                          ),
                          icon: Icon(
                            available
                                ? Icons.add_shopping_cart_rounded
                                : Icons.inventory_2_outlined,
                            size: 19,
                          ),
                          label: Text(
                            available
                                ? (isArabic
                                    ? 'أضف إلى السلة'
                                    : 'Add to Cart')
                                : (isArabic
                                    ? 'غير متوفر'
                                    : 'Unavailable'),
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
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
}

class _ProductImage extends StatelessWidget {
  final String? imageUrl;

  const _ProductImage({
    required this.imageUrl,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    final hasImage =
        imageUrl != null &&
        imageUrl!.trim().isNotEmpty;

    return Container(
      width: double.infinity,
      height: 205,
      color: Colors.white,
      alignment: Alignment.center,
      child: hasImage
          ? Padding(
              padding: const EdgeInsets.all(8),
              child: Image.network(
                AppConstants.getImageUrl(
                  imageUrl,
                ),
                width: double.infinity,
                height: double.infinity,
                fit: BoxFit.contain,
                errorBuilder: (
                  context,
                  error,
                  stackTrace,
                ) {
                  return const _ImagePlaceholder();
                },
              ),
            )
          : const _ImagePlaceholder(),
    );
  }
}


class _ImagePlaceholder extends StatelessWidget {
  const _ImagePlaceholder();

  @override
  Widget build(
    BuildContext context,
  ) {
    return Container(
      color: const Color(0xFFF0F5EB),
      alignment: Alignment.center,
      child: const Icon(
        Icons.inventory_2_outlined,
        size: 58,
        color: _suppliesPrimaryGreen,
      ),
    );
  }
}

class _AvailabilityBadge extends StatelessWidget {
  final bool available;
  final String status;
  final bool isArabic;

  const _AvailabilityBadge({
    required this.available,
    required this.status,
    required this.isArabic,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    final label =
        available
            ? (isArabic ? 'متوفر' : 'Available')
            : status == 'OUT_OF_STOCK'
            ? (isArabic ? 'نفد المخزون' : 'Out of Stock')
            : (isArabic ? 'غير متوفر' : 'Unavailable');

    return Container(
      padding:
          const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color:
            available
                ? const Color(0xFFEAF3DF)
                : const Color(0xFFFCE7E7),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Text(
        label,
        style: TextStyle(
          color:
              available
                  ? _suppliesPrimaryGreen
                  : const Color(0xFFB44F4F),
          fontSize: 10,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback? onTap;

  const _CategoryChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    return Material(
      color:
          selected
              ? const Color(0xFFEAF3DF)
              : Colors.white,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding:
              const EdgeInsets.symmetric(
            horizontal: 15,
            vertical: 10,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color:
                  selected
                      ? _suppliesPrimaryGreen
                      : const Color(0xFFDDE6D8),
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              color:
                  selected
                      ? _suppliesPrimaryGreen
                      : _suppliesTextSecondary,
              fontSize: 12,
              fontWeight:
                  selected
                      ? FontWeight.w800
                      : FontWeight.w600,
            ),
          ),
        ),
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
  Widget build(
    BuildContext context,
  ) {
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
                  onTap == null
                      ? Colors.white54
                      : Colors.white,
              size: 21,
            ),
          ),
        ),
      ),
    );
  }
}

class _CartHeaderButton extends StatelessWidget {
  final int count;
  final String tooltip;
  final VoidCallback onTap;

  const _CartHeaderButton({
    required this.count,
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
        color: Colors.white.withValues(
          alpha: 0.10,
        ),
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: SizedBox(
            width: 48,
            height: 44,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                const Center(
                  child: Icon(
                    Icons.shopping_cart_outlined,
                    color: Colors.white,
                    size: 21,
                  ),
                ),
                if (count > 0)
                  PositionedDirectional(
                    top: 3,
                    end: 3,
                    child: Container(
                      constraints:
                          const BoxConstraints(
                        minWidth: 18,
                        minHeight: 18,
                      ),
                      padding:
                          const EdgeInsets.symmetric(
                        horizontal: 4,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF3D36A),
                        borderRadius:
                            BorderRadius.circular(
                          20,
                        ),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        count > 99 ? '99+' : '$count',
                        style: const TextStyle(
                          color: _suppliesDarkGreen,
                          fontSize: 9,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SuppliesBackdrop extends StatelessWidget {
  const _SuppliesBackdrop();

  @override
  Widget build(
    BuildContext context,
  ) {
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
                stops: [
                  0.0,
                  0.50,
                  1.0,
                ],
              ),
            ),
          ),
          PositionedDirectional(
            end: -190,
            top: 200,
            child: Container(
              width: 470,
              height: 470,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFFCFE6B4).withValues(
                      alpha: 0.28,
                    ),
                    const Color(0xFFCFE6B4).withValues(
                      alpha: 0.0,
                    ),
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
                    const Color(0xFFE7DFAF).withValues(
                      alpha: 0.22,
                    ),
                    const Color(0xFFE7DFAF).withValues(
                      alpha: 0.0,
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
