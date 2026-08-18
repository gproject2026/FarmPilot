import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../providers/crop_provider.dart';

class AddCropScreen extends StatefulWidget {
  final Map<String, dynamic>? crop;

  const AddCropScreen({
    super.key,
    this.crop,
  });

  @override
  State<AddCropScreen> createState() => _AddCropScreenState();
}

class _AddCropScreenState extends State<AddCropScreen> {
  final _formKey = GlobalKey<FormState>();

  final _cropNameController = TextEditingController();
  final _cropTypeController = TextEditingController();
  final _irrigationController = TextEditingController();
  final _fertilizationController = TextEditingController();
  final _notesController = TextEditingController();

  DateTime? _plantingDate;
  bool _isSaving = false;

  bool get _isEditing => widget.crop != null;

  @override
  void initState() {
    super.initState();

    if (_isEditing) {
      final crop = widget.crop!;

      _cropNameController.text =
          crop['cropName']?.toString() ?? '';

      _cropTypeController.text =
          crop['cropType']?.toString() ?? '';

      _irrigationController.text =
          crop['irrigationSchedule']?.toString() ?? '';

      _fertilizationController.text =
          crop['fertilizationSchedule']?.toString() ?? '';

      _notesController.text =
          crop['notes']?.toString() ?? '';

      final plantingDateValue =
          crop['plantingDate']?.toString();

      if (plantingDateValue != null &&
          plantingDateValue.isNotEmpty) {
        _plantingDate = DateTime.tryParse(
          plantingDateValue,
        );
      }
    }
  }

  @override
  void dispose() {
    _cropNameController.dispose();
    _cropTypeController.dispose();
    _irrigationController.dispose();
    _fertilizationController.dispose();
    _notesController.dispose();

    super.dispose();
  }

  String? _optionalValue(
    TextEditingController controller,
  ) {
    final value = controller.text.trim();

    if (value.isEmpty) {
      return null;
    }

    return value;
  }

  String? _formattedPlantingDate() {
    final date = _plantingDate;

    if (date == null) {
      return null;
    }

    final month = date.month.toString().padLeft(
      2,
      '0',
    );

    final day = date.day.toString().padLeft(
      2,
      '0',
    );

    return '${date.year}-$month-$day';
  }

  Future<void> _selectPlantingDate() async {
    final selectedDate = await showDatePicker(
      context: context,
      initialDate: _plantingDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (selectedDate != null) {
      setState(() {
        _plantingDate = selectedDate;
      });
    }
  }

  Future<void> _saveCrop() async {
    if (!_formKey.currentState!.validate()) {
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
          content: Text(
            'Authentication token not found',
          ),
        ),
      );

      return;
    }

    setState(() {
      _isSaving = true;
    });

    bool success;

    if (_isEditing) {
      success = await cropProvider.updateCrop(
        token: token,
        cropId: widget.crop!['id'].toString(),
        cropName: _cropNameController.text.trim(),
        cropType: _optionalValue(
          _cropTypeController,
        ),
        plantingDate: _formattedPlantingDate(),
        irrigationSchedule: _optionalValue(
          _irrigationController,
        ),
        fertilizationSchedule: _optionalValue(
          _fertilizationController,
        ),
        notes: _optionalValue(
          _notesController,
        ),
      );
    } else {
      success = await cropProvider.createCrop(
        token: token,
        cropName: _cropNameController.text.trim(),
        cropType: _optionalValue(
          _cropTypeController,
        ),
        plantingDate: _formattedPlantingDate(),
        irrigationSchedule: _optionalValue(
          _irrigationController,
        ),
        fertilizationSchedule: _optionalValue(
          _fertilizationController,
        ),
        notes: _optionalValue(
          _notesController,
        ),
      );
    }

    if (!mounted) {
      return;
    }

