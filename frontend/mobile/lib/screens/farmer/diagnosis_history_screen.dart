import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_constants.dart';
import '../../providers/diagnosis_provider.dart';
import 'diagnosis_result_screen.dart';

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
    final detectedPlantName =
        diagnosis['plantName']?.toString();

    if (detectedPlantName != null &&
        detectedPlantName.trim().isNotEmpty) {
      return detectedPlantName.trim();
    }

    final crop = diagnosis['crop'];

    if (crop is Map) {
      final cropName =
          crop['cropName']?.toString() ??
              crop['name']?.toString();

      if (cropName != null &&
          cropName.trim().isNotEmpty) {
        return cropName.trim();
      }
    }

    return 'Unknown Plant';
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
      return 'Unknown date';
    }

    final date = DateTime.tryParse(
      createdAt.toString(),
    );

    if (date == null) {
      return 'Unknown date';
    }

    final localDate = date.toLocal();

    const months = [
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

    final day = localDate.day;
    final month = months[
        localDate.month - 1];
    final year = localDate.year;

    return '$day $month $year';
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
        'Diagnosis ID was not found',
      );

      return;
    }

    final imageUrl = _buildImageUrl(
      diagnosis['imageUrl']?.toString(),
    );

    if (imageUrl == null) {
      _showMessage(
        'Diagnosis image was not found',
      );

      return;
    }

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
          'Could not download diagnosis image',
        );
      }

      final imageBytes =
          Uint8List.fromList(
        responseData,
      );

      final diseaseName =
          diagnosis['diseaseName']
                  ?.toString() ??
              'Unknown Diagnosis';

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
                  'No description available.',
          'causes':
              diagnosis['causes']
                      ?.toString() ??
                  'No causes available.',
          'treatment':
              diagnosis['treatment']
                      ?.toString() ??
                  'No treatment available.',
          'prevention':
              diagnosis['prevention']
                      ?.toString() ??
                  'No prevention information available.',
          'needsExpertReview': !isHealthy,
        },
        'diagnosis': diagnosis,
        'disclaimer':
            'This is a preliminary AI-assisted assessment and not a laboratory diagnosis. Consult an agricultural specialist before applying hazardous chemicals.',
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
                                        diagnosis['diseaseName']
                                                ?.toString() ??
                                            'Unknown Diagnosis';

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
                                      onOpen: () =>
                                          _openDiagnosis(
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
  final Future<void> Function()?
      onRefresh;

  const _HistoryTopBar({
    required this.onBack,
    required this.onRefresh,
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
              icon: Icons
                  .arrow_back_rounded,
              tooltip: 'Back',
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
                color:
                    const Color(
                  0xFFDDECB8,
                ),
                borderRadius:
                    BorderRadius
                        .circular(
                  13,
                ),
              ),
              child:
                  const Icon(
                Icons.eco_rounded,
                color:
                    _historyDark,
              ),
            ),
            const SizedBox(
              width: 10,
            ),
            const Expanded(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment
                        .start,
                children: [
                  Text(
                    'FarmPilot',
                    style:
                        TextStyle(
                      color:
                          Colors.white,
                      fontSize:
                          19,
                      fontWeight:
                          FontWeight
                              .w800,
                    ),
                  ),
                  Text(
                    'Diagnosis History',
                    style:
                        TextStyle(
                      color:
                          Color(
                        0xCCFFFFFF,
                      ),
                      fontSize:
                          12,
                    ),
                  ),
                ],
              ),
            ),
            _HistoryHeaderButton(
              icon:
                  Icons.refresh_rounded,
              tooltip:
                  'Refresh',
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
              const Row(
            children: [
              _HistoryHeroIcon(),
              SizedBox(
                width: 16,
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment
                          .start,
                  children: [
                    Text(
                      'Diagnosis History',
                      style:
                          TextStyle(
                        color:
                            _historyText,
                        fontSize:
                            24,
                        fontWeight:
                            FontWeight
                                .w800,
                      ),
                    ),
                    SizedBox(
                      height: 4,
                    ),
                    Text(
                      'Review previous AI plant analyses and reopen detailed results.',
                      style:
                          TextStyle(
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
              '$totalDiagnoses diagnoses',
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
  final VoidCallback onOpen;

  const _DiagnosisHistoryCard({
    required this.diagnosis,
    required this.cropName,
    required this.diseaseName,
    required this.confidence,
    required this.date,
    required this.imageUrl,
    required this.statusColor,
    required this.isOpening,
    required this.onOpen,
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
            isOpening
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
                              width:
                                  20,
                              height:
                                  20,
                              child:
                                  CircularProgressIndicator(
                                strokeWidth:
                                    2,
                                color:
                                    _historyPrimary,
                              ),
                            )
                          else
                            const Icon(
                              Icons
                                  .arrow_forward_ios_rounded,
                              size:
                                  15,
                              color:
                                  _historyMuted,
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
        child: const Column(
          mainAxisSize:
              MainAxisSize.min,
          children: [
            CircleAvatar(
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
            SizedBox(
              height: 16,
            ),
            Text(
              'No diagnoses yet',
              textAlign:
                  TextAlign.center,
              style:
                  TextStyle(
                color:
                    _historyText,
                fontSize:
                    20,
                fontWeight:
                    FontWeight
                        .w800,
              ),
            ),
            SizedBox(
              height: 8,
            ),
            Text(
              'Your plant diagnosis history will appear here.',
              textAlign:
                  TextAlign.center,
              style:
                  TextStyle(
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
                  const Text(
                'Try Again',
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
