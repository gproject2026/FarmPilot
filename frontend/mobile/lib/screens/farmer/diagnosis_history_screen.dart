import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../l10n/generated/app_localizations.dart';

import '../../core/constants/app_constants.dart';
import '../../providers/diagnosis_provider.dart';
import '../../providers/locale_provider.dart';
import 'diagnosis_result_screen.dart';

String _t(
  BuildContext context,
  String english,
  String arabic,
) {
  return Localizations.localeOf(context).languageCode == 'ar'
      ? arabic
      : english;
}

class DiagnosisHistoryScreen extends StatefulWidget {
  const DiagnosisHistoryScreen({
    super.key,
  });

  @override
  State<DiagnosisHistoryScreen> createState() =>
      _DiagnosisHistoryScreenState();
}

class _DiagnosisHistoryScreenState
    extends State<DiagnosisHistoryScreen> {
  final Dio _dio = Dio();

  String? _openingDiagnosisId;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback(
      (_) {
        _loadDiagnoses();
      },
    );
  }

  Future<void> _loadDiagnoses() async {
    await Provider.of<DiagnosisProvider>(
      context,
      listen: false,
    ).loadMyDiagnoses();
  }

  String? _buildImageUrl(
    String? imageUrl,
  ) {
    if (imageUrl == null ||
        imageUrl.trim().isEmpty) {
      return null;
    }

    final value = imageUrl.trim();

    if (value.startsWith('http://') ||
        value.startsWith('https://')) {
      return value;
    }

    if (value.startsWith('/')) {
      return '${AppConstants.baseUrl}$value';
    }

    return '${AppConstants.baseUrl}/$value';
  }

  String _getCropName(
    Map<String, dynamic> diagnosis,
  ) {
    final isArabic =
        Localizations.localeOf(context).languageCode == 'ar';

    final localizedDetectedName = isArabic
        ? diagnosis['plantNameAr']?.toString()
        : diagnosis['plantNameEn']?.toString();

    if (localizedDetectedName != null &&
        localizedDetectedName.trim().isNotEmpty) {
      return localizedDetectedName.trim();
    }

    final detectedPlantName =
        diagnosis['plantName']?.toString();

    final crop = diagnosis['crop'];

    if (crop is Map) {
      final localizedCropName = isArabic
          ? crop['cropNameAr']?.toString()
          : crop['cropNameEn']?.toString();

      if (localizedCropName != null &&
          localizedCropName.trim().isNotEmpty) {
        return localizedCropName.trim();
      }

      final cropName =
          crop['cropName']?.toString() ??
              crop['name']?.toString();

      if (cropName != null &&
          cropName.trim().isNotEmpty) {
        return cropName.trim();
      }
    }

    if (detectedPlantName != null &&
        detectedPlantName.trim().isNotEmpty) {
      return detectedPlantName.trim();
    }

    return _t(
      context,
      'Unknown Plant',
      'نبات غير معروف',
    );
  }

  String _getDiseaseName(
    Map<String, dynamic> diagnosis,
  ) {
    final isArabic =
        Localizations.localeOf(context).languageCode == 'ar';

    final localizedDisease = isArabic
        ? diagnosis['diseaseNameAr']?.toString()
        : diagnosis['diseaseNameEn']?.toString();

    if (localizedDisease != null &&
        localizedDisease.trim().isNotEmpty) {
      return localizedDisease.trim();
    }

    final diseaseName =
        diagnosis['diseaseName']?.toString();

    if (diseaseName != null &&
        diseaseName.trim().isNotEmpty) {
      return diseaseName.trim();
    }

    return _t(
      context,
      'Unknown Diagnosis',
      'تشخيص غير معروف',
    );
  }

  double _getConfidence(
    Map<String, dynamic> diagnosis,
  ) {
    final value = double.tryParse(
          diagnosis['confidence']?.toString() ??
              '0',
        ) ??
        0;

    return value.clamp(0, 100).toDouble();
  }

  String _formatDate(
    dynamic createdAt,
  ) {
    if (createdAt == null) {
      return _t(
        context,
        'Unknown date',
        'تاريخ غير معروف',
      );
    }

    final date = DateTime.tryParse(
      createdAt.toString(),
    );

    if (date == null) {
      return _t(
        context,
        'Unknown date',
        'تاريخ غير معروف',
      );
    }

    final localDate = date.toLocal();

    const monthsEn = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];

    const monthsAr = [
      'يناير',
      'فبراير',
      'مارس',
      'أبريل',
      'مايو',
      'يونيو',
      'يوليو',
      'أغسطس',
      'سبتمبر',
      'أكتوبر',
      'نوفمبر',
      'ديسمبر',
    ];

    final isArabic =
        Localizations.localeOf(context).languageCode == 'ar';

    final month = isArabic
        ? monthsAr[localDate.month - 1]
        : monthsEn[localDate.month - 1];

    return '${localDate.day} $month ${localDate.year}';
  }

  bool _isHealthyDiagnosis(
    String diseaseName,
  ) {
    final value =
        diseaseName.toLowerCase();

    return value.contains(
          'no clear disease',
        ) ||
        value.contains(
          'healthy',
        );
  }

  Color _getStatusColor(
    String diseaseName,
  ) {
    if (_isHealthyDiagnosis(
      diseaseName,
    )) {
      return Colors.green;
    }

    if (diseaseName
        .toLowerCase()
        .contains('image unclear')) {
      return Colors.blueGrey;
    }

    if (diseaseName
        .toLowerCase()
        .contains('no plant detected')) {
      return Colors.blueGrey;
    }

    return Colors.orange;
  }

  Future<void> _openDiagnosis(
    Map<String, dynamic> diagnosis,
  ) async {
    final diagnosisId =
        diagnosis['id']?.toString();

    if (diagnosisId == null ||
        diagnosisId.isEmpty) {
      _showMessage(
        _t(context, 'Diagnosis ID was not found', 'لم يتم العثور على معرف التشخيص'),
      );

      return;
    }

    final imageUrl = _buildImageUrl(
      diagnosis['imageUrl']?.toString(),
    );

    if (imageUrl == null) {
      _showMessage(
        _t(context, 'Diagnosis image was not found', 'لم يتم العثور على صورة التشخيص'),
      );

      return;
    }

    final downloadErrorMessage = _t(
      context,
      'Could not download diagnosis image',
      'تعذر تنزيل صورة التشخيص',
    );

    final noDescriptionMessage = _t(
      context,
      'No description available.',
      'لا يوجد وصف متاح.',
    );

    final noCausesMessage = _t(
      context,
      'No causes available.',
      'لا توجد أسباب متاحة.',
    );

    final noTreatmentMessage = _t(
      context,
      'No treatment available.',
      'لا يوجد علاج متاح.',
    );

    final noPreventionMessage = _t(
      context,
      'No prevention information available.',
      'لا توجد معلومات وقاية متاحة.',
    );

    final disclaimerMessage = _t(
      context,
      'This is a preliminary AI-assisted assessment and not a laboratory diagnosis. Consult an agricultural specialist before applying hazardous chemicals.',
      'هذا تقييم أولي بمساعدة الذكاء الاصطناعي وليس تشخيصًا مخبريًا. استشر مختصًا زراعيًا قبل استخدام أي مواد كيميائية خطرة.',
    );

    final diseaseName =
        _getDiseaseName(diagnosis);

    final confidence =
        _getConfidence(
      diagnosis,
    );

    final cropName =
        _getCropName(
      diagnosis,
    );

    final isHealthy =
        _isHealthyDiagnosis(
      diseaseName,
    );

    setState(() {
      _openingDiagnosisId = diagnosisId;
    });

    try {
      final response =
          await _dio.get<List<int>>(
        imageUrl,
        options: Options(
          responseType: ResponseType.bytes,
        ),
      );

      final responseData = response.data;

      if (responseData == null ||
          responseData.isEmpty) {
        throw Exception(
          downloadErrorMessage,
        );
      }

      final imageBytes =
          Uint8List.fromList(
        responseData,
      );

      final result = <String, dynamic>{
        'analysis': {
          'isPlant': !diseaseName
              .toLowerCase()
              .contains(
                'no plant detected',
              ),
          'isImageClear': !diseaseName
              .toLowerCase()
              .contains(
                'image unclear',
              ),
          'isHealthy': isHealthy,
          'plantName': cropName,
          'diseaseName': diseaseName,
          'confidence': confidence,
          'severity':
              isHealthy ? 'none' : 'unknown',
          'visibleSymptoms': <String>[],
          'description':
              diagnosis['description']
                      ?.toString() ??
                  noDescriptionMessage,
          'causes':
              diagnosis['causes']
                      ?.toString() ??
                  noCausesMessage,
          'treatment':
              diagnosis['treatment']
                      ?.toString() ??
                  noTreatmentMessage,
          'prevention':
              diagnosis['prevention']
                      ?.toString() ??
                  noPreventionMessage,
          'needsExpertReview': !isHealthy,
        },
        'diagnosis': diagnosis,
        'disclaimer':
            disclaimerMessage,
      };

      if (!mounted) {
        return;
      }

      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) =>
              DiagnosisResultScreen(
            result: result,
            imageBytes: imageBytes,
          ),
        ),
      );
    } catch (error) {
      if (!mounted) {
        return;
      }

      _showMessage(
        error
            .toString()
            .replaceFirst(
              'Exception: ',
              '',
            ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _openingDiagnosisId = null;
        });
      }
    }
  }

  Future<void> _deleteDiagnosis(
    Map<String, dynamic> diagnosis,
  ) async {
    final diagnosisId =
        diagnosis['id']?.toString();

    if (diagnosisId == null ||
        diagnosisId.isEmpty) {
      _showMessage(
        _t(
          context,
          'Diagnosis ID was not found',
          'لم يتم العثور على معرف التشخيص',
        ),
      );
      return;
    }

    final shouldDelete =
        await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(
            _t(
              context,
              'Delete Diagnosis',
              'حذف التشخيص',
            ),
          ),
          content: Text(
            _t(
              context,
              'Are you sure you want to delete this diagnosis?',
              'هل أنت متأكد أنك تريد حذف هذا التشخيص؟',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(
                  dialogContext,
                  false,
                );
              },
              child: Text(
                _t(
                  context,
                  'Cancel',
                  'إلغاء',
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(
                  dialogContext,
                  true,
                );
              },
              child: Text(
                _t(
                  context,
                  'Delete',
                  'حذف',
                ),
                style: const TextStyle(
                  color: Colors.red,
                  fontWeight:
                      FontWeight.w700,
                ),
              ),
            ),
          ],
        );
      },
    );

    if (shouldDelete != true ||
        !mounted) {
      return;
    }

    final diagnosisProvider =
        Provider.of<DiagnosisProvider>(
      context,
      listen: false,
    );

    final success =
        await diagnosisProvider
            .deleteDiagnosis(
      diagnosisId,
    );

    if (!mounted) {
      return;
    }

    if (success) {
      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text(
            _t(
              context,
              'Diagnosis deleted successfully',
              'تم حذف التشخيص بنجاح',
            ),
          ),
          backgroundColor:
              Colors.green,
        ),
      );
    } else {
      _showMessage(
        diagnosisProvider.errorMessage ??
            _t(
              context,
              'Failed to delete diagnosis',
              'فشل حذف التشخيص',
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

  void _showMessage(
    String message,
  ) {
    ScaffoldMessenger.of(context)
        .showSnackBar(
      SnackBar(
        content: Text(
          message,
        ),
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  Widget build(
    BuildContext context,
  ) {
    final diagnosisProvider =
        Provider.of<DiagnosisProvider>(
      context,
    );

    final diagnoses =
        diagnosisProvider.diagnoses;

    final l10n =
        AppLocalizations.of(context)!;

    final isArabic =
        Localizations.localeOf(context).languageCode == 'ar';

    return Scaffold(
      backgroundColor:
          const Color(0xFFF8FAF4),
      body: Stack(
        children: [
          const Positioned.fill(
            child:
                _HistoryBackdrop(),
          ),
          Column(
            children: [
              _HistoryTopBar(
                onBack: () =>
                    Navigator.pop(
                  context,
                ),
                onRefresh:
                    diagnosisProvider
                            .isLoading
                        ? null
                        : _loadDiagnoses,
                onLanguage:
                    _changeLanguage,
                isArabic:
                    isArabic,
                l10n:
                    l10n,
              ),
              Expanded(
                child:
                    RefreshIndicator(
                  onRefresh:
                      _loadDiagnoses,
                  color:
                      _historyPrimary,
                  child:
                      CustomScrollView(
                    physics:
                        const AlwaysScrollableScrollPhysics(),
                    slivers: [
                      SliverToBoxAdapter(
                        child: Center(
                          child:
                              ConstrainedBox(
                            constraints:
                                const BoxConstraints(
                              maxWidth:
                                  1320,
                            ),
                            child:
                                Padding(
                              padding:
                                  const EdgeInsets
                                      .fromLTRB(
                                24,
                                26,
                                24,
                                18,
                              ),
                              child:
                                  _HistoryHero(
                                totalDiagnoses:
                                    diagnoses
                                        .length,
                              ),
                            ),
                          ),
                        ),
                      ),
                      if (diagnosisProvider
                              .isLoading &&
                          diagnoses.isEmpty)
                        const SliverFillRemaining(
                          hasScrollBody:
                              false,
                          child: Center(
                            child:
                                CircularProgressIndicator(
                              color:
                                  _historyPrimary,
                            ),
                          ),
                        )
                      else if (diagnosisProvider
                                  .errorMessage !=
                              null &&
                          diagnoses.isEmpty)
                        SliverFillRemaining(
                          hasScrollBody:
                              false,
                          child:
                              _HistoryErrorState(
                            message:
                                diagnosisProvider
                                    .errorMessage!,
                            onRetry:
                                _loadDiagnoses,
                          ),
                        )
                      else if (diagnoses
                          .isEmpty)
                        const SliverFillRemaining(
                          hasScrollBody:
                              false,
                          child:
                              _HistoryEmptyState(),
                        )
                      else
                        SliverPadding(
                          padding:
                              const EdgeInsets
                                  .fromLTRB(
                            24,
                            0,
                            24,
                            42,
                          ),
                          sliver:
                              SliverLayoutBuilder(
                            builder: (
                              context,
                              constraints,
                            ) {
                              final width =
                                  constraints
                                      .crossAxisExtent;

                              final crossAxisCount =
                                  width >= 1180
                                      ? 3
                                      : width >= 760
                                          ? 2
                                          : 1;

                              return SliverGrid(
                                delegate:
                                    SliverChildBuilderDelegate(
                                  (
                                    context,
                                    index,
                                  ) {
                                    final rawDiagnosis =
                                        diagnoses[
                                            index];

                                    if (rawDiagnosis
                                        is! Map) {
                                      return const SizedBox
                                          .shrink();
                                    }

                                    final diagnosis =
                                        Map<String,
                                                dynamic>.from(
                                      rawDiagnosis,
                                    );

                                    final diseaseName =
                                        _getDiseaseName(
                                      diagnosis,
                                    );

                                    return _DiagnosisHistoryCard(
                                      diagnosis:
                                          diagnosis,
                                      cropName:
                                          _getCropName(
                                        diagnosis,
                                      ),
                                      diseaseName:
                                          diseaseName,
                                      confidence:
                                          _getConfidence(
                                        diagnosis,
                                      ),
                                      date:
                                          _formatDate(
                                        diagnosis[
                                            'createdAt'],
                                      ),
                                      imageUrl:
                                          _buildImageUrl(
                                        diagnosis[
                                                'imageUrl']
                                            ?.toString(),
                                      ),
                                      statusColor:
                                          _getStatusColor(
                                        diseaseName,
                                      ),
                                      isOpening:
                                          _openingDiagnosisId ==
                                              diagnosis[
                                                      'id']
                                                  ?.toString(),
                                      isDeleting:
                                          diagnosisProvider
                                                  .deletingDiagnosisId ==
                                              diagnosis[
                                                      'id']
                                                  ?.toString(),
                                      onOpen: () =>
                                          _openDiagnosis(
                                        diagnosis,
                                      ),
                                      onDelete: () =>
                                          _deleteDiagnosis(
                                        diagnosis,
                                      ),
                                    );
                                  },
                                  childCount:
                                      diagnoses
                                          .length,
                                ),
                                gridDelegate:
                                    SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount:
                                      crossAxisCount,
                                  crossAxisSpacing:
                                      16,
                                  mainAxisSpacing:
                                      16,
                                  mainAxisExtent:
                                      310,
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
      ),
    );
  }
}

const _historyDark =
    Color(0xFF173F24);
const _historyPrimary =
    Color(0xFF2F743F);
const _historyLight =
    Color(0xFFEAF3DF);
const _historyText =
    Color(0xFF1D2C21);
const _historyMuted =
    Color(0xFF6C786E);

class _HistoryTopBar
    extends StatelessWidget {
  final VoidCallback onBack;
  final Future<void> Function()? onRefresh;
  final ValueChanged<String> onLanguage;
  final bool isArabic;
  final AppLocalizations l10n;

  const _HistoryTopBar({
    required this.onBack,
    required this.onRefresh,
    required this.onLanguage,
    required this.isArabic,
    required this.l10n,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    return Container(
      decoration:
          const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xFF123A22),
            Color(0xFF205A34),
            Color(0xFF2E6F40),
          ],
        ),
      ),
      padding:
          const EdgeInsets.fromLTRB(
        18,
        12,
        18,
        14,
      ),
      child: SafeArea(
        bottom: false,
        child: Row(
          children: [
            _HistoryHeaderButton(
              icon: Icons.arrow_back_rounded,
              tooltip: _t(
                context,
                'Back',
                'رجوع',
              ),
              onTap: onBack,
            ),
            const SizedBox(
              width: 12,
            ),
            Container(
              width: 44,
              height: 44,
              decoration:
                  BoxDecoration(
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
                color:
                    _historyDark,
              ),
            ),
            const SizedBox(
              width: 10,
            ),
            Expanded(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.appName,
                    style:
                        const TextStyle(
                      color:
                          Colors.white,
                      fontSize: 19,
                      fontWeight:
                          FontWeight.w800,
                    ),
                  ),
                  Text(
                    _t(
                      context,
                      'Diagnosis History',
                      'سجل التشخيصات',
                    ),
                    style:
                        const TextStyle(
                      color: Color(
                        0xCCFFFFFF,
                      ),
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
              onSelected:
                  onLanguage,
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
                              ? _historyPrimary
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
                              ? _historyPrimary
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
                decoration:
                    BoxDecoration(
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
                  color:
                      Colors.white,
                  size: 21,
                ),
              ),
            ),
            const SizedBox(
              width: 10,
            ),
            _HistoryHeaderButton(
              icon:
                  Icons.refresh_rounded,
              tooltip: _t(
                context,
                'Refresh',
                'تحديث',
              ),
              onTap:
                  onRefresh,
            ),
          ],
        ),
      ),
    );
  }
}

class _HistoryHeaderButton
    extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback? onTap;

  const _HistoryHeaderButton({
    required this.icon,
    required this.tooltip,
    required this.onTap,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color:
            Colors.white.withValues(
          alpha:
              onTap == null
                  ? 0.05
                  : 0.10,
        ),
        borderRadius:
            BorderRadius.circular(
          14,
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius:
              BorderRadius.circular(
            14,
          ),
          child: SizedBox(
            width: 44,
            height: 44,
            child: Icon(
              icon,
              color:
                  onTap == null
                      ? Colors
                          .white54
                      : Colors
                          .white,
              size: 21,
            ),
          ),
        ),
      ),
    );
  }
}

class _HistoryHero
    extends StatelessWidget {
  final int totalDiagnoses;

  const _HistoryHero({
    required this.totalDiagnoses,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    return Container(
      width:
          double.infinity,
      padding:
          const EdgeInsets.all(
        24,
      ),
      decoration:
          _historyCardDecoration(
        24,
      ),
      child: LayoutBuilder(
        builder: (
          context,
          constraints,
        ) {
          final heading =
              Row(
            children: [
              const _HistoryHeroIcon(),
              const SizedBox(
                width: 16,
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment
                          .start,
                  children: [
                    Text(
                      _t(
                        context,
                        'Diagnosis History',
                        'سجل التشخيصات',
                      ),
                      style:
                          const TextStyle(
                        color:
                            _historyText,
                        fontSize:
                            24,
                        fontWeight:
                            FontWeight
                                .w800,
                      ),
                    ),
                    const SizedBox(
                      height: 4,
                    ),
                    Text(
                      _t(
                        context,
                        'Review previous AI plant analyses and reopen detailed results.',
                        'راجع تحليلات النباتات السابقة بالذكاء الاصطناعي وافتح النتائج التفصيلية مجددًا.',
                      ),
                      style:
                          const TextStyle(
                        color:
                            _historyMuted,
                        fontSize:
                            13,
                        height:
                            1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );

          final count =
              Container(
            padding:
                const EdgeInsets
                    .symmetric(
              horizontal: 14,
              vertical: 10,
            ),
            decoration:
                BoxDecoration(
              color:
                  const Color(
                0xFFF1F6E9,
              ),
              borderRadius:
                  BorderRadius
                      .circular(
                15,
              ),
            ),
            child: Text(
              Localizations.localeOf(context).languageCode == 'ar'
                  ? '$totalDiagnoses تشخيصات'
                  : '$totalDiagnoses diagnoses',
              style:
                  const TextStyle(
                color:
                    _historyPrimary,
                fontSize:
                    12,
                fontWeight:
                    FontWeight
                        .w700,
              ),
            ),
          );

          if (constraints
                  .maxWidth <
              680) {
            return Column(
              crossAxisAlignment:
                  CrossAxisAlignment
                      .start,
              children: [
                heading,
                const SizedBox(
                  height: 18,
                ),
                count,
              ],
            );
          }

          return Row(
            children: [
              Expanded(
                child:
                    heading,
              ),
              const SizedBox(
                width: 18,
              ),
              count,
            ],
          );
        },
      ),
    );
  }
}

class _HistoryHeroIcon
    extends StatelessWidget {
  const _HistoryHeroIcon();

  @override
  Widget build(
    BuildContext context,
  ) {
    return Container(
      width: 58,
      height: 58,
      decoration:
          BoxDecoration(
        color:
            _historyLight,
        borderRadius:
            BorderRadius.circular(
          17,
        ),
      ),
      child:
          const Icon(
        Icons
            .history_rounded,
        color:
            _historyPrimary,
        size: 28,
      ),
    );
  }
}

class _DiagnosisHistoryCard
    extends StatelessWidget {
  final Map<String, dynamic>
      diagnosis;
  final String cropName;
  final String diseaseName;
  final double confidence;
  final String date;
  final String? imageUrl;
  final Color statusColor;
  final bool isOpening;
  final bool isDeleting;
  final VoidCallback onOpen;
  final VoidCallback onDelete;

  const _DiagnosisHistoryCard({
    required this.diagnosis,
    required this.cropName,
    required this.diseaseName,
    required this.confidence,
    required this.date,
    required this.imageUrl,
    required this.statusColor,
    required this.isOpening,
    required this.isDeleting,
    required this.onOpen,
    required this.onDelete,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    return Material(
      color:
          Colors.transparent,
      child: InkWell(
        onTap:
            isOpening || isDeleting
                ? null
                : onOpen,
        borderRadius:
            BorderRadius.circular(
          22,
        ),
        child: Ink(
          decoration:
              _historyCardDecoration(
            22,
          ),
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment
                    .start,
            children: [
              ClipRRect(
                borderRadius:
                    const BorderRadius
                        .vertical(
                  top:
                      Radius.circular(
                    21,
                  ),
                ),
                child: SizedBox(
                  width:
                      double.infinity,
                  height: 145,
                  child:
                      imageUrl ==
                              null
                          ? Container(
                              color:
                                  const Color(
                                0xFFF1F5EE,
                              ),
                              child:
                                  const Icon(
                                Icons
                                    .image_not_supported_outlined,
                                size:
                                    46,
                                color:
                                    _historyMuted,
                              ),
                            )
                          : Image.network(
                              imageUrl!,
                              fit:
                                  BoxFit.cover,
                              errorBuilder:
                                  (
                                context,
                                error,
                                stackTrace,
                              ) {
                                return Container(
                                  color:
                                      const Color(
                                    0xFFF1F5EE,
                                  ),
                                  child:
                                      const Icon(
                                    Icons
                                        .broken_image_outlined,
                                    size:
                                        46,
                                    color:
                                        _historyMuted,
                                  ),
                                );
                              },
                            ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding:
                      const EdgeInsets
                          .all(
                    16,
                  ),
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment
                            .start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child:
                                Text(
                              cropName,
                              maxLines:
                                  1,
                              overflow:
                                  TextOverflow
                                      .ellipsis,
                              style:
                                  const TextStyle(
                                color:
                                    _historyText,
                                fontSize:
                                    17,
                                fontWeight:
                                    FontWeight
                                        .w800,
                              ),
                            ),
                          ),
                          if (isOpening)
                            const SizedBox(
                              width: 20,
                              height: 20,
                              child:
                                  CircularProgressIndicator(
                                strokeWidth: 2,
                                color:
                                    _historyPrimary,
                              ),
                            )
                          else
                            IconButton(
                              tooltip: _t(
                                context,
                                'Delete Diagnosis',
                                'حذف التشخيص',
                              ),
                              onPressed:
                                  isDeleting
                                      ? null
                                      : onDelete,
                              style:
                                  IconButton.styleFrom(
                                backgroundColor:
                                    const Color(
                                  0xFFFFF3F3,
                                ),
                                foregroundColor:
                                    const Color(
                                  0xFFC65353,
                                ),
                              ),
                              icon: isDeleting
                                  ? const SizedBox(
                                      width: 17,
                                      height: 17,
                                      child:
                                          CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color:
                                            Color(
                                          0xFFC65353,
                                        ),
                                      ),
                                    )
                                  : const Icon(
                                      Icons
                                          .delete_outline_rounded,
                                      size: 18,
                                    ),
                            ),
                        ],
                      ),
                      const SizedBox(
                        height: 8,
                      ),
                      Container(
                        padding:
                            const EdgeInsets
                                .symmetric(
                          horizontal:
                              10,
                          vertical:
                              6,
                        ),
                        decoration:
                            BoxDecoration(
                          color:
                              statusColor
                                  .withValues(
                            alpha:
                                0.10,
                          ),
                          borderRadius:
                              BorderRadius
                                  .circular(
                            14,
                          ),
                        ),
                        child: Text(
                          diseaseName,
                          maxLines: 1,
                          overflow:
                              TextOverflow
                                  .ellipsis,
                          style:
                              TextStyle(
                            color:
                                statusColor,
                            fontSize:
                                11,
                            fontWeight:
                                FontWeight
                                    .w800,
                          ),
                        ),
                      ),
                      const Spacer(),
                      Row(
                        children: [
                          Icon(
                            Icons
                                .analytics_outlined,
                            size:
                                16,
                            color:
                                statusColor,
                          ),
                          const SizedBox(
                            width: 5,
                          ),
                          Text(
                            '${confidence.toStringAsFixed(0)}%',
                            style:
                                TextStyle(
                              color:
                                  statusColor,
                              fontWeight:
                                  FontWeight
                                      .w700,
                              fontSize:
                                  12,
                            ),
                          ),
                          const SizedBox(
                            width: 14,
                          ),
                          const Icon(
                            Icons
                                .calendar_today_outlined,
                            size:
                                14,
                            color:
                                _historyMuted,
                          ),
                          const SizedBox(
                            width: 5,
                          ),
                          Expanded(
                            child:
                                Text(
                              date,
                              maxLines:
                                  1,
                              overflow:
                                  TextOverflow
                                      .ellipsis,
                              style:
                                  const TextStyle(
                                color:
                                    _historyMuted,
                                fontSize:
                                    12,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HistoryEmptyState
    extends StatelessWidget {
  const _HistoryEmptyState();

  @override
  Widget build(
    BuildContext context,
  ) {
    return Center(
      child: Container(
        constraints:
            const BoxConstraints(
          maxWidth: 460,
        ),
        margin:
            const EdgeInsets.all(
          24,
        ),
        padding:
            const EdgeInsets.all(
          30,
        ),
        decoration:
            _historyCardDecoration(
          24,
        ),
        child: Column(
          mainAxisSize:
              MainAxisSize.min,
          children: [
            const CircleAvatar(
              radius: 40,
              backgroundColor:
                  _historyLight,
              child: Icon(
                Icons
                    .health_and_safety_outlined,
                size: 38,
                color:
                    _historyPrimary,
              ),
            ),
            const SizedBox(
              height: 16,
            ),
            Text(
              _t(
                context,
                'No diagnoses yet',
                'لا توجد تشخيصات بعد',
              ),
              textAlign:
                  TextAlign.center,
              style:
                  const TextStyle(
                color:
                    _historyText,
                fontSize:
                    20,
                fontWeight:
                    FontWeight
                        .w800,
              ),
            ),
            const SizedBox(
              height: 8,
            ),
            Text(
              _t(
                context,
                'Your plant diagnosis history will appear here.',
                'سيظهر سجل تشخيصات النباتات هنا.',
              ),
              textAlign:
                  TextAlign.center,
              style:
                  const TextStyle(
                color:
                    _historyMuted,
                fontSize:
                    13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HistoryErrorState
    extends StatelessWidget {
  final String message;
  final Future<void> Function()
      onRetry;

  const _HistoryErrorState({
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    return Center(
      child: Container(
        constraints:
            const BoxConstraints(
          maxWidth: 440,
        ),
        margin:
            const EdgeInsets.all(
          24,
        ),
        padding:
            const EdgeInsets.all(
          28,
        ),
        decoration:
            _historyCardDecoration(
          24,
        ),
        child: Column(
          mainAxisSize:
              MainAxisSize.min,
          children: [
            const Icon(
              Icons
                  .error_outline_rounded,
              size: 56,
              color:
                  Color(
                0xFFC65353,
              ),
            ),
            const SizedBox(
              height: 14,
            ),
            Text(
              message,
              textAlign:
                  TextAlign.center,
              style:
                  const TextStyle(
                color:
                    _historyText,
              ),
            ),
            const SizedBox(
              height: 18,
            ),
            ElevatedButton.icon(
              onPressed:
                  onRetry,
              style:
                  ElevatedButton
                      .styleFrom(
                backgroundColor:
                    _historyPrimary,
                foregroundColor:
                    Colors.white,
                elevation: 0,
              ),
              icon:
                  const Icon(
                Icons
                    .refresh_rounded,
              ),
              label:
                  Text(
                _t(
                  context,
                  'Try Again',
                  'حاول مرة أخرى',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HistoryBackdrop
    extends StatelessWidget {
  const _HistoryBackdrop();

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
                    Alignment
                        .topCenter,
                end:
                    Alignment
                        .bottomCenter,
                colors: [
                  Color(
                    0xFFF8FAF4,
                  ),
                  Color(
                    0xFFFFFCF5,
                  ),
                  Color(
                    0xFFF3F8EC,
                  ),
                ],
              ),
            ),
          ),
          PositionedDirectional(
            end: -180,
            top: 190,
            child:
                _HistoryGlow(
              size: 450,
              color:
                  const Color(
                0xFFCFE6B4,
              ),
            ),
          ),
          PositionedDirectional(
            start: -190,
            bottom: -220,
            child:
                _HistoryGlow(
              size: 520,
              color:
                  const Color(
                0xFFE7DFAF,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HistoryGlow
    extends StatelessWidget {
  final double size;
  final Color color;

  const _HistoryGlow({
    required this.size,
    required this.color,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    return Container(
      width: size,
      height: size,
      decoration:
          BoxDecoration(
        shape:
            BoxShape.circle,
        gradient:
            RadialGradient(
          colors: [
            color.withValues(
              alpha: 0.25,
            ),
            color.withValues(
              alpha: 0,
            ),
          ],
        ),
      ),
    );
  }
}

BoxDecoration
    _historyCardDecoration(
  double radius,
) {
  return BoxDecoration(
    color:
        Colors.white,
    borderRadius:
        BorderRadius.circular(
      radius,
    ),
    border: Border.all(
      color:
          const Color(
        0xFFDCE5D8,
      ),
    ),
    boxShadow: [
      BoxShadow(
        color:
            _historyDark
                .withValues(
          alpha: 0.05,
        ),
        blurRadius:
            20,
        offset:
            const Offset(
          0,
          7,
        ),
      ),
    ],
  );
}
