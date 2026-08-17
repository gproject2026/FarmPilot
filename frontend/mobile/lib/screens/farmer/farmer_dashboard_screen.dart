import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../l10n/generated/app_localizations.dart';
import '../../providers/auth_provider.dart';
import '../../providers/dashboard_provider.dart';
import '../../providers/locale_provider.dart';
import '../../providers/notification_provider.dart';
import '../notifications_screen.dart';
import 'diagnose_plant_screen.dart';
import 'diagnosis_history_screen.dart';
import 'farmer_orders_screen.dart';
import 'my_crops_screen.dart';
import 'my_products_screen.dart';
import 'profile_screen.dart';
import 'reminders_screen.dart';

class FarmerDashboardScreen extends StatefulWidget {
  const FarmerDashboardScreen({
    super.key,
  });

  @override
  State<FarmerDashboardScreen> createState() =>
      _FarmerDashboardScreenState();
}

class _FarmerDashboardScreenState
    extends State<FarmerDashboardScreen> {
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
    await Future.wait([
      Provider.of<DashboardProvider>(
        context,
        listen: false,
      ).loadFarmerDashboard(),
      Provider.of<NotificationProvider>(
        context,
        listen: false,
      ).loadNotifications(),
    ]);
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
    final dashboardProvider =
        Provider.of<DashboardProvider>(
      context,
    );

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

    if (dashboardProvider.isLoading &&
        dashboardProvider.dashboardData ==
            null) {
      return const Scaffold(
        backgroundColor: _background,
        body: Center(
          child: CircularProgressIndicator(
            color: _primaryGreen,
          ),
        ),
      );
    }

    if (dashboardProvider.dashboardData ==
        null) {
      return Scaffold(
        backgroundColor: _background,
        body: RefreshIndicator(
          onRefresh: _loadData,
          child: ListView(
            physics:
                const AlwaysScrollableScrollPhysics(),
            children: [
              const SizedBox(
                height: 250,
              ),
              Center(
                child: Text(
                  l10n.noData,
                ),
              ),
            ],
          ),
        ),
      );
    }

    final dashboardData =
        dashboardProvider.dashboardData!;

    final productsCount =
        dashboardData['productsCount']
            ?.toString() ??
        '0';

    final cropsCount =
        dashboardData['cropsCount']
            ?.toString() ??
        '0';

    final diagnosesCount =
        dashboardData['diagnosesCount']
            ?.toString() ??
        '0';

    final ordersCount =
        dashboardData['ordersCount']
            ?.toString() ??
        '0';

    final totalSales =
        dashboardData['totalSales']
            ?.toString() ??
        '0';

    return Scaffold(
      backgroundColor:
          _background,
      body: Stack(
        children: [
          const Positioned.fill(
            child: _DashboardBackdrop(),
          ),
          RefreshIndicator(
            onRefresh:
                _loadData,
            color:
                _primaryGreen,
            child:
                CustomScrollView(
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
                          constraints.maxWidth >=
                              1000;

                      return Padding(
                        padding:
                            EdgeInsets.fromLTRB(
                          isWide ? 42 : 18,
                          isWide ? 30 : 20,
                          isWide ? 42 : 18,
                          52,
                        ),
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            _buildWelcomeSection(
                              l10n,
                            ),
                            const SizedBox(
                              height: 24,
                            ),
                            _buildStatsGrid(
                              isWide:
                                  isWide,
                              productsCount:
                                  productsCount,
                              cropsCount:
                                  cropsCount,
                              diagnosesCount:
                                  diagnosesCount,
                              ordersCount:
                                  ordersCount,
                              totalSales:
                                  totalSales,
                              l10n:
                                  l10n,
                            ),
                            const SizedBox(
                              height: 38,
                            ),
                            _buildSectionTitle(
                              l10n.quickActions,
                              l10n.quickActionsSubtitle,
                            ),
                            const SizedBox(
                              height: 17,
                            ),
                            _buildQuickActions(
                              isWide:
                                  isWide,
                              l10n:
                                  l10n,
                              dashboardProvider:
                                  dashboardProvider,
                              notificationProvider:
                                  notificationProvider,
                            ),
                            const SizedBox(
                              height: 38,
                            ),
                            _buildSectionTitle(
                              l10n.farmManagement,
                              l10n.farmManagementSubtitle,
                            ),
                            const SizedBox(
                              height: 17,
                            ),
                            _buildManagementCards(
                              isWide:
                                  isWide,
                              l10n:
                                  l10n,
                              dashboardProvider:
                                  dashboardProvider,
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
            color: _darkGreen.withValues(
              alpha: 0.18,
            ),
            blurRadius: 24,
            offset: const Offset(
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
                    BorderRadius.circular(
                  14,
                ),
              ),
              child:
                  const Icon(
                Icons.eco_rounded,
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
                    TextStyle(
                  color:
                      Colors.white,
                  fontSize:
                      22,
                  fontWeight:
                      FontWeight.w800,
                ),
              ),
            ),
            _HeaderIconButton(
              icon:
                  Icons.language_rounded,
              onTap: () {
                _showLanguageMenu(
                  isArabic:
                      isArabic,
                  l10n:
                      l10n,
                );
              },
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
                    right:
                        -4,
                    top:
                        -4,
                    child:
                        Container(
                      constraints:
                          const BoxConstraints(
                        minWidth:
                            18,
                        minHeight:
                            18,
                      ),
                      padding:
                          const EdgeInsets.symmetric(
                        horizontal:
                            4,
                      ),
                      decoration:
                          BoxDecoration(
                        color:
                            const Color(
                          0xFFE35D5D,
                        ),
                        borderRadius:
                            BorderRadius.circular(
                          12,
                        ),
                        border:
                            Border.all(
                          color:
                              Colors.white,
                          width:
                              1.5,
                        ),
                      ),
                      alignment:
                          Alignment.center,
                      child:
                          Text(
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
                          fontSize:
                              9,
                          fontWeight:
                              FontWeight.bold,
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
      width: double.infinity,
      constraints: const BoxConstraints(
        minHeight: 150,
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: 28,
        vertical: 28,
      ),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: AlignmentDirectional.centerStart,
          end: AlignmentDirectional.centerEnd,
          colors: [
            Color(0xFFFFFFFF),
            Color(0xFFFFFEFA),
            Color(0xFFF6F9F0),
          ],
        ),
        borderRadius: BorderRadius.circular(
          28,
        ),
        border: Border.all(
          color: const Color(
            0xFFDDE7D8,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: _darkGreen.withValues(
              alpha: 0.055,
            ),
            blurRadius: 24,
            offset: const Offset(
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
            decoration: BoxDecoration(
              color: const Color(
                0xFFEAF3DF,
              ),
              borderRadius: BorderRadius.circular(
                20,
              ),
            ),
            child: const Icon(
              Icons.agriculture_rounded,
              color: _primaryGreen,
              size: 34,
            ),
          ),
          const SizedBox(
            width: 24,
          ),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment:
                  CrossAxisAlignment.end,
              children: [
                Text(
                  l10n.welcomeFarmer,
                  textAlign: TextAlign.end,
                  style: const TextStyle(
                    color: _textPrimary,
                    fontSize: 31,
                    fontWeight:
                        FontWeight.w800,
                    letterSpacing: -0.8,
                  ),
                ),
                const SizedBox(
                  height: 8,
                ),
                Text(
                  l10n.farmerWelcomeSubtitle,
                  textAlign: TextAlign.end,
                  style: const TextStyle(
                    color: _textSecondary,
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

  Widget _buildStatsGrid({
    required bool isWide,
    required String productsCount,
    required String cropsCount,
    required String diagnosesCount,
    required String ordersCount,
    required String totalSales,
    required AppLocalizations l10n,
  }) {
    final stats = [
      _StatInfo(
        title:
            l10n.products,
        value:
            productsCount,
        icon:
            Icons.inventory_2_outlined,
        background:
            const Color(
          0xFFE9F3E8,
        ),
        foreground:
            const Color(
          0xFF3D7A47,
        ),
      ),
      _StatInfo(
        title:
            l10n.crops,
        value:
            cropsCount,
        icon:
            Icons.eco_outlined,
        background:
            const Color(
          0xFFF2F1D8,
        ),
        foreground:
            const Color(
          0xFF7A7B35,
        ),
      ),
      _StatInfo(
        title:
            l10n.orders,
        value:
            ordersCount,
        icon:
            Icons.shopping_bag_outlined,
        background:
            const Color(
          0xFFFFEFE0,
        ),
        foreground:
            const Color(
          0xFFB46A2C,
        ),
      ),
      _StatInfo(
        title:
            l10n.aiDiagnoses,
        value:
            diagnosesCount,
        icon:
            Icons.health_and_safety_outlined,
        background:
            const Color(
          0xFFE8EEF7,
        ),
        foreground:
            const Color(
          0xFF52709C,
        ),
      ),
      _StatInfo(
        title:
            l10n.totalSales,
        value:
            '₪ $totalSales',
        icon:
            Icons.payments_outlined,
        background:
            const Color(
          0xFFF1E8F5,
        ),
        foreground:
            const Color(
          0xFF865B93,
        ),
      ),
    ];

    return LayoutBuilder(
      builder: (
        context,
        constraints,
      ) {
        final width =
            constraints.maxWidth;

        final columns =
            isWide
                ? 5
                : width >= 650
                    ? 3
                    : 2;

        final spacing =
            14.0;

        final cardWidth =
            (width -
                    (spacing *
                        (columns - 1))) /
                columns;

        return Wrap(
          spacing:
              spacing,
          runSpacing:
              spacing,
          children:
              stats.map(
            (stat) {
              return SizedBox(
                width:
                    cardWidth,
                child:
                    _StatCard(
                  stat:
                      stat,
                ),
              );
            },
          ).toList(),
        );
      },
    );
  }

  Widget _buildQuickActions({
    required bool isWide,
    required AppLocalizations l10n,
    required DashboardProvider
        dashboardProvider,
    required NotificationProvider
        notificationProvider,
  }) {
    final actions = [
      _ActionInfo(
        title:
            l10n.myProducts,
        subtitle:
            l10n.manageListings,
        icon:
            Icons.inventory_2_outlined,
        onTap: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) =>
                  const MyProductsScreen(),
            ),
          );

          if (!mounted) {
            return;
          }

          await dashboardProvider
              .loadFarmerDashboard();
        },
      ),
      _ActionInfo(
        title:
            l10n.myOrders,
        subtitle:
            l10n.manageCustomerOrders,
        icon:
            Icons.shopping_cart_outlined,
        onTap: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) =>
                  const FarmerOrdersScreen(),
            ),
          );

          if (!mounted) {
            return;
          }

          await Future.wait([
            dashboardProvider
                .loadFarmerDashboard(),
            notificationProvider
                .loadNotifications(),
          ]);
        },
      ),
      _ActionInfo(
        title:
            l10n.myCrops,
        subtitle:
            l10n.trackYourCrops,
        icon:
            Icons.eco_outlined,
        onTap: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) =>
                  const MyCropsScreen(),
            ),
          );

          if (!mounted) {
            return;
          }

          await dashboardProvider
              .loadFarmerDashboard();
        },
      ),
      _ActionInfo(
        title:
            l10n.plantDiagnosis,
        subtitle:
            l10n.aiPoweredDiagnosis,
        icon:
            Icons.local_florist_outlined,
        onTap: () async {
          final currentNotificationProvider =
              Provider.of<
                  NotificationProvider>(
            context,
            listen:
                false,
          );

          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) =>
                  const DiagnosePlantScreen(),
            ),
          );

          if (!mounted) {
            return;
          }

          await Future.wait([
            dashboardProvider
                .loadFarmerDashboard(),
            currentNotificationProvider
                .loadNotifications(),
          ]);
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
                : constraints.maxWidth >=
                        650
                    ? 2
                    : 1;

        final spacing =
            14.0;

        final width =
            (constraints.maxWidth -
                    spacing *
                        (columns - 1)) /
                columns;

        return Wrap(
          spacing:
              spacing,
          runSpacing:
              spacing,
          children:
              actions.map(
            (action) {
              return SizedBox(
                width:
                    width,
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
    required DashboardProvider
        dashboardProvider,
    required NotificationProvider
        notificationProvider,
  }) {
    final items = [
      _ActionInfo(
        title:
            l10n.diagnosisHistory,
        subtitle:
            l10n.reviewPreviousPlantAnalyses,
        icon:
            Icons.history_rounded,
        onTap: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) =>
                  const DiagnosisHistoryScreen(),
            ),
          );

          if (!mounted) {
            return;
          }

          await dashboardProvider
              .loadFarmerDashboard();
        },
      ),
      _ActionInfo(
        title:
            l10n.reminders,
        subtitle:
            l10n.stayOnTopFarmTasks,
        icon:
            Icons.notifications_active_outlined,
        onTap: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) =>
                  const RemindersScreen(),
            ),
          );

          if (!mounted) {
            return;
          }

          await dashboardProvider
              .loadFarmerDashboard();
        },
      ),
      _ActionInfo(
        title:
            notificationProvider.unreadCount >
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
            l10n.myProfile,
        subtitle:
            l10n.manageAccountDetails,
        icon:
            Icons.person_outline_rounded,
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) =>
                  const ProfileScreen(),
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

        final spacing =
            14.0;

        final width =
            (constraints.maxWidth -
                    spacing *
                        (columns - 1)) /
                columns;

        return Wrap(
          spacing:
              spacing,
          runSpacing:
              spacing,
          children:
              items.map(
            (item) {
              return SizedBox(
                width:
                    width,
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
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 7,
              height: 28,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xFF4D8A4B),
                    Color(0xFF9FC65B),
                  ],
                ),
                borderRadius: BorderRadius.circular(
                  10,
                ),
              ),
            ),
            const SizedBox(
              width: 10,
            ),
            Text(
              title,
              style: const TextStyle(
                color: _textPrimary,
                fontSize: 23,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
        const SizedBox(
          height: 6,
        ),
        Padding(
          padding: const EdgeInsetsDirectional.only(
            start: 17,
          ),
          child: Text(
            subtitle,
            style: const TextStyle(
              color: _textSecondary,
              fontSize: 14,
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }

  void _showLanguageMenu({
    required bool isArabic,
    required AppLocalizations l10n,
  }) {
    showModalBottomSheet<void>(
      context:
          context,
      showDragHandle:
          true,
      builder:
          (sheetContext) {
        return SafeArea(
          child: Padding(
            padding:
                const EdgeInsets.all(
              20,
            ),
            child: Column(
              mainAxisSize:
                  MainAxisSize.min,
              children: [
                ListTile(
                  leading:
                      Icon(
                    Icons.check,
                    color: !isArabic
                        ? _primaryGreen
                        : Colors.transparent,
                  ),
                  title:
                      Text(
                    l10n.english,
                  ),
                  onTap: () {
                    Navigator.pop(
                      sheetContext,
                    );
                    _changeLanguage(
                      'en',
                    );
                  },
                ),
                ListTile(
                  leading:
                      Icon(
                    Icons.check,
                    color: isArabic
                        ? _primaryGreen
                        : Colors.transparent,
                  ),
                  title:
                      Text(
                    l10n.arabic,
                  ),
                  onTap: () {
                    Navigator.pop(
                      sheetContext,
                    );
                    _changeLanguage(
                      'ar',
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
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
          width:
              44,
          height:
              44,
          child:
              Icon(
            icon,
            color:
                Colors.white,
            size:
                22,
          ),
        ),
      ),
    );
  }
}

class _StatInfo {
  final String title;
  final String value;
  final IconData icon;
  final Color background;
  final Color foreground;

  const _StatInfo({
    required this.title,
    required this.value,
    required this.icon,
    required this.background,
    required this.foreground,
  });
}

class _StatCard
    extends StatelessWidget {
  final _StatInfo stat;

  const _StatCard({
    required this.stat,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    return Container(
      padding:
          const EdgeInsets.all(
        18,
      ),
      decoration:
          BoxDecoration(
        gradient:
            const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFFFFFFF),
            Color(0xFFFFFEFB),
          ],
        ),
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
            color: const Color(0xFF173F24)
                .withValues(alpha: 0.05),
            blurRadius: 18,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Container(
            width:
                42,
            height:
                42,
            decoration:
                BoxDecoration(
              color:
                  stat.background,
              borderRadius:
                  BorderRadius.circular(
                13,
              ),
            ),
            child:
                Icon(
              stat.icon,
              color:
                  stat.foreground,
              size:
                  22,
            ),
          ),
          const SizedBox(
            height:
                16,
          ),
          Text(
            stat.value,
            maxLines:
                1,
            overflow:
                TextOverflow.ellipsis,
            style:
                const TextStyle(
              color:
                  Color(
                0xFF1D2C21,
              ),
              fontSize:
                  27,
              fontWeight:
                  FontWeight.w800,
            ),
          ),
          const SizedBox(
            height:
                4,
          ),
          Text(
            stat.title,
            maxLines:
                1,
            overflow:
                TextOverflow.ellipsis,
            style:
                const TextStyle(
              color:
                  Color(
                0xFF68756B,
              ),
              fontSize:
                  13,
              fontWeight:
                  FontWeight.w600,
            ),
          ),
        ],
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
            gradient:
                const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFFFFFFFF),
                Color(0xFFFFFEFA),
              ],
            ),
            borderRadius:
                BorderRadius.circular(
              20,
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
                color: const Color(0xFF173F24)
                    .withValues(alpha: 0.05),
                blurRadius: 18,
                offset: const Offset(0, 7),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width:
                    52,
                height:
                    52,
                decoration:
                    BoxDecoration(
                  color:
                      const Color(
                    0xFFE9F2E1,
                  ),
                  borderRadius:
                      BorderRadius.circular(
                    16,
                  ),
                ),
                child:
                    Icon(
                  action.icon,
                  color:
                      const Color(
                    0xFF2F6B3D,
                  ),
                  size:
                      26,
                ),
              ),
              const SizedBox(
                width:
                    14,
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
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
                            FontWeight.w700,
                      ),
                    ),
                    const SizedBox(
                      height:
                          4,
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
                Directionality.of(context) ==
                        TextDirection.rtl
                    ? Icons.chevron_left_rounded
                    : Icons.chevron_right_rounded,
                size: 22,
                color: const Color(0xFF94A096),
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
            gradient:
                const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFFFFFFFF),
                Color(0xFFFFFEFA),
              ],
            ),
            borderRadius:
                BorderRadius.circular(
              18,
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
                color: const Color(0xFF173F24)
                    .withValues(alpha: 0.045),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            children: [
              Icon(
                item.icon,
                color:
                    const Color(
                  0xFF2F6B3D,
                ),
                size:
                    25,
              ),
              const SizedBox(
                width:
                    14,
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
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
                            FontWeight.w700,
                        fontSize:
                            15,
                      ),
                    ),
                    const SizedBox(
                      height:
                          3,
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
                Directionality.of(context) ==
                        TextDirection.rtl
                    ? Icons.chevron_left_rounded
                    : Icons.chevron_right_rounded,
                color: const Color(0xFF94A096),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DashboardBackdrop extends StatelessWidget {
  const _DashboardBackdrop();

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Stack(
        fit: StackFit.expand,
        children: [
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFFF8FAF4),
                  Color(0xFFFFFCF5),
                  Color(0xFFF4F8ED),
                ],
                stops: [
                  0.0,
                  0.48,
                  1.0,
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
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFFCFE6B4)
                        .withValues(alpha: 0.34),
                    const Color(0xFFCFE6B4)
                        .withValues(alpha: 0.0),
                  ],
                ),
              ),
            ),
          ),
          PositionedDirectional(
            start: -190,
            bottom: -210,
            child: Container(
              width: 520,
              height: 520,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFFE7DFAF)
                        .withValues(alpha: 0.26),
                    const Color(0xFFE7DFAF)
                        .withValues(alpha: 0.0),
                  ],
                ),
              ),
            ),
          ),
          PositionedDirectional(
            start: -45,
            bottom: -28,
            child: Opacity(
              opacity: 0.035,
              child: Icon(
                Icons.eco_rounded,
                size: 280,
                color: const Color(0xFF2F6B3D),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
