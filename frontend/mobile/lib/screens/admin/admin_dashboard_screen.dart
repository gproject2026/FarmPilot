import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../l10n/generated/app_localizations.dart';
import '../../providers/auth_provider.dart';
import '../../providers/dashboard_provider.dart';
import '../../providers/locale_provider.dart';
import 'admin_categories_screen.dart';
import 'admin_orders_screen.dart';
import 'admin_products_screen.dart';
import 'admin_users_screen.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({
    super.key,
  });

  @override
  State<AdminDashboardScreen> createState() =>
      _AdminDashboardScreenState();
}

class _AdminDashboardScreenState
    extends State<AdminDashboardScreen> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback(
      (_) {
        _loadDashboard();
      },
    );
  }

  Future<void> _loadDashboard() async {
    try {
      await Provider.of<DashboardProvider>(
        context,
        listen: false,
      ).loadAdminDashboard();
    } catch (_) {}
  }

  void _openManageUsers() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) =>
            const AdminUsersScreen(),
      ),
    );
  }

  void _openManageOrders() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) =>
            const AdminOrdersScreen(),
      ),
    );
  }

  void _openManageProducts() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) =>
            const AdminProductsScreen(),
      ),
    );
  }

  void _openManageCategories() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) =>
            const AdminCategoriesScreen(),
      ),
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

  void _logout() {
    final authProvider =
        Provider.of<AuthProvider>(
      context,
      listen: false,
    );

    final dashboardProvider =
        Provider.of<DashboardProvider>(
      context,
      listen: false,
    );

    dashboardProvider.clearDashboard();
    authProvider.logout();

    Navigator.of(context)
        .pushNamedAndRemoveUntil(
      '/',
      (route) => false,
    );
  }

  @override
  Widget build(
    BuildContext context,
  ) {
    final dashboardProvider =
        Provider.of<DashboardProvider>(
      context,
    );

    final localeProvider =
        Provider.of<LocaleProvider>(
      context,
    );

    final l10n =
        AppLocalizations.of(context)!;

    final data =
        dashboardProvider.dashboardData;

    final isArabic =
        localeProvider.locale.languageCode ==
            'ar';

    return Scaffold(
      backgroundColor:
          const Color(0xFFF8FAF4),
      body: Stack(
        children: [
          const Positioned.fill(
            child: _AdminBackdrop(),
          ),
          Column(
            children: [
              _AdminTopBar(
                isArabic: isArabic,
                l10n: l10n,
                isLoading:
                    dashboardProvider.isLoading,
                onChangeLanguage:
                    _changeLanguage,
                onRefresh:
                    dashboardProvider.isLoading
                        ? null
                        : _loadDashboard,
                onLogout: _logout,
              ),
              Expanded(
                child:
                    dashboardProvider.isLoading &&
                            data == null
                        ? const Center(
                            child:
                                CircularProgressIndicator(
                              color:
                                  _adminPrimary,
                            ),
                          )
                        : data == null
                            ? _buildErrorState(
                                dashboardProvider,
                                l10n,
                              )
                            : _buildDashboard(
                                data,
                                l10n,
                              ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(
    DashboardProvider dashboardProvider,
    AppLocalizations l10n,
  ) {
    return RefreshIndicator(
      onRefresh: _loadDashboard,
      color: _adminPrimary,
      child: ListView(
        physics:
            const AlwaysScrollableScrollPhysics(),
        padding:
            const EdgeInsets.all(24),
        children: [
          const SizedBox(height: 120),
          Center(
            child: Container(
              constraints:
                  const BoxConstraints(
                maxWidth: 460,
              ),
              padding:
                  const EdgeInsets.all(30),
              decoration:
                  _adminCardDecoration(24),
              child: Column(
                mainAxisSize:
                    MainAxisSize.min,
                children: [
                  Container(
                    width: 82,
                    height: 82,
                    decoration:
                        const BoxDecoration(
                      color: _adminLight,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons
                          .admin_panel_settings_outlined,
                      size: 38,
                      color:
                          _adminPrimary,
                    ),
                  ),
                  const SizedBox(
                    height: 18,
                  ),
                  Text(
                    dashboardProvider
                            .errorMessage ??
                        l10n
                            .unableToLoadAdminDashboard,
                    textAlign:
                        TextAlign.center,
                    style:
                        const TextStyle(
                      color: _adminText,
                      fontSize: 16,
                      fontWeight:
                          FontWeight.w600,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(
                    height: 18,
                  ),
                  ElevatedButton.icon(
                    onPressed:
                        _loadDashboard,
                    style:
                        ElevatedButton.styleFrom(
                      backgroundColor:
                          _adminPrimary,
                      foregroundColor:
                          Colors.white,
                      elevation: 0,
                      padding:
                          const EdgeInsets
                              .symmetric(
                        horizontal: 18,
                        vertical: 14,
                      ),
                      shape:
                          RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(
                          14,
                        ),
                      ),
                    ),
                    icon: const Icon(
                      Icons.refresh_rounded,
                    ),
                    label: Text(
                      l10n.tryAgain,
                      style:
                          const TextStyle(
                        fontWeight:
                            FontWeight.w700,
                      ),
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

  Widget _buildDashboard(
    Map<String, dynamic> data,
    AppLocalizations l10n,
  ) {
    return RefreshIndicator(
      onRefresh: _loadDashboard,
      color: _adminPrimary,
      child: LayoutBuilder(
        builder: (
          context,
          constraints,
        ) {
          final width =
              constraints.maxWidth;

          final statColumns = width >= 1100
              ? 3
              : width >= 720
                  ? 2
                  : 1;

          final toolColumns = width >= 900
              ? 2
              : 1;

          return SingleChildScrollView(
            physics:
                const AlwaysScrollableScrollPhysics(),
            padding:
                EdgeInsets.fromLTRB(
              width < 650 ? 16 : 24,
              24,
              width < 650 ? 16 : 24,
              42,
            ),
            child: Center(
              child: ConstrainedBox(
                constraints:
                    const BoxConstraints(
                  maxWidth: 1320,
                ),
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    _AdminHero(
                      l10n: l10n,
                    ),
                    const SizedBox(height: 20),
                    GridView.count(
                      crossAxisCount:
                          statColumns,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio:
                          statColumns == 1
                              ? 3.2
                              : 2.15,
                      shrinkWrap: true,
                      physics:
                          const NeverScrollableScrollPhysics(),
                      children: [
                        _statCard(
                          title:
                              l10n.totalUsers,
                          value: _value(
                            data['totalUsers'],
                          ),
                          icon:
                              Icons.people_alt_outlined,
                        ),
                        _statCard(
                          title:
                              l10n.farmers,
                          value: _value(
                            data['totalFarmers'],
                          ),
                          icon:
                              Icons.agriculture_outlined,
                        ),
                        _statCard(
                          title:
                              l10n.customers,
                          value: _value(
                            data['totalCustomers'],
                          ),
                          icon:
                              Icons.person_outline_rounded,
                        ),
                        _statCard(
                          title:
                              l10n.products,
                          value: _value(
                            data['totalProducts'],
                          ),
                          icon:
                              Icons.inventory_2_outlined,
                        ),
                        _statCard(
                          title:
                              l10n.orders,
                          value: _value(
                            data['totalOrders'],
                          ),
                          icon:
                              Icons.receipt_long_outlined,
                        ),
                        _statCard(
                          title:
                              l10n.diagnoses,
                          value: _value(
                            data['totalDiagnoses'],
                          ),
                          icon: Icons
                              .health_and_safety_outlined,
                        ),
                      ],
                    ),
                    const SizedBox(height: 28),
                    Row(
                      children: [
                        Container(
                          width: 6,
                          height: 28,
                          decoration:
                              BoxDecoration(
                            color:
                                _adminPrimary,
                            borderRadius:
                                BorderRadius.circular(
                              10,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          l10n.adminTools,
                          style:
                              const TextStyle(
                            color:
                                _adminText,
                            fontSize: 22,
                            fontWeight:
                                FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    GridView.count(
                      crossAxisCount:
                          toolColumns,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio:
                          toolColumns == 1
                              ? 3.4
                              : 2.7,
                      shrinkWrap: true,
                      physics:
                          const NeverScrollableScrollPhysics(),
                      children: [
                        _adminToolCard(
                          icon: Icons
                              .manage_accounts_outlined,
                          title:
                              l10n.manageUsers,
                          subtitle:
                              Localizations.localeOf(context).languageCode == 'ar'
                                  ? 'عرض وإدارة مستخدمي النظام وأدوارهم.'
                                  : 'View and manage system users and roles.',
                          onPressed:
                              _openManageUsers,
                        ),
                        _adminToolCard(
                          icon: Icons
                              .receipt_long_outlined,
                          title:
                              l10n.manageOrders,
                          subtitle:
                              Localizations.localeOf(context).languageCode == 'ar'
                                  ? 'مراجعة الطلبات ومتابعة حالتها.'
                                  : 'Review orders and track their status.',
                          onPressed:
                              _openManageOrders,
                        ),
                        _adminToolCard(
                          icon: Icons
                              .inventory_2_outlined,
                          title:
                              l10n.manageProducts,
                          subtitle:
                              Localizations.localeOf(context).languageCode == 'ar'
                                  ? 'مراجعة منتجات المتجر ومدى توفرها.'
                                  : 'Review marketplace products and availability.',
                          onPressed:
                              _openManageProducts,
                        ),
                        _adminToolCard(
                          icon: Icons
                              .category_outlined,
                          title:
                              l10n.manageCategories,
                          subtitle:
                              Localizations.localeOf(context).languageCode == 'ar'
                                  ? 'تنظيم تصنيفات منتجات المتجر.'
                                  : 'Organize marketplace product categories.',
                          onPressed:
                              _openManageCategories,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _adminToolCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onPressed,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius:
            BorderRadius.circular(22),
        child: Ink(
          padding:
              const EdgeInsets.all(18),
          decoration:
              _adminCardDecoration(22),
          child: Row(
            children: [
              Container(
                width: 54,
                height: 54,
                decoration:
                    BoxDecoration(
                  color: _adminLight,
                  borderRadius:
                      BorderRadius.circular(
                    15,
                  ),
                ),
                child: Icon(
                  icon,
                  color:
                      _adminPrimary,
                  size: 27,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  mainAxisAlignment:
                      MainAxisAlignment.center,
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow:
                          TextOverflow.ellipsis,
                      style:
                          const TextStyle(
                        color: _adminText,
                        fontSize: 16,
                        fontWeight:
                            FontWeight.w800,
                      ),
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                    Text(
                      subtitle,
                      maxLines: 2,
                      overflow:
                          TextOverflow.ellipsis,
                      style:
                          const TextStyle(
                        color:
                            _adminMuted,
                        fontSize: 12,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              const Icon(
                Icons
                    .arrow_forward_ios_rounded,
                size: 15,
                color: _adminMuted,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _statCard({
    required String title,
    required String value,
    required IconData icon,
  }) {
    return Container(
      padding:
          const EdgeInsets.symmetric(
        horizontal: 18,
        vertical: 16,
      ),
      decoration:
          _adminCardDecoration(22),
      child: Row(
        children: [
          Container(
            width: 54,
            height: 54,
            decoration:
                BoxDecoration(
              color: _adminLight,
              borderRadius:
                  BorderRadius.circular(
                15,
              ),
            ),
            child: Icon(
              icon,
              color:
                  _adminPrimary,
              size: 27,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              mainAxisAlignment:
                  MainAxisAlignment.center,
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  maxLines: 1,
                  overflow:
                      TextOverflow.ellipsis,
                  style:
                      const TextStyle(
                    color: _adminText,
                    fontSize: 27,
                    fontWeight:
                        FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  title,
                  maxLines: 1,
                  overflow:
                      TextOverflow.ellipsis,
                  style:
                      const TextStyle(
                    color: _adminMuted,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _value(
    dynamic value,
  ) {
    return value?.toString() ?? '0';
  }
}

const _adminDark =
    Color(0xFF173F24);
const _adminPrimary =
    Color(0xFF2F743F);
const _adminLight =
    Color(0xFFEAF3DF);
const _adminText =
    Color(0xFF1D2C21);
const _adminMuted =
    Color(0xFF6C786E);

class _AdminTopBar
    extends StatelessWidget {
  final bool isArabic;
  final AppLocalizations l10n;
  final bool isLoading;
  final ValueChanged<String>
      onChangeLanguage;
  final Future<void> Function()?
      onRefresh;
  final VoidCallback onLogout;

  const _AdminTopBar({
    required this.isArabic,
    required this.l10n,
    required this.isLoading,
    required this.onChangeLanguage,
    required this.onRefresh,
    required this.onLogout,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
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
                Icons.eco_rounded,
                color:
                    _adminDark,
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
                      fontSize:
                          19,
                      fontWeight:
                          FontWeight.w800,
                    ),
                  ),
                  Text(
                    l10n.adminDashboard,
                    style:
                        const TextStyle(
                      color: Color(
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
              color: Colors.white,
              onSelected:
                  onChangeLanguage,
              icon:
                  const Icon(
                Icons.language_rounded,
                color:
                    Colors.white,
              ),
              itemBuilder:
                  (context) {
                return [
                  PopupMenuItem<String>(
                    value: 'en',
                    child: Row(
                      children: [
                        Icon(
                          Icons.check_rounded,
                          color: !isArabic
                              ? _adminPrimary
                              : Colors
                                  .transparent,
                        ),
                        const SizedBox(
                          width: 8,
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
                      children: [
                        Icon(
                          Icons.check_rounded,
                          color: isArabic
                              ? _adminPrimary
                              : Colors
                                  .transparent,
                        ),
                        const SizedBox(
                          width: 8,
                        ),
                        Text(
                          l10n.arabic,
                        ),
                      ],
                    ),
                  ),
                ];
              },
            ),
            _AdminHeaderButton(
              icon:
                  Icons.refresh_rounded,
              tooltip:
                  l10n.refresh,
              onTap:
                  onRefresh,
            ),
            const SizedBox(width: 4),
            _AdminHeaderButton(
              icon:
                  Icons.logout_rounded,
              tooltip:
                  l10n.logout,
              onTap:
                  onLogout,
            ),
          ],
        ),
      ),
    );
  }
}

class _AdminHeaderButton
    extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback? onTap;

  const _AdminHeaderButton({
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

class _AdminHero
    extends StatelessWidget {
  final AppLocalizations l10n;

  const _AdminHero({
    required this.l10n,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    return Container(
      width:
          double.infinity,
      padding:
          const EdgeInsets.all(
        24,
      ),
      decoration:
          _adminCardDecoration(
        24,
      ),
      child: Row(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration:
                BoxDecoration(
              color:
                  _adminLight,
              borderRadius:
                  BorderRadius.circular(
                18,
              ),
            ),
            child:
                const Icon(
              Icons
                  .admin_panel_settings_outlined,
              size: 32,
              color:
                  _adminPrimary,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.welcomeAdmin,
                  style:
                      const TextStyle(
                    color:
                        _adminText,
                    fontSize: 24,
                    fontWeight:
                        FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  l10n
                      .systemOverviewStatistics,
                  style:
                      const TextStyle(
                    color:
                        _adminMuted,
                    fontSize: 13,
                    height: 1.4,
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

class _AdminBackdrop
    extends StatelessWidget {
  const _AdminBackdrop();

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
                _AdminGlow(
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
                _AdminGlow(
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

class _AdminGlow
    extends StatelessWidget {
  final double size;
  final Color color;

  const _AdminGlow({
    required this.size,
    required this.color,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
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
              alpha: 0.25,
            ),
            color.withValues(
              alpha: 0,
            ),
          ],
        ),
      ),
    );
  }
}

BoxDecoration
    _adminCardDecoration(
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
            _adminDark
                .withValues(
          alpha: 0.05,
        ),
        blurRadius: 20,
        offset:
            const Offset(
          0,
          7,
        ),
      ),
    ],
  );
}
