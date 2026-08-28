import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../l10n/generated/app_localizations.dart';
import '../../models/order_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/order_provider.dart';
import '../../providers/locale_provider.dart';

String _t(
  BuildContext context,
  String english,
  String arabic,
) {
  return Localizations.localeOf(context)
              .languageCode ==
          'ar'
      ? arabic
      : english;
}

String _localizedStatus(
  BuildContext context,
  String status,
) {
  switch (status.trim().toUpperCase()) {
    case 'CONFIRMED':
      return _t(
        context,
        'Confirmed',
        'مؤكد',
      );
    case 'COMPLETED':
      return _t(
        context,
        'Completed',
        'مكتمل',
      );
    case 'CANCELLED':
      return _t(
        context,
        'Cancelled',
        'ملغي',
      );
    case 'PENDING':
    default:
      return _t(
        context,
        'Pending',
        'قيد الانتظار',
      );
  }
}

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
          title: Text(
            _t(
              context,
              'Confirm Order',
              'تأكيد الطلب',
            ),
          ),
          content: Text(
            _t(
              context,
              'Are you sure you want to confirm this order?',
              'هل أنت متأكد أنك تريد تأكيد هذا الطلب؟',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(
                  dialogContext,
                  false,
                );
              },
              child: Text(
                _t(
                  context,
                  'No',
                  'لا',
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(
                  dialogContext,
                  true,
                );
              },
              child: Text(
                _t(
                  context,
                  'Confirm',
                  'تأكيد',
                ),
              ),
            ),
          ],
        );
      },
    );

    if (shouldConfirm != true ||
        !mounted) {
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

    final token = authProvider.token;

    if (token == null ||
        token.isEmpty) {
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
      successMessage: _t(
        context,
        'Order confirmed successfully',
        'تم تأكيد الطلب بنجاح',
      ),
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
          title: Text(
            _t(
              context,
              'Complete Order',
              'إكمال الطلب',
            ),
          ),
          content: Text(
            _t(
              context,
              'Are you sure this order has been completed?',
              'هل أنت متأكد أن هذا الطلب قد اكتمل؟',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(
                  dialogContext,
                  false,
                );
              },
              child: Text(
                _t(
                  context,
                  'No',
                  'لا',
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(
                  dialogContext,
                  true,
                );
              },
              child: Text(
                _t(
                  context,
                  'Complete',
                  'إكمال',
                ),
              ),
            ),
          ],
        );
      },
    );

    if (shouldComplete != true ||
        !mounted) {
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

    final token = authProvider.token;

    if (token == null ||
        token.isEmpty) {
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
      successMessage: _t(
        context,
        'Order completed successfully',
        'تم إكمال الطلب بنجاح',
      ),
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
          title: Text(
            _t(
              context,
              'Cancel Order',
              'إلغاء الطلب',
            ),
          ),
          content: Text(
            _t(
              context,
              'Are you sure you want to cancel this order?',
              'هل أنت متأكد أنك تريد إلغاء هذا الطلب؟',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(
                  dialogContext,
                  false,
                );
              },
              child: Text(
                _t(
                  context,
                  'No',
                  'لا',
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(
                  dialogContext,
                  true,
                );
              },
              child: Text(
                _t(
                  context,
                  'Yes, Cancel',
                  'نعم، إلغاء',
                ),
                style: const TextStyle(
                  color: Colors.red,
                ),
              ),
            ),
          ],
        );
      },
    );

    if (shouldCancel != true ||
        !mounted) {
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

    final token = authProvider.token;

    if (token == null ||
        token.isEmpty) {
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
      successMessage: _t(
        context,
        'Order cancelled successfully',
        'تم إلغاء الطلب بنجاح',
      ),
      errorMessage:
          orderProvider.errorMessage,
    );
  }

  void _showResultMessage({
    required bool success,
    required String successMessage,
    String? errorMessage,
  }) {
    final message = success
        ? successMessage
        : (errorMessage == null ||
                errorMessage.trim().isEmpty)
            ? _t(
                context,
                'Something went wrong',
                'حدث خطأ ما',
              )
            : errorMessage;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            message,
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

  const _OrdersTopBar({
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    final l10n =
        AppLocalizations.of(context)!;

    final isArabic =
        Localizations.localeOf(context)
                .languageCode ==
            'ar';

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
      padding: const EdgeInsets.fromLTRB(
        18,
        12,
        18,
        14,
      ),
      child: SafeArea(
        bottom: false,
        child: Row(
          children: [
            _HeaderButton(
              icon: Icons.arrow_back_rounded,
              tooltip: _t(
                context,
                'Back',
                'رجوع',
              ),
              onTap: () =>
                  Navigator.pop(context),
            ),
            const SizedBox(width: 12),
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: const Color(
                  0xFFDDECB8,
                ),
                borderRadius:
                    BorderRadius.circular(
                  13,
                ),
              ),
              child: const Icon(
                Icons.eco_rounded,
                color: _ordersDark,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.appName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 19,
                      fontWeight:
                          FontWeight.w800,
                    ),
                  ),
                  Text(
                    _t(
                      context,
                      'Manage Orders',
                      'إدارة الطلبات',
                    ),
                    style: const TextStyle(
                      color:
                          Color(0xCCFFFFFF),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            PopupMenuButton<String>(
              tooltip:
                  l10n.changeLanguage,
              position:
                  PopupMenuPosition.under,
              offset:
                  const Offset(0, 8),
              color:
                  const Color(0xFFF8FAF4),
              elevation: 8,
              shape: RoundedRectangleBorder(
                borderRadius:
                    BorderRadius.circular(
                  16,
                ),
              ),
              onSelected: (languageCode) {
                Provider.of<LocaleProvider>(
                  context,
                  listen: false,
                ).setLocale(
                  Locale(languageCode),
                );
              },
              itemBuilder: (context) {
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
                          color: !isArabic
                              ? _ordersPrimary
                              : Colors.transparent,
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                        Text(
                          l10n.english,
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
                          color: isArabic
                              ? _ordersPrimary
                              : Colors.transparent,
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                        Text(
                          l10n.arabic,
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
                  color: Colors.white
                      .withValues(
                    alpha: 0.10,
                  ),
                  borderRadius:
                      BorderRadius.circular(
                    14,
                  ),
                ),
                alignment:
                    Alignment.center,
                child: const Icon(
                  Icons.language_rounded,
                  color: Colors.white,
                  size: 21,
                ),
              ),
            ),
            const SizedBox(width: 10),
            _HeaderButton(
              icon: Icons.refresh_rounded,
              tooltip: _t(
                context,
                'Refresh',
                'تحديث',
              ),
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
              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      _t(
                        context,
                        'Customer Orders',
                        'طلبات العملاء',
                      ),
                      style: const TextStyle(
                        color: _ordersText,
                        fontSize: 24,
                        fontWeight:
                            FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _t(
                        context,
                        'Review incoming orders and keep every order status up to date.',
                        'راجع الطلبات الواردة وحافظ على تحديث حالة كل طلب.',
                      ),
                      style: const TextStyle(
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
              _MiniStat(
                label: _t(
                  context,
                  'Total',
                  'الإجمالي',
                ),
                value: total,
              ),
              _MiniStat(
                label: _t(
                  context,
                  'Pending',
                  'قيد الانتظار',
                ),
                value: pending,
              ),
              _MiniStat(
                label: _t(
                  context,
                  'Confirmed',
                  'مؤكد',
                ),
                value: confirmed,
              ),
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
            label: Text(_filterLabel(context, status)),
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

  String _filterLabel(BuildContext context, String status) {
    switch (status) {
      case 'ALL':
        return _t(context, 'All Orders', 'كل الطلبات');
      case 'PENDING':
        return _t(context, 'Pending', 'قيد الانتظار');
      case 'CONFIRMED':
        return _t(context, 'Confirmed', 'مؤكد');
      case 'COMPLETED':
        return _t(context, 'Completed', 'مكتمل');
      case 'CANCELLED':
        return _t(context, 'Cancelled', 'ملغي');
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
                      "${_t(context, 'Order', 'طلب')} #${_shortOrderId(order.id)}",
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
          _FulfillmentPanel(order: order),
          const SizedBox(height: 18),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 17, vertical: 15),
            decoration: BoxDecoration(
              color: const Color(0xFFF5F8F1),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    _t(
                      context,
                      'Order Total',
                      'إجمالي الطلب',
                    ),
                    style: const TextStyle(
                      color: _ordersText,
                      fontSize: 14,
                      fontWeight:
                          FontWeight.w700,
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
                    label: Text(_t(context, 'Confirm Order', 'تأكيد الطلب')),
                  ),
                if (canComplete)
                  ElevatedButton.icon(
                    onPressed: isLoading ? null : onComplete,
                    style: _primaryButtonStyle(),
                    icon: const Icon(Icons.task_alt_rounded),
                    label: Text(_t(context, 'Complete Order', 'إكمال الطلب')),
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
                    label: Text(_t(context, 'Cancel', 'إلغاء')),
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


class _FulfillmentPanel extends StatelessWidget {
  final OrderModel order;

  const _FulfillmentPanel({
    required this.order,
  });

  @override
  Widget build(BuildContext context) {
    final isDelivery =
        order.deliveryMethod.trim().toUpperCase() == 'DELIVERY';

    final method = isDelivery
        ? _t(context, 'Delivery', 'توصيل')
        : _t(
            context,
            'Pickup from Farmer',
            'استلام من المزارع',
          );

    final payment = isDelivery
        ? _t(
            context,
            'Cash on Delivery',
            'الدفع نقدًا عند التوصيل',
          )
        : _t(
            context,
            'Cash on Pickup',
            'الدفع نقدًا عند الاستلام',
          );

    final location = isDelivery
        ? order.deliveryAddress?.trim()
        : order.pickupLocation?.trim();

    return _InnerPanel(
      title: _t(
        context,
        'Fulfillment & Payment',
        'تفاصيل الاستلام والدفع',
      ),
      icon: isDelivery
          ? Icons.local_shipping_outlined
          : Icons.storefront_outlined,
      child: Column(
        children: [
          _LabeledInfoRow(
            icon: isDelivery
                ? Icons.local_shipping_outlined
                : Icons.shopping_bag_outlined,
            label: _t(
              context,
              'Delivery Method',
              'طريقة الاستلام',
            ),
            value: method,
          ),
          _LabeledInfoRow(
            icon: Icons.payments_outlined,
            label: _t(
              context,
              'Payment Method',
              'طريقة الدفع',
            ),
            value: payment,
          ),
          if (location != null && location.isNotEmpty)
            _LabeledInfoRow(
              icon: Icons.location_on_outlined,
              label: isDelivery
                  ? _t(
                      context,
                      'Delivery Address',
                      'عنوان التوصيل',
                    )
                  : _t(
                      context,
                      'Pickup Location',
                      'موقع الاستلام',
                    ),
              value: location,
              isLast: true,
            ),
        ],
      ),
    );
  }
}

class _LabeledInfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final bool isLast;

  const _LabeledInfoRow({
    required this.icon,
    required this.label,
    required this.value,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: isLast ? 0 : 9,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: 17,
            color: _ordersMuted,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: const TextStyle(
                  color: _ordersMuted,
                  fontSize: 13,
                  height: 1.4,
                ),
                children: [
                  TextSpan(
                    text: '$label: ',
                    style: const TextStyle(
                      color: _ordersText,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  TextSpan(text: value),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CustomerPanel extends StatelessWidget {
  final OrderModel order;

  const _CustomerPanel({required this.order});

  @override
  Widget build(BuildContext context) {
    final customer = order.customer;
    return _InnerPanel(
      title: _t(context, 'Customer', 'العميل'),
      icon: Icons.person_outline_rounded,
      child: Column(
        children: [
          _InfoRow(
            icon: Icons.person_outline,
            text: customer.fullName.isEmpty ? _t(context, 'Customer', 'العميل') : customer.fullName,
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
      title: _t(context, 'Order Items', 'عناصر الطلب'),
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
        item.product.name.isEmpty ? _t(context, 'Product', 'منتج') : item.product.name;
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
                  "${_t(context, 'Quantity', 'الكمية')}: ${item.quantity}$unit",
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
        _localizedStatus(context, status),
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
                  ? _t(
                      context,
                      'No orders yet',
                      'لا توجد طلبات بعد',
                    )
                  : _t(
                      context,
                      'No ${status.toLowerCase()} orders',
                      'لا توجد طلبات بحالة ${_localizedStatus(context, status)}',
                    ),
              style: const TextStyle(
                color: _ordersText,
                fontSize: 19,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              _t(
                context,
                'Orders from customers will appear here.',
                'ستظهر طلبات العملاء هنا.',
              ),
              style: const TextStyle(
                color: _ordersMuted,
              ),
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
              label: Text(_t(context, 'Try Again', 'حاول مرة أخرى')),
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
