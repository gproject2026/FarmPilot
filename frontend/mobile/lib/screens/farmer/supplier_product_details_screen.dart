import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_constants.dart';
import '../../models/supplier_cart_model.dart';
import '../../providers/supplier_cart_provider.dart';
import 'supplier_cart_screen.dart';

const Color _detailsDarkGreen = Color(0xFF173F24);
const Color _detailsPrimaryGreen = Color(0xFF2F6B3D);
const Color _detailsLightGreen = Color(0xFFDDECB8);
const Color _detailsBackground = Color(0xFFF8FAF4);
const Color _detailsTextPrimary = Color(0xFF1D2C21);
const Color _detailsTextSecondary = Color(0xFF68756B);

class SupplierProductDetailsScreen extends StatelessWidget {
  final Map<String, dynamic> product;

  const SupplierProductDetailsScreen({
    super.key,
    required this.product,
  });

  String _localizedValue({
    required Map<String, dynamic> source,
    required String baseKey,
    required bool isArabic,
    String fallback = '',
  }) {
    final baseValue =
        source[baseKey]?.toString().trim() ?? '';

    final enValue =
        source['${baseKey}En']?.toString().trim() ?? '';

    final arValue =
        source['${baseKey}Ar']?.toString().trim() ?? '';

    if (isArabic) {
      if (arValue.isNotEmpty) {
        return arValue;
      }

      if (baseValue.isNotEmpty) {
        return baseValue;
      }

      if (enValue.isNotEmpty) {
        return enValue;
      }

      return fallback;
    }

    if (enValue.isNotEmpty) {
      return enValue;
    }

    if (baseValue.isNotEmpty) {
      return baseValue;
    }

    if (arValue.isNotEmpty) {
      return arValue;
    }

    return fallback;
  }

  String _localizedCategoryName(
    dynamic category,
    bool isArabic,
  ) {
    if (category is! Map) {
      return '';
    }

    return _localizedValue(
      source: Map<String, dynamic>.from(category),
      baseKey: 'name',
      isArabic: isArabic,
    );
  }

  String _resolveImageUrl(
    String imageUrl,
  ) {
    final trimmedUrl = imageUrl.trim();

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

  void _addToCart(
    BuildContext context, {
    required bool isArabic,
    required String name,
    required double price,
    required String unit,
    required int availableQuantity,
    required String? imageUrl,
  }) {
    final productId =
        product['id']?.toString().trim() ?? '';

    final supplier =
        product['supplier'];

    final supplierId =
        supplier is Map
            ? supplier['id']?.toString().trim() ?? ''
            : '';

    if (productId.isEmpty ||
        supplierId.isEmpty ||
        availableQuantity <= 0) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(
              isArabic
                  ? 'لا يمكن إضافة هذا المنتج إلى السلة.'
                  : 'This product cannot be added to the cart.',
            ),
            backgroundColor: Colors.red,
          ),
        );

