import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/order_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/order_provider.dart';

class FarmerOrdersScreen extends StatefulWidget {
  const FarmerOrdersScreen({
    super.key,
  });

  @override
  State<FarmerOrdersScreen> createState() =>
      _FarmerOrdersScreenState();
}

class _FarmerOrdersScreenState
    extends State<FarmerOrdersScreen> {
  String selectedStatus = 'ALL';

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback(
      (_) {
        _loadOrders();
      },
    );
  }

  Future<void> _loadOrders() async {
    final authProvider =
        Provider.of<AuthProvider>(
      context,
      listen: false,
    );

    final orderProvider =
        Provider.of<OrderProvider>(
      context,
      listen: false,
    );

    final token = authProvider.token;

    if (token == null ||
        token.isEmpty) {
      return;
    }

    await orderProvider.fetchFarmerOrders(
      token: token,
    );
  }

  Future<void> _confirmOrder(
    OrderModel order,
  ) async {
    final shouldConfirm =
        await showDialog<bool>(
      context: context,
      builder: (
        dialogContext,
      ) {
        return AlertDialog(
          title: const Text(
            'Confirm Order',
          ),
          content: const Text(
            'Are you sure you want to confirm this order?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(
                  dialogContext,
                  false,
                );
              },
              child: const Text(
                'No',
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(
                  dialogContext,
                  true,
                );
              },
              child: const Text(
                'Confirm',
              ),
            ),
          ],
        );
      },
    );

    if (
      shouldConfirm != true ||
      !mounted
    ) {
      return;
    }

    final authProvider =
        Provider.of<AuthProvider>(
      context,
      listen: false,
    );

    final orderProvider =
        Provider.of<OrderProvider>(
      context,
      listen: false,
    );

    final token =
        authProvider.token;

    if (
      token == null ||
      token.isEmpty
    ) {
      return;
    }

    final success =
        await orderProvider.confirmOrder(
      token: token,
      orderId: order.id,
    );

    if (!mounted) {
      return;
    }

    _showResultMessage(
      success: success,
      successMessage:
          'Order confirmed successfully',
      errorMessage:
          orderProvider.errorMessage,
    );
  }

  Future<void> _completeOrder(
    OrderModel order,
  ) async {
    final shouldComplete =
        await showDialog<bool>(
      context: context,
      builder: (
        dialogContext,
      ) {
        return AlertDialog(
          title: const Text(
            'Complete Order',
          ),
          content: const Text(
            'Are you sure this order has been completed?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(
                  dialogContext,
                  false,
                );
              },
              child: const Text(
                'No',
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(
                  dialogContext,
                  true,
                );
              },
              child: const Text(
                'Complete',
              ),
            ),
          ],
        );
      },
    );

    if (
      shouldComplete != true ||
      !mounted
    ) {
      return;
    }

    final authProvider =
        Provider.of<AuthProvider>(
      context,
      listen: false,
    );

    final orderProvider =
        Provider.of<OrderProvider>(
      context,
      listen: false,
    );

    final token =
        authProvider.token;

    if (
      token == null ||
      token.isEmpty
    ) {
      return;
    }

    final success =
        await orderProvider.completeOrder(
      token: token,
      orderId: order.id,
    );

    if (!mounted) {
      return;
    }

    _showResultMessage(
      success: success,
      successMessage:
          'Order completed successfully',
      errorMessage:
          orderProvider.errorMessage,
    );
  }

  Future<void> _cancelOrder(
    OrderModel order,
  ) async {
    final shouldCancel =
        await showDialog<bool>(
      context: context,
      builder: (
        dialogContext,
      ) {
        return AlertDialog(
          title: const Text(
            'Cancel Order',
          ),
          content: const Text(
            'Are you sure you want to cancel this order?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(
                  dialogContext,
                  false,
                );
              },
              child: const Text(
                'No',
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(
                  dialogContext,
                  true,
                );
              },
              child: const Text(
                'Yes, Cancel',
                style: TextStyle(
                  color: Colors.red,
                ),
              ),
            ),
          ],
        );
      },
    );

    if (
      shouldCancel != true ||
      !mounted
    ) {
      return;
    }

    final authProvider =
        Provider.of<AuthProvider>(
      context,
      listen: false,
    );

    final orderProvider =
        Provider.of<OrderProvider>(
      context,
      listen: false,
    );

    final token =
        authProvider.token;

    if (
      token == null ||
      token.isEmpty
    ) {
      return;
    }

    final success =
        await orderProvider.cancelOrder(
      token: token,
      orderId: order.id,
    );

    if (!mounted) {
      return;
    }

    _showResultMessage(
      success: success,
      successMessage:
          'Order cancelled successfully',
      errorMessage:
          orderProvider.errorMessage,
    );
  }

  void _showResultMessage({
    required bool success,
    required String successMessage,
    String? errorMessage,
  }) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            success
                ? successMessage
                : errorMessage ??
                    'Something went wrong',
          ),
          backgroundColor:
              success
                  ? Colors.green
                  : Colors.red,
        ),
      );
  }

  List<OrderModel> _filteredOrders(
    List<OrderModel> orders,
  ) {
    if (selectedStatus == 'ALL') {
      return orders;
    }

    return orders.where(
      (order) {
        return order.status
                .trim()
                .toUpperCase() ==
            selectedStatus;
      },
    ).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAF4),
      body: Consumer<OrderProvider>(
        builder: (context, orderProvider, child) {
          final allOrders = orderProvider.farmerOrders;
          final orders = _filteredOrders(allOrders);

          return Stack(
            children: [
              const Positioned.fill(child: _OrdersBackdrop()),
              Column(
                children: [
                  _OrdersTopBar(onRefresh: _loadOrders),
                  Expanded(
                    child: orderProvider.isLoading && allOrders.isEmpty
                        ? const Center(
                            child: CircularProgressIndicator(
                              color: _ordersPrimary,
                            ),
                          )
                        : orderProvider.errorMessage != null &&
                                allOrders.isEmpty
                            ? _ErrorView(
                                message: orderProvider.errorMessage!,
                                onRetry: _loadOrders,
                              )
                            : RefreshIndicator(
                                color: _ordersPrimary,
                                onRefresh: _loadOrders,
                                child: CustomScrollView(
                                  physics:
                                      const AlwaysScrollableScrollPhysics(),
                                  slivers: [
                                    SliverToBoxAdapter(
                                      child: Center(
                                        child: ConstrainedBox(
                                          constraints: const BoxConstraints(
                                            maxWidth: 1320,
                                          ),
                                          child: Padding(
                                            padding: const EdgeInsets.fromLTRB(
                                              24,
                                              26,
                                              24,
                                              0,
                                            ),
                                            child: Column(
                                              children: [
                                                _OrdersHero(
                                                  total: allOrders.length,
                                                  pending: allOrders
                                                      .where(
                                                        (o) =>
                                                            o.status
                                                                .trim()
                                                                .toUpperCase() ==
                                                            'PENDING',
                                                      )
                                                      .length,
                                                  confirmed: allOrders
                                                      .where(
                                                        (o) =>
                                                            o.status
                                                                .trim()
                                                                .toUpperCase() ==
                                                            'CONFIRMED',
                                                      )
                                                      .length,
                                                ),
                                                const SizedBox(height: 18),
                                                _StatusFilter(
                                                  selectedStatus:
                                                      selectedStatus,
                                                  onChanged: (status) {
                                                    setState(() {
                                                      selectedStatus = status;
                                                    });
                                                  },
                                                ),
                                                const SizedBox(height: 18),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    if (orders.isEmpty)
                                      SliverFillRemaining(
                                        hasScrollBody: false,
                                        child: _EmptyOrdersView(
                                          status: selectedStatus,
                                        ),
                                      )
                                    else
                                      SliverPadding(
                                        padding: const EdgeInsets.fromLTRB(
                                          24,
                                          0,
                                          24,
                                          42,
                                        ),
                                        sliver: SliverList.separated(
                                          itemCount: orders.length,
                                          separatorBuilder: (_, _) =>
                                              const SizedBox(height: 16),
                                          itemBuilder: (context, index) {
                                            final order = orders[index];
                                            return Center(
                                              child: ConstrainedBox(
                                                constraints:
                                                    const BoxConstraints(
                                                  maxWidth: 1320,
                                                ),
                                                child: _FarmerOrderCard(
                                                  order: order,
                                                  isLoading:
                                                      orderProvider.isLoading,
                                                  onConfirm: () =>
                                                      _confirmOrder(order),
                                                  onComplete: () =>
                                                      _completeOrder(order),
                                                  onCancel: () =>
                                                      _cancelOrder(order),
                                                ),
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
          );
        },
      ),
    );
  }
}

const _ordersDark = Color(0xFF173F24);
const _ordersPrimary = Color(0xFF2F743F);
const _ordersLight = Color(0xFFEAF3DF);
const _ordersText = Color(0xFF1D2C21);
const _ordersMuted = Color(0xFF6C786E);

class _OrdersTopBar extends StatelessWidget {
  final Future<void> Function() onRefresh;

  const _OrdersTopBar({required this.onRefresh});

  @override
  Widget build(BuildContext context) {
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
                color: const Color(0xFFDDECB8),
                borderRadius: BorderRadius.circular(13),
              ),
              child: const Icon(Icons.eco_rounded, color: _ordersDark),
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
                  Text(
                    'Manage Orders',
                    style: TextStyle(
                      color: Color(0xCCFFFFFF),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            _HeaderButton(
              icon: Icons.refresh_rounded,
              tooltip: 'Refresh',
              onTap: onRefresh,
            ),
          ],
        ),
      ),
    );
  }
}

class _HeaderButton extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;

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
        color: Colors.white.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: SizedBox(
            width: 44,
            height: 44,
            child: Icon(icon, color: Colors.white, size: 21),
          ),
        ),
      ),
    );
  }
}

class _OrdersHero extends StatelessWidget {
  final int total;
  final int pending;
  final int confirmed;

  const _OrdersHero({
    required this.total,
    required this.pending,
    required this.confirmed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: _ordersCardDecoration(radius: 25),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final heading = Row(
            children: [
              Container(
                width: 58,
                height: 58,
                decoration: BoxDecoration(
                  color: _ordersLight,
                  borderRadius: BorderRadius.circular(17),
                ),
                child: const Icon(
                  Icons.shopping_cart_checkout_rounded,
                  color: _ordersPrimary,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Customer Orders',
                      style: TextStyle(
                        color: _ordersText,
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Review incoming orders and keep every order status up to date.',
                      style: TextStyle(
                        color: _ordersMuted,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );

          final stats = Wrap(
            spacing: 9,
            runSpacing: 9,
            children: [
              _MiniStat(label: 'Total', value: total),
              _MiniStat(label: 'Pending', value: pending),
              _MiniStat(label: 'Confirmed', value: confirmed),
            ],
          );

          if (constraints.maxWidth < 720) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                heading,
                const SizedBox(height: 18),
                stats,
              ],
            );
          }

          return Row(
            children: [
              Expanded(child: heading),
              const SizedBox(width: 20),
              stats,
            ],
          );
        },
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  final String label;
  final int value;

  const _MiniStat({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 9),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F6E9),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Text(
        '$label  $value',
        style: const TextStyle(
          color: _ordersPrimary,
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _StatusFilter extends StatelessWidget {
  final String selectedStatus;
  final ValueChanged<String> onChanged;

  const _StatusFilter({
    required this.selectedStatus,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    const statuses = [
      'ALL',
      'PENDING',
      'CONFIRMED',
      'COMPLETED',
      'CANCELLED',
    ];

    return SizedBox(
      height: 44,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: statuses.length,
       separatorBuilder: (_, _) => const SizedBox(width: 9),
        itemBuilder: (context, index) {
          final status = statuses[index];
          final selected = selectedStatus == status;

          return ChoiceChip(
            label: Text(_filterLabel(status)),
            selected: selected,
            onSelected: (_) => onChanged(status),
            showCheckmark: false,
            backgroundColor: Colors.white,
            selectedColor: _ordersPrimary,
            side: BorderSide(
              color: selected
                  ? _ordersPrimary
                  : const Color(0xFFDCE5D8),
            ),
            labelStyle: TextStyle(
              color: selected ? Colors.white : _ordersMuted,
              fontWeight: FontWeight.w700,
              fontSize: 12,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 10),
          );
        },
      ),
    );
  }

  String _filterLabel(String status) {
    switch (status) {
      case 'ALL':
        return 'All Orders';
      case 'PENDING':
        return 'Pending';
      case 'CONFIRMED':
        return 'Confirmed';
      case 'COMPLETED':
        return 'Completed';
      case 'CANCELLED':
        return 'Cancelled';
      default:
        return status;
    }
  }
}

class _FarmerOrderCard extends StatelessWidget {
  final OrderModel order;
  final bool isLoading;
  final VoidCallback onConfirm;
  final VoidCallback onComplete;
  final VoidCallback onCancel;

  const _FarmerOrderCard({
    required this.order,
    required this.isLoading,
    required this.onConfirm,
    required this.onComplete,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    final status = order.status.trim().toUpperCase();
    final canConfirm = status == 'PENDING';
    final canComplete = status == 'CONFIRMED';
    final canCancel = status == 'PENDING' || status == 'CONFIRMED';

    return Container(
      padding: const EdgeInsets.all(22),
      decoration: _ordersCardDecoration(radius: 22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: _ordersLight,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.receipt_long_outlined,
                  color: _ordersPrimary,
                ),
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Order #${_shortOrderId(order.id)}',
                      style: const TextStyle(
                        color: _ordersText,
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _formatDate(order.createdAt),
                      style: const TextStyle(
                        color: _ordersMuted,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              _StatusBadge(status: status),
            ],
          ),
          const SizedBox(height: 20),
          LayoutBuilder(
            builder: (context, constraints) {
              final customer = _CustomerPanel(order: order);
              final items = _ItemsPanel(order: order);

              if (constraints.maxWidth < 760) {
                return Column(
                  children: [
                    customer,
                    const SizedBox(height: 14),
                    items,
                  ],
                );
              }

              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(flex: 4, child: customer),
                  const SizedBox(width: 14),
                  Expanded(flex: 6, child: items),
                ],
              );
            },
          ),
          const SizedBox(height: 18),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 17, vertical: 15),
            decoration: BoxDecoration(
              color: const Color(0xFFF5F8F1),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Row(
              children: [
                const Expanded(
                  child: Text(
                    'Order Total',
                    style: TextStyle(
                      color: _ordersText,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                Text(
                  '${order.totalPrice.toStringAsFixed(2)} ₪',
                  style: const TextStyle(
                    color: _ordersPrimary,
                    fontSize: 19,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
          if (canConfirm || canComplete || canCancel) ...[
            const SizedBox(height: 16),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                if (canConfirm)
                  ElevatedButton.icon(
                    onPressed: isLoading ? null : onConfirm,
                    style: _primaryButtonStyle(),
                    icon: const Icon(Icons.check_circle_outline_rounded),
                    label: const Text('Confirm Order'),
                  ),
                if (canComplete)
                  ElevatedButton.icon(
                    onPressed: isLoading ? null : onComplete,
                    style: _primaryButtonStyle(),
                    icon: const Icon(Icons.task_alt_rounded),
                    label: const Text('Complete Order'),
                  ),
                if (canCancel)
                  OutlinedButton.icon(
                    onPressed: isLoading ? null : onCancel,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFFC64D4D),
                      side: const BorderSide(color: Color(0xFFE3B7B7)),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 15,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(13),
                      ),
                    ),
                    icon: const Icon(Icons.cancel_outlined),
                    label: const Text('Cancel'),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  static String _shortOrderId(String id) =>
      id.length <= 8 ? id : id.substring(0, 8);

  static String _formatDate(DateTime date) {
    final d = date.toLocal();
    String two(int value) => value.toString().padLeft(2, '0');
    return '${two(d.day)}/${two(d.month)}/${d.year}  ${two(d.hour)}:${two(d.minute)}';
  }
}

class _CustomerPanel extends StatelessWidget {
  final OrderModel order;

  const _CustomerPanel({required this.order});

  @override
  Widget build(BuildContext context) {
    final customer = order.customer;
    return _InnerPanel(
      title: 'Customer',
      icon: Icons.person_outline_rounded,
      child: Column(
        children: [
          _InfoRow(
            icon: Icons.person_outline,
            text: customer.fullName.isEmpty ? 'Customer' : customer.fullName,
          ),
          if (customer.email.isNotEmpty)
            _InfoRow(icon: Icons.email_outlined, text: customer.email),
          if (customer.phone.isNotEmpty)
            _InfoRow(icon: Icons.phone_outlined, text: customer.phone),
          if (customer.address.isNotEmpty)
            _InfoRow(
              icon: Icons.location_on_outlined,
              text: customer.address,
            ),
        ],
      ),
    );
  }
}

class _ItemsPanel extends StatelessWidget {
  final OrderModel order;

  const _ItemsPanel({required this.order});

  @override
  Widget build(BuildContext context) {
    return _InnerPanel(
      title: 'Order Items',
      icon: Icons.shopping_basket_outlined,
      child: Column(
        children: order.orderItems
            .map((item) => _OrderItemRow(item: item))
            .toList(),
      ),
    );
  }
}

class _InnerPanel extends StatelessWidget {
  final String title;
  final IconData icon;
  final Widget child;

  const _InnerPanel({
    required this.title,
    required this.icon,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFCFDFB),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E9DE)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: _ordersPrimary, size: 19),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  color: _ordersText,
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 13),
          child,
        ],
      ),
    );
  }
}

class _OrderItemRow extends StatelessWidget {
  final OrderItemModel item;

  const _OrderItemRow({required this.item});

  @override
  Widget build(BuildContext context) {
    final productName =
        item.product.name.isEmpty ? 'Product' : item.product.name;
    final unit =
        item.product.unit.isEmpty ? '' : ' ${item.product.unit}';

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Container(
            width: 39,
            height: 39,
            decoration: BoxDecoration(
              color: _ordersLight,
              borderRadius: BorderRadius.circular(11),
            ),
            child: const Icon(
              Icons.shopping_basket_outlined,
              color: _ordersPrimary,
              size: 19,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  productName,
                  style: const TextStyle(
                    color: _ordersText,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Quantity: ${item.quantity}$unit',
                  style: const TextStyle(
                    color: _ordersMuted,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '${(item.price * item.quantity).toStringAsFixed(2)} ₪',
            style: const TextStyle(
              color: _ordersText,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String text;

  const _InfoRow({
    required this.icon,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 9),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 17, color: _ordersMuted),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                color: _ordersText,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String status;

  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    final color = _statusColor(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.11),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        _statusLabel(status),
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }

  Color _statusColor(String value) {
    switch (value.toUpperCase()) {
      case 'CONFIRMED':
        return const Color(0xFF4F76A7);
      case 'COMPLETED':
        return const Color(0xFF3F8A50);
      case 'CANCELLED':
        return const Color(0xFFC65353);
      case 'PENDING':
      default:
        return const Color(0xFFC8792C);
    }
  }

  String _statusLabel(String value) {
    switch (value.toUpperCase()) {
      case 'CONFIRMED':
        return 'Confirmed';
      case 'COMPLETED':
        return 'Completed';
      case 'CANCELLED':
        return 'Cancelled';
      case 'PENDING':
      default:
        return 'Pending';
    }
  }
}

class _EmptyOrdersView extends StatelessWidget {
  final String status;

  const _EmptyOrdersView({required this.status});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 76,
              height: 76,
              decoration: const BoxDecoration(
                color: _ordersLight,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.receipt_long_outlined,
                size: 34,
                color: _ordersPrimary,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              status == 'ALL'
                  ? 'No orders yet'
                  : 'No ${status.toLowerCase()} orders',
              style: const TextStyle(
                color: _ordersText,
                fontSize: 19,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Orders from customers will appear here.',
              style: TextStyle(color: _ordersMuted),
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String message;
  final Future<void> Function() onRetry;

  const _ErrorView({
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 430),
        margin: const EdgeInsets.all(24),
        padding: const EdgeInsets.all(25),
        decoration: _ordersCardDecoration(radius: 22),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.error_outline_rounded,
              size: 55,
              color: Color(0xFFC65353),
            ),
            const SizedBox(height: 13),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: _ordersText),
            ),
            const SizedBox(height: 17),
            ElevatedButton.icon(
              onPressed: onRetry,
              style: _primaryButtonStyle(),
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }
}

class _OrdersBackdrop extends StatelessWidget {
  const _OrdersBackdrop();

  @override
  Widget build(BuildContext context) {
    return const DecoratedBox(
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
    );
  }
}

ButtonStyle _primaryButtonStyle() {
  return ElevatedButton.styleFrom(
    backgroundColor: _ordersPrimary,
    foregroundColor: Colors.white,
    elevation: 0,
    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 15),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(13),
    ),
  );
}

BoxDecoration _ordersCardDecoration({required double radius}) {
  return BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(radius),
    border: Border.all(color: const Color(0xFFDCE5D8)),
    boxShadow: [
      BoxShadow(
        color: _ordersDark.withValues(alpha: 0.05),
        blurRadius: 20,
        offset: const Offset(0, 7),
      ),
    ],
  );
}
