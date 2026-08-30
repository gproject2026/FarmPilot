import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_constants.dart';
import '../../models/cart_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/cart_provider.dart';
import '../../providers/locale_provider.dart';
import '../../providers/order_provider.dart';
import '../../providers/product_provider.dart';
import 'customer_orders_screen.dart';
import 'customer_products_screen.dart';

const Color _cartDarkGreen = Color(0xFF173F24);
const Color _cartPrimaryGreen = Color(0xFF2F6B3D);
const Color _cartLightGreen = Color(0xFFDDECB8);
const Color _cartBackground = Color(0xFFF8FAF4);
const Color _cartTextPrimary = Color(0xFF1D2C21);
const Color _cartTextSecondary = Color(0xFF68756B);

String _localizedCartProductName(String name, bool isArabic) {
  if (!isArabic) {
    return name;
  }

  final key = name.trim().toLowerCase();

  const translations = <String, String>{
    'orange': 'برتقال',
    'fresh mint': 'نعناع طازج',
    'fresh parsley': 'بقدونس طازج',
    'fresh rosemary': 'إكليل الجبل الطازج',
    'mountain sidr honey': 'عسل سدر جبلي',
    'watermelon': 'بطيخ',
    'cabbage': 'ملفوف',
    'apples': 'تفاح',
    'apple': 'تفاح',
    'limon': 'ليمون',
    'lemon': 'ليمون',
    'tomato': 'طماطم',
    'tomatoes': 'طماطم',
    'strawberry': 'فراولة',
    'strawberries': 'فراولة',
    'cauliflower': 'قرنبيط',
    'carrots': 'جزر',
    'carrot': 'جزر',
    'cucumber': 'خيار',
    'cucumbers': 'خيار',
    'lettuce': 'خس',
    'potato': 'بطاطا',
    'potatoes': 'بطاطا',
    'onion': 'بصل',
    'onions': 'بصل',
    'garlic': 'ثوم',
    'pepper': 'فلفل',
    'peppers': 'فلفل',
    'corn': 'ذرة',
    'grapes': 'عنب',
    'grape': 'عنب',
  };

  return translations[key] ?? name;
}

String _localizedCartUnit(String unit, bool isArabic) {
  if (!isArabic) {
    return unit;
  }

  switch (unit.trim().toLowerCase()) {
    case 'kg':
      return 'كغ';
    case 'ton':
    case 'tons':
      return 'طن';
    case 'box':
    case 'boxes':
      return 'صندوق';
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
    default:
      return unit;
  }
}

class CustomerCartScreen extends StatelessWidget {
  const CustomerCartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cartProvider = Provider.of<CartProvider>(context);
    final orderProvider = Provider.of<OrderProvider>(context);

    final isArabic = Localizations.localeOf(context).languageCode == 'ar';

