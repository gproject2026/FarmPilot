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

  InputDecoration _inputDecoration({
    required String label,
    required IconData icon,
    String? hint,
  }) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      prefixIcon: Icon(
        icon,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(
          12,
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
      appBar: AppBar(
        title: Text(
          _isEditing ? 'Edit Crop' : 'Add Crop',
        ),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(
          16,
        ),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  color: Colors.green.shade100,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.eco,
                  size: 48,
                  color: Colors.green.shade700,
                ),
              ),
              const SizedBox(
                height: 24,
              ),
              TextFormField(
                controller: _cropNameController,
                decoration: _inputDecoration(
                  label: 'Crop name',
                  hint: 'Example: Tomato',
                  icon: Icons.eco,
                ),
                validator: (value) {
                  if (value == null ||
                      value.trim().isEmpty) {
                    return 'Please enter the crop name';
                  }

                  return null;
                },
              ),
              const SizedBox(
                height: 16,
              ),
              TextFormField(
                controller: _cropTypeController,
                decoration: _inputDecoration(
                  label: 'Crop type',
                  hint: 'Example: Vegetable',
                  icon: Icons.category_outlined,
                ),
              ),
              const SizedBox(
                height: 16,
              ),
              InkWell(
                onTap: _selectPlantingDate,
                borderRadius: BorderRadius.circular(
                  12,
                ),
                child: InputDecorator(
                  decoration: _inputDecoration(
                    label: 'Planting date',
                    icon: Icons.calendar_month,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          formattedDate,
                          style: TextStyle(
                            color: _plantingDate == null
                                ? Colors.grey.shade700
                                : Colors.black,
                          ),
                        ),
                      ),
                      if (_plantingDate != null)
                        IconButton(
                          onPressed: () {
                            setState(() {
                              _plantingDate = null;
                            });
                          },
                          icon: const Icon(
                            Icons.close,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(
                height: 16,
              ),
              TextFormField(
                controller: _irrigationController,
                decoration: _inputDecoration(
                  label: 'Irrigation schedule',
                  hint: 'Example: Every two days',
                  icon: Icons.water_drop_outlined,
                ),
              ),
              const SizedBox(
                height: 16,
              ),
              TextFormField(
                controller: _fertilizationController,
                decoration: _inputDecoration(
                  label: 'Fertilization schedule',
                  hint: 'Example: Once every two weeks',
                  icon: Icons.science_outlined,
                ),
              ),
              const SizedBox(
                height: 16,
              ),
              TextFormField(
                controller: _notesController,
                maxLines: 4,
                decoration: _inputDecoration(
                  label: 'Notes',
                  hint: 'Write any additional notes',
                  icon: Icons.notes,
                ),
              ),
              const SizedBox(
                height: 28,
              ),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  onPressed:
                      _isSaving ? null : _saveCrop,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                        12,
                      ),
                    ),
                  ),
                  icon: _isSaving
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Icon(
                          _isEditing
                              ? Icons.save
                              : Icons.add,
                        ),
                  label: Text(
                    _isSaving
                        ? 'Saving...'
                        : _isEditing
                            ? 'Save Changes'
                            : 'Add Crop',
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