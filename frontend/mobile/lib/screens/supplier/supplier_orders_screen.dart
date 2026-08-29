import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_constants.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../providers/locale_provider.dart';
import '../../providers/supplier_order_provider.dart';

String _t(
  BuildContext context,
  String english,
  String arabic,
) {
  return Localizations.localeOf(context).languageCode == 'ar'
      ? arabic
      : english;
}

String _localizedStatus(
  BuildContext context,
  String status,
) {
  switch (status.trim().toUpperCase()) {
    case 'CONFIRMED':
      return _t(context, 'Confirmed', 'مؤكد');
    case 'COMPLETED':
      return _t(context, 'Completed', 'مكتمل');
    case 'CANCELLED':
      return _t(context, 'Cancelled', 'ملغي');
    case 'PENDING':
    default:
      return _t(context, 'Pending', 'قيد الانتظار');
  }
}

class SupplierOrdersScreen extends StatefulWidget {
  const SupplierOrdersScreen({
    super.key,
  });

  @override
  State<SupplierOrdersScreen> createState() =>
      _SupplierOrdersScreenState();
}

class _SupplierOrdersScreenState
    extends State<SupplierOrdersScreen> {
  String selectedStatus = 'ALL';

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback(
      (_) => _loadOrders(),
    );
  }

  Future<void> _loadOrders() async {
    await Provider.of<SupplierOrderProvider>(
      context,
      listen: false,
    ).loadSupplierOrders();
  }

  List<Map<String, dynamic>> _ordersFrom(
    List orders,
  ) {
    return orders
        .whereType<Map>()
        .map(
          (order) =>
              Map<String, dynamic>.from(order),
        )
        .where((order) {
          if (selectedStatus == 'ALL') {
            return true;
          }

          return order['status']
                  ?.toString()
                  .trim()
                  .toUpperCase() ==
              selectedStatus;
        })
        .toList();
  }

  Future<void> _changeStatus({
    required Map<String, dynamic> order,
    required String status,
  }) async {
    final orderId =
        order['id']?.toString().trim() ?? '';

    if (orderId.isEmpty) {
      _showMessage(
        _t(
          context,
          'Order ID was not found',
          'لم يتم العثور على معرف الطلب',
        ),
        success: false,
      );
      return;
    }

    final action = switch (status) {
      'CONFIRMED' =>
        _t(context, 'confirm', 'تأكيد'),
      'COMPLETED' =>
        _t(context, 'complete', 'إكمال'),
      'CANCELLED' =>
        _t(context, 'cancel', 'إلغاء'),
      _ => _t(context, 'update', 'تحديث'),
    };

    final shouldContinue =
        await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(
            switch (status) {
              'CONFIRMED' => _t(
                  context,
                  'Confirm Supply Order',
                  'تأكيد طلب المستلزمات',
                ),
              'COMPLETED' => _t(
                  context,
                  'Complete Supply Order',
                  'إكمال طلب المستلزمات',
                ),
              'CANCELLED' => _t(
                  context,
                  'Cancel Supply Order',
                  'إلغاء طلب المستلزمات',
                ),
              _ => _t(
                  context,
                  'Update Supply Order',
                  'تحديث طلب المستلزمات',
                ),
            },
          ),
          content: Text(
            _t(
              context,
              'Are you sure you want to $action this supply order?',
              'هل أنت متأكد أنك تريد $action طلب المستلزمات هذا؟',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () =>
                  Navigator.pop(
                dialogContext,
                false,
              ),
              child: Text(
                _t(
                  context,
                  'No',
                  'لا',
                ),
              ),
            ),
            status == 'CANCELLED'
                ? TextButton(
                    onPressed: () =>
                        Navigator.pop(
                      dialogContext,
                      true,
                    ),
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
                  )
                : ElevatedButton(
                    onPressed: () =>
                        Navigator.pop(
                      dialogContext,
                      true,
                    ),
                    child: Text(
                      status == 'CONFIRMED'
                          ? _t(
                              context,
                              'Confirm',
                              'تأكيد',
                            )
                          : _t(
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

    if (shouldContinue != true ||
        !mounted) {
      return;
    }

    final provider =
        Provider.of<SupplierOrderProvider>(
      context,
      listen: false,
    );

    final success =
        await provider.updateOrderStatus(
      orderId: orderId,
      status: status,
    );

    if (!mounted) {
      return;
    }

    _showMessage(
      success
          ? switch (status) {
              'CONFIRMED' => _t(
                  context,
                  'Supply order confirmed successfully',
                  'تم تأكيد طلب المستلزمات بنجاح',
                ),
              'COMPLETED' => _t(
                  context,
                  'Supply order completed successfully',
                  'تم إكمال طلب المستلزمات بنجاح',
                ),
              'CANCELLED' => _t(
                  context,
                  'Supply order cancelled successfully',
                  'تم إلغاء طلب المستلزمات بنجاح',
                ),
              _ => _t(
                  context,
                  'Supply order updated successfully',
                  'تم تحديث طلب المستلزمات بنجاح',
                ),
            }
          : (provider.errorMessage?.trim().isNotEmpty ==
                  true
              ? provider.errorMessage!
              : _t(
                  context,
                  'Something went wrong',
                  'حدث خطأ ما',
                )),
      success: success,
    );
  }

  void _showMessage(
    String message, {
    required bool success,
  }) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor:
              success ? Colors.green : Colors.red,
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          const Color(0xFFF8FAF4),
      body: Consumer<SupplierOrderProvider>(
        builder: (
          context,
          provider,
          child,
        ) {
          final allOrders =
              provider.supplierOrders;
          final orders =
              _ordersFrom(allOrders);

          int countStatus(String status) {
            return allOrders
                .whereType<Map>()
                .where(
                  (order) =>
                      order['status']
                          ?.toString()
                          .trim()
                          .toUpperCase() ==
                      status,
                )
                .length;
          }

          return Stack(
            children: [
              const Positioned.fill(
                child: _OrdersBackdrop(),
              ),
              Column(
                children: [
                  _OrdersTopBar(
                    onRefresh: _loadOrders,
                  ),
                  Expanded(
                    child: provider.isLoading &&
                            allOrders.isEmpty
                        ? const Center(
                            child:
                                CircularProgressIndicator(
                              color:
                                  _ordersPrimary,
                            ),
                          )
                        : provider.errorMessage !=
                                    null &&
                                allOrders.isEmpty
                            ? _ErrorView(
                                message: provider
                                    .errorMessage!,
                                onRetry:
                                    _loadOrders,
                              )
                            : RefreshIndicator(
                                color:
                                    _ordersPrimary,
                                onRefresh:
                                    _loadOrders,
                                child:
                                    CustomScrollView(
                                  physics:
                                      const AlwaysScrollableScrollPhysics(),
                                  slivers: [
                                    SliverToBoxAdapter(
                                      child: Center(
                                        child:
                                            ConstrainedBox(
                                          constraints:
                                              const BoxConstraints(
                                            maxWidth:
                                                1320,
                                          ),
                                          child:
                                              Padding(
                                            padding:
                                                const EdgeInsets.fromLTRB(
                                              24,
                                              26,
                                              24,
                                              0,
                                            ),
                                            child:
                                                Column(
                                              children: [
                                                _OrdersHero(
                                                  total:
                                                      allOrders.length,
                                                  pending:
                                                      countStatus('PENDING'),
                                                  confirmed:
                                                      countStatus('CONFIRMED'),
                                                ),
                                                const SizedBox(
                                                  height:
                                                      18,
                                                ),
                                                _StatusFilter(
                                                  selectedStatus:
                                                      selectedStatus,
                                                  onChanged:
                                                      (status) {
                                                    setState(
                                                      () {
                                                        selectedStatus =
                                                            status;
                                                      },
                                                    );
                                                  },
                                                ),
                                                const SizedBox(
                                                  height:
                                                      18,
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    if (orders
                                        .isEmpty)
                                      SliverFillRemaining(
                                        hasScrollBody:
                                            false,
                                        child:
                                            _EmptyOrdersView(
                                          status:
                                              selectedStatus,
                                        ),
                                      )
                                    else
                                      SliverPadding(
                                        padding:
                                            const EdgeInsets.fromLTRB(
                                          24,
                                          0,
                                          24,
                                          42,
                                        ),
                                        sliver:
                                            SliverList.separated(
                                          itemCount:
                                              orders.length,
                                          separatorBuilder:
                                              (_, _) =>
                                                  const SizedBox(
                                            height:
                                                16,
                                          ),
                                          itemBuilder:
                                              (
                                            context,
                                            index,
                                          ) {
                                            final order =
                                                orders[index];

                                            return Center(
                                              child:
                                                  ConstrainedBox(
                                                constraints:
                                                    const BoxConstraints(
                                                  maxWidth:
                                                      1320,
                                                ),
                                                child:
                                                    _SupplierOrderCard(
                                                  order:
                                                      order,
                                                  isUpdating:
                                                      provider.isUpdatingStatus,
                                                  onConfirm:
                                                      () => _changeStatus(
                                                    order:
                                                        order,
                                                    status:
                                                        'CONFIRMED',
                                                  ),
                                                  onComplete:
                                                      () => _changeStatus(
                                                    order:
                                                        order,
                                                    status:
                                                        'COMPLETED',
                                                  ),
                                                  onCancel:
                                                      () => _changeStatus(
                                                    order:
                                                        order,
                                                    status:
                                                        'CANCELLED',
                                                  ),
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
              icon:
                  Icons.arrow_back_rounded,
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
                color:
                    const Color(0xFFDDECB8),
                borderRadius:
                    BorderRadius.circular(
                  13,
                ),
              ),
              child: const Icon(
                Icons.inventory_2_outlined,
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
                    style:
                        const TextStyle(
                      color: Colors.white,
                      fontSize: 19,
                      fontWeight:
                          FontWeight.w800,
                    ),
                  ),
                  Text(
                    _t(
                      context,
                      'Manage Supply Orders',
                      'إدارة طلبات المستلزمات',
                    ),
                    style:
                        const TextStyle(
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
              shape:
                  RoundedRectangleBorder(
                borderRadius:
                    BorderRadius.circular(
                  16,
                ),
              ),
              onSelected:
                  (languageCode) {
                Provider.of<
                    LocaleProvider>(
                  context,
                  listen: false,
                ).setLocale(
                  Locale(languageCode),
                );
              },
              itemBuilder: (context) => [
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
                            : Colors
                                .transparent,
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                      Text(l10n.english),
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
                            : Colors
                                .transparent,
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                      Text(l10n.arabic),
                    ],
                  ),
                ),
              ],
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
              icon:
                  Icons.refresh_rounded,
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
        color: Colors.white.withValues(
          alpha: 0.10,
        ),
        borderRadius:
            BorderRadius.circular(14),
        child: InkWell(
          onTap: onTap,
          borderRadius:
              BorderRadius.circular(14),
          child: SizedBox(
            width: 44,
            height: 44,
            child: Icon(
              icon,
              color: Colors.white,
              size: 21,
            ),
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
      decoration:
          _ordersCardDecoration(
        radius: 25,
      ),
      child: LayoutBuilder(
        builder: (
          context,
          constraints,
        ) {
          final heading = Row(
            children: [
              Container(
                width: 58,
                height: 58,
                decoration: BoxDecoration(
                  color: _ordersLight,
                  borderRadius:
                      BorderRadius.circular(
                    17,
                  ),
                ),
                child: const Icon(
                  Icons
                      .local_shipping_outlined,
                  color: _ordersPrimary,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment
                          .start,
                  children: [
                    Text(
                      _t(
                        context,
                        'Farmer Supply Orders',
                        'طلبات المستلزمات من المزارعين',
                      ),
                      style:
                          const TextStyle(
                        color: _ordersText,
                        fontSize: 24,
                        fontWeight:
                            FontWeight.w800,
                      ),
                    ),
                    const SizedBox(
                      height: 4,
                    ),
                    Text(
                      _t(
                        context,
                        'Review incoming farmer orders and keep each supply order status up to date.',
                        'راجع طلبات المزارعين الواردة وحافظ على تحديث حالة كل طلب مستلزمات.',
                      ),
                      style:
                          const TextStyle(
                        color:
                            _ordersMuted,
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

          if (constraints.maxWidth <
              720) {
            return Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
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

  const _MiniStat({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding:
          const EdgeInsets.symmetric(
        horizontal: 13,
        vertical: 9,
      ),
      decoration: BoxDecoration(
        color:
            const Color(0xFFF1F6E9),
        borderRadius:
            BorderRadius.circular(14),
      ),
      child: Text(
        '$label  $value',
        style: const TextStyle(
          color: _ordersPrimary,
          fontSize: 12,
          fontWeight:
              FontWeight.w700,
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
        scrollDirection:
            Axis.horizontal,
        itemCount: statuses.length,
        separatorBuilder: (_, _) =>
            const SizedBox(width: 9),
        itemBuilder: (
          context,
          index,
        ) {
          final status =
              statuses[index];
          final selected =
              selectedStatus == status;

          return ChoiceChip(
            label: Text(
              _filterLabel(
                context,
                status,
              ),
            ),
            selected: selected,
            onSelected: (_) =>
                onChanged(status),
            showCheckmark: false,
            backgroundColor:
                Colors.white,
            selectedColor:
                _ordersPrimary,
            side: BorderSide(
              color: selected
                  ? _ordersPrimary
                  : const Color(
                      0xFFDCE5D8,
                    ),
            ),
            labelStyle: TextStyle(
              color: selected
                  ? Colors.white
                  : _ordersMuted,
              fontWeight:
                  FontWeight.w700,
              fontSize: 12,
            ),
            padding:
                const EdgeInsets.symmetric(
              horizontal: 10,
            ),
          );
        },
      ),
    );
  }

  String _filterLabel(
    BuildContext context,
    String status,
  ) {
    switch (status) {
      case 'ALL':
        return _t(
          context,
          'All Orders',
          'كل الطلبات',
        );
      case 'PENDING':
        return _t(
          context,
          'Pending',
          'قيد الانتظار',
        );
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
      default:
        return status;
    }
  }
}

class _SupplierOrderCard
    extends StatelessWidget {
  final Map<String, dynamic> order;
  final bool isUpdating;
  final VoidCallback onConfirm;
  final VoidCallback onComplete;
  final VoidCallback onCancel;

  const _SupplierOrderCard({
    required this.order,
    required this.isUpdating,
    required this.onConfirm,
    required this.onComplete,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    final status = order['status']
            ?.toString()
            .trim()
            .toUpperCase() ??
        'PENDING';

    final canConfirm =
        status == 'PENDING';
    final canComplete =
        status == 'CONFIRMED';
    final canCancel =
        status == 'PENDING' ||
            status == 'CONFIRMED';

    final id =
        order['id']?.toString() ?? '';
    final createdAt =
        _parseDate(order['createdAt']);

    return Container(
      padding: const EdgeInsets.all(22),
      decoration:
          _ordersCardDecoration(
        radius: 22,
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: _ordersLight,
                  borderRadius:
                      BorderRadius.circular(
                    14,
                  ),
                ),
                child: const Icon(
                  Icons
                      .receipt_long_outlined,
                  color: _ordersPrimary,
                ),
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment
                          .start,
                  children: [
                    Text(
                      "${_t(context, 'Supply Order', 'طلب مستلزمات')} #${_shortOrderId(id)}",
                      style:
                          const TextStyle(
                        color: _ordersText,
                        fontSize: 17,
                        fontWeight:
                            FontWeight.w800,
                      ),
                    ),
                    if (createdAt !=
                        null) ...[
                      const SizedBox(
                        height: 4,
                      ),
                      Text(
                        _formatDate(
                          createdAt,
                        ),
                        style:
                            const TextStyle(
                          color:
                              _ordersMuted,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              _StatusBadge(
                status: status,
              ),
            ],
          ),
          const SizedBox(height: 20),
          LayoutBuilder(
            builder: (
              context,
              constraints,
            ) {
              final farmer =
                  _FarmerPanel(
                order: order,
              );
              final items =
                  _ItemsPanel(
                order: order,
              );

              if (constraints.maxWidth <
                  760) {
                return Column(
                  children: [
                    farmer,
                    const SizedBox(
                      height: 14,
                    ),
                    items,
                  ],
                );
              }

              return Row(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 4,
                    child: farmer,
                  ),
                  const SizedBox(
                    width: 14,
                  ),
                  Expanded(
                    flex: 6,
                    child: items,
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 18),
          _FulfillmentPanel(
            order: order,
          ),
          const SizedBox(height: 18),
          Container(
            padding:
                const EdgeInsets.symmetric(
              horizontal: 17,
              vertical: 15,
            ),
            decoration: BoxDecoration(
              color:
                  const Color(0xFFF5F8F1),
              borderRadius:
                  BorderRadius.circular(
                15,
              ),
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
                    style:
                        const TextStyle(
                      color: _ordersText,
                      fontSize: 14,
                      fontWeight:
                          FontWeight.w700,
                    ),
                  ),
                ),
                Text(
                  '${_money(order['totalPrice'])} ₪',
                  style:
                      const TextStyle(
                    color:
                        _ordersPrimary,
                    fontSize: 19,
                    fontWeight:
                        FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
          if (canConfirm ||
              canComplete ||
              canCancel) ...[
            const SizedBox(height: 16),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                if (canConfirm)
                  ElevatedButton.icon(
                    onPressed: isUpdating
                        ? null
                        : onConfirm,
                    style:
                        _primaryButtonStyle(),
                    icon: const Icon(
                      Icons
                          .check_circle_outline_rounded,
                    ),
                    label: Text(
                      _t(
                        context,
                        'Confirm Order',
                        'تأكيد الطلب',
                      ),
                    ),
                  ),
                if (canComplete)
                  ElevatedButton.icon(
                    onPressed: isUpdating
                        ? null
                        : onComplete,
                    style:
                        _primaryButtonStyle(),
                    icon: const Icon(
                      Icons
                          .task_alt_rounded,
                    ),
                    label: Text(
                      _t(
                        context,
                        'Complete Order',
                        'إكمال الطلب',
                      ),
                    ),
                  ),
                if (canCancel)
                  OutlinedButton.icon(
                    onPressed: isUpdating
                        ? null
                        : onCancel,
                    style: OutlinedButton
                        .styleFrom(
                      foregroundColor:
                          const Color(
                        0xFFC64D4D,
                      ),
                      side:
                          const BorderSide(
                        color: Color(
                          0xFFE3B7B7,
                        ),
                      ),
                      padding:
                          const EdgeInsets
                              .symmetric(
                        horizontal: 18,
                        vertical: 15,
                      ),
                      shape:
                          RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius
                                .circular(
                          13,
                        ),
                      ),
                    ),
                    icon: const Icon(
                      Icons
                          .cancel_outlined,
                    ),
                    label: Text(
                      _t(
                        context,
                        'Cancel',
                        'إلغاء',
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _FarmerPanel extends StatelessWidget {
  final Map<String, dynamic> order;

  const _FarmerPanel({
    required this.order,
  });

  @override
  Widget build(BuildContext context) {
    final farmer = order['farmer']
            is Map
        ? Map<String, dynamic>.from(
            order['farmer'] as Map,
          )
        : <String, dynamic>{};

    final name = farmer['fullName']
            ?.toString()
            .trim() ??
        '';
    final email = farmer['email']
            ?.toString()
            .trim() ??
        '';
    final phone = farmer['phone']
            ?.toString()
            .trim() ??
        '';
    final address = farmer['address']
            ?.toString()
            .trim() ??
        '';

    return _InnerPanel(
      title:
          _t(context, 'Farmer', 'المزارع'),
      icon:
          Icons.person_outline_rounded,
      child: Column(
        children: [
          _InfoRow(
            icon: Icons.person_outline,
            text: name.isEmpty
                ? _t(
                    context,
                    'Farmer',
                    'المزارع',
                  )
                : name,
          ),
          if (email.isNotEmpty)
            _InfoRow(
              icon:
                  Icons.email_outlined,
              text: email,
            ),
          if (phone.isNotEmpty)
            _InfoRow(
              icon:
                  Icons.phone_outlined,
              text: phone,
            ),
          if (address.isNotEmpty)
            _InfoRow(
              icon: Icons
                  .location_on_outlined,
              text: address,
            ),
        ],
      ),
    );
  }
}

class _ItemsPanel extends StatelessWidget {
  final Map<String, dynamic> order;

  const _ItemsPanel({
    required this.order,
  });

  @override
  Widget build(BuildContext context) {
    final rawItems =
        order['orderItems'];

    final items = rawItems is List
        ? rawItems
            .whereType<Map>()
            .map(
              (item) =>
                  Map<String, dynamic>.from(
                item,
              ),
            )
            .toList()
        : <Map<String, dynamic>>[];

    return _InnerPanel(
      title: _t(
        context,
        'Order Items',
        'عناصر الطلب',
      ),
      icon:
          Icons.shopping_basket_outlined,
      child: items.isEmpty
          ? Text(
              _t(
                context,
                'No items found',
                'لم يتم العثور على عناصر',
              ),
              style: const TextStyle(
                color: _ordersMuted,
              ),
            )
          : Column(
              children: items
                  .map(
                    (item) =>
                        _OrderItemRow(
                      item: item,
                    ),
                  )
                  .toList(),
            ),
    );
  }
}

class _OrderItemRow
    extends StatelessWidget {
  final Map<String, dynamic> item;

  const _OrderItemRow({
    required this.item,
  });

  @override
  Widget build(BuildContext context) {
    final product =
        item['product'] is Map
            ? Map<String, dynamic>.from(
                item['product'] as Map,
              )
            : <String, dynamic>{};

    final isArabic =
        Localizations.localeOf(context)
                .languageCode ==
            'ar';

    final name = _localizedValue(
      product,
      generic: 'name',
      english: 'nameEn',
      arabic: 'nameAr',
      isArabic: isArabic,
      fallback: _t(
        context,
        'Product',
        'منتج',
      ),
    );

    final unit =
        product['unit']?.toString() ??
            '';
    final quantity =
        _intValue(item['quantity']);
    final price =
        _doubleValue(item['price']);

    final rawImageUrl =
        product['imageUrl']
            ?.toString()
            .trim();
    final imageUrl = rawImageUrl ==
                null ||
            rawImageUrl.isEmpty
        ? null
        : AppConstants.getImageUrl(
            rawImageUrl,
          );

    return Padding(
      padding:
          const EdgeInsets.only(
        bottom: 10,
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius:
                BorderRadius.circular(
              11,
            ),
            child: Container(
              width: 44,
              height: 44,
              color: _ordersLight,
              child: imageUrl == null
                  ? const Icon(
                      Icons
                          .shopping_basket_outlined,
                      color:
                          _ordersPrimary,
                      size: 20,
                    )
                  : Image.network(
                      imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (
                        context,
                        error,
                        stackTrace,
                      ) {
                        return const Icon(
                          Icons
                              .shopping_basket_outlined,
                          color:
                              _ordersPrimary,
                          size: 20,
                        );
                      },
                    ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style:
                      const TextStyle(
                    color: _ordersText,
                    fontWeight:
                        FontWeight.w700,
                  ),
                ),
                const SizedBox(
                  height: 2,
                ),
                Text(
                  "${_t(context, 'Quantity', 'الكمية')}: $quantity${unit.trim().isEmpty ? '' : ' $unit'}",
                  style:
                      const TextStyle(
                    color:
                        _ordersMuted,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '${(price * quantity).toStringAsFixed(2)} ₪',
            style: const TextStyle(
              color: _ordersText,
              fontWeight:
                  FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _FulfillmentPanel
    extends StatelessWidget {
  final Map<String, dynamic> order;

  const _FulfillmentPanel({
    required this.order,
  });

  @override
  Widget build(BuildContext context) {
    final deliveryMethod =
        order['deliveryMethod']
                ?.toString()
                .trim()
                .toUpperCase() ??
            'PICKUP';

    final isDelivery =
        deliveryMethod == 'DELIVERY';

    final method = isDelivery
        ? _t(
            context,
            'Delivery',
            'توصيل',
          )
        : _t(
            context,
            'Pickup from Supplier',
            'استلام من المورد',
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
        ? order['deliveryAddress']
            ?.toString()
            .trim()
        : order['pickupLocation']
            ?.toString()
            .trim();

    return _InnerPanel(
      title: _t(
        context,
        'Fulfillment & Payment',
        'تفاصيل الاستلام والدفع',
      ),
      icon: isDelivery
          ? Icons
              .local_shipping_outlined
          : Icons.storefront_outlined,
      child: Column(
        children: [
          _LabeledInfoRow(
            icon: isDelivery
                ? Icons
                    .local_shipping_outlined
                : Icons
                    .shopping_bag_outlined,
            label: _t(
              context,
              'Delivery Method',
              'طريقة الاستلام',
            ),
            value: method,
          ),
          _LabeledInfoRow(
            icon:
                Icons.payments_outlined,
            label: _t(
              context,
              'Payment Method',
              'طريقة الدفع',
            ),
            value: payment,
          ),
          if (location != null &&
              location.isNotEmpty)
            _LabeledInfoRow(
              icon: Icons
                  .location_on_outlined,
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
        color:
            const Color(0xFFFCFDFB),
        borderRadius:
            BorderRadius.circular(16),
        border: Border.all(
          color:
              const Color(0xFFE2E9DE),
        ),
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                color: _ordersPrimary,
                size: 19,
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style:
                    const TextStyle(
                  color: _ordersText,
                  fontSize: 14,
                  fontWeight:
                      FontWeight.w800,
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
      padding:
          const EdgeInsets.only(
        bottom: 9,
      ),
      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: 17,
            color: _ordersMuted,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style:
                  const TextStyle(
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

class _LabeledInfoRow
    extends StatelessWidget {
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
        crossAxisAlignment:
            CrossAxisAlignment.start,
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
                style:
                    const TextStyle(
                  color: _ordersMuted,
                  fontSize: 13,
                  height: 1.4,
                ),
                children: [
                  TextSpan(
                    text: '$label: ',
                    style:
                        const TextStyle(
                      color:
                          _ordersText,
                      fontWeight:
                          FontWeight
                              .w700,
                    ),
                  ),
                  TextSpan(
                    text: value,
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

class _StatusBadge
    extends StatelessWidget {
  final String status;

  const _StatusBadge({
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    final color =
        _statusColor(status);

    return Container(
      padding:
          const EdgeInsets.symmetric(
        horizontal: 11,
        vertical: 7,
      ),
      decoration: BoxDecoration(
        color: color.withValues(
          alpha: 0.11,
        ),
        borderRadius:
            BorderRadius.circular(20),
      ),
      child: Text(
        _localizedStatus(
          context,
          status,
        ),
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight:
              FontWeight.w800,
        ),
      ),
    );
  }

  Color _statusColor(String value) {
    switch (value.toUpperCase()) {
      case 'CONFIRMED':
        return const Color(
          0xFF4F76A7,
        );
      case 'COMPLETED':
        return const Color(
          0xFF3F8A50,
        );
      case 'CANCELLED':
        return const Color(
          0xFFC65353,
        );
      case 'PENDING':
      default:
        return const Color(
          0xFFC8792C,
        );
    }
  }
}

class _EmptyOrdersView
    extends StatelessWidget {
  final String status;

  const _EmptyOrdersView({
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding:
            const EdgeInsets.all(30),
        child: Column(
          mainAxisSize:
              MainAxisSize.min,
          children: [
            Container(
              width: 76,
              height: 76,
              decoration:
                  const BoxDecoration(
                color: _ordersLight,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons
                    .receipt_long_outlined,
                size: 34,
                color: _ordersPrimary,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              status == 'ALL'
                  ? _t(
                      context,
                      'No supply orders yet',
                      'لا توجد طلبات مستلزمات بعد',
                    )
                  : _t(
                      context,
                      'No ${status.toLowerCase()} supply orders',
                      'لا توجد طلبات مستلزمات بحالة ${_localizedStatus(context, status)}',
                    ),
              textAlign:
                  TextAlign.center,
              style:
                  const TextStyle(
                color: _ordersText,
                fontSize: 19,
                fontWeight:
                    FontWeight.w800,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              _t(
                context,
                'Orders from farmers will appear here.',
                'ستظهر طلبات المزارعين هنا.',
              ),
              textAlign:
                  TextAlign.center,
              style:
                  const TextStyle(
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
        constraints:
            const BoxConstraints(
          maxWidth: 430,
        ),
        margin:
            const EdgeInsets.all(24),
        padding:
            const EdgeInsets.all(25),
        decoration:
            _ordersCardDecoration(
          radius: 22,
        ),
        child: Column(
          mainAxisSize:
              MainAxisSize.min,
          children: [
            const Icon(
              Icons.error_outline_rounded,
              size: 55,
              color:
                  Color(0xFFC65353),
            ),
            const SizedBox(height: 13),
            Text(
              message,
              textAlign:
                  TextAlign.center,
              style:
                  const TextStyle(
                color: _ordersText,
              ),
            ),
            const SizedBox(height: 17),
            ElevatedButton.icon(
              onPressed: onRetry,
              style:
                  _primaryButtonStyle(),
              icon: const Icon(
                Icons.refresh_rounded,
              ),
              label: Text(
                _t(
                  context,
                  'Try Again',
                  'حاول مرة أخرى',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OrdersBackdrop
    extends StatelessWidget {
  const _OrdersBackdrop();

  @override
  Widget build(BuildContext context) {
    return const DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin:
              Alignment.topCenter,
          end:
              Alignment.bottomCenter,
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
    padding:
        const EdgeInsets.symmetric(
      horizontal: 18,
      vertical: 15,
    ),
    shape: RoundedRectangleBorder(
      borderRadius:
          BorderRadius.circular(13),
    ),
  );
}

BoxDecoration _ordersCardDecoration({
  required double radius,
}) {
  return BoxDecoration(
    color: Colors.white,
    borderRadius:
        BorderRadius.circular(radius),
    border: Border.all(
      color:
          const Color(0xFFDCE5D8),
    ),
    boxShadow: [
      BoxShadow(
        color: _ordersDark.withValues(
          alpha: 0.05,
        ),
        blurRadius: 20,
        offset:
            const Offset(0, 7),
      ),
    ],
  );
}

String _shortOrderId(String id) {
  if (id.isEmpty) {
    return '--------';
  }

  return id.length <= 8
      ? id
      : id.substring(0, 8);
}

DateTime? _parseDate(dynamic value) {
  if (value == null) {
    return null;
  }

  return DateTime.tryParse(
    value.toString(),
  );
}

String _formatDate(DateTime date) {
  final d = date.toLocal();

  String two(int value) =>
      value.toString().padLeft(
            2,
            '0',
          );

  return '${two(d.day)}/${two(d.month)}/${d.year}  ${two(d.hour)}:${two(d.minute)}';
}

double _doubleValue(dynamic value) {
  if (value is num) {
    return value.toDouble();
  }

  return double.tryParse(
        value?.toString() ?? '',
      ) ??
      0;
}

int _intValue(dynamic value) {
  if (value is num) {
    return value.toInt();
  }

  return int.tryParse(
        value?.toString() ?? '',
      ) ??
      0;
}

String _money(dynamic value) {
  return _doubleValue(value)
      .toStringAsFixed(2);
}

String _localizedValue(
  Map<String, dynamic> data, {
  required String generic,
  required String english,
  required String arabic,
  required bool isArabic,
  required String fallback,
}) {
  final preferred = data[
          isArabic ? arabic : english]
      ?.toString()
      .trim();

  if (preferred != null &&
      preferred.isNotEmpty) {
    return preferred;
  }

  final genericValue =
      data[generic]
          ?.toString()
          .trim();

  if (genericValue != null &&
      genericValue.isNotEmpty) {
    return genericValue;
  }

  final alternate = data[
          isArabic ? english : arabic]
      ?.toString()
      .trim();

  if (alternate != null &&
      alternate.isNotEmpty) {
    return alternate;
  }

  return fallback;
}
