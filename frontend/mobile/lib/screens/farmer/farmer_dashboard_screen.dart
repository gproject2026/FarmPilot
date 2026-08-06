import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../providers/dashboard_provider.dart';
import '../../providers/notification_provider.dart';
import '../notifications_screen.dart';
import 'diagnose_plant_screen.dart';
import 'diagnosis_history_screen.dart';
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
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
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

    await Provider.of<NotificationProvider>(
      context,
      listen: false,
    ).loadNotifications();
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

    notificationProvider.clearNotifications();
    authProvider.logout();

    if (!mounted) {
      return;
    }

    Navigator.of(context).pushNamedAndRemoveUntil(
      '/',
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final dashboardProvider =
        Provider.of<DashboardProvider>(
      context,
    );

    final notificationProvider =
        Provider.of<NotificationProvider>(
      context,
    );

    return Scaffold(
      backgroundColor:
          const Color(0xFFF5F7F4),
      appBar: AppBar(
        title: const Text(
          'Farmer Dashboard',
        ),
        backgroundColor:
            Colors.green,
        foregroundColor:
            Colors.white,
        actions: [
          IconButton(
            tooltip: 'Notifications',
            onPressed:
                _openNotifications,
            icon: Stack(
              clipBehavior:
                  Clip.none,
              children: [
                const Icon(
                  Icons.notifications_outlined,
                ),
                if (notificationProvider
                        .unreadCount >
                    0)
                  Positioned(
                    top: -7,
                    right: -7,
                    child: Container(
                      constraints:
                          const BoxConstraints(
                        minWidth: 18,
                        minHeight: 18,
                      ),
                      padding:
                          const EdgeInsets.symmetric(
                        horizontal: 5,
                      ),
                      alignment:
                          Alignment.center,
                      decoration:
                          BoxDecoration(
                        color: Colors.red,
                        borderRadius:
                            BorderRadius.circular(
                          10,
                        ),
                        border: Border.all(
                          color: Colors.white,
                          width: 1.5,
                        ),
                      ),
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
          ),
          IconButton(
            tooltip: 'Logout',
            onPressed: _logout,
            icon: const Icon(
              Icons.logout,
            ),
          ),
        ],
      ),
      body: dashboardProvider.isLoading &&
              dashboardProvider
                      .dashboardData ==
                  null
          ? const Center(
              child:
                  CircularProgressIndicator(),
            )
          : dashboardProvider
                      .dashboardData ==
                  null
              ? RefreshIndicator(
                  onRefresh: _loadData,
                  child: ListView(
                    physics:
                        const AlwaysScrollableScrollPhysics(),
                    children: const [
                      SizedBox(
                        height: 250,
                      ),
                      Center(
                        child: Text(
                          'No Data',
                        ),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadData,
                  child:
                      SingleChildScrollView(
                    physics:
                        const AlwaysScrollableScrollPhysics(),
                    padding:
                        const EdgeInsets.all(
                      20,
                    ),
                    child: Column(
                      children: [
                        const Text(
                          'Welcome Farmer 🌱',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight:
                                FontWeight.bold,
                          ),
                        ),
                        const SizedBox(
                          height: 30,
                        ),
                        _navigationButton(
                          icon: Icons
                              .inventory_2_outlined,
                          label:
                              'My Products',
                          onPressed:
                              () async {
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
                        const SizedBox(
                          height: 14,
                        ),
                        _navigationButton(
                          icon:
                              Icons.eco_outlined,
                          label:
                              'My Crops',
                          onPressed:
                              () async {
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
                        const SizedBox(
                          height: 14,
                        ),
                        _navigationButton(
                          icon: Icons
                              .local_florist_outlined,
                          label:
                              'Plant Diagnosis',
                          onPressed: () async {
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

                            await dashboardProvider
                                .loadFarmerDashboard();
                          },
                        ),
                        const SizedBox(
                          height: 14,
                        ),
                        _navigationButton(
                          icon:
                              Icons.history,
                          label:
                              'Diagnosis History',
                          onPressed: () async {
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
                        const SizedBox(
                          height: 14,
                        ),
                        _navigationButton(
                          icon: Icons
                              .notifications_active_outlined,
                          label:
                              'Reminders',
                          onPressed:
                              () async {
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
                        const SizedBox(
                          height: 14,
                        ),
                        _navigationButton(
                          icon: Icons
                              .notifications_outlined,
                          label: notificationProvider
                                      .unreadCount >
                                  0
                              ? 'Notifications (${notificationProvider.unreadCount})'
                              : 'Notifications',
                          onPressed:
                              _openNotifications,
                        ),
                        const SizedBox(
                          height: 14,
                        ),
                        _navigationButton(
                          icon: Icons
                              .person_outline,
                          label:
                              'My Profile',
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    const ProfileScreen(),
                              ),
                            );
                          },
                        ),
                        const SizedBox(
                          height: 28,
                        ),
                        dashboardCard(
                          title:
                              'Products',
                          value:
                              dashboardProvider
                                  .dashboardData![
                                      'productsCount']
                                  .toString(),
                          icon:
                              Icons.inventory_2,
                        ),
                        dashboardCard(
                          title:
                              'Crops',
                          value:
                              dashboardProvider
                                  .dashboardData![
                                      'cropsCount']
                                  .toString(),
                          icon:
                              Icons.eco,
                        ),
                        dashboardCard(
                          title:
                              'AI Diagnoses',
                          value:
                              dashboardProvider
                                  .dashboardData![
                                      'diagnosesCount']
                                  .toString(),
                          icon: Icons
                              .health_and_safety_outlined,
                        ),
                        dashboardCard(
                          title:
                              'Orders',
                          value:
                              dashboardProvider
                                  .dashboardData![
                                      'ordersCount']
                                  .toString(),
                          icon: Icons
                              .shopping_cart_outlined,
                        ),
                        dashboardCard(
                          title:
                              'Total Sales',
                          value:
                              dashboardProvider
                                  .dashboardData![
                                      'totalSales']
                                  .toString(),
                          icon:
                              Icons.payments_outlined,
                        ),
                      ],
                    ),
                  ),
                ),
    );
  }

  Widget _navigationButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(
          icon,
        ),
        label: Text(
          label,
        ),
      ),
    );
  }

  Widget dashboardCard({
    required String title,
    required String value,
    required IconData icon,
  }) {
    return Card(
      margin:
          const EdgeInsets.only(
        bottom: 12,
      ),
      shape:
          RoundedRectangleBorder(
        borderRadius:
            BorderRadius.circular(
          16,
        ),
      ),
      child: ListTile(
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
            fontSize: 18,
          ),
        ),
        trailing: Text(
          value,
          style:
              const TextStyle(
            fontSize: 22,
            fontWeight:
                FontWeight.bold,
          ),
        ),
      ),
    );
  }
}