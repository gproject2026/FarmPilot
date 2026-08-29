import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_constants.dart';
import '../../models/supplier_cart_model.dart';
import '../../providers/locale_provider.dart';
import '../../providers/supplier_cart_provider.dart';
import '../../providers/supplier_order_provider.dart';
import 'farmer_supply_orders_screen.dart';

const Color _cartDarkGreen = Color(0xFF173F24);
const Color _cartPrimaryGreen = Color(0xFF2F6B3D);
const Color _cartLightGreen = Color(0xFFDDECB8);
const Color _cartBackground = Color(0xFFF8FAF4);
const Color _cartTextPrimary = Color(0xFF1D2C21);
const Color _cartTextSecondary = Color(0xFF68756B);

class SupplierCartScreen extends StatelessWidget {
  const SupplierCartScreen({
    super.key,
  });

  bool _isArabic(
    BuildContext context,
  ) {
    return Localizations.localeOf(context)
            .languageCode ==
        'ar';
  }

  

  @override
  Widget build(
    BuildContext context,
  ) {
    final cartProvider =
        Provider.of<SupplierCartProvider>(
      context,
    );

    final orderProvider =
        Provider.of<SupplierOrderProvider>(
      context,
    );

    final isArabic =
        _isArabic(
      context,
    );

    return Scaffold(
      backgroundColor:
          _cartBackground,
      body: Stack(
        children: [
          const Positioned.fill(
            child:
                _CartBackdrop(),
          ),
          CustomScrollView(
            physics:
                const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(
                child: _buildHeader(
                  context:
                      context,
                  cartProvider:
                      cartProvider,
                  orderProvider:
                      orderProvider,
                  isArabic:
                      isArabic,
                ),
              ),
              if (cartProvider.isEmpty)
                SliverFillRemaining(
                  hasScrollBody:
                      false,
                  child:
                      _EmptySupplierCart(
                    isArabic:
                        isArabic,
                  ),
                )
              else
                SliverToBoxAdapter(
                  child:
                      LayoutBuilder(
                    builder: (
                      context,
                      constraints,
                    ) {
                      final isWide =
                          constraints.maxWidth >=
                              980;

                      return Padding(
                        padding:
                            EdgeInsets.fromLTRB(
                          isWide
                              ? 42
                              : 18,
                          isWide
                              ? 28
                              : 20,
                          isWide
                              ? 42
                              : 18,
                          44,
                        ),
                        child:
                            isWide
                                ? Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Expanded(
                                        flex: 13,
                                        child:
                                            _buildItemsSection(
                                          cartProvider:
                                              cartProvider,
                                          orderProvider:
                                              orderProvider,
                                          isArabic:
                                              isArabic,
                                        ),
                                      ),
                                      const SizedBox(
                                        width: 24,
                                      ),
                                      SizedBox(
                                        width: 360,
                                        child:
                                            _SupplierCartSummary(
                                          isArabic:
                                              isArabic,
                                          totalQuantity:
                                              cartProvider.totalQuantity,
                                          totalPrice:
                                              cartProvider.totalPrice,
                                          isLoading:
                                              orderProvider.isCreatingOrder,
                                          onCheckout:
                                              () => _checkout(
                                            context,
                                          ),
                                        ),
                                      ),
                                    ],
                                  )
                                : Column(
                                    children: [
                                      _buildItemsSection(
                                        cartProvider:
                                            cartProvider,
                                        orderProvider:
                                            orderProvider,
                                        isArabic:
                                            isArabic,
                                      ),
                                      const SizedBox(
                                        height: 20,
                                      ),
                                      _SupplierCartSummary(
                                        isArabic:
                                            isArabic,
                                        totalQuantity:
                                            cartProvider.totalQuantity,
                                        totalPrice:
                                            cartProvider.totalPrice,
                                        isLoading:
                                            orderProvider.isCreatingOrder,
                                        onCheckout:
                                            () => _checkout(
                                          context,
                                        ),
                                      ),
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

  Widget _buildHeader({
    required BuildContext context,
    required SupplierCartProvider
        cartProvider,
    required SupplierOrderProvider
        orderProvider,
    required bool isArabic,
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
                _cartDarkGreen.withValues(
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
            _HeaderButton(
              icon:
                  Icons.arrow_back_rounded,
              tooltip:
                  isArabic
                      ? 'رجوع'
                      : 'Back',
              onTap: () {
                Navigator.pop(
                  context,
                );
              },
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
                    _cartLightGreen,
                borderRadius:
                    BorderRadius.circular(
                  13,
                ),
              ),
              child:
                  const Icon(
                Icons.agriculture_outlined,
                color:
                    _cartDarkGreen,
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
                      fontSize: 19,
                      fontWeight:
                          FontWeight.w800,
                    ),
                  ),
                  const SizedBox(
                    height: 2,
                  ),
                  Text(
                    isArabic
                        ? 'سلة المستلزمات'
                        : 'Supply Cart',
                    style:
                        const TextStyle(
                      color:
                          Color(
                        0xCCFFFFFF,
                      ),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            PopupMenuButton<String>(
              tooltip:
                  isArabic
                      ? 'تغيير اللغة'
                      : 'Change Language',
              offset:
                  const Offset(
                0,
                48,
              ),
              position:
                  PopupMenuPosition.under,
              color:
                  const Color(
                0xFFF8FAF4,
              ),
              elevation: 8,
              shape:
                  RoundedRectangleBorder(
                borderRadius:
                    BorderRadius.circular(
                  16,
                ),
              ),
              onSelected:
                  (
                languageCode,
              ) {
                Provider.of<
                    LocaleProvider>(
                  context,
                  listen: false,
                ).setLocale(
                  Locale(
                    languageCode,
                  ),
                );
              },
              itemBuilder:
                  (
                context,
              ) {
                return [
                  PopupMenuItem<String>(
                    value: 'en',
                    child: Row(
                      mainAxisSize:
                          MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.check_rounded,
                          size: 20,
                          color:
                              !isArabic
                                  ? _cartPrimaryGreen
                                  : Colors.transparent,
                        ),
                        const SizedBox(
                          width: 10,
                        ),
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
                      mainAxisSize:
                          MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.check_rounded,
                          size: 20,
                          color:
                              isArabic
                                  ? _cartPrimaryGreen
                                  : Colors.transparent,
                        ),
                        const SizedBox(
                          width: 10,
                        ),
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
                alignment:
                    Alignment.center,
                child:
                    const Icon(
                  Icons.language_rounded,
                  color:
                      Colors.white,
                  size: 21,
                ),
              ),
            ),
            const SizedBox(
              width: 8,
            ),
            if (!cartProvider.isEmpty)
              _HeaderButton(
                icon:
                    Icons.delete_sweep_outlined,
                tooltip:
                    isArabic
                        ? 'تفريغ السلة'
                        : 'Clear cart',
                onTap:
                    orderProvider
                            .isCreatingOrder
                        ? null
                        : () {
                            _showClearCartDialog(
                              context,
                              cartProvider,
                            );
                          },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildItemsSection({
    required SupplierCartProvider
        cartProvider,
    required SupplierOrderProvider
        orderProvider,
    required bool isArabic,
  }) {
    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        _SectionHeading(
          icon:
              Icons.shopping_cart_outlined,
          title:
              isArabic
                  ? 'سلة المستلزمات'
                  : 'Your Supply Cart',
          subtitle:
              isArabic
                  ? 'راجع المستلزمات وعدّل الكميات قبل إتمام الطلب.'
                  : 'Review supplies and adjust quantities before checkout.',
        ),
        const SizedBox(
          height: 16,
        ),
        ...List.generate(
          cartProvider.items.length,
          (
            index,
          ) {
            final item =
                cartProvider.items[index];

            return Padding(
              padding:
                  EdgeInsets.only(
                bottom:
                    index ==
                            cartProvider.items
                                    .length -
                                1
                        ? 0
                        : 14,
              ),
              child:
                  _SupplierCartItemCard(
                item:
                    item,
                isArabic:
                    isArabic,
                isLoading:
                    orderProvider.isCreatingOrder,
              ),
            );
          },
        ),
      ],
    );
  }

  Future<void> _checkout(
    BuildContext context,
  ) async {
    final cartProvider =
        Provider.of<SupplierCartProvider>(
      context,
      listen: false,
    );

    final orderProvider =
        Provider.of<SupplierOrderProvider>(
      context,
      listen: false,
    );

    final isArabic =
        _isArabic(
      context,
    );

    if (cartProvider.isEmpty) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(
              isArabic
                  ? 'سلة المستلزمات فارغة'
                  : 'Your supply cart is empty',
            ),
          ),
        );

      return;
    }

    final checkoutDetails =
        await _showCheckoutDialog(
      context,
      cartProvider.totalPrice,
    );

    if (checkoutDetails == null ||
        !context.mounted) {
      return;
    }

    final success =
        await orderProvider
            .createSupplierOrder(
      items:
          cartProvider.toOrderItems(),
      deliveryMethod:
          checkoutDetails.deliveryMethod,
      deliveryAddress:
          checkoutDetails.deliveryAddress,
      paymentMethod:
          'CASH',
    );

    if (!context.mounted) {
      return;
    }

    if (success) {
      cartProvider.clearCart();

      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(
              isArabic
                  ? 'تم إنشاء طلب المستلزمات بنجاح'
                  : 'Supply order created successfully',
            ),
            backgroundColor:
                _cartPrimaryGreen,
          ),
        );

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder:
              (_) =>
                  const FarmerSupplyOrdersScreen(),
        ),
      );
    } else {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(
              orderProvider.errorMessage ??
                  (isArabic
                      ? 'فشل إنشاء طلب المستلزمات'
                      : 'Failed to create supply order'),
            ),
            backgroundColor:
                Colors.red,
          ),
        );
    }
  }

  Future<_SupplierCheckoutDetails?>
      _showCheckoutDialog(
    BuildContext context,
    double totalPrice,
  ) async {
    final isArabic =
        _isArabic(
      context,
    );

    final addressController =
        TextEditingController();

    String deliveryMethod =
        'PICKUP';

    String? validationMessage;

    try {
      return await showDialog<
          _SupplierCheckoutDetails>(
        context: context,
        builder:
            (
          dialogContext,
        ) {
          return StatefulBuilder(
            builder: (
              context,
              setDialogState,
            ) {
              final isDelivery =
                  deliveryMethod ==
                      'DELIVERY';

              return AlertDialog(
                backgroundColor:
                    const Color(
                  0xFFFFFEFA,
                ),
                shape:
                    RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(
                    24,
                  ),
                ),
                title: Row(
                  children: [
                    const Icon(
                      Icons.shopping_bag_outlined,
                      color:
                          _cartPrimaryGreen,
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    Expanded(
                      child: Text(
                        isArabic
                            ? 'إتمام طلب المستلزمات'
                            : 'Supply Checkout',
                        style:
                            const TextStyle(
                          fontWeight:
                              FontWeight.w800,
                        ),
                      ),
                    ),
                  ],
                ),
                content:
                    SingleChildScrollView(
                  child: SizedBox(
                    width: 470,
                    child: Column(
                      mainAxisSize:
                          MainAxisSize.min,
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        Container(
                          width:
                              double.infinity,
                          padding:
                              const EdgeInsets.all(
                            14,
                          ),
                          decoration:
                              BoxDecoration(
                            color:
                                const Color(
                              0xFFEAF3DF,
                            ),
                            borderRadius:
                                BorderRadius.circular(
                              16,
                            ),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.receipt_long_outlined,
                                color:
                                    _cartPrimaryGreen,
                              ),
                              const SizedBox(
                                width: 10,
                              ),
                              Expanded(
                                child: Text(
                                  isArabic
                                      ? 'الإجمالي'
                                      : 'Order total',
                                  style:
                                      const TextStyle(
                                    color:
                                        _cartTextSecondary,
                                    fontWeight:
                                        FontWeight.w600,
                                  ),
                                ),
                              ),
                              Text(
                                '${totalPrice.toStringAsFixed(2)} ₪',
                                style:
                                    const TextStyle(
                                  color:
                                      _cartPrimaryGreen,
                                  fontSize: 18,
                                  fontWeight:
                                      FontWeight.w800,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        Text(
                          isArabic
                              ? 'طريقة الاستلام'
                              : 'Delivery Method',
                          style:
                              const TextStyle(
                            color:
                                _cartTextPrimary,
                            fontSize: 16,
                            fontWeight:
                                FontWeight.w800,
                          ),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        _CheckoutChoiceTile(
                          title:
                              isArabic
                                  ? 'استلام من المورد'
                                  : 'Pickup from Supplier',
                          subtitle:
                              isArabic
                                  ? 'سيتم استخدام موقع متجر المورد كموقع للاستلام.'
                                  : 'The supplier store location will be used for pickup.',
                          icon:
                              Icons.storefront_outlined,
                          selected:
                              deliveryMethod ==
                                  'PICKUP',
                          onTap: () {
                            setDialogState(
                              () {
                                deliveryMethod =
                                    'PICKUP';
                                validationMessage =
                                    null;
                              },
                            );
                          },
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        _CheckoutChoiceTile(
                          title:
                              isArabic
                                  ? 'توصيل'
                                  : 'Delivery',
                          subtitle:
                              isArabic
                                  ? 'أدخل العنوان الذي تريد توصيل المستلزمات إليه.'
                                  : 'Enter the address where you want the supplies delivered.',
                          icon:
                              Icons.local_shipping_outlined,
                          selected:
                              deliveryMethod ==
                                  'DELIVERY',
                          onTap: () {
                            setDialogState(
                              () {
                                deliveryMethod =
                                    'DELIVERY';
                                validationMessage =
                                    null;
                              },
                            );
                          },
                        ),
                        if (isDelivery) ...[
                          const SizedBox(
                            height: 16,
                          ),
                          TextField(
                            controller:
                                addressController,
                            keyboardType:
                                TextInputType.streetAddress,
                            textInputAction:
                                TextInputAction.done,
                            maxLines: 3,
                            minLines: 1,
                            onChanged:
                                (_) {
                              if (validationMessage !=
                                  null) {
                                setDialogState(
                                  () {
                                    validationMessage =
                                        null;
                                  },
                                );
                              }
                            },
                            decoration:
                                InputDecoration(
                              labelText:
                                  isArabic
                                      ? 'عنوان التوصيل'
                                      : 'Delivery Address',
                              hintText:
                                  isArabic
                                      ? 'مثال: المدينة، الحي، الشارع...'
                                      : 'Example: city, neighborhood, street...',
                              prefixIcon:
                                  const Icon(
                                Icons.location_on_outlined,
                              ),
                              errorText:
                                  validationMessage,
                              filled: true,
                              fillColor:
                                  Colors.white,
                              border:
                                  OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.circular(
                                  14,
                                ),
                                borderSide:
                                    const BorderSide(
                                  color:
                                      Color(
                                    0xFFDDE6D8,
                                  ),
                                ),
                              ),
                              enabledBorder:
                                  OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.circular(
                                  14,
                                ),
                                borderSide:
                                    const BorderSide(
                                  color:
                                      Color(
                                    0xFFDDE6D8,
                                  ),
                                ),
                              ),
                              focusedBorder:
                                  OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.circular(
                                  14,
                                ),
                                borderSide:
                                    const BorderSide(
                                  color:
                                      _cartPrimaryGreen,
                                  width: 1.5,
                                ),
                              ),
                            ),
                          ),
                        ],
                        const SizedBox(
                          height: 20,
                        ),
                        Text(
                          isArabic
                              ? 'طريقة الدفع'
                              : 'Payment Method',
                          style:
                              const TextStyle(
                            color:
                                _cartTextPrimary,
                            fontSize: 16,
                            fontWeight:
                                FontWeight.w800,
                          ),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        Container(
                          width:
                              double.infinity,
                          padding:
                              const EdgeInsets.all(
                            14,
                          ),
                          decoration:
                              BoxDecoration(
                            color:
                                const Color(
                              0xFFF5F8F0,
                            ),
                            borderRadius:
                                BorderRadius.circular(
                              16,
                            ),
                            border:
                                Border.all(
                              color:
                                  const Color(
                                0xFFDDE6D8,
                              ),
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 42,
                                height: 42,
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
                                child:
                                    const Icon(
                                  Icons.payments_outlined,
                                  color:
                                      _cartPrimaryGreen,
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
                                      isDelivery
                                          ? (isArabic
                                              ? 'الدفع نقدًا عند التوصيل'
                                              : 'Cash on Delivery')
                                          : (isArabic
                                              ? 'الدفع نقدًا عند الاستلام'
                                              : 'Cash on Pickup'),
                                      style:
                                          const TextStyle(
                                        color:
                                            _cartTextPrimary,
                                        fontWeight:
                                            FontWeight.w800,
                                      ),
                                    ),
                                    const SizedBox(
                                      height: 3,
                                    ),
                                    Text(
                                      isArabic
                                          ? 'الدفع الإلكتروني غير مطلوب.'
                                          : 'No online payment is required.',
                                      style:
                                          const TextStyle(
                                        color:
                                            _cartTextSecondary,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const Icon(
                                Icons.check_circle_rounded,
                                color:
                                    _cartPrimaryGreen,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(
                        dialogContext,
                      ).pop();
                    },
                    child: Text(
                      isArabic
                          ? 'إلغاء'
                          : 'Cancel',
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: () {
                      final normalizedAddress =
                          addressController.text
                              .trim();

                      if (isDelivery &&
                          normalizedAddress
                              .isEmpty) {
                        setDialogState(
                          () {
                            validationMessage =
                                isArabic
                                    ? 'عنوان التوصيل مطلوب'
                                    : 'Delivery address is required';
                          },
                        );

                        return;
                      }

                      Navigator.of(
                        dialogContext,
                      ).pop(
                        _SupplierCheckoutDetails(
                          deliveryMethod:
                              deliveryMethod,
                          deliveryAddress:
                              isDelivery
                                  ? normalizedAddress
                                  : null,
                        ),
                      );
                    },
                    style:
                        ElevatedButton.styleFrom(
                      backgroundColor:
                          _cartPrimaryGreen,
                      foregroundColor:
                          Colors.white,
                      elevation: 0,
                      shape:
                          RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(
                          12,
                        ),
                      ),
                    ),
                    icon:
                        const Icon(
                      Icons.check_rounded,
                    ),
                    label: Text(
                      isArabic
                          ? 'إنشاء الطلب'
                          : 'Create Order',
                    ),
                  ),
                ],
              );
            },
          );
        },
      );
    } finally {
      addressController.dispose();
    }
  }

  void _showClearCartDialog(
    BuildContext context,
    SupplierCartProvider cartProvider,
  ) {
    showDialog<void>(
      context: context,
      builder:
          (
        dialogContext,
      ) {
        final isArabic =
            _isArabic(
          context,
        );

        return AlertDialog(
          backgroundColor:
              const Color(
            0xFFFFFEFA,
          ),
          shape:
              RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(
              24,
            ),
          ),
          title: Row(
            children: [
              const Icon(
                Icons.delete_sweep_outlined,
                color:
                    Colors.red,
              ),
              const SizedBox(
                width: 10,
              ),
              Text(
                isArabic
                    ? 'تفريغ السلة'
                    : 'Clear Cart',
              ),
            ],
          ),
          content: Text(
            isArabic
                ? 'هل أنت متأكد من إزالة جميع المستلزمات من السلة؟'
                : 'Are you sure you want to remove all supplies from the cart?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(
                  dialogContext,
                ).pop();
              },
              child: Text(
                isArabic
                    ? 'إلغاء'
                    : 'Cancel',
              ),
            ),
            TextButton(
              onPressed: () {
                cartProvider
                    .clearCart();

                Navigator.of(
                  dialogContext,
                ).pop();
              },
              child: Text(
                isArabic
                    ? 'تفريغ'
                    : 'Clear',
                style:
                    const TextStyle(
                  color:
                      Colors.red,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _SupplierCheckoutDetails {
  final String deliveryMethod;
  final String? deliveryAddress;

  const _SupplierCheckoutDetails({
    required this.deliveryMethod,
    this.deliveryAddress,
  });
}

class _CheckoutChoiceTile
    extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const _CheckoutChoiceTile({
    required this.title,
    required this.subtitle,
    required this.icon,
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
              ? const Color(
                  0xFFEAF3DF,
                )
              : Colors.white,
      borderRadius:
          BorderRadius.circular(
        16,
      ),
      child: InkWell(
        onTap:
            onTap,
        borderRadius:
            BorderRadius.circular(
          16,
        ),
        child: Container(
          width:
              double.infinity,
          padding:
              const EdgeInsets.all(
            14,
          ),
          decoration:
              BoxDecoration(
            borderRadius:
                BorderRadius.circular(
              16,
            ),
            border:
                Border.all(
              color:
                  selected
                      ? _cartPrimaryGreen
                      : const Color(
                          0xFFDDE6D8,
                        ),
              width:
                  selected
                      ? 1.5
                      : 1,
            ),
          ),
          child: Row(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Container(
                width: 42,
                height: 42,
                decoration:
                    BoxDecoration(
                  color:
                      selected
                          ? Colors.white
                          : const Color(
                              0xFFF5F8F0,
                            ),
                  borderRadius:
                      BorderRadius.circular(
                    12,
                  ),
                ),
                child: Icon(
                  icon,
                  color:
                      _cartPrimaryGreen,
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
                            _cartTextPrimary,
                        fontWeight:
                            FontWeight.w800,
                      ),
                    ),
                    const SizedBox(
                      height: 4,
                    ),
                    Text(
                      subtitle,
                      style:
                          const TextStyle(
                        color:
                            _cartTextSecondary,
                        fontSize: 12,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(
                width: 8,
              ),
              Icon(
                selected
                    ? Icons.radio_button_checked_rounded
                    : Icons.radio_button_off_rounded,
                color:
                    selected
                        ? _cartPrimaryGreen
                        : const Color(
                            0xFF9AA59B,
                          ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HeaderButton
    extends StatelessWidget {
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

class _SectionHeading
    extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _SectionHeading({
    required this.icon,
    required this.title,
    required this.subtitle,
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
          width: 48,
          height: 48,
          decoration:
              BoxDecoration(
            color:
                const Color(
              0xFFEAF3DF,
            ),
            borderRadius:
                BorderRadius.circular(
              15,
            ),
          ),
          child: Icon(
            icon,
            color:
                _cartPrimaryGreen,
            size: 24,
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
                      _cartTextPrimary,
                  fontSize: 22,
                  fontWeight:
                      FontWeight.w800,
                ),
              ),
              const SizedBox(
                height: 4,
              ),
              Text(
                subtitle,
                style:
                    const TextStyle(
                  color:
                      _cartTextSecondary,
                  fontSize: 13,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SupplierCartItemCard
    extends StatelessWidget {
  final SupplierCartItem item;
  final bool isArabic;
  final bool isLoading;

  const _SupplierCartItemCard({
    required this.item,
    required this.isArabic,
    required this.isLoading,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    final cartProvider =
        Provider.of<SupplierCartProvider>(
      context,
      listen: false,
    );

    return Container(
      padding:
          const EdgeInsets.all(
        14,
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
                _cartDarkGreen.withValues(
              alpha: 0.045,
            ),
            blurRadius: 18,
            offset:
                const Offset(
              0,
              7,
            ),
          ),
        ],
      ),
      child: LayoutBuilder(
        builder: (
          context,
          constraints,
        ) {
          final compact =
              constraints.maxWidth <
                  540;

          if (compact) {
            return Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    _ProductImage(
                      imageUrl:
                          item.imageUrl,
                      width: 96,
                      height: 108,
                    ),
                    const SizedBox(
                      width: 12,
                    ),
                    Expanded(
                      child:
                          _ProductInfo(
                        item:
                            item,
                        isArabic:
                            isArabic,
                      ),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 14,
                ),
                _buildControls(
                  context:
                      context,
                  cartProvider:
                      cartProvider,
                ),
              ],
            );
          }

          return Row(
            crossAxisAlignment:
                CrossAxisAlignment.center,
            children: [
              _ProductImage(
                imageUrl:
                    item.imageUrl,
                width: 110,
                height: 118,
              ),
              const SizedBox(
                width: 16,
              ),
              Expanded(
                child:
                    _ProductInfo(
                  item:
                      item,
                  isArabic:
                      isArabic,
                ),
              ),
              const SizedBox(
                width: 18,
              ),
              SizedBox(
                width: 190,
                child:
                    _buildControls(
                  context:
                      context,
                  cartProvider:
                      cartProvider,
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildControls({
    required BuildContext context,
    required SupplierCartProvider
        cartProvider,
  }) {
    return Row(
      children: [
        _QuantityButton(
          icon:
              item.quantity > 1
                  ? Icons.remove_rounded
                  : Icons.delete_outline_rounded,
          onPressed:
              isLoading
                  ? null
                  : () {
                      cartProvider
                          .decreaseQuantity(
                        item.productId,
                      );
                    },
        ),
        Expanded(
          child: Container(
            alignment:
                Alignment.center,
            child: Text(
              item.quantity
                  .toString(),
              style:
                  const TextStyle(
                color:
                    _cartTextPrimary,
                fontSize: 17,
                fontWeight:
                    FontWeight.w800,
              ),
            ),
          ),
        ),
        _QuantityButton(
          icon:
              Icons.add_rounded,
          onPressed:
              isLoading ||
                      !item.canIncrease
                  ? null
                  : () {
                      cartProvider
                          .increaseQuantity(
                        item.productId,
                      );
                    },
        ),
        const SizedBox(
          width: 8,
        ),
        IconButton(
          onPressed:
              isLoading
                  ? null
                  : () {
                      cartProvider
                          .removeItem(
                        item.productId,
                      );
                    },
          tooltip:
              isArabic
                  ? 'إزالة المنتج'
                  : 'Remove product',
          style:
              IconButton.styleFrom(
            backgroundColor:
                const Color(
              0xFFFCE7E7,
            ),
            foregroundColor:
                const Color(
              0xFFB44F4F,
            ),
          ),
          icon:
              const Icon(
            Icons.delete_outline_rounded,
          ),
        ),
      ],
    );
  }
}

class _ProductInfo
    extends StatelessWidget {
  final SupplierCartItem item;
  final bool isArabic;

  const _ProductInfo({
    required this.item,
    required this.isArabic,
  });

  String _localizedUnit(
    String unit,
  ) {
    if (!isArabic) {
      return unit;
    }

    switch (unit
        .trim()
        .toLowerCase()) {
      case 'kg':
        return 'كغ';
      case 'g':
      case 'gram':
      case 'grams':
        return 'غ';
      case 'l':
      case 'liter':
      case 'litre':
        return 'لتر';
      case 'piece':
      case 'pieces':
      case 'pc':
      case 'pcs':
        return 'قطعة';
      case 'packet':
      case 'packets':
        return 'عبوة';
      case 'bag':
      case 'bags':
        return 'كيس';
      case 'bottle':
      case 'bottles':
        return 'عبوة';
      default:
        return unit;
    }
  }

  @override
  Widget build(
    BuildContext context,
  ) {
    final displayUnit =
        _localizedUnit(
      item.unit,
    );

    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        Text(
          item.name,
          maxLines: 2,
          overflow:
              TextOverflow.ellipsis,
          style:
              const TextStyle(
            color:
                _cartTextPrimary,
            fontSize: 17,
            fontWeight:
                FontWeight.w800,
          ),
        ),
        const SizedBox(
          height: 7,
        ),
        Text(
          '${item.price.toStringAsFixed(2)} ₪'
          '${displayUnit.isEmpty ? '' : ' / $displayUnit'}',
          style:
              const TextStyle(
            color:
                _cartTextSecondary,
            fontSize: 13,
          ),
        ),
        const SizedBox(
          height: 7,
        ),
        Text(
          '${isArabic ? 'المتوفر' : 'Available'}: '
          '${item.availableQuantity}'
          '${displayUnit.isEmpty ? '' : ' $displayUnit'}',
          style:
              const TextStyle(
            color:
                _cartTextSecondary,
            fontSize: 12,
          ),
        ),
        const SizedBox(
          height: 9,
        ),
        Container(
          padding:
              const EdgeInsets.symmetric(
            horizontal: 10,
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
              18,
            ),
          ),
          child: Text(
            '${isArabic ? 'المجموع الفرعي' : 'Subtotal'}: '
            '${item.totalPrice.toStringAsFixed(2)} ₪',
            style:
                const TextStyle(
              color:
                  _cartPrimaryGreen,
              fontSize: 12,
              fontWeight:
                  FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}

class _ProductImage
    extends StatelessWidget {
  final String? imageUrl;
  final double width;
  final double height;

  const _ProductImage({
    required this.imageUrl,
    required this.width,
    required this.height,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    final hasImage =
        imageUrl != null &&
        imageUrl!
            .trim()
            .isNotEmpty;

    return ClipRRect(
      borderRadius:
          BorderRadius.circular(
        16,
      ),
      child: Container(
        width: width,
        height: height,
        color:
            const Color(
          0xFFF0F5EB,
        ),
        child:
            hasImage
                ? Image.network(
                    _buildImageUrl(
                      imageUrl!,
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
                        child: Icon(
                          Icons.image_not_supported_outlined,
                          size: 42,
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
                      size: 45,
                      color:
                          _cartPrimaryGreen,
                    ),
                  ),
      ),
    );
  }

  String _buildImageUrl(
    String value,
  ) {
    final trimmed =
        value.trim();

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

    if (trimmed.startsWith(
          'http://',
        ) ||
        trimmed.startsWith(
          'https://',
        )) {
      return trimmed;
    }

    final normalized =
        trimmed.startsWith('/')
            ? trimmed
            : '/$trimmed';

    return '${AppConstants.baseUrl}$normalized';
  }
}

class _QuantityButton
    extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;

  const _QuantityButton({
    required this.icon,
    required this.onPressed,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    return SizedBox(
      width: 38,
      height: 38,
      child: IconButton(
        padding:
            EdgeInsets.zero,
        onPressed:
            onPressed,
        icon: Icon(
          icon,
          size: 19,
        ),
        style:
            IconButton.styleFrom(
          backgroundColor:
              const Color(
            0xFFEAF3DF,
          ),
          foregroundColor:
              _cartPrimaryGreen,
          disabledBackgroundColor:
              const Color(
            0xFFF1F3EF,
          ),
          disabledForegroundColor:
              const Color(
            0xFFADB5AD,
          ),
        ),
      ),
    );
  }
}

class _SupplierCartSummary
    extends StatelessWidget {
  final bool isArabic;
  final int totalQuantity;
  final double totalPrice;
  final bool isLoading;
  final VoidCallback onCheckout;

  const _SupplierCartSummary({
    required this.isArabic,
    required this.totalQuantity,
    required this.totalPrice,
    required this.isLoading,
    required this.onCheckout,
  });

  @override
  Widget build(
    BuildContext context,
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
          24,
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
                _cartDarkGreen.withValues(
              alpha: 0.055,
            ),
            blurRadius: 20,
            offset:
                const Offset(
              0,
              8,
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
                Icons.receipt_long_outlined,
                color:
                    _cartPrimaryGreen,
                size: 22,
              ),
              const SizedBox(
                width: 9,
              ),
              Text(
                isArabic
                    ? 'ملخص الطلب'
                    : 'Order Summary',
                style:
                    const TextStyle(
                  color:
                      _cartTextPrimary,
                  fontSize: 20,
                  fontWeight:
                      FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(
            height: 20,
          ),
          _SummaryRow(
            label:
                isArabic
                    ? 'إجمالي المنتجات'
                    : 'Total items',
            value:
                totalQuantity.toString(),
          ),
          const SizedBox(
            height: 12,
          ),
          const Divider(
            color:
                Color(
              0xFFE1E8DD,
            ),
          ),
          const SizedBox(
            height: 12,
          ),
          _SummaryRow(
            label:
                isArabic
                    ? 'السعر الإجمالي'
                    : 'Total price',
            value:
                '${totalPrice.toStringAsFixed(2)} ₪',
            emphasize:
                true,
          ),
          const SizedBox(
            height: 20,
          ),
          SizedBox(
            width:
                double.infinity,
            height: 52,
            child:
                ElevatedButton.icon(
              onPressed:
                  isLoading
                      ? null
                      : onCheckout,
              style:
                  ElevatedButton.styleFrom(
                backgroundColor:
                    _cartPrimaryGreen,
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
                    15,
                  ),
                ),
              ),
              icon:
                  isLoading
                      ? const SizedBox(
                          width: 21,
                          height: 21,
                          child:
                              CircularProgressIndicator(
                            strokeWidth:
                                2,
                            color:
                                Colors.white,
                          ),
                        )
                      : const Icon(
                          Icons.shopping_bag_outlined,
                        ),
              label: Text(
                isLoading
                    ? (isArabic
                        ? 'جارٍ إنشاء الطلب...'
                        : 'Creating Order...')
                    : (isArabic
                        ? 'إتمام الشراء'
                        : 'Checkout'),
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
}

class _SummaryRow
    extends StatelessWidget {
  final String label;
  final String value;
  final bool emphasize;

  const _SummaryRow({
    required this.label,
    required this.value,
    this.emphasize = false,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style:
                TextStyle(
              color:
                  emphasize
                      ? _cartTextPrimary
                      : _cartTextSecondary,
              fontSize:
                  emphasize
                      ? 16
                      : 14,
              fontWeight:
                  emphasize
                      ? FontWeight.w700
                      : FontWeight.w500,
            ),
          ),
        ),
        Text(
          value,
          style:
              TextStyle(
            color:
                emphasize
                    ? _cartPrimaryGreen
                    : _cartTextPrimary,
            fontSize:
                emphasize
                    ? 21
                    : 15,
            fontWeight:
                FontWeight.w800,
          ),
        ),
      ],
    );
  }
}

class _EmptySupplierCart
    extends StatelessWidget {
  final bool isArabic;

  const _EmptySupplierCart({
    required this.isArabic,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    return Center(
      child: Padding(
        padding:
            const EdgeInsets.all(
          24,
        ),
        child: Container(
          constraints:
              const BoxConstraints(
            maxWidth: 480,
          ),
          padding:
              const EdgeInsets.all(
            30,
          ),
          decoration:
              BoxDecoration(
            color:
                Colors.white,
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
                    _cartDarkGreen.withValues(
                  alpha: 0.05,
                ),
                blurRadius: 20,
                offset:
                    const Offset(
                  0,
                  8,
                ),
              ),
            ],
          ),
          child: Column(
            mainAxisSize:
                MainAxisSize.min,
            children: [
              Container(
                width: 92,
                height: 92,
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
                  Icons.shopping_cart_outlined,
                  size: 46,
                  color:
                      _cartPrimaryGreen,
                ),
              ),
              const SizedBox(
                height: 18,
              ),
              Text(
                isArabic
                    ? 'سلة المستلزمات فارغة'
                    : 'Your supply cart is empty',
                textAlign:
                    TextAlign.center,
                style:
                    const TextStyle(
                  color:
                      _cartTextPrimary,
                  fontSize: 22,
                  fontWeight:
                      FontWeight.w800,
                ),
              ),
              const SizedBox(
                height: 8,
              ),
              Text(
                isArabic
                    ? 'أضف مستلزمات زراعية من متجر الموردين لإنشاء طلب.'
                    : 'Add agricultural supplies from the supplier marketplace to create an order.',
                textAlign:
                    TextAlign.center,
                style:
                    const TextStyle(
                  color:
                      _cartTextSecondary,
                  fontSize: 14,
                  height: 1.5,
                ),
              ),
              const SizedBox(
                height: 18,
              ),
              Text(
                isArabic
                    ? 'يمكنك الرجوع للمتجر من زر الرجوع وإضافة المنتجات.'
                    : 'Go back to the marketplace and add products to your cart.',
                textAlign:
                    TextAlign.center,
                style:
                    const TextStyle(
                  color:
                      _cartPrimaryGreen,
                  fontSize: 13,
                  fontWeight:
                      FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CartBackdrop
    extends StatelessWidget {
  const _CartBackdrop();

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
            end: -190,
            top: 210,
            child: Container(
              width: 470,
              height: 470,
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