    setState(() {
      _isSaving = false;
    });

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _isEditing
                ? 'Crop updated successfully'
                : 'Crop added successfully',
          ),
        ),
      );

      Navigator.pop(
        context,
        true,
      );

      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          cropProvider.errorMessage ??
              'Failed to save crop',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final formattedDate = _plantingDate == null
        ? 'Select planting date'
        : _formattedPlantingDate()!;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAF4),
      body: Stack(
        children: [
          const Positioned.fill(child: _AddCropBackdrop()),
          Column(
            children: [
              _AddCropTopBar(
                title: _isEditing ? 'Edit Crop' : 'Add Crop',
                onBack: () => Navigator.pop(context),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(
                    24,
                    26,
                    24,
                    42,
                  ),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(
                        maxWidth: 980,
                      ),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            _AddCropHero(
                              isEditing: _isEditing,
                            ),
                            const SizedBox(height: 20),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(24),
                              decoration: _addCropCardDecoration(
                                24,
                              ),
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  const _FormSectionTitle(
                                    icon: Icons.eco_outlined,
                                    title: 'Crop Information',
                                    subtitle:
                                        'Enter the crop details and management schedule.',
                                  ),
                                  const SizedBox(height: 24),
                                  LayoutBuilder(
                                    builder: (
                                      context,
                                      constraints,
                                    ) {
                                      if (constraints.maxWidth <
                                          680) {
                                        return Column(
                                          children: [
                                            _StyledCropField(
                                              controller:
                                                  _cropNameController,
                                              label: 'Crop name',
                                              hint:
                                                  'Example: Tomato',
                                              icon:
                                                  Icons.eco_outlined,
                                              validator:
                                                  (value) {
                                                if (value == null ||
                                                    value
                                                        .trim()
                                                        .isEmpty) {
                                                  return 'Please enter the crop name';
                                                }
                                                return null;
                                              },
                                            ),
                                            const SizedBox(
                                              height: 16,
                                            ),
                                            _StyledCropField(
                                              controller:
                                                  _cropTypeController,
                                              label: 'Crop type',
                                              hint:
                                                  'Example: Vegetable',
                                              icon: Icons
                                                  .category_outlined,
                                            ),
                                          ],
                                        );
                                      }

                                      return Row(
                                        children: [
                                          Expanded(
                                            child:
                                                _StyledCropField(
                                              controller:
                                                  _cropNameController,
                                              label: 'Crop name',
                                              hint:
                                                  'Example: Tomato',
                                              icon:
                                                  Icons.eco_outlined,
                                              validator:
                                                  (value) {
                                                if (value == null ||
                                                    value
                                                        .trim()
                                                        .isEmpty) {
                                                  return 'Please enter the crop name';
                                                }
                                                return null;
                                              },
                                            ),
                                          ),
                                          const SizedBox(
                                            width: 16,
                                          ),
                                          Expanded(
                                            child:
                                                _StyledCropField(
                                              controller:
                                                  _cropTypeController,
                                              label: 'Crop type',
                                              hint:
                                                  'Example: Vegetable',
                                              icon: Icons
                                                  .category_outlined,
                                            ),
                                          ),
                                        ],
                                      );
                                    },
                                  ),
                                  const SizedBox(height: 16),
                                  _DateField(
                                    value: formattedDate,
                                    hasDate:
                                        _plantingDate != null,
                                    onTap:
                                        _selectPlantingDate,
                                    onClear: () {
                                      setState(() {
                                        _plantingDate = null;
                                      });
                                    },
                                  ),
                                  const SizedBox(height: 16),
                                  _StyledCropField(
                                    controller:
                                        _irrigationController,
                                    label:
                                        'Irrigation schedule',
                                    hint:
                                        'Example: Every two days',
                                    icon: Icons
                                        .water_drop_outlined,
                                  ),
                                  const SizedBox(height: 16),
                                  _StyledCropField(
                                    controller:
                                        _fertilizationController,
                                    label:
                                        'Fertilization schedule',
                                    hint:
                                        'Example: Once every two weeks',
                                    icon:
                                        Icons.science_outlined,
                                  ),
                                  const SizedBox(height: 16),
                                  _StyledCropField(
                                    controller:
                                        _notesController,
                                    label: 'Notes',
                                    hint:
                                        'Write any additional notes',
                                    icon:
                                        Icons.notes_rounded,
                                    maxLines: 4,
                                  ),
                                  const SizedBox(height: 26),
                                  SizedBox(
                                    width: double.infinity,
                                    height: 54,
                                    child:
                                        ElevatedButton.icon(
                                      onPressed: _isSaving
                                          ? null
                                          : _saveCrop,
                                      style: ElevatedButton
                                          .styleFrom(
                                        backgroundColor:
                                            _addCropPrimary,
                                        foregroundColor:
                                            Colors.white,
                                        disabledBackgroundColor:
                                            const Color(
                                          0xFF9FB5A4,
                                        ),
                                        elevation: 0,
                                        shape:
                                            RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius
                                                  .circular(
                                            15,
                                          ),
                                        ),
                                      ),
                                      icon: _isSaving
                                          ? const SizedBox(
                                              width: 20,
                                              height: 20,
                                              child:
                                                  CircularProgressIndicator(
                                                strokeWidth:
                                                    2,
                                                color:
                                                    Colors.white,
                                              ),
                                            )
                                          : Icon(
                                              _isEditing
                                                  ? Icons
                                                      .save_outlined
                                                  : Icons
                                                      .add_rounded,
                                            ),
                                      label: Text(
                                        _isSaving
                                            ? 'Saving...'
                                            : _isEditing
                                                ? 'Save Changes'
                                                : 'Add Crop',
                                        style:
                                            const TextStyle(
                                          fontWeight:
                                              FontWeight.w700,
                                          fontSize: 15,
                                        ),
                                      ),
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
              ),
            ],
          ),
        ],
      ),
    );
  }
}

const _addCropDark = Color(0xFF173F24);
const _addCropPrimary = Color(0xFF2F743F);
const _addCropLight = Color(0xFFEAF3DF);
const _addCropText = Color(0xFF1D2C21);
const _addCropMuted = Color(0xFF6C786E);

