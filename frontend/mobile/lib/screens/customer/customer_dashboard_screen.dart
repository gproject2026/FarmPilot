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

    final userName = authProvider
            .userData?['fullName']
            ?.toString() ??
        l10n.customer;

    final isArabic =
        localeProvider
                .locale.languageCode ==
            'ar';

    return Scaffold(
      backgroundColor:
          const Color(
        0xFFF5F7F4,
      ),
      appBar: AppBar(
        title: Text(
          l10n.customerDashboard,
        ),
        backgroundColor:
            Colors.green,
        foregroundColor:
            Colors.white,
        actions: [
          PopupMenuButton<String>(
            tooltip:
                l10n.changeLanguage,
            icon: const Icon(
              Icons.language,
            ),
            onSelected:
                _changeLanguage,
            itemBuilder:
                (context) {
              return [
                PopupMenuItem<String>(
                  value: 'en',
                  child: Row(
                    children: [
                      Icon(
                        Icons.check,
                        color:
                            !isArabic
                                ? Colors.green
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
                        Icons.check,
                        color:
                            isArabic
                                ? Colors.green
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
          Stack(
            alignment:
                Alignment.center,
            children: [
              IconButton(
                tooltip:
                    l10n.notifications,
                onPressed:
                    _openNotifications,
                icon: const Icon(
                  Icons
                      .notifications_outlined,
                ),
              ),
              if (notificationProvider
                      .unreadCount >
                  0)
                PositionedDirectional(
                  top: 7,
                  end: 6,
                  child: Container(
                    constraints:
                        const BoxConstraints(
                      minWidth: 18,
                      minHeight: 18,
                    ),
                    padding:
                        const EdgeInsets.symmetric(
                      horizontal: 5,
                      vertical: 2,
                    ),
                    decoration:
                        const BoxDecoration(
                      color:
                          Colors.red,
                      shape:
                          BoxShape.circle,
                    ),
                    child: Text(
                      notificationProvider
                                  .unreadCount >
                              99
                          ? '99+'
                          : notificationProvider
                              .unreadCount
                              .toString(),
                      textAlign:
                          TextAlign.center,
                      style:
                          const TextStyle(
                        color:
                            Colors.white,
                        fontSize: 10,
                        fontWeight:
                            FontWeight.bold,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          IconButton(
            onPressed:
                _logout,
            icon: const Icon(
              Icons.logout,
            ),
            tooltip:
                l10n.logout,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh:
            _loadNotifications,
        child:
            SingleChildScrollView(
          physics:
              const AlwaysScrollableScrollPhysics(),
          padding:
              const EdgeInsets.all(
            20,
          ),
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment
                    .stretch,
            children: [
              Text(
                l10n.welcomeCustomer(
                  userName,
                ),
                textAlign:
                    TextAlign.center,
                style:
                    const TextStyle(
                  fontSize: 28,
                  fontWeight:
                      FontWeight.bold,
                ),
              ),
              const SizedBox(
                height: 12,
              ),
              Text(
                l10n
                    .customerDashboardSubtitle,
                textAlign:
                    TextAlign.center,
                style: TextStyle(
                  fontSize: 15,
                  color:
                      Colors.grey.shade600,
                ),
              ),
              const SizedBox(
                height: 30,
              ),
              SizedBox(
                width:
                    double.infinity,
                height: 52,
                child:
                    ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            const CustomerProductsScreen(),
                      ),
                    );
                  },
                  icon: const Icon(
                    Icons
                        .storefront_outlined,
                  ),
                  label: Text(
                    l10n
                        .browseMarketplace,
                  ),
                ),
              ),
              const SizedBox(
                height: 24,
              ),
              _DashboardCard(
                title:
                    l10n.myOrders,
                subtitle:
                    l10n.myOrdersSubtitle,
                icon: Icons
                    .shopping_bag_outlined,
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
              const SizedBox(
                height: 12,
              ),
              _DashboardCard(
                title:
                    l10n.marketplace,
                subtitle:
                    l10n.marketplaceSubtitle,
                icon: Icons
                    .storefront_outlined,
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
              const SizedBox(
                height: 12,
              ),
              _DashboardCard(
                title:
                    l10n.myFavorites,
                subtitle:
                    l10n.myFavoritesSubtitle,
                icon:
                    Icons.favorite_outline,
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
              const SizedBox(
                height: 12,
              ),
              _DashboardCard(
                title:
                    l10n.notifications,
                subtitle:
                    notificationProvider
                                .unreadCount >
                            0
                        ? l10n
                            .unreadNotifications(
                            notificationProvider
                                .unreadCount,
                          )
                        : l10n
                            .latestNotifications,
                icon: Icons
                    .notifications_outlined,
                onTap:
                    _openNotifications,
              ),
              const SizedBox(
                height: 12,
              ),
              _DashboardCard(
                title:
                    l10n.shoppingCart,
                subtitle:
                    l10n.shoppingCartSubtitle,
                icon: Icons
                    .shopping_cart_outlined,
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
              const SizedBox(
                height: 12,
              ),
              _DashboardCard(
                title:
                    l10n.myProfile,
                subtitle:
                    l10n.myProfileSubtitle,
                icon:
                    Icons.person_outline,
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
            ],
          ),
        ),
      ),
    );
  }
}

class _DashboardCard
    extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;

  const _DashboardCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    return Card(
      elevation: 1,
      shape:
          RoundedRectangleBorder(
        borderRadius:
            BorderRadius.circular(
          16,
        ),
      ),
      child: ListTile(
        onTap:
            onTap,
        contentPadding:
            const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 10,
        ),
        leading: CircleAvatar(
          backgroundColor:
              Colors.green.shade100,
          child: Icon(
            icon,
            color:
                Colors.green.shade700,
          ),
        ),
        title: Text(
          title,
          style:
              const TextStyle(
            fontSize: 17,
            fontWeight:
                FontWeight.bold,
          ),
        ),
        subtitle: Padding(
          padding:
              const EdgeInsets.only(
            top: 4,
          ),
          child: Text(
            subtitle,
          ),
        ),
        trailing: const Icon(
          Icons.arrow_forward_ios,
          size: 18,
        ),
      ),
    );
  }
}