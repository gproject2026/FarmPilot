import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../l10n/generated/app_localizations.dart';
import '../../providers/auth_provider.dart';
import '../../providers/locale_provider.dart';
import '../../providers/notification_provider.dart';
import '../notifications_screen.dart';
import 'supplier_categories_screen.dart';
import 'supplier_inventory_screen.dart';
import 'supplier_orders_screen.dart';
import 'supplier_products_screen.dart';
import 'supplier_store_location_screen.dart';

class SupplierDashboardScreen extends StatefulWidget {
  const SupplierDashboardScreen({
    super.key,
  });

  @override
  State<SupplierDashboardScreen> createState() =>
      _SupplierDashboardScreenState();
}

class _SupplierDashboardScreenState
    extends State<SupplierDashboardScreen> {
  static const Color _darkGreen =
      Color(0xFF173F24);

  static const Color _primaryGreen =
      Color(0xFF2F6B3D);

  static const Color _lightGreen =
      Color(0xFFDDECB8);

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
        _loadData();
      },
    );
  }

  Future<void> _loadData() async {
    await Provider.of<NotificationProvider>(
      context,
      listen: false,
    ).loadNotifications();
  }

  Future<void> _openNotifications() async {
    final notificationProvider =
        Provider.of<NotificationProvider>(
      context,
      listen: false,
    );

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            const NotificationsScreen(),
      ),
    );

    if (!mounted) {
      return;
    }

    await notificationProvider
        .loadNotifications();
  }

  Future<void> _logout() async {
    final authProvider =
        Provider.of<AuthProvider>(
      context,
      listen: false,
    );

    final notificationProvider =
        Provider.of<NotificationProvider>(
      context,
      listen: false,
    );

    notificationProvider
        .clearNotifications();

    authProvider.logout();

    if (!mounted) {
      return;
    }

    Navigator.of(context)
        .pushNamedAndRemoveUntil(
      '/',
      (route) => false,
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

  @override
  Widget build(
    BuildContext context,
  ) {
    final notificationProvider =
        Provider.of<NotificationProvider>(
      context,
    );

    final localeProvider =
        Provider.of<LocaleProvider>(
      context,
    );

    final l10n =
        AppLocalizations.of(context)!;

    final isArabic =
        localeProvider
                .locale.languageCode ==
            'ar';

    return Scaffold(
      backgroundColor:
          _background,
      body: Stack(
        children: [
          const Positioned.fill(
            child:
                _SupplierDashboardBackdrop(),
          ),
          RefreshIndicator(
            onRefresh: _loadData,
            color: _primaryGreen,
            child: CustomScrollView(
              physics:
                  const AlwaysScrollableScrollPhysics(),
              slivers: [
                SliverToBoxAdapter(
                  child: _buildHeader(
                    l10n: l10n,
                    isArabic:
                        isArabic,
                    notificationProvider:
                        notificationProvider,
                  ),
                ),
                SliverToBoxAdapter(
                  child: LayoutBuilder(
                    builder: (
                      context,
                      constraints,
                    ) {
                      final isWide =
                          constraints
                                  .maxWidth >=
                              1000;

                      return Padding(
                        padding:
                            EdgeInsets
                                .fromLTRB(
                          isWide
                              ? 42
                              : 18,
                          isWide
                              ? 30
                              : 20,
                          isWide
                              ? 42
                              : 18,
                          52,
                        ),
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment
                                  .start,
                          children: [
                            _buildWelcomeSection(
                              l10n,
                            ),
                            const SizedBox(
                              height: 30,
                            ),
                            _buildSectionTitle(
                              l10n.quickActions,
                              l10n
                                  .quickActionsSubtitle,
                            ),
                            const SizedBox(
                              height: 17,
                            ),
                            _buildQuickActions(
                              isWide:
                                  isWide,
                              l10n:
                                  l10n,
                            ),
                            const SizedBox(
                              height: 38,
                            ),
                            _buildSectionTitle(
                              l10n
                                  .supplierManagement,
                              l10n
                                  .supplierManagementSubtitle,
                            ),
                            const SizedBox(
                              height: 17,
                            ),
                            _buildManagementCards(
                              isWide:
                                  isWide,
                              l10n:
                                  l10n,
                              notificationProvider:
                                  notificationProvider,
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader({
    required AppLocalizations l10n,
    required bool isArabic,
    required NotificationProvider
        notificationProvider,
  }) {
    return Container(
      padding:
          const EdgeInsets.fromLTRB(
        24,
        18,
        24,
        24,
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
            Color(0xFF123A22),
            Color(0xFF205A34),
            Color(0xFF2E6F40),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color:
                _darkGreen.withValues(
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
            Container(
              width: 46,
              height: 46,
              decoration:
                  BoxDecoration(
                color:
                    _lightGreen,
                borderRadius:
                    BorderRadius
                        .circular(
                  14,
                ),
              ),
              child:
                  const Icon(
                Icons.storefront_rounded,
                color:
                    _darkGreen,
                size: 25,
              ),
            ),
            const SizedBox(
              width: 12,
            ),
            Expanded(
              child: Text(
                l10n.appName,
                style:
                    const TextStyle(
                  color:
                      Colors.white,
                  fontSize: 22,
                  fontWeight:
                      FontWeight.w800,
                ),
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
                    BorderRadius
                        .circular(
                  16,
                ),
              ),
              onSelected:
                  _changeLanguage,
              itemBuilder:
                  (context) {
                return [
                  PopupMenuItem<
                      String>(
                    value: 'en',
                    child: Row(
                      mainAxisSize:
                          MainAxisSize
                              .min,
                      children: [
                        Icon(
                          Icons
                              .check_rounded,
                          size: 20,
                          color: !isArabic
                              ? _primaryGreen
                              : Colors
                                  .transparent,
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
                  PopupMenuItem<
                      String>(
                    value: 'ar',
                    child: Row(
                      mainAxisSize:
                          MainAxisSize
                              .min,
                      children: [
                        Icon(
                          Icons
                              .check_rounded,
                          size: 20,
                          color: isArabic
                              ? _primaryGreen
                              : Colors
                                  .transparent,
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
                decoration:
                    BoxDecoration(
                  color:
                      Colors.white
                          .withValues(
                    alpha: 0.10,
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
                  Icons.language_rounded,
                  color:
                      Colors.white,
                  size: 22,
                ),
              ),
            ),
            const SizedBox(
              width: 10,
            ),
            Stack(
              clipBehavior:
                  Clip.none,
              children: [
                _HeaderIconButton(
                  icon: Icons
                      .notifications_none_rounded,
                  onTap:
                      _openNotifications,
                ),
                if (notificationProvider
                        .unreadCount >
                    0)
                  Positioned(
                    right: -4,
                    top: -4,
                    child:
                        Container(
                      constraints:
                          const BoxConstraints(
                        minWidth: 18,
                        minHeight: 18,
                      ),
                      padding:
                          const EdgeInsets
                              .symmetric(
                        horizontal: 4,
                      ),
                      decoration:
                          BoxDecoration(
                        color:
                            const Color(
                          0xFFE35D5D,
                        ),
                        borderRadius:
                            BorderRadius
                                .circular(
                          12,
                        ),
                        border:
                            Border.all(
                          color:
                              Colors.white,
                          width: 1.5,
                        ),
                      ),
                      alignment:
                          Alignment
                              .center,
                      child: Text(
                        notificationProvider
                                    .unreadCount >
                                99
                            ? '99+'
                            : notificationProvider
                                .unreadCount
                                .toString(),
                        style:
                            const TextStyle(
                          color:
                              Colors.white,
                          fontSize: 9,
                          fontWeight:
                              FontWeight
                                  .bold,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(
              width: 10,
            ),
            _HeaderIconButton(
              icon:
                  Icons.logout_rounded,
              onTap:
                  _logout,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomeSection(
    AppLocalizations l10n,
  ) {
    return Container(
      width:
          double.infinity,
      constraints:
          const BoxConstraints(
        minHeight: 150,
      ),
      padding:
          const EdgeInsets.symmetric(
        horizontal: 28,
        vertical: 28,
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
            Color(0xFFFFFFFF),
            Color(0xFFFFFEFA),
            Color(0xFFF6F9F0),
          ],
        ),
        borderRadius:
            BorderRadius.circular(
          28,
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
                _darkGreen.withValues(
              alpha: 0.055,
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
      child: Row(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration:
                BoxDecoration(
              color:
                  const Color(
                0xFFEAF3DF,
              ),
              borderRadius:
                  BorderRadius
                      .circular(
                20,
              ),
            ),
            child:
                const Icon(
              Icons.storefront_outlined,
              color:
                  _primaryGreen,
              size: 34,
            ),
          ),
          const SizedBox(
            width: 24,
          ),
          Expanded(
            child: Column(
              mainAxisSize:
                  MainAxisSize.min,
              crossAxisAlignment:
                  CrossAxisAlignment
                      .start,
              children: [
                Text(
                  l10n.welcomeSupplier,
                  style:
                      const TextStyle(
                    color:
                        _textPrimary,
                    fontSize: 31,
                    fontWeight:
                        FontWeight.w800,
                    letterSpacing:
                        -0.8,
                  ),
                ),
                const SizedBox(
                  height: 8,
                ),
                Text(
                  l10n
                      .supplierDashboardSubtitle,
                  style:
                      const TextStyle(
                    color:
                        _textSecondary,
                    fontSize: 15,
                    height: 1.55,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions({
    required bool isWide,
    required AppLocalizations l10n,
  }) {
    final actions = [
      _ActionInfo(
        title:
            l10n.mySupplierProducts,
        subtitle:
            l10n.manageSupplierProducts,
        icon:
            Icons.inventory_2_outlined,
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) =>
                  const SupplierProductsScreen(),
            ),
          );
        },
      ),
      _ActionInfo(
        title:
            l10n.supplierOrders,
        subtitle:
            l10n.manageFarmerOrders,
        icon:
            Icons.shopping_bag_outlined,
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) =>
                  const SupplierOrdersScreen(),
            ),
          );
        },
      ),
      _ActionInfo(
        title:
            l10n.supplierCategories,
        subtitle:
            l10n.browseSupplierCategories,
        icon:
            Icons.category_outlined,
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) =>
                  const SupplierCategoriesScreen(),
            ),
          );
        },
      ),
      _ActionInfo(
        title:
            l10n.supplierInventory,
        subtitle:
            l10n.manageSupplierInventory,
        icon:
            Icons.warehouse_outlined,
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) =>
                  const SupplierInventoryScreen(),
            ),
          );
        },
      ),
    ];

    return LayoutBuilder(
      builder: (
        context,
        constraints,
      ) {
        final columns =
            isWide
                ? 4
                : constraints
                            .maxWidth >=
                        650
                    ? 2
                    : 1;

        const spacing =
            14.0;

        final width =
            (constraints.maxWidth -
                    spacing *
                        (columns - 1)) /
                columns;

        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children:
              actions.map(
            (action) {
              return SizedBox(
                width: width,
                child:
                    _QuickActionCard(
                  action:
                      action,
                ),
              );
            },
          ).toList(),
        );
      },
    );
  }

  Widget _buildManagementCards({
    required bool isWide,
    required AppLocalizations l10n,
    required NotificationProvider
        notificationProvider,
  }) {
    final items = [
      _ActionInfo(
        title:
            notificationProvider
                        .unreadCount >
                    0
                ? '${l10n.notifications} '
                    '(${notificationProvider.unreadCount})'
                : l10n.notifications,
        subtitle:
            l10n.viewLatestUpdates,
        icon:
            Icons.notifications_outlined,
        onTap:
            _openNotifications,
      ),
      _ActionInfo(
        title:
            l10n.storeLocation,
        subtitle:
            l10n.manageStoreLocation,
        icon:
            Icons.location_on_outlined,
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) =>
                  const SupplierStoreLocationScreen(),
            ),
          );
        },
      ),
    ];

    return LayoutBuilder(
      builder: (
        context,
        constraints,
      ) {
        final columns =
            isWide
                ? 2
                : 1;

        const spacing =
            14.0;

        final width =
            (constraints.maxWidth -
                    spacing *
                        (columns - 1)) /
                columns;

        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children:
              items.map(
            (item) {
              return SizedBox(
                width: width,
                child:
                    _ManagementCard(
                  item:
                      item,
                ),
              );
            },
          ).toList(),
        );
      },
    );
  }

  Widget _buildSectionTitle(
    String title,
    String subtitle,
  ) {
    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisSize:
              MainAxisSize.min,
          children: [
            Container(
              width: 7,
              height: 28,
              decoration:
                  BoxDecoration(
                gradient:
                    const LinearGradient(
                  begin:
                      Alignment.topCenter,
                  end:
                      Alignment.bottomCenter,
                  colors: [
                    Color(
                      0xFF4D8A4B,
                    ),
                    Color(
                      0xFF9FC65B,
                    ),
                  ],
                ),
                borderRadius:
                    BorderRadius
                        .circular(
                  10,
                ),
              ),
            ),
            const SizedBox(
              width: 10,
            ),
            Text(
              title,
              style:
                  const TextStyle(
                color:
                    _textPrimary,
                fontSize: 23,
                fontWeight:
                    FontWeight.w800,
              ),
            ),
          ],
        ),
        const SizedBox(
          height: 6,
        ),
        Padding(
          padding:
              const EdgeInsetsDirectional
                  .only(
            start: 17,
          ),
          child: Text(
            subtitle,
            style:
                const TextStyle(
              color:
                  _textSecondary,
              fontSize: 14,
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }
}

class _HeaderIconButton
    extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _HeaderIconButton({
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    return Material(
      color:
          Colors.white.withValues(
        alpha: 0.10,
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
                Colors.white,
            size: 22,
          ),
        ),
      ),
    );
  }
}

class _ActionInfo {
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;

  const _ActionInfo({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
  });
}

class _QuickActionCard
    extends StatelessWidget {
  final _ActionInfo action;

  const _QuickActionCard({
    required this.action,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    return Material(
      color:
          Colors.transparent,
      borderRadius:
          BorderRadius.circular(
        20,
      ),
      child: InkWell(
        onTap:
            action.onTap,
        borderRadius:
            BorderRadius.circular(
          20,
        ),
        child: Container(
          padding:
              const EdgeInsets.all(
            20,
          ),
          decoration:
              BoxDecoration(
            color:
                Colors.white,
            borderRadius:
                BorderRadius
                    .circular(
              20,
            ),
            border:
                Border.all(
              color:
                  const Color(
                0xFFDDE6D8,
              ),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration:
                    BoxDecoration(
                  color:
                      const Color(
                    0xFFE9F2E1,
                  ),
                  borderRadius:
                      BorderRadius
                          .circular(
                    16,
                  ),
                ),
                child: Icon(
                  action.icon,
                  color:
                      const Color(
                    0xFF2F6B3D,
                  ),
                  size: 26,
                ),
              ),
              const SizedBox(
                width: 14,
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment
                          .start,
                  children: [
                    Text(
                      action.title,
                      style:
                          const TextStyle(
                        color:
                            Color(
                          0xFF1D2C21,
                        ),
                        fontSize:
                            16,
                        fontWeight:
                            FontWeight
                                .w700,
                      ),
                    ),
                    const SizedBox(
                      height: 4,
                    ),
                    Text(
                      action.subtitle,
                      style:
                          const TextStyle(
                        color:
                            Color(
                          0xFF68756B,
                        ),
                        fontSize:
                            12,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Directionality.of(
                          context,
                        ) ==
                        TextDirection
                            .rtl
                    ? Icons
                        .chevron_left_rounded
                    : Icons
                        .chevron_right_rounded,
                size: 22,
                color:
                    const Color(
                  0xFF94A096,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ManagementCard
    extends StatelessWidget {
  final _ActionInfo item;

  const _ManagementCard({
    required this.item,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    return Material(
      color:
          Colors.transparent,
      borderRadius:
          BorderRadius.circular(
        18,
      ),
      child: InkWell(
        onTap:
            item.onTap,
        borderRadius:
            BorderRadius.circular(
          18,
        ),
        child: Container(
          padding:
              const EdgeInsets.all(
            18,
          ),
          decoration:
              BoxDecoration(
            color:
                Colors.white,
            borderRadius:
                BorderRadius
                    .circular(
              18,
            ),
            border:
                Border.all(
              color:
                  const Color(
                0xFFDDE6D8,
              ),
            ),
          ),
          child: Row(
            children: [
              Icon(
                item.icon,
                color:
                    const Color(
                  0xFF2F6B3D,
                ),
                size: 25,
              ),
              const SizedBox(
                width: 14,
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment
                          .start,
                  children: [
                    Text(
                      item.title,
                      style:
                          const TextStyle(
                        color:
                            Color(
                          0xFF1D2C21,
                        ),
                        fontWeight:
                            FontWeight
                                .w700,
                        fontSize:
                            15,
                      ),
                    ),
                    const SizedBox(
                      height: 3,
                    ),
                    Text(
                      item.subtitle,
                      style:
                          const TextStyle(
                        color:
                            Color(
                          0xFF68756B,
                        ),
                        fontSize:
                            12,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Directionality.of(
                          context,
                        ) ==
                        TextDirection
                            .rtl
                    ? Icons
                        .chevron_left_rounded
                    : Icons
                        .chevron_right_rounded,
                color:
                    const Color(
                  0xFF94A096,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SupplierDashboardBackdrop
    extends StatelessWidget {
  const _SupplierDashboardBackdrop();

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
              ),
            ),
          ),
          PositionedDirectional(
            end: -180,
            top: 180,
            child: Container(
              width: 460,
              height: 460,
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
                      alpha: 0.34,
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
        ],
      ),
    );
  }
}