class _AddCropTopBar extends StatelessWidget {
  final String title;
  final VoidCallback onBack;

  const _AddCropTopBar({
    required this.title,
    required this.onBack,
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
            _AddCropHeaderButton(
              icon: Icons.arrow_back_rounded,
              tooltip: 'Back',
              onTap: onBack,
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
                color: _addCropDark,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  const Text(
                    'FarmPilot',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 19,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  Text(
                    title,
                    style: const TextStyle(
                      color: Color(0xCCFFFFFF),
                      fontSize: 12,
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

class _AddCropHeaderButton extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;

  const _AddCropHeaderButton({
    required this.icon,
    required this.tooltip,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: Colors.white.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: SizedBox(
            width: 44,
            height: 44,
            child: Icon(
              icon,
              color: Colors.white,
              size: 21,
            ),
          ),
        ),
      ),
    );
  }
}

class _AddCropHero extends StatelessWidget {
  final bool isEditing;

  const _AddCropHero({
    required this.isEditing,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: _addCropCardDecoration(24),
      child: Row(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: _addCropLight,
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Icon(
              Icons.eco_rounded,
              size: 31,
              color: _addCropPrimary,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  isEditing
                      ? 'Edit Crop'
                      : 'Add New Crop',
                  style: const TextStyle(
                    color: _addCropText,
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  isEditing
                      ? 'Update crop information and management schedules.'
                      : 'Add a crop and start tracking its planting and care schedule.',
                  style: const TextStyle(
                    color: _addCropMuted,
                    fontSize: 13,
                    height: 1.4,
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

class _FormSectionTitle extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _FormSectionTitle({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 43,
          height: 43,
          decoration: BoxDecoration(
            color: _addCropLight,
            borderRadius: BorderRadius.circular(13),
          ),
          child: Icon(
            icon,
            color: _addCropPrimary,
            size: 22,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: _addCropText,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: const TextStyle(
                  color: _addCropMuted,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _StyledCropField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final IconData icon;
  final String? Function(String?)? validator;
  final int maxLines;

  const _StyledCropField({
    required this.controller,
    required this.label,
    required this.hint,
    required this.icon,
    this.validator,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      validator: validator,
      maxLines: maxLines,
      style: const TextStyle(
        color: _addCropText,
        fontSize: 14,
        fontWeight: FontWeight.w600,
      ),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        labelStyle: const TextStyle(
          color: _addCropMuted,
        ),
        hintStyle: const TextStyle(
          color: Color(0xFF9AA59B),
        ),
        prefixIcon: Icon(
          icon,
          color: _addCropPrimary,
          size: 21,
        ),
        filled: true,
        fillColor: const Color(0xFFFCFDFB),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 17,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(
            color: Color(0xFFD8E2D4),
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(
            color: Color(0xFFD8E2D4),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(
            color: _addCropPrimary,
            width: 1.5,
          ),
        ),
      ),
    );
  }
}

class _DateField extends StatelessWidget {
  final String value;
  final bool hasDate;
  final VoidCallback onTap;
  final VoidCallback onClear;

  const _DateField({
    required this.value,
    required this.hasDate,
    required this.onTap,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(15),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: 'Planting date',
          labelStyle: const TextStyle(
            color: _addCropMuted,
          ),
          prefixIcon: const Icon(
            Icons.calendar_month_outlined,
            color: _addCropPrimary,
          ),
          filled: true,
          fillColor: const Color(0xFFFCFDFB),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: const BorderSide(
              color: Color(0xFFD8E2D4),
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: const BorderSide(
              color: Color(0xFFD8E2D4),
            ),
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                value,
                style: TextStyle(
                  color: hasDate
                      ? _addCropText
                      : _addCropMuted,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            if (hasDate)
              IconButton(
                tooltip: 'Clear date',
                onPressed: onClear,
                icon: const Icon(
                  Icons.close_rounded,
                  size: 19,
                  color: _addCropMuted,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _AddCropBackdrop extends StatelessWidget {
  const _AddCropBackdrop();

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
            top: 180,
            child: _AddCropGlow(
              size: 450,
              color: Color(0xFFCFE6B4),
            ),
          ),
          PositionedDirectional(
            start: -190,
            bottom: -220,
            child: _AddCropGlow(
              size: 520,
              color: Color(0xFFE7DFAF),
            ),
          ),
        ],
      ),
    );
  }
}

class _AddCropGlow extends StatelessWidget {
  final double size;
  final Color color;

  const _AddCropGlow({
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

BoxDecoration _addCropCardDecoration(
  double radius,
) {
  return BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(radius),
    border: Border.all(
      color: const Color(0xFFDCE5D8),
    ),
    boxShadow: [
      BoxShadow(
        color: _addCropDark.withValues(alpha: 0.05),
        blurRadius: 20,
        offset: const Offset(0, 7),
      ),
    ],
  );
}
