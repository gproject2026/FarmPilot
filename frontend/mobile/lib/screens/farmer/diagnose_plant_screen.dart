import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../providers/crop_provider.dart';
import '../../providers/diagnosis_provider.dart';
import '../../services/image_upload_service.dart';

class DiagnosePlantScreen extends StatefulWidget {
  const DiagnosePlantScreen({
    super.key,
  });

  @override
  State<DiagnosePlantScreen> createState() =>
      _DiagnosePlantScreenState();
}

class _DiagnosePlantScreenState
    extends State<DiagnosePlantScreen> {
  final ImagePicker _imagePicker =
      ImagePicker();

  final ImageUploadService
      _imageUploadService =
      ImageUploadService();

  final TextEditingController
      _symptomsController =
      TextEditingController();

  Uint8List? _selectedImageBytes;
  String? _selectedImageName;
  String? _selectedCropId;

  bool _isUploading = false;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback(
      (_) {
        _loadCrops();
      },
    );
  }

  Future<void> _loadCrops() async {
    final authProvider =
        Provider.of<AuthProvider>(
      context,
      listen: false,
    );

    final token = authProvider.token;

    if (token == null || token.isEmpty) {
      _showMessage(
        'Authentication token was not found',
        isError: true,
      );

      return;
    }

    await Provider.of<CropProvider>(
      context,
      listen: false,
    ).getMyCrops(token);

    if (!mounted) {
      return;
    }

    final cropProvider =
        Provider.of<CropProvider>(
      context,
      listen: false,
    );

    if (cropProvider.crops.isNotEmpty &&
        _selectedCropId == null) {
      setState(() {
        _selectedCropId =
            cropProvider.crops.first['id']
                ?.toString();
      });
    }
  }

  Future<void> _pickImage(
    ImageSource source,
  ) async {
    try {
      final pickedImage =
          await _imagePicker.pickImage(
        source: source,
        imageQuality: 85,
        maxWidth: 1600,
      );

      if (pickedImage == null) {
        return;
      }

      final imageBytes =
          await pickedImage.readAsBytes();

      if (!mounted) {
        return;
      }

      setState(() {
        _selectedImageBytes =
            imageBytes;

        _selectedImageName =
            pickedImage.name;
      });
    } catch (error) {
      if (!mounted) {
        return;
      }

      _showMessage(
        'Failed to select image: $error',
        isError: true,
      );
    }
  }

  void _removeImage() {
    setState(() {
      _selectedImageBytes = null;
      _selectedImageName = null;
    });
  }

  Future<void> _analyzePlant() async {
    if (_selectedImageBytes == null ||
        _selectedImageName == null) {
      _showMessage(
        'Please select or capture a plant image',
        isError: true,
      );

      return;
    }

    if (_selectedCropId == null) {
      _showMessage(
        'Please select a crop',
        isError: true,
      );

      return;
    }

    final cropProvider =
        Provider.of<CropProvider>(
      context,
      listen: false,
    );

    final diagnosisProvider =
        Provider.of<DiagnosisProvider>(
      context,
      listen: false,
    );

    final selectedCrop =
        cropProvider.crops.firstWhere(
      (crop) =>
          crop['id']?.toString() ==
          _selectedCropId,
      orElse: () => null,
    );

    if (selectedCrop == null) {
      _showMessage(
        'Selected crop was not found',
        isError: true,
      );

      return;
    }

    final plantName =
        selectedCrop['cropName']
                ?.toString() ??
            selectedCrop['name']
                ?.toString() ??
            'Unknown plant';

    setState(() {
      _isUploading = true;
    });

    try {
      final imageUrl =
          await _imageUploadService.uploadImage(
        imageBytes:
            _selectedImageBytes!,
        fileName:
            _selectedImageName!,
      );

      final result =
          await diagnosisProvider.analyzePlant(
        imageUrl: imageUrl,
        cropId: _selectedCropId,
        plantName: plantName,
        symptoms:
            _symptomsController.text
                    .trim()
                    .isEmpty
                ? null
                : _symptomsController.text
                    .trim(),
      );

      if (!mounted) {
        return;
      }

      await _showDiagnosisResult(
        result,
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
        isError: true,
      );
    } finally {
      if (mounted) {
        setState(() {
          _isUploading = false;
        });
      }
    }
  }

  Future<void> _showDiagnosisResult(
    Map<String, dynamic> result,
  ) async {
    final analysis =
        result['analysis'] is Map
            ? Map<String, dynamic>.from(
                result['analysis'],
              )
            : <String, dynamic>{};

    final diseaseName =
        analysis['diseaseName']
                ?.toString() ??
            'Unknown diagnosis';

    final plantName =
        analysis['plantName']
                ?.toString() ??
            'Unknown plant';

    final confidence =
        analysis['confidence']
                ?.toString() ??
            '0';

    final isHealthy =
        analysis['isHealthy'] == true;

    final treatment =
        analysis['treatment']
                ?.toString() ??
            '';

    final prevention =
        analysis['prevention']
                ?.toString() ??
            '';

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(
                isHealthy
                    ? Icons
                        .check_circle_outline
                    : Icons
                        .health_and_safety_outlined,
                color: isHealthy
                    ? Colors.green
                    : Colors.orange,
              ),
              const SizedBox(
                width: 10,
              ),
              const Expanded(
                child: Text(
                  'Diagnosis Result',
                ),
              ),
            ],
          ),
          content: SizedBox(
            width: 550,
            child:
                SingleChildScrollView(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment
                        .start,
                children: [
                  _resultItem(
                    'Plant',
                    plantName,
                  ),
                  _resultItem(
                    'Diagnosis',
                    diseaseName,
                  ),
                  _resultItem(
                    'Confidence',
                    '$confidence%',
                  ),
                  if (treatment.isNotEmpty)
                    _resultItem(
                      'Treatment',
                      treatment,
                    ),
                  if (prevention.isNotEmpty)
                    _resultItem(
                      'Prevention',
                      prevention,
                    ),
                  const SizedBox(
                    height: 12,
                  ),
                  Container(
                    padding:
                        const EdgeInsets
                            .all(
                      12,
                    ),
                    decoration:
                        BoxDecoration(
                      color: Colors
                          .amber
                          .shade50,
                      borderRadius:
                          BorderRadius
                              .circular(
                        10,
                      ),
                      border:
                          Border.all(
                        color: Colors
                            .amber
                            .shade300,
                      ),
                    ),
                    child: const Text(
                      'This is a preliminary AI-assisted assessment and not a laboratory diagnosis.',
                    ),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(
                  dialogContext,
                );
              },
              child: const Text(
                'Close',
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _resultItem(
    String title,
    String value,
  ) {
    return Padding(
      padding:
          const EdgeInsets.only(
        bottom: 14,
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style:
                const TextStyle(
              fontWeight:
                  FontWeight.bold,
              fontSize: 15,
            ),
          ),
          const SizedBox(
            height: 4,
          ),
          Text(
            value,
            style:
                const TextStyle(
              fontSize: 15,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  void _showMessage(
    String message, {
    required bool isError,
  }) {
    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context)
        .showSnackBar(
      SnackBar(
        content: Text(
          message,
        ),
        backgroundColor: isError
            ? Colors.red
            : Colors.green,
      ),
    );
  }

  @override
  void dispose() {
    _symptomsController.dispose();
    super.dispose();
  }

  @override
  Widget build(
    BuildContext context,
  ) {
    final cropProvider =
        Provider.of<CropProvider>(
      context,
    );

    final diagnosisProvider =
        Provider.of<DiagnosisProvider>(
      context,
    );

    final isLoading =
        _isUploading ||
        diagnosisProvider.isLoading;

    return Scaffold(
      backgroundColor:
          const Color(
        0xFFF5F7F4,
      ),
      appBar: AppBar(
        title: const Text(
          'Plant Diagnosis',
        ),
        backgroundColor:
            Colors.green,
        foregroundColor:
            Colors.white,
      ),
      body:
          SingleChildScrollView(
        padding:
            const EdgeInsets.all(
          20,
        ),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment
                  .stretch,
          children: [
            const Icon(
              Icons
                  .health_and_safety_outlined,
              size: 70,
              color: Colors.green,
            ),
            const SizedBox(
              height: 12,
            ),
            const Text(
              'AI Plant Disease Detection',
              textAlign:
                  TextAlign.center,
              style: TextStyle(
                fontSize: 24,
                fontWeight:
                    FontWeight.bold,
              ),
            ),
            const SizedBox(
              height: 8,
            ),
            const Text(
              'Capture or select a clear image of the affected plant area.',
              textAlign:
                  TextAlign.center,
              style: TextStyle(
                fontSize: 15,
                color: Colors.grey,
              ),
            ),
            const SizedBox(
              height: 24,
            ),
            Container(
              height: 270,
              decoration:
                  BoxDecoration(
                color: Colors.white,
                borderRadius:
                    BorderRadius
                        .circular(
                  16,
                ),
                border: Border.all(
                  color: Colors
                      .green
                      .shade200,
                ),
              ),
              child:
                  _selectedImageBytes ==
                          null
                      ? const Column(
                          mainAxisAlignment:
                              MainAxisAlignment
                                  .center,
                          children: [
                            Icon(
                              Icons
                                  .image_outlined,
                              size: 70,
                              color: Colors
                                  .grey,
                            ),
                            SizedBox(
                              height: 12,
                            ),
                            Text(
                              'No image selected',
                              style:
                                  TextStyle(
                                color:
                                    Colors
                                        .grey,
                              ),
                            ),
                          ],
                        )
                      : Stack(
                          fit:
                              StackFit
                                  .expand,
                          children: [
                            ClipRRect(
                              borderRadius:
                                  BorderRadius
                                      .circular(
                                15,
                              ),
                              child:
                                  Image.memory(
                                _selectedImageBytes!,
                                fit: BoxFit
                                    .contain,
                              ),
                            ),
                            Positioned(
                              top: 8,
                              right: 8,
                              child:
                                  IconButton
                                      .filled(
                                onPressed:
                                    isLoading
                                        ? null
                                        : _removeImage,
                                icon:
                                    const Icon(
                                  Icons
                                      .close,
                                ),
                              ),
                            ),
                          ],
                        ),
            ),
            const SizedBox(
              height: 14,
            ),
            Row(
              children: [
                Expanded(
                  child:
                      ElevatedButton.icon(
                    onPressed:
                        isLoading
                            ? null
                            : () {
                                _pickImage(
                                  ImageSource
                                      .camera,
                                );
                              },
                    icon:
                        const Icon(
                      Icons.camera_alt,
                    ),
                    label:
                        const Text(
                      'Take Photo',
                    ),
                  ),
                ),
                const SizedBox(
                  width: 12,
                ),
                Expanded(
                  child:
                      OutlinedButton.icon(
                    onPressed:
                        isLoading
                            ? null
                            : () {
                                _pickImage(
                                  ImageSource
                                      .gallery,
                                );
                              },
                    icon:
                        const Icon(
                      Icons
                          .photo_library_outlined,
                    ),
                    label:
                        const Text(
                      'Gallery',
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(
              height: 24,
            ),
            if (cropProvider.isLoading)
              const Center(
                child:
                    CircularProgressIndicator(),
              )
            else if (cropProvider
                .crops.isEmpty)
              Container(
                padding:
                    const EdgeInsets
                        .all(
                  16,
                ),
                decoration:
                    BoxDecoration(
                  color:
                      Colors.orange
                          .shade50,
                  borderRadius:
                      BorderRadius
                          .circular(
                    12,
                  ),
                ),
                child: const Text(
                  'No crops were found. Add a crop before starting a diagnosis.',
                  textAlign:
                      TextAlign.center,
                ),
              )
            else
              DropdownButtonFormField<
                  String>(
                initialValue:
                    _selectedCropId,
                decoration:
                    const InputDecoration(
                  labelText:
                      'Select Crop',
                  prefixIcon: Icon(
                    Icons.eco_outlined,
                  ),
                  border:
                      OutlineInputBorder(),
                ),
                items:
                    cropProvider.crops
                        .map(
                  (crop) {
                    final cropId =
                        crop['id']
                            ?.toString();

                    final cropName =
                        crop['cropName']
                                ?.toString() ??
                            crop['name']
                                ?.toString() ??
                            'Unnamed Crop';

                    return DropdownMenuItem<
                        String>(
                      value: cropId,
                      child: Text(
                        cropName,
                      ),
                    );
                  },
                ).toList(),
                onChanged:
                    isLoading
                        ? null
                        : (value) {
                            setState(
                              () {
                                _selectedCropId =
                                    value;
                              },
                            );
                          },
              ),
            const SizedBox(
              height: 18,
            ),
            TextField(
              controller:
                  _symptomsController,
              enabled: !isLoading,
              maxLines: 4,
              decoration:
                  const InputDecoration(
                labelText:
                    'Observed Symptoms (Optional)',
                hintText:
                    'Example: Yellow leaves, brown spots, wilting...',
                prefixIcon: Icon(
                  Icons
                      .description_outlined,
                ),
                border:
                    OutlineInputBorder(),
                alignLabelWithHint:
                    true,
              ),
            ),
            const SizedBox(
              height: 24,
            ),
            SizedBox(
              height: 54,
              child:
                  ElevatedButton.icon(
                onPressed:
                    isLoading ||
                            cropProvider
                                .crops
                                .isEmpty
                        ? null
                        : _analyzePlant,
                icon: isLoading
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child:
                            CircularProgressIndicator(
                          strokeWidth: 2,
                        ),
                      )
                    : const Icon(
                        Icons
                            .auto_awesome,
                      ),
                label: Text(
                  isLoading
                      ? 'Analyzing Plant...'
                      : 'Analyze Plant',
                ),
              ),
            ),
            const SizedBox(
              height: 18,
            ),
            const Text(
              'For better results, use a clear, well-lit photo showing the affected leaves, stem, or fruit.',
              textAlign:
                  TextAlign.center,
              style: TextStyle(
                color: Colors.grey,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}