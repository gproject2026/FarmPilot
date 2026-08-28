import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/order_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/order_provider.dart';
import '../../providers/locale_provider.dart';

const Color _ordersDarkGreen = Color(0xFF173F24);
const Color _ordersPrimaryGreen = Color(0xFF2F6B3D);
const Color _ordersLightGreen = Color(0xFFDDECB8);
const Color _ordersBackground = Color(0xFFF8FAF4);
const Color _ordersTextPrimary = Color(0xFF1D2C21);
const Color _ordersTextSecondary = Color(0xFF68756B);

class CustomerOrdersScreen extends StatefulWidget {
  const CustomerOrdersScreen({
    super.key,
  });

  @override
  State<CustomerOrdersScreen> createState() =>
      _CustomerOrdersScreenState();
}

class _CustomerOrdersScreenState
    extends State<CustomerOrdersScreen> {
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

    await orderProvider
        .fetchCustomerOrders(
      token: token,
    );
  }

  Future<void> _cancelOrder(
    OrderModel order,
  ) async {
    final shouldCancel =
        await showDialog<bool>(
      context: context,
      builder:
          (dialogContext) {
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
                Icons.cancel_outlined,
                color: Color(0xFFB44F4F),
              ),
              const SizedBox(
                width: 10,
              ),
              Text(
                _isArabic
                    ? 'إلغاء الطلب'
                    : 'Cancel Order',
              ),
            ],
          ),
          content: Text(
            _isArabic
                ? 'هل أنت متأكد من إلغاء هذا الطلب؟'
                : 'Are you sure you want to cancel this order?',
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
                _isArabic ? 'لا' : 'No',
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(
                  dialogContext,
                  true,
                );
              },
              style:
                  ElevatedButton.styleFrom(
                backgroundColor:
                    const Color(
                  0xFFB44F4F,
                ),
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
              child: Text(
                _isArabic
                    ? 'نعم، إلغاء الطلب'
                    : 'Yes, Cancel',
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
        await orderProvider
            .cancelOrder(
      token: token,
      orderId: order.id,
    );

    if (!mounted) {
      return;
    }

    if (success) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(
              _isArabic
                  ? 'تم إلغاء الطلب بنجاح'
                  : 'Order cancelled successfully',
            ),
            backgroundColor:
                _ordersPrimaryGreen,
          ),
        );
    } else {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(
              orderProvider
                      .errorMessage ??
                  (_isArabic
                      ? 'فشل إلغاء الطلب'
                      : 'Failed to cancel order'),
            ),
            backgroundColor:
                Colors.red,
          ),
        );
    }
  }

  @override
  Widget build(
    BuildContext context,
  ) {
    return Scaffold(
      backgroundColor:
          _ordersBackground,
      body: Stack(
        children: [
          const Positioned.fill(
            child:
                _OrdersBackdrop(),
          ),
          Consumer<OrderProvider>(
            builder: (
              context,
              orderProvider,
              child,
            ) {
              return RefreshIndicator(
                onRefresh:
                    _loadOrders,
                color:
                    _ordersPrimaryGreen,
                child:
                    CustomScrollView(
                  physics:
                      const AlwaysScrollableScrollPhysics(),
                  slivers: [
                    SliverToBoxAdapter(
                      child:
                          _buildHeader(
                        orderProvider:
                            orderProvider,
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: Padding(
                        padding:
                            const EdgeInsets.fromLTRB(
                          22,
                          24,
                          22,
                          16,
                        ),
                        child:
                            _buildIntroCard(
                          orderProvider,
                        ),
                      ),
                    ),
                    if (orderProvider
                            .isLoading &&
                        orderProvider
                            .customerOrders
                            .isEmpty)
                      const SliverFillRemaining(
                        hasScrollBody:
                            false,
                        child: Center(
                          child:
                              CircularProgressIndicator(
                            color:
                                _ordersPrimaryGreen,
                          ),
                        ),
                      )
                    else if (orderProvider
                                .errorMessage !=
                            null &&
                        orderProvider
                            .customerOrders
                            .isEmpty)
                      SliverFillRemaining(
                        hasScrollBody:
                            false,
                        child:
                            _ErrorView(
                          isArabic: _isArabic,
                          message:
                              orderProvider
                                  .errorMessage!,
                          onRetry:
                              _loadOrders,
                        ),
                      )
                    else if (orderProvider
                        .customerOrders
                        .isEmpty)
                      SliverFillRemaining(
                        hasScrollBody:
                            false,
                        child:
                            _EmptyOrdersView(
                          isArabic: _isArabic,
                          onRefresh:
                              _loadOrders,
                        ),
                      )
                    else
                      SliverPadding(
                        padding:
                            const EdgeInsets.fromLTRB(
                          22,
                          0,
                          22,
                          42,
                        ),
                        sliver:
                            SliverList.separated(
                          itemCount:
                              orderProvider
                                  .customerOrders
                                  .length,
                          separatorBuilder:
                              (
                            context,
                            index,
                          ) {
                            return const SizedBox(
                              height: 16,
                            );
                          },
                          itemBuilder:
                              (
                            context,
                            index,
                          ) {
                            final order =
                                orderProvider
                                        .customerOrders[
                                    index];

                            return _OrderCard(
                              isArabic: _isArabic,
                              order:
                                  order,
                              isLoading:
                                  orderProvider
                                      .isLoading,
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
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildHeader({
    required OrderProvider
        orderProvider,
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
                _ordersDarkGreen
                    .withValues(
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
              tooltip: _isArabic ? 'رجوع' : 'Back',
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
                    _ordersLightGreen,
                borderRadius:
                    BorderRadius.circular(
                  13,
                ),
              ),
              child:
                  const Icon(
                Icons.eco_rounded,
                color:
                    _ordersDarkGreen,
                size: 24,
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
                      fontSize: 19,
                      fontWeight:
                          FontWeight.w800,
                    ),
                  ),
                  SizedBox(
                    height: 2,
                  ),
                  Text(
                    _isArabic ? 'طلباتي' : 'My Orders',
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
              tooltip: '',
              offset: const Offset(0, 50),
              color: Colors.white,
              elevation: 8,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              onSelected: _changeLanguage,
              itemBuilder: (context) => [
                PopupMenuItem<String>(
                  value: 'en',
                  child: Row(
                    children: [
                      if (!_isArabic) ...[
                        const Icon(
                          Icons.check_rounded,
                          color: _ordersPrimaryGreen,
                          size: 20,
                        ),
                        const SizedBox(width: 10),
                      ],
                      const Text('English'),
                    ],
                  ),
                ),
                PopupMenuItem<String>(
                  value: 'ar',
                  child: Row(
                    children: [
                      if (_isArabic) ...[
                        const Icon(
                          Icons.check_rounded,
                          color: _ordersPrimaryGreen,
                          size: 20,
                        ),
                        const SizedBox(width: 10),
                      ],
                      const Text('العربية'),
                    ],
                  ),
                ),
              ],
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
            _HeaderButton(
              icon:
                  Icons.refresh_rounded,
              tooltip:
                  _isArabic ? 'تحديث' : 'Refresh',
              onTap:
                  orderProvider
                          .isLoading
                      ? null
                      : _loadOrders,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIntroCard(
    OrderProvider orderProvider,
  ) {
    final totalOrders =
        orderProvider
            .customerOrders.length;

    final pendingOrders =
        orderProvider.customerOrders
            .where(
              (order) =>
                  order.status ==
                  'PENDING',
            )
            .length;

    return Container(
      width:
          double.infinity,
      padding:
          const EdgeInsets.symmetric(
        horizontal: 24,
        vertical: 22,
      ),
      decoration:
          BoxDecoration(
        gradient:
            const LinearGradient(
          begin:
              AlignmentDirectional
                  .centerStart,
          end:
              AlignmentDirectional
                  .centerEnd,
          colors: [
            Color(
              0xFFFFFFFF,
            ),
            Color(
              0xFFFFFEFA,
            ),
            Color(
              0xFFF5F9EE,
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
            0xFFDDE7D8,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color:
                _ordersDarkGreen
                    .withValues(
              alpha: 0.045,
            ),
            blurRadius: 18,
            offset:
                const Offset(
              0,
              6,
            ),
          ),
        ],
      ),
      child: LayoutBuilder(
        builder: (
          context,
          constraints,
        ) {
          final isCompact =
              constraints.maxWidth <
                  620;

          final heading =
              Row(
            children: [
              Container(
                width: 54,
                height: 54,
                decoration:
                    BoxDecoration(
                  color:
                      const Color(
                    0xFFEAF3DF,
                  ),
                  borderRadius:
                      BorderRadius
                          .circular(
                    17,
                  ),
                ),
                child:
                    const Icon(
                  Icons.receipt_long_outlined,
                  color:
                      _ordersPrimaryGreen,
                  size: 28,
                ),
              ),
              const SizedBox(
                width: 16,
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment
                          .start,
                  children: [
                    Text(
                      _isArabic ? 'طلباتي' : 'My Orders',
                      style:
                          const TextStyle(
                        color:
                            _ordersTextPrimary,
                        fontSize: 24,
                        fontWeight:
                            FontWeight
                                .w800,
                      ),
                    ),
                    const SizedBox(
                      height: 4,
                    ),
                    Text(
                      _isArabic
                          ? 'تابع مشترياتك وراجع حالة كل طلب.'
                          : 'Track your purchases and review the status of each order.',
                      style:
                          const TextStyle(
                        color:
                            _ordersTextSecondary,
                        fontSize: 13,
                        height: 1.45,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );

          final stats =
              Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _MiniStat(
                label:
                    _isArabic ? 'إجمالي الطلبات' : 'Total Orders',
                value:
                    totalOrders
                        .toString(),
                icon:
                    Icons
                        .shopping_bag_outlined,
                background:
                    const Color(
                  0xFFEAF3DF,
                ),
                foreground:
                    _ordersPrimaryGreen,
              ),
              _MiniStat(
                label:
                    _isArabic ? 'قيد الانتظار' : 'Pending',
                value:
                    pendingOrders
                        .toString(),
                icon:
                    Icons
                        .schedule_rounded,
                background:
                    const Color(
                  0xFFFFF0DE,
                ),
                foreground:
                    const Color(
                  0xFFB46A2C,
                ),
              ),
            ],
          );

          if (isCompact) {
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
                child: heading,
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
            BorderRadius.circular(
          14,
        ),
        child: InkWell(
          onTap: onTap,
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

class _MiniStat
    extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color background;
  final Color foreground;

  const _MiniStat({
    required this.label,
    required this.value,
    required this.icon,
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
        horizontal: 13,
        vertical: 10,
      ),
      decoration:
          BoxDecoration(
        color: background,
        borderRadius:
            BorderRadius.circular(
          16,
        ),
      ),
      child: Row(
        mainAxisSize:
            MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: foreground,
            size: 18,
          ),
          const SizedBox(
            width: 7,
          ),
          Text(
            '$label: $value',
            style: TextStyle(
              color: foreground,
              fontSize: 12,
              fontWeight:
                  FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _OrderCard
    extends StatelessWidget {
  final bool isArabic;
  final OrderModel order;
  final bool isLoading;
  final VoidCallback onCancel;

  const _OrderCard({
    required this.isArabic,
    required this.order,
    required this.isLoading,
    required this.onCancel,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    final canCancel =
        order.status ==
            'PENDING';

    return Container(
      padding:
          const EdgeInsets.all(
        20,
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
                _ordersDarkGreen
                    .withValues(
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
        crossAxisAlignment:
            CrossAxisAlignment
                .start,
        children: [
          Row(
            crossAxisAlignment:
                CrossAxisAlignment
                    .start,
            children: [
              Container(
                width: 50,
                height: 50,
                decoration:
                    BoxDecoration(
                  color:
                      const Color(
                    0xFFEAF3DF,
                  ),
                  borderRadius:
                      BorderRadius
                          .circular(
                    16,
                  ),
                ),
                child:
                    const Icon(
                  Icons
                      .shopping_bag_outlined,
                  color:
                      _ordersPrimaryGreen,
                  size: 24,
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
                      isArabic
                          ? 'طلب رقم #${_shortOrderId(order.id)}'
                          : 'Order #${_shortOrderId(order.id)}',
                      style:
                          const TextStyle(
                        color:
                            _ordersTextPrimary,
                        fontSize: 18,
                        fontWeight:
                            FontWeight
                                .w800,
                      ),
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                    Row(
                      children: [
                        const Icon(
                          Icons
                              .schedule_outlined,
                          size: 15,
                          color:
                              _ordersTextSecondary,
                        ),
                        const SizedBox(
                          width: 5,
                        ),
                        Text(
                          _formatDate(
                            order.createdAt,
                          ),
                          style:
                              const TextStyle(
                            color:
                                _ordersTextSecondary,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(
                width: 10,
              ),
              _StatusBadge(
                isArabic: isArabic,
                status:
                    order.status,
              ),
            ],
          ),
          const SizedBox(
            height: 18,
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
                0xFFF7F9F4,
              ),
              borderRadius:
                  BorderRadius
                      .circular(
                18,
              ),
              border:
                  Border.all(
                color:
                    const Color(
                  0xFFE4EAE1,
                ),
              ),
            ),
            child: Column(
              children:
                  order.orderItems
                      .map(
                (item) {
                  return _OrderItemRow(
                    isArabic: isArabic,
                    item: item,
                  );
                },
              ).toList(),
            ),
          ),
          const SizedBox(
            height: 18,
          ),
          _OrderFulfillmentDetails(
            isArabic: isArabic,
            order: order,
          ),
          const SizedBox(
            height: 18,
          ),
          Row(
            children: [
              Text(
                isArabic ? 'الإجمالي' : 'Total',
                style:
                    TextStyle(
                  color:
                      _ordersTextPrimary,
                  fontSize: 16,
                  fontWeight:
                      FontWeight.w700,
                ),
              ),
              const Spacer(),
              Text(
                '${order.totalPrice.toStringAsFixed(2)} ₪',
                style:
                    const TextStyle(
                  color:
                      _ordersPrimaryGreen,
                  fontSize: 21,
                  fontWeight:
                      FontWeight.w800,
                ),
              ),
            ],
          ),
          if (canCancel) ...[
            const SizedBox(
              height: 16,
            ),
            SizedBox(
              width:
                  double.infinity,
              height: 46,
              child:
                  OutlinedButton.icon(
                onPressed:
                    isLoading
                        ? null
                        : onCancel,
                icon:
                    const Icon(
                  Icons.cancel_outlined,
                ),
                label: Text(
                  isArabic
                      ? 'إلغاء الطلب'
                      : 'Cancel Order',
                ),
                style:
                    OutlinedButton.styleFrom(
                  foregroundColor:
                      const Color(
                    0xFFB44F4F,
                  ),
                  side:
                      const BorderSide(
                    color:
                        Color(
                      0xFFD77070,
                    ),
                  ),
                  backgroundColor:
                      const Color(
                    0xFFFFFAFA,
                  ),
                  shape:
                      RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius
                            .circular(
                      14,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ],
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


class _OrderFulfillmentDetails extends StatelessWidget {
  final bool isArabic;
  final OrderModel order;

  const _OrderFulfillmentDetails({
    required this.isArabic,
    required this.order,
  });

  @override
  Widget build(BuildContext context) {
    final isDelivery = order.deliveryMethod == 'DELIVERY';

    final methodLabel = isDelivery
        ? (isArabic ? 'توصيل' : 'Delivery')
        : (isArabic ? 'استلام من المزارع' : 'Pickup from Farmer');

    final paymentLabel = isDelivery
        ? (isArabic ? 'الدفع نقدًا عند التوصيل' : 'Cash on Delivery')
        : (isArabic ? 'الدفع نقدًا عند الاستلام' : 'Cash on Pickup');

    final location = isDelivery
        ? order.deliveryAddress?.trim()
        : order.pickupLocation?.trim();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F9EE),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: const Color(0xFFDDE7D8),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                isDelivery
                    ? Icons.local_shipping_outlined
                    : Icons.storefront_outlined,
                color: _ordersPrimaryGreen,
                size: 21,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  isArabic ? 'تفاصيل الاستلام والدفع' : 'Fulfillment & Payment',
                  style: const TextStyle(
                    color: _ordersTextPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          _OrderDetailRow(
            icon: isDelivery
                ? Icons.local_shipping_outlined
                : Icons.shopping_bag_outlined,
            label: isArabic ? 'طريقة الاستلام' : 'Delivery Method',
            value: methodLabel,
          ),
          const SizedBox(height: 11),
          _OrderDetailRow(
            icon: Icons.payments_outlined,
            label: isArabic ? 'طريقة الدفع' : 'Payment Method',
            value: paymentLabel,
          ),
          if (location != null && location.isNotEmpty) ...[
            const SizedBox(height: 11),
            _OrderDetailRow(
              icon: Icons.location_on_outlined,
              label: isDelivery
                  ? (isArabic ? 'عنوان التوصيل' : 'Delivery Address')
                  : (isArabic ? 'موقع الاستلام' : 'Pickup Location'),
              value: location,
            ),
          ],
        ],
      ),
    );
  }
}

class _OrderDetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _OrderDetailRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 18,
          color: _ordersTextSecondary,
        ),
        const SizedBox(width: 9),
        Expanded(
          child: RichText(
            text: TextSpan(
              style: const TextStyle(
                color: _ordersTextSecondary,
                fontSize: 12.5,
                height: 1.45,
              ),
              children: [
                TextSpan(
                  text: '$label: ',
                  style: const TextStyle(
                    color: _ordersTextPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                TextSpan(text: value),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _OrderItemRow
    extends StatelessWidget {
  final bool isArabic;
  final OrderItemModel item;

  const _OrderItemRow({
    required this.isArabic,
    required this.item,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    final productName =
        item.product.localizedName(
      isArabic,
    );

    final unit =
        item.product.unit.isEmpty
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
                .center,
        children: [
          Container(
            width: 46,
            height: 46,
            decoration:
                BoxDecoration(
              color:
                  const Color(
                0xFFEAF3DF,
              ),
              borderRadius:
                  BorderRadius
                      .circular(
                12,
              ),
            ),
            child:
                const Icon(
              Icons
                  .shopping_basket_outlined,
              color:
                  _ordersPrimaryGreen,
              size: 22,
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
                  maxLines: 1,
                  overflow:
                      TextOverflow
                          .ellipsis,
                  style:
                      const TextStyle(
                    color:
                        _ordersTextPrimary,
                    fontWeight:
                        FontWeight.w700,
                  ),
                ),
                const SizedBox(
                  height: 4,
                ),
                Text(
                  isArabic
                      ? 'الكمية: ${item.quantity}$unit'
                      : 'Quantity: ${item.quantity}$unit',
                  style:
                      const TextStyle(
                    color:
                        _ordersTextSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(
            width: 10,
          ),
          Text(
            '${(item.price * item.quantity).toStringAsFixed(2)} ₪',
            style:
                const TextStyle(
              color:
                  _ordersTextPrimary,
              fontWeight:
                  FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusBadge
    extends StatelessWidget {
  final bool isArabic;
  final String status;

  const _StatusBadge({
    required this.isArabic,
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

    final background =
        _statusBackground(
      status,
    );

    return Container(
      padding:
          const EdgeInsets.symmetric(
        horizontal: 11,
        vertical: 7,
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
            _statusIcon(
              status,
            ),
            color: color,
            size: 15,
          ),
          const SizedBox(
            width: 5,
          ),
          Text(
            _statusLabel(
              status,
              isArabic,
            ),
            style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight:
                  FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }

  Color _statusColor(
    String value,
  ) {
    switch (value) {
      case 'CONFIRMED':
        return const Color(
          0xFF52709C,
        );
      case 'COMPLETED':
        return const Color(
          0xFF3B7B45,
        );
      case 'CANCELLED':
        return const Color(
          0xFFB44F4F,
        );
      case 'PENDING':
      default:
        return const Color(
          0xFFB46A2C,
        );
    }
  }

  Color _statusBackground(
    String value,
  ) {
    switch (value) {
      case 'CONFIRMED':
        return const Color(
          0xFFE8EEF7,
        );
      case 'COMPLETED':
        return const Color(
          0xFFE7F1E7,
        );
      case 'CANCELLED':
        return const Color(
          0xFFFCE7E7,
        );
      case 'PENDING':
      default:
        return const Color(
          0xFFFFEFE0,
        );
    }
  }

  IconData _statusIcon(
    String value,
  ) {
    switch (value) {
      case 'CONFIRMED':
        return Icons
            .verified_outlined;
      case 'COMPLETED':
        return Icons
            .check_circle_outline_rounded;
      case 'CANCELLED':
        return Icons
            .cancel_outlined;
      case 'PENDING':
      default:
        return Icons
            .schedule_rounded;
    }
  }

  String _statusLabel(
    String value,
    bool isArabic,
  ) {
    switch (value) {
      case 'CONFIRMED':
        return isArabic ? 'مؤكد' : 'Confirmed';
      case 'COMPLETED':
        return isArabic ? 'مكتمل' : 'Completed';
      case 'CANCELLED':
        return isArabic ? 'ملغي' : 'Cancelled';
      case 'PENDING':
      default:
        return isArabic ? 'قيد الانتظار' : 'Pending';
    }
  }
}

class _EmptyOrdersView
    extends StatelessWidget {
  final bool isArabic;
  final Future<void> Function()
      onRefresh;

  const _EmptyOrdersView({
    required this.isArabic,
    required this.onRefresh,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    return RefreshIndicator(
      onRefresh: onRefresh,
      color:
          _ordersPrimaryGreen,
      child: ListView(
        physics:
            const AlwaysScrollableScrollPhysics(),
        children: [
          const SizedBox(
            height: 130,
          ),
          Center(
            child: Container(
              constraints:
                  const BoxConstraints(
                maxWidth: 470,
              ),
              margin:
                  const EdgeInsets.symmetric(
                horizontal: 22,
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
                        _ordersDarkGreen
                            .withValues(
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
              child:
                  Column(
                children: [
                  const Icon(
                    Icons
                        .receipt_long_outlined,
                    size: 72,
                    color:
                        _ordersPrimaryGreen,
                  ),
                  const SizedBox(
                    height: 16,
                  ),
                  Text(
                    isArabic
                        ? 'لا توجد طلبات بعد'
                        : 'No orders yet',
                    style:
                        const TextStyle(
                      color:
                          _ordersTextPrimary,
                      fontSize: 21,
                      fontWeight:
                          FontWeight.w800,
                    ),
                  ),
                  const SizedBox(
                    height: 8,
                  ),
                  Text(
                    isArabic
                        ? 'ستظهر طلباتك هنا بعد إتمام عملية شراء.'
                        : 'Your orders will appear here after you complete a purchase.',
                    textAlign:
                        TextAlign.center,
                    style:
                        const TextStyle(
                      color:
                          _ordersTextSecondary,
                      fontSize: 14,
                      height: 1.5,
                    ),
                  ),
                ],
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
  final bool isArabic;
  final String message;
  final Future<void> Function()
      onRetry;

  const _ErrorView({
    required this.isArabic,
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
        child: Container(
          constraints:
              const BoxConstraints(
            maxWidth: 470,
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
                0xFFF0D6D6,
              ),
            ),
          ),
          child: Column(
            mainAxisSize:
                MainAxisSize.min,
            children: [
              const Icon(
                Icons
                    .error_outline_rounded,
                size: 64,
                color:
                    Color(
                  0xFFB44F4F,
                ),
              ),
              const SizedBox(
                height: 16,
              ),
              Text(
                message,
                textAlign:
                    TextAlign.center,
                style:
                    const TextStyle(
                  color:
                      _ordersTextPrimary,
                  fontSize: 15,
                  height: 1.5,
                ),
              ),
              const SizedBox(
                height: 18,
              ),
              ElevatedButton.icon(
                onPressed:
                    onRetry,
                style:
                    ElevatedButton.styleFrom(
                  backgroundColor:
                      _ordersPrimaryGreen,
                  foregroundColor:
                      Colors.white,
                  elevation: 0,
                  shape:
                      RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius
                            .circular(
                      14,
                    ),
                  ),
                ),
                icon:
                    const Icon(
                  Icons.refresh_rounded,
                ),
                label: Text(
                  isArabic
                      ? 'حاول مرة أخرى'
                      : 'Try Again',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OrdersBackdrop
    extends StatelessWidget {
  const _OrdersBackdrop();

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
            top: 200,
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
