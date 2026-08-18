import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../providers/crop_provider.dart';
import '../../providers/diagnosis_provider.dart';
import '../../services/image_upload_service.dart';
import 'diagnosis_result_screen.dart';

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
  static const String _aiDetectValue =
      '__AI_DETECT__';

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

  String _selectedCropValue =
      _aiDetectValue;

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

    if (token == null ||
        token.isEmpty) {
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

    final diagnosisProvider =
        Provider.of<DiagnosisProvider>(
      context,
      listen: false,
    );

    final selectedCropId =
        _selectedCropValue ==
                _aiDetectValue
            ? null
            : _selectedCropValue;

    setState(() {
      _isUploading = true;
    });

    try {
      final imageUrl =
          await _imageUploadService
              .uploadImage(
        imageBytes:
            _selectedImageBytes!,
        fileName:
            _selectedImageName!,
      );

      final symptoms =
          _symptomsController.text
              .trim();

      final result =
          await diagnosisProvider
              .analyzePlant(
        imageUrl: imageUrl,
        cropId: selectedCropId,

        
        plantName: null,

        symptoms: symptoms.isEmpty
            ? null
            : symptoms,
      );

      if (!mounted) {
        return;
      }

      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) =>
              DiagnosisResultScreen(
            result: result,
            imageBytes:
                _selectedImageBytes!,
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
          const Color(0xFFF8FAF4),
      body: Stack(
        children: [
          const Positioned.fill(
            child:
                _DiagnosisBackdrop(),
          ),
          Column(
            children: [
              _DiagnosisTopBar(
                onBack: () =>
                    Navigator.pop(
                  context,
                ),
              ),
              Expanded(
                child:
                    SingleChildScrollView(
                  padding:
                      const EdgeInsets
                          .fromLTRB(
                    24,
                    26,
                    24,
                    42,
                  ),
                  child: Center(
                    child:
                        ConstrainedBox(
                      constraints:
                          const BoxConstraints(
                        maxWidth: 1120,
                      ),
                      child: Column(
                        children: [
                          const _DiagnosisHero(),
                          const SizedBox(
                            height: 20,
                          ),
                          Container(
                            width:
                                double.infinity,
                            padding:
                                const EdgeInsets
                                    .all(
                              24,
                            ),
                            decoration:
                                _diagnosisCardDecoration(
                              24,
                            ),
                            child: Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment
                                      .start,
                              children: [
                                const _DiagnosisSectionTitle(
                                  icon: Icons
                                      .image_search_outlined,
                                  title:
                                      'Plant Image',
                                  subtitle:
                                      'Use a clear, well-lit image of the affected plant area.',
                                ),
                                const SizedBox(
                                  height: 18,
                                ),
                                _DiagnosisImageBox(
                                  imageBytes:
                                      _selectedImageBytes,
                                  isLoading:
                                      isLoading,
                                  onRemove:
                                      _removeImage,
                                ),
                                const SizedBox(
                                  height: 14,
                                ),
                                LayoutBuilder(
                                  builder: (
                                    context,
                                    constraints,
                                  ) {
                                    final narrow =
                                        constraints
                                                .maxWidth <
                                            620;

                                    final cameraButton =
                                        ElevatedButton.icon(
                                      onPressed:
                                          isLoading
                                              ? null
                                              : () {
                                                  _pickImage(
                                                    ImageSource.camera,
                                                  );
                                                },
                                      style:
                                          ElevatedButton
                                              .styleFrom(
                                        backgroundColor:
                                            _diagnosisPrimary,
                                        foregroundColor:
                                            Colors.white,
                                        disabledBackgroundColor:
                                            const Color(
                                          0xFF9FB5A4,
                                        ),
                                        elevation:
                                            0,
                                        minimumSize:
                                            const Size(
                                          0,
                                          50,
                                        ),
                                        shape:
                                            RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius
                                                  .circular(
                                            14,
                                          ),
                                        ),
                                      ),
                                      icon:
                                          const Icon(
                                        Icons
                                            .camera_alt_outlined,
                                      ),
                                      label:
                                          const Text(
                                        'Take Photo',
                                        style:
                                            TextStyle(
                                          fontWeight:
                                              FontWeight
                                                  .w700,
                                        ),
                                      ),
                                    );

                                    final galleryButton =
                                        OutlinedButton
                                            .icon(
                                      onPressed:
                                          isLoading
                                              ? null
                                              : () {
                                                  _pickImage(
                                                    ImageSource.gallery,
                                                  );
                                                },
                                      style:
                                          OutlinedButton
                                              .styleFrom(
                                        foregroundColor:
                                            _diagnosisPrimary,
                                        side:
                                            const BorderSide(
                                          color:
                                              _diagnosisPrimary,
                                        ),
                                        minimumSize:
                                            const Size(
                                          0,
                                          50,
                                        ),
                                        shape:
                                            RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius
                                                  .circular(
                                            14,
                                          ),
                                        ),
                                      ),
                                      icon:
                                          const Icon(
                                        Icons
                                            .photo_library_outlined,
                                      ),
                                      label:
                                          const Text(
                                        'Gallery',
                                        style:
                                            TextStyle(
                                          fontWeight:
                                              FontWeight
                                                  .w700,
                                        ),
                                      ),
                                    );

                                    if (narrow) {
                                      return Column(
                                        children: [
                                          SizedBox(
                                            width:
                                                double.infinity,
                                            child:
                                                cameraButton,
                                          ),
                                          const SizedBox(
                                            height:
                                                12,
                                          ),
                                          SizedBox(
                                            width:
                                                double.infinity,
                                            child:
                                                galleryButton,
                                          ),
                                        ],
                                      );
                                    }

                                    return Row(
                                      children: [
                                        Expanded(
                                          child:
                                              cameraButton,
                                        ),
                                        const SizedBox(
                                          width:
                                              12,
                                        ),
                                        Expanded(
                                          child:
                                              galleryButton,
                                        ),
                                      ],
                                    );
                                  },
                                ),
                                const SizedBox(
                                  height: 26,
                                ),
                                const _DiagnosisSectionTitle(
                                  icon: Icons
                                      .tune_rounded,
                                  title:
                                      'Diagnosis Details',
                                  subtitle:
                                      'Link the diagnosis to a crop or let AI identify the plant automatically.',
                                ),
                                const SizedBox(
                                  height: 18,
                                ),
                                if (cropProvider
                                    .isLoading)
                                  const Center(
                                    child:
                                        Padding(
                                      padding:
                                          EdgeInsets
                                              .all(
                                        10,
                                      ),
                                      child:
                                          CircularProgressIndicator(
                                        color:
                                            _diagnosisPrimary,
                                      ),
                                    ),
                                  )
                                else
                                  DropdownButtonFormField<
                                      String>(
                                    initialValue:
                                        _selectedCropValue,
                                    decoration:
                                        _diagnosisFieldDecoration(
                                      label:
                                          'Link to Crop (Optional)',
                                      icon: Icons
                                          .eco_outlined,
                                      helperText:
                                          'Leave AI detection selected to identify the plant automatically.',
                                    ),
                                    items: [
                                      const DropdownMenuItem<
                                          String>(
                                        value:
                                            _aiDetectValue,
                                        child: Text(
                                          'Let AI detect the plant',
                                        ),
                                      ),
                                      ...cropProvider
                                          .crops
                                          .map(
                                        (
                                          crop,
                                        ) {
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
                                            value:
                                                cropId,
                                            child:
                                                Text(
                                              cropName,
                                              overflow:
                                                  TextOverflow
                                                      .ellipsis,
                                            ),
                                          );
                                        },
                                      ),
                                    ],
                                    onChanged:
                                        isLoading
                                            ? null
                                            : (
                                                value,
                                              ) {
                                                if (value ==
                                                    null) {
                                                  return;
                                                }

                                                setState(
                                                  () {
                                                    _selectedCropValue =
                                                        value;
                                                  },
                                                );
                                              },
                                  ),
                                const SizedBox(
                                  height: 16,
                                ),
                                TextField(
                                  controller:
                                      _symptomsController,
                                  enabled:
                                      !isLoading,
                                  maxLines: 4,
                                  decoration:
                                      _diagnosisFieldDecoration(
                                    label:
                                        'Observed Symptoms (Optional)',
                                    hint:
                                        'Example: Yellow leaves, brown spots, wilting...',
                                    icon: Icons
                                        .description_outlined,
                                    alignLabelWithHint:
                                        true,
                                  ),
                                ),
                                const SizedBox(
                                  height: 26,
                                ),
                                SizedBox(
                                  width:
                                      double.infinity,
                                  height: 54,
                                  child:
                                      ElevatedButton.icon(
                                    onPressed:
                                        isLoading
                                            ? null
                                            : _analyzePlant,
                                    style:
                                        ElevatedButton
                                            .styleFrom(
                                      backgroundColor:
                                          _diagnosisPrimary,
                                      foregroundColor:
                                          Colors.white,
                                      disabledBackgroundColor:
                                          const Color(
                                        0xFF9FB5A4,
                                      ),
                                      elevation:
                                          0,
                                      shape:
                                          RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius
                                                .circular(
                                          15,
                                        ),
                                      ),
                                    ),
                                    icon:
                                        isLoading
                                            ? const SizedBox(
                                                width:
                                                    20,
                                                height:
                                                    20,
                                                child:
                                                    CircularProgressIndicator(
                                                  strokeWidth:
                                                      2,
                                                  color:
                                                      Colors.white,
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
                                      style:
                                          const TextStyle(
                                        fontWeight:
                                            FontWeight
                                                .w700,
                                        fontSize:
                                            15,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(
                                  height: 16,
                                ),
                                Container(
                                  width:
                                      double.infinity,
                                  padding:
                                      const EdgeInsets
                                          .all(
                                    14,
                                  ),
                                  decoration:
                                      BoxDecoration(
                                    color:
                                        const Color(
                                      0xFFF1F7E9,
                                    ),
                                    borderRadius:
                                        BorderRadius
                                            .circular(
                                      14,
                                    ),
                                  ),
                                  child:
                                      const Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment
                                            .start,
                                    children: [
                                      Icon(
                                        Icons
                                            .tips_and_updates_outlined,
                                        size:
                                            19,
                                        color:
                                            _diagnosisPrimary,
                                      ),
                                      SizedBox(
                                        width:
                                            10,
                                      ),
                                      Expanded(
                                        child:
                                            Text(
                                          'For better results, use a clear photo showing the affected leaves, stem, or fruit.',
                                          style:
                                              TextStyle(
                                            color:
                                                _diagnosisMuted,
                                            fontSize:
                                                12,
                                            height:
                                                1.45,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
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

const _diagnosisDark =
    Color(0xFF173F24);
const _diagnosisPrimary =
    Color(0xFF2F743F);
const _diagnosisLight =
    Color(0xFFEAF3DF);
const _diagnosisText =
    Color(0xFF1D2C21);
const _diagnosisMuted =
    Color(0xFF6C786E);

class _DiagnosisTopBar
    extends StatelessWidget {
  final VoidCallback onBack;

  const _DiagnosisTopBar({
    required this.onBack,
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
            _DiagnosisHeaderButton(
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
                color: const Color(
                  0xFFDDECB8,
                ),
                borderRadius:
                    BorderRadius
                        .circular(
                  13,
                ),
              ),
              child: const Icon(
                Icons.eco_rounded,
                color:
                    _diagnosisDark,
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
                    'Plant Diagnosis',
                    style:
                        TextStyle(
                      color: Color(
                        0xCCFFFFFF,
                      ),
                      fontSize:
                          12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DiagnosisHeaderButton
    extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;

  const _DiagnosisHeaderButton({
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
          alpha: 0.10,
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
                  Colors.white,
              size: 21,
            ),
          ),
        ),
      ),
    );
  }
}

class _DiagnosisHero
    extends StatelessWidget {
  const _DiagnosisHero();

  @override
  Widget build(
    BuildContext context,
  ) {
    return Container(
      width: double.infinity,
      padding:
          const EdgeInsets.all(
        24,
      ),
      decoration:
          _diagnosisCardDecoration(
        24,
      ),
      child: Row(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration:
                BoxDecoration(
              color:
                  _diagnosisLight,
              borderRadius:
                  BorderRadius
                      .circular(
                18,
              ),
            ),
            child:
                const Icon(
              Icons
                  .health_and_safety_outlined,
              size: 32,
              color:
                  _diagnosisPrimary,
            ),
          ),
          const SizedBox(
            width: 16,
          ),
          const Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment
                      .start,
              children: [
                Text(
                  'AI Plant Disease Detection',
                  style:
                      TextStyle(
                    color:
                        _diagnosisText,
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
                  'Capture or select a clear image. AI will identify the plant and analyze visible symptoms.',
                  style:
                      TextStyle(
                    color:
                        _diagnosisMuted,
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
      ),
    );
  }
}

class _DiagnosisSectionTitle
    extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _DiagnosisSectionTitle({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    return Row(
      children: [
        Container(
          width: 43,
          height: 43,
          decoration:
              BoxDecoration(
            color:
                _diagnosisLight,
            borderRadius:
                BorderRadius
                    .circular(
              13,
            ),
          ),
          child: Icon(
            icon,
            color:
                _diagnosisPrimary,
            size: 22,
          ),
        ),
        const SizedBox(
          width: 12,
        ),
        Expanded(
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment
                    .start,
            children: [
              Text(
                title,
                style:
                    const TextStyle(
                  color:
                      _diagnosisText,
                  fontSize:
                      18,
                  fontWeight:
                      FontWeight
                          .w800,
                ),
              ),
              const SizedBox(
                height: 2,
              ),
              Text(
                subtitle,
                style:
                    const TextStyle(
                  color:
                      _diagnosisMuted,
                  fontSize:
                      12,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _DiagnosisImageBox
    extends StatelessWidget {
  final Uint8List? imageBytes;
  final bool isLoading;
  final VoidCallback onRemove;

  const _DiagnosisImageBox({
    required this.imageBytes,
    required this.isLoading,
    required this.onRemove,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    return Container(
      width: double.infinity,
      height: 300,
      decoration:
          BoxDecoration(
        color:
            const Color(
          0xFFF2F6EE,
        ),
        borderRadius:
            BorderRadius.circular(
          18,
        ),
        border: Border.all(
          color:
              const Color(
            0xFFD8E2D4,
          ),
        ),
      ),
      clipBehavior:
          Clip.antiAlias,
      child: imageBytes == null
          ? const Column(
              mainAxisAlignment:
                  MainAxisAlignment
                      .center,
              children: [
                Icon(
                  Icons
                      .image_outlined,
                  size: 64,
                  color:
                      Color(
                    0xFF97A29A,
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                Text(
                  'No image selected',
                  style:
                      TextStyle(
                    color:
                        _diagnosisMuted,
                    fontWeight:
                        FontWeight
                            .w600,
                  ),
                ),
              ],
            )
          : Stack(
              fit:
                  StackFit.expand,
              children: [
                Image.memory(
                  imageBytes!,
                  fit:
                      BoxFit.contain,
                ),
                PositionedDirectional(
                  top: 12,
                  end: 12,
                  child: Material(
                    color:
                        const Color(
                      0xD9FFFFFF,
                    ),
                    borderRadius:
                        BorderRadius
                            .circular(
                      12,
                    ),
                    child: IconButton(
                      tooltip:
                          'Remove image',
                      onPressed:
                          isLoading
                              ? null
                              : onRemove,
                      color:
                          const Color(
                        0xFFC65353,
                      ),
                      icon:
                          const Icon(
                        Icons
                            .close_rounded,
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}

InputDecoration
    _diagnosisFieldDecoration({
  required String label,
  required IconData icon,
  String? hint,
  String? helperText,
  bool alignLabelWithHint = false,
}) {
  return InputDecoration(
    labelText: label,
    hintText: hint,
    helperText: helperText,
    alignLabelWithHint:
        alignLabelWithHint,
    labelStyle:
        const TextStyle(
      color:
          _diagnosisMuted,
    ),
    hintStyle:
        const TextStyle(
      color:
          Color(0xFF9AA59B),
    ),
    helperStyle:
        const TextStyle(
      color:
          _diagnosisMuted,
      fontSize: 11,
    ),
    prefixIcon: Icon(
      icon,
      color:
          _diagnosisPrimary,
      size: 21,
    ),
    filled: true,
    fillColor:
        const Color(
      0xFFFCFDFB,
    ),
    contentPadding:
        const EdgeInsets
            .symmetric(
      horizontal: 16,
      vertical: 17,
    ),
    border:
        OutlineInputBorder(
      borderRadius:
          BorderRadius.circular(
        15,
      ),
      borderSide:
          const BorderSide(
        color:
            Color(
          0xFFD8E2D4,
        ),
      ),
    ),
    enabledBorder:
        OutlineInputBorder(
      borderRadius:
          BorderRadius.circular(
        15,
      ),
      borderSide:
          const BorderSide(
        color:
            Color(
          0xFFD8E2D4,
        ),
      ),
    ),
    focusedBorder:
        OutlineInputBorder(
      borderRadius:
          BorderRadius.circular(
        15,
      ),
      borderSide:
          const BorderSide(
        color:
            _diagnosisPrimary,
        width:
            1.5,
      ),
    ),
  );
}

class _DiagnosisBackdrop
    extends StatelessWidget {
  const _DiagnosisBackdrop();

  @override
  Widget build(
    BuildContext context,
  ) {
    return IgnorePointer(
      child: Stack(
        fit: StackFit.expand,
        children: [
          const DecoratedBox(
            decoration:
                BoxDecoration(
              gradient:
                  LinearGradient(
                begin:
                    Alignment.topCenter,
                end:
                    Alignment.bottomCenter,
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
            top: 180,
            child:
                _DiagnosisGlow(
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
                _DiagnosisGlow(
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

class _DiagnosisGlow
    extends StatelessWidget {
  final double size;
  final Color color;

  const _DiagnosisGlow({
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
    _diagnosisCardDecoration(
  double radius,
) {
  return BoxDecoration(
    color: Colors.white,
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
            _diagnosisDark
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