      return;
    }

    final cartProvider =
        Provider.of<SupplierCartProvider>(
      context,
      listen: false,
    );

    final sameSupplier =
        cartProvider.canAddProduct(
      supplierId,
    );

    if (!sameSupplier) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(
              isArabic
                  ? 'السلة تحتوي منتجات من مورد آخر. أنهِ الطلب الحالي أو أفرغ السلة أولًا.'
                  : 'Your cart contains products from another supplier. Complete that order or clear the cart first.',
            ),
            backgroundColor: const Color(
              0xFFB7791F,
            ),
          ),
        );

      return;
    }

    final added =
        cartProvider.addToCart(
      SupplierCartItem(
        productId: productId,
        supplierId: supplierId,
        name: name,
        price: price,
        unit: unit,
        quantity: 1,
        availableQuantity:
            availableQuantity,
        imageUrl: imageUrl,
      ),
    );

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            added
                ? isArabic
                    ? 'تمت إضافة $name إلى سلة المستلزمات.'
                    : '$name added to the supply cart.'
                : isArabic
                    ? 'وصلت الكمية في السلة إلى الحد المتوفر.'
                    : 'The cart quantity has reached the available stock.',
          ),
          backgroundColor:
              added
                  ? _detailsPrimaryGreen
                  : const Color(
                      0xFFB7791F,
                    ),
        ),
      );
  }

  @override
  Widget build(
    BuildContext context,
  ) {
    final isArabic =
        Localizations.localeOf(context)
                .languageCode ==
            'ar';

    final name =
        _localizedValue(
      source: product,
      baseKey: 'name',
      isArabic: isArabic,
      fallback:
          isArabic
              ? 'منتج'
              : 'Product',
    );

    final description =
        _localizedValue(
      source: product,
      baseKey: 'description',
      isArabic: isArabic,
    );

    final plantingInstructions =
        _localizedValue(
      source: product,
      baseKey: 'plantingInstructions',
      isArabic: isArabic,
    );

    final irrigationInstructions =
        _localizedValue(
      source: product,
      baseKey: 'irrigationInstructions',
      isArabic: isArabic,
    );

    final usageInstructions =
        _localizedValue(
      source: product,
      baseKey: 'usageInstructions',
      isArabic: isArabic,
    );

    final categoryName =
        _localizedCategoryName(
      product['category'],
      isArabic,
    );

    final unit =
        product['unit']?.toString().trim() ?? '';

    final imageUrl =
        product['imageUrl']?.toString();

    final status =
        product['status']?.toString() ?? '';

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

    final supplier =
        product['supplier'];

    final supplierName =
        supplier is Map
            ? supplier['fullName']
                      ?.toString()
                      .trim() ??
                  ''
            : '';

    final supplierPhone =
        supplier is Map
            ? supplier['phone']
                      ?.toString()
                      .trim() ??
                  ''
            : '';

    final supplierAddress =
        supplier is Map
            ? supplier['address']
                      ?.toString()
                      .trim() ??
                  ''
            : '';

    final isAvailable =
        quantity > 0 &&
        status == 'AVAILABLE';

    return Scaffold(
      backgroundColor:
          _detailsBackground,
      body: Stack(
        children: [
          const Positioned.fill(
            child:
                _ProductDetailsBackdrop(),
          ),
          CustomScrollView(
            physics:
                const ClampingScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(
                child: _buildHeader(
                  context,
                  name,
                  isArabic,
                ),
              ),
              SliverToBoxAdapter(
                child: LayoutBuilder(
                  builder: (
                    context,
                    constraints,
                  ) {
                    final isWide =
                        constraints.maxWidth >=
                            900;

                    return Padding(
                      padding:
                          EdgeInsets.fromLTRB(
                        isWide ? 42 : 18,
                        isWide ? 30 : 20,
                        isWide ? 42 : 18,
                        50,
                      ),
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          if (isWide)
                            Row(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  flex: 11,
                                  child:
                                      _buildProductImageCard(
                                    imageUrl,
                                  ),
                                ),
                                const SizedBox(
                                  width: 24,
                                ),
                                Expanded(
                                  flex: 9,
                                  child:
                                      _buildProductInfoCard(
                                    context,
                                    isArabic:
                                        isArabic,
                                    name: name,
                                    categoryName:
                                        categoryName,
                                    supplierName:
                                        supplierName,
                                    price: price,
                                    unit: unit,
                                    quantity:
                                        quantity,
                                    isAvailable:
                                        isAvailable,
                                    imageUrl:
                                        imageUrl,
                                  ),
                                ),
                              ],
                            )
                          else ...[
                            _buildProductImageCard(
                              imageUrl,
                            ),
                            const SizedBox(
                              height: 18,
                            ),
                            _buildProductInfoCard(
                              context,
                              isArabic:
                                  isArabic,
                              name: name,
                              categoryName:
                                  categoryName,
                              supplierName:
                                  supplierName,
                              price: price,
                              unit: unit,
                              quantity:
                                  quantity,
                              isAvailable:
                                  isAvailable,
                              imageUrl:
                                  imageUrl,
                            ),
                          ],
                          if (description
                              .isNotEmpty) ...[
                            const SizedBox(
                              height: 24,
                            ),
                            _buildTextCard(
                              icon:
                                  Icons.description_outlined,
                              title:
                                  isArabic
                                      ? 'الوصف'
                                      : 'Description',
                              text:
                                  description,
                            ),
                          ],
                          if (supplierName
                                  .isNotEmpty ||
                              supplierPhone
                                  .isNotEmpty ||
                              supplierAddress
                                  .isNotEmpty) ...[
                            const SizedBox(
                              height: 24,
                            ),
                            _buildSupplierCard(
                              isArabic:
                                  isArabic,
                              supplierName:
                                  supplierName,
                              supplierPhone:
                                  supplierPhone,
                              supplierAddress:
                                  supplierAddress,
                            ),
                          ],
                          if (plantingInstructions
                                  .isNotEmpty ||
                              irrigationInstructions
                                  .isNotEmpty ||
                              usageInstructions
                                  .isNotEmpty) ...[
                            const SizedBox(
                              height: 24,
                            ),
                            _buildInstructionsCard(
                              isArabic:
                                  isArabic,
                              plantingInstructions:
                                  plantingInstructions,
                              irrigationInstructions:
                                  irrigationInstructions,
                              usageInstructions:
                                  usageInstructions,
                            ),
                          ],
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(
    BuildContext context,
    String productName,
    bool isArabic,
  ) {
    final cartProvider =
        Provider.of<SupplierCartProvider>(
      context,
    );

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
        boxShadow: [
          BoxShadow(
            color:
                _detailsDarkGreen.withValues(
              alpha: 0.18,
            ),
            blurRadius: 24,
            offset:
                const Offset(
              0,
              8,
            ),
          ),
        ],
      ),
      child: SafeArea(
        bottom: false,
        child: Row(
          children: [
            Material(
              color:
                  Colors.white.withValues(
                alpha: 0.10,
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
                  width: 44,
                  height: 44,
                  child: Icon(
                    Icons.arrow_back_rounded,
                    color:
                        Colors.white,
                  ),
                ),
              ),
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
                    _detailsLightGreen,
                borderRadius:
                    BorderRadius.circular(
                  13,
                ),
              ),
              child:
                  const Icon(
                Icons.agriculture_outlined,
                color:
                    _detailsDarkGreen,
                size: 24,
              ),
            ),
            const SizedBox(
              width: 10,
            ),
            Expanded(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  const Text(
                    'FarmPilot',
                    style:
                        TextStyle(
                      color:
                          Colors.white,
                      fontSize: 18,
                      fontWeight:
                          FontWeight.w800,
                    ),
                  ),
                  const SizedBox(
                    height: 2,
                  ),
                  Text(
                    productName,
                    maxLines: 1,
                    overflow:
                        TextOverflow.ellipsis,
                    style:
                        TextStyle(
                      color:
                          Colors.white.withValues(
                        alpha: 0.78,
                      ),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(
              width: 10,
            ),
            Stack(
              clipBehavior:
                  Clip.none,
              children: [
                Material(
  color: Colors.transparent,
  child: InkWell(
    onTap: () {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) =>
              const SupplierCartScreen(),
        ),
      );
    },
    borderRadius:
        BorderRadius.circular(
      14,
    ),
    child: Container(
      width: 44,
      height: 44,
      decoration:
          BoxDecoration(
        color:
            Colors.white.withValues(
          alpha: 0.10,
        ),
        borderRadius:
            BorderRadius.circular(
          14,
        ),
      ),
      child:
          const Icon(
        Icons.shopping_cart_outlined,
        color:
            Colors.white,
        size: 21,
      ),
    ),
  ),
),
                if (cartProvider
                        .totalQuantity >
                    0)
                  PositionedDirectional(
                    end: -5,
                    top: -5,
                    child: Container(
                      constraints:
                          const BoxConstraints(
                        minWidth: 19,
                        minHeight: 19,
                      ),
                      padding:
                          const EdgeInsets.symmetric(
                        horizontal: 5,
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
                          width: 1.5,
                        ),
                      ),
                      alignment:
                          Alignment.center,
                      child: Text(
                        cartProvider
                            .totalQuantity
                            .toString(),
                        style:
                            const TextStyle(
                          color:
                              Colors.white,
                          fontSize: 9,
                          fontWeight:
                              FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductImageCard(
    String? imageUrl,
  ) {
    return Container(
      width: double.infinity,
      decoration:
          BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(
          26,
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
                _detailsDarkGreen.withValues(
              alpha: 0.055,
            ),
            blurRadius: 22,
            offset:
                const Offset(
              0,
              8,
            ),
          ),
        ],
      ),
      clipBehavior:
          Clip.antiAlias,
      child: AspectRatio(
        aspectRatio: 16 / 9,
        child: Container(
          color:
              const Color(
            0xFFF0F5EB,
          ),
          child: imageUrl != null &&
                  imageUrl
                      .trim()
                      .isNotEmpty
              ? Image.network(
                  _resolveImageUrl(
                    imageUrl,
                  ),
                  fit:
                      BoxFit.cover,
                  errorBuilder: (
                    context,
                    error,
                    stackTrace,
                  ) {
                    return const Center(
                      child: Icon(
                        Icons.image_not_supported_outlined,
                        size: 70,
                        color:
                            Color(
                          0xFF9AA59B,
                        ),
                      ),
                    );
                  },
                )
              : const Center(
                  child: Icon(
                    Icons.inventory_2_outlined,
                    size: 80,
                    color:
                        _detailsPrimaryGreen,
                  ),
                ),
        ),
      ),
    );
  }

  Widget _buildProductInfoCard(
    BuildContext context, {
    required bool isArabic,
    required String name,
    required String categoryName,
    required String supplierName,
    required double price,
    required String unit,
    required int quantity,
    required bool isAvailable,
    required String? imageUrl,
  }) {
    return Container(
      width: double.infinity,
      padding:
          const EdgeInsets.all(
        24,
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
          26,
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
                _detailsDarkGreen.withValues(
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
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          if (categoryName
              .isNotEmpty)
            Container(
              padding:
                  const EdgeInsets.symmetric(
                horizontal: 11,
                vertical: 6,
              ),
              decoration:
                  BoxDecoration(
                color:
                    const Color(
                  0xFFEAF3DF,
                ),
                borderRadius:
                    BorderRadius.circular(
                  20,
                ),
              ),
              child: Text(
                categoryName,
                style:
                    const TextStyle(
                  color:
                      _detailsPrimaryGreen,
                  fontSize: 12,
                  fontWeight:
                      FontWeight.w700,
                ),
              ),
            ),
          if (categoryName
              .isNotEmpty)
            const SizedBox(
              height: 14,
            ),
          Text(
            name,
            style:
                const TextStyle(
              color:
                  _detailsTextPrimary,
              fontSize: 28,
              fontWeight:
                  FontWeight.w800,
              letterSpacing: -0.6,
            ),
          ),
          const SizedBox(
            height: 14,
          ),
          Text(
            '${price.toStringAsFixed(2)} ₪'
            '${unit.isEmpty ? '' : ' / $unit'}',
            style:
                const TextStyle(
              color:
                  _detailsPrimaryGreen,
              fontSize: 24,
              fontWeight:
                  FontWeight.w800,
            ),
          ),
          const SizedBox(
            height: 18,
          ),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _InfoPill(
                icon:
                    isAvailable
                        ? Icons.check_circle_outline_rounded
                        : Icons.cancel_outlined,
                label:
                    isAvailable
                        ? isArabic
                            ? 'المتوفر: $quantity'
                            : 'Available: $quantity'
                        : isArabic
                            ? 'غير متوفر'
                            : 'Out of stock',
                background:
                    isAvailable
                        ? const Color(
                            0xFFEAF3DF,
                          )
                        : const Color(
                            0xFFFCE7E7,
                          ),
                foreground:
                    isAvailable
                        ? _detailsPrimaryGreen
                        : const Color(
                            0xFFB44F4F,
                          ),
              ),
              if (supplierName
                  .isNotEmpty)
                _InfoPill(
                  icon:
                      Icons.storefront_outlined,
                  label:
                      '${isArabic ? 'المورد' : 'Supplier'}: $supplierName',
                  background:
                      const Color(
                    0xFFF1F3EF,
                  ),
                  foreground:
                      const Color(
                    0xFF5F6B61,
                  ),
                ),
            ],
          ),
          const SizedBox(
            height: 22,
          ),
          SizedBox(
            width: double.infinity,
            height: 48,
            child:
                ElevatedButton.icon(
              onPressed:
                  isAvailable
                      ? () {
                          _addToCart(
                            context,
                            isArabic:
                                isArabic,
                            name:
                                name,
                            price:
                                price,
                            unit:
                                unit,
                            availableQuantity:
                                quantity,
                            imageUrl:
                                imageUrl,
                          );
                        }
                      : null,
              style:
                  ElevatedButton.styleFrom(
                backgroundColor:
                    _detailsPrimaryGreen,
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
              icon:
                  const Icon(
                Icons.add_shopping_cart_rounded,
                size: 19,
              ),
              label:
                  Text(
                isAvailable
                    ? isArabic
                        ? 'أضف إلى سلة المستلزمات'
                        : 'Add to Supply Cart'
                    : isArabic
                        ? 'غير متوفر حاليًا'
                        : 'Currently Unavailable',
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
    );
  }

  Widget _buildTextCard({
    required IconData icon,
    required String title,
    required String text,
  }) {
    return Container(
      width: double.infinity,
      padding:
          const EdgeInsets.all(
        22,
      ),
      decoration:
          BoxDecoration(
        color: Colors.white,
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
                _detailsDarkGreen.withValues(
              alpha: 0.04,
            ),
            blurRadius: 16,
            offset:
                const Offset(
              0,
              6,
            ),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                color:
                    _detailsPrimaryGreen,
                size: 22,
              ),
              const SizedBox(
                width: 9,
              ),
              Text(
                title,
                style:
                    const TextStyle(
                  color:
                      _detailsTextPrimary,
                  fontSize: 18,
                  fontWeight:
                      FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(
            height: 12,
          ),
          Text(
            text,
            style:
                const TextStyle(
              color:
                  _detailsTextSecondary,
              fontSize: 14,
              height: 1.55,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSupplierCard({
    required bool isArabic,
    required String supplierName,
    required String supplierPhone,
    required String supplierAddress,
  }) {
    return Container(
      width: double.infinity,
      padding:
          const EdgeInsets.all(
        22,
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
            Color(
              0xFFFFFFFF,
            ),
            Color(
              0xFFF8FBF3,
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
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.storefront_outlined,
                color:
                    _detailsPrimaryGreen,
                size: 23,
              ),
              const SizedBox(
                width: 9,
              ),
              Text(
                isArabic
                    ? 'معلومات المورد'
                    : 'Supplier Information',
                style:
                    const TextStyle(
                  color:
                      _detailsTextPrimary,
                  fontSize: 18,
                  fontWeight:
                      FontWeight.w800,
                ),
              ),
            ],
          ),
          if (supplierName
              .isNotEmpty) ...[
            const SizedBox(
              height: 16,
            ),
            _SupplierInfoRow(
              icon:
                  Icons.person_outline_rounded,
              label:
                  isArabic
                      ? 'المورد'
                      : 'Supplier',
              value:
                  supplierName,
            ),
          ],
          if (supplierPhone
              .isNotEmpty) ...[
            const SizedBox(
              height: 12,
            ),
            _SupplierInfoRow(
              icon:
                  Icons.phone_outlined,
              label:
                  isArabic
                      ? 'الهاتف'
                      : 'Phone',
              value:
                  supplierPhone,
            ),
          ],
          if (supplierAddress
              .isNotEmpty) ...[
            const SizedBox(
              height: 12,
            ),
            _SupplierInfoRow(
              icon:
                  Icons.location_on_outlined,
              label:
                  isArabic
                      ? 'موقع المتجر'
                      : 'Store Location',
              value:
                  supplierAddress,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInstructionsCard({
    required bool isArabic,
    required String plantingInstructions,
    required String irrigationInstructions,
    required String usageInstructions,
  }) {
    return Container(
      width: double.infinity,
      padding:
          const EdgeInsets.all(
        22,
      ),
      decoration:
          BoxDecoration(
        color: Colors.white,
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
                _detailsDarkGreen.withValues(
              alpha: 0.04,
            ),
            blurRadius: 16,
            offset:
                const Offset(
              0,
              6,
            ),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.menu_book_outlined,
                color:
                    _detailsPrimaryGreen,
                size: 23,
              ),
              const SizedBox(
                width: 9,
              ),
              Text(
                isArabic
                    ? 'تعليمات المنتج'
                    : 'Product Instructions',
                style:
                    const TextStyle(
                  color:
                      _detailsTextPrimary,
                  fontSize: 18,
                  fontWeight:
                      FontWeight.w800,
                ),
              ),
            ],
          ),
          if (plantingInstructions
              .isNotEmpty) ...[
            const SizedBox(
              height: 18,
            ),
            _InstructionBlock(
              icon:
                  Icons.grass_rounded,
              title:
                  isArabic
                      ? 'تعليمات الزراعة'
                      : 'Planting Instructions',
              text:
                  plantingInstructions,
            ),
          ],
          if (irrigationInstructions
              .isNotEmpty) ...[
            const SizedBox(
              height: 14,
            ),
            _InstructionBlock(
              icon:
                  Icons.water_drop_outlined,
              title:
                  isArabic
                      ? 'تعليمات الري'
                      : 'Irrigation Instructions',
              text:
                  irrigationInstructions,
            ),
          ],
          if (usageInstructions
              .isNotEmpty) ...[
            const SizedBox(
              height: 14,
            ),
            _InstructionBlock(
              icon:
                  Icons.fact_check_outlined,
              title:
                  isArabic
                      ? 'تعليمات الاستخدام'
                      : 'Usage Instructions',
              text:
                  usageInstructions,
            ),
          ],
        ],
      ),
    );
  }
}

class _InfoPill
    extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color background;
  final Color foreground;

  const _InfoPill({
    required this.icon,
    required this.label,
    required this.background,
    required this.foreground,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    return Container(
      padding:
          const EdgeInsets.symmetric(
        horizontal: 11,
        vertical: 8,
      ),
      decoration:
          BoxDecoration(
        color: background,
        borderRadius:
            BorderRadius.circular(
          18,
        ),
      ),
      child: Row(
        mainAxisSize:
            MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 17,
            color: foreground,
          ),
          const SizedBox(
            width: 6,
          ),
          Flexible(
            child: Text(
              label,
              style:
                  TextStyle(
                color:
                    foreground,
                fontSize: 12,
                fontWeight:
                    FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SupplierInfoRow
    extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _SupplierInfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    return Row(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        Container(
          width: 38,
          height: 38,
          decoration:
              BoxDecoration(
            color:
                const Color(
              0xFFEAF3DF,
            ),
            borderRadius:
                BorderRadius.circular(
              12,
            ),
          ),
          child: Icon(
            icon,
            color:
                _detailsPrimaryGreen,
            size: 20,
          ),
        ),
        const SizedBox(
          width: 12,
        ),
        Expanded(
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style:
                    const TextStyle(
                  color:
                      _detailsTextSecondary,
                  fontSize: 11,
                  fontWeight:
                      FontWeight.w600,
                ),
              ),
              const SizedBox(
                height: 3,
              ),
              Text(
                value,
                style:
                    const TextStyle(
                  color:
                      _detailsTextPrimary,
                  fontSize: 14,
                  fontWeight:
                      FontWeight.w700,
                  height: 1.35,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _InstructionBlock
    extends StatelessWidget {
  final IconData icon;
  final String title;
  final String text;

  const _InstructionBlock({
    required this.icon,
    required this.title,
    required this.text,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    return Container(
      width: double.infinity,
      padding:
          const EdgeInsets.all(
        16,
      ),
      decoration:
          BoxDecoration(
        color:
            const Color(
          0xFFF7F9F4,
        ),
        borderRadius:
            BorderRadius.circular(
          16,
        ),
        border:
            Border.all(
          color:
              const Color(
            0xFFE3E9DF,
          ),
        ),
      ),
      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Container(
            width: 38,
            height: 38,
            decoration:
                BoxDecoration(
              color:
                  const Color(
                0xFFEAF3DF,
              ),
              borderRadius:
                  BorderRadius.circular(
                12,
              ),
            ),
            child: Icon(
              icon,
              color:
                  _detailsPrimaryGreen,
              size: 20,
            ),
          ),
          const SizedBox(
            width: 12,
          ),
          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style:
                      const TextStyle(
                    color:
                        _detailsTextPrimary,
                    fontSize: 14,
                    fontWeight:
                        FontWeight.w800,
                  ),
                ),
                const SizedBox(
                  height: 6,
                ),
                Text(
                  text,
                  style:
                      const TextStyle(
                    color:
                        _detailsTextSecondary,
                    fontSize: 13,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ProductDetailsBackdrop
    extends StatelessWidget {
  const _ProductDetailsBackdrop();

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
            end: -180,
            top: 200,
            child: Container(
              width: 460,
              height: 460,
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
                      alpha: 0.28,
                    ),
                    const Color(
                      0xFFCFE6B4,
                    ).withValues(
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
                      alpha: 0.22,
                    ),
                    const Color(
                      0xFFE7DFAF,
                    ).withValues(
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
