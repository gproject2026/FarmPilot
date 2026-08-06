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

    return Scaffold(
      backgroundColor:
          const Color(0xFFF5F7F4),
      appBar: AppBar(
        title: const Text(
          'Diagnosis History',
        ),
        backgroundColor:
            Colors.green,
        foregroundColor:
            Colors.white,
      ),
      body: RefreshIndicator(
        onRefresh: _loadDiagnoses,
        child: _buildBody(
          diagnosisProvider,
        ),
      ),
    );
  }

  Widget _buildBody(
    DiagnosisProvider diagnosisProvider,
  ) {
    if (diagnosisProvider.isLoading &&
        diagnosisProvider
            .diagnoses.isEmpty) {
      return  ListView(
        physics:
            AlwaysScrollableScrollPhysics(),
        children: [
          SizedBox(
            height: 280,
          ),
          Center(
            child:
                CircularProgressIndicator(),
          ),
        ],
      );
    }

    if (diagnosisProvider.errorMessage !=
            null &&
        diagnosisProvider
            .diagnoses.isEmpty) {
      return ListView(
        physics:
            const AlwaysScrollableScrollPhysics(),
        padding:
            const EdgeInsets.all(
          24,
        ),
        children: [
          const SizedBox(
            height: 170,
          ),
          const Icon(
            Icons.error_outline,
            size: 70,
            color: Colors.red,
          ),
          const SizedBox(
            height: 16,
          ),
          Text(
            diagnosisProvider
                .errorMessage!,
            textAlign:
                TextAlign.center,
            style:
                const TextStyle(
              fontSize: 16,
            ),
          ),
          const SizedBox(
            height: 18,
          ),
          ElevatedButton.icon(
            onPressed:
                _loadDiagnoses,
            icon:
                const Icon(
              Icons.refresh,
            ),
            label:
                const Text(
              'Try Again',
            ),
          ),
        ],
      );
    }

    if (diagnosisProvider
        .diagnoses.isEmpty) {
      return ListView(
        physics:
            const AlwaysScrollableScrollPhysics(),
        padding:
            const EdgeInsets.all(
          24,
        ),
        children: const [
          SizedBox(
            height: 160,
          ),
          Icon(
            Icons
                .health_and_safety_outlined,
            size: 80,
            color: Colors.grey,
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
              fontSize: 22,
              fontWeight:
                  FontWeight.bold,
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
              color: Colors.grey,
            ),
          ),
        ],
      );
    }

    return ListView.separated(
      physics:
          const AlwaysScrollableScrollPhysics(),
      padding:
          const EdgeInsets.all(
        16,
      ),
      itemCount:
          diagnosisProvider
              .diagnoses.length,
      separatorBuilder: (
        context,
        index,
      ) {
        return const SizedBox(
          height: 12,
        );
      },
      itemBuilder: (
        context,
        index,
      ) {
        final rawDiagnosis =
            diagnosisProvider
                .diagnoses[index];

        if (rawDiagnosis is! Map) {
          return const SizedBox.shrink();
        }

        final diagnosis =
            Map<String, dynamic>.from(
          rawDiagnosis,
        );

        return _buildDiagnosisCard(
          diagnosis,
        );
      },
    );
  }

  Widget _buildDiagnosisCard(
    Map<String, dynamic> diagnosis,
  ) {
    final diagnosisId =
        diagnosis['id']?.toString() ??
            '';

    final diseaseName =
        diagnosis['diseaseName']
                ?.toString() ??
            'Unknown Diagnosis';

    final cropName =
        _getCropName(
      diagnosis,
    );

    final confidence =
        _getConfidence(
      diagnosis,
    );

    final date = _formatDate(
      diagnosis['createdAt'],
    );

    final imageUrl = _buildImageUrl(
      diagnosis['imageUrl']?.toString(),
    );

    final statusColor =
        _getStatusColor(
      diseaseName,
    );

    final isOpening =
        _openingDiagnosisId ==
            diagnosisId;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius:
            BorderRadius.circular(
          16,
        ),
      ),
      child: InkWell(
        borderRadius:
            BorderRadius.circular(
          16,
        ),
        onTap: isOpening
            ? null
            : () {
                _openDiagnosis(
                  diagnosis,
                );
              },
        child: Padding(
          padding:
              const EdgeInsets.all(
            12,
          ),
          child: Row(
            children: [
              ClipRRect(
                borderRadius:
                    BorderRadius.circular(
                  12,
                ),
                child: Container(
                  width: 88,
                  height: 88,
                  color:
                      Colors.grey.shade100,
                  child: imageUrl == null
                      ? const Icon(
                          Icons
                              .image_not_supported_outlined,
                          color:
                              Colors.grey,
                        )
                      : Image.network(
                          imageUrl,
                          fit:
                              BoxFit.cover,
                          errorBuilder: (
                            context,
                            error,
                            stackTrace,
                          ) {
                            return const Icon(
                              Icons
                                  .broken_image_outlined,
                              color:
                                  Colors.grey,
                            );
                          },
                        ),
                ),
              ),
              const SizedBox(
                width: 14,
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment
                          .start,
                  children: [
                    Text(
                      cropName,
                      maxLines: 1,
                      overflow:
                          TextOverflow
                              .ellipsis,
                      style:
                          const TextStyle(
                        fontSize: 17,
                        fontWeight:
                            FontWeight
                                .bold,
                      ),
                    ),
                    const SizedBox(
                      height: 6,
                    ),
                    Text(
                      diseaseName,
                      maxLines: 2,
                      overflow:
                          TextOverflow
                              .ellipsis,
                      style:
                          TextStyle(
                        color:
                            statusColor,
                        fontWeight:
                            FontWeight
                                .w600,
                      ),
                    ),
                    const SizedBox(
                      height: 8,
                    ),
                    Row(
                      children: [
                        Icon(
                          Icons
                              .analytics_outlined,
                          size: 17,
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
                                    .bold,
                          ),
                        ),
                        const SizedBox(
                          width: 14,
                        ),
                        const Icon(
                          Icons
                              .calendar_today_outlined,
                          size: 15,
                          color:
                              Colors.grey,
                        ),
                        const SizedBox(
                          width: 5,
                        ),
                        Expanded(
                          child: Text(
                            date,
                            overflow:
                                TextOverflow
                                    .ellipsis,
                            style:
                                const TextStyle(
                              color:
                                  Colors.grey,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(
                width: 8,
              ),
              isOpening
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child:
                          CircularProgressIndicator(
                        strokeWidth: 2,
                      ),
                    )
                  : const Icon(
                      Icons
                          .chevron_right,
                      color:
                          Colors.grey,
                    ),
            ],
          ),
        ),
      ),
    );
  }
}