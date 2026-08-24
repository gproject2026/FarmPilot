import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../l10n/generated/app_localizations.dart';
import '../../providers/auth_provider.dart';
import '../../providers/crop_provider.dart';
import '../../providers/locale_provider.dart';
import 'add_crop_screen.dart';


String _t(
  BuildContext context,
  String english,
  String arabic,
) {
  return Localizations.localeOf(context).languageCode == 'ar'
      ? arabic
      : english;
}

String _localizedCropValue(
  BuildContext context,
  dynamic value,
) {
  if (value == null || value.toString().trim().isEmpty) {
    return _t(
      context,
      'Not specified',
      'غير محدد',
    );
  }

  final original = value.toString().trim();
  final key = original.toLowerCase();

  const arabicMap = <String, String>{
    'wheat': 'قمح',
    'strawberry': 'فراولة',
    'cucumber': 'خيار',
    'tomato': 'طماطم',
    'grain': 'حبوب',
    'fruit': 'فاكهة',
    'vegetable': 'خضروات',
    'every 3 days': 'كل 3 أيام',
    'drip irrigation every morning': 'ري بالتنقيط كل صباح',
    'daily in the early morning': 'يوميًا في الصباح الباكر',
    'npk fertilizer every 3 weeks': 'سماد NPK كل 3 أسابيع',
    'organic fertilizer every 3 weeks': 'سماد عضوي كل 3 أسابيع',
    'npk fertilizer every 14 days': 'سماد NPK كل 14 يومًا',
    'requires full sunlight and moderate humidity':
        'يحتاج إلى أشعة شمس كاملة ورطوبة معتدلة',
    'grown in open field. check regularly for powdery mildew':
        'مزروع في حقل مفتوح. افحصه بانتظام بحثًا عن البياض الدقيقي',
    'not specified': 'غير محدد',
  };

  if (Localizations.localeOf(context).languageCode == 'ar') {
    return arabicMap[key] ?? original;
  }

  return original;
}


