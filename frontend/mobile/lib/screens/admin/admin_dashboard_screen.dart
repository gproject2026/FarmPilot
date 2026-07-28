import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../providers/dashboard_provider.dart';

class AdminDashboardScreen
    extends StatefulWidget {
  const AdminDashboardScreen({
    super.key,
  });

  @override
  State<AdminDashboardScreen>
      createState() =>
          _AdminDashboardScreenState();
}

class _AdminDashboardScreenState
    extends State<AdminDashboardScreen> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance
        .addPostFrameCallback(
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
  Widget build(BuildContext context) {
    final dashboardProvider =
        Provider.of<DashboardProvider>(
      context,
    );

    final data =
        dashboardProvider.dashboardData;

    return Scaffold(
      backgroundColor:
          const Color(0xFFF5F7F4),
      appBar: AppBar(
        title: const Text(
          'Admin Dashboard',
        ),
        backgroundColor:
            Colors.green,
        foregroundColor:
            Colors.white,
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
              child:
                  CircularProgressIndicator(),
            )
          : data == null
              ? RefreshIndicator(
                  onRefresh:
                      _loadDashboard,
                  child: ListView(
                    physics:
                        const AlwaysScrollableScrollPhysics(),
                    padding:
                        const EdgeInsets.all(
                      24,
                    ),
                    children: [
                      const SizedBox(
                        height: 180,
                      ),
                      const Icon(
                        Icons
                            .admin_panel_settings_outlined,
                        size: 80,
                        color: Colors.grey,
                      ),
                      const SizedBox(
                        height: 16,
                      ),
                      Center(
                        child: Text(
                          dashboardProvider
                                  .errorMessage ??
                              'Unable to load admin dashboard',
                          textAlign:
                              TextAlign.center,
                          style:
                              const TextStyle(
                            fontSize: 18,
                            fontWeight:
                                FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 16,
                      ),
                      Center(
                        child:
                            ElevatedButton.icon(
                          onPressed:
                              _loadDashboard,
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
                )
              : RefreshIndicator(
                  onRefresh:
                      _loadDashboard,
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
                          CrossAxisAlignment.start,
                      children: [
                        const Center(
                          child: Icon(
                            Icons
                                .admin_panel_settings,
                            size: 72,
                            color: Colors.green,
                          ),
                        ),
                        const SizedBox(
                          height: 12,
                        ),
                        const Center(
                          child: Text(
                            'Welcome Admin',
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight:
                                  FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 8,
                        ),
                        Center(
                          child: Text(
                            'System overview and statistics',
                            style: TextStyle(
                              fontSize: 15,
                              color: Colors
                                  .grey.shade700,
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 28,
                        ),
                        GridView.count(
                          crossAxisCount:
                              MediaQuery.of(
                                        context,
                                      ).size.width >
                                      800
                                  ? 3
                                  : 2,
                          crossAxisSpacing: 14,
                          mainAxisSpacing: 14,
                          childAspectRatio:
                              MediaQuery.of(
                                        context,
                                      ).size.width >
                                      800
                                  ? 1.9
                                  : 1.35,
                          shrinkWrap: true,
                          physics:
                              const NeverScrollableScrollPhysics(),
                          children: [
                            _statCard(
                              title:
                                  'Total Users',
                              value: _value(
                                data[
                                    'totalUsers'],
                              ),
                              icon:
                                  Icons.people,
                            ),
                            _statCard(
                              title:
                                  'Farmers',
                              value: _value(
                                data[
                                    'totalFarmers'],
                              ),
                              icon:
                                  Icons.agriculture,
                            ),
                            _statCard(
                              title:
                                  'Customers',
                              value: _value(
                                data[
                                    'totalCustomers'],
                              ),
                              icon: Icons
                                  .person_outline,
                            ),
                            _statCard(
                              title:
                                  'Products',
                              value: _value(
                                data[
                                    'totalProducts'],
                              ),
                              icon: Icons
                                  .inventory_2_outlined,
                            ),
                            _statCard(
                              title:
                                  'Orders',
                              value: _value(
                                data[
                                    'totalOrders'],
                              ),
                              icon: Icons
                                  .shopping_cart_outlined,
                            ),
                            _statCard(
                              title:
                                  'Diagnoses',
                              value: _value(
                                data[
                                    'totalDiagnoses'],
                              ),
                              icon: Icons
                                  .health_and_safety_outlined,
                            ),
                          ],
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
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius:
            BorderRadius.circular(
          18,
        ),
      ),
      child: Padding(
        padding:
            const EdgeInsets.all(
          18,
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 28,
              backgroundColor:
                  Colors.green.shade100,
              child: Icon(
                icon,
                color:
                    Colors.green.shade700,
                size: 28,
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
                    style:
                        const TextStyle(
                      fontSize: 28,
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),
                  const SizedBox(
                    height: 4,
                  ),
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 15,
                      color: Colors
                          .grey.shade700,
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