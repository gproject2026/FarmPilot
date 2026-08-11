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
  Widget build(
    BuildContext context,
  ) {
    return Scaffold(
      backgroundColor:
          const Color(
        0xFFF5F7F4,
      ),
      appBar: AppBar(
        title: const Text(
          'Manage Orders',
        ),
        backgroundColor:
            Colors.green,
        foregroundColor:
            Colors.white,
        actions: [
          IconButton(
            tooltip: 'Refresh',
            onPressed:
                _loadOrders,
            icon: const Icon(
              Icons.refresh,
            ),
          ),
        ],
      ),
      body:
          Consumer<OrderProvider>(
        builder: (
          context,
          orderProvider,
          child,
        ) {
          if (
            orderProvider.isLoading &&
            orderProvider
                .farmerOrders
                .isEmpty
          ) {
            return const Center(
              child:
                  CircularProgressIndicator(),
            );
          }

          if (
            orderProvider.errorMessage !=
                    null &&
            orderProvider
                .farmerOrders
                .isEmpty
          ) {
            return _ErrorView(
              message:
                  orderProvider
                      .errorMessage!,
              onRetry:
                  _loadOrders,
            );
          }

          final orders =
              _filteredOrders(
            orderProvider.farmerOrders,
          );

          return Column(
            children: [
              _StatusFilter(
                selectedStatus:
                    selectedStatus,
                onChanged:
                    (status) {
                  setState(() {
                    selectedStatus =
                        status;
                  });
                },
              ),
              Expanded(
                child:
                    orders.isEmpty
                        ? _EmptyOrdersView(
                            onRefresh:
                                _loadOrders,
                            status:
                                selectedStatus,
                          )
                        : RefreshIndicator(
                            onRefresh:
                                _loadOrders,
                            child:
                                ListView.builder(
                              padding:
                                  const EdgeInsets.all(
                                16,
                              ),
                              itemCount:
                                  orders.length,
                              itemBuilder:
                                  (
                                context,
                                index,
                              ) {
                                final order =
                                    orders[
                                        index];

                                return _FarmerOrderCard(
                                  order:
                                      order,
                                  isLoading:
                                      orderProvider
                                          .isLoading,
                                  onConfirm:
                                      () {
                                    _confirmOrder(
                                      order,
                                    );
                                  },
                                  onComplete:
                                      () {
                                    _completeOrder(
                                      order,
                                    );
                                  },
                                  onCancel:
                                      () {
                                    _cancelOrder(
                                      order,
                                    );
                                  },
                                );
                              },
                            ),
                          ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _StatusFilter
    extends StatelessWidget {
  final String selectedStatus;
  final ValueChanged<String>
      onChanged;

  const _StatusFilter({
    required this.selectedStatus,
    required this.onChanged,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    const statuses = [
      'ALL',
      'PENDING',
      'CONFIRMED',
      'COMPLETED',
      'CANCELLED',
    ];

    return SizedBox(
      height: 60,
      child: ListView.separated(
        scrollDirection:
            Axis.horizontal,
        padding:
            const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 10,
        ),
        itemCount:
            statuses.length,
        separatorBuilder:
            (
          context,
          index,
        ) {
          return const SizedBox(
            width: 8,
          );
        },
        itemBuilder:
            (
          context,
          index,
        ) {
          final status =
              statuses[index];

          final selected =
              selectedStatus ==
                  status;

          return ChoiceChip(
            label: Text(
              status,
            ),
            selected:
                selected,
            onSelected:
                (_) {
              onChanged(
                status,
              );
            },
          );
        },
      ),
    );
  }
}

class _FarmerOrderCard
    extends StatelessWidget {
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
  Widget build(
    BuildContext context,
  ) {
    final status =
        order.status
            .trim()
            .toUpperCase();

    final canConfirm =
        status ==
            'PENDING';

    final canComplete =
        status ==
            'CONFIRMED';

    final canCancel =
        status ==
                'PENDING' ||
            status ==
                'CONFIRMED';

    return Card(
      margin:
          const EdgeInsets.only(
        bottom: 16,
      ),
      elevation: 2,
      shape:
          RoundedRectangleBorder(
        borderRadius:
            BorderRadius.circular(
          16,
        ),
      ),
      child: Padding(
        padding:
            const EdgeInsets.all(
          16,
        ),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment
                  .start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Order #${_shortOrderId(order.id)}',
                    style:
                        const TextStyle(
                      fontSize: 17,
                      fontWeight:
                          FontWeight
                              .bold,
                    ),
                  ),
                ),
                _StatusBadge(
                  status:
                      status,
                ),
              ],
            ),

            const SizedBox(
              height: 8,
            ),

            Text(
              _formatDate(
                order.createdAt,
              ),
              style:
                  TextStyle(
                color:
                    Colors
                        .grey
                        .shade600,
                fontSize:
                    13,
              ),
            ),

            const Divider(
              height: 24,
            ),

            const Text(
              'Customer',
              style:
                  TextStyle(
                fontSize: 15,
                fontWeight:
                    FontWeight.bold,
              ),
            ),

            const SizedBox(
              height: 10,
            ),

            _InfoRow(
              icon:
                  Icons.person_outline,
              text:
                  order.customer
                          .fullName
                          .isEmpty
                      ? 'Customer'
                      : order
                          .customer
                          .fullName,
            ),

            if (
              order.customer.email
                  .isNotEmpty
            )
              _InfoRow(
                icon:
                    Icons
                        .email_outlined,
                text:
                    order.customer
                        .email,
              ),

            if (
              order.customer.phone
                  .isNotEmpty
            )
              _InfoRow(
                icon:
                    Icons
                        .phone_outlined,
                text:
                    order.customer
                        .phone,
              ),

            if (
              order.customer.address
                  .isNotEmpty
            )
              _InfoRow(
                icon:
                    Icons
                        .location_on_outlined,
                text:
                    order.customer
                        .address,
              ),

            const Divider(
              height: 24,
            ),

            const Text(
              'Order Items',
              style:
                  TextStyle(
                fontSize: 15,
                fontWeight:
                    FontWeight.bold,
              ),
            ),

            const SizedBox(
              height: 12,
            ),

            ...order.orderItems.map(
              (item) {
                return _OrderItemRow(
                  item:
                      item,
                );
              },
            ),

            const Divider(
              height: 24,
            ),

            Row(
              children: [
                const Expanded(
                  child: Text(
                    'Total',
                    style:
                        TextStyle(
                      fontSize:
                          16,
                      fontWeight:
                          FontWeight
                              .w600,
                    ),
                  ),
                ),
                Text(
                  '${order.totalPrice.toStringAsFixed(2)} ₪',
                  style:
                      const TextStyle(
                    fontSize:
                        18,
                    fontWeight:
                        FontWeight
                            .bold,
                    color:
                        Colors.green,
                  ),
                ),
              ],
            ),

            if (
              canConfirm ||
              canComplete ||
              canCancel
            ) ...[
              const SizedBox(
                height: 18,
              ),

              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  if (
                    canConfirm
                  )
                    ElevatedButton.icon(
                      onPressed:
                          isLoading
                              ? null
                              : onConfirm,
                      icon:
                          const Icon(
                        Icons
                            .check_circle_outline,
                      ),
                      label:
                          const Text(
                        'Confirm',
                      ),
                    ),

                  if (
                    canComplete
                  )
                    ElevatedButton.icon(
                      onPressed:
                          isLoading
                              ? null
                              : onComplete,
                      icon:
                          const Icon(
                        Icons
                            .task_alt,
                      ),
                      label:
                          const Text(
                        'Complete',
                      ),
                    ),

                  if (
                    canCancel
                  )
                    OutlinedButton.icon(
                      onPressed:
                          isLoading
                              ? null
                              : onCancel,
                      icon:
                          const Icon(
                        Icons
                            .cancel_outlined,
                      ),
                      label:
                          const Text(
                        'Cancel',
                      ),
                      style:
                          OutlinedButton
                              .styleFrom(
                        foregroundColor:
                            Colors.red,
                        side:
                            const BorderSide(
                          color:
                              Colors.red,
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  static String _shortOrderId(
    String id,
  ) {
    if (id.length <= 8) {
      return id;
    }

    return id.substring(
      0,
      8,
    );
  }

  static String _formatDate(
    DateTime date,
  ) {
    final localDate =
        date.toLocal();

    final day =
        localDate.day
            .toString()
            .padLeft(
              2,
              '0',
            );

    final month =
        localDate.month
            .toString()
            .padLeft(
              2,
              '0',
            );

    final hour =
        localDate.hour
            .toString()
            .padLeft(
              2,
              '0',
            );

    final minute =
        localDate.minute
            .toString()
            .padLeft(
              2,
              '0',
            );

    return '$day/$month/${localDate.year}  $hour:$minute';
  }
}

class _OrderItemRow
    extends StatelessWidget {
  final OrderItemModel item;

  const _OrderItemRow({
    required this.item,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    final productName =
        item.product.name
                .isEmpty
            ? 'Product'
            : item.product.name;

    final unit =
        item.product.unit
                .isEmpty
            ? ''
            : ' ${item.product.unit}';

    return Padding(
      padding:
          const EdgeInsets.only(
        bottom: 12,
      ),
      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment
                .start,
        children: [
          Container(
            width: 46,
            height: 46,
            decoration:
                BoxDecoration(
              color:
                  Colors
                      .green
                      .shade50,
              borderRadius:
                  BorderRadius
                      .circular(
                10,
              ),
            ),
            child:
                const Icon(
              Icons
                  .shopping_basket_outlined,
              color:
                  Colors.green,
            ),
          ),
          const SizedBox(
            width: 12,
          ),
          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment
                      .start,
              children: [
                Text(
                  productName,
                  style:
                      const TextStyle(
                    fontWeight:
                        FontWeight
                            .w600,
                  ),
                ),
                const SizedBox(
                  height: 4,
                ),
                Text(
                  'Quantity: ${item.quantity}$unit',
                  style:
                      TextStyle(
                    color:
                        Colors
                            .grey
                            .shade600,
                    fontSize:
                        13,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '${(item.price * item.quantity).toStringAsFixed(2)} ₪',
            style:
                const TextStyle(
              fontWeight:
                  FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoRow
    extends StatelessWidget {
  final IconData icon;
  final String text;

  const _InfoRow({
    required this.icon,
    required this.text,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    return Padding(
      padding:
          const EdgeInsets.only(
        bottom: 7,
      ),
      child: Row(
        children: [
          Icon(
            icon,
            size: 18,
            color:
                Colors
                    .grey
                    .shade700,
          ),
          const SizedBox(
            width: 8,
          ),
          Expanded(
            child: Text(
              text,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusBadge
    extends StatelessWidget {
  final String status;

  const _StatusBadge({
    required this.status,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    final color =
        _statusColor(
      status,
    );

    return Container(
      padding:
          const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 6,
      ),
      decoration:
          BoxDecoration(
        color:
            color.withValues(
          alpha: 0.12,
        ),
        borderRadius:
            BorderRadius.circular(
          20,
        ),
      ),
      child: Text(
        _statusLabel(
          status,
        ),
        style:
            TextStyle(
          color: color,
          fontSize: 12,
          fontWeight:
              FontWeight.bold,
        ),
      ),
    );
  }

  Color _statusColor(
    String value,
  ) {
    switch (
        value.toUpperCase()) {
      case 'CONFIRMED':
        return Colors.blue;

      case 'COMPLETED':
        return Colors.green;

      case 'CANCELLED':
        return Colors.red;

      case 'PENDING':
      default:
        return Colors.orange;
    }
  }

  String _statusLabel(
    String value,
  ) {
    switch (
        value.toUpperCase()) {
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

class _EmptyOrdersView
    extends StatelessWidget {
  final Future<void> Function()
      onRefresh;

  final String status;

  const _EmptyOrdersView({
    required this.onRefresh,
    required this.status,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    return RefreshIndicator(
      onRefresh:
          onRefresh,
      child: ListView(
        physics:
            const AlwaysScrollableScrollPhysics(),
        children: [
          const SizedBox(
            height: 180,
          ),
          const Icon(
            Icons
                .receipt_long_outlined,
            size: 80,
            color: Colors.grey,
          ),
          const SizedBox(
            height: 16,
          ),
          Center(
            child: Text(
              status == 'ALL'
                  ? 'No orders yet'
                  : 'No ${status.toLowerCase()} orders',
              style:
                  const TextStyle(
                fontSize: 20,
                fontWeight:
                    FontWeight
                        .bold,
              ),
            ),
          ),
          const SizedBox(
            height: 8,
          ),
          const Center(
            child: Text(
              'Orders from customers will appear here.',
              style:
                  TextStyle(
                color:
                    Colors.grey,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ErrorView
    extends StatelessWidget {
  final String message;
  final Future<void> Function()
      onRetry;

  const _ErrorView({
    required this.message,
    required this.onRetry,
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
        child: Column(
          mainAxisSize:
              MainAxisSize.min,
          children: [
            const Icon(
              Icons.error_outline,
              size: 70,
              color: Colors.red,
            ),
            const SizedBox(
              height: 16,
            ),
            Text(
              message,
              textAlign:
                  TextAlign.center,
            ),
            const SizedBox(
              height: 16,
            ),
            ElevatedButton.icon(
              onPressed:
                  onRetry,
              icon:
                  const Icon(
                Icons.refresh,
              ),
              label:
                  const Text(
                'Try Again',
              ),
            ),
          ],
        ),
      ),
    );
  }
}