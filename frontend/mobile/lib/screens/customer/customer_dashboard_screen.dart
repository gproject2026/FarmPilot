import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../providers/favorite_provider.dart';
import '../../providers/notification_provider.dart';
import '../farmer/profile_screen.dart';
import '../notifications_screen.dart';
import 'customer_cart_screen.dart';
import 'customer_favorites_screen.dart';
import 'customer_orders_screen.dart';
import 'customer_products_screen.dart';

class CustomerDashboardScreen
    extends StatefulWidget {
  const CustomerDashboardScreen({
    super.key,
  });

  @override
  State<CustomerDashboardScreen>
      createState() =>
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

  @override
  Widget build(BuildContext context) {
    final authProvider =
        Provider.of<AuthProvider>(context);

    final notificationProvider =
        Provider.of<NotificationProvider>(
      context,
    );

    final userName = authProvider
            .userData?['fullName']
            ?.toString() ??
        'Customer';

    return Scaffold(
      backgroundColor:
          const Color(0xFFF5F7F4),
      appBar: AppBar(
        title: const Text(
          'Customer Dashboard',
        ),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        actions: [
          Stack(
            alignment: Alignment.center,
            children: [
              IconButton(
                tooltip: 'Notifications',
                onPressed: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          const NotificationsScreen(),
                    ),
                  );

                  if (mounted) {
                    _loadNotifications();
                  }
                },
                icon: const Icon(
                  Icons.notifications_outlined,
                ),
              ),
              if (notificationProvider
                      .unreadCount >
                  0)
                Positioned(
                  top: 7,
                  right: 6,
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
                      color: Colors.red,
                      shape: BoxShape.circle,
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
                      style: const TextStyle(
                        color: Colors.white,
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
            onPressed: () {
              Provider.of<FavoriteProvider>(
                context,
                listen: false,
              ).clearFavorites();

              Provider.of<
                  NotificationProvider>(
                context,
                listen: false,
              ).clearNotifications();

              authProvider.logout();

              Navigator.of(context)
                  .pushNamedAndRemoveUntil(
                '/',
                (route) => false,
              );
            },
            icon: const Icon(
              Icons.logout,
            ),
            tooltip: 'Logout',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadNotifications,
        child: SingleChildScrollView(
          physics:
              const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.stretch,
            children: [
              Text(
                'Welcome $userName 👋',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight:
                      FontWeight.bold,
                ),
              ),
              const SizedBox(
                height: 12,
              ),
              Text(
                'Browse fresh products and follow your orders.',
                textAlign: TextAlign.center,
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
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
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
                    Icons.storefront_outlined,
                  ),
                  label: const Text(
                    'Browse Marketplace',
                  ),
                ),
              ),
              const SizedBox(
                height: 24,
              ),
              _DashboardCard(
                title: 'My Orders',
                subtitle:
                    'View your current and previous orders',
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
                title: 'Marketplace',
                subtitle:
                    'Browse available products and add them to your cart',
                icon:
                    Icons.storefront_outlined,
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
                title: 'My Favorites',
                subtitle:
                    'View products you saved for later',
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
                title: 'Notifications',
                subtitle: notificationProvider
                            .unreadCount >
                        0
                    ? '${notificationProvider.unreadCount} unread notifications'
                    : 'View your latest notifications',
                icon: Icons
                    .notifications_outlined,
                onTap: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          const NotificationsScreen(),
                    ),
                  );

                  if (mounted) {
                    _loadNotifications();
                  }
                },
              ),
              const SizedBox(
                height: 12,
              ),
              _DashboardCard(
                title: 'Shopping Cart',
                subtitle:
                    'Review your products and complete checkout',
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
                title: 'My Profile',
                subtitle:
                    'View and edit your personal information',
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
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius:
            BorderRadius.circular(16),
      ),
      child: ListTile(
        onTap: onTap,
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
            color: Colors.green.shade700,
          ),
        ),
        title: Text(
          title,
          style: const TextStyle(
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