import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_constants.dart';
import '../../providers/diagnosis_provider.dart';
import 'diagnosis_result_screen.dart';

class NotificationDiagnosisScreen
    extends StatefulWidget {
  final String diagnosisId;

  const NotificationDiagnosisScreen({
    super.key,
    required this.diagnosisId,
  });

  @override
  State<NotificationDiagnosisScreen>
      createState() =>
          _NotificationDiagnosisScreenState();
}

class _NotificationDiagnosisScreenState
    extends State<NotificationDiagnosisScreen> {
  final Dio _dio = Dio();

  String? _errorMessage;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback(
      (_) {
        _openDiagnosis();
      },
    );
  }

  Future<void> _openDiagnosis() async {
    try {
      final diagnosisProvider =
          Provider.of<DiagnosisProvider>(
        context,
        listen: false,
      );

      final diagnosis =
          await diagnosisProvider
              .getDiagnosisById(
        widget.diagnosisId,
      );

      if (!mounted) {
        return;
      }

      if (diagnosis == null) {
        setState(() {
          _errorMessage =
              diagnosisProvider.errorMessage ??
                  'Diagnosis was not found';
        });

        return;
      }

      final imageUrl = _buildImageUrl(
        diagnosis['imageUrl']?.toString(),
      );

      if (imageUrl == null) {
        setState(() {
          _errorMessage =
              'Diagnosis image was not found';
        });

        return;
      }

      final response =
          await _dio.get<List<int>>(
        imageUrl,
        options: Options(
          responseType: ResponseType.bytes,
        ),
      );

      final responseData =
          response.data;

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
          double.tryParse(
            diagnosis['confidence']
                    ?.toString() ??
                '0',
          ) ??
          0;

      final plantName =
          _getPlantName(
        diagnosis,
      );

      final isHealthy =
          _isHealthyDiagnosis(
        diseaseName,
      );

      final result =
          <String, dynamic>{
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
          'plantName': plantName,
          'diseaseName': diseaseName,
          'confidence': confidence,
          'severity':
              isHealthy
                  ? 'none'
                  : 'unknown',
          'visibleSymptoms':
              <String>[],
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
          'needsExpertReview':
              !isHealthy,
        },
        'diagnosis':
            diagnosis,
        'disclaimer':
            'This is a preliminary AI-assisted assessment and not a laboratory diagnosis. Consult an agricultural specialist before applying hazardous chemicals.',
      };

      if (!mounted) {
        return;
      }

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) =>
              DiagnosisResultScreen(
            result: result,
            imageBytes:
                imageBytes,
          ),
        ),
      );
    } catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        _errorMessage = error
            .toString()
            .replaceFirst(
              'Exception: ',
              '',
            );
      });
    }
  }

  String? _buildImageUrl(
    String? imageUrl,
  ) {
    if (imageUrl == null ||
        imageUrl.trim().isEmpty) {
      return null;
    }

    final value =
        imageUrl.trim();

    if (value.startsWith('http://') ||
        value.startsWith('https://')) {
      return value;
    }

    if (value.startsWith('/')) {
      return '${AppConstants.baseUrl}$value';
    }

    return '${AppConstants.baseUrl}/$value';
  }

  String _getPlantName(
    Map<String, dynamic> diagnosis,
  ) {
    String cleanName(
      String value,
    ) {
      return value
          .replaceAll(
            RegExp(
              r'\s*\(.*?\)',
            ),
            '',
          )
          .trim();
    }

    final detectedPlantName =
        diagnosis['plantName']
            ?.toString();

    if (detectedPlantName != null &&
        detectedPlantName
            .trim()
            .isNotEmpty) {
      return cleanName(
        detectedPlantName,
      );
    }

    final crop =
        diagnosis['crop'];

    if (crop is Map) {
      final cropName =
          crop['cropName']
                  ?.toString() ??
              crop['name']
                  ?.toString();

      if (cropName != null &&
          cropName
              .trim()
              .isNotEmpty) {
        return cleanName(
          cropName,
        );
      }
    }

    return 'Unknown Plant';
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

  @override
  Widget build(
    BuildContext context,
  ) {
    return Scaffold(
      backgroundColor:
          const Color(
        0xFFF5F7F4,
      ),
      appBar: AppBar(
        title: const Text(
          'Opening Diagnosis',
        ),
        backgroundColor:
            Colors.green,
        foregroundColor:
            Colors.white,
      ),
      body: _errorMessage == null
          ? const Center(
              child: Column(
                mainAxisSize:
                    MainAxisSize.min,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(
                    height: 18,
                  ),
                  Text(
                    'Loading diagnosis...',
                    style: TextStyle(
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            )
          : Center(
              child: Padding(
                padding:
                    const EdgeInsets.all(
                  24,
                ),
                child: Column(
                  mainAxisSize:
                      MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 70,
                      color: Colors.red,
                    ),
                    const SizedBox(
                      height: 16,
                    ),
                    Text(
                      _errorMessage!,
                      textAlign:
                          TextAlign.center,
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    ElevatedButton.icon(
                      onPressed: () {
                        setState(() {
                          _errorMessage =
                              null;
                        });

                        _openDiagnosis();
                      },
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
                ),
              ),
            ),
    );
  }
}