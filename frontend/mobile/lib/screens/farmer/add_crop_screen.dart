import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../l10n/generated/app_localizations.dart';
import '../../providers/auth_provider.dart';
import '../../providers/crop_provider.dart';
import '../../providers/locale_provider.dart';

String _t(
  BuildContext context,
  String english,
  String arabic,
) {
  return Localizations.localeOf(context).languageCode == 'ar'
      ? arabic
      : english;
}

class _CropTypeOption {
  final String value;
  final String english;
  final String arabic;

  const _CropTypeOption({
    required this.value,
    required this.english,
    required this.arabic,
  });
}

const _cropTypeOptions = <_CropTypeOption>[
  _CropTypeOption(value: 'VEGETABLE', english: 'Vegetable', arabic: 'خضروات'),
  _CropTypeOption(value: 'FRUIT', english: 'Fruit', arabic: 'فواكه'),
  _CropTypeOption(value: 'GRAIN', english: 'Grain', arabic: 'حبوب'),
  _CropTypeOption(value: 'HERB', english: 'Herb', arabic: 'أعشاب'),
  _CropTypeOption(value: 'LEGUME', english: 'Legume', arabic: 'بقوليات'),
  _CropTypeOption(value: 'ROOT', english: 'Root crop', arabic: 'محاصيل جذرية'),
  _CropTypeOption(value: 'OTHER', english: 'Other', arabic: 'أخرى'),
];

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
  final _irrigationController = TextEditingController();
  final _fertilizationController = TextEditingController();
  final _notesController = TextEditingController();

  DateTime? _plantingDate;
  bool _isSaving = false;
  String? _selectedCropType;
  String? _lastLanguageCode;

  String? _cropNameEn;
  String? _cropNameAr;
  String? _cropTypeEn;
  String? _cropTypeAr;
  String? _irrigationScheduleEn;
  String? _irrigationScheduleAr;
  String? _fertilizationScheduleEn;
  String? _fertilizationScheduleAr;
  String? _notesEn;
  String? _notesAr;

  bool get _isEditing => widget.crop != null;

  @override
  void initState() {
    super.initState();

    if (_isEditing) {
      final crop = widget.crop!;

      _cropNameEn = crop['cropNameEn']?.toString().trim();
      _cropNameAr = crop['cropNameAr']?.toString().trim();
      _cropTypeEn = crop['cropTypeEn']?.toString().trim();
      _cropTypeAr = crop['cropTypeAr']?.toString().trim();
      _irrigationScheduleEn =
          crop['irrigationScheduleEn']?.toString().trim();
      _irrigationScheduleAr =
          crop['irrigationScheduleAr']?.toString().trim();
      _fertilizationScheduleEn =
          crop['fertilizationScheduleEn']?.toString().trim();
      _fertilizationScheduleAr =
          crop['fertilizationScheduleAr']?.toString().trim();
      _notesEn = crop['notesEn']?.toString().trim();
      _notesAr = crop['notesAr']?.toString().trim();

      final fallbackName =
          crop['cropName']?.toString().trim() ?? '';
      final fallbackType =
          crop['cropType']?.toString().trim() ?? '';
      final fallbackIrrigation =
          crop['irrigationSchedule']?.toString().trim() ?? '';
      final fallbackFertilization =
          crop['fertilizationSchedule']?.toString().trim() ?? '';
      final fallbackNotes =
          crop['notes']?.toString().trim() ?? '';

      _cropNameController.text =
          _cropNameEn?.isNotEmpty == true
              ? _cropNameEn!
              : _cropNameAr?.isNotEmpty == true
                  ? _cropNameAr!
                  : fallbackName;

      _irrigationController.text =
          _irrigationScheduleEn?.isNotEmpty == true
              ? _irrigationScheduleEn!
              : _irrigationScheduleAr?.isNotEmpty == true
                  ? _irrigationScheduleAr!
                  : fallbackIrrigation;

      _fertilizationController.text =
          _fertilizationScheduleEn?.isNotEmpty == true
              ? _fertilizationScheduleEn!
              : _fertilizationScheduleAr?.isNotEmpty == true
                  ? _fertilizationScheduleAr!
                  : fallbackFertilization;

      _notesController.text =
          _notesEn?.isNotEmpty == true
              ? _notesEn!
              : _notesAr?.isNotEmpty == true
                  ? _notesAr!
                  : fallbackNotes;

      _selectedCropType = _matchCropType(
        _cropTypeEn?.isNotEmpty == true
            ? _cropTypeEn!
            : _cropTypeAr?.isNotEmpty == true
                ? _cropTypeAr!
                : fallbackType,
      );

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
  void didChangeDependencies() {
    super.didChangeDependencies();

    final languageCode =
        Localizations.localeOf(context).languageCode;

    if (_lastLanguageCode == null) {
      _lastLanguageCode = languageCode;
      _applyLocalizedValues(languageCode);
      return;
    }

    if (_lastLanguageCode != languageCode) {
      _storeVisibleValues(_lastLanguageCode!);
      _lastLanguageCode = languageCode;
      _applyLocalizedValues(languageCode);
    }
  }

  String? _matchCropType(String? value) {
    final normalized = value?.trim().toLowerCase();

    if (normalized == null || normalized.isEmpty) {
      return null;
    }

    for (final option in _cropTypeOptions) {
      if (option.value.toLowerCase() == normalized ||
          option.english.toLowerCase() == normalized ||
          option.arabic == value?.trim()) {
        return option.value;
      }
    }

    return null;
  }

  _CropTypeOption? _selectedTypeOption() {
    final value = _selectedCropType;

    if (value == null) {
      return null;
    }

    for (final option in _cropTypeOptions) {
      if (option.value == value) {
        return option;
      }
    }

    return null;
  }

  void _storeVisibleValues(String languageCode) {
    final isArabic = languageCode == 'ar';

    if (isArabic) {
      _cropNameAr = _cropNameController.text.trim();
      _irrigationScheduleAr =
          _irrigationController.text.trim();
      _fertilizationScheduleAr =
          _fertilizationController.text.trim();
      _notesAr = _notesController.text.trim();
    } else {
      _cropNameEn = _cropNameController.text.trim();
      _irrigationScheduleEn =
          _irrigationController.text.trim();
      _fertilizationScheduleEn =
          _fertilizationController.text.trim();
      _notesEn = _notesController.text.trim();
    }
  }

  void _applyLocalizedValues(String languageCode) {
    final isArabic = languageCode == 'ar';

    final name = isArabic ? _cropNameAr : _cropNameEn;
    final irrigation = isArabic
        ? _irrigationScheduleAr
        : _irrigationScheduleEn;
    final fertilization = isArabic
        ? _fertilizationScheduleAr
        : _fertilizationScheduleEn;
    final notes = isArabic ? _notesAr : _notesEn;

    if (name != null && name.isNotEmpty) {
      _cropNameController.text = name;
    }

    if (irrigation != null && irrigation.isNotEmpty) {
      _irrigationController.text = irrigation;
    }

    if (fertilization != null &&
        fertilization.isNotEmpty) {
      _fertilizationController.text = fertilization;
    }

    if (notes != null && notes.isNotEmpty) {
      _notesController.text = notes;
    }
  }

  @override
  void dispose() {
    _cropNameController.dispose();
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

  Future<void> _generateAiCare() async {
    final cropName =
        _cropNameController.text.trim();
    final typeOption =
        _selectedTypeOption();

    if (cropName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _t(
              context,
              'Please enter the crop name first',
              'يرجى إدخال اسم المحصول أولًا',
            ),
          ),
        ),
      );
      return;
    }

    if (typeOption == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _t(
              context,
              'Please select the crop type first',
              'يرجى اختيار نوع المحصول أولًا',
            ),
          ),
        ),
      );
      return;
    }

    final languageCode =
        Localizations.localeOf(context).languageCode;

    _storeVisibleValues(languageCode);

    final cropProvider =
        Provider.of<CropProvider>(
      context,
      listen: false,
    );

    final result =
        await cropProvider.generateCropCareSuggestion(
      cropName: cropName,
      cropType: languageCode == 'ar'
          ? typeOption.arabic
          : typeOption.english,
      language: languageCode,
      plantingDate: _formattedPlantingDate(),
      notes: _optionalValue(_notesController),
    );

    if (!mounted) {
      return;
    }

    if (result == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            cropProvider.errorMessage ??
                _t(
                  context,
                  'Failed to generate AI crop care suggestions',
                  'فشل إنشاء اقتراحات العناية بالمحصول',
                ),
          ),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final enteredName = cropName;

    _cropNameEn =
        result['cropNameEn']?.toString().trim();
    _cropNameAr =
        result['cropNameAr']?.toString().trim();

    if (languageCode == 'ar') {
      _cropNameAr = enteredName;
    } else {
      _cropNameEn = enteredName;
    }

    _cropTypeEn = typeOption.english;
    _cropTypeAr = typeOption.arabic;

    _irrigationScheduleEn =
        result['irrigationScheduleEn']
            ?.toString()
            .trim();
    _irrigationScheduleAr =
        result['irrigationScheduleAr']
            ?.toString()
            .trim();

    _fertilizationScheduleEn =
        result['fertilizationScheduleEn']
            ?.toString()
            .trim();
    _fertilizationScheduleAr =
        result['fertilizationScheduleAr']
            ?.toString()
            .trim();

    setState(() {
      _irrigationController.text =
          languageCode == 'ar'
              ? (_irrigationScheduleAr ?? '')
              : (_irrigationScheduleEn ?? '');

      _fertilizationController.text =
          languageCode == 'ar'
              ? (_fertilizationScheduleAr ?? '')
              : (_fertilizationScheduleEn ?? '');
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          _t(
            context,
            'AI suggestions added. You can edit them before saving.',
            'تمت إضافة اقتراحات الذكاء الاصطناعي، ويمكنك تعديلها قبل الحفظ.',
          ),
        ),
      ),
    );
  }

  Future<void> _saveCrop() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final typeOption =
        _selectedTypeOption();

    if (typeOption == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _t(
              context,
              'Please select a crop type',
              'يرجى اختيار نوع المحصول',
            ),
          ),
        ),
      );
      return;
    }

    final languageCode =
        Localizations.localeOf(context).languageCode;

    _storeVisibleValues(languageCode);

    _cropTypeEn = typeOption.english;
    _cropTypeAr = typeOption.arabic;

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
        SnackBar(
          content: Text(
            _t(
              context,
              'Authentication token not found',
              'لم يتم العثور على رمز تسجيل الدخول',
            ),
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
        cropType: languageCode == 'ar'
            ? typeOption.arabic
            : typeOption.english,
        cropNameEn: _cropNameEn,
        cropNameAr: _cropNameAr,
        cropTypeEn: _cropTypeEn,
        cropTypeAr: _cropTypeAr,
        plantingDate: _formattedPlantingDate(),
        irrigationSchedule:
            _optionalValue(_irrigationController),
        irrigationScheduleEn:
            _irrigationScheduleEn,
        irrigationScheduleAr:
            _irrigationScheduleAr,
        fertilizationSchedule:
            _optionalValue(_fertilizationController),
        fertilizationScheduleEn:
            _fertilizationScheduleEn,
        fertilizationScheduleAr:
            _fertilizationScheduleAr,
        notes: _optionalValue(_notesController),
        notesEn: _notesEn,
        notesAr: _notesAr,
      );
    } else {
      success = await cropProvider.createCrop(
        token: token,
        cropName: _cropNameController.text.trim(),
        cropType: languageCode == 'ar'
            ? typeOption.arabic
            : typeOption.english,
        cropNameEn: _cropNameEn,
        cropNameAr: _cropNameAr,
        cropTypeEn: _cropTypeEn,
        cropTypeAr: _cropTypeAr,
        plantingDate: _formattedPlantingDate(),
        irrigationSchedule:
            _optionalValue(_irrigationController),
        irrigationScheduleEn:
            _irrigationScheduleEn,
        irrigationScheduleAr:
            _irrigationScheduleAr,
        fertilizationSchedule:
            _optionalValue(_fertilizationController),
        fertilizationScheduleEn:
            _fertilizationScheduleEn,
        fertilizationScheduleAr:
            _fertilizationScheduleAr,
        notes: _optionalValue(_notesController),
        notesEn: _notesEn,
        notesAr: _notesAr,
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
                ? _t(
                    context,
                    'Crop updated successfully',
                    'تم تحديث المحصول بنجاح',
                  )
                : _t(
                    context,
                    'Crop added successfully',
                    'تمت إضافة المحصول بنجاح',
                  ),
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
              _t(
                context,
                'Failed to save crop',
                'فشل حفظ المحصول',
              ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n =
        AppLocalizations.of(context)!;

    final isArabic =
        Localizations.localeOf(context).languageCode == 'ar';

    final cropProvider =
        Provider.of<CropProvider>(
      context,
    );

    final formattedDate = _plantingDate == null
        ? _t(
            context,
            'Select planting date',
            'اختر تاريخ الزراعة',
          )
        : _formattedPlantingDate()!;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAF4),
      body: Stack(
        children: [
          const Positioned.fill(child: _AddCropBackdrop()),
          Column(
            children: [
              _AddCropTopBar(
                title: _isEditing
                    ? _t(
                        context,
                        'Edit Crop',
                        'تعديل المحصول',
                      )
                    : _t(
                        context,
                        'Add Crop',
                        'إضافة محصول',
                      ),
                onBack: () =>
                    Navigator.pop(context),
                onLanguage:
                    _changeLanguage,
                isArabic:
                    isArabic,
                l10n:
                    l10n,
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
                                  _FormSectionTitle(
                                    icon: Icons.eco_outlined,
                                    title: _t(
                                      context,
                                      'Crop Information',
                                      'معلومات المحصول',
                                    ),
                                    subtitle: _t(
                                      context,
                                      'Enter the crop details and management schedule.',
                                      'أدخل تفاصيل المحصول وجدول إدارته.',
                                    ),
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
                                              label: _t(context, 'Crop name', 'اسم المحصول'),
                                              hint: _t(context, 'Example: Tomato', 'مثال: طماطم'),
                                              icon:
                                                  Icons.eco_outlined,
                                              validator:
                                                  (value) {
                                                if (value == null ||
                                                    value
                                                        .trim()
                                                        .isEmpty) {
                                                  return _t(context, 'Please enter the crop name', 'يرجى إدخال اسم المحصول');
                                                }
                                                return null;
                                              },
                                            ),
                                            const SizedBox(
                                              height: 16,
                                            ),
                                            _CropTypeDropdown(
                                              value:
                                                  _selectedCropType,
                                              isArabic:
                                                  isArabic,
                                              onChanged:
                                                  (value) {
                                                setState(() {
                                                  _selectedCropType =
                                                      value;
                                                });
                                              },
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
                                              label: _t(context, 'Crop name', 'اسم المحصول'),
                                              hint: _t(context, 'Example: Tomato', 'مثال: طماطم'),
                                              icon:
                                                  Icons.eco_outlined,
                                              validator:
                                                  (value) {
                                                if (value == null ||
                                                    value
                                                        .trim()
                                                        .isEmpty) {
                                                  return _t(context, 'Please enter the crop name', 'يرجى إدخال اسم المحصول');
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
                                                _CropTypeDropdown(
                                              value:
                                                  _selectedCropType,
                                              isArabic:
                                                  isArabic,
                                              onChanged:
                                                  (value) {
                                                setState(() {
                                                  _selectedCropType =
                                                      value;
                                                });
                                              },
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
                                  const SizedBox(height: 18),
                                  SizedBox(
                                    width: double.infinity,
                                    child: OutlinedButton.icon(
                                      onPressed:
                                          cropProvider.isGeneratingCare
                                              ? null
                                              : _generateAiCare,
                                      style:
                                          OutlinedButton.styleFrom(
                                        foregroundColor:
                                            _addCropPrimary,
                                        side: const BorderSide(
                                          color:
                                              _addCropPrimary,
                                        ),
                                        padding:
                                            const EdgeInsets.symmetric(
                                          horizontal: 18,
                                          vertical: 15,
                                        ),
                                        shape:
                                            RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(
                                            14,
                                          ),
                                        ),
                                      ),
                                      icon:
                                          cropProvider.isGeneratingCare
                                              ? const SizedBox(
                                                  width: 19,
                                                  height: 19,
                                                  child:
                                                      CircularProgressIndicator(
                                                    strokeWidth:
                                                        2,
                                                    color:
                                                        _addCropPrimary,
                                                  ),
                                                )
                                              : const Icon(
                                                  Icons.auto_awesome_rounded,
                                                ),
                                      label: Text(
                                        cropProvider.isGeneratingCare
                                            ? _t(
                                                context,
                                                'Generating suggestions...',
                                                'جارٍ إنشاء الاقتراحات...',
                                              )
                                            : _t(
                                                context,
                                                'Suggest irrigation and fertilization with AI',
                                                'اقتراح الري والتسميد بالذكاء الاصطناعي',
                                              ),
                                        style:
                                            const TextStyle(
                                          fontWeight:
                                              FontWeight.w700,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  _StyledCropField(
                                    controller:
                                        _irrigationController,
                                    label: _t(context, 'Irrigation schedule', 'جدول الري'),
                                    hint: _t(context, 'Example: Every two days', 'مثال: كل يومين'),
                                    icon: Icons
                                        .water_drop_outlined,
                                  ),
                                  const SizedBox(height: 16),
                                  _StyledCropField(
                                    controller:
                                        _fertilizationController,
                                    label: _t(context, 'Fertilization schedule', 'جدول التسميد'),
                                    hint: _t(context, 'Example: Once every two weeks', 'مثال: مرة كل أسبوعين'),
                                    icon:
                                        Icons.science_outlined,
                                  ),
                                  const SizedBox(height: 16),
                                  _StyledCropField(
                                    controller:
                                        _notesController,
                                    label: _t(context, 'Notes', 'ملاحظات'),
                                    hint: _t(context, 'Write any additional notes', 'اكتب أي ملاحظات إضافية'),
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
                                            ? _t(
                                                context,
                                                'Saving...',
                                                'جارٍ الحفظ...',
                                              )
                                            : _isEditing
                                                ? _t(
                                                    context,
                                                    'Save Changes',
                                                    'حفظ التغييرات',
                                                  )
                                                : _t(
                                                    context,
                                                    'Add Crop',
                                                    'إضافة محصول',
                                                  ),
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
  final ValueChanged<String> onLanguage;
  final bool isArabic;
  final AppLocalizations l10n;

  const _AddCropTopBar({
    required this.title,
    required this.onBack,
    required this.onLanguage,
    required this.isArabic,
    required this.l10n,
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
              tooltip: _t(
                context,
                'Back',
                'رجوع',
              ),
              onTap: onBack,
            ),
            const SizedBox(width: 12),
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
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
                color: _addCropDark,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.appName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 19,
                      fontWeight:
                          FontWeight.w800,
                    ),
                  ),
                  Text(
                    title,
                    style: const TextStyle(
                      color:
                          Color(0xCCFFFFFF),
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
              onSelected: onLanguage,
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
                              ? _addCropPrimary
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
                              ? _addCropPrimary
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
                decoration: BoxDecoration(
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
                  color: Colors.white,
                  size: 21,
                ),
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
                      ? _t(
                          context,
                          'Edit Crop',
                          'تعديل المحصول',
                        )
                      : _t(
                          context,
                          'Add New Crop',
                          'إضافة محصول جديد',
                        ),
                  style: const TextStyle(
                    color: _addCropText,
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  isEditing
                      ? _t(
                          context,
                          'Update crop information and management schedules.',
                          'حدّث معلومات المحصول وجداول إدارته.',
                        )
                      : _t(
                          context,
                          'Add a crop and start tracking its planting and care schedule.',
                          'أضف محصولًا وابدأ بمتابعة موعد زراعته وجدول العناية به.',
                        ),
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

class _CropTypeDropdown extends StatelessWidget {
  final String? value;
  final bool isArabic;
  final ValueChanged<String?> onChanged;

  const _CropTypeDropdown({
    required this.value,
    required this.isArabic,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      initialValue: value,
      isExpanded: true,
      decoration: InputDecoration(
        labelText: _t(
          context,
          'Crop type',
          'نوع المحصول',
        ),
        hintText: _t(
          context,
          'Select crop type',
          'اختر نوع المحصول',
        ),
        prefixIcon: const Icon(
          Icons.category_outlined,
          color: _addCropPrimary,
          size: 21,
        ),
        filled: true,
        fillColor: const Color(0xFFFCFDFB),
        contentPadding:
            const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 17,
        ),
        border: OutlineInputBorder(
          borderRadius:
              BorderRadius.circular(15),
          borderSide: const BorderSide(
            color: Color(0xFFD8E2D4),
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius:
              BorderRadius.circular(15),
          borderSide: const BorderSide(
            color: Color(0xFFD8E2D4),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius:
              BorderRadius.circular(15),
          borderSide: const BorderSide(
            color: _addCropPrimary,
            width: 1.5,
          ),
        ),
      ),
      items: _cropTypeOptions
          .map(
            (option) =>
                DropdownMenuItem<String>(
              value: option.value,
              child: Text(
                isArabic
                    ? option.arabic
                    : option.english,
              ),
            ),
          )
          .toList(),
      onChanged: onChanged,
      validator: (selectedValue) {
        if (selectedValue == null ||
            selectedValue.isEmpty) {
          return _t(
            context,
            'Please select a crop type',
            'يرجى اختيار نوع المحصول',
          );
        }

        return null;
      },
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
          labelText: _t(context, 'Planting date', 'تاريخ الزراعة'),
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
                tooltip: _t(context, 'Clear date', 'مسح التاريخ'),
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
