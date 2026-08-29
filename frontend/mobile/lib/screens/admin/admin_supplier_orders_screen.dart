import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_constants.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../providers/locale_provider.dart';
import '../../providers/supplier_order_provider.dart';

class AdminSupplierOrdersScreen extends StatefulWidget {
  const AdminSupplierOrdersScreen({
    super.key,
  });

  @override
  State<AdminSupplierOrdersScreen> createState() =>
      _AdminSupplierOrdersScreenState();
}

class _AdminSupplierOrdersScreenState
    extends State<AdminSupplierOrdersScreen> {
  String _selectedStatus = 'ALL';

  bool get _isArabic =>
      Localizations.localeOf(context).languageCode ==
      'ar';

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
    await Provider.of<SupplierOrderProvider>(
      context,
      listen: false,
    ).loadAdminSupplierOrders();
  }

  List<Map<String, dynamic>> _filteredOrders(
    List orders,
  ) {
    final mappedOrders = orders
        .whereType<Map>()
        .map(
          (order) =>
              Map<String, dynamic>.from(order),
        )
        .toList();

    if (_selectedStatus == 'ALL') {
      return mappedOrders;
    }

    return mappedOrders.where(
      (order) {
        return order['status']
                ?.toString()
                .trim()
                .toUpperCase() ==
            _selectedStatus;
      },
    ).toList();
  }

  int _statusCount(
    List orders,
    String status,
  ) {
    return orders
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
  Widget build(BuildContext context) {
    final provider =
        Provider.of<SupplierOrderProvider>(
      context,
    );

    final allOrders =
        provider.adminSupplierOrders;

    final orders =
        _filteredOrders(allOrders);

    return Scaffold(
      backgroundColor:
          const Color(0xFFF8FAF4),
      body: Stack(
        children: [
          const Positioned.fill(
            child:
                _AdminSupplyOrdersBackdrop(),
          ),
          Column(
            children: [
              _AdminSupplyOrdersTopBar(
                isArabic: _isArabic,
                isLoading:
                    provider.isLoading,
                onBack: () =>
                    Navigator.pop(context),
                onRefresh: _loadOrders,
                onChangeLanguage:
                    _changeLanguage,
              ),
              Expanded(
                child:
                    provider.isLoading &&
                            allOrders.isEmpty
                        ? const Center(
                            child:
                                CircularProgressIndicator(
                              color:
                                  _adminSupplyPrimary,
                            ),
                          )
                        : provider.errorMessage !=
                                    null &&
                                allOrders.isEmpty
                            ? _AdminSupplyOrdersErrorView(
                                message:
                                    provider
                                        .errorMessage!,
                                isArabic:
                                    _isArabic,
                                onRetry:
                                    _loadOrders,
                              )
                            : RefreshIndicator(
                                color:
                                    _adminSupplyPrimary,
                                onRefresh:
                                    _loadOrders,
                                child:
                                    CustomScrollView(
                                  physics:
                                      const AlwaysScrollableScrollPhysics(),
                                  slivers: [
                                    SliverToBoxAdapter(
                                      child:
                                          Center(
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
                                                _AdminSupplyOrdersHero(
                                                  isArabic:
                                                      _isArabic,
                                                  total:
                                                      allOrders
                                                          .length,
                                                  pending:
                                                      _statusCount(
                                                    allOrders,
                                                    'PENDING',
                                                  ),
                                                  confirmed:
                                                      _statusCount(
                                                    allOrders,
                                                    'CONFIRMED',
                                                  ),
                                                  completed:
                                                      _statusCount(
                                                    allOrders,
                                                    'COMPLETED',
                                                  ),
                                                ),
                                                const SizedBox(
                                                  height:
                                                      18,
                                                ),
                                                _AdminSupplyStatusFilter(
                                                  selectedStatus:
                                                      _selectedStatus,
                                                  isArabic:
                                                      _isArabic,
                                                  onChanged:
                                                      (
                                                    status,
                                                  ) {
                                                    setState(
                                                      () {
                                                        _selectedStatus =
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
                                    if (orders.isEmpty)
                                      SliverFillRemaining(
                                        hasScrollBody:
                                            false,
                                        child:
                                            _AdminSupplyOrdersEmptyView(
                                          isArabic:
                                              _isArabic,
                                          status:
                                              _selectedStatus,
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
    (
  _,
  _,
) =>
        const SizedBox(
  height: 16,
),
                                          itemBuilder:
                                              (
                                            context,
                                            index,
                                          ) {
                                            final order =
                                                orders[
                                                    index];

                                            return Center(
                                              child:
                                                  ConstrainedBox(
                                                constraints:
                                                    const BoxConstraints(
                                                  maxWidth:
                                                      1320,
                                                ),
                                                child:
                                                    _AdminSupplierOrderCard(
                                                  order:
                                                      order,
                                                  isArabic:
                                                      _isArabic,
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
      ),
    );
  }
}

const _adminSupplyDark =
    Color(0xFF173F24);

const _adminSupplyPrimary =
    Color(0xFF2F743F);

const _adminSupplyLight =
    Color(0xFFEAF3DF);

const _adminSupplyText =
    Color(0xFF1D2C21);

const _adminSupplyMuted =
    Color(0xFF6C786E);

class _AdminSupplyOrdersTopBar
    extends StatelessWidget {
  final bool isArabic;
  final bool isLoading;
  final VoidCallback onBack;
  final Future<void> Function()
      onRefresh;
  final ValueChanged<String>
      onChangeLanguage;

  const _AdminSupplyOrdersTopBar({
    required this.isArabic,
    required this.isLoading,
    required this.onBack,
    required this.onRefresh,
    required this.onChangeLanguage,
  });

  @override
  Widget build(BuildContext context) {
    final l10n =
        AppLocalizations.of(context)!;

    return Container(
      decoration:
          const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xFF123A22),
            Color(0xFF205A34),
            Color(0xFF2E6F40),
          ],
        ),
      ),
      padding:
          const EdgeInsets.fromLTRB(
        18,
        12,
        18,
        14,
      ),
      child: SafeArea(
        bottom: false,
        child: Row(
          children: [
            _AdminSupplyHeaderButton(
              icon:
                  Icons.arrow_back_rounded,
              tooltip:
                  isArabic
                      ? 'رجوع'
                      : 'Back',
              onTap: onBack,
            ),
            const SizedBox(width: 12),
            Container(
              width: 44,
              height: 44,
              decoration:
                  BoxDecoration(
                color:
                    const Color(
                  0xFFDDECB8,
                ),
                borderRadius:
                    BorderRadius.circular(
                  13,
                ),
              ),
              child:
                  const Icon(
                Icons
                    .local_shipping_outlined,
                color:
                    _adminSupplyDark,
              ),
            ),
            const SizedBox(width: 10),
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
                  Text(
                    isArabic
                        ? 'طلبات المستلزمات'
                        : 'Supply Orders',
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
                  l10n.changeLanguage,
              position:
                  PopupMenuPosition.under,
              offset:
                  const Offset(
                0,
                8,
              ),
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
                  onChangeLanguage,
              itemBuilder:
                  (context) {
                return [
                  PopupMenuItem<String>(
                    value: 'en',
                    child: Row(
                      children: [
                        Icon(
                          Icons
                              .check_rounded,
                          size: 20,
                          color:
                              !isArabic
                                  ? _adminSupplyPrimary
                                  : Colors
                                      .transparent,
                        ),
                        const SizedBox(
                          width:
                              10,
                        ),
                        Text(
                          l10n
                              .english,
                        ),
                      ],
                    ),
                  ),
                  PopupMenuItem<String>(
                    value: 'ar',
                    child: Row(
                      children: [
                        Icon(
                          Icons
                              .check_rounded,
                          size: 20,
                          color:
                              isArabic
                                  ? _adminSupplyPrimary
                                  : Colors
                                      .transparent,
                        ),
                        const SizedBox(
                          width:
                              10,
                        ),
                        Text(
                          l10n
                              .arabic,
                        ),
                      ],
                    ),
                  ),
                ];
              },
              child:
                  Container(
                width: 44,
                height: 44,
                decoration:
                    BoxDecoration(
                  color:
                      Colors.white
                          .withValues(
                    alpha:
                        0.10,
                  ),
                  borderRadius:
                      BorderRadius
                          .circular(
                    14,
                  ),
                ),
                alignment:
                    Alignment.center,
                child:
                    const Icon(
                  Icons
                      .language_rounded,
                  color:
                      Colors.white,
                  size: 21,
                ),
              ),
            ),
            const SizedBox(width: 10),
            _AdminSupplyHeaderButton(
              icon:
                  Icons.refresh_rounded,
              tooltip:
                  isArabic
                      ? 'تحديث'
                      : 'Refresh',
              onTap:
                  isLoading
                      ? null
                      : () {
                          onRefresh();
                        },
            ),
          ],
        ),
      ),
    );
  }
}

class _AdminSupplyHeaderButton
    extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback? onTap;

  const _AdminSupplyHeaderButton({
    required this.icon,
    required this.tooltip,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
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

class _AdminSupplyOrdersHero
    extends StatelessWidget {
  final bool isArabic;
  final int total;
  final int pending;
  final int confirmed;
  final int completed;

  const _AdminSupplyOrdersHero({
    required this.isArabic,
    required this.total,
    required this.pending,
    required this.confirmed,
    required this.completed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding:
          const EdgeInsets.all(
        24,
      ),
      decoration:
          _adminSupplyCardDecoration(
        25,
      ),
      child: LayoutBuilder(
        builder:
            (
          context,
          constraints,
        ) {
          final heading = Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration:
                    BoxDecoration(
                  color:
                      _adminSupplyLight,
                  borderRadius:
                      BorderRadius.circular(
                    18,
                  ),
                ),
                child:
                    const Icon(
                  Icons
                      .receipt_long_outlined,
                  color:
                      _adminSupplyPrimary,
                  size: 30,
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
                      isArabic
                          ? 'إدارة طلبات المستلزمات'
                          : 'Supply Order Management',
                      style:
                          const TextStyle(
                        color:
                            _adminSupplyText,
                        fontSize:
                            24,
                        fontWeight:
                            FontWeight
                                .w800,
                      ),
                    ),
                    const SizedBox(
                      height: 4,
                    ),
                    Text(
                      isArabic
                          ? 'راجع طلبات المستلزمات بين المزارعين والموردين وتابع حالتها وتفاصيل الاستلام.'
                          : 'Review supply orders between farmers and suppliers, including status, products and fulfillment details.',
                      style:
                          const TextStyle(
                        color:
                            _adminSupplyMuted,
                        fontSize:
                            13,
                        height:
                            1.4,
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
              _AdminSupplyMiniStat(
                label:
                    isArabic
                        ? 'الإجمالي'
                        : 'Total',
                value: total,
              ),
              _AdminSupplyMiniStat(
                label:
                    isArabic
                        ? 'قيد الانتظار'
                        : 'Pending',
                value: pending,
              ),
              _AdminSupplyMiniStat(
                label:
                    isArabic
                        ? 'مؤكد'
                        : 'Confirmed',
                value:
                    confirmed,
              ),
              _AdminSupplyMiniStat(
                label:
                    isArabic
                        ? 'مكتمل'
                        : 'Completed',
                value:
                    completed,
              ),
            ],
          );

          if (constraints.maxWidth <
              760) {
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
              Expanded(
                child: heading,
              ),
              const SizedBox(
                width: 20,
              ),
              stats,
            ],
          );
        },
      ),
    );
  }
}

class _AdminSupplyMiniStat
    extends StatelessWidget {
  final String label;
  final int value;

  const _AdminSupplyMiniStat({
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
      decoration:
          BoxDecoration(
        color:
            const Color(
          0xFFF1F6E9,
        ),
        borderRadius:
            BorderRadius.circular(
          14,
        ),
      ),
      child: Text(
        '$label  $value',
        style:
            const TextStyle(
          color:
              _adminSupplyPrimary,
          fontSize: 12,
          fontWeight:
              FontWeight.w700,
        ),
      ),
    );
  }
}

class _AdminSupplyStatusFilter
    extends StatelessWidget {
  final String selectedStatus;
  final bool isArabic;
  final ValueChanged<String>
      onChanged;

  const _AdminSupplyStatusFilter({
    required this.selectedStatus,
    required this.isArabic,
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
      child:
          ListView.separated(
        scrollDirection:
            Axis.horizontal,
        itemCount:
            statuses.length,
        separatorBuilder:
    (_, _) =>
        const SizedBox(
  width: 9,
),
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
              _filterLabel(
                status,
              ),
            ),
            selected:
                selected,
            onSelected:
                (_) =>
                    onChanged(
              status,
            ),
            showCheckmark:
                false,
            backgroundColor:
                Colors.white,
            selectedColor:
                _adminSupplyPrimary,
            side:
                BorderSide(
              color:
                  selected
                      ? _adminSupplyPrimary
                      : const Color(
                          0xFFDCE5D8,
                        ),
            ),
            labelStyle:
                TextStyle(
              color:
                  selected
                      ? Colors.white
                      : _adminSupplyMuted,
              fontWeight:
                  FontWeight.w700,
              fontSize:
                  12,
            ),
            padding:
                const EdgeInsets
                    .symmetric(
              horizontal: 10,
            ),
          );
        },
      ),
    );
  }

  String _filterLabel(
    String status,
  ) {
    switch (status) {
      case 'ALL':
        return isArabic
            ? 'كل الطلبات'
            : 'All Orders';

      case 'PENDING':
        return isArabic
            ? 'قيد الانتظار'
            : 'Pending';

      case 'CONFIRMED':
        return isArabic
            ? 'مؤكد'
            : 'Confirmed';

      case 'COMPLETED':
        return isArabic
            ? 'مكتمل'
            : 'Completed';

      case 'CANCELLED':
        return isArabic
            ? 'ملغي'
            : 'Cancelled';

      default:
        return status;
    }
  }
}

class _AdminSupplierOrderCard
    extends StatelessWidget {
  final Map<String, dynamic> order;
  final bool isArabic;

  const _AdminSupplierOrderCard({
    required this.order,
    required this.isArabic,
  });

  @override
  Widget build(BuildContext context) {
    final status =
        order['status']
                ?.toString()
                .trim()
                .toUpperCase() ??
            'PENDING';

    final id =
        order['id']
                ?.toString()
                .trim() ??
            '';

    final createdAt =
        _parseDate(
      order['createdAt'],
    );

    return Container(
      padding:
          const EdgeInsets.all(
        22,
      ),
      decoration:
          _adminSupplyCardDecoration(
        22,
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
                decoration:
                    BoxDecoration(
                  color:
                      _adminSupplyLight,
                  borderRadius:
                      BorderRadius
                          .circular(
                    14,
                  ),
                ),
                child:
                    const Icon(
                  Icons
                      .receipt_long_outlined,
                  color:
                      _adminSupplyPrimary,
                ),
              ),
              const SizedBox(
                width: 13,
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment
                          .start,
                  children: [
                    Text(
                      '${isArabic ? 'طلب مستلزمات' : 'Supply Order'} #${_shortOrderId(id)}',
                      style:
                          const TextStyle(
                        color:
                            _adminSupplyText,
                        fontSize:
                            17,
                        fontWeight:
                            FontWeight
                                .w800,
                      ),
                    ),
                    if (createdAt !=
                        null) ...[
                      const SizedBox(
                        height:
                            4,
                      ),
                      Text(
                        _formatDate(
                          createdAt,
                        ),
                        style:
                            const TextStyle(
                          color:
                              _adminSupplyMuted,
                          fontSize:
                              12,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              _AdminSupplyStatusBadge(
                status:
                    status,
                isArabic:
                    isArabic,
              ),
            ],
          ),
          const SizedBox(
            height: 20,
          ),
          LayoutBuilder(
            builder:
                (
              context,
              constraints,
            ) {
              final farmer =
                  _AdminPartyPanel(
                title:
                    isArabic
                        ? 'المزارع'
                        : 'Farmer',
                icon:
                    Icons
                        .agriculture_outlined,
                data:
                    _mapValue(
                  order['farmer'],
                ),
                isArabic:
                    isArabic,
              );

              final supplier =
                  _AdminPartyPanel(
                title:
                    isArabic
                        ? 'المورد'
                        : 'Supplier',
                icon:
                    Icons
                        .storefront_outlined,
                data:
                    _mapValue(
                  order['supplier'],
                ),
                isArabic:
                    isArabic,
              );

              if (constraints.maxWidth <
                  760) {
                return Column(
                  children: [
                    farmer,
                    const SizedBox(
                      height: 14,
                    ),
                    supplier,
                  ],
                );
              }

              return Row(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child:
                        farmer,
                  ),
                  const SizedBox(
                    width: 14,
                  ),
                  Expanded(
                    child:
                        supplier,
                  ),
                ],
              );
            },
          ),
          const SizedBox(
            height: 14,
          ),
          _AdminSupplyItemsPanel(
            order:
                order,
            isArabic:
                isArabic,
          ),
          const SizedBox(
            height: 14,
          ),
          _AdminSupplyFulfillmentPanel(
            order:
                order,
            isArabic:
                isArabic,
          ),
          const SizedBox(
            height: 18,
          ),
          Container(
            padding:
                const EdgeInsets
                    .symmetric(
              horizontal: 17,
              vertical: 15,
            ),
            decoration:
                BoxDecoration(
              color:
                  const Color(
                0xFFF5F8F1,
              ),
              borderRadius:
                  BorderRadius
                      .circular(
                15,
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    isArabic
                        ? 'إجمالي الطلب'
                        : 'Order Total',
                    style:
                        const TextStyle(
                      color:
                          _adminSupplyText,
                      fontSize:
                          14,
                      fontWeight:
                          FontWeight
                              .w700,
                    ),
                  ),
                ),
                Text(
                  '${_money(order['totalPrice'])} ₪',
                  style:
                      const TextStyle(
                    color:
                        _adminSupplyPrimary,
                    fontSize:
                        19,
                    fontWeight:
                        FontWeight
                            .w800,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(
            height: 12,
          ),
          Container(
            width:
                double.infinity,
            padding:
                const EdgeInsets
                    .all(
              12,
            ),
            decoration:
                BoxDecoration(
              color:
                  const Color(
                0xFFF8FAF4,
              ),
              borderRadius:
                  BorderRadius
                      .circular(
                13,
              ),
              border:
                  Border.all(
                color:
                    const Color(
                  0xFFE0E7DC,
                ),
              ),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons
                      .visibility_outlined,
                  color:
                      _adminSupplyMuted,
                  size: 18,
                ),
                const SizedBox(
                  width: 8,
                ),
                Expanded(
                  child: Text(
                    isArabic
                        ? 'عرض إداري فقط — يتم تحديث حالة الطلب بواسطة المزارع أو المورد حسب صلاحيات النظام.'
                        : 'Admin view only — order status is updated by the farmer or supplier according to system permissions.',
                    style:
                        const TextStyle(
                      color:
                          _adminSupplyMuted,
                      fontSize:
                          12,
                      height:
                          1.4,
                    ),
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

class _AdminPartyPanel
    extends StatelessWidget {
  final String title;
  final IconData icon;
  final Map<String, dynamic> data;
  final bool isArabic;

  const _AdminPartyPanel({
    required this.title,
    required this.icon,
    required this.data,
    required this.isArabic,
  });

  @override
  Widget build(BuildContext context) {
    final name =
        data['fullName']
                ?.toString()
                .trim() ??
            '';

    final email =
        data['email']
                ?.toString()
                .trim() ??
            '';

    final phone =
        data['phone']
                ?.toString()
                .trim() ??
            '';

    final address =
        data['address']
                ?.toString()
                .trim() ??
            '';

    return _AdminInnerPanel(
      title: title,
      icon: icon,
      child: Column(
        children: [
          _AdminInfoRow(
            icon:
                Icons.person_outline,
            text:
                name.isEmpty
                    ? title
                    : name,
          ),
          if (email.isNotEmpty)
            _AdminInfoRow(
              icon:
                  Icons.email_outlined,
              text: email,
            ),
          if (phone.isNotEmpty)
            _AdminInfoRow(
              icon:
                  Icons.phone_outlined,
              text: phone,
            ),
          if (address.isNotEmpty)
            _AdminInfoRow(
              icon:
                  Icons
                      .location_on_outlined,
              text: address,
            ),
        ],
      ),
    );
  }
}

class _AdminSupplyItemsPanel
    extends StatelessWidget {
  final Map<String, dynamic> order;
  final bool isArabic;

  const _AdminSupplyItemsPanel({
    required this.order,
    required this.isArabic,
  });

  @override
  Widget build(BuildContext context) {
    final rawItems =
        order['orderItems'];

    final items =
        rawItems is List
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

    return _AdminInnerPanel(
      title:
          isArabic
              ? 'عناصر الطلب'
              : 'Order Items',
      icon:
          Icons
              .shopping_basket_outlined,
      child:
          items.isEmpty
              ? Text(
                  isArabic
                      ? 'لم يتم العثور على عناصر'
                      : 'No items found',
                  style:
                      const TextStyle(
                    color:
                        _adminSupplyMuted,
                  ),
                )
              : Column(
                  children:
                      items.map(
                    (item) {
                      return _AdminSupplyOrderItemRow(
                        item:
                            item,
                        isArabic:
                            isArabic,
                      );
                    },
                  ).toList(),
                ),
    );
  }
}

class _AdminSupplyOrderItemRow
    extends StatelessWidget {
  final Map<String, dynamic> item;
  final bool isArabic;

  const _AdminSupplyOrderItemRow({
    required this.item,
    required this.isArabic,
  });

  @override
  Widget build(BuildContext context) {
    final product =
        _mapValue(
      item['product'],
    );

    final name =
        _localizedValue(
      product,
      generic: 'name',
      english: 'nameEn',
      arabic: 'nameAr',
      isArabic:
          isArabic,
      fallback:
          isArabic
              ? 'منتج'
              : 'Product',
    );

    final category =
        _mapValue(
      product['category'],
    );

    final categoryName =
        _localizedValue(
      category,
      generic: 'name',
      english: 'nameEn',
      arabic: 'nameAr',
      isArabic:
          isArabic,
      fallback: '',
    );

    final unit =
        product['unit']
                ?.toString()
                .trim() ??
            '';

    final quantity =
        _intValue(
      item['quantity'],
    );

    final price =
        _doubleValue(
      item['price'],
    );

    final rawImageUrl =
        product['imageUrl']
            ?.toString()
            .trim();

    final imageUrl =
        rawImageUrl == null ||
                rawImageUrl.isEmpty
            ? null
            : AppConstants
                .getImageUrl(
                rawImageUrl,
              );

    return Padding(
      padding:
          const EdgeInsets.only(
        bottom: 12,
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius:
                BorderRadius.circular(
              11,
            ),
            child: Container(
              width: 48,
              height: 48,
              color:
                  _adminSupplyLight,
              child:
                  imageUrl == null
                      ? const Icon(
                          Icons
                              .shopping_basket_outlined,
                          color:
                              _adminSupplyPrimary,
                          size:
                              21,
                        )
                      : Image.network(
                          imageUrl,
                          fit:
                              BoxFit.cover,
                          errorBuilder:
                              (
                            context,
                            error,
                            stackTrace,
                          ) {
                            return const Icon(
                              Icons
                                  .shopping_basket_outlined,
                              color:
                                  _adminSupplyPrimary,
                              size:
                                  21,
                            );
                          },
                        ),
            ),
          ),
          const SizedBox(
            width: 11,
          ),
          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style:
                      const TextStyle(
                    color:
                        _adminSupplyText,
                    fontWeight:
                        FontWeight
                            .w700,
                  ),
                ),
                if (categoryName
                    .isNotEmpty) ...[
                  const SizedBox(
                    height:
                        2,
                  ),
                  Text(
                    categoryName,
                    style:
                        const TextStyle(
                      color:
                          _adminSupplyMuted,
                      fontSize:
                          11,
                    ),
                  ),
                ],
                const SizedBox(
                  height:
                      2,
                ),
                Text(
                  '${isArabic ? 'الكمية' : 'Quantity'}: $quantity${unit.isEmpty ? '' : ' $unit'}',
                  style:
                      const TextStyle(
                    color:
                        _adminSupplyMuted,
                    fontSize:
                        12,
                  ),
                ),
                Text(
                  '${isArabic ? 'سعر الوحدة' : 'Unit Price'}: ${price.toStringAsFixed(2)} ₪',
                  style:
                      const TextStyle(
                    color:
                        _adminSupplyMuted,
                    fontSize:
                        12,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(
            width: 12,
          ),
          Text(
            '${(price * quantity).toStringAsFixed(2)} ₪',
            style:
                const TextStyle(
              color:
                  _adminSupplyText,
              fontWeight:
                  FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _AdminSupplyFulfillmentPanel
    extends StatelessWidget {
  final Map<String, dynamic> order;
  final bool isArabic;

  const _AdminSupplyFulfillmentPanel({
    required this.order,
    required this.isArabic,
  });

  @override
  Widget build(BuildContext context) {
    final deliveryMethod =
        order['deliveryMethod']
                ?.toString()
                .trim()
                .toUpperCase() ??
            'PICKUP';

    final paymentMethod =
        order['paymentMethod']
                ?.toString()
                .trim()
                .toUpperCase() ??
            'CASH';

    final isDelivery =
        deliveryMethod ==
            'DELIVERY';

    final method =
        isDelivery
            ? (isArabic
                ? 'توصيل'
                : 'Delivery')
            : (isArabic
                ? 'استلام من المورد'
                : 'Pickup from Supplier');

    String payment;

    if (paymentMethod == 'CASH') {
      payment =
          isDelivery
              ? (isArabic
                  ? 'الدفع نقدًا عند التوصيل'
                  : 'Cash on Delivery')
              : (isArabic
                  ? 'الدفع نقدًا عند الاستلام'
                  : 'Cash on Pickup');
    } else {
      payment =
          paymentMethod;
    }

    final location =
        isDelivery
            ? order['deliveryAddress']
                ?.toString()
                .trim()
            : order['pickupLocation']
                ?.toString()
                .trim();

    return _AdminInnerPanel(
      title:
          isArabic
              ? 'تفاصيل الاستلام والدفع'
              : 'Fulfillment & Payment',
      icon:
          isDelivery
              ? Icons
                  .local_shipping_outlined
              : Icons
                  .storefront_outlined,
      child: Column(
        children: [
          _AdminLabeledInfoRow(
            icon:
                isDelivery
                    ? Icons
                        .local_shipping_outlined
                    : Icons
                        .shopping_bag_outlined,
            label:
                isArabic
                    ? 'طريقة الاستلام'
                    : 'Delivery Method',
            value:
                method,
          ),
          _AdminLabeledInfoRow(
            icon:
                Icons.payments_outlined,
            label:
                isArabic
                    ? 'طريقة الدفع'
                    : 'Payment Method',
            value:
                payment,
          ),
          if (location != null &&
              location.isNotEmpty)
            _AdminLabeledInfoRow(
              icon:
                  Icons
                      .location_on_outlined,
              label:
                  isDelivery
                      ? (isArabic
                          ? 'عنوان التوصيل'
                          : 'Delivery Address')
                      : (isArabic
                          ? 'موقع الاستلام'
                          : 'Pickup Location'),
              value:
                  location,
              isLast:
                  true,
            ),
        ],
      ),
    );
  }
}

class _AdminInnerPanel
    extends StatelessWidget {
  final String title;
  final IconData icon;
  final Widget child;

  const _AdminInnerPanel({
    required this.title,
    required this.icon,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width:
          double.infinity,
      padding:
          const EdgeInsets.all(
        16,
      ),
      decoration:
          BoxDecoration(
        color:
            const Color(
          0xFFFCFDFB,
        ),
        borderRadius:
            BorderRadius.circular(
          16,
        ),
        border:
            Border.all(
          color:
              const Color(
            0xFFE2E9DE,
          ),
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
                color:
                    _adminSupplyPrimary,
                size: 19,
              ),
              const SizedBox(
                width: 8,
              ),
              Text(
                title,
                style:
                    const TextStyle(
                  color:
                      _adminSupplyText,
                  fontSize:
                      14,
                  fontWeight:
                      FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(
            height: 13,
          ),
          child,
        ],
      ),
    );
  }
}

class _AdminInfoRow
    extends StatelessWidget {
  final IconData icon;
  final String text;

  const _AdminInfoRow({
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
            color:
                _adminSupplyMuted,
          ),
          const SizedBox(
            width: 8,
          ),
          Expanded(
            child: Text(
              text,
              style:
                  const TextStyle(
                color:
                    _adminSupplyText,
                fontSize:
                    13,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AdminLabeledInfoRow
    extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final bool isLast;

  const _AdminLabeledInfoRow({
    required this.icon,
    required this.label,
    required this.value,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:
          EdgeInsets.only(
        bottom:
            isLast ? 0 : 9,
      ),
      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: 17,
            color:
                _adminSupplyMuted,
          ),
          const SizedBox(
            width: 8,
          ),
          Expanded(
            child: RichText(
              text:
                  TextSpan(
                style:
                    const TextStyle(
                  color:
                      _adminSupplyMuted,
                  fontSize:
                      13,
                  height:
                      1.4,
                ),
                children: [
                  TextSpan(
                    text:
                        '$label: ',
                    style:
                        const TextStyle(
                      color:
                          _adminSupplyText,
                      fontWeight:
                          FontWeight
                              .w700,
                    ),
                  ),
                  TextSpan(
                    text:
                        value,
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

class _AdminSupplyStatusBadge
    extends StatelessWidget {
  final String status;
  final bool isArabic;

  const _AdminSupplyStatusBadge({
    required this.status,
    required this.isArabic,
  });

  @override
  Widget build(BuildContext context) {
    final color =
        _statusColor(
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
        color:
            color.withValues(
          alpha: 0.11,
        ),
        borderRadius:
            BorderRadius.circular(
          20,
        ),
      ),
      child: Text(
        _localizedStatus(
          status,
          isArabic,
        ),
        style:
            TextStyle(
          color: color,
          fontSize: 11,
          fontWeight:
              FontWeight.w800,
        ),
      ),
    );
  }
}

class _AdminSupplyOrdersEmptyView
    extends StatelessWidget {
  final bool isArabic;
  final String status;

  const _AdminSupplyOrdersEmptyView({
    required this.isArabic,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    final message =
        status == 'ALL'
            ? (isArabic
                ? 'لا توجد طلبات مستلزمات بعد'
                : 'No supply orders yet')
            : (isArabic
                ? 'لا توجد طلبات مستلزمات بحالة ${_localizedStatus(status, true)}'
                : 'No ${status.toLowerCase()} supply orders');

    return Center(
      child: Padding(
        padding:
            const EdgeInsets.all(
          30,
        ),
        child: Column(
          mainAxisSize:
              MainAxisSize.min,
          children: [
            Container(
              width: 76,
              height: 76,
              decoration:
                  const BoxDecoration(
                color:
                    _adminSupplyLight,
                shape:
                    BoxShape.circle,
              ),
              child:
                  const Icon(
                Icons
                    .receipt_long_outlined,
                size: 34,
                color:
                    _adminSupplyPrimary,
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
                    _adminSupplyText,
                fontSize:
                    19,
                fontWeight:
                    FontWeight
                        .w800,
              ),
            ),
            const SizedBox(
              height: 6,
            ),
            Text(
              isArabic
                  ? 'ستظهر طلبات المزارعين من الموردين هنا.'
                  : 'Farmer orders from suppliers will appear here.',
              textAlign:
                  TextAlign.center,
              style:
                  const TextStyle(
                color:
                    _adminSupplyMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AdminSupplyOrdersErrorView
    extends StatelessWidget {
  final String message;
  final bool isArabic;
  final Future<void> Function()
      onRetry;

  const _AdminSupplyOrdersErrorView({
    required this.message,
    required this.isArabic,
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
            const EdgeInsets.all(
          24,
        ),
        padding:
            const EdgeInsets.all(
          25,
        ),
        decoration:
            _adminSupplyCardDecoration(
          22,
        ),
        child: Column(
          mainAxisSize:
              MainAxisSize.min,
          children: [
            const Icon(
              Icons
                  .error_outline_rounded,
              size: 55,
              color:
                  Color(
                0xFFC65353,
              ),
            ),
            const SizedBox(
              height: 13,
            ),
            Text(
              message,
              textAlign:
                  TextAlign.center,
              style:
                  const TextStyle(
                color:
                    _adminSupplyText,
              ),
            ),
            const SizedBox(
              height: 17,
            ),
            ElevatedButton.icon(
              onPressed:
                  onRetry,
              style:
                  ElevatedButton
                      .styleFrom(
                backgroundColor:
                    _adminSupplyPrimary,
                foregroundColor:
                    Colors.white,
                elevation:
                    0,
                padding:
                    const EdgeInsets
                        .symmetric(
                  horizontal:
                      18,
                  vertical:
                      15,
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
              icon:
                  const Icon(
                Icons
                    .refresh_rounded,
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
    );
  }
}

class _AdminSupplyOrdersBackdrop
    extends StatelessWidget {
  const _AdminSupplyOrdersBackdrop();

  @override
  Widget build(BuildContext context) {
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
                    Alignment
                        .topCenter,
                end:
                    Alignment
                        .bottomCenter,
                colors: [
                  Color(
                    0xFFF8FAF4,
                  ),
                  Color(
                    0xFFFFFCF5,
                  ),
                  Color(
                    0xFFF3F8EC,
                  ),
                ],
              ),
            ),
          ),
          PositionedDirectional(
            end: -180,
            top: 190,
            child:
                _AdminSupplyGlow(
              size: 450,
              color:
                  const Color(
                0xFFCFE6B4,
              ),
            ),
          ),
          PositionedDirectional(
            start: -190,
            bottom: -220,
            child:
                _AdminSupplyGlow(
              size: 520,
              color:
                  const Color(
                0xFFE7DFAF,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AdminSupplyGlow
    extends StatelessWidget {
  final double size;
  final Color color;

  const _AdminSupplyGlow({
    required this.size,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration:
          BoxDecoration(
        shape:
            BoxShape.circle,
        gradient:
            RadialGradient(
          colors: [
            color.withValues(
              alpha:
                  0.25,
            ),
            color.withValues(
              alpha:
                  0,
            ),
          ],
        ),
      ),
    );
  }
}

BoxDecoration
    _adminSupplyCardDecoration(
  double radius,
) {
  return BoxDecoration(
    color: Colors.white,
    borderRadius:
        BorderRadius.circular(
      radius,
    ),
    border: Border.all(
      color:
          const Color(
        0xFFDCE5D8,
      ),
    ),
    boxShadow: [
      BoxShadow(
        color:
            _adminSupplyDark
                .withValues(
          alpha:
              0.05,
        ),
        blurRadius:
            20,
        offset:
            const Offset(
          0,
          7,
        ),
      ),
    ],
  );
}

Map<String, dynamic> _mapValue(
  dynamic value,
) {
  if (value is Map) {
    return Map<String, dynamic>.from(
      value,
    );
  }

  return <String, dynamic>{};
}

String _shortOrderId(
  String id,
) {
  if (id.isEmpty) {
    return '--------';
  }

  return id.length <= 8
      ? id
      : id.substring(
          0,
          8,
        );
}

DateTime? _parseDate(
  dynamic value,
) {
  if (value == null) {
    return null;
  }

  return DateTime.tryParse(
    value.toString(),
  );
}

String _formatDate(
  DateTime date,
) {
  final d =
      date.toLocal();

  String two(
    int value,
  ) =>
      value
          .toString()
          .padLeft(
            2,
            '0',
          );

  return '${two(d.day)}/${two(d.month)}/${d.year}  ${two(d.hour)}:${two(d.minute)}';
}

double _doubleValue(
  dynamic value,
) {
  if (value is num) {
    return value.toDouble();
  }

  return double.tryParse(
        value?.toString() ?? '',
      ) ??
      0;
}

int _intValue(
  dynamic value,
) {
  if (value is num) {
    return value.toInt();
  }

  return int.tryParse(
        value?.toString() ?? '',
      ) ??
      0;
}

String _money(
  dynamic value,
) {
  return _doubleValue(
    value,
  ).toStringAsFixed(
    2,
  );
}

String _localizedValue(
  Map<String, dynamic> data, {
  required String generic,
  required String english,
  required String arabic,
  required bool isArabic,
  required String fallback,
}) {
  final preferred =
      data[
              isArabic
                  ? arabic
                  : english]
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

  final alternate =
      data[
              isArabic
                  ? english
                  : arabic]
          ?.toString()
          .trim();

  if (alternate != null &&
      alternate.isNotEmpty) {
    return alternate;
  }

  return fallback;
}

String _localizedStatus(
  String status,
  bool isArabic,
) {
  final normalized =
      status
          .trim()
          .toUpperCase();

  if (!isArabic) {
    switch (normalized) {
      case 'PENDING':
        return 'Pending';

      case 'CONFIRMED':
        return 'Confirmed';

      case 'COMPLETED':
        return 'Completed';

      case 'CANCELLED':
        return 'Cancelled';

      default:
        return normalized;
    }
  }

  switch (normalized) {
    case 'PENDING':
      return 'قيد الانتظار';

    case 'CONFIRMED':
      return 'مؤكد';

    case 'COMPLETED':
      return 'مكتمل';

    case 'CANCELLED':
      return 'ملغي';

    default:
      return status;
  }
}

Color _statusColor(
  String status,
) {
  switch (
      status
          .trim()
          .toUpperCase()) {
    case 'PENDING':
      return const Color(
        0xFFC8792C,
      );

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

    default:
      return const Color(
        0xFF6C786E,
      );
  }
}
