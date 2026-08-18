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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAF4),
      body: Consumer<CropProvider>(
        builder: (context, cropProvider, child) {
          final crops = cropProvider.crops;

          return Stack(
            children: [
              const Positioned.fill(child: _CropsBackdrop()),
              Column(
                children: [
                  _CropsTopBar(
                    onRefresh: cropProvider.isLoading ? null : _loadCrops,
                  ),
                  Expanded(
                    child: RefreshIndicator(
                      onRefresh: _loadCrops,
                      color: _cropsPrimary,
                      child: CustomScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        slivers: [
                          SliverToBoxAdapter(
                            child: Center(
                              child: ConstrainedBox(
                                constraints: const BoxConstraints(
                                  maxWidth: 1320,
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.fromLTRB(
                                    24,
                                    26,
                                    24,
                                    18,
                                  ),
                                  child: _CropsHero(
                                    totalCrops: crops.length,
                                    isLoading: cropProvider.isLoading,
                                    onAddCrop: cropProvider.isLoading
                                        ? null
                                        : _openAddCropScreen,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          if (cropProvider.isLoading && crops.isEmpty)
                            const SliverFillRemaining(
                              hasScrollBody: false,
                              child: Center(
                                child: CircularProgressIndicator(
                                  color: _cropsPrimary,
                                ),
                              ),
                            )
                          else if (cropProvider.errorMessage != null &&
                              crops.isEmpty)
                            SliverFillRemaining(
                              hasScrollBody: false,
                              child: _CropsErrorState(
                                message: cropProvider.errorMessage!,
                                onRetry: _loadCrops,
                              ),
                            )
                          else if (crops.isEmpty)
                            SliverFillRemaining(
                              hasScrollBody: false,
                              child: _EmptyCrops(
                                onAdd: _openAddCropScreen,
                              ),
                            )
                          else
                            SliverPadding(
                              padding: const EdgeInsets.fromLTRB(
                                24,
                                0,
                                24,
                                42,
                              ),
                              sliver: SliverLayoutBuilder(
                                builder: (context, constraints) {
                                  final width = constraints.crossAxisExtent;
                                  final crossAxisCount = width >= 1180
                                      ? 3
                                      : width >= 760
                                          ? 2
                                          : 1;

                                  return SliverGrid(
                                    delegate: SliverChildBuilderDelegate(
                                      (context, index) {
                                        final crop =
                                            Map<String, dynamic>.from(
                                          crops[index] as Map,
                                        );

                                        return _CropCard(
                                          crop: crop,
                                          displayValue: _displayValue,
                                          formatDate: _formatDate,
                                          onEdit: () =>
                                              _openEditCropScreen(crop),
                                          onDelete: () => _deleteCrop(crop),
                                        );
                                      },
                                      childCount: crops.length,
                                    ),
                                    gridDelegate:
                                        SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: crossAxisCount,
                                      crossAxisSpacing: 16,
                                      mainAxisSpacing: 16,
                                      mainAxisExtent: 430,
                                    ),
                                  );
                                },
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}

const _cropsDark = Color(0xFF173F24);
const _cropsPrimary = Color(0xFF2F743F);
const _cropsLight = Color(0xFFEAF3DF);
const _cropsText = Color(0xFF1D2C21);
const _cropsMuted = Color(0xFF6C786E);

class _CropsTopBar extends StatelessWidget {
  final Future<void> Function()? onRefresh;

  const _CropsTopBar({
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xFF123A22),
            Color(0xFF205A34),
            Color(0xFF2E6F40),
          ],
        ),
      ),
      padding: const EdgeInsets.fromLTRB(18, 12, 18, 14),
      child: SafeArea(
        bottom: false,
        child: Row(
          children: [
            _CropsHeaderButton(
              icon: Icons.arrow_back_rounded,
              tooltip: 'Back',
              onTap: () => Navigator.pop(context),
            ),
            const SizedBox(width: 12),
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: const Color(0xFFDDECB8),
                borderRadius: BorderRadius.circular(13),
              ),
              child: const Icon(
                Icons.eco_rounded,
                color: _cropsDark,
              ),
            ),
            const SizedBox(width: 10),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'FarmPilot',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 19,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  Text(
                    'My Crops',
                    style: TextStyle(
                      color: Color(0xCCFFFFFF),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            _CropsHeaderButton(
              icon: Icons.refresh_rounded,
              tooltip: 'Refresh',
              onTap: onRefresh,
            ),
          ],
        ),
      ),
    );
  }
}

class _CropsHeaderButton extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback? onTap;

  const _CropsHeaderButton({
    required this.icon,
    required this.tooltip,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: Colors.white.withValues(
          alpha: onTap == null ? 0.05 : 0.10,
        ),
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: SizedBox(
            width: 44,
            height: 44,
            child: Icon(
              icon,
              color: onTap == null ? Colors.white54 : Colors.white,
              size: 21,
            ),
          ),
        ),
      ),
    );
  }
}

class _CropsHero extends StatelessWidget {
  final int totalCrops;
  final bool isLoading;
  final VoidCallback? onAddCrop;

  const _CropsHero({
    required this.totalCrops,
    required this.isLoading,
    required this.onAddCrop,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: _cropCardDecoration(25),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final heading = Row(
            children: [
              Container(
                width: 58,
                height: 58,
                decoration: BoxDecoration(
                  color: _cropsLight,
                  borderRadius: BorderRadius.circular(17),
                ),
                child: const Icon(
                  Icons.eco_outlined,
                  color: _cropsPrimary,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'My Crops',
                      style: TextStyle(
                        color: _cropsText,
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Track planting dates, irrigation, fertilization and notes for every crop.',
                      style: TextStyle(
                        color: _cropsMuted,
                        fontSize: 13,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );

          final actions = Wrap(
            spacing: 10,
            runSpacing: 10,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 13,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F6E9),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Text(
                  '$totalCrops crops',
                  style: const TextStyle(
                    color: _cropsPrimary,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              ElevatedButton.icon(
                onPressed: onAddCrop,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _cropsPrimary,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: const Color(0xFFD3DCCF),
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 15,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                icon: isLoading
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.add_rounded),
                label: const Text(
                  'Add Crop',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          );

          if (constraints.maxWidth < 700) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                heading,
                const SizedBox(height: 18),
                actions,
              ],
            );
          }

          return Row(
            children: [
              Expanded(child: heading),
              const SizedBox(width: 20),
              actions,
            ],
          );
        },
      ),
    );
  }
}

class _CropCard extends StatelessWidget {
  final Map<String, dynamic> crop;
  final String Function(dynamic) displayValue;
  final String Function(dynamic) formatDate;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _CropCard({
    required this.crop,
    required this.displayValue,
    required this.formatDate,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final cropName = displayValue(crop['cropName']);
    final cropType = displayValue(crop['cropType']);

    return Container(
      decoration: _cropCardDecoration(22),
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: _cropsLight,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: const Icon(
                  Icons.eco_rounded,
                  color: _cropsPrimary,
                  size: 28,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      cropName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: _cropsText,
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      cropType,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: _cropsMuted,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          _CropInfoTile(
            icon: Icons.calendar_month,
            label: 'Planting date',
            value: formatDate(crop['plantingDate']),
          ),
          const SizedBox(height: 10),
          _CropInfoTile(
            icon: Icons.water_drop_outlined,
            label: 'Irrigation',
            value: displayValue(crop['irrigationSchedule']),
          ),
          const SizedBox(height: 10),
          _CropInfoTile(
            icon: Icons.science_outlined,
            label: 'Fertilization',
            value: displayValue(crop['fertilizationSchedule']),
          ),
          const SizedBox(height: 10),
          _CropInfoTile(
            icon: Icons.notes_rounded,
            label: 'Notes',
            value: displayValue(crop['notes']),
            maxLines: 2,
          ),
          const Spacer(),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: onEdit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _cropsPrimary,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 13),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(13),
                    ),
                  ),
                  icon: const Icon(
                    Icons.edit_outlined,
                    size: 18,
                  ),
                  label: const Text(
                    'Edit Crop',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              SizedBox(
                width: 48,
                height: 48,
                child: IconButton(
                  tooltip: 'Delete Crop',
                  onPressed: onDelete,
                  style: IconButton.styleFrom(
                    backgroundColor: const Color(0xFFFFF3F3),
                    foregroundColor: const Color(0xFFC65353),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(13),
                    ),
                  ),
                  icon: const Icon(
                    Icons.delete_outline,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CropInfoTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final int maxLines;

  const _CropInfoTile({
    required this.icon,
    required this.label,
    required this.value,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 10,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFFBFCF9),
        borderRadius: BorderRadius.circular(13),
        border: Border.all(
          color: const Color(0xFFE3E9DF),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: _cropsLight,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              size: 17,
              color: _cropsPrimary,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    color: _cropsMuted,
                    fontSize: 10,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  maxLines: maxLines,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: _cropsText,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    height: 1.35,
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

class _EmptyCrops extends StatelessWidget {
  final VoidCallback onAdd;

  const _EmptyCrops({
    required this.onAdd,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        constraints: const BoxConstraints(
          maxWidth: 460,
        ),
        margin: const EdgeInsets.all(24),
        padding: const EdgeInsets.all(30),
        decoration: _cropCardDecoration(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 82,
              height: 82,
              decoration: const BoxDecoration(
                color: _cropsLight,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.eco_outlined,
                size: 38,
                color: _cropsPrimary,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'No crops added yet',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: _cropsText,
                fontSize: 20,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Add your first crop to start managing planting, irrigation and fertilization.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: _cropsMuted,
                fontSize: 13,
                height: 1.45,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: onAdd,
              style: ElevatedButton.styleFrom(
                backgroundColor: _cropsPrimary,
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 14,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              icon: const Icon(Icons.add_rounded),
              label: const Text('Add Crop'),
            ),
          ],
        ),
      ),
    );
  }
}

class _CropsErrorState extends StatelessWidget {
  final String message;
  final Future<void> Function() onRetry;

  const _CropsErrorState({
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        constraints: const BoxConstraints(
          maxWidth: 440,
        ),
        margin: const EdgeInsets.all(24),
        padding: const EdgeInsets.all(28),
        decoration: _cropCardDecoration(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.error_outline_rounded,
              size: 56,
              color: Color(0xFFC65353),
            ),
            const SizedBox(height: 14),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: _cropsText,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 18),
            ElevatedButton.icon(
              onPressed: onRetry,
              style: ElevatedButton.styleFrom(
                backgroundColor: _cropsPrimary,
                foregroundColor: Colors.white,
                elevation: 0,
              ),
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }
}

class _CropsBackdrop extends StatelessWidget {
  const _CropsBackdrop();

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
                  Color(0xFFF3F8EC),
                ],
              ),
            ),
          ),
          PositionedDirectional(
            end: -180,
            top: 190,
            child: _CropGlow(
              size: 450,
              color: const Color(0xFFCFE6B4),
            ),
          ),
          PositionedDirectional(
            start: -190,
            bottom: -220,
            child: _CropGlow(
              size: 520,
              color: const Color(0xFFE7DFAF),
            ),
          ),
        ],
      ),
    );
  }
}

class _CropGlow extends StatelessWidget {
  final double size;
  final Color color;

  const _CropGlow({
    required this.size,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [
            color.withValues(alpha: 0.25),
            color.withValues(alpha: 0),
          ],
        ),
      ),
    );
  }
}

BoxDecoration _cropCardDecoration(double radius) {
  return BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(radius),
    border: Border.all(
      color: const Color(0xFFDCE5D8),
    ),
    boxShadow: [
      BoxShadow(
        color: _cropsDark.withValues(alpha: 0.05),
        blurRadius: 20,
        offset: const Offset(0, 7),
      ),
    ],
  );
}
