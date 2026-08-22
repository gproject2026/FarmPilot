import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/order_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/order_provider.dart';
import '../../providers/locale_provider.dart';

class AdminOrdersScreen extends StatefulWidget {
  const AdminOrdersScreen({
    super.key,
  });

  @override
  State<AdminOrdersScreen> createState() =>
      _AdminOrdersScreenState();
}

class _AdminOrdersScreenState
    extends State<AdminOrdersScreen> {
  String _selectedStatus = 'ALL';

  bool get _isArabic =>
      Localizations.localeOf(context).languageCode == 'ar';

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

    final token =
        authProvider.token;

    if (token == null ||
        token.trim().isEmpty) {
      return;
    }

    await Provider.of<OrderProvider>(
      context,
      listen: false,
    ).fetchAdminOrders(
      token: token,
    );
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

  List<OrderModel> _filteredOrders(
    List<OrderModel> orders,
  ) {
    if (_selectedStatus == 'ALL') {
      return orders;
    }

    return orders.where(
      (order) {
        return order.status
                .trim()
                .toUpperCase() ==
            _selectedStatus;
      },
    ).toList();
  }

  @override
  Widget build(BuildContext context) {
    final orderProvider =
        Provider.of<OrderProvider>(
      context,
    );

    final orders =
        _filteredOrders(
      orderProvider.adminOrders,
    );

    return Scaffold(
      backgroundColor:
          const Color(
        0xFFF5F7F4,
      ),
      appBar: AppBar(
        toolbarHeight: 72,
        titleSpacing: 12,
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color(0xFF123A22),
                Color(0xFF205A34),
                Color(0xFF2E6F40),
              ],
            ),
          ),
        ),
        title: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: const Color(0xFFDDECB8),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.eco_rounded,
                color: Color(0xFF173F24),
              ),
            ),
            const SizedBox(width: 10),
            Column(
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
                Text(
                  _isArabic ? 'إدارة الطلبات' : 'Manage Orders',
                  style: const TextStyle(
                    color: Color(0xCCFFFFFF),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          PopupMenuButton<String>(
            tooltip:
                _isArabic ? 'تغيير اللغة' : 'Change Language',
            color: Colors.white,
            onSelected: _changeLanguage,
            icon: const Icon(
              Icons.language_rounded,
              color: Colors.white,
            ),
            itemBuilder: (context) {
              return [
                PopupMenuItem<String>(
                  value: 'en',
                  child: Row(
                    children: [
                      Icon(
                        Icons.check_rounded,
                        color: !_isArabic
                            ? const Color(0xFF2F743F)
                            : Colors.transparent,
                      ),
                      const SizedBox(width: 8),
                      const Text('English'),
                    ],
                  ),
                ),
                PopupMenuItem<String>(
                  value: 'ar',
                  child: Row(
                    children: [
                      Icon(
                        Icons.check_rounded,
                        color: _isArabic
                            ? const Color(0xFF2F743F)
                            : Colors.transparent,
                      ),
                      const SizedBox(width: 8),
                      const Text('Arabic'),
                    ],
                  ),
                ),
              ];
            },
          ),
          IconButton(
            tooltip: _isArabic ? 'تحديث' : 'Refresh',
            onPressed:
                orderProvider.isLoading
                    ? null
                    : _loadOrders,
            icon: const Icon(
              Icons.refresh,
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildStatusFilter(),
          Expanded(
            child: _buildBody(
              orderProvider,
              orders,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusFilter() {
    final statuses = [
      'ALL',
      'PENDING',
      'CONFIRMED',
      'COMPLETED',
      'CANCELLED',
    ];

    return Container(
      width: double.infinity,
      padding:
          const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 12,
      ),
      color: Colors.transparent,
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

              return Padding(
                padding:
                    const EdgeInsets.only(
                  right: 8,
                ),
                child: ChoiceChip(
                  label: Text(
                    _localizedStatus(status),
                  ),
                  selected: selected,
                  selectedColor: const Color(0xFF2F743F),
                  backgroundColor: Colors.white,
                  labelStyle: TextStyle(
                    color: selected ? Colors.white : const Color(0xFF1D2C21),
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                  ),
                  side: BorderSide(
                    color: selected
                        ? const Color(0xFF2F743F)
                        : const Color(0xFFD8E2D4),
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  onSelected: (_) {
                    setState(() {
                      _selectedStatus =
                          status;
                    });
                  },
                ),
              );
            },
          ).toList(),
        ),
      ),
    );
  }

  Widget _buildBody(
    OrderProvider orderProvider,
    List<OrderModel> orders,
  ) {
    if (orderProvider.isLoading &&
        orderProvider
            .adminOrders.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(
          color: Color(0xFF2F743F),
        ),
      );
    }

    if (orderProvider.errorMessage !=
            null &&
        orderProvider
            .adminOrders.isEmpty) {
      return RefreshIndicator(
        onRefresh:
            _loadOrders,
        child: ListView(
          physics:
              const AlwaysScrollableScrollPhysics(),
          padding:
              const EdgeInsets.all(
            24,
          ),
          children: [
            const SizedBox(
              height: 140,
            ),
            const Icon(
              Icons.error_outline,
              size: 80,
              color: Color(0xFFC65353),
            ),
            const SizedBox(
              height: 16,
            ),
            Text(
              orderProvider
                      .errorMessage ??
                  (_isArabic
                      ? 'فشل تحميل الطلبات'
                      : 'Failed to load orders'),
              textAlign:
                  TextAlign.center,
              style:
                  const TextStyle(
                fontSize: 17,
                fontWeight:
                    FontWeight.w600,
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            Center(
              child:
                  ElevatedButton.icon(
                onPressed:
                    _loadOrders,
                icon:
                    const Icon(
                  Icons.refresh,
                ),
                label: Text(
                  _isArabic ? 'حاول مرة أخرى' : 'Try Again',
                ),
              ),
            ),
          ],
        ),
      );
    }

    if (orders.isEmpty) {
      return RefreshIndicator(
        onRefresh:
            _loadOrders,
        child: ListView(
          physics:
              const AlwaysScrollableScrollPhysics(),
          padding:
              const EdgeInsets.all(
            24,
          ),
          children: [
            const SizedBox(
              height: 140,
            ),
            const Icon(
              Icons
                  .shopping_cart_outlined,
              size: 80,
              color: Color(0xFF6C786E),
            ),
            const SizedBox(
              height: 16,
            ),
            Center(
              child: Text(
                _selectedStatus ==
                        'ALL'
                    ? (_isArabic
                        ? 'لا توجد طلبات'
                        : 'No orders found')
                    : (_isArabic
                        ? 'لا توجد طلبات بحالة ${_localizedStatus(_selectedStatus)}'
                        : 'No $_selectedStatus orders found'),
                style:
                    const TextStyle(
                  fontSize: 18,
                  fontWeight:
                      FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh:
          _loadOrders,
      child: ListView.builder(
        physics:
            const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
        itemCount:
            orders.length,
        itemBuilder: (
          context,
          index,
        ) {
          final order =
              orders[index];

          return _orderCard(
            order,
          );
        },
      ),
    );
  }

  Widget _orderCard(
    OrderModel order,
  ) {
    final statusColor =
        _statusColor(
      order.status,
    );

    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 14),
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: const BorderSide(
          color: Color(0xFFDCE5D8),
        ),
      ),
      child: ExpansionTile(
        tilePadding:
            const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 8,
        ),
        childrenPadding:
            const EdgeInsets.fromLTRB(
          16,
          0,
          16,
          16,
        ),
        leading: CircleAvatar(
          backgroundColor:
              statusColor.withValues(
            alpha: 0.14,
          ),
          child: Icon(
            _statusIcon(
              order.status,
            ),
            color:
                statusColor,
          ),
        ),
        title: Text(
          order.customer.fullName
                  .trim()
                  .isEmpty
              ? (_isArabic ? 'عميل غير معروف' : 'Unknown Customer')
              : order
                  .customer.fullName,
          style:
              const TextStyle(
            fontWeight: FontWeight.w800,
            color:  Color(0xFF1D2C21),
          ),
        ),
        subtitle: Padding(
          padding:
              const EdgeInsets.only(
            top: 6,
          ),
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Text(
                _isArabic
                    ? 'طلب رقم #${_shortId(order.id)}'
                    : 'Order #${_shortId(order.id)}',
              ),
              const SizedBox(
                height: 4,
              ),
              Text(
                _isArabic
                    ? 'الإجمالي: ${order.totalPrice.toStringAsFixed(2)}'
                    : 'Total: ${order.totalPrice.toStringAsFixed(2)}',
              ),
              const SizedBox(
                height: 4,
              ),
              Text(
                _formatDateTime(
                  order.createdAt,
                ),
              ),
            ],
          ),
        ),
        trailing: Container(
          padding:
              const EdgeInsets.symmetric(
            horizontal: 10,
            vertical: 6,
          ),
          decoration:
              BoxDecoration(
            color:
                statusColor.withValues(
              alpha: 0.12,
            ),
            borderRadius:
                BorderRadius.circular(
              20,
            ),
          ),
          child: Text(
            _localizedStatus(order.status),
            style:
                TextStyle(
              color:
                  statusColor,
              fontSize: 11,
              fontWeight:
                  FontWeight.bold,
            ),
          ),
        ),
        children: [
          const Divider(),
          const SizedBox(
            height: 8,
          ),
          _sectionTitle(
            icon:
                Icons.person_outline,
            title:
                _isArabic ? 'العميل' : 'Customer',
          ),
          const SizedBox(
            height: 8,
          ),
          _infoRow(
            icon:
                Icons.email_outlined,
            text:
                order.customer.email,
          ),
          if (order.customer.phone
              .trim()
              .isNotEmpty)
            _infoRow(
              icon:
                  Icons.phone_outlined,
              text:
                  order.customer.phone,
            ),
          if (order.customer.address
              .trim()
              .isNotEmpty)
            _infoRow(
              icon: Icons
                  .location_on_outlined,
              text:
                  order.customer.address,
            ),
          const SizedBox(
            height: 14,
          ),
          _sectionTitle(
            icon:
                Icons.inventory_2_outlined,
            title:
                _isArabic ? 'عناصر الطلب' : 'Order Items',
          ),
          const SizedBox(
            height: 8,
          ),
          ...order.orderItems.map(
            (item) {
              return _orderItemCard(
                item,
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _orderItemCard(
    OrderItemModel item,
  ) {
    final product =
        item.product;

    final farmerName =
        product.farmer.fullName
                .trim()
                .isEmpty
            ? (_isArabic ? 'مزارع غير معروف' : 'Unknown Farmer')
            : product
                .farmer.fullName;

    return Container(
      width:
          double.infinity,
      margin:
          const EdgeInsets.only(
        bottom: 10,
      ),
      padding:
          const EdgeInsets.all(
        12,
      ),
      decoration:
          BoxDecoration(
        color:
            Colors.grey.shade50,
        borderRadius:
            BorderRadius.circular(
          12,
        ),
        border: Border.all(
          color: const Color(0xFFE3E9DF),
        ),
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Text(
            product.name
                    .trim()
                    .isEmpty
                ? (_isArabic ? 'منتج غير معروف' : 'Unknown Product')
                : product.name,
            style:
                const TextStyle(
              fontSize: 16,
              fontWeight:
                  FontWeight.bold,
            ),
          ),
          const SizedBox(
            height: 7,
          ),
          Text(
            _isArabic ? 'المزارع: $farmerName' : 'Farmer: $farmerName',
          ),
          const SizedBox(
            height: 4,
          ),
          Text(
            _isArabic
                ? 'الكمية: ${item.quantity} ${product.unit}'
                : 'Quantity: ${item.quantity} ${product.unit}',
          ),
          const SizedBox(
            height: 4,
          ),
          Text(
            _isArabic
                ? 'السعر: ${item.price.toStringAsFixed(2)}'
                : 'Price: ${item.price.toStringAsFixed(2)}',
          ),
          const SizedBox(
            height: 4,
          ),
          Text(
            _isArabic
                ? 'المجموع الفرعي: ${(item.price * item.quantity).toStringAsFixed(2)}'
                : 'Subtotal: ${(item.price * item.quantity).toStringAsFixed(2)}',
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

  Widget _sectionTitle({
    required IconData icon,
    required String title,
  }) {
    return Row(
      children: [
        Icon(
          icon,
          color: const Color(0xFF2F743F),
          size: 20,
        ),
        const SizedBox(
          width: 8,
        ),
        Text(
          title,
          style:
              const TextStyle(
            fontSize: 16,
            fontWeight:
                FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _infoRow({
    required IconData icon,
    required String text,
  }) {
    if (text.trim().isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding:
          const EdgeInsets.only(
        bottom: 7,
      ),
      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: 18,
            color: const Color(0xFF6C786E),
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

  String _localizedStatus(
    String status,
  ) {
    final normalized =
        status.trim().toUpperCase();

    if (!_isArabic) {
      return normalized == 'ALL'
          ? 'ALL ORDERS'
          : normalized;
    }

    switch (normalized) {
      case 'ALL':
        return 'جميع الطلبات';
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
        return const Color(0xFFC8792C);
      case 'CONFIRMED':
        return const Color(0xFF4C78A8);
      case 'COMPLETED':
        return const Color(0xFF3F8A50);
      case 'CANCELLED':
        return const Color(0xFFC65353);
      default:
        return const Color(0xFF6C786E);
    }
  }

  IconData _statusIcon(
    String status,
  ) {
    switch (
        status
            .trim()
            .toUpperCase()) {
      case 'PENDING':
        return Icons.schedule;
      case 'CONFIRMED':
        return Icons
            .check_circle_outline;
      case 'COMPLETED':
        return Icons
            .task_alt_outlined;
      case 'CANCELLED':
        return Icons.cancel_outlined;
      default:
        return Icons
            .shopping_cart_outlined;
    }
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

  String _formatDateTime(
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