    return Scaffold(
      backgroundColor: _cartBackground,
      body: Stack(
        children: [
          const Positioned.fill(child: _CartBackdrop()),
          CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(
                child: _buildHeader(
                  context: context,
                  cartProvider: cartProvider,
                  orderProvider: orderProvider,
                  isArabic: isArabic,
                ),
              ),
              if (cartProvider.isEmpty)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: _EmptyCart(isArabic: isArabic),
                )
              else
                SliverToBoxAdapter(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final isWide = constraints.maxWidth >= 980;

                      return Padding(
                        padding: EdgeInsets.fromLTRB(
                          isWide ? 42 : 18,
                          isWide ? 28 : 20,
                          isWide ? 42 : 18,
                          44,
                        ),
                        child: isWide
                            ? Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    flex: 13,
                                    child: _buildItemsSection(
                                      cartProvider: cartProvider,
                                      orderProvider: orderProvider,
                                      isArabic: isArabic,
                                    ),
                                  ),
                                  const SizedBox(width: 24),
                                  SizedBox(
                                    width: 360,
                                    child: _CartSummary(
                                      isArabic: isArabic,
                                      totalQuantity: cartProvider.itemCount.toDouble(),
                                      totalPrice: cartProvider.totalPrice,
                                      isLoading: orderProvider.isLoading,
                                      onCheckout: () => _checkout(context),
                                    ),
                                  ),
                                ],
                              )
                            : Column(
                                children: [
                                  _buildItemsSection(
                                    cartProvider: cartProvider,
                                    orderProvider: orderProvider,
                                    isArabic: isArabic,
                                  ),
                                  const SizedBox(height: 20),
                                  _CartSummary(
                                    isArabic: isArabic,
                                    totalQuantity: cartProvider.itemCount.toDouble(),
                                    totalPrice: cartProvider.totalPrice,
                                    isLoading: orderProvider.isLoading,
                                    onCheckout: () => _checkout(context),
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
    required CartProvider cartProvider,
    required OrderProvider orderProvider,
    required bool isArabic,
  }) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF123A22), Color(0xFF205A34), Color(0xFF2E6F40)],
        ),
        boxShadow: [
          BoxShadow(
            color: _cartDarkGreen.withValues(alpha: 0.18),
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
              tooltip: isArabic ? 'رجوع' : 'Back',
              onTap: () => Navigator.pop(context),
            ),
            const SizedBox(width: 12),
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: _cartLightGreen,
                borderRadius: BorderRadius.circular(13),
              ),
              child: const Icon(
                Icons.eco_rounded,
                color: _cartDarkGreen,
                size: 24,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'FarmPilot',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 19,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    isArabic ? 'سلة التسوق' : 'Shopping Cart',
                    style: const TextStyle(
                      color: Color(0xCCFFFFFF),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            PopupMenuButton<String>(
              tooltip: isArabic ? 'تغيير اللغة' : 'Change Language',
              offset: const Offset(0, 48),
              position: PopupMenuPosition.under,
              color: const Color(0xFFF8FAF4),
              elevation: 8,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              onSelected: (languageCode) {
                Provider.of<LocaleProvider>(
                  context,
                  listen: false,
                ).setLocale(Locale(languageCode));
              },
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
                              ? _cartPrimaryGreen
                              : Colors.transparent,
                        ),
                        const SizedBox(width: 10),
                        Text(isArabic ? 'الإنجليزية' : 'English'),
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
                              ? _cartPrimaryGreen
                              : Colors.transparent,
                        ),
                        const SizedBox(width: 10),
                        Text(isArabic ? 'العربية' : 'Arabic'),
                      ],
                    ),
                  ),
                ];
              },
              child: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.10),
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
            if (!cartProvider.isEmpty)
              _HeaderButton(
                icon: Icons.delete_sweep_outlined,
                tooltip: isArabic ? 'تفريغ السلة' : 'Clear cart',
                onTap: orderProvider.isLoading
                    ? null
                    : () => _showClearCartDialog(context, cartProvider),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildItemsSection({
    required CartProvider cartProvider,
    required OrderProvider orderProvider,
    required bool isArabic,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionHeading(
          icon: Icons.shopping_cart_outlined,
          title: isArabic ? 'سلتك' : 'Your Cart',
          subtitle: isArabic
              ? 'راجع منتجاتك وعدّل الكميات قبل إتمام الشراء.'
              : 'Review your products and adjust quantities before checkout.',
        ),
        const SizedBox(height: 16),
        ...List.generate(cartProvider.items.length, (index) {
          final item = cartProvider.items[index];

          return Padding(
            padding: EdgeInsets.only(
              bottom: index == cartProvider.items.length - 1 ? 0 : 14,
            ),
            child: _CartItemCard(
              item: item,
              isArabic: isArabic,
              isLoading: orderProvider.isLoading,
            ),
          );
        }),
      ],
    );
  }

  Future<void> _checkout(BuildContext context) async {
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final cartProvider = Provider.of<CartProvider>(context, listen: false);
    final orderProvider = Provider.of<OrderProvider>(context, listen: false);

    final token = authProvider.token;

    if (token == null || token.isEmpty) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(
              isArabic
                  ? 'يجب تسجيل الدخول قبل إنشاء طلب'
                  : 'You must log in before creating an order',
            ),
            backgroundColor: Colors.red,
          ),
        );
      return;
    }

    if (cartProvider.isEmpty) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(isArabic ? 'سلة التسوق فارغة' : 'Your cart is empty'),
          ),
        );
      return;
    }

    final checkoutDetails = await _showCheckoutDialog(
      context,
      cartProvider.totalPrice,
    );

    if (checkoutDetails == null || !context.mounted) {
      return;
    }

    final success = await orderProvider.createOrder(
      token: token,
      items: cartProvider.toOrderItems(),
      deliveryMethod: checkoutDetails.deliveryMethod,
      deliveryAddress: checkoutDetails.deliveryAddress,
      paymentMethod: 'CASH',
    );

    if (!context.mounted) {
      return;
    }

    if (success) {
      cartProvider.clearCart();

      // Refresh marketplace stock immediately after the order succeeds.
      // This keeps the available quantity in sync without a browser refresh.
      await Provider.of<ProductProvider>(
        context,
        listen: false,
      ).loadAllProducts();

      if (!context.mounted) {
        return;
      }

      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(
              isArabic ? 'تم إنشاء الطلب بنجاح' : 'Order created successfully',
            ),
            backgroundColor: _cartPrimaryGreen,
          ),
        );

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const CustomerOrdersScreen()),
      );
    } else {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(
              orderProvider.errorMessage ??
                  (isArabic ? 'فشل إنشاء الطلب' : 'Failed to create order'),
            ),
            backgroundColor: Colors.red,
          ),
        );
    }
  }

  Future<_CheckoutDetails?> _showCheckoutDialog(
    BuildContext context,
    double totalPrice,
  ) async {
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';
    final addressController = TextEditingController();

    String deliveryMethod = 'PICKUP';
    String? validationMessage;

    try {
      return await showDialog<_CheckoutDetails>(
        context: context,
        builder: (dialogContext) {
          return StatefulBuilder(
            builder: (context, setDialogState) {
              final isDelivery = deliveryMethod == 'DELIVERY';

              return AlertDialog(
                backgroundColor: const Color(0xFFFFFEFA),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                title: Row(
                  children: [
                    const Icon(
                      Icons.shopping_bag_outlined,
                      color: _cartPrimaryGreen,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        isArabic ? 'إتمام الطلب' : 'Checkout',
                        style: const TextStyle(fontWeight: FontWeight.w800),
                      ),
                    ),
                  ],
                ),
                content: SingleChildScrollView(
                  child: SizedBox(
                    width: 470,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: const Color(0xFFEAF3DF),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.receipt_long_outlined,
                                color: _cartPrimaryGreen,
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  isArabic ? 'الإجمالي' : 'Order total',
                                  style: const TextStyle(
                                    color: _cartTextSecondary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              Text(
                                '${totalPrice.toStringAsFixed(2)} ₪',
                                style: const TextStyle(
                                  color: _cartPrimaryGreen,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          isArabic ? 'طريقة الاستلام' : 'Delivery Method',
                          style: const TextStyle(
                            color: _cartTextPrimary,
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 10),
                        _CheckoutChoiceTile(
                          title: isArabic
                              ? 'استلام من المزارع'
                              : 'Pickup from Farmer',
                          subtitle: isArabic
                              ? 'سيتم اعتماد موقع الاستلام المسجل لدى المزارع.'
                              : 'The farmer\'s saved pickup location will be used.',
                          icon: Icons.storefront_outlined,
                          selected: deliveryMethod == 'PICKUP',
                          onTap: () {
                            setDialogState(() {
                              deliveryMethod = 'PICKUP';
                              validationMessage = null;
                            });
                          },
                        ),
                        const SizedBox(height: 10),
                        _CheckoutChoiceTile(
                          title: isArabic ? 'توصيل' : 'Delivery',
                          subtitle: isArabic
                              ? 'أدخل العنوان الذي تريد توصيل الطلب إليه.'
                              : 'Enter the address where you want the order delivered.',
                          icon: Icons.local_shipping_outlined,
                          selected: deliveryMethod == 'DELIVERY',
                          onTap: () {
                            setDialogState(() {
                              deliveryMethod = 'DELIVERY';
                              validationMessage = null;
                            });
                          },
                        ),
                        if (isDelivery) ...[
                          const SizedBox(height: 16),
                          TextField(
                            controller: addressController,
                            keyboardType: TextInputType.streetAddress,
                            textInputAction: TextInputAction.done,
                            maxLines: 3,
                            minLines: 1,
                            onChanged: (_) {
                              if (validationMessage != null) {
                                setDialogState(() {
                                  validationMessage = null;
                                });
                              }
                            },
                            decoration: InputDecoration(
                              labelText: isArabic
                                  ? 'عنوان التوصيل'
                                  : 'Delivery Address',
                              hintText: isArabic
                                  ? 'مثال: المدينة، الحي، الشارع...'
                                  : 'Example: city, neighborhood, street...',
                              prefixIcon: const Icon(
                                Icons.location_on_outlined,
                              ),
                              errorText: validationMessage,
                              filled: true,
                              fillColor: Colors.white,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14),
                                borderSide: const BorderSide(
                                  color: Color(0xFFDDE6D8),
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14),
                                borderSide: const BorderSide(
                                  color: Color(0xFFDDE6D8),
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14),
                                borderSide: const BorderSide(
                                  color: _cartPrimaryGreen,
                                  width: 1.5,
                                ),
                              ),
                            ),
                          ),
                        ],
                        const SizedBox(height: 20),
                        Text(
                          isArabic ? 'طريقة الدفع' : 'Payment Method',
                          style: const TextStyle(
                            color: _cartTextPrimary,
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF5F8F0),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: const Color(0xFFDDE6D8),
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 42,
                                height: 42,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFEAF3DF),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(
                                  Icons.payments_outlined,
                                  color: _cartPrimaryGreen,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      isDelivery
                                          ? (isArabic
                                                ? 'الدفع نقدًا عند التوصيل'
                                                : 'Cash on Delivery')
                                          : (isArabic
                                                ? 'الدفع نقدًا عند الاستلام'
                                                : 'Cash on Pickup'),
                                      style: const TextStyle(
                                        color: _cartTextPrimary,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                    const SizedBox(height: 3),
                                    Text(
                                      isArabic
                                          ? 'الدفع الإلكتروني غير مطلوب.'
                                          : 'No online payment is required.',
                                      style: const TextStyle(
                                        color: _cartTextSecondary,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const Icon(
                                Icons.check_circle_rounded,
                                color: _cartPrimaryGreen,
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
                      Navigator.of(dialogContext).pop();
                    },
                    child: Text(isArabic ? 'إلغاء' : 'Cancel'),
                  ),
                  ElevatedButton.icon(
                    onPressed: () {
                      final normalizedAddress = addressController.text.trim();

                      if (isDelivery && normalizedAddress.isEmpty) {
                        setDialogState(() {
                          validationMessage = isArabic
                              ? 'عنوان التوصيل مطلوب'
                              : 'Delivery address is required';
                        });
                        return;
                      }

                      Navigator.of(dialogContext).pop(
                        _CheckoutDetails(
                          deliveryMethod: deliveryMethod,
                          deliveryAddress:
                              isDelivery ? normalizedAddress : null,
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _cartPrimaryGreen,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    icon: const Icon(Icons.check_rounded),
                    label: Text(isArabic ? 'إنشاء الطلب' : 'Create Order'),
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

  void _showClearCartDialog(BuildContext context, CartProvider cartProvider) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        final isArabic = Localizations.localeOf(context).languageCode == 'ar';

        return AlertDialog(
          backgroundColor: const Color(0xFFFFFEFA),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          title: Row(
            children: [
              const Icon(Icons.delete_sweep_outlined, color: Colors.red),
              const SizedBox(width: 10),
              Text(isArabic ? 'تفريغ السلة' : 'Clear Cart'),
            ],
          ),
          content: Text(
            isArabic
                ? 'هل أنت متأكد من إزالة جميع المنتجات من السلة؟'
                : 'Are you sure you want to remove all products from the cart?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
              child: Text(isArabic ? 'إلغاء' : 'Cancel'),
            ),
            TextButton(
              onPressed: () {
                cartProvider.clearCart();
                Navigator.of(dialogContext).pop();
              },
              child: Text(
                isArabic ? 'تفريغ' : 'Clear',
                style: const TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _CheckoutDetails {
  final String deliveryMethod;
  final String? deliveryAddress;

  const _CheckoutDetails({
    required this.deliveryMethod,
    this.deliveryAddress,
  });
}

class _CheckoutChoiceTile extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return Material(
      color: selected ? const Color(0xFFEAF3DF) : Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: selected
                  ? _cartPrimaryGreen
                  : const Color(0xFFDDE6D8),
              width: selected ? 1.5 : 1,
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: selected
                      ? Colors.white
                      : const Color(0xFFF5F8F0),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: _cartPrimaryGreen,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: _cartTextPrimary,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        color: _cartTextSecondary,
                        fontSize: 12,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                selected
                    ? Icons.radio_button_checked_rounded
                    : Icons.radio_button_off_rounded,
                color: selected
                    ? _cartPrimaryGreen
                    : const Color(0xFF9AA59B),
              ),
            ],
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
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: Colors.white.withValues(alpha: onTap == null ? 0.05 : 0.10),
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

class _SectionHeading extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _SectionHeading({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: const Color(0xFFEAF3DF),
            borderRadius: BorderRadius.circular(15),
          ),
          child: Icon(icon, color: _cartPrimaryGreen, size: 24),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: _cartTextPrimary,
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: const TextStyle(
                  color: _cartTextSecondary,
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

class _CartItemCard extends StatelessWidget {
  final CartItem item;
  final bool isArabic;
  final bool isLoading;

  const _CartItemCard({
    required this.item,
    required this.isArabic,
    required this.isLoading,
  });

  @override
  Widget build(BuildContext context) {
    final cartProvider = Provider.of<CartProvider>(context, listen: false);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFFFFFFF), Color(0xFFFFFEFA)],
        ),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFDDE6D8)),
        boxShadow: [
          BoxShadow(
            color: _cartDarkGreen.withValues(alpha: 0.045),
            blurRadius: 18,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final compact = constraints.maxWidth < 540;

          if (compact) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _ProductImage(
                      imageUrl: item.imageUrl,
                      width: 96,
                      height: 108,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _ProductInfo(
                        item: item,
                        isArabic: isArabic,
                        displayName: _localizedCartProductName(
                          item.name,
                          isArabic,
                        ),
                        displayUnit: _localizedCartUnit(item.selectedUnit, isArabic),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                _buildControls(context: context, cartProvider: cartProvider),
              ],
            );
          }

          return Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _ProductImage(imageUrl: item.imageUrl, width: 110, height: 118),
              const SizedBox(width: 16),
              Expanded(
                child: _ProductInfo(
                  item: item,
                  isArabic: isArabic,
                  displayName: _localizedCartProductName(item.name, isArabic),
                  displayUnit: _localizedCartUnit(item.selectedUnit, isArabic),
                ),
              ),
              const SizedBox(width: 18),
              SizedBox(
                width: 190,
                child: _buildControls(
                  context: context,
                  cartProvider: cartProvider,
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
    required CartProvider cartProvider,
  }) {
    final availableUnits = item.availableUnits;
    final quantityText = _formatQuantity(item.quantity);

    final unitSelector = availableUnits.length > 1
        ? DropdownButtonFormField<String>(
            initialValue: item.selectedUnit,
            isExpanded: true,
            decoration: InputDecoration(
              labelText: isArabic ? 'الوحدة' : 'Unit',
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 10,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            items: availableUnits
                .map(
                  (unit) => DropdownMenuItem<String>(
                    value: unit,
                    child: Text(
                      _localizedCartUnit(unit, isArabic),
                    ),
                  ),
                )
                .toList(),
            onChanged: isLoading
                ? null
                : (value) {
                    if (value == null) {
                      return;
                    }

                    cartProvider.changeUnit(
                      productId: item.productId,
                      unit: value,
                    );
                  },
          )
        : Container(
            height: 48,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: const Color(0xFFF5F8F0),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color(0xFFDDE6D8),
              ),
            ),
            child: Text(
              _localizedCartUnit(item.selectedUnit, isArabic),
              style: const TextStyle(
                color: _cartTextPrimary,
                fontWeight: FontWeight.w700,
              ),
            ),
          );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: TextFormField(
                key: ValueKey(
                  '${item.productId}-${item.selectedUnit}-$quantityText',
                ),
                initialValue: quantityText,
                enabled: !isLoading,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                textInputAction: TextInputAction.done,
                decoration: InputDecoration(
                  labelText: isArabic ? 'الكمية' : 'Quantity',
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 12,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onChanged: (value) {
                  final parsed = double.tryParse(
                    value.trim().replaceAll(',', '.'),
                  );

                  if (parsed == null || parsed <= 0) {
                    return;
                  }

                  cartProvider.updateQuantity(
                    productId: item.productId,
                    quantity: parsed,
                  );
                },
              ),
            ),
            const SizedBox(width: 10),
            Expanded(child: unitSelector),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            _QuantityButton(
              icon: Icons.remove_rounded,
              onPressed: isLoading
                  ? null
                  : () {
                      cartProvider.decreaseQuantity(
                        item.productId,
                      );
                    },
            ),
            const SizedBox(width: 8),
            _QuantityButton(
              icon: Icons.add_rounded,
              onPressed: isLoading
                  ? null
                  : () {
                      cartProvider.increaseQuantity(
                        item.productId,
                      );
                    },
            ),
            const Spacer(),
            IconButton(
              onPressed: isLoading
                  ? null
                  : () {
                      cartProvider.removeItem(
                        item.productId,
                      );
                    },
              tooltip: isArabic
                  ? 'إزالة المنتج'
                  : 'Remove product',
              style: IconButton.styleFrom(
                backgroundColor: const Color(0xFFFCE7E7),
                foregroundColor: const Color(0xFFB44F4F),
              ),
              icon: const Icon(
                Icons.delete_outline_rounded,
              ),
            ),
          ],
        ),
      ],
    );
  }

  String _formatQuantity(double value) {
    if (value == value.roundToDouble()) {
      return value.toInt().toString();
    }

    return value
        .toStringAsFixed(3)
        .replaceFirst(RegExp(r'0+$'), '')
        .replaceFirst(RegExp(r'\.$'), '');
  }

}

class _ProductInfo extends StatelessWidget {
  final CartItem item;
  final bool isArabic;
  final String displayName;
  final String displayUnit;

  const _ProductInfo({
    required this.item,
    required this.isArabic,
    required this.displayName,
    required this.displayUnit,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          displayName,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: _cartTextPrimary,
            fontSize: 17,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 7),
        Text(
          '${_priceForSelectedUnit(item).toStringAsFixed(2)} ₪'
          '${displayUnit.isEmpty ? '' : ' / $displayUnit'}',
          style: const TextStyle(
            color: _cartTextSecondary,
            fontSize: 13,
          ),
        ),
        const SizedBox(height: 9),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: const Color(0xFFEAF3DF),
            borderRadius: BorderRadius.circular(18),
          ),
          child: Text(
            '${isArabic ? 'المجموع الفرعي' : 'Subtotal'}: '
            '${item.totalPrice.toStringAsFixed(2)} ₪',
            style: const TextStyle(
              color: _cartPrimaryGreen,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
  double _priceForSelectedUnit(
    CartItem item,
  ) {
    final productUnit =
        item.productUnit.trim().toLowerCase();

    final selectedUnit =
        item.selectedUnit.trim().toLowerCase();

    if (productUnit == selectedUnit) {
      return item.price;
    }

    if (productUnit == 'ton' &&
        selectedUnit == 'kg') {
      return item.price / 1000.0;
    }

    if (productUnit == 'kg' &&
        selectedUnit == 'ton') {
      return item.price * 1000.0;
    }

    return item.price;
  }

}

class _ProductImage extends StatelessWidget {
  final String? imageUrl;
  final double width;
  final double height;

  const _ProductImage({
    required this.imageUrl,
    required this.width,
    required this.height,
  });

  @override
  Widget build(BuildContext context) {
    final hasImage = imageUrl != null && imageUrl!.trim().isNotEmpty;

    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: width,
        height: height,
        color: const Color(0xFFF0F5EB),
        child: hasImage
            ? Image.network(
                _buildImageUrl(imageUrl!),
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return const Center(
                    child: Icon(
                      Icons.image_not_supported_outlined,
                      size: 42,
                      color: Color(0xFF9AA59B),
                    ),
                  );
                },
              )
            : const Center(
                child: Icon(
                  Icons.eco_outlined,
                  size: 45,
                  color: _cartPrimaryGreen,
                ),
              ),
      ),
    );
  }

  String _buildImageUrl(String value) {
    final trimmed = value.trim();

    if (trimmed.isEmpty) {
      return '';
    }

    if (trimmed.startsWith('http://localhost:3000') ||
        trimmed.startsWith('http://127.0.0.1:3000')) {
      return trimmed.replaceFirst(
        RegExp(r'http://(localhost|127\.0\.0\.1):3000'),
        AppConstants.baseUrl,
      );
    }

    if (trimmed.startsWith('http://') || trimmed.startsWith('https://')) {
      return trimmed;
    }

    final normalized = trimmed.startsWith('/') ? trimmed : '/$trimmed';

    return '${AppConstants.baseUrl}$normalized';
  }
}

class _QuantityButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;

  const _QuantityButton({required this.icon, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 38,
      height: 38,
      child: IconButton(
        padding: EdgeInsets.zero,
        onPressed: onPressed,
        icon: Icon(icon, size: 19),
        style: IconButton.styleFrom(
          backgroundColor: const Color(0xFFEAF3DF),
          foregroundColor: _cartPrimaryGreen,
        ),
      ),
    );
  }
}

class _CartSummary extends StatelessWidget {
  final bool isArabic;
  final double totalQuantity;
  final double totalPrice;
  final bool isLoading;
  final VoidCallback onCheckout;

  const _CartSummary({
    required this.isArabic,
    required this.totalQuantity,
    required this.totalPrice,
    required this.isLoading,
    required this.onCheckout,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFFFFFFF), Color(0xFFFFFEFA)],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFDDE6D8)),
        boxShadow: [
          BoxShadow(
            color: _cartDarkGreen.withValues(alpha: 0.055),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.receipt_long_outlined,
                color: _cartPrimaryGreen,
                size: 22,
              ),
              const SizedBox(width: 9),
              Text(
                isArabic ? 'ملخص الطلب' : 'Order Summary',
                style: const TextStyle(
                  color: _cartTextPrimary,
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _SummaryRow(
            label: isArabic ? 'إجمالي المنتجات' : 'Total products',
            value: totalQuantity.toInt().toString(),
          ),
          const SizedBox(height: 12),
          const Divider(color: Color(0xFFE1E8DD)),
          const SizedBox(height: 12),
          _SummaryRow(
            label: isArabic ? 'السعر الإجمالي' : 'Total price',
            value: '${totalPrice.toStringAsFixed(2)} ₪',
            emphasize: true,
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton.icon(
              onPressed: isLoading ? null : onCheckout,
              style: ElevatedButton.styleFrom(
                backgroundColor: _cartPrimaryGreen,
                foregroundColor: Colors.white,
                disabledBackgroundColor: const Color(0xFFD6DDD4),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
              icon: isLoading
                  ? const SizedBox(
                      width: 21,
                      height: 21,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.shopping_bag_outlined),
              label: Text(
                isLoading
                    ? (isArabic ? 'جارٍ إنشاء الطلب...' : 'Creating Order...')
                    : (isArabic ? 'إتمام الشراء' : 'Checkout'),
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;
  final bool emphasize;

  const _SummaryRow({
    required this.label,
    required this.value,
    this.emphasize = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              color: emphasize ? _cartTextPrimary : _cartTextSecondary,
              fontSize: emphasize ? 16 : 14,
              fontWeight: emphasize ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: emphasize ? _cartPrimaryGreen : _cartTextPrimary,
            fontSize: emphasize ? 21 : 15,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }
}

class _EmptyCart extends StatelessWidget {
  final bool isArabic;

  const _EmptyCart({required this.isArabic});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 480),
          padding: const EdgeInsets.all(30),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(26),
            border: Border.all(color: const Color(0xFFDDE6D8)),
            boxShadow: [
              BoxShadow(
                color: _cartDarkGreen.withValues(alpha: 0.05),
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
                  Icons.shopping_cart_outlined,
                  size: 46,
                  color: _cartPrimaryGreen,
                ),
              ),
              const SizedBox(height: 18),
              Text(
                isArabic ? 'سلة التسوق فارغة' : 'Your cart is empty',
                style: const TextStyle(
                  color: _cartTextPrimary,
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                isArabic
                    ? 'أضف منتجات من السوق لإنشاء طلب.'
                    : 'Add products from the marketplace to create an order.',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: _cartTextSecondary,
                  fontSize: 14,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 22),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                      builder: (_) => const CustomerProductsScreen(),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: _cartPrimaryGreen,
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
                icon: const Icon(Icons.storefront_outlined),
                label: Text(
                  isArabic ? 'العودة إلى السوق' : 'Back to Marketplace',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CartBackdrop extends StatelessWidget {
  const _CartBackdrop();

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
                    const Color(0xFFCFE6B4).withValues(alpha: 0.28),
                    const Color(0xFFCFE6B4).withValues(alpha: 0.0),
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
                    const Color(0xFFE7DFAF).withValues(alpha: 0.22),
                    const Color(0xFFE7DFAF).withValues(alpha: 0.0),
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
