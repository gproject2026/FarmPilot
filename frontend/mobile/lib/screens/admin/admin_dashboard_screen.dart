import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../providers/dashboard_provider.dart';
import 'admin_orders_screen.dart';
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
        builder: (_) => const AdminUsersScreen(),
      ),
    );
  }

  void _openManageOrders() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const AdminOrdersScreen(),
      ),
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

    final data = dashboardProvider.dashboardData;

    return Scaffold(
      backgroundColor: const Color(
        0xFFF5F7F4,
      ),
      appBar: AppBar(
        title: const Text(
          'Admin Dashboard',
        ),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            tooltip: 'Refresh',
            onPressed:
                dashboardProvider.isLoading
                    ? null
                    : _loadDashboard,
            icon: const Icon(
              Icons.refresh,
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
              data == null
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : data == null
              ? _buildErrorState(
                  dashboardProvider,
                )
              : _buildDashboard(
                  data,
                ),
    );
  }

  Widget _buildErrorState(
    DashboardProvider dashboardProvider,
  ) {
    return RefreshIndicator(
      onRefresh: _loadDashboard,
      child: ListView(
        physics:
            const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(
          24,
        ),
        children: [
          const SizedBox(
            height: 120,
          ),
          const Icon(
            Icons.admin_panel_settings_outlined,
            size: 80,
            color: Colors.grey,
          ),
          const SizedBox(
            height: 16,
          ),
          Center(
            child: Text(
              dashboardProvider.errorMessage ??
                  'Unable to load admin dashboard',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(
            height: 16,
          ),
          Center(
            child: ElevatedButton.icon(
              onPressed: _loadDashboard,
              icon: const Icon(
                Icons.refresh,
              ),
              label: const Text(
                'Try Again',
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDashboard(
    Map<String, dynamic> data,
  ) {
    return RefreshIndicator(
      onRefresh: _loadDashboard,
      child: LayoutBuilder(
        builder: (
          context,
          constraints,
        ) {
          final width = constraints.maxWidth;

          int crossAxisCount;
          double childAspectRatio;

          if (width >= 1000) {
            crossAxisCount = 3;
            childAspectRatio = 2.3;
          } else if (width >= 650) {
            crossAxisCount = 2;
            childAspectRatio = 2.1;
          } else {
            crossAxisCount = 1;
            childAspectRatio = 3.2;
          }

          return SingleChildScrollView(
            physics:
                const AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.symmetric(
              horizontal: width < 650 ? 16 : 24,
              vertical: 18,
            ),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  maxWidth: 1200,
                ),
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    const Center(
                      child: Icon(
                        Icons.admin_panel_settings,
                        size: 58,
                        color: Colors.green,
                      ),
                    ),
                    const SizedBox(
                      height: 8,
                    ),
                    const Center(
                      child: Text(
                        'Welcome Admin',
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight:
                              FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 6,
                    ),
                    Center(
                      child: Text(
                        'System overview and statistics',
                        style: TextStyle(
                          fontSize: 15,
                          color:
                              Colors.grey.shade700,
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 22,
                    ),
                    GridView.count(
                      crossAxisCount:
                          crossAxisCount,
                      crossAxisSpacing: 14,
                      mainAxisSpacing: 14,
                      childAspectRatio:
                          childAspectRatio,
                      shrinkWrap: true,
                      physics:
                          const NeverScrollableScrollPhysics(),
                      children: [
                        _statCard(
                          title: 'Total Users',
                          value: _value(
                            data['totalUsers'],
                          ),
                          icon: Icons.people,
                        ),
                        _statCard(
                          title: 'Farmers',
                          value: _value(
                            data['totalFarmers'],
                          ),
                          icon: Icons.agriculture,
                        ),
                        _statCard(
                          title: 'Customers',
                          value: _value(
                            data['totalCustomers'],
                          ),
                          icon:
                              Icons.person_outline,
                        ),
                        _statCard(
                          title: 'Products',
                          value: _value(
                            data['totalProducts'],
                          ),
                          icon: Icons
                              .inventory_2_outlined,
                        ),
                        _statCard(
                          title: 'Orders',
                          value: _value(
                            data['totalOrders'],
                          ),
                          icon: Icons
                              .shopping_cart_outlined,
                        ),
                        _statCard(
                          title: 'Diagnoses',
                          value: _value(
                            data['totalDiagnoses'],
                          ),
                          icon: Icons
                              .health_and_safety_outlined,
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 28,
                    ),
                    const Text(
                      'Admin Tools',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight:
                            FontWeight.bold,
                      ),
                    ),
                    const SizedBox(
                      height: 14,
                    ),

                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed:
                            _openManageUsers,
                        icon: const Icon(
                          Icons.manage_accounts,
                        ),
                        label: const Text(
                          'Manage Users',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight:
                                FontWeight.w600,
                          ),
                        ),
                        style:
                            ElevatedButton.styleFrom(
                          backgroundColor:
                              Colors.green,
                          foregroundColor:
                              Colors.white,
                          padding:
                              const EdgeInsets.symmetric(
                            vertical: 17,
                          ),
                          shape:
                              RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(
                              14,
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(
                      height: 12,
                    ),

                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed:
                            _openManageOrders,
                        icon: const Icon(
                          Icons.receipt_long_outlined,
                        ),
                        label: const Text(
                          'Manage Orders',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight:
                                FontWeight.w600,
                          ),
                        ),
                        style:
                            ElevatedButton.styleFrom(
                          backgroundColor:
                              Colors.green,
                          foregroundColor:
                              Colors.white,
                          padding:
                              const EdgeInsets.symmetric(
                            vertical: 17,
                          ),
                          shape:
                              RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(
                              14,
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(
                      height: 20,
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

  Widget _statCard({
    required String title,
    required String value,
    required IconData icon,
  }) {
    return Card(
      elevation: 2,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(
          18,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 14,
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 25,
              backgroundColor:
                  Colors.green.shade100,
              child: Icon(
                icon,
                color:
                    Colors.green.shade700,
                size: 25,
              ),
            ),
            const SizedBox(
              width: 16,
            ),
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
                      fontSize: 26,
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),
                  const SizedBox(
                    height: 2,
                  ),
                  Text(
                    title,
                    maxLines: 1,
                    overflow:
                        TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 15,
                      color:
                          Colors.grey.shade700,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _value(
    dynamic value,
  ) {
    return value?.toString() ?? '0';
  }
}