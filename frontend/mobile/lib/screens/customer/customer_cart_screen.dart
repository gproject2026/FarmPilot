import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_constants.dart';
import '../../models/cart_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/cart_provider.dart';
import '../../providers/order_provider.dart';
import 'customer_orders_screen.dart';

const Color _cartDarkGreen = Color(0xFF173F24);
const Color _cartPrimaryGreen = Color(0xFF2F6B3D);
const Color _cartLightGreen = Color(0xFFDDECB8);
const Color _cartBackground = Color(0xFFF8FAF4);
const Color _cartTextPrimary = Color(0xFF1D2C21);
const Color _cartTextSecondary = Color(0xFF68756B);

class CustomerCartScreen extends StatelessWidget {
  const CustomerCartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cartProvider = Provider.of<CartProvider>(context);
    final orderProvider = Provider.of<OrderProvider>(context);

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
                ),
              ),
              if (cartProvider.isEmpty)
                const SliverFillRemaining(
                  hasScrollBody: false,
                  child: _EmptyCart(),
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
                                    ),
                                  ),
                                  const SizedBox(width: 24),
                                  SizedBox(
                                    width: 360,
                                    child: _CartSummary(
                                      totalQuantity: cartProvider.totalQuantity,
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
                                  ),
                                  const SizedBox(height: 20),
                                  _CartSummary(
                                    totalQuantity: cartProvider.totalQuantity,
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
  }) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 18),
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
              tooltip: 'Back',
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
                    'Shopping Cart',
                    style: TextStyle(
                      color: Color(0xCCFFFFFF),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            if (!cartProvider.isEmpty)
              _HeaderButton(
                icon: Icons.delete_sweep_outlined,
                tooltip: 'Clear cart',
                onTap: orderProvider.isLoading
                    ? null
                    : () => _showClearCartDialog(
                          context,
                          cartProvider,
                        ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildItemsSection({
    required CartProvider cartProvider,
    required OrderProvider orderProvider,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionHeading(
          icon: Icons.shopping_cart_outlined,
          title: 'Your Cart',
          subtitle:
              'Review your products and adjust quantities before checkout.',
        ),
        const SizedBox(height: 16),
        ...List.generate(
          cartProvider.items.length,
          (index) {
            final item = cartProvider.items[index];

            return Padding(
              padding: EdgeInsets.only(
                bottom:
                    index == cartProvider.items.length - 1 ? 0 : 14,
              ),
              child: _CartItemCard(
                item: item,
                isLoading: orderProvider.isLoading,
              ),
            );
          },
        ),
      ],
    );
  }

  Future<void> _checkout(BuildContext context) async {
    final authProvider = Provider.of<AuthProvider>(
      context,
      listen: false,
    );
    final cartProvider = Provider.of<CartProvider>(
      context,
      listen: false,
    );
    final orderProvider = Provider.of<OrderProvider>(
      context,
      listen: false,
    );

    final token = authProvider.token;

    if (token == null || token.isEmpty) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(
            content: Text(
              'You must log in before creating an order',
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
          const SnackBar(
            content: Text('Your cart is empty'),
          ),
        );
      return;
    }

    final confirmed = await _showCheckoutDialog(
      context,
      cartProvider.totalPrice,
    );

    if (!confirmed || !context.mounted) {
      return;
    }

    final success = await orderProvider.createOrder(
      token: token,
      items: cartProvider.toOrderItems(),
    );

    if (!context.mounted) {
      return;
    }

    if (success) {
      cartProvider.clearCart();

      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(
            content: Text('Order created successfully'),
            backgroundColor: _cartPrimaryGreen,
          ),
        );

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => const CustomerOrdersScreen(),
        ),
      );
    } else {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(
              orderProvider.errorMessage ??
                  'Failed to create order',
            ),
            backgroundColor: Colors.red,
          ),
        );
    }
  }

  Future<bool> _showCheckoutDialog(
    BuildContext context,
    double totalPrice,
  ) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: const Color(0xFFFFFEFA),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          title: const Row(
            children: [
              Icon(
                Icons.shopping_bag_outlined,
                color: _cartPrimaryGreen,
              ),
              SizedBox(width: 10),
              Text('Confirm Order'),
            ],
          ),
          content: Text(
            'Create this order with a total of '
            '${totalPrice.toStringAsFixed(2)} ₪?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(false);
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(true);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: _cartPrimaryGreen,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('Create Order'),
            ),
          ],
        );
      },
    );

    return result ?? false;
  }

  void _showClearCartDialog(
    BuildContext context,
    CartProvider cartProvider,
  ) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: const Color(0xFFFFFEFA),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          title: const Row(
            children: [
              Icon(
                Icons.delete_sweep_outlined,
                color: Colors.red,
              ),
              SizedBox(width: 10),
              Text('Clear Cart'),
            ],
          ),
          content: const Text(
            'Are you sure you want to remove all products from the cart?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                cartProvider.clearCart();
                Navigator.of(dialogContext).pop();
              },
              child: const Text(
                'Clear',
                style: TextStyle(
                  color: Colors.red,
                ),
              ),
            ),
          ],
        );
      },
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
          child: Icon(
            icon,
            color: _cartPrimaryGreen,
            size: 24,
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
  final bool isLoading;

  const _CartItemCard({
    required this.item,
    required this.isLoading,
  });

  @override
  Widget build(BuildContext context) {
    final cartProvider = Provider.of<CartProvider>(
      context,
      listen: false,
    );

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFFFFFFF),
            Color(0xFFFFFEFA),
          ],
        ),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: const Color(0xFFDDE6D8),
        ),
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
                      child: _ProductInfo(item: item),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                _buildControls(
                  context: context,
                  cartProvider: cartProvider,
                ),
              ],
            );
          }

          return Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _ProductImage(
                imageUrl: item.imageUrl,
                width: 110,
                height: 118,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _ProductInfo(item: item),
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
    return Row(
      children: [
        _QuantityButton(
          icon: item.quantity > 1
              ? Icons.remove_rounded
              : Icons.delete_outline_rounded,
          onPressed: isLoading
              ? null
              : () {
                  cartProvider.decreaseQuantity(
                    item.productId,
                  );
                },
        ),
        Expanded(
          child: Container(
            alignment: Alignment.center,
            child: Text(
              item.quantity.toString(),
              style: const TextStyle(
                color: _cartTextPrimary,
                fontSize: 17,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ),
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
        const SizedBox(width: 8),
        IconButton(
          onPressed: isLoading
              ? null
              : () {
                  cartProvider.removeItem(
                    item.productId,
                  );
                },
          tooltip: 'Remove product',
          style: IconButton.styleFrom(
            backgroundColor: const Color(0xFFFCE7E7),
            foregroundColor: const Color(0xFFB44F4F),
          ),
          icon: const Icon(
            Icons.delete_outline_rounded,
          ),
        ),
      ],
    );
  }
}

class _ProductInfo extends StatelessWidget {
  final CartItem item;

  const _ProductInfo({
    required this.item,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          item.name,
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
          '${item.price.toStringAsFixed(2)} ₪'
          '${item.unit.isEmpty ? '' : ' / ${item.unit}'}',
          style: const TextStyle(
            color: _cartTextSecondary,
            fontSize: 13,
          ),
        ),
        const SizedBox(height: 9),
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 10,
            vertical: 6,
          ),
          decoration: BoxDecoration(
            color: const Color(0xFFEAF3DF),
            borderRadius: BorderRadius.circular(18),
          ),
          child: Text(
            'Subtotal: '
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
    final hasImage =
        imageUrl != null && imageUrl!.trim().isNotEmpty;

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
                errorBuilder: (
                  context,
                  error,
                  stackTrace,
                ) {
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
        trimmed.startsWith('/') ? trimmed : '/$trimmed';

    return '${AppConstants.baseUrl}$normalized';
  }
}

class _QuantityButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;

  const _QuantityButton({
    required this.icon,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 38,
      height: 38,
      child: IconButton(
        padding: EdgeInsets.zero,
        onPressed: onPressed,
        icon: Icon(
          icon,
          size: 19,
        ),
        style: IconButton.styleFrom(
          backgroundColor: const Color(0xFFEAF3DF),
          foregroundColor: _cartPrimaryGreen,
        ),
      ),
    );
  }
}

class _CartSummary extends StatelessWidget {
  final int totalQuantity;
  final double totalPrice;
  final bool isLoading;
  final VoidCallback onCheckout;

  const _CartSummary({
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
          colors: [
            Color(0xFFFFFFFF),
            Color(0xFFFFFEFA),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: const Color(0xFFDDE6D8),
        ),
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
          const Row(
            children: [
              Icon(
                Icons.receipt_long_outlined,
                color: _cartPrimaryGreen,
                size: 22,
              ),
              SizedBox(width: 9),
              Text(
                'Order Summary',
                style: TextStyle(
                  color: _cartTextPrimary,
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _SummaryRow(
            label: 'Total products',
            value: totalQuantity.toString(),
          ),
          const SizedBox(height: 12),
          const Divider(
            color: Color(0xFFE1E8DD),
          ),
          const SizedBox(height: 12),
          _SummaryRow(
            label: 'Total price',
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
                disabledBackgroundColor:
                    const Color(0xFFD6DDD4),
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
                  : const Icon(
                      Icons.shopping_bag_outlined,
                    ),
              label: Text(
                isLoading
                    ? 'Creating Order...'
                    : 'Checkout',
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                ),
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
              color: emphasize
                  ? _cartTextPrimary
                  : _cartTextSecondary,
              fontSize: emphasize ? 16 : 14,
              fontWeight: emphasize
                  ? FontWeight.w700
                  : FontWeight.w500,
            ),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: emphasize
                ? _cartPrimaryGreen
                : _cartTextPrimary,
            fontSize: emphasize ? 21 : 15,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }
}

class _EmptyCart extends StatelessWidget {
  const _EmptyCart();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Container(
          constraints: const BoxConstraints(
            maxWidth: 480,
          ),
          padding: const EdgeInsets.all(30),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(26),
            border: Border.all(
              color: const Color(0xFFDDE6D8),
            ),
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
              const Text(
                'Your cart is empty',
                style: TextStyle(
                  color: _cartTextPrimary,
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Add products from the marketplace to create an order.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: _cartTextSecondary,
                  fontSize: 14,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 22),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.of(context).pop();
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
                icon: const Icon(
                  Icons.storefront_outlined,
                ),
                label: const Text(
                  'Back to Marketplace',
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
