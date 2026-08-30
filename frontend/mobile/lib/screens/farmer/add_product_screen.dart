import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_constants.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../providers/category_provider.dart';
import '../../providers/dashboard_provider.dart';
import '../../providers/locale_provider.dart';
import '../../providers/product_provider.dart';

class AddProductScreen extends StatefulWidget {
  final Map<String, dynamic>? product;

  const AddProductScreen({
    super.key,
    this.product,
  });

  bool get isEditing => product != null;

  @override
  State<AddProductScreen> createState() =>
      _AddProductScreenState();
}

class _AddProductScreenState
    extends State<AddProductScreen> {
  final nameController =
      TextEditingController();

  final descriptionController =
      TextEditingController();

  final priceController =
      TextEditingController();

  final quantityController =
      TextEditingController();

  final unitController =
      TextEditingController();

  final ImagePicker imagePicker =
      ImagePicker();

  Uint8List? selectedImageBytes;

  String? selectedImageName;

  String? currentImageUrl;

  static const List<String> _standardUnits = <String>[
    'kg',
    'ton',
    'piece',
    'box',
  ];

  bool localizedDataLoaded = false;

  @override
  void initState() {
    super.initState();

    _fillCommonProductData();

    WidgetsBinding.instance.addPostFrameCallback(
      (_) {
        if (!mounted) {
          return;
        }

        _initializeCategories();
      },
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (localizedDataLoaded) {
      return;
    }

    _fillLocalizedProductData();

    localizedDataLoaded = true;
  }

  Future<void> _initializeCategories() async {
    final categoryProvider =
        Provider.of<CategoryProvider>(
      context,
      listen: false,
    );

    await categoryProvider.loadCategories();

    if (!mounted ||
        !widget.isEditing) {
      return;
    }

    final product = widget.product!;

    final categoryId =
        product['categoryId']?.toString() ??
            product['category']?['id']
                ?.toString();

    if (categoryId != null) {
      categoryProvider.selectCategory(
        categoryId,
      );
    }
  }

  void _fillCommonProductData() {
    if (!widget.isEditing) {
      return;
    }

    final product = widget.product!;

    priceController.text =
        product['price']?.toString() ??
            '';

    quantityController.text =
        product['quantity']
                ?.toString() ??
            '';

    unitController.text =
        product['unit']?.toString() ??
            '';

    currentImageUrl =
        product['imageUrl']?.toString();
  }

  void _fillLocalizedProductData() {
    if (!widget.isEditing) {
      return;
    }

    final product = widget.product!;

    final languageCode =
        Localizations.localeOf(
      context,
    ).languageCode;

    if (languageCode == 'ar') {
      nameController.text =
          _firstNonEmpty([
        product['nameAr'],
        product['name'],
        product['nameEn'],
      ]);

      descriptionController.text =
          _firstNonEmpty([
        product['descriptionAr'],
        product['description'],
        product['descriptionEn'],
      ]);

      return;
    }

    nameController.text =
        _firstNonEmpty([
      product['nameEn'],
      product['name'],
      product['nameAr'],
    ]);

    descriptionController.text =
        _firstNonEmpty([
      product['descriptionEn'],
      product['description'],
      product['descriptionAr'],
    ]);
  }

  String _firstNonEmpty(
    List<dynamic> values,
  ) {
    for (final value in values) {
      final text =
          value?.toString().trim() ??
              '';

      if (text.isNotEmpty) {
        return text;
      }
    }

    return '';
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

    if (value.startsWith(
          'http://',
        ) ||
        value.startsWith(
          'https://',
        )) {
      return value;
    }

    if (value.startsWith('/')) {
      return '${AppConstants.baseUrl}$value';
    }

    return '${AppConstants.baseUrl}/$value';
  }

  String _getCategoryName(
    dynamic category,
    BuildContext context,
  ) {
    if (category is! Map) {
      return '';
    }

    final languageCode =
        Localizations.localeOf(
      context,
    ).languageCode;

    final name =
        category['name']
            ?.toString()
            .trim();

    final nameEn =
        category['nameEn']
            ?.toString()
            .trim();

    final nameAr =
        category['nameAr']
            ?.toString()
            .trim();

    if (languageCode == 'ar') {
      if (nameAr != null &&
          nameAr.isNotEmpty) {
        return nameAr;
      }

      if (name != null &&
          name.isNotEmpty) {
        return name;
      }

      if (nameEn != null &&
          nameEn.isNotEmpty) {
        return nameEn;
      }

      return '';
    }

    if (nameEn != null &&
        nameEn.isNotEmpty) {
      return nameEn;
    }

    if (name != null &&
        name.isNotEmpty) {
      return name;
    }

    if (nameAr != null &&
        nameAr.isNotEmpty) {
      return nameAr;
    }

    return '';
  }

  List<String> _availableUnits() {
    final currentUnit = unitController.text.trim();

    if (currentUnit.isEmpty ||
        _standardUnits.contains(currentUnit)) {
      return List<String>.from(_standardUnits);
    }

    return <String>[
      ..._standardUnits,
      currentUnit,
    ];
  }

  String _unitLabel(
    String unit,
    bool isArabic,
  ) {
    switch (unit) {
      case 'kg':
        return isArabic
            ? 'كيلوغرام (kg)'
            : 'Kilogram (kg)';
      case 'ton':
        return isArabic
            ? 'طن (ton)'
            : 'Ton (ton)';
      case 'piece':
        return isArabic
            ? 'حبة (piece)'
            : 'Piece';
      case 'box':
        return isArabic
            ? 'صندوق (box)'
            : 'Box';
      default:
        return unit;
    }
  }

  Future<void> _pickImage() async {
    final l10n =
        AppLocalizations.of(context)!;

    try {
      final XFile? pickedImage =
          await imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
        maxWidth: 1200,
      );

      if (pickedImage == null) {
        return;
      }

      final Uint8List imageBytes =
          await pickedImage.readAsBytes();

      if (!mounted) {
        return;
      }

      setState(
        () {
          selectedImageBytes =
              imageBytes;

          selectedImageName =
              pickedImage.name;
        },
      );
    } catch (e) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text(
            l10n.failedToSelectImage(
              e.toString(),
            ),
          ),
          backgroundColor:
              Colors.red,
        ),
      );
    }
  }

  void _removeSelectedImage() {
    setState(
      () {
        selectedImageBytes = null;
        selectedImageName = null;
      },
    );
  }

  @override
  void dispose() {
    nameController.dispose();

    descriptionController.dispose();

    priceController.dispose();

    quantityController.dispose();

    unitController.dispose();

    super.dispose();
  }

  Future<void>
      _generateMarketingContent() async {
    final l10n =
        AppLocalizations.of(context)!;

    final productProvider =
        Provider.of<ProductProvider>(
      context,
      listen: false,
    );

    final productName =
        nameController.text.trim();

    final productDetails =
        descriptionController.text.trim();

    if (productName.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text(
            l10n
                .pleaseEnterProductNameFirst,
          ),
        ),
      );

      return;
    }

    final languageCode =
        Localizations.localeOf(
      context,
    ).languageCode;

    final language =
        languageCode == 'ar'
            ? 'Arabic'
            : 'English';

    final fallbackDetails =
        languageCode == 'ar'
            ? 'منتج زراعي طازج'
            : 'Fresh farm product';

    try {
      final result =
          await productProvider
              .generateMarketingContent(
        productName: productName,
        productDetails:
            productDetails.isEmpty
                ? fallbackDetails
                : productDetails,
        language: language,
        productId:
            widget.isEditing
                ? widget.product!['id']
                    ?.toString()
                : null,
      );

      if (!mounted) {
        return;
      }

      await _showMarketingResult(
        result,
      );
    } catch (error) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text(
            error
                .toString()
                .replaceFirst(
                  'Exception: ',
                  '',
                ),
          ),
          backgroundColor:
              Colors.red,
        ),
      );
    }
  }

  Future<void> _showMarketingResult(
    Map<String, dynamic> result,
  ) async {
    final l10n =
        AppLocalizations.of(context)!;

    final title =
        result['title']?.toString() ??
            '';

    final description =
        result['description']
                ?.toString() ??
            '';

    final keywords =
        result['keywords'] is List
            ? List<dynamic>.from(
                result['keywords'],
              ).map(
                (item) {
                  return item.toString();
                },
              ).toList()
            : <String>[];

    final suggestions =
        result['suggestions'] is List
            ? List<dynamic>.from(
                result['suggestions'],
              ).map(
                (item) {
                  return item.toString();
                },
              ).toList()
            : <String>[];

    final shouldUse =
        await showDialog<bool>(
      context: context,
      builder: (
        dialogContext,
      ) {
        return AlertDialog(
          title: Row(
            children: [
              const Icon(
                Icons.auto_awesome,
                color: Colors.green,
              ),
              const SizedBox(
                width: 10,
              ),
              Expanded(
                child: Text(
                  l10n.marketingContent,
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
                  Text(
                    l10n.suggestedTitle,
                    style:
                        const TextStyle(
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),
                  const SizedBox(
                    height: 6,
                  ),
                  SelectableText(
                    title,
                  ),
                  const SizedBox(
                    height: 18,
                  ),
                  Text(
                    l10n
                        .suggestedDescription,
                    style:
                        const TextStyle(
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),
                  const SizedBox(
                    height: 6,
                  ),
                  SelectableText(
                    description,
                  ),
                  if (keywords
                      .isNotEmpty) ...[
                    const SizedBox(
                      height: 18,
                    ),
                    Text(
                      l10n.keywords,
                      style:
                          const TextStyle(
                        fontWeight:
                            FontWeight
                                .bold,
                      ),
                    ),
                    const SizedBox(
                      height: 8,
                    ),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children:
                          keywords.map(
                        (
                          keyword,
                        ) {
                          return Chip(
                            label: Text(
                              keyword,
                            ),
                          );
                        },
                      ).toList(),
                    ),
                  ],
                  if (suggestions
                      .isNotEmpty) ...[
                    const SizedBox(
                      height: 18,
                    ),
                    Text(
                      l10n
                          .marketingSuggestions,
                      style:
                          const TextStyle(
                        fontWeight:
                            FontWeight
                                .bold,
                      ),
                    ),
                    const SizedBox(
                      height: 8,
                    ),
                    ...suggestions.map(
                      (
                        suggestion,
                      ) {
                        return Padding(
                          padding:
                              const EdgeInsets
                                  .only(
                            bottom: 8,
                          ),
                          child: Row(
                            crossAxisAlignment:
                                CrossAxisAlignment
                                    .start,
                            children: [
                              const Icon(
                                Icons
                                    .check_circle_outline,
                                size: 18,
                                color:
                                    Colors.green,
                              ),
                              const SizedBox(
                                width: 8,
                              ),
                              Expanded(
                                child: Text(
                                  suggestion,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ],
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(
                  dialogContext,
                  false,
                );
              },
              child: Text(
                l10n.close,
              ),
            ),
            ElevatedButton.icon(
              onPressed:
                  description.isEmpty
                      ? null
                      : () {
                          Navigator.pop(
                            dialogContext,
                            true,
                          );
                        },
              icon: const Icon(
                Icons.check,
              ),
              label: Text(
                l10n.useContent,
              ),
            ),
          ],
        );
      },
    );

    if (shouldUse != true ||
        !mounted) {
      return;
    }

    setState(
      () {
        if (description.isNotEmpty) {
          descriptionController.text =
              description;
        }
      },
    );

    ScaffoldMessenger.of(context)
        .showSnackBar(
      SnackBar(
        content: Text(
          l10n.marketingContentAdded,
        ),
        backgroundColor:
            Colors.green,
      ),
    );
  }

  Future<void> _saveProduct() async {
    final l10n =
        AppLocalizations.of(context)!;

    final productProvider =
        Provider.of<ProductProvider>(
      context,
      listen: false,
    );

    final categoryProvider =
        Provider.of<CategoryProvider>(
      context,
      listen: false,
    );

    final dashboardProvider =
        Provider.of<DashboardProvider>(
      context,
      listen: false,
    );

    final categoryId =
        categoryProvider
            .selectedCategoryId;

    if (categoryId == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text(
            l10n
                .pleaseSelectCategory,
          ),
        ),
      );

      return;
    }

    final name =
        nameController.text.trim();

    final description =
        descriptionController.text
            .trim();

    final price =
        double.tryParse(
      priceController.text.trim(),
    );

    final quantity =
        int.tryParse(
      quantityController.text.trim(),
    );

    final unit =
        unitController.text.trim();

    if (name.isEmpty ||
        price == null ||
        price <= 0 ||
        quantity == null ||
        quantity < 0 ||
        unit.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text(
            l10n
                .pleaseEnterValidProductData,
          ),
        ),
      );

      return;
    }

    final inputIsArabic =
        RegExp(
          r'[\u0600-\u06FF]',
        ).hasMatch(name);

    final nameAr =
        inputIsArabic
            ? name
            : '';

    final descriptionAr =
        inputIsArabic
            ? description
            : '';

    final nameEn =
        inputIsArabic
            ? ''
            : name;

    final descriptionEn =
        inputIsArabic
            ? ''
            : description;

    try {
      String? imageUrl =
          currentImageUrl;

      if (selectedImageBytes != null &&
          selectedImageName != null) {
        imageUrl =
            await productProvider
                .uploadProductImage(
          imageBytes:
              selectedImageBytes!,
          fileName:
              selectedImageName!,
        );
      }

      if (widget.isEditing) {
        final productId =
            widget.product!['id']
                ?.toString();

        if (productId == null ||
            productId.isEmpty) {
          throw Exception(
            l10n.productIdNotFound,
          );
        }

        await productProvider
            .updateProduct(
          productId: productId,
          categoryId: categoryId,

          // Legacy fields
          name: name,
          description: description,

          // Current language only.
          // Backend + Gemini generate
          // the opposite language.
          nameEn: nameEn,
          nameAr: nameAr,
          descriptionEn:
              descriptionEn,
          descriptionAr:
              descriptionAr,

          price: price,
          quantity: quantity,
          unit: unit,
          imageUrl: imageUrl,
        );
      } else {
        await productProvider
            .createProduct(
          categoryId: categoryId,

          // Legacy fields
          name: name,
          description: description,

          // Current language only.
          // Backend + Gemini generate
          // the opposite language.
          nameEn: nameEn,
          nameAr: nameAr,
          descriptionEn:
              descriptionEn,
          descriptionAr:
              descriptionAr,

          price: price,
          quantity: quantity,
          unit: unit,
          imageUrl: imageUrl,
        );
      }

      await dashboardProvider
          .loadFarmerDashboard();

      if (!mounted) {
        return;
      }

      Navigator.pop(
        context,
        true,
      );
    } catch (e) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text(
            e
                .toString()
                .replaceFirst(
                  'Exception: ',
                  '',
                ),
          ),
          backgroundColor:
              Colors.red,
        ),
      );
    }
  }

  void _changeLanguage(String languageCode) {
    Provider.of<LocaleProvider>(
      context,
      listen: false,
    ).setLocale(Locale(languageCode));
  }

  @override
  Widget build(
    BuildContext context,
  ) {
    final productProvider =
        Provider.of<ProductProvider>(
      context,
    );

    final categoryProvider =
        Provider.of<CategoryProvider>(
      context,
    );

    final l10n =
        AppLocalizations.of(context)!;

    final isArabic =
        Localizations.localeOf(context).languageCode == 'ar';

    final oldImageUrl =
        _buildImageUrl(
      currentImageUrl,
    );

    final pageTitle =
        widget.isEditing
            ? l10n.editProduct
            : l10n.addProduct;

    return Scaffold(
      backgroundColor:
          const Color(0xFFF8FAF4),
      body: Stack(
        children: [
          const Positioned.fill(
            child:
                _AddProductBackdrop(),
          ),
          Column(
            children: [
              _AddProductTopBar(
                title: pageTitle,
                backTooltip: isArabic ? 'رجوع' : 'Back',
                onBack: () =>
                    Navigator.pop(
                  context,
                ),
                onLanguage: (languageCode) {
                  _changeLanguage(
                    languageCode,
                  );
                },
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
                          _AddProductHero(
                            title: pageTitle,
                            isEditing:
                                widget
                                    .isEditing,
                          ),
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
                                _addProductCardDecoration(
                              24,
                            ),
                            child: Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment
                                      .start,
                              children: [
                                _ProductSectionTitle(
                                  icon: Icons
                                      .inventory_2_outlined,
                                  title: isArabic
                                      ? 'معلومات المنتج'
                                      : 'Product Information',
                                  subtitle: isArabic
                                      ? 'أضف تفاصيل المنتج الأساسية التي سيشاهدها العملاء في المتجر.'
                                      : 'Add the core product details customers will see in the marketplace.',
                                ),
                                const SizedBox(
                                  height: 24,
                                ),
                                if (categoryProvider
                                    .isLoading)
                                  const Center(
                                    child:
                                        Padding(
                                      padding:
                                          EdgeInsets
                                              .all(
                                        12,
                                      ),
                                      child:
                                          CircularProgressIndicator(
                                        color:
                                            _addProductPrimary,
                                      ),
                                    ),
                                  )
                                else
                                  DropdownButtonFormField<
                                      String>(
                                    initialValue:
                                        categoryProvider
                                            .selectedCategoryId,
                                    decoration:
                                        _fieldDecoration(
                                      label:
                                          l10n.category,
                                      icon: Icons
                                          .category_outlined,
                                    ),
                                    items:
                                        categoryProvider
                                            .categories
                                            .map(
                                      (
                                        category,
                                      ) {
                                        final categoryName =
                                            _getCategoryName(
                                          category,
                                          context,
                                        );

                                        return DropdownMenuItem<
                                            String>(
                                          value: category[
                                                  'id']
                                              .toString(),
                                          child: Text(
                                            categoryName,
                                            overflow:
                                                TextOverflow
                                                    .ellipsis,
                                          ),
                                        );
                                      },
                                    ).toList(),
                                    onChanged:
                                        categoryProvider
                                            .selectCategory,
                                  ),
                                const SizedBox(
                                  height: 16,
                                ),
                                TextField(
                                  controller:
                                      nameController,
                                  decoration:
                                      _fieldDecoration(
                                    label:
                                        l10n.productName,
                                    icon: Icons
                                        .inventory_2_outlined,
                                  ),
                                ),
                                const SizedBox(
                                  height: 12,
                                ),
                                SizedBox(
                                  width:
                                      double.infinity,
                                  height: 50,
                                  child:
                                      OutlinedButton
                                          .icon(
                                    onPressed:
                                        productProvider
                                                .isLoading
                                            ? null
                                            : _generateMarketingContent,
                                    style:
                                        OutlinedButton
                                            .styleFrom(
                                      foregroundColor:
                                          _addProductPrimary,
                                      side:
                                          const BorderSide(
                                        color:
                                            _addProductPrimary,
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
                                          .auto_awesome,
                                    ),
                                    label: Text(
                                      l10n
                                          .generateMarketingContent,
                                      style:
                                          const TextStyle(
                                        fontWeight:
                                            FontWeight
                                                .w700,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(
                                  height: 16,
                                ),
                                TextField(
                                  controller:
                                      descriptionController,
                                  maxLines: 4,
                                  decoration:
                                      _fieldDecoration(
                                    label:
                                        l10n.description,
                                    icon: Icons
                                        .notes_outlined,
                                    alignLabelWithHint:
                                        true,
                                  ),
                                ),
                                const SizedBox(
                                  height: 16,
                                ),
                                LayoutBuilder(
                                  builder: (
                                    context,
                                    constraints,
                                  ) {
                                    final narrow =
                                        constraints
                                                .maxWidth <
                                            720;

                                    final priceField =
                                        TextField(
                                      controller:
                                          priceController,
                                      keyboardType:
                                          const TextInputType
                                              .numberWithOptions(
                                        decimal:
                                            true,
                                      ),
                                      decoration:
                                          _fieldDecoration(
                                        label:
                                            l10n.price,
                                        icon: Icons
                                            .payments_outlined,
                                      ),
                                    );

                                    final quantityField =
                                        TextField(
                                      controller:
                                          quantityController,
                                      keyboardType:
                                          TextInputType
                                              .number,
                                      decoration:
                                          _fieldDecoration(
                                        label: l10n
                                            .quantity,
                                        icon: Icons
                                            .inventory_outlined,
                                      ),
                                    );

                                    final availableUnits =
                                        _availableUnits();

                                    final currentUnit =
                                        unitController.text
                                            .trim();

                                    final unitField =
                                        DropdownButtonFormField<
                                            String>(
                                      initialValue:
                                          currentUnit.isEmpty
                                              ? null
                                              : currentUnit,
                                      isExpanded: true,
                                      decoration:
                                          _fieldDecoration(
                                        label:
                                            l10n.unit,
                                        hint: isArabic
                                            ? 'اختر الوحدة'
                                            : 'Select unit',
                                        icon: Icons
                                            .scale_outlined,
                                      ),
                                      items:
                                          availableUnits
                                              .map(
                                        (
                                          unit,
                                        ) {
                                          return DropdownMenuItem<
                                              String>(
                                            value: unit,
                                            child: Text(
                                              _unitLabel(
                                                unit,
                                                isArabic,
                                              ),
                                              overflow:
                                                  TextOverflow
                                                      .ellipsis,
                                            ),
                                          );
                                        },
                                      ).toList(),
                                      onChanged:
                                          productProvider
                                                  .isLoading
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
                                                      unitController
                                                              .text =
                                                          value;
                                                    },
                                                  );
                                                },
                                    );

                                    if (narrow) {
                                      return Column(
                                        children: [
                                          priceField,
                                          const SizedBox(
                                            height:
                                                16,
                                          ),
                                          quantityField,
                                          const SizedBox(
                                            height:
                                                16,
                                          ),
                                          unitField,
                                        ],
                                      );
                                    }

                                    return Row(
                                      children: [
                                        Expanded(
                                          child:
                                              priceField,
                                        ),
                                        const SizedBox(
                                          width:
                                              16,
                                        ),
                                        Expanded(
                                          child:
                                              quantityField,
                                        ),
                                        const SizedBox(
                                          width:
                                              16,
                                        ),
                                        Expanded(
                                          child:
                                              unitField,
                                        ),
                                      ],
                                    );
                                  },
                                ),
                                const SizedBox(
                                  height: 24,
                                ),
                                _ProductSectionTitle(
                                  icon: Icons
                                      .image_outlined,
                                  title: isArabic
                                      ? 'صورة المنتج'
                                      : 'Product Image',
                                  subtitle: isArabic
                                      ? 'اختر صورة واضحة للمنتج لعرضها في المتجر.'
                                      : 'Choose a clear product photo for the marketplace listing.',
                                ),
                                const SizedBox(
                                  height: 18,
                                ),
                                if (selectedImageBytes !=
                                    null)
                                  _ImagePreviewCard(
                                    onRemove:
                                        _removeSelectedImage,
                                    child:
                                        Image.memory(
                                      selectedImageBytes!,
                                      fit:
                                          BoxFit.cover,
                                      width:
                                          double.infinity,
                                      height:
                                          double.infinity,
                                    ),
                                  )
                                else if (oldImageUrl !=
                                    null)
                                  _ImagePreviewCard(
                                    child:
                                        Image.network(
                                      oldImageUrl,
                                      fit:
                                          BoxFit.cover,
                                      width:
                                          double.infinity,
                                      height:
                                          double.infinity,
                                      errorBuilder: (
                                        context,
                                        error,
                                        stackTrace,
                                      ) {
                                        return const Center(
                                          child:
                                              Icon(
                                            Icons
                                                .broken_image_outlined,
                                            size:
                                                60,
                                            color:
                                                _addProductMuted,
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                if (selectedImageBytes !=
                                        null ||
                                    oldImageUrl !=
                                        null)
                                  const SizedBox(
                                    height: 14,
                                  ),
                                SizedBox(
                                  width:
                                      double.infinity,
                                  height: 50,
                                  child:
                                      OutlinedButton
                                          .icon(
                                    onPressed:
                                        productProvider
                                                .isLoading
                                            ? null
                                            : _pickImage,
                                    style:
                                        OutlinedButton
                                            .styleFrom(
                                      foregroundColor:
                                          _addProductPrimary,
                                      side:
                                          const BorderSide(
                                        color:
                                            Color(
                                          0xFFC7D8C1,
                                        ),
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
                                          .add_photo_alternate_outlined,
                                    ),
                                    label: Text(
                                      selectedImageBytes ==
                                              null
                                          ? l10n
                                              .chooseProductImage
                                          : l10n
                                              .changeProductImage,
                                      style:
                                          const TextStyle(
                                        fontWeight:
                                            FontWeight
                                                .w700,
                                      ),
                                    ),
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
                                      ElevatedButton
                                          .icon(
                                    onPressed:
                                        productProvider
                                                .isLoading
                                            ? null
                                            : _saveProduct,
                                    style:
                                        ElevatedButton
                                            .styleFrom(
                                      backgroundColor:
                                          _addProductPrimary,
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
                                        productProvider
                                                .isLoading
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
                                            : Icon(
                                                widget
                                                        .isEditing
                                                    ? Icons
                                                        .save_outlined
                                                    : Icons
                                                        .add_rounded,
                                              ),
                                    label:
                                        productProvider
                                                .isLoading
                                            ? Text(
                                                isArabic
                                                    ? 'جارٍ الحفظ...'
                                                    : 'Saving...',
                                                style:
                                                    const TextStyle(
                                                  fontWeight:
                                                      FontWeight.w700,
                                                ),
                                              )
                                            : Text(
                                                widget
                                                        .isEditing
                                                    ? l10n
                                                        .saveChanges
                                                    : l10n
                                                        .addProduct,
                                                style:
                                                    const TextStyle(
                                                  fontWeight:
                                                      FontWeight.w700,
                                                  fontSize:
                                                      15,
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
            ],
          ),
        ],
      ),
    );
  }
}

const _addProductDark =
    Color(0xFF173F24);
const _addProductPrimary =
    Color(0xFF2F743F);
const _addProductLight =
    Color(0xFFEAF3DF);
const _addProductText =
    Color(0xFF1D2C21);
const _addProductMuted =
    Color(0xFF6C786E);

class _AddProductTopBar
    extends StatelessWidget {
  final String title;
  final String backTooltip;
  final VoidCallback onBack;
  final ValueChanged<String> onLanguage;

  const _AddProductTopBar({
    required this.title,
    required this.backTooltip,
    required this.onBack,
    required this.onLanguage,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    final l10n =
        AppLocalizations.of(context)!;

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
            _AddProductHeaderButton(
              icon: Icons
                  .arrow_back_rounded,
              tooltip: backTooltip,
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
                    _addProductDark,
              ),
            ),
            const SizedBox(
              width: 10,
            ),
            Expanded(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment
                        .start,
                children: [
                  const Text(
                    'FarmPilot',
                    style: TextStyle(
                      color:
                          Colors.white,
                      fontSize: 19,
                      fontWeight:
                          FontWeight
                              .w800,
                    ),
                  ),
                  Text(
                    title,
                    style:
                        const TextStyle(
                      color: Color(
                        0xCCFFFFFF,
                      ),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(
              width: 10,
            ),
            Directionality(
              textDirection: TextDirection.ltr,
              child: PopupMenuButton<String>(
                tooltip: l10n.changeLanguage,
                position: PopupMenuPosition.under,
                offset: const Offset(0, 8),
                color: const Color(0xFFF8FAF4),
                elevation: 8,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                onSelected: onLanguage,
                itemBuilder: (context) {
                  final isArabic =
                      Localizations.localeOf(context).languageCode == 'ar';

                  return [
                    PopupMenuItem<String>(
                      value: 'en',
                      child: Directionality(
                        textDirection: TextDirection.ltr,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.check_rounded,
                              size: 20,
                              color: !isArabic
                                  ? _addProductPrimary
                                  : Colors.transparent,
                            ),
                            const SizedBox(width: 10),
                            Text(l10n.english),
                          ],
                        ),
                      ),
                    ),
                    PopupMenuItem<String>(
                      value: 'ar',
                      child: Directionality(
                        textDirection: TextDirection.rtl,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.check_rounded,
                              size: 20,
                              color: isArabic
                                  ? _addProductPrimary
                                  : Colors.transparent,
                            ),
                            const SizedBox(width: 10),
                            Text(l10n.arabic),
                          ],
                        ),
                      ),
                    ),
                  ];
                },
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(
                      alpha: 0.10,
                    ),
                    borderRadius: BorderRadius.circular(
                      14,
                    ),
                  ),
                  alignment: Alignment.center,
                  child: const Icon(
                    Icons.language_rounded,
                    color: Colors.white,
                    size: 21,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AddProductHeaderButton
    extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;

  const _AddProductHeaderButton({
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

class _AddProductHero
    extends StatelessWidget {
  final String title;
  final bool isEditing;

  const _AddProductHero({
    required this.title,
    required this.isEditing,
  });

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
          _addProductCardDecoration(
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
                  _addProductLight,
              borderRadius:
                  BorderRadius
                      .circular(
                18,
              ),
            ),
            child: const Icon(
              Icons
                  .inventory_2_outlined,
              size: 31,
              color:
                  _addProductPrimary,
            ),
          ),
          const SizedBox(
            width: 16,
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
                        _addProductText,
                    fontSize: 24,
                    fontWeight:
                        FontWeight
                            .w800,
                  ),
                ),
                const SizedBox(
                  height: 4,
                ),
                Text(
                  Localizations.localeOf(context).languageCode == 'ar'
                      ? (isEditing
                          ? 'حدّث تفاصيل المنتج والصورة ومعلومات العرض في المتجر.'
                          : 'أنشئ منتجًا جديدًا في المتجر واستخدم الذكاء الاصطناعي للمساعدة في إعداد المحتوى التسويقي.')
                      : (isEditing
                          ? 'Update product details, image and marketplace information.'
                          : 'Create a marketplace listing and use AI to help prepare the marketing content.'),
                  style:
                      const TextStyle(
                    color:
                        _addProductMuted,
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

class _ProductSectionTitle
    extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _ProductSectionTitle({
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
                _addProductLight,
            borderRadius:
                BorderRadius.circular(
              13,
            ),
          ),
          child: Icon(
            icon,
            color:
                _addProductPrimary,
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
                      _addProductText,
                  fontSize: 18,
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
                      _addProductMuted,
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

class _ImagePreviewCard
    extends StatelessWidget {
  final Widget child;
  final VoidCallback? onRemove;

  const _ImagePreviewCard({
    required this.child,
    this.onRemove,
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
      child: Stack(
        fit: StackFit.expand,
        children: [
          child,
          if (onRemove != null)
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
                      Localizations.localeOf(context).languageCode == 'ar'
                          ? 'إزالة الصورة'
                          : 'Remove image',
                  onPressed:
                      onRemove,
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

InputDecoration _fieldDecoration({
  required String label,
  required IconData icon,
  String? hint,
  bool alignLabelWithHint = false,
}) {
  return InputDecoration(
    labelText: label,
    hintText: hint,
    alignLabelWithHint:
        alignLabelWithHint,
    labelStyle:
        const TextStyle(
      color:
          _addProductMuted,
    ),
    hintStyle:
        const TextStyle(
      color:
          Color(0xFF9AA59B),
    ),
    prefixIcon: Icon(
      icon,
      color:
          _addProductPrimary,
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
            _addProductPrimary,
        width: 1.5,
      ),
    ),
  );
}

class _AddProductBackdrop
    extends StatelessWidget {
  const _AddProductBackdrop();

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
                begin: Alignment
                    .topCenter,
                end: Alignment
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
            top: 180,
            child:
                _AddProductGlow(
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
                _AddProductGlow(
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

class _AddProductGlow
    extends StatelessWidget {
  final double size;
  final Color color;

  const _AddProductGlow({
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
    _addProductCardDecoration(
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
            _addProductDark
                .withValues(
          alpha: 0.05,
        ),
        blurRadius: 20,
        offset:
            const Offset(
          0,
          7,
        ),
      ),
    ],
  );
}
