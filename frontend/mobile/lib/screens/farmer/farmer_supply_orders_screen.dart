import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_constants.dart';
import '../../providers/locale_provider.dart';
import '../../providers/supplier_order_provider.dart';

const Color _ordersDarkGreen = Color(0xFF173F24);
const Color _ordersPrimaryGreen = Color(0xFF2F6B3D);
const Color _ordersLightGreen = Color(0xFFDDECB8);
const Color _ordersBackground = Color(0xFFF8FAF4);
const Color _ordersTextPrimary = Color(0xFF1D2C21);
const Color _ordersTextSecondary = Color(0xFF68756B);

class FarmerSupplyOrdersScreen extends StatefulWidget {
  const FarmerSupplyOrdersScreen({
    super.key,
  });

  @override
  State<FarmerSupplyOrdersScreen> createState() =>
      _FarmerSupplyOrdersScreenState();
}

class _FarmerSupplyOrdersScreenState
    extends State<FarmerSupplyOrdersScreen> {
  String _selectedStatus = 'ALL';

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
    ).loadFarmerSupplierOrders();
  }

  bool get _isArabic =>
      Localizations.localeOf(context)
          .languageCode ==
      'ar';

  String _t(
    String en,
    String ar,
  ) {
    return _isArabic ? ar : en;
  }

  List<Map<String, dynamic>> _filteredOrders(
    List rawOrders,
  ) {
    final orders = rawOrders
        .whereType<Map>()
        .map(
          (order) =>
              Map<String, dynamic>.from(
            order,
          ),
        )
        .toList();

    if (_selectedStatus == 'ALL') {
      return orders;
    }

    return orders
        .where(
          (order) =>
              order['status']
                  ?.toString()
                  .toUpperCase() ==
              _selectedStatus,
        )
        .toList();
  }

  int _statusCount(
    List rawOrders,
    String status,
  ) {
    return rawOrders.where(
      (order) =>
          order is Map &&
          order['status']
                  ?.toString()
                  .toUpperCase() ==
              status,
    ).length;
  }

  Future<void> _cancelOrder(
    Map<String, dynamic> order,
  ) async {
    final orderId =
        order['id']?.toString() ?? '';

    if (orderId.isEmpty) {
      return;
    }

    final confirmed =
        await showDialog<bool>(
      context: context,
      builder: (
        dialogContext,
      ) {
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
                color:
                    Color(
                  0xFFB44F4F,
                ),
              ),
              const SizedBox(
                width: 10,
              ),
              Expanded(
                child: Text(
                  _t(
                    'Cancel Supply Order',
                    'إلغاء طلب المستلزمات',
                  ),
                  style:
                      const TextStyle(
                    fontWeight:
                        FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          content: Text(
            _t(
              'Are you sure you want to cancel this pending order?',
              'هل أنت متأكد من إلغاء هذا الطلب المعلّق؟',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(
                  dialogContext,
                ).pop(
                  false,
                );
              },
              child: Text(
                _t(
                  'Keep Order',
                  'إبقاء الطلب',
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(
                  dialogContext,
                ).pop(
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
                _t(
                  'Cancel Order',
                  'إلغاء الطلب',
                ),
              ),
            ),
          ],
        );
      },
    );

    if (confirmed != true ||
        !mounted) {
      return;
    }

    final provider =
        Provider.of<SupplierOrderProvider>(
      context,
      listen: false,
    );

    final success =
        await provider.cancelOrder(
      orderId,
    );

    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            success
                ? _t(
                    'Supply order cancelled successfully.',
                    'تم إلغاء طلب المستلزمات بنجاح.',
                  )
                : provider.errorMessage ??
                    _t(
                      'Failed to cancel supply order.',
                      'فشل إلغاء طلب المستلزمات.',
                    ),
          ),
          backgroundColor:
              success
                  ? _ordersPrimaryGreen
                  : Colors.red,
        ),
      );
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
          Consumer<SupplierOrderProvider>(
            builder: (
              context,
              provider,
              child,
            ) {
              final filteredOrders =
                  _filteredOrders(
                provider
                    .farmerSupplierOrders,
              );

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
                        context,
                      ),
                    ),
                    SliverToBoxAdapter(
                      child:
                          _buildHero(
                        provider
                            .farmerSupplierOrders,
                      ),
                    ),
                    SliverToBoxAdapter(
                      child:
                          _buildFilters(
                        provider
                            .farmerSupplierOrders,
                      ),
                    ),
                    if (provider
                            .isLoading &&
                        provider
                            .farmerSupplierOrders
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
                    else if (provider
                            .errorMessage !=
                        null &&
                        provider
                            .farmerSupplierOrders
                            .isEmpty)
                      SliverFillRemaining(
                        hasScrollBody:
                            false,
                        child:
                            _buildErrorState(
                          provider
                              .errorMessage!,
                        ),
                      )
                    else if (filteredOrders
                        .isEmpty)
                      SliverFillRemaining(
                        hasScrollBody:
                            false,
                        child:
                            _buildEmptyState(),
                      )
                    else
                      SliverPadding(
                        padding:
                            const EdgeInsets.fromLTRB(
                          18,
                          0,
                          18,
                          44,
                        ),
                        sliver:
                            SliverList.separated(
                          itemCount:
                              filteredOrders
                                  .length,
                          separatorBuilder:
                              (
                            context,
                            index,
                          ) =>
                                  const SizedBox(
                            height: 16,
                          ),
                          itemBuilder:
                              (
                            context,
                            index,
                          ) {
                            return _buildOrderCard(
                              provider:
                                  provider,
                              order:
                                  filteredOrders[
                                      index],
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

  Widget _buildHeader(
    BuildContext context,
  ) {
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
                _ordersDarkGreen.withValues(
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
                  _t(
                'Back',
                'رجوع',
              ),
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
                Icons.local_shipping_outlined,
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
                    _t(
                      'My Supply Orders',
                      'طلبات المستلزمات الخاصة بي',
                    ),
                    maxLines: 1,
                    overflow:
                        TextOverflow.ellipsis,
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
                  _t(
                'Change Language',
                'تغيير اللغة',
              ),
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
                              !_isArabic
                                  ? _ordersPrimaryGreen
                                  : Colors.transparent,
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                        Text(
                          _t(
                            'English',
                            'الإنجليزية',
                          ),
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
                              _isArabic
                                  ? _ordersPrimaryGreen
                                  : Colors.transparent,
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                        Text(
                          _t(
                            'Arabic',
                            'العربية',
                          ),
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
            _HeaderButton(
              icon:
                  Icons.refresh_rounded,
              tooltip:
                  _t(
                'Refresh',
                'تحديث',
              ),
              onTap:
                  _loadOrders,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHero(
    List orders,
  ) {
    return Padding(
      padding:
          const EdgeInsets.fromLTRB(
        18,
        24,
        18,
        18,
      ),
      child: Container(
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
                0xFFF9FBF5,
              ),
            ],
          ),
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
                  _ordersDarkGreen.withValues(
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
              CrossAxisAlignment.start,
          children: [
            Row(
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
                        BorderRadius.circular(
                      16,
                    ),
                  ),
                  child:
                      const Icon(
                    Icons.inventory_2_outlined,
                    color:
                        _ordersPrimaryGreen,
                    size: 26,
                  ),
                ),
                const SizedBox(
                  width: 14,
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Text(
                        _t(
                          'Supply Orders',
                          'طلبات المستلزمات',
                        ),
                        style:
                            const TextStyle(
                          color:
                              _ordersTextPrimary,
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
                          'Track agricultural supplies purchased from suppliers.',
                          'تابع المستلزمات الزراعية التي اشتريتها من الموردين.',
                        ),
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
            ),
            const SizedBox(
              height: 20,
            ),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                _StatChip(
                  icon:
                      Icons.receipt_long_outlined,
                  label:
                      _t(
                    'Total',
                    'الإجمالي',
                  ),
                  value:
                      orders.length,
                ),
                _StatChip(
                  icon:
                      Icons.schedule_rounded,
                  label:
                      _t(
                    'Pending',
                    'قيد الانتظار',
                  ),
                  value:
                      _statusCount(
                    orders,
                    'PENDING',
                  ),
                ),
                _StatChip(
                  icon:
                      Icons.check_circle_outline_rounded,
                  label:
                      _t(
                    'Confirmed',
                    'مؤكد',
                  ),
                  value:
                      _statusCount(
                    orders,
                    'CONFIRMED',
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilters(
    List orders,
  ) {
    const statuses = [
      'ALL',
      'PENDING',
      'CONFIRMED',
      'COMPLETED',
      'CANCELLED',
    ];

    return Padding(
      padding:
          const EdgeInsets.fromLTRB(
        18,
        0,
        18,
        18,
      ),
      child: SingleChildScrollView(
        scrollDirection:
            Axis.horizontal,
        child: Row(
          children:
              statuses.map(
            (status) {
              final selected =
                  _selectedStatus ==
                      status;

              final count =
                  status == 'ALL'
                      ? orders.length
                      : _statusCount(
                          orders,
                          status,
                        );

              return Padding(
                padding:
                    const EdgeInsetsDirectional.only(
                  end: 9,
                ),
                child: ChoiceChip(
                  selected:
                      selected,
                  onSelected:
                      (_) {
                    setState(
                      () {
                        _selectedStatus =
                            status;
                      },
                    );
                  },
                  backgroundColor:
                      Colors.white,
                  selectedColor:
                      const Color(
                    0xFFEAF3DF,
                  ),
                  side:
                      BorderSide(
                    color:
                        selected
                            ? _ordersPrimaryGreen
                            : const Color(
                                0xFFDDE6D8,
                              ),
                  ),
                  shape:
                      RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(
                      18,
                    ),
                  ),
                  label: Text(
                    '${_statusLabel(status)} ($count)',
                    style:
                        TextStyle(
                      color:
                          selected
                              ? _ordersPrimaryGreen
                              : _ordersTextSecondary,
                      fontWeight:
                          selected
                              ? FontWeight.w800
                              : FontWeight.w600,
                    ),
                  ),
                ),
              );
            },
          ).toList(),
        ),
      ),
    );
  }

  String _statusLabel(
    String status,
  ) {
    switch (status) {
      case 'PENDING':
        return _t(
          'Pending',
          'قيد الانتظار',
        );
      case 'CONFIRMED':
        return _t(
          'Confirmed',
          'مؤكد',
        );
      case 'COMPLETED':
        return _t(
          'Completed',
          'مكتمل',
        );
      case 'CANCELLED':
        return _t(
          'Cancelled',
          'ملغي',
        );
      default:
        return _t(
          'All',
          'الكل',
        );
    }
  }

  Widget _buildOrderCard({
    required SupplierOrderProvider
        provider,
    required Map<String, dynamic>
        order,
  }) {
    final orderId =
        order['id']?.toString() ?? '';

    final status =
        order['status']
                ?.toString()
                .toUpperCase() ??
            'PENDING';

    final deliveryMethod =
        order['deliveryMethod']
                ?.toString()
                .toUpperCase() ??
            'PICKUP';

    final paymentMethod =
        order['paymentMethod']
                ?.toString()
                .toUpperCase() ??
            'CASH';

    final deliveryAddress =
        order['deliveryAddress']
                ?.toString()
                .trim() ??
            '';

    final pickupLocation =
        order['pickupLocation']
                ?.toString()
                .trim() ??
            '';

    final totalPrice =
        double.tryParse(
          order['totalPrice']
                  ?.toString() ??
              '0',
        ) ??
        0.0;

    final createdAt =
        order['createdAt']
            ?.toString();

    final supplier =
        order['supplier'];

    final supplierName =
        supplier is Map
            ? supplier['fullName']
                      ?.toString()
                      .trim() ??
                  ''
            : '';

    final supplierPhone =
        supplier is Map
            ? supplier['phone']
                      ?.toString()
                      .trim() ??
                  ''
            : '';

    final supplierAddress =
        supplier is Map
            ? supplier['address']
                      ?.toString()
                      .trim() ??
                  ''
            : '';

    final rawItems =
        order['orderItems'];

    final items =
        rawItems is List
            ? rawItems
            : <dynamic>[];

    return Container(
      padding:
          const EdgeInsets.all(
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
                _ordersDarkGreen.withValues(
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
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment:
                CrossAxisAlignment.start,
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
                      BorderRadius.circular(
                    14,
                  ),
                ),
                child:
                    const Icon(
                  Icons.shopping_bag_outlined,
                  color:
                      _ordersPrimaryGreen,
                  size: 23,
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
                      _t(
                        'Supply Order',
                        'طلب مستلزمات',
                      ),
                      style:
                          const TextStyle(
                        color:
                            _ordersTextPrimary,
                        fontSize: 17,
                        fontWeight:
                            FontWeight.w800,
                      ),
                    ),
                    const SizedBox(
                      height: 4,
                    ),
                    Text(
                      orderId.isNotEmpty
                          ? '#${_shortId(orderId)}'
                          : '',
                      style:
                          const TextStyle(
                        color:
                            _ordersTextSecondary,
                        fontSize: 12,
                      ),
                    ),
                    if (createdAt !=
                        null) ...[
                      const SizedBox(
                        height: 3,
                      ),
                      Text(
                        _formatDate(
                          createdAt,
                        ),
                        style:
                            const TextStyle(
                          color:
                              _ordersTextSecondary,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              _StatusBadge(
                status:
                    status,
                label:
                    _statusLabel(
                  status,
                ),
              ),
            ],
          ),
          if (supplierName
                  .isNotEmpty ||
              supplierPhone
                  .isNotEmpty ||
              supplierAddress
                  .isNotEmpty) ...[
            const SizedBox(
              height: 18,
            ),
            _buildSupplierSection(
              supplierName:
                  supplierName,
              supplierPhone:
                  supplierPhone,
              supplierAddress:
                  supplierAddress,
            ),
          ],
          if (items
              .isNotEmpty) ...[
            const SizedBox(
              height: 18,
            ),
            Text(
              _t(
                'Items',
                'المنتجات',
              ),
              style:
                  const TextStyle(
                color:
                    _ordersTextPrimary,
                fontSize: 16,
                fontWeight:
                    FontWeight.w800,
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            ...List.generate(
              items.length,
              (
                index,
              ) {
                final rawItem =
                    items[index];

                if (rawItem
                    is! Map) {
                  return const SizedBox
                      .shrink();
                }

                return Padding(
                  padding:
                      EdgeInsets.only(
                    bottom:
                        index ==
                                items.length -
                                    1
                            ? 0
                            : 10,
                  ),
                  child:
                      _buildOrderItem(
                    Map<String, dynamic>.from(
                      rawItem,
                    ),
                  ),
                );
              },
            ),
          ],
          const SizedBox(
            height: 18,
          ),
          _buildFulfillmentSection(
            deliveryMethod:
                deliveryMethod,
            paymentMethod:
                paymentMethod,
            deliveryAddress:
                deliveryAddress,
            pickupLocation:
                pickupLocation,
            supplierAddress:
                supplierAddress,
          ),
          const SizedBox(
            height: 18,
          ),
          Container(
            padding:
                const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 13,
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
            ),
            child: Row(
              children: [
                Text(
                  _t(
                    'Total',
                    'الإجمالي',
                  ),
                  style:
                      const TextStyle(
                    color:
                        _ordersTextSecondary,
                    fontWeight:
                        FontWeight.w600,
                  ),
                ),
                const Spacer(),
                Text(
                  '${totalPrice.toStringAsFixed(2)} ₪',
                  style:
                      const TextStyle(
                    color:
                        _ordersPrimaryGreen,
                    fontSize: 20,
                    fontWeight:
                        FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
          if (status ==
              'PENDING') ...[
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
                    provider
                            .isUpdatingStatus
                        ? null
                        : () {
                            _cancelOrder(
                              order,
                            );
                          },
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
                      0xFFE3B8B8,
                    ),
                  ),
                  shape:
                      RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(
                      14,
                    ),
                  ),
                ),
                icon:
                    provider
                            .isUpdatingStatus
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child:
                                CircularProgressIndicator(
                              strokeWidth:
                                  2,
                              color:
                                  Color(
                                0xFFB44F4F,
                              ),
                            ),
                          )
                        : const Icon(
                            Icons.cancel_outlined,
                          ),
                label:
                    Text(
                  _t(
                    'Cancel Order',
                    'إلغاء الطلب',
                  ),
                  style:
                      const TextStyle(
                    fontWeight:
                        FontWeight.w700,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSupplierSection({
    required String supplierName,
    required String supplierPhone,
    required String supplierAddress,
  }) {
    return Container(
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
            BorderRadius.circular(
          16,
        ),
        border:
            Border.all(
          color:
              const Color(
            0xFFE1E8DD,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.storefront_outlined,
                color:
                    _ordersPrimaryGreen,
                size: 20,
              ),
              const SizedBox(
                width: 8,
              ),
              Text(
                _t(
                  'Supplier',
                  'المورد',
                ),
                style:
                    const TextStyle(
                  color:
                      _ordersTextPrimary,
                  fontWeight:
                      FontWeight.w800,
                ),
              ),
            ],
          ),
          if (supplierName
              .isNotEmpty) ...[
            const SizedBox(
              height: 10,
            ),
            _InfoRow(
              icon:
                  Icons.person_outline_rounded,
              value:
                  supplierName,
            ),
          ],
          if (supplierPhone
              .isNotEmpty) ...[
            const SizedBox(
              height: 8,
            ),
            _InfoRow(
              icon:
                  Icons.phone_outlined,
              value:
                  supplierPhone,
            ),
          ],
          if (supplierAddress
              .isNotEmpty) ...[
            const SizedBox(
              height: 8,
            ),
            _InfoRow(
              icon:
                  Icons.location_on_outlined,
              value:
                  supplierAddress,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildOrderItem(
    Map<String, dynamic> item,
  ) {
    final product =
        item['product'];

    final productMap =
        product is Map
            ? Map<String, dynamic>.from(
                product,
              )
            : <String, dynamic>{};

    final productName =
        _localizedValue(
      productMap,
      'name',
      _t(
        'Product',
        'منتج',
      ),
    );

    final unit =
        productMap['unit']
                ?.toString() ??
            item['unit']
                ?.toString() ??
            '';

    final imageUrl =
        productMap['imageUrl']
            ?.toString();

    final quantity =
        int.tryParse(
          item['quantity']
                  ?.toString() ??
              '0',
        ) ??
        0;

    final unitPrice =
        double.tryParse(
          item['price']
                  ?.toString() ??
              item['unitPrice']
                  ?.toString() ??
              productMap['price']
                  ?.toString() ??
              '0',
        ) ??
        0.0;

    final lineTotal =
    double.tryParse(
      item['totalPrice']
              ?.toString() ??
          item['subtotal']
              ?.toString() ??
          '',
    ) ??
    (unitPrice * quantity);

    return Container(
      padding:
          const EdgeInsets.all(
        12,
      ),
      decoration:
          BoxDecoration(
        color:
            Colors.white,
        borderRadius:
            BorderRadius.circular(
          16,
        ),
        border:
            Border.all(
          color:
              const Color(
            0xFFE1E8DD,
          ),
        ),
      ),
      child: Row(
        children: [
          _ProductImage(
            imageUrl:
                imageUrl,
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
                  productName,
                  maxLines: 2,
                  overflow:
                      TextOverflow.ellipsis,
                  style:
                      const TextStyle(
                    color:
                        _ordersTextPrimary,
                    fontSize: 14,
                    fontWeight:
                        FontWeight.w800,
                  ),
                ),
                const SizedBox(
                  height: 5,
                ),
                Text(
                  '${_t('Quantity', 'الكمية')}: $quantity'
                  '${unit.isEmpty ? '' : ' $unit'}',
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
            '${lineTotal.toStringAsFixed(2)} ₪',
            style:
                const TextStyle(
              color:
                  _ordersPrimaryGreen,
              fontSize: 14,
              fontWeight:
                  FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFulfillmentSection({
    required String deliveryMethod,
    required String paymentMethod,
    required String deliveryAddress,
    required String pickupLocation,
    required String supplierAddress,
  }) {
    final isDelivery =
        deliveryMethod ==
            'DELIVERY';

    final location =
        isDelivery
            ? deliveryAddress
            : pickupLocation
                    .isNotEmpty
                ? pickupLocation
                : supplierAddress;

    return Container(
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
            BorderRadius.circular(
          16,
        ),
        border:
            Border.all(
          color:
              const Color(
            0xFFE1E8DD,
          ),
        ),
      ),
      child: Column(
        children: [
          _InfoLine(
            icon:
                isDelivery
                    ? Icons.local_shipping_outlined
                    : Icons.storefront_outlined,
            label:
                _t(
              'Delivery Method',
              'طريقة الاستلام',
            ),
            value:
                isDelivery
                    ? _t(
                        'Delivery',
                        'توصيل',
                      )
                    : _t(
                        'Pickup from Supplier',
                        'استلام من المورد',
                      ),
          ),
          if (location
              .isNotEmpty) ...[
            const SizedBox(
              height: 12,
            ),
            _InfoLine(
              icon:
                  Icons.location_on_outlined,
              label:
                  isDelivery
                      ? _t(
                          'Delivery Address',
                          'عنوان التوصيل',
                        )
                      : _t(
                          'Pickup Location',
                          'موقع الاستلام',
                        ),
              value:
                  location,
            ),
          ],
          const SizedBox(
            height: 12,
          ),
          _InfoLine(
            icon:
                Icons.payments_outlined,
            label:
                _t(
              'Payment',
              'الدفع',
            ),
            value:
                paymentMethod ==
                        'CASH'
                    ? isDelivery
                        ? _t(
                            'Cash on Delivery',
                            'نقدًا عند التوصيل',
                          )
                        : _t(
                            'Cash on Pickup',
                            'نقدًا عند الاستلام',
                          )
                    : paymentMethod,
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(
    String message,
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
            maxWidth: 500,
          ),
          padding:
              const EdgeInsets.all(
            28,
          ),
          decoration:
              BoxDecoration(
            color:
                Colors.white,
            borderRadius:
                BorderRadius.circular(
              24,
            ),
            border:
                Border.all(
              color:
                  const Color(
                0xFFE8CACA,
              ),
            ),
          ),
          child: Column(
            mainAxisSize:
                MainAxisSize.min,
            children: [
              const Icon(
                Icons.error_outline_rounded,
                size: 48,
                color:
                    Color(
                  0xFFB44F4F,
                ),
              ),
              const SizedBox(
                height: 12,
              ),
              Text(
                message,
                textAlign:
                    TextAlign.center,
                style:
                    const TextStyle(
                  color:
                      _ordersTextPrimary,
                  height: 1.45,
                ),
              ),
              const SizedBox(
                height: 16,
              ),
              ElevatedButton.icon(
                onPressed:
                    _loadOrders,
                style:
                    ElevatedButton.styleFrom(
                  backgroundColor:
                      _ordersPrimaryGreen,
                  foregroundColor:
                      Colors.white,
                  elevation: 0,
                ),
                icon:
                    const Icon(
                  Icons.refresh_rounded,
                ),
                label:
                    Text(
                  _t(
                    'Try Again',
                    'حاول مرة أخرى',
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    final filterIsAll =
        _selectedStatus ==
            'ALL';

    return Center(
      child: Padding(
        padding:
            const EdgeInsets.all(
          24,
        ),
        child: Container(
          constraints:
              const BoxConstraints(
            maxWidth: 500,
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
                    _ordersDarkGreen.withValues(
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
                  Icons.inventory_2_outlined,
                  size: 46,
                  color:
                      _ordersPrimaryGreen,
                ),
              ),
              const SizedBox(
                height: 18,
              ),
              Text(
                filterIsAll
                    ? _t(
                        'No Supply Orders Yet',
                        'لا توجد طلبات مستلزمات بعد',
                      )
                    : _t(
                        'No Orders in This Status',
                        'لا توجد طلبات بهذه الحالة',
                      ),
                textAlign:
                    TextAlign.center,
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
                filterIsAll
                    ? _t(
                        'Your agricultural supply orders will appear here after checkout.',
                        'ستظهر هنا طلبات المستلزمات الزراعية بعد إتمام الشراء.',
                      )
                    : _t(
                        'Choose another status to view your other supply orders.',
                        'اختر حالة أخرى لعرض بقية طلبات المستلزمات.',
                      ),
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
    );
  }

  String _localizedValue(
    Map<String, dynamic> source,
    String baseKey,
    String fallback,
  ) {
    final base =
        source[baseKey]
                ?.toString()
                .trim() ??
            '';

    final en =
        source['${baseKey}En']
                ?.toString()
                .trim() ??
            '';

    final ar =
        source['${baseKey}Ar']
                ?.toString()
                .trim() ??
            '';

    if (_isArabic) {
      if (ar.isNotEmpty) {
        return ar;
      }

      if (base.isNotEmpty) {
        return base;
      }

      if (en.isNotEmpty) {
        return en;
      }

      return fallback;
    }

    if (en.isNotEmpty) {
      return en;
    }

    if (base.isNotEmpty) {
      return base;
    }

    if (ar.isNotEmpty) {
      return ar;
    }

    return fallback;
  }

  String _shortId(
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

  String _formatDate(
    String value,
  ) {
    final date =
        DateTime.tryParse(
      value,
    );

    if (date == null) {
      return '';
    }

    final local =
        date.toLocal();

    final day =
        local.day
            .toString()
            .padLeft(
              2,
              '0',
            );

    final month =
        local.month
            .toString()
            .padLeft(
              2,
              '0',
            );

    final hour =
        local.hour
            .toString()
            .padLeft(
              2,
              '0',
            );

    final minute =
        local.minute
            .toString()
            .padLeft(
              2,
              '0',
            );

    return '$day/$month/${local.year} $hour:$minute';
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

class _StatChip
    extends StatelessWidget {
  final IconData icon;
  final String label;
  final int value;

  const _StatChip({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    return Container(
      padding:
          const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 9,
      ),
      decoration:
          BoxDecoration(
        color:
            const Color(
          0xFFF5F8F0,
        ),
        borderRadius:
            BorderRadius.circular(
          18,
        ),
        border:
            Border.all(
          color:
              const Color(
            0xFFE1E8DD,
          ),
        ),
      ),
      child: Row(
        mainAxisSize:
            MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 17,
            color:
                _ordersPrimaryGreen,
          ),
          const SizedBox(
            width: 6,
          ),
          Text(
            '$label: $value',
            style:
                const TextStyle(
              color:
                  _ordersTextPrimary,
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

class _StatusBadge
    extends StatelessWidget {
  final String status;
  final String label;

  const _StatusBadge({
    required this.status,
    required this.label,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    final colors =
        _statusColors(
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
            colors.$1,
        borderRadius:
            BorderRadius.circular(
          18,
        ),
      ),
      child: Text(
        label,
        style:
            TextStyle(
          color:
              colors.$2,
          fontSize: 11,
          fontWeight:
              FontWeight.w800,
        ),
      ),
    );
  }

  static (
    Color,
    Color
  ) _statusColors(
    String status,
  ) {
    switch (status) {
      case 'CONFIRMED':
        return (
          const Color(
            0xFFE5F0FF,
          ),
          const Color(
            0xFF35669A,
          ),
        );
      case 'COMPLETED':
        return (
          const Color(
            0xFFEAF3DF,
          ),
          _ordersPrimaryGreen,
        );
      case 'CANCELLED':
        return (
          const Color(
            0xFFFCE7E7,
          ),
          const Color(
            0xFFB44F4F,
          ),
        );
      default:
        return (
          const Color(
            0xFFFFF3D6,
          ),
          const Color(
            0xFF9A6A16,
          ),
        );
    }
  }
}

class _InfoRow
    extends StatelessWidget {
  final IconData icon;
  final String value;

  const _InfoRow({
    required this.icon,
    required this.value,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    return Row(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 18,
          color:
              _ordersPrimaryGreen,
        ),
        const SizedBox(
          width: 8,
        ),
        Expanded(
          child: Text(
            value,
            style:
                const TextStyle(
              color:
                  _ordersTextSecondary,
              fontSize: 13,
              height: 1.35,
            ),
          ),
        ),
      ],
    );
  }
}

class _InfoLine
    extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoLine({
    required this.icon,
    required this.label,
    required this.value,
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
          width: 38,
          height: 38,
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
          child: Icon(
            icon,
            color:
                _ordersPrimaryGreen,
            size: 19,
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
                label,
                style:
                    const TextStyle(
                  color:
                      _ordersTextSecondary,
                  fontSize: 11,
                  fontWeight:
                      FontWeight.w600,
                ),
              ),
              const SizedBox(
                height: 3,
              ),
              Text(
                value,
                style:
                    const TextStyle(
                  color:
                      _ordersTextPrimary,
                  fontSize: 13,
                  fontWeight:
                      FontWeight.w700,
                  height: 1.35,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ProductImage
    extends StatelessWidget {
  final String? imageUrl;

  const _ProductImage({
    required this.imageUrl,
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
        13,
      ),
      child: Container(
        width: 64,
        height: 64,
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
                      return const Icon(
                        Icons.image_not_supported_outlined,
                        color:
                            Color(
                          0xFF9AA59B,
                        ),
                      );
                    },
                  )
                : const Icon(
                    Icons.inventory_2_outlined,
                    color:
                        _ordersPrimaryGreen,
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
