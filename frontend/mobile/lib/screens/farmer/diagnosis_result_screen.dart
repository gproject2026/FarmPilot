import 'dart:typed_data';

import 'package:flutter/material.dart';

class DiagnosisResultScreen extends StatelessWidget {
  final Map<String, dynamic> result;
  final Uint8List imageBytes;

  const DiagnosisResultScreen({
    super.key,
    required this.result,
    required this.imageBytes,
  });

  @override
  Widget build(BuildContext context) {
    final analysis = result['analysis'] is Map
        ? Map<String, dynamic>.from(
            result['analysis'],
          )
        : <String, dynamic>{};

    final plantName =
        analysis['plantName']?.toString() ??
            'Unknown Plant';

    final diseaseName =
        analysis['diseaseName']?.toString() ??
            'Unknown Diagnosis';

    final description =
        analysis['description']?.toString() ??
            'No description available.';

    final causes =
        analysis['causes']?.toString() ??
            'No causes available.';

    final treatment =
        analysis['treatment']?.toString() ??
            'No treatment available.';

    final prevention =
        analysis['prevention']?.toString() ??
            'No prevention information available.';

    final severity =
        analysis['severity']?.toString().toLowerCase() ??
            'unknown';

    final confidenceValue = double.tryParse(
          analysis['confidence']?.toString() ?? '0',
        ) ??
        0;

    final confidence =
        confidenceValue.clamp(0, 100).toDouble();

    final isHealthy =
        analysis['isHealthy'] == true;

    final needsExpertReview =
        analysis['needsExpertReview'] == true;

    final visibleSymptoms =
        analysis['visibleSymptoms'] is List
            ? List<dynamic>.from(
                analysis['visibleSymptoms'],
              ).map(
                (item) => item.toString(),
              ).toList()
            : <String>[];

    final disclaimer =
        result['disclaimer']?.toString() ??
            'This is a preliminary AI-assisted assessment and not a laboratory diagnosis.';

    final statusData = _getStatusData(
      isHealthy: isHealthy,
      severity: severity,
    );

    return Scaffold(
      backgroundColor: const Color(
        0xFFF5F7F4,
      ),
      appBar: AppBar(
        title: const Text(
          'Diagnosis Result',
        ),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(
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
              plantName: plantName,
              diseaseName: diseaseName,
              confidence: confidence,
              statusText:
                  statusData['text'] as String,
              statusColor:
                  statusData['color'] as Color,
              statusIcon:
                  statusData['icon'] as IconData,
            ),
            const SizedBox(
              height: 16,
            ),
            _buildSectionCard(
              icon: Icons.info_outline,
              title: 'Description',
              content: description,
            ),
            const SizedBox(
              height: 14,
            ),
            if (visibleSymptoms.isNotEmpty)
              _buildSymptomsCard(
                visibleSymptoms,
              ),
            if (visibleSymptoms.isNotEmpty)
              const SizedBox(
                height: 14,
              ),
            _buildSectionCard(
              icon: Icons.search_outlined,
              title: 'Possible Causes',
              content: causes,
            ),
            const SizedBox(
              height: 14,
            ),
            _buildSectionCard(
              icon:
                  Icons.medical_services_outlined,
              title: 'Recommended Treatment',
              content: treatment,
            ),
            const SizedBox(
              height: 14,
            ),
            _buildSectionCard(
              icon: Icons.shield_outlined,
              title: 'Prevention',
              content: prevention,
            ),
            if (needsExpertReview) ...[
              const SizedBox(
                height: 14,
              ),
              _buildExpertReviewCard(),
            ],
            const SizedBox(
              height: 14,
            ),
            _buildDisclaimerCard(
              disclaimer,
            ),
            const SizedBox(
              height: 24,
            ),
            SizedBox(
              height: 52,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(
                    context,
                  );
                },
                icon: const Icon(
                  Icons.refresh,
                ),
                label: const Text(
                  'Start New Diagnosis',
                ),
              ),
            ),
            const SizedBox(
              height: 16,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageCard() {
    return Container(
      height: 280,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(
          18,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(
              alpha: 0.08,
            ),
            blurRadius: 12,
            offset: const Offset(
              0,
              4,
            ),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(
          18,
        ),
        child: Image.memory(
          imageBytes,
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
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(
          18,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(
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
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 7,
              ),
              decoration: BoxDecoration(
                color: statusColor.withValues(
                  alpha: 0.12,
                ),
                borderRadius: BorderRadius.circular(
                  20,
                ),
              ),
              child: Text(
                statusText,
                style: TextStyle(
                  color: statusColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(
              height: 18,
            ),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Diagnosis',
                style: TextStyle(
                  color: Colors.grey,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(
              height: 5,
            ),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                diseaseName,
                style: const TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(
              height: 18,
            ),
            Row(
              children: [
                const Text(
                  'Confidence',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                Text(
                  '${confidence.toStringAsFixed(0)}%',
                  style: TextStyle(
                    color: statusColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(
              height: 8,
            ),
            LinearProgressIndicator(
              value: confidence / 100,
              minHeight: 10,
              borderRadius: BorderRadius.circular(
                10,
              ),
              backgroundColor:
                  Colors.grey.shade200,
              valueColor:
                  AlwaysStoppedAnimation<Color>(
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
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(
          16,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(
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
                  color: Colors.green,
                ),
                const SizedBox(
                  width: 10,
                ),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
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
              style: const TextStyle(
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
    List<String> symptoms,
  ) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(
          16,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(
          16,
        ),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(
                  Icons.visibility_outlined,
                  color: Colors.green,
                ),
                SizedBox(
                  width: 10,
                ),
                Text(
                  'Visible Symptoms',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
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
                  padding: const EdgeInsets.only(
                    bottom: 9,
                  ),
                  child: Row(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.check_circle_outline,
                        color: Colors.green,
                        size: 20,
                      ),
                      const SizedBox(
                        width: 9,
                      ),
                      Expanded(
                        child: Text(
                          symptom,
                          style: const TextStyle(
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

  Widget _buildExpertReviewCard() {
    return Container(
      padding: const EdgeInsets.all(
        16,
      ),
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        borderRadius: BorderRadius.circular(
          16,
        ),
        border: Border.all(
          color: Colors.orange.shade300,
        ),
      ),
      child: const Row(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.person_search_outlined,
            color: Colors.orange,
          ),
          SizedBox(
            width: 10,
          ),
          Expanded(
            child: Text(
              'Expert review is recommended for this case, especially before applying chemical treatments.',
              style: TextStyle(
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
      padding: const EdgeInsets.all(
        16,
      ),
      decoration: BoxDecoration(
        color: Colors.amber.shade50,
        borderRadius: BorderRadius.circular(
          16,
        ),
        border: Border.all(
          color: Colors.amber.shade300,
        ),
      ),
      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.warning_amber_rounded,
            color: Colors.orange,
          ),
          const SizedBox(
            width: 10,
          ),
          Expanded(
            child: Text(
              disclaimer,
              style: const TextStyle(
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Map<String, dynamic> _getStatusData({
    required bool isHealthy,
    required String severity,
  }) {
    if (isHealthy) {
      return {
        'text': 'Healthy',
        'color': Colors.green,
        'icon': Icons.check_circle,
      };
    }

    switch (severity) {
      case 'low':
        return {
          'text': 'Low Risk',
          'color': Colors.amber.shade700,
          'icon': Icons.info,
        };

      case 'moderate':
        return {
          'text': 'Moderate Risk',
          'color': Colors.orange,
          'icon': Icons.warning_rounded,
        };

      case 'high':
        return {
          'text': 'High Risk',
          'color': Colors.red,
          'icon': Icons.dangerous,
        };

      default:
        return {
          'text': 'Needs Review',
          'color': Colors.blueGrey,
          'icon': Icons.help_outline,
        };
    }
  }
}