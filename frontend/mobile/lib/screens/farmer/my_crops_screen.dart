import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../providers/crop_provider.dart';
import 'add_crop_screen.dart';

class MyCropsScreen extends StatefulWidget {
  const MyCropsScreen({super.key});

  @override
  State<MyCropsScreen> createState() => _MyCropsScreenState();
}

class _MyCropsScreenState extends State<MyCropsScreen> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadCrops();
    });
  }

  Future<void> _loadCrops() async {
    final authProvider = Provider.of<AuthProvider>(
      context,
      listen: false,
    );

    final cropProvider = Provider.of<CropProvider>(
      context,
      listen: false,
    );

    final token = authProvider.token;

    if (token != null && token.isNotEmpty) {
      await cropProvider.getMyCrops(token);
    }
  }

  Future<void> _openAddCropScreen() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const AddCropScreen(),
      ),
    );

    if (result == true) {
      await _loadCrops();
    }
  }

  Future<void> _openEditCropScreen(
    Map<String, dynamic> crop,
  ) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AddCropScreen(
          crop: crop,
        ),
      ),
    );

    if (result == true) {
      await _loadCrops();
    }
  }

  Future<void> _deleteCrop(
    Map<String, dynamic> crop,
  ) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Delete Crop'),
          content: Text(
            'Are you sure you want to delete ${crop['cropName']}?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, false);
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, true);
              },
              child: const Text(
                'Delete',
                style: TextStyle(
                  color: Colors.red,
                ),
              ),
            ),
          ],
        );
      },
    );

    if (shouldDelete != true || !mounted) {
      return;
    }

    final authProvider = Provider.of<AuthProvider>(
      context,
      listen: false,
    );

    final cropProvider = Provider.of<CropProvider>(
      context,
      listen: false,
    );

    final token = authProvider.token;

    if (token == null || token.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Authentication token not found'),
        ),
      );
      return;
    }

    final success = await cropProvider.deleteCrop(
      token: token,
      cropId: crop['id'].toString(),
    );

    if (!mounted) {
      return;
    }

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Crop deleted successfully'),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            cropProvider.errorMessage ??
                'Failed to delete crop',
          ),
        ),
      );
    }
  }

  String _displayValue(dynamic value) {
    if (value == null || value.toString().trim().isEmpty) {
      return 'Not specified';
    }

    return value.toString();
  }

  String _formatDate(dynamic value) {
    if (value == null || value.toString().isEmpty) {
      return 'Not specified';
    }

    final date = DateTime.tryParse(value.toString());

    if (date == null) {
      return value.toString();
    }

    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');

    return '${date.year}-$month-$day';
  }

  Widget _buildInformationRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.only(
        bottom: 8,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: 19,
            color: Colors.green.shade700,
          ),
          const SizedBox(
            width: 8,
          ),
          Expanded(
            child: Text(
              '$label: $value',
              style: const TextStyle(
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCropCard(
    Map<String, dynamic> crop,
  ) {
    return Card(
      margin: const EdgeInsets.only(
        bottom: 14,
      ),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(
          14,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(
          16,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: Colors.green.shade100,
                    borderRadius: BorderRadius.circular(
                      12,
                    ),
                  ),
                  child: Icon(
                    Icons.eco,
                    color: Colors.green.shade700,
                    size: 30,
                  ),
                ),
                const SizedBox(
                  width: 12,
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Text(
                        _displayValue(
                          crop['cropName'],
                        ),
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(
                        height: 4,
                      ),
                      Text(
                        _displayValue(
                          crop['cropType'],
                        ),
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ],
                  ),
                ),
                PopupMenuButton<String>(
                  onSelected: (value) {
                    if (value == 'edit') {
                      _openEditCropScreen(crop);
                    }

                    if (value == 'delete') {
                      _deleteCrop(crop);
                    }
                  },
                  itemBuilder: (_) {
                    return const [
                      PopupMenuItem(
                        value: 'edit',
                        child: Row(
                          children: [
                            Icon(
                              Icons.edit,
                            ),
                            SizedBox(
                              width: 8,
                            ),
                            Text('Edit'),
                          ],
                        ),
                      ),
                      PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(
                              Icons.delete,
                              color: Colors.red,
                            ),
                            SizedBox(
                              width: 8,
                            ),
                            Text(
                              'Delete',
                              style: TextStyle(
                                color: Colors.red,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ];
                  },
                ),
              ],
            ),
            const Divider(
              height: 26,
            ),
            _buildInformationRow(
              icon: Icons.calendar_month,
              label: 'Planting date',
              value: _formatDate(
                crop['plantingDate'],
              ),
            ),
            _buildInformationRow(
              icon: Icons.water_drop,
              label: 'Irrigation',
              value: _displayValue(
                crop['irrigationSchedule'],
              ),
            ),
            _buildInformationRow(
              icon: Icons.science,
              label: 'Fertilization',
              value: _displayValue(
                crop['fertilizationSchedule'],
              ),
            ),
            _buildInformationRow(
              icon: Icons.notes,
              label: 'Notes',
              value: _displayValue(
                crop['notes'],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'My Crops',
        ),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: _loadCrops,
            icon: const Icon(
              Icons.refresh,
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openAddCropScreen,
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        icon: const Icon(
          Icons.add,
        ),
        label: const Text(
          'Add Crop',
        ),
      ),
      body: Consumer<CropProvider>(
        builder: (
          context,
          cropProvider,
          child,
        ) {
          if (cropProvider.isLoading &&
              cropProvider.crops.isEmpty) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (cropProvider.errorMessage != null &&
              cropProvider.crops.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(
                  24,
                ),
                child: Column(
                  mainAxisAlignment:
                      MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 60,
                      color: Colors.red,
                    ),
                    const SizedBox(
                      height: 16,
                    ),
                    Text(
                      cropProvider.errorMessage!,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(
                      height: 16,
                    ),
                    ElevatedButton(
                      onPressed: _loadCrops,
                      child: const Text(
                        'Try Again',
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          if (cropProvider.crops.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(
                  24,
                ),
                child: Column(
                  mainAxisAlignment:
                      MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.eco_outlined,
                      size: 80,
                      color: Colors.green.shade300,
                    ),
                    const SizedBox(
                      height: 16,
                    ),
                    const Text(
                      'No crops added yet',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(
                      height: 8,
                    ),
                    const Text(
                      'Add your first crop to start managing it.',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(
                      height: 18,
                    ),
                    ElevatedButton.icon(
                      onPressed: _openAddCropScreen,
                      icon: const Icon(
                        Icons.add,
                      ),
                      label: const Text(
                        'Add Crop',
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: _loadCrops,
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(
                16,
                16,
                16,
                90,
              ),
              itemCount: cropProvider.crops.length,
              itemBuilder: (
                context,
                index,
              ) {
                final crop = Map<String, dynamic>.from(
                  cropProvider.crops[index] as Map,
                );

                return _buildCropCard(crop);
              },
            ),
          );
        },
      ),
    );
  }
}