import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/cart_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/cart_provider.dart';
import '../../providers/order_provider.dart';
import 'customer_orders_screen.dart';

class CustomerCartScreen extends StatelessWidget {
  const CustomerCartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cartProvider =
        Provider.of<CartProvider>(context);

    final orderProvider =
        Provider.of<OrderProvider>(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7F4),
      appBar: AppBar(
        title: const Text('Shopping Cart'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        actions: [
          if (!cartProvider.isEmpty)
            IconButton(
              onPressed: orderProvider.isLoading
                  ? null
                  : () {
                      _showClearCartDialog(
                        context,
                        cartProvider,
                      );
                    },
              icon: const Icon(
                Icons.delete_sweep_outlined,
              ),
              tooltip: 'Clear cart',
            ),
        ],
      ),
      body: cartProvider.isEmpty
          ? const _EmptyCart()
          : Column(
              children: [
                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount:
                        cartProvider.items.length,
                    separatorBuilder:
                        (context, index) {
                      return const SizedBox(
                        height: 12,
                      );
                    },
                    itemBuilder: (context, index) {
                      final item =
                          cartProvider.items[index];

                      return _CartItemCard(
                        item: item,
                        isLoading:
                            orderProvider.isLoading,
                      );
                    },
                  ),
                ),
                _CartSummary(
                  totalQuantity:
                      cartProvider.totalQuantity,
                  totalPrice:
                      cartProvider.totalPrice,
                  isLoading:
                      orderProvider.isLoading,
                  onCheckout: () {
                    _checkout(context);
                  },
                ),
              ],
            ),
    );
  }

  Future<void> _checkout(
    BuildContext context,
  ) async {
    final authProvider =
        Provider.of<AuthProvider>(
      context,
      listen: false,
    );

    final cartProvider =
        Provider.of<CartProvider>(
      context,
      listen: false,
    );

    final orderProvider =
        Provider.of<OrderProvider>(
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
            content: Text(
              'Your cart is empty',
            ),
          ),
        );

      return;
    }

    final confirmed =
        await _showCheckoutDialog(
      context,
      cartProvider.totalPrice,
    );

    if (!confirmed || !context.mounted) {
      return;
    }

    final success =
        await orderProvider.createOrder(
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
            content: Text(
              'Order created successfully',
            ),
            backgroundColor: Colors.green,
          ),
        );

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) =>
              const CustomerOrdersScreen(),
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
          title: const Text(
            'Confirm Order',
          ),
          content: Text(
            'Create this order with a total of '
            '${totalPrice.toStringAsFixed(2)} ₪?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(
                  false,
                );
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(
                  true,
                );
              },
              child: const Text(
                'Create Order',
              ),
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
          title: const Text(
            'Clear Cart',
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

class _CartItemCard extends StatelessWidget {
  final CartItem item;
  final bool isLoading;

  const _CartItemCard({
    required this.item,
    required this.isLoading,
  });

  @override
  Widget build(BuildContext context) {
    final cartProvider =
        Provider.of<CartProvider>(
      context,
      listen: false,
    );

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            _ProductImage(
              imageUrl: item.imageUrl,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name,
                    maxLines: 2,
                    overflow:
                        TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '${item.price.toStringAsFixed(2)} ₪'
                    '${item.unit.isEmpty ? '' : ' / ${item.unit}'}',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Subtotal: '
                    '${item.totalPrice.toStringAsFixed(2)} ₪',
                    style: const TextStyle(
                      color: Colors.green,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      _QuantityButton(
                        icon: item.quantity > 1
                            ? Icons.remove
                            : Icons.delete_outline,
                        onPressed: isLoading
                            ? null
                            : () {
                                cartProvider
                                    .decreaseQuantity(
                                  item.productId,
                                );
                              },
                      ),
                      Container(
                        constraints:
                            const BoxConstraints(
                          minWidth: 42,
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          item.quantity.toString(),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight:
                                FontWeight.bold,
                          ),
                        ),
                      ),
                      _QuantityButton(
                        icon: Icons.add,
                        onPressed: isLoading
                            ? null
                            : () {
                                cartProvider
                                    .increaseQuantity(
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
                        icon: const Icon(
                          Icons.delete_outline,
                          color: Colors.red,
                        ),
                        tooltip: 'Remove product',
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
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
  Widget build(BuildContext context) {
    final hasImage =
        imageUrl != null &&
        imageUrl!.trim().isNotEmpty;

    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: Container(
        width: 90,
        height: 105,
        color: Colors.green.shade50,
        child: hasImage
            ? Image.network(
                _buildImageUrl(imageUrl!),
                fit: BoxFit.cover,
                errorBuilder: (
                  context,
                  error,
                  stackTrace,
                ) {
                  return const Icon(
                    Icons.image_not_supported_outlined,
                    size: 42,
                    color: Colors.grey,
                  );
                },
              )
            : const Icon(
                Icons.eco_outlined,
                size: 45,
                color: Colors.green,
              ),
      ),
    );
  }

  String _buildImageUrl(String value) {
    if (value.startsWith('http://') ||
        value.startsWith('https://')) {
      return value;
    }

    return 'http://localhost:3000$value';
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
      width: 36,
      height: 36,
      child: IconButton(
        padding: EdgeInsets.zero,
        onPressed: onPressed,
        icon: Icon(
          icon,
          size: 20,
        ),
        style: IconButton.styleFrom(
          backgroundColor: Colors.green.shade50,
          foregroundColor: Colors.green,
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
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(
          20,
          16,
          20,
          18,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(
                alpha: 0.08,
              ),
              blurRadius: 12,
              offset: const Offset(0, -3),
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              children: [
                const Text(
                  'Total products',
                  style: TextStyle(
                    fontSize: 15,
                  ),
                ),
                const Spacer(),
                Text(
                  totalQuantity.toString(),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Text(
                  'Total price',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                Text(
                  '${totalPrice.toStringAsFixed(2)} ₪',
                  style: const TextStyle(
                    fontSize: 20,
                    color: Colors.green,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed:
                    isLoading ? null : onCheckout,
                icon: isLoading
                    ? const SizedBox(
                        width: 21,
                        height: 21,
                        child:
                            CircularProgressIndicator(
                          strokeWidth: 2,
                        ),
                      )
                    : const Icon(
                        Icons.shopping_bag_outlined,
                      ),
                label: Text(
                  isLoading
                      ? 'Creating Order...'
                      : 'Checkout',
                ),
              ),
            ),
          ],
        ),
      ),
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
        child: Column(
          mainAxisAlignment:
              MainAxisAlignment.center,
          children: [
            Icon(
              Icons.shopping_cart_outlined,
              size: 95,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 18),
            const Text(
              'Your cart is empty',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Add products from the marketplace to create an order.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.of(context).pop();
              },
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
    );
  }
}