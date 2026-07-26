import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/dashboard_provider.dart';
import 'my_crops_screen.dart';
import 'my_products_screen.dart';

class FarmerDashboardScreen extends StatefulWidget {
  const FarmerDashboardScreen({super.key});

  @override
  State<FarmerDashboardScreen> createState() =>
      _FarmerDashboardScreenState();
}

class _FarmerDashboardScreenState
    extends State<FarmerDashboardScreen> {
  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      Provider.of<DashboardProvider>(
        context,
        listen: false,
      ).loadFarmerDashboard();
    });
  }

  @override
  Widget build(BuildContext context) {
    final dashboardProvider =
        Provider.of<DashboardProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Farmer Dashboard',
        ),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      body: dashboardProvider.isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : dashboardProvider.dashboardData == null
              ? const Center(
                  child: Text(
                    'No Data',
                  ),
                )
              : RefreshIndicator(
                  onRefresh: () async {
                    await dashboardProvider.loadFarmerDashboard();
                  },
                  child: SingleChildScrollView(
                    physics:
                        const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        const Text(
                          'Welcome Farmer 🌱',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(
                          height: 30,
                        ),

                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton.icon(
                            onPressed: () async {
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
                            icon: const Icon(
                              Icons.inventory_2_outlined,
                            ),
                            label: const Text(
                              'My Products',
                            ),
                          ),
                        ),

                        const SizedBox(
                          height: 14,
                        ),

                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton.icon(
                            onPressed: () async {
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
                            icon: const Icon(
                              Icons.eco_outlined,
                            ),
                            label: const Text(
                              'My Crops',
                            ),
                          ),
                        ),

                        const SizedBox(
                          height: 28,
                        ),

                        dashboardCard(
                          title: 'Products',
                          value: dashboardProvider
                              .dashboardData!['productsCount']
                              .toString(),
                          icon: Icons.inventory_2,
                        ),

                        dashboardCard(
                          title: 'Crops',
                          value: dashboardProvider
                              .dashboardData!['cropsCount']
                              .toString(),
                          icon: Icons.eco,
                        ),

                        dashboardCard(
                          title: 'AI Diagnoses',
                          value: dashboardProvider
                              .dashboardData!['diagnosesCount']
                              .toString(),
                          icon: Icons.health_and_safety_outlined,
                        ),

                        dashboardCard(
                          title: 'Orders',
                          value: dashboardProvider
                              .dashboardData!['ordersCount']
                              .toString(),
                          icon: Icons.shopping_cart_outlined,
                        ),

                        dashboardCard(
                          title: 'Total Sales',
                          value: dashboardProvider
                              .dashboardData!['totalSales']
                              .toString(),
                          icon: Icons.payments_outlined,
                        ),
                      ],
                    ),
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
      margin: const EdgeInsets.only(
        bottom: 12,
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.green.shade100,
          child: Icon(
            icon,
            color: Colors.green.shade700,
          ),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 18,
          ),
        ),
        trailing: Text(
          value,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}