import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/diagnosis_provider.dart';

class DiagnosisResultScreen
    extends StatefulWidget {
  final Map<String, dynamic> result;
  final Uint8List imageBytes;

  const DiagnosisResultScreen({
    super.key,
    required this.result,
    required this.imageBytes,
  });

  @override
  State<DiagnosisResultScreen> createState() =>
      _DiagnosisResultScreenState();
}

class _DiagnosisResultScreenState
    extends State<DiagnosisResultScreen> {
  bool _showArabic = false;

  Map<String, dynamic>? _translation;

  Map<String, dynamic> get _analysis {
    if (widget.result['analysis'] is Map) {
      return Map<String, dynamic>.from(
        widget.result['analysis'],
      );
    }

    return <String, dynamic>{};
  }

  Future<void> _toggleLanguage() async {
    if (_showArabic) {
      setState(() {
        _showArabic = false;
      });

      return;
    }

    if (_translation != null) {
      setState(() {
        _showArabic = true;
      });

      return;
    }

    final diagnosisProvider =
        Provider.of<DiagnosisProvider>(
      context,
      listen: false,
    );

    final analysis = _analysis;

    final visibleSymptoms =
        analysis['visibleSymptoms'] is List
            ? List<dynamic>.from(
                analysis['visibleSymptoms'],
              )
                .map(
                  (item) => item.toString(),
                )
                .toList()
            : <String>[];

    final translation =
        await diagnosisProvider
            .translateDiagnosisToArabic(
      plantName:
          analysis['plantName']
                  ?.toString() ??
              'Unknown Plant',
      diseaseName:
          analysis['diseaseName']
                  ?.toString() ??
              'Unknown Diagnosis',
      visibleSymptoms:
          visibleSymptoms,
      description:
          analysis['description']
                  ?.toString() ??
              'No description available.',
      causes:
          analysis['causes']
                  ?.toString() ??
              'No causes available.',
      treatment:
          analysis['treatment']
                  ?.toString() ??
              'No treatment available.',
      prevention:
          analysis['prevention']
                  ?.toString() ??
              'No prevention information available.',
    );

    if (!mounted) {
      return;
    }

    if (translation == null) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(
              diagnosisProvider.errorMessage ??
                  'Failed to translate diagnosis',
            ),
            backgroundColor:
                Colors.red,
          ),
        );

      return;
    }

    setState(() {
      _translation = translation;
      _showArabic = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final analysis = _analysis;

    final originalPlantName =
        analysis['plantName']
                ?.toString() ??
            'Unknown Plant';

    final originalDiseaseName =
        analysis['diseaseName']
                ?.toString() ??
            'Unknown Diagnosis';

    final originalDescription =
        analysis['description']
                ?.toString() ??
            'No description available.';

    final originalCauses =
        analysis['causes']
                ?.toString() ??
            'No causes available.';

    final originalTreatment =
        analysis['treatment']
                ?.toString() ??
            'No treatment available.';

    final originalPrevention =
        analysis['prevention']
                ?.toString() ??
            'No prevention information available.';

    final originalVisibleSymptoms =
        analysis['visibleSymptoms'] is List
            ? List<dynamic>.from(
                analysis['visibleSymptoms'],
              )
                .map(
                  (item) => item.toString(),
                )
                .toList()
            : <String>[];

    final plantName =
        _showArabic
            ? _translatedString(
                'plantName',
                originalPlantName,
              )
            : originalPlantName;

    final diseaseName =
        _showArabic
            ? _translatedString(
                'diseaseName',
                originalDiseaseName,
              )
            : originalDiseaseName;

    final description =
        _showArabic
            ? _translatedString(
                'description',
                originalDescription,
              )
            : originalDescription;

    final causes =
        _showArabic
            ? _translatedString(
                'causes',
                originalCauses,
              )
            : originalCauses;

    final treatment =
        _showArabic
            ? _translatedString(
                'treatment',
                originalTreatment,
              )
            : originalTreatment;

    final prevention =
        _showArabic
            ? _translatedString(
                'prevention',
                originalPrevention,
              )
            : originalPrevention;

    final visibleSymptoms =
        _showArabic
            ? _translatedSymptoms(
                originalVisibleSymptoms,
              )
            : originalVisibleSymptoms;

    final severity =
        analysis['severity']
                ?.toString()
                .toLowerCase() ??
            'unknown';

    final confidenceValue =
        double.tryParse(
              analysis['confidence']
                      ?.toString() ??
                  '0',
            ) ??
            0;

    final confidence =
        confidenceValue
            .clamp(
              0,
              100,
            )
            .toDouble();

    final isHealthy =
        analysis['isHealthy'] == true;

    final needsExpertReview =
        analysis['needsExpertReview'] ==
            true;

    final disclaimer =
        widget.result['disclaimer']
                ?.toString() ??
            'This is a preliminary AI-assisted assessment and not a laboratory diagnosis.';

    final statusData =
        _getStatusData(
      isHealthy: isHealthy,
      severity: severity,
      isArabic: _showArabic,
    );

    final diagnosisProvider =
        Provider.of<DiagnosisProvider>(
      context,
    );

    return Directionality(
      textDirection:
          _showArabic
              ? TextDirection.rtl
              : TextDirection.ltr,
      child: Scaffold(
        backgroundColor:
            const Color(
          0xFFF5F7F4,
        ),
        appBar: AppBar(
          title: Text(
            _showArabic
                ? 'نتيجة التشخيص'
                : 'Diagnosis Result',
          ),
          backgroundColor:
              Colors.green,
          foregroundColor:
              Colors.white,
          actions: [
            TextButton.icon(
              onPressed:
                  diagnosisProvider
                          .isTranslating
                      ? null
                      : _toggleLanguage,
              icon: diagnosisProvider
                      .isTranslating
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child:
                          CircularProgressIndicator(
                        strokeWidth: 2,
                        color:
                            Colors.white,
                      ),
                    )
                  : const Icon(
                      Icons.language,
                      color: Colors.white,
                    ),
              label: Text(
                diagnosisProvider
                        .isTranslating
                    ? (_showArabic
                        ? 'جارٍ الترجمة'
                        : 'Translating')
                    : (_showArabic
                        ? 'English'
                        : 'عربي'),
                style:
                    const TextStyle(
                  color: Colors.white,
                  fontWeight:
                      FontWeight.bold,
                ),
              ),
            ),
            IconButton(
              tooltip:
                  _showArabic
                      ? 'الصفحة الرئيسية'
                      : 'Farmer Dashboard',
              icon: const Icon(
                Icons.home_outlined,
              ),
              onPressed: () {
                Navigator.of(context)
                    .popUntil(
                  (route) =>
                      route.isFirst,
                );
              },
            ),
          ],
        ),
        body: SingleChildScrollView(
          padding:
              const EdgeInsets.all(
            18,
          ),
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.stretch,
            children: [
              _buildImageCard(),
              const SizedBox(
                height: 18,
              ),
              _buildSummaryCard(
                plantName:
                    plantName,
                diseaseName:
                    diseaseName,
                confidence:
                    confidence,
                statusText:
                    statusData['text']
                        as String,
                statusColor:
                    statusData['color']
                        as Color,
                statusIcon:
                    statusData['icon']
                        as IconData,
                isArabic:
                    _showArabic,
              ),
              const SizedBox(
                height: 16,
              ),
              _buildSectionCard(
                icon:
                    Icons.info_outline,
                title:
                    _showArabic
                        ? 'الوصف'
                        : 'Description',
                content:
                    description,
              ),
              const SizedBox(
                height: 14,
              ),
              if (visibleSymptoms
                  .isNotEmpty)
                _buildSymptomsCard(
                  visibleSymptoms,
                  isArabic:
                      _showArabic,
                ),
              if (visibleSymptoms
                  .isNotEmpty)
                const SizedBox(
                  height: 14,
                ),
              _buildSectionCard(
                icon:
                    Icons.search_outlined,
                title:
                    _showArabic
                        ? 'الأسباب المحتملة'
                        : 'Possible Causes',
                content:
                    causes,
              ),
              const SizedBox(
                height: 14,
              ),
              _buildSectionCard(
                icon: Icons
                    .medical_services_outlined,
                title:
                    _showArabic
                        ? 'العلاج الموصى به'
                        : 'Recommended Treatment',
                content:
                    treatment,
              ),
              const SizedBox(
                height: 14,
              ),
              _buildSectionCard(
                icon:
                    Icons.shield_outlined,
                title:
                    _showArabic
                        ? 'الوقاية'
                        : 'Prevention',
                content:
                    prevention,
              ),
              if (needsExpertReview) ...[
                const SizedBox(
                  height: 14,
                ),
                _buildExpertReviewCard(
                  isArabic:
                      _showArabic,
                ),
              ],
              const SizedBox(
                height: 14,
              ),
              _buildDisclaimerCard(
                _showArabic
                    ? 'هذا تقييم أولي بمساعدة الذكاء الاصطناعي وليس تشخيصًا مخبريًا. يُنصح باستشارة مختص زراعي قبل استخدام المواد الكيميائية الخطرة.'
                    : disclaimer,
              ),
              const SizedBox(
                height: 24,
              ),
              SizedBox(
                height: 52,
                child:
                    ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(
                      context,
                    );
                  },
                  icon: const Icon(
                    Icons.refresh,
                  ),
                  label: Text(
                    _showArabic
                        ? 'بدء تشخيص جديد'
                        : 'Start New Diagnosis',
                  ),
                ),
              ),
              const SizedBox(
                height: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _translatedString(
    String key,
    String fallback,
  ) {
    final value =
        _translation?[key]
            ?.toString()
            .trim();

    if (value == null ||
        value.isEmpty) {
      return fallback;
    }

    return value;
  }

  List<String> _translatedSymptoms(
    List<String> fallback,
  ) {
    final value =
        _translation?[
            'visibleSymptoms'];

    if (value is! List) {
      return fallback;
    }

    final symptoms =
        value
            .map(
              (item) =>
                  item.toString(),
            )
            .where(
              (item) =>
                  item.trim().isNotEmpty,
            )
            .toList();

    if (symptoms.isEmpty) {
      return fallback;
    }

    return symptoms;
  }

  Widget _buildImageCard() {
    return Container(
      height: 280,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(
          18,
        ),
        boxShadow: [
          BoxShadow(
            color:
                Colors.black.withValues(
              alpha: 0.08,
            ),
            blurRadius: 12,
            offset:
                const Offset(
              0,
              4,
            ),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius:
            BorderRadius.circular(
          18,
        ),
        child: Image.memory(
          widget.imageBytes,
          fit: BoxFit.contain,
        ),
      ),
    );
  }

  Widget _buildSummaryCard({
    required String plantName,
    required String diseaseName,
    required double confidence,
    required String statusText,
    required Color statusColor,
    required IconData statusIcon,
    required bool isArabic,
  }) {
    return Card(
      elevation: 2,
      shape:
          RoundedRectangleBorder(
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
        child: Column(
          children: [
            Icon(
              statusIcon,
              color: statusColor,
              size: 54,
            ),
            const SizedBox(
              height: 10,
            ),
            Text(
              plantName,
              textAlign:
                  TextAlign.center,
              style:
                  const TextStyle(
                fontSize: 24,
                fontWeight:
                    FontWeight.bold,
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            Container(
              padding:
                  const EdgeInsets
                      .symmetric(
                horizontal: 14,
                vertical: 7,
              ),
              decoration:
                  BoxDecoration(
                color: statusColor
                    .withValues(
                  alpha: 0.12,
                ),
                borderRadius:
                    BorderRadius.circular(
                  20,
                ),
              ),
              child: Text(
                statusText,
                style: TextStyle(
                  color: statusColor,
                  fontWeight:
                      FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(
              height: 18,
            ),
            Align(
              alignment:
                  isArabic
                      ? Alignment
                          .centerRight
                      : Alignment
                          .centerLeft,
              child: Text(
                isArabic
                    ? 'التشخيص'
                    : 'Diagnosis',
                style:
                    const TextStyle(
                  color:
                      Colors.grey,
                  fontWeight:
                      FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(
              height: 5,
            ),
            Align(
              alignment:
                  isArabic
                      ? Alignment
                          .centerRight
                      : Alignment
                          .centerLeft,
              child: Text(
                diseaseName,
                style:
                    const TextStyle(
                  fontSize: 19,
                  fontWeight:
                      FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(
              height: 18,
            ),
            Row(
              children: [
                Text(
                  isArabic
                      ? 'نسبة الثقة'
                      : 'Confidence',
                  style:
                      const TextStyle(
                    fontWeight:
                        FontWeight.w600,
                  ),
                ),
                const Spacer(),
                Text(
                  '${confidence.toStringAsFixed(0)}%',
                  style: TextStyle(
                    color:
                        statusColor,
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(
              height: 8,
            ),
            LinearProgressIndicator(
              value:
                  confidence / 100,
              minHeight: 10,
              borderRadius:
                  BorderRadius.circular(
                10,
              ),
              backgroundColor:
                  Colors.grey.shade200,
              valueColor:
                  AlwaysStoppedAnimation<
                      Color>(
                statusColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionCard({
    required IconData icon,
    required String title,
    required String content,
  }) {
    return Card(
      elevation: 1,
      shape:
          RoundedRectangleBorder(
        borderRadius:
            BorderRadius.circular(
          16,
        ),
      ),
      child: Padding(
        padding:
            const EdgeInsets.all(
          16,
        ),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  icon,
                  color:
                      Colors.green,
                ),
                const SizedBox(
                  width: 10,
                ),
                Expanded(
                  child: Text(
                    title,
                    style:
                        const TextStyle(
                      fontSize: 17,
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(
              height: 12,
            ),
            Text(
              content,
              style:
                  const TextStyle(
                fontSize: 15,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSymptomsCard(
    List<String> symptoms, {
    required bool isArabic,
  }) {
    return Card(
      elevation: 1,
      shape:
          RoundedRectangleBorder(
        borderRadius:
            BorderRadius.circular(
          16,
        ),
      ),
      child: Padding(
        padding:
            const EdgeInsets.all(
          16,
        ),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons
                      .visibility_outlined,
                  color: Colors.green,
                ),
                const SizedBox(
                  width: 10,
                ),
                Text(
                  isArabic
                      ? 'الأعراض الظاهرة'
                      : 'Visible Symptoms',
                  style:
                      const TextStyle(
                    fontSize: 17,
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(
              height: 12,
            ),
            ...symptoms.map(
              (symptom) {
                return Padding(
                  padding:
                      const EdgeInsets.only(
                    bottom: 9,
                  ),
                  child: Row(
                    crossAxisAlignment:
                        CrossAxisAlignment
                            .start,
                    children: [
                      const Icon(
                        Icons
                            .check_circle_outline,
                        color:
                            Colors.green,
                        size: 20,
                      ),
                      const SizedBox(
                        width: 9,
                      ),
                      Expanded(
                        child: Text(
                          symptom,
                          style:
                              const TextStyle(
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExpertReviewCard({
    required bool isArabic,
  }) {
    return Container(
      padding:
          const EdgeInsets.all(
        16,
      ),
      decoration:
          BoxDecoration(
        color:
            Colors.orange.shade50,
        borderRadius:
            BorderRadius.circular(
          16,
        ),
        border: Border.all(
          color:
              Colors.orange.shade300,
        ),
      ),
      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons
                .person_search_outlined,
            color: Colors.orange,
          ),
          const SizedBox(
            width: 10,
          ),
          Expanded(
            child: Text(
              isArabic
                  ? 'يُنصح بمراجعة مختص زراعي لهذه الحالة، خاصة قبل استخدام العلاجات الكيميائية.'
                  : 'Expert review is recommended for this case, especially before applying chemical treatments.',
              style:
                  const TextStyle(
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDisclaimerCard(
    String disclaimer,
  ) {
    return Container(
      padding:
          const EdgeInsets.all(
        16,
      ),
      decoration:
          BoxDecoration(
        color:
            Colors.amber.shade50,
        borderRadius:
            BorderRadius.circular(
          16,
        ),
        border: Border.all(
          color:
              Colors.amber.shade300,
        ),
      ),
      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons
                .warning_amber_rounded,
            color: Colors.orange,
          ),
          const SizedBox(
            width: 10,
          ),
          Expanded(
            child: Text(
              disclaimer,
              style:
                  const TextStyle(
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Map<String, dynamic>
      _getStatusData({
    required bool isHealthy,
    required String severity,
    required bool isArabic,
  }) {
    if (isHealthy) {
      return {
        'text':
            isArabic
                ? 'سليم'
                : 'Healthy',
        'color':
            Colors.green,
        'icon':
            Icons.check_circle,
      };
    }

    switch (severity) {
      case 'low':
        return {
          'text':
              isArabic
                  ? 'خطورة منخفضة'
                  : 'Low Risk',
          'color':
              Colors.amber.shade700,
          'icon':
              Icons.info,
        };

      case 'moderate':
        return {
          'text':
              isArabic
                  ? 'خطورة متوسطة'
                  : 'Moderate Risk',
          'color':
              Colors.orange,
          'icon':
              Icons.warning_rounded,
        };

      case 'high':
        return {
          'text':
              isArabic
                  ? 'خطورة عالية'
                  : 'High Risk',
          'color':
              Colors.red,
          'icon':
              Icons.dangerous,
        };

      default:
        return {
          'text':
              isArabic
                  ? 'يحتاج إلى مراجعة'
                  : 'Needs Review',
          'color':
              Colors.blueGrey,
          'icon':
              Icons.help_outline,
        };
    }
  }
}