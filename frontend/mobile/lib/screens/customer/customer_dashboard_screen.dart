import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../l10n/generated/app_localizations.dart';
import '../../providers/auth_provider.dart';
import '../../providers/favorite_provider.dart';
import '../../providers/locale_provider.dart';
import '../../providers/notification_provider.dart';
import '../farmer/profile_screen.dart';
import '../notifications_screen.dart';
import 'customer_cart_screen.dart';
import 'customer_favorites_screen.dart';
import 'customer_orders_screen.dart';
import 'customer_products_screen.dart';

class CustomerDashboardScreen extends StatefulWidget {
  const CustomerDashboardScreen({
    super.key,
  });

  @override
  State<CustomerDashboardScreen> createState() =>
      _CustomerDashboardScreenState();
}

class _CustomerDashboardScreenState
    extends State<CustomerDashboardScreen> {
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
        _loadNotifications();
      },
    );
  }

  Future<void> _loadNotifications() async {
    try {
      await Provider.of<NotificationProvider>(
        context,
        listen: false,
      ).loadNotifications();
    } catch (e) {
      debugPrint(
        'LOAD NOTIFICATIONS ERROR: $e',
      );
    }
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

    final favoriteProvider =
        Provider.of<FavoriteProvider>(
      context,
      listen: false,
    );

    final notificationProvider =
        Provider.of<NotificationProvider>(
      context,
      listen: false,
    );

    favoriteProvider.clearFavorites();

    notificationProvider
        .clearNotifications();

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
    final authProvider =
        Provider.of<AuthProvider>(
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

    final userName =
        authProvider.userData?['fullName']
                ?.toString() ??
            l10n.customer;

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
            child: _CustomerBackdrop(),
          ),
          RefreshIndicator(
            onRefresh:
                _loadNotifications,
            color:
                _primaryGreen,
            child:
                CustomScrollView(
              physics:
                  const AlwaysScrollableScrollPhysics(),
              slivers: [
                SliverToBoxAdapter(
                  child: _buildHeader(
                    l10n:
                        l10n,
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
                              CrossAxisAlignment.start,
                          children: [
                            _buildWelcomeCard(
                              l10n:
                                  l10n,
                              userName:
                                  userName,
                            ),
                            const SizedBox(
                              height:
                                  26,
                            ),
                            _buildMarketplaceCard(
                              l10n:
                                  l10n,
                            ),
                            const SizedBox(
                              height:
                                  34,
                            ),
                            _buildSectionTitle(
                              l10n
                                  .customerDashboard,
                              l10n
                                  .customerDashboardSubtitle,
                            ),
                            const SizedBox(
                              height:
                                  16,
                            ),
                            _buildActionGrid(
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
              alpha:
                  0.18,
            ),
            blurRadius:
                24,
            offset:
                const Offset(
              0,
              8,
            ),
          ),
        ],
      ),
      child: SafeArea(
        bottom:
            false,
        child: Row(
          children: [
            Container(
              width:
                  46,
              height:
                  46,
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
                size:
                    25,
              ),
            ),
            const SizedBox(
              width:
                  12,
            ),
            Expanded(
              child: Text(
                l10n.appName,
                style:
                    const TextStyle(
                  color:
                      Colors.white,
                  fontSize:
                      22,
                  fontWeight:
                      FontWeight.w800,
                ),
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
              onSelected: (languageCode) {
                _changeLanguage(languageCode);
              },
              itemBuilder: (context) => [
                PopupMenuItem<String>(
                  value: 'en',
                  child: Row(
                    children: [
                      if (!isArabic) ...[
                        const Icon(
                          Icons.check_rounded,
                          color: _primaryGreen,
                          size: 20,
                        ),
                        const SizedBox(width: 10),
                      ],
                      Text(l10n.english),
                    ],
                  ),
                ),
                PopupMenuItem<String>(
                  value: 'ar',
                  child: Row(
                    children: [
                      if (isArabic) ...[
                        const Icon(
                          Icons.check_rounded,
                          color: _primaryGreen,
                          size: 20,
                        ),
                        const SizedBox(width: 10),
                      ],
                      Text(l10n.arabic),
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
                  size: 22,
                ),
              ),
            ),
            const SizedBox(
              width:
                  10,
            ),
            Stack(
              clipBehavior:
                  Clip.none,
              children: [
                _HeaderIconButton(
                  icon:
                      Icons.notifications_none_rounded,
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
              width:
                  10,
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

  Widget _buildWelcomeCard({
    required AppLocalizations l10n,
    required String userName,
  }) {
    return Container(
      width:
          double.infinity,
      padding:
          const EdgeInsets.symmetric(
        horizontal:
            28,
        vertical:
            28,
      ),
      decoration:
          BoxDecoration(
        gradient:
            const LinearGradient(
          begin:
              AlignmentDirectional.centerStart,
          end:
              AlignmentDirectional.centerEnd,
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
              alpha:
                  0.055,
            ),
            blurRadius:
                24,
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
            width:
                64,
            height:
                64,
            decoration:
                BoxDecoration(
              color:
                  const Color(
                0xFFEAF3DF,
              ),
              borderRadius:
                  BorderRadius.circular(
                20,
              ),
            ),
            child:
                const Icon(
              Icons
                  .shopping_basket_outlined,
              color:
                  _primaryGreen,
              size:
                  32,
            ),
          ),
          const SizedBox(
            width:
                24,
          ),
          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.welcomeCustomer(
                    userName,
                  ),
                  style:
                      const TextStyle(
                    color:
                        _textPrimary,
                    fontSize:
                        30,
                    fontWeight:
                        FontWeight.w800,
                    letterSpacing:
                        -0.7,
                  ),
                ),
                const SizedBox(
                  height:
                      8,
                ),
                Text(
                  l10n
                      .customerDashboardSubtitle,
                  style:
                      const TextStyle(
                    color:
                        _textSecondary,
                    fontSize:
                        15,
                    height:
                        1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMarketplaceCard({
    required AppLocalizations l10n,
  }) {
    return Material(
      color:
          Colors.transparent,
      borderRadius:
          BorderRadius.circular(
        26,
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) =>
                  const CustomerProductsScreen(),
            ),
          );
        },
        borderRadius:
            BorderRadius.circular(
          26,
        ),
        child: Container(
          width:
              double.infinity,
          padding:
              const EdgeInsets.all(
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
                Color(0xFF245D35),
                Color(0xFF3A7A49),
              ],
            ),
            borderRadius:
                BorderRadius.circular(
              26,
            ),
            boxShadow: [
              BoxShadow(
                color:
                    _primaryGreen.withValues(
                  alpha:
                      0.18,
                ),
                blurRadius:
                    24,
                offset:
                    const Offset(
                  0,
                  10,
                ),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width:
                    62,
                height:
                    62,
                decoration:
                    BoxDecoration(
                  color:
                      Colors.white.withValues(
                    alpha:
                        0.12,
                  ),
                  borderRadius:
                      BorderRadius.circular(
                    18,
                  ),
                ),
                child:
                    const Icon(
                  Icons
                      .storefront_outlined,
                  color:
                      Colors.white,
                  size:
                      30,
                ),
              ),
              const SizedBox(
                width:
                    18,
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.browseMarketplace,
                      style:
                          const TextStyle(
                        color:
                            Colors.white,
                        fontSize:
                            20,
                        fontWeight:
                            FontWeight.w800,
                      ),
                    ),
                    const SizedBox(
                      height:
                          5,
                    ),
                    Text(
                      l10n.marketplaceSubtitle,
                      style:
                          TextStyle(
                        color:
                            Colors.white.withValues(
                          alpha:
                              0.82,
                        ),
                        fontSize:
                            13,
                        height:
                            1.45,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Directionality.of(context) ==
                        TextDirection.rtl
                    ? Icons
                        .chevron_left_rounded
                    : Icons
                        .chevron_right_rounded,
                color:
                    Colors.white,
                size:
                    28,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionGrid({
    required bool isWide,
    required AppLocalizations l10n,
    required NotificationProvider
        notificationProvider,
  }) {
    final actions = [
      _CustomerActionInfo(
        title:
            l10n.myOrders,
        subtitle:
            l10n.myOrdersSubtitle,
        icon:
            Icons.shopping_bag_outlined,
        iconBackground:
            const Color(
          0xFFFFEFE0,
        ),
        iconColor:
            const Color(
          0xFFB46A2C,
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) =>
                  const CustomerOrdersScreen(),
            ),
          );
        },
      ),
      _CustomerActionInfo(
        title:
            l10n.marketplace,
        subtitle:
            l10n.marketplaceSubtitle,
        icon:
            Icons.storefront_outlined,
        iconBackground:
            const Color(
          0xFFE9F3E8,
        ),
        iconColor:
            const Color(
          0xFF3D7A47,
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) =>
                  const CustomerProductsScreen(),
            ),
          );
        },
      ),
      _CustomerActionInfo(
        title:
            l10n.myFavorites,
        subtitle:
            l10n.myFavoritesSubtitle,
        icon:
            Icons.favorite_outline_rounded,
        iconBackground:
            const Color(
          0xFFF8E8EC,
        ),
        iconColor:
            const Color(
          0xFFB15B72,
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) =>
                  const CustomerFavoritesScreen(),
            ),
          );
        },
      ),
      _CustomerActionInfo(
        title:
            l10n.shoppingCart,
        subtitle:
            l10n.shoppingCartSubtitle,
        icon:
            Icons.shopping_cart_outlined,
        iconBackground:
            const Color(
          0xFFF2F1D8,
        ),
        iconColor:
            const Color(
          0xFF7A7B35,
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) =>
                  const CustomerCartScreen(),
            ),
          );
        },
      ),
      _CustomerActionInfo(
        title:
            l10n.notifications,
        subtitle:
            notificationProvider.unreadCount >
                    0
                ? l10n.unreadNotifications(
                    notificationProvider
                        .unreadCount,
                  )
                : l10n
                    .latestNotifications,
        icon:
            Icons.notifications_outlined,
        iconBackground:
            const Color(
          0xFFE8EEF7,
        ),
        iconColor:
            const Color(
          0xFF52709C,
        ),
        onTap:
            _openNotifications,
      ),
      _CustomerActionInfo(
        title:
            l10n.myProfile,
        subtitle:
            l10n.myProfileSubtitle,
        icon:
            Icons.person_outline_rounded,
        iconBackground:
            const Color(
          0xFFEDE8F3,
        ),
        iconColor:
            const Color(
          0xFF785A8E,
        ),
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
        final width =
            constraints.maxWidth;

        final columns =
            isWide
                ? 3
                : width >= 650
                    ? 2
                    : 1;

        const spacing =
            14.0;

        final cardWidth =
            (width -
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
                    cardWidth,
                child:
                    _CustomerActionCard(
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
              width:
                  7,
              height:
                  28,
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
                    BorderRadius.circular(
                  10,
                ),
              ),
            ),
            const SizedBox(
              width:
                  10,
            ),
            Text(
              title,
              style:
                  const TextStyle(
                color:
                    _textPrimary,
                fontSize:
                    23,
                fontWeight:
                    FontWeight.w800,
              ),
            ),
          ],
        ),
        const SizedBox(
          height:
              6,
        ),
        Padding(
          padding:
              const EdgeInsetsDirectional.only(
            start:
                17,
          ),
          child: Text(
            subtitle,
            style:
                const TextStyle(
              color:
                  _textSecondary,
              fontSize:
                  14,
              height:
                  1.4,
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
        alpha:
            0.10,
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

class _CustomerActionInfo {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color iconBackground;
  final Color iconColor;
  final VoidCallback onTap;

  const _CustomerActionInfo({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.iconBackground,
    required this.iconColor,
    required this.onTap,
  });
}

class _CustomerActionCard
    extends StatelessWidget {
  final _CustomerActionInfo action;

  const _CustomerActionCard({
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
                color:
                    const Color(
                  0xFF173F24,
                ).withValues(
                  alpha:
                      0.05,
                ),
                blurRadius:
                    18,
                offset:
                    const Offset(
                  0,
                  7,
                ),
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
                      action
                          .iconBackground,
                  borderRadius:
                      BorderRadius.circular(
                    16,
                  ),
                ),
                child:
                    Icon(
                  action.icon,
                  color:
                      action
                          .iconColor,
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
                        height:
                            1.4,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Directionality.of(
                          context,
                        ) ==
                        TextDirection.rtl
                    ? Icons
                        .chevron_left_rounded
                    : Icons
                        .chevron_right_rounded,
                color:
                    const Color(
                  0xFF94A096,
                ),
                size:
                    22,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CustomerBackdrop
    extends StatelessWidget {
  const _CustomerBackdrop();

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
                  0.48,
                  1.0,
                ],
              ),
            ),
          ),
          PositionedDirectional(
            end:
                -180,
            top:
                180,
            child: Container(
              width:
                  460,
              height:
                  460,
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
                      alpha:
                          0.30,
                    ),
                    const Color(
                      0xFFCFE6B4,
                    ).withValues(
                      alpha:
                          0.0,
                    ),
                  ],
                ),
              ),
            ),
          ),
          PositionedDirectional(
            start:
                -190,
            bottom:
                -210,
            child: Container(
              width:
                  520,
              height:
                  520,
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
                      alpha:
                          0.24,
                    ),
                    const Color(
                      0xFFE7DFAF,
                    ).withValues(
                      alpha:
                          0.0,
                    ),
                  ],
                ),
              ),
            ),
          ),
          PositionedDirectional(
            start:
                -45,
            bottom:
                -28,
            child: Opacity(
              opacity:
                  0.03,
              child: Icon(
                Icons
                    .shopping_basket_rounded,
                size:
                    270,
                color:
                    const Color(
                  0xFF2F6B3D,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