String _localizedCropField(
  BuildContext context,
  Map<String, dynamic> crop, {
  required String legacyKey,
  required String enKey,
  required String arKey,
}) {
  final isArabic =
      Localizations.localeOf(context).languageCode == 'ar';

  final preferred =
      crop[isArabic ? arKey : enKey]?.toString().trim();

  if (preferred != null && preferred.isNotEmpty) {
    return preferred;
  }

  final fallbackOtherLanguage =
      crop[isArabic ? enKey : arKey]?.toString().trim();

  if (fallbackOtherLanguage != null &&
      fallbackOtherLanguage.isNotEmpty) {
    return fallbackOtherLanguage;
  }

  return _localizedCropValue(
    context,
    crop[legacyKey],
  );
}

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
          title: Text(_t(context, 'Delete Crop', 'حذف المحصول')),
          content: Text(
            "${_t(context, 'Are you sure you want to delete', 'هل أنت متأكد أنك تريد حذف')} ${_localizedCropField(
              context,
              crop,
              legacyKey: 'cropName',
              enKey: 'cropNameEn',
              arKey: 'cropNameAr',
            )}?",
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, false);
              },
              child: Text(_t(context, 'Cancel', 'إلغاء')),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, true);
              },
              child: Text(
                _t(context, 'Delete', 'حذف'),
                style: const TextStyle(
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
        SnackBar(
          content: Text(
            _t(
              context,
              'Authentication token not found',
              'لم يتم العثور على رمز تسجيل الدخول',
            ),
          ),
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
        SnackBar(
          content: Text(
            _t(
              context,
              'Crop deleted successfully',
              'تم حذف المحصول بنجاح',
            ),
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            cropProvider.errorMessage ??
                _t(
                  context,
                  'Failed to delete crop',
                  'فشل حذف المحصول',
                ),
          ),
        ),
      );
    }
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

  String _displayValue(dynamic value) {
    return _localizedCropValue(
      context,
      value,
    );
  }

  String _formatDate(dynamic value) {
    if (value == null || value.toString().isEmpty) {
      return _t(
        context,
        'Not specified',
        'غير محدد',
      );
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
          final l10n =
              AppLocalizations.of(context)!;
          final isArabic =
              Localizations.localeOf(context).languageCode == 'ar';

          return Stack(
            children: [
              const Positioned.fill(child: _CropsBackdrop()),
              Column(
                children: [
                  _CropsTopBar(
                    onRefresh:
                        cropProvider.isLoading
                            ? null
                            : _loadCrops,
                    onLanguage:
                        _changeLanguage,
                    isArabic:
                        isArabic,
                    l10n:
                        l10n,
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
                                      mainAxisExtent: 640,
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
  final ValueChanged<String> onLanguage;
  final bool isArabic;
  final AppLocalizations l10n;

  const _CropsTopBar({
    required this.onRefresh,
    required this.onLanguage,
    required this.isArabic,
    required this.l10n,
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
      padding: const EdgeInsets.fromLTRB(
        18,
        12,
        18,
        14,
      ),
      child: SafeArea(
        bottom: false,
        child: Row(
          children: [
            _CropsHeaderButton(
              icon: Icons.arrow_back_rounded,
              tooltip: _t(
                context,
                'Back',
                'رجوع',
              ),
              onTap: () =>
                  Navigator.pop(context),
            ),
            const SizedBox(width: 12),
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: const Color(
                  0xFFDDECB8,
                ),
                borderRadius:
                    BorderRadius.circular(
                  13,
                ),
              ),
              child: const Icon(
                Icons.eco_rounded,
                color: _cropsDark,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.appName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 19,
                      fontWeight:
                          FontWeight.w800,
                    ),
                  ),
                  Text(
                    _t(
                      context,
                      'My Crops',
                      'محاصيلي',
                    ),
                    style: const TextStyle(
                      color:
                          Color(0xCCFFFFFF),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            PopupMenuButton<String>(
              tooltip:
                  l10n.changeLanguage,
              position:
                  PopupMenuPosition.under,
              offset:
                  const Offset(0, 8),
              color:
                  const Color(0xFFF8FAF4),
              elevation: 8,
              shape: RoundedRectangleBorder(
                borderRadius:
                    BorderRadius.circular(
                  16,
                ),
              ),
              onSelected: onLanguage,
              itemBuilder: (context) {
                return [
                  PopupMenuItem<String>(
                    value: 'en',
                    child: Row(
                      mainAxisSize:
                          MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.check_rounded,
                          size: 20,
                          color: !isArabic
                              ? _cropsPrimary
                              : Colors.transparent,
                        ),
                        const SizedBox(
                          width: 10,
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
                      mainAxisSize:
                          MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.check_rounded,
                          size: 20,
                          color: isArabic
                              ? _cropsPrimary
                              : Colors.transparent,
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                        Text(
                          l10n.arabic,
                        ),
                      ],
                    ),
                  ),
                ];
              },
              child: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: Colors.white
                      .withValues(
                    alpha: 0.10,
                  ),
                  borderRadius:
                      BorderRadius.circular(
                    14,
                  ),
                ),
                alignment:
                    Alignment.center,
                child: const Icon(
                  Icons.language_rounded,
                  color: Colors.white,
                  size: 21,
                ),
              ),
            ),
            const SizedBox(width: 10),
            _CropsHeaderButton(
              icon: Icons.refresh_rounded,
              tooltip: _t(
                context,
                'Refresh',
                'تحديث',
              ),
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
              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      _t(
                        context,
                        'My Crops',
                        'محاصيلي',
                      ),
                      style: const TextStyle(
                        color: _cropsText,
                        fontSize: 24,
                        fontWeight:
                            FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _t(
                        context,
                        'Track planting dates, irrigation, fertilization and notes for every crop.',
                        'تابع مواعيد الزراعة والري والتسميد والملاحظات لكل محصول.',
                      ),
                      style: const TextStyle(
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
                  Localizations.localeOf(context).languageCode == 'ar' ? '$totalCrops محاصيل' : '$totalCrops crops',
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
                label: Text(
                  _t(
                    context,
                    'Add Crop',
                    'إضافة محصول',
                  ),
                  style: const TextStyle(
                    fontWeight:
                        FontWeight.w700,
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
    final cropName = _localizedCropField(
      context,
      crop,
      legacyKey: 'cropName',
      enKey: 'cropNameEn',
      arKey: 'cropNameAr',
    );

    final cropType = _localizedCropField(
      context,
      crop,
      legacyKey: 'cropType',
      enKey: 'cropTypeEn',
      arKey: 'cropTypeAr',
    );

    final isArabic =
        Localizations.localeOf(context).languageCode == 'ar';

    String formatNumber(dynamic value) {
      final number =
          double.tryParse(value?.toString() ?? '');

      if (number == null) {
        return '';
      }

      if (number == number.roundToDouble()) {
        return number.toStringAsFixed(0);
      }

      return number.toStringAsFixed(2);
    }

    String localizedAreaUnit(dynamic value) {
      final unit =
          value?.toString().trim().toLowerCase() ?? '';

      if (!isArabic) {
        switch (unit) {
          case 'm2':
            return 'm²';
          case 'dunum':
            return 'dunum';
          case 'hectare':
            return 'hectare';
          default:
            return value?.toString().trim() ?? '';
        }
      }

      switch (unit) {
        case 'm2':
          return 'م²';
        case 'dunum':
          return 'دونم';
        case 'hectare':
          return 'هكتار';
        default:
          return value?.toString().trim() ?? '';
      }
    }

    String localizedYieldUnit(dynamic value) {
      final unit =
          value?.toString().trim().toLowerCase() ?? '';

      if (!isArabic) {
        return value?.toString().trim() ?? '';
      }

      switch (unit) {
        case 'kg':
          return 'كغ';
        case 'g':
          return 'غ';
        case 'ton':
        case 'tons':
        case 'tonne':
        case 'tonnes':
          return 'طن';
        default:
          return value?.toString().trim() ?? '';
      }
    }

    String localizedConfidence(dynamic value) {
      final confidence =
          value?.toString().trim().toUpperCase() ?? '';

      switch (confidence) {
        case 'HIGH':
          return isArabic ? 'مرتفعة' : 'High';
        case 'MEDIUM':
          return isArabic ? 'متوسطة' : 'Medium';
        case 'LOW':
          return isArabic ? 'منخفضة' : 'Low';
        default:
          return _t(
            context,
            'Not specified',
            'غير محدد',
          );
      }
    }

    final areaText = () {
      final area =
          formatNumber(crop['area']);

      if (area.isEmpty) {
        return _t(
          context,
          'Not specified',
          'غير محدد',
        );
      }

      final unit =
          localizedAreaUnit(crop['areaUnit']);

      return unit.isEmpty
          ? area
          : '$area $unit';
    }();

    final expectedYieldText = () {
      final min =
          formatNumber(crop['expectedYieldMin']);
      final max =
          formatNumber(crop['expectedYieldMax']);

      if (min.isEmpty || max.isEmpty) {
        return _t(
          context,
          'Not specified',
          'غير محدد',
        );
      }

      final unit =
          localizedYieldUnit(crop['yieldUnit']);

      final range = min == max
          ? min
          : '$min - $max';

      return unit.isEmpty
          ? range
          : '$range $unit';
    }();

    final confidenceText =
        localizedConfidence(
      crop['yieldConfidence'],
    );

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
            label: _t(context, 'Planting date', 'تاريخ الزراعة'),
            value: formatDate(crop['plantingDate']),
          ),
          const SizedBox(height: 10),
          _CropInfoTile(
            icon: Icons.square_foot_outlined,
            label: _t(
              context,
              'Cultivated area',
              'المساحة المزروعة',
            ),
            value: areaText,
          ),
          const SizedBox(height: 10),
          _CropInfoTile(
            icon: Icons.analytics_outlined,
            label: _t(
              context,
              'Expected yield',
              'الإنتاج المتوقع',
            ),
            value: expectedYieldText,
          ),
          const SizedBox(height: 10),
          _CropInfoTile(
            icon: Icons.verified_outlined,
            label: _t(
              context,
              'Confidence',
              'مستوى الثقة',
            ),
            value: confidenceText,
          ),
          const SizedBox(height: 10),
          _CropInfoTile(
            icon: Icons.water_drop_outlined,
            label: _t(context, 'Irrigation', 'الري'),
            value: _localizedCropField(
              context,
              crop,
              legacyKey: 'irrigationSchedule',
              enKey: 'irrigationScheduleEn',
              arKey: 'irrigationScheduleAr',
            ),
          ),
          const SizedBox(height: 10),
          _CropInfoTile(
            icon: Icons.science_outlined,
            label: _t(context, 'Fertilization', 'التسميد'),
            value: _localizedCropField(
              context,
              crop,
              legacyKey: 'fertilizationSchedule',
              enKey: 'fertilizationScheduleEn',
              arKey: 'fertilizationScheduleAr',
            ),
          ),
          const SizedBox(height: 10),
          _CropInfoTile(
            icon: Icons.notes_rounded,
            label: _t(context, 'Notes', 'ملاحظات'),
            value: _localizedCropField(
              context,
              crop,
              legacyKey: 'notes',
              enKey: 'notesEn',
              arKey: 'notesAr',
            ),
            maxLines: 3,
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
                  label: Text(
                    _t(
                      context,
                      'Edit Crop',
                      'تعديل المحصول',
                    ),
                    style: const TextStyle(
                      fontWeight:
                          FontWeight.w700,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              SizedBox(
                width: 48,
                height: 48,
                child: IconButton(
                  tooltip: _t(context, 'Delete Crop', 'حذف المحصول'),
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
            Text(
              _t(
                context,
                'No crops added yet',
                'لم تتم إضافة محاصيل بعد',
              ),
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: _cropsText,
                fontSize: 20,
                fontWeight:
                    FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _t(
                context,
                'Add your first crop to start managing planting, irrigation and fertilization.',
                'أضف محصولك الأول لبدء إدارة الزراعة والري والتسميد.',
              ),
              textAlign: TextAlign.center,
              style: const TextStyle(
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
              label: Text(_t(context, 'Add Crop', 'إضافة محصول')),
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
              label: Text(_t(context, 'Try Again', 'حاول مرة أخرى')),
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
