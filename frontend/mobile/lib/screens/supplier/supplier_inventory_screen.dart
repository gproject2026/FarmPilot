import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../l10n/generated/app_localizations.dart';
import '../../providers/supplier_product_provider.dart';

class SupplierInventoryScreen extends StatefulWidget {
  const SupplierInventoryScreen({
    super.key,
  });

  @override
  State<SupplierInventoryScreen> createState() =>
      _SupplierInventoryScreenState();
}

class _SupplierInventoryScreenState
    extends State<SupplierInventoryScreen> {
  static const Color _darkGreen =
      Color(0xFF173F24);

  static const Color _primaryGreen =
      Color(0xFF2F6B3D);

  static const Color _background =
      Color(0xFFF8FAF4);

  static const Color _textPrimary =
      Color(0xFF1D2C21);

  static const Color _textSecondary =
      Color(0xFF68756B);

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback(
      (_) {
        _loadInventory();
      },
    );
  }

  Future<void> _loadInventory() async {
    await Provider.of<SupplierProductProvider>(
      context,
      listen: false,
    ).loadMySupplierProducts();
  }

  String _localizedProductName(
    Map<String, dynamic> product,
    bool isArabic,
  ) {
    final localized = isArabic
        ? product['nameAr']
        : product['nameEn'];

    final localizedText =
        localized?.toString().trim() ?? '';

    if (localizedText.isNotEmpty) {
      return localizedText;
    }

    return product['name']
            ?.toString()
            .trim() ??
        '';
  }

  String _localizedCategoryName(
    Map<String, dynamic> product,
    bool isArabic,
  ) {
    final category = product['category'];

    if (category is! Map) {
      return '';
    }

    final localized = isArabic
        ? category['nameAr']
        : category['nameEn'];

    final localizedText =
        localized?.toString().trim() ?? '';

    if (localizedText.isNotEmpty) {
      return localizedText;
    }

    return category['name']
            ?.toString()
            .trim() ??
        '';
  }

  String _statusLabel(
    String status,
    AppLocalizations l10n,
  ) {
    switch (status) {
      case 'OUT_OF_STOCK':
        return l10n.outOfStock;

      case 'HIDDEN':
        return l10n.hidden;

      case 'AVAILABLE':
      default:
        return l10n.available;
    }
  }

  Color _statusColor(
    String status,
  ) {
    switch (status) {
      case 'OUT_OF_STOCK':
        return const Color(
          0xFFC66A20,
        );

      case 'HIDDEN':
        return const Color(
          0xFF6B7280,
        );

      case 'AVAILABLE':
      default:
        return _primaryGreen;
    }
  }

  IconData _statusIcon(
    String status,
  ) {
    switch (status) {
      case 'OUT_OF_STOCK':
        return Icons
            .inventory_2_outlined;

      case 'HIDDEN':
        return Icons
            .visibility_off_outlined;

      case 'AVAILABLE':
      default:
        return Icons
            .check_circle_outline_rounded;
    }
  }

  Future<void> _openInventoryDialog({
    required Map<String, dynamic> product,
    required AppLocalizations l10n,
    required bool isArabic,
  }) async {
    final productId =
        product['id']?.toString() ?? '';

    if (productId.isEmpty) {
      return;
    }

    final currentQuantity =
        int.tryParse(
          product['quantity']
                  ?.toString() ??
              '0',
        ) ??
        0;

    var selectedStatus =
        product['status']
                ?.toString() ??
            'AVAILABLE';

    if (![
      'AVAILABLE',
      'OUT_OF_STOCK',
      'HIDDEN',
    ].contains(selectedStatus)) {
      selectedStatus = currentQuantity <= 0
          ? 'OUT_OF_STOCK'
          : 'AVAILABLE';
    }

    final quantityController =
        TextEditingController(
      text: currentQuantity.toString(),
    );

    final productName =
        _localizedProductName(
      product,
      isArabic,
    );

    final result =
        await showDialog<_InventoryUpdate>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (
            context,
            setDialogState,
          ) {
            void syncStatusWithQuantity(
              String value,
            ) {
              final quantity =
                  int.tryParse(
                value.trim(),
              );

              if (quantity == null ||
                  quantity < 0) {
                return;
              }

              if (quantity == 0 &&
                  selectedStatus !=
                      'HIDDEN') {
                setDialogState(
                  () {
                    selectedStatus =
                        'OUT_OF_STOCK';
                  },
                );
                return;
              }

              if (quantity > 0 &&
                  selectedStatus ==
                      'OUT_OF_STOCK') {
                setDialogState(
                  () {
                    selectedStatus =
                        'AVAILABLE';
                  },
                );
              }
            }

            return AlertDialog(
              backgroundColor:
                  Colors.white,
              shape:
                  RoundedRectangleBorder(
                borderRadius:
                    BorderRadius.circular(
                  24,
                ),
              ),
              titlePadding:
                  const EdgeInsets.fromLTRB(
                24,
                24,
                24,
                0,
              ),
              contentPadding:
                  const EdgeInsets.fromLTRB(
                24,
                20,
                24,
                8,
              ),
              actionsPadding:
                  const EdgeInsets.fromLTRB(
                24,
                8,
                24,
                20,
              ),
              title: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration:
                        BoxDecoration(
                      color:
                          const Color(
                        0xFFE9F2E1,
                      ),
                      borderRadius:
                          BorderRadius
                              .circular(
                        14,
                      ),
                    ),
                    child:
                        const Icon(
                      Icons
                          .warehouse_outlined,
                      color:
                          _primaryGreen,
                    ),
                  ),
                  const SizedBox(
                    width: 12,
                  ),
                  Expanded(
                    child: Text(
                      l10n
                          .updateInventory,
                      style:
                          const TextStyle(
                        color:
                            _textPrimary,
                        fontWeight:
                            FontWeight.w800,
                        fontSize: 20,
                      ),
                    ),
                  ),
                ],
              ),
              content:
                  ConstrainedBox(
                constraints:
                    const BoxConstraints(
                  maxWidth: 440,
                ),
                child:
                    SingleChildScrollView(
                  child: Column(
                    mainAxisSize:
                        MainAxisSize.min,
                    crossAxisAlignment:
                        CrossAxisAlignment
                            .start,
                    children: [
                      if (productName
                          .isNotEmpty)
                        Container(
                          width:
                              double.infinity,
                          padding:
                              const EdgeInsets
                                  .all(
                            14,
                          ),
                          decoration:
                              BoxDecoration(
                            color:
                                _background,
                            borderRadius:
                                BorderRadius
                                    .circular(
                              14,
                            ),
                            border:
                                Border.all(
                              color:
                                  const Color(
                                0xFFDDE6D8,
                              ),
                            ),
                          ),
                          child: Text(
                            productName,
                            style:
                                const TextStyle(
                              color:
                                  _textPrimary,
                              fontWeight:
                                  FontWeight
                                      .w700,
                            ),
                          ),
                        ),
                      const SizedBox(
                        height: 18,
                      ),
                      Text(
                        l10n.quantity,
                        style:
                            const TextStyle(
                          color:
                              _textPrimary,
                          fontWeight:
                              FontWeight.w700,
                        ),
                      ),
                      const SizedBox(
                        height: 8,
                      ),
                      TextField(
                        controller:
                            quantityController,
                        keyboardType:
                            TextInputType
                                .number,
                        onChanged:
                            syncStatusWithQuantity,
                        decoration:
                            InputDecoration(
                          prefixIcon:
                              const Icon(
                            Icons
                                .inventory_outlined,
                            color:
                                _primaryGreen,
                          ),
                          border:
                              OutlineInputBorder(
                            borderRadius:
                                BorderRadius
                                    .circular(
                              14,
                            ),
                          ),
                          enabledBorder:
                              OutlineInputBorder(
                            borderRadius:
                                BorderRadius
                                    .circular(
                              14,
                            ),
                            borderSide:
                                const BorderSide(
                              color:
                                  Color(
                                0xFFD7E1D3,
                              ),
                            ),
                          ),
                          focusedBorder:
                              OutlineInputBorder(
                            borderRadius:
                                BorderRadius
                                    .circular(
                              14,
                            ),
                            borderSide:
                                const BorderSide(
                              color:
                                  _primaryGreen,
                              width: 1.5,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 18,
                      ),
                      Text(
                        l10n.stockStatus,
                        style:
                            const TextStyle(
                          color:
                              _textPrimary,
                          fontWeight:
                              FontWeight.w700,
                        ),
                      ),
                      const SizedBox(
                        height: 8,
                      ),
                      DropdownButtonFormField<
                          String>(
                        initialValue:
                            selectedStatus,
                        decoration:
                            InputDecoration(
                          prefixIcon:
                              const Icon(
                            Icons
                                .fact_check_outlined,
                            color:
                                _primaryGreen,
                          ),
                          border:
                              OutlineInputBorder(
                            borderRadius:
                                BorderRadius
                                    .circular(
                              14,
                            ),
                          ),
                          enabledBorder:
                              OutlineInputBorder(
                            borderRadius:
                                BorderRadius
                                    .circular(
                              14,
                            ),
                            borderSide:
                                const BorderSide(
                              color:
                                  Color(
                                0xFFD7E1D3,
                              ),
                            ),
                          ),
                        ),
                        items: [
                          DropdownMenuItem(
                            value:
                                'AVAILABLE',
                            child: Text(
                              l10n.available,
                            ),
                          ),
                          DropdownMenuItem(
                            value:
                                'OUT_OF_STOCK',
                            child: Text(
                              l10n
                                  .outOfStock,
                            ),
                          ),
                          DropdownMenuItem(
                            value:
                                'HIDDEN',
                            child: Text(
                              l10n.hidden,
                            ),
                          ),
                        ],
                        onChanged: (value) {
                          if (value ==
                              null) {
                            return;
                          }

                          setDialogState(
                            () {
                              selectedStatus =
                                  value;
                            },
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(
                      dialogContext,
                    );
                  },
                  child: Text(
                    MaterialLocalizations
                            .of(
                              context,
                            )
                        .cancelButtonLabel,
                    style:
                        const TextStyle(
                      color:
                          _textSecondary,
                    ),
                  ),
                ),
                FilledButton.icon(
                  style:
                      FilledButton.styleFrom(
                    backgroundColor:
                        _primaryGreen,
                    foregroundColor:
                        Colors.white,
                    padding:
                        const EdgeInsets
                            .symmetric(
                      horizontal: 18,
                      vertical: 14,
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
                  onPressed: () {
                    final quantity =
                        int.tryParse(
                      quantityController
                          .text
                          .trim(),
                    );

                    if (quantity ==
                            null ||
                        quantity < 0) {
                      ScaffoldMessenger
                              .of(context)
                          .showSnackBar(
                        SnackBar(
                          content: Text(
                            l10n
                                .enterValidQuantity,
                          ),
                        ),
                      );
                      return;
                    }

                    var finalStatus =
                        selectedStatus;

                    if (quantity == 0 &&
                        finalStatus ==
                            'AVAILABLE') {
                      finalStatus =
                          'OUT_OF_STOCK';
                    }

                    if (quantity > 0 &&
                        finalStatus ==
                            'OUT_OF_STOCK') {
                      finalStatus =
                          'AVAILABLE';
                    }

                    Navigator.pop(
                      dialogContext,
                      _InventoryUpdate(
                        quantity:
                            quantity,
                        status:
                            finalStatus,
                      ),
                    );
                  },
                  icon:
                      const Icon(
                    Icons.save_outlined,
                  ),
                  label: Text(
                    l10n
                        .updateInventory,
                  ),
                ),
              ],
            );
          },
        );
      },
    );

    quantityController.dispose();

    if (result == null ||
        !mounted) {
      return;
    }

    final provider =
        Provider.of<SupplierProductProvider>(
      context,
      listen: false,
    );

    final success =
        await provider
            .updateSupplierInventory(
      productId: productId,
      quantity: result.quantity,
      status: result.status,
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
                ? l10n
                    .inventoryUpdatedSuccessfully
                : provider
                            .errorMessage
                            ?.trim()
                            .isNotEmpty ==
                        true
                    ? provider
                        .errorMessage!
                    : l10n
                        .failedToUpdateInventory,
          ),
          behavior:
              SnackBarBehavior.floating,
        ),
      );
  }

  @override
  Widget build(
    BuildContext context,
  ) {
    final l10n =
        AppLocalizations.of(context)!;

    final isArabic =
        Localizations.localeOf(
              context,
            ).languageCode ==
            'ar';

    final provider =
        Provider.of<SupplierProductProvider>(
      context,
    );

    return Scaffold(
      backgroundColor:
          _background,
      appBar: AppBar(
        backgroundColor:
            _primaryGreen,
        foregroundColor:
            Colors.white,
        elevation: 0,
        title: Text(
          l10n.supplierInventory,
          style:
              const TextStyle(
            fontWeight:
                FontWeight.w800,
          ),
        ),
        actions: [
          IconButton(
            tooltip:
                l10n.refresh,
            onPressed:
                provider.isLoading
                    ? null
                    : _loadInventory,
            icon:
                const Icon(
              Icons.refresh_rounded,
            ),
          ),
        ],
      ),
      body: RefreshIndicator(
        color: _primaryGreen,
        onRefresh: _loadInventory,
        child: _buildBody(
          provider: provider,
          l10n: l10n,
          isArabic: isArabic,
        ),
      ),
    );
  }

  Widget _buildBody({
    required SupplierProductProvider
        provider,
    required AppLocalizations l10n,
    required bool isArabic,
  }) {
    if (provider.isLoading &&
        provider
            .supplierProducts
            .isEmpty) {
      return ListView(
        physics:
            AlwaysScrollableScrollPhysics(),
        children: [
          SizedBox(
            height: 320,
            child: Center(
              child:
                  CircularProgressIndicator(
                color:
                    _primaryGreen,
              ),
            ),
          ),
        ],
      );
    }

    if (provider.errorMessage !=
            null &&
        provider
            .supplierProducts
            .isEmpty) {
      return ListView(
        physics:
            const AlwaysScrollableScrollPhysics(),
        padding:
            const EdgeInsets.all(
          24,
        ),
        children: [
          const SizedBox(
            height: 100,
          ),
          Icon(
            Icons
                .error_outline_rounded,
            size: 64,
            color: Colors.red
                .withValues(
              alpha: 0.70,
            ),
          ),
          const SizedBox(
            height: 18,
          ),
          Text(
            provider.errorMessage!,
            textAlign:
                TextAlign.center,
            style:
                const TextStyle(
              color:
                  _textSecondary,
              fontSize: 15,
            ),
          ),
          const SizedBox(
            height: 18,
          ),
          Center(
            child:
                FilledButton.icon(
              onPressed:
                  _loadInventory,
              style:
                  FilledButton
                      .styleFrom(
                backgroundColor:
                    _primaryGreen,
              ),
              icon:
                  const Icon(
                Icons
                    .refresh_rounded,
              ),
              label: Text(
                l10n.tryAgain,
              ),
            ),
          ),
        ],
      );
    }

    final products =
        provider.supplierProducts;

    if (products.isEmpty) {
      return ListView(
        physics:
            const AlwaysScrollableScrollPhysics(),
        padding:
            const EdgeInsets.all(
          24,
        ),
        children: [
          const SizedBox(
            height: 100,
          ),
          Container(
            width: 86,
            height: 86,
            margin:
                const EdgeInsets
                    .symmetric(
              horizontal: 100,
            ),
            decoration:
                BoxDecoration(
              color:
                  const Color(
                0xFFE9F2E1,
              ),
              borderRadius:
                  BorderRadius
                      .circular(
                28,
              ),
            ),
            child:
                const Icon(
              Icons
                  .warehouse_outlined,
              color:
                  _primaryGreen,
              size: 42,
            ),
          ),
          const SizedBox(
            height: 22,
          ),
          Text(
            l10n.noInventoryProducts,
            textAlign:
                TextAlign.center,
            style:
                const TextStyle(
              color:
                  _textPrimary,
              fontSize: 20,
              fontWeight:
                  FontWeight.w800,
            ),
          ),
        ],
      );
    }

    return LayoutBuilder(
      builder: (
        context,
        constraints,
      ) {
        final horizontalPadding =
            constraints.maxWidth >=
                    1000
                ? 42.0
                : 18.0;

        return ListView(
          physics:
              const AlwaysScrollableScrollPhysics(),
          padding:
              EdgeInsets.fromLTRB(
            horizontalPadding,
            24,
            horizontalPadding,
            40,
          ),
          children: [
            _buildHeaderCard(
              l10n: l10n,
              count:
                  products.length,
            ),
            const SizedBox(
              height: 22,
            ),
            Wrap(
              spacing: 16,
              runSpacing: 16,
              children:
                  products.map<Widget>(
                (rawProduct) {
                  if (rawProduct
                      is! Map) {
                    return const SizedBox
                        .shrink();
                  }

                  final product =
                      Map<String,
                          dynamic>.from(
                    rawProduct,
                  );

                  final width =
                      constraints.maxWidth >=
                              1100
                          ? (constraints
                                      .maxWidth -
                                  horizontalPadding *
                                      2 -
                                  32) /
                              3
                          : constraints.maxWidth >=
                                  700
                              ? (constraints
                                          .maxWidth -
                                      horizontalPadding *
                                          2 -
                                      16) /
                                  2
                              : constraints
                                      .maxWidth -
                                  horizontalPadding *
                                      2;

                  return SizedBox(
                    width: width,
                    child:
                        _buildInventoryCard(
                      product:
                          product,
                      l10n: l10n,
                      isArabic:
                          isArabic,
                    ),
                  );
                },
              ).toList(),
            ),
          ],
        );
      },
    );
  }

  Widget _buildHeaderCard({
    required AppLocalizations l10n,
    required int count,
  }) {
    return Container(
      width: double.infinity,
      padding:
          const EdgeInsets.all(
        24,
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
              0xFFF1F7E9,
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
            0xFFDCE7D6,
          ),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration:
                BoxDecoration(
              color:
                  const Color(
                0xFFE3F0D6,
              ),
              borderRadius:
                  BorderRadius
                      .circular(
                18,
              ),
            ),
            child:
                const Icon(
              Icons
                  .warehouse_outlined,
              color:
                  _primaryGreen,
              size: 31,
            ),
          ),
          const SizedBox(
            width: 18,
          ),
          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment
                      .start,
              children: [
                Text(
                  l10n
                      .inventoryManagement,
                  style:
                      const TextStyle(
                    color:
                        _textPrimary,
                    fontSize: 23,
                    fontWeight:
                        FontWeight
                            .w800,
                  ),
                ),
                const SizedBox(
                  height: 5,
                ),
                Text(
                  l10n
                      .inventoryManagementSubtitle,
                  style:
                      const TextStyle(
                    color:
                        _textSecondary,
                    fontSize: 14,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding:
                const EdgeInsets
                    .symmetric(
              horizontal: 14,
              vertical: 9,
            ),
            decoration:
                BoxDecoration(
              color:
                  _primaryGreen,
              borderRadius:
                  BorderRadius
                      .circular(
                18,
              ),
            ),
            child: Text(
              count.toString(),
              style:
                  const TextStyle(
                color:
                    Colors.white,
                fontWeight:
                    FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInventoryCard({
    required Map<String, dynamic>
        product,
    required AppLocalizations l10n,
    required bool isArabic,
  }) {
    final name =
        _localizedProductName(
      product,
      isArabic,
    );

    final category =
        _localizedCategoryName(
      product,
      isArabic,
    );

    final quantity =
        int.tryParse(
          product['quantity']
                  ?.toString() ??
              '0',
        ) ??
        0;

    final unit =
        product['unit']
                ?.toString()
                .trim() ??
            '';

    final status =
        product['status']
                ?.toString() ??
            'AVAILABLE';

    final statusColor =
        _statusColor(
      status,
    );

    return Container(
      padding:
          const EdgeInsets.all(
        20,
      ),
      decoration:
          BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(
          22,
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
                _darkGreen.withValues(
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
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
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
                    0xFFE9F2E1,
                  ),
                  borderRadius:
                      BorderRadius
                          .circular(
                    15,
                  ),
                ),
                child:
                    const Icon(
                  Icons
                      .inventory_2_outlined,
                  color:
                      _primaryGreen,
                  size: 26,
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
                      name.isNotEmpty
                          ? name
                          : '-',
                      maxLines: 2,
                      overflow:
                          TextOverflow
                              .ellipsis,
                      style:
                          const TextStyle(
                        color:
                            _textPrimary,
                        fontSize: 17,
                        fontWeight:
                            FontWeight
                                .w800,
                      ),
                    ),
                    if (category
                        .isNotEmpty) ...[
                      const SizedBox(
                        height: 4,
                      ),
                      Text(
                        category,
                        maxLines: 1,
                        overflow:
                            TextOverflow
                                .ellipsis,
                        style:
                            const TextStyle(
                          color:
                              _textSecondary,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(
            height: 22,
          ),
          Container(
            width: double.infinity,
            padding:
                const EdgeInsets
                    .all(
              15,
            ),
            decoration:
                BoxDecoration(
              color:
                  _background,
              borderRadius:
                  BorderRadius
                      .circular(
                16,
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child:
                      _InventoryMetric(
                    icon: Icons
                        .inventory_outlined,
                    label:
                        l10n.currentStock,
                    value: unit
                            .isEmpty
                        ? quantity
                            .toString()
                        : '$quantity $unit',
                  ),
                ),
                Container(
                  width: 1,
                  height: 42,
                  color:
                      const Color(
                    0xFFDDE6D8,
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding:
                        const EdgeInsetsDirectional
                            .only(
                      start: 14,
                    ),
                    child:
                        _InventoryMetric(
                      icon:
                          _statusIcon(
                        status,
                      ),
                      label:
                          l10n.status,
                      value:
                          _statusLabel(
                        status,
                        l10n,
                      ),
                      valueColor:
                          statusColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(
            height: 18,
          ),
          Container(
            padding:
                const EdgeInsets
                    .symmetric(
              horizontal: 11,
              vertical: 7,
            ),
            decoration:
                BoxDecoration(
              color:
                  statusColor.withValues(
                alpha: 0.10,
              ),
              borderRadius:
                  BorderRadius
                      .circular(
                20,
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
                  color:
                      statusColor,
                  size: 16,
                ),
                const SizedBox(
                  width: 6,
                ),
                Text(
                  _statusLabel(
                    status,
                    l10n,
                  ),
                  style:
                      TextStyle(
                    color:
                        statusColor,
                    fontSize: 12,
                    fontWeight:
                        FontWeight
                            .w700,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(
            height: 18,
          ),
          SizedBox(
            width: double.infinity,
            child:
                FilledButton.icon(
              onPressed: () {
                _openInventoryDialog(
                  product:
                      product,
                  l10n: l10n,
                  isArabic:
                      isArabic,
                );
              },
              style:
                  FilledButton
                      .styleFrom(
                backgroundColor:
                    _primaryGreen,
                foregroundColor:
                    Colors.white,
                padding:
                    const EdgeInsets
                        .symmetric(
                  vertical: 14,
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
              icon:
                  const Icon(
                Icons
                    .edit_outlined,
                size: 19,
              ),
              label: Text(
                l10n.updateInventory,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InventoryMetric
    extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;

  const _InventoryMetric({
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor,
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
          size: 20,
          color:
              const Color(
            0xFF2F6B3D,
          ),
        ),
        const SizedBox(
          width: 9,
        ),
        Expanded(
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment
                    .start,
            children: [
              Text(
                label,
                style:
                    const TextStyle(
                  color:
                      Color(
                    0xFF68756B,
                  ),
                  fontSize: 11,
                ),
              ),
              const SizedBox(
                height: 3,
              ),
              Text(
                value,
                maxLines: 2,
                overflow:
                    TextOverflow
                        .ellipsis,
                style:
                    TextStyle(
                  color:
                      valueColor ??
                          const Color(
                            0xFF1D2C21,
                          ),
                  fontSize: 13,
                  fontWeight:
                      FontWeight
                          .w700,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _InventoryUpdate {
  final int quantity;
  final String status;

  const _InventoryUpdate({
    required this.quantity,
    required this.status,
  });
}