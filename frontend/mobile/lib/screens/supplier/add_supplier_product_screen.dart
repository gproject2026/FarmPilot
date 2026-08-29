import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_constants.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../providers/supplier_category_provider.dart';
import '../../providers/supplier_product_provider.dart';

class AddSupplierProductScreen
    extends StatefulWidget {
  final Map<String, dynamic>? product;

  const AddSupplierProductScreen({
    super.key,
    this.product,
  });

  bool get isEditing => product != null;

  @override
  State<AddSupplierProductScreen>
      createState() =>
          _AddSupplierProductScreenState();
}

class _AddSupplierProductScreenState
    extends State<
        AddSupplierProductScreen> {
  static const Color _primary =
      Color(0xFF2F6B3D);

  static const Color _darkGreen =
      Color(0xFF173F24);

  static const Color _lightGreen =
      Color(0xFFEAF3E7);

  static const Color _background =
      Color(0xFFF7F9F4);

  static const Color _text =
      Color(0xFF1D2A20);

  static const Color _muted =
      Color(0xFF6D786F);

  final TextEditingController
      nameController =
      TextEditingController();

  final TextEditingController
      descriptionController =
      TextEditingController();

  final TextEditingController
      plantingInstructionsController =
      TextEditingController();

  final TextEditingController
      irrigationInstructionsController =
      TextEditingController();

  final TextEditingController
      usageInstructionsController =
      TextEditingController();

  final TextEditingController
      priceController =
      TextEditingController();

  final TextEditingController
      quantityController =
      TextEditingController();

  final TextEditingController
      unitController =
      TextEditingController();

  final ImagePicker imagePicker =
      ImagePicker();

  Uint8List? selectedImageBytes;

  String? selectedImageName;

  String? currentImageUrl;

  bool localizedDataLoaded = false;

  bool isSaving = false;

  @override
  void initState() {
    super.initState();

    _fillCommonProductData();

    WidgetsBinding.instance
        .addPostFrameCallback(
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

  @override
  void dispose() {
    nameController.dispose();
    descriptionController.dispose();

    plantingInstructionsController
        .dispose();

    irrigationInstructionsController
        .dispose();

    usageInstructionsController
        .dispose();

    priceController.dispose();
    quantityController.dispose();
    unitController.dispose();

    super.dispose();
  }

  Future<void>
      _initializeCategories() async {
    final categoryProvider =
        Provider.of<
            SupplierCategoryProvider>(
      context,
      listen: false,
    );

    await categoryProvider
        .loadSupplierCategories();

    if (!mounted ||
        !widget.isEditing) {
      return;
    }

    final product =
        widget.product!;

    final categoryId =
        product['categoryId']
                ?.toString() ??
            product['category']?['id']
                ?.toString();

    if (categoryId != null &&
        categoryId.trim().isNotEmpty) {
      categoryProvider.selectCategory(
        categoryId,
      );
    }
  }

  void _fillCommonProductData() {
    if (!widget.isEditing) {
      return;
    }

    final product =
        widget.product!;

    priceController.text =
        product['price']
                ?.toString() ??
            '';

    quantityController.text =
        product['quantity']
                ?.toString() ??
            '';

    unitController.text =
        product['unit']
                ?.toString() ??
            '';

    currentImageUrl =
        product['imageUrl']
            ?.toString();
  }

  void _fillLocalizedProductData() {
    if (!widget.isEditing) {
      return;
    }

    final product =
        widget.product!;

    final languageCode =
        Localizations.localeOf(
      context,
    ).languageCode;

    if (languageCode == 'ar') {
      nameController.text =
          _firstNonEmpty(
        [
          product['nameAr'],
          product['name'],
          product['nameEn'],
        ],
      );

      descriptionController.text =
          _firstNonEmpty(
        [
          product['descriptionAr'],
          product['description'],
          product['descriptionEn'],
        ],
      );

      plantingInstructionsController
          .text =
          _firstNonEmpty(
        [
          product[
              'plantingInstructionsAr'],
          product[
              'plantingInstructions'],
          product[
              'plantingInstructionsEn'],
        ],
      );

      irrigationInstructionsController
          .text =
          _firstNonEmpty(
        [
          product[
              'irrigationInstructionsAr'],
          product[
              'irrigationInstructions'],
          product[
              'irrigationInstructionsEn'],
        ],
      );

      usageInstructionsController.text =
          _firstNonEmpty(
        [
          product[
              'usageInstructionsAr'],
          product[
              'usageInstructions'],
          product[
              'usageInstructionsEn'],
        ],
      );

      return;
    }

    nameController.text =
        _firstNonEmpty(
      [
        product['nameEn'],
        product['name'],
        product['nameAr'],
      ],
    );

    descriptionController.text =
        _firstNonEmpty(
      [
        product['descriptionEn'],
        product['description'],
        product['descriptionAr'],
      ],
    );

    plantingInstructionsController
        .text =
        _firstNonEmpty(
      [
        product[
            'plantingInstructionsEn'],
        product[
            'plantingInstructions'],
        product[
            'plantingInstructionsAr'],
      ],
    );

    irrigationInstructionsController
        .text =
        _firstNonEmpty(
      [
        product[
            'irrigationInstructionsEn'],
        product[
            'irrigationInstructions'],
        product[
            'irrigationInstructionsAr'],
      ],
    );

    usageInstructionsController.text =
        _firstNonEmpty(
      [
        product[
            'usageInstructionsEn'],
        product[
            'usageInstructions'],
        product[
            'usageInstructionsAr'],
      ],
    );
  }

  String? _getImageUrl(
    dynamic imageUrl,
  ) {
    if (imageUrl == null) {
      return null;
    }

    final url =
        AppConstants.getImageUrl(
      imageUrl.toString(),
    );

    if (url.isEmpty) {
      return null;
    }

    return url;
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

  String _existingValue(
    String key,
  ) {
    if (!widget.isEditing) {
      return '';
    }

    return widget.product![key]
            ?.toString()
            .trim() ??
        '';
  }

  String _localizedCategoryName(
    dynamic category,
  ) {
    final languageCode =
        Localizations.localeOf(
      context,
    ).languageCode;

    if (languageCode == 'ar') {
      return _firstNonEmpty(
        [
          category['nameAr'],
          category['name'],
          category['nameEn'],
        ],
      );
    }

    return _firstNonEmpty(
      [
        category['nameEn'],
        category['name'],
        category['nameAr'],
      ],
    );
  }

  Future<void>
      _selectImage() async {
    final l10n =
        AppLocalizations.of(
      context,
    )!;

    try {
      final XFile? image =
          await imagePicker.pickImage(
        source:
            ImageSource.gallery,
        imageQuality: 88,
      );

      if (image == null) {
        return;
      }

      final bytes =
          await image.readAsBytes();

      if (!mounted) {
        return;
      }

      setState(
        () {
          selectedImageBytes =
              bytes;

          selectedImageName =
              image.name;
        },
      );
    } catch (error) {
      if (!mounted) {
        return;
      }

      _showMessage(
        l10n.failedToSelectImage(
          error.toString(),
        ),
        isError: true,
      );
    }
  }

  void _removeImage() {
    setState(
      () {
        selectedImageBytes = null;
        selectedImageName = null;
        currentImageUrl = null;
      },
    );
  }

  Future<void>
      _saveProduct() async {
    if (isSaving) {
      return;
    }

    final l10n =
        AppLocalizations.of(
      context,
    )!;

    final languageCode =
        Localizations.localeOf(
      context,
    ).languageCode;

    final categoryProvider =
        Provider.of<
            SupplierCategoryProvider>(
      context,
      listen: false,
    );

    final productProvider =
        Provider.of<
            SupplierProductProvider>(
      context,
      listen: false,
    );

    final categoryId =
        categoryProvider
            .selectedCategoryId;

    if (categoryId == null ||
        categoryId.trim().isEmpty) {
      _showMessage(
        l10n.pleaseSelectCategory,
        isError: true,
      );

      return;
    }

    final name =
        nameController.text.trim();

    final description =
        descriptionController.text
            .trim();

    final plantingInstructions =
        plantingInstructionsController
            .text
            .trim();

    final irrigationInstructions =
        irrigationInstructionsController
            .text
            .trim();

    final usageInstructions =
        usageInstructionsController
            .text
            .trim();

    final price =
        double.tryParse(
      priceController.text
          .trim()
          .replaceAll(
            ',',
            '.',
          ),
    );

    final quantity =
        int.tryParse(
      quantityController.text
          .trim(),
    );

    final unit =
        unitController.text.trim();

    if (name.isEmpty ||
        price == null ||
        price < 0 ||
        quantity == null ||
        quantity < 0 ||
        unit.isEmpty) {
      _showMessage(
        l10n
            .pleaseEnterValidSupplierProductData,
        isError: true,
      );

      return;
    }

    if (widget.isEditing &&
        (widget.product!['id'] ==
                null ||
            widget.product!['id']
                .toString()
                .trim()
                .isEmpty)) {
      _showMessage(
        l10n.supplierProductIdNotFound,
        isError: true,
      );

      return;
    }

    setState(
      () {
        isSaving = true;
      },
    );

    try {
      String? imageUrl =
          currentImageUrl;

      if (selectedImageBytes != null) {
        try {
          imageUrl =
              await productProvider
                  .uploadSupplierProductImage(
            imageBytes:
                selectedImageBytes!,
            fileName:
                selectedImageName ??
                    'supplier-product.jpg',
          );
        } catch (error) {
          if (!mounted) {
            return;
          }

          _showMessage(
            '${l10n.supplierProductImageUploadFailed}: '
            '${_cleanError(error)}',
            isError: true,
          );

          return;
        }
      }

      String nameEn =
          _existingValue(
        'nameEn',
      );

      String nameAr =
          _existingValue(
        'nameAr',
      );

      String descriptionEn =
          _existingValue(
        'descriptionEn',
      );

      String descriptionAr =
          _existingValue(
        'descriptionAr',
      );

      String plantingInstructionsEn =
          _existingValue(
        'plantingInstructionsEn',
      );

      String plantingInstructionsAr =
          _existingValue(
        'plantingInstructionsAr',
      );

      String irrigationInstructionsEn =
          _existingValue(
        'irrigationInstructionsEn',
      );

      String irrigationInstructionsAr =
          _existingValue(
        'irrigationInstructionsAr',
      );

      String usageInstructionsEn =
          _existingValue(
        'usageInstructionsEn',
      );

      String usageInstructionsAr =
          _existingValue(
        'usageInstructionsAr',
      );

      if (languageCode == 'ar') {
        nameAr = name;

        descriptionAr =
            description;

        plantingInstructionsAr =
            plantingInstructions;

        irrigationInstructionsAr =
            irrigationInstructions;

        usageInstructionsAr =
            usageInstructions;
      } else {
        nameEn = name;

        descriptionEn =
            description;

        plantingInstructionsEn =
            plantingInstructions;

        irrigationInstructionsEn =
            irrigationInstructions;

        usageInstructionsEn =
            usageInstructions;
      }

      if (widget.isEditing) {
        final productId =
            widget.product!['id']
                .toString();

        final status =
            widget.product!['status']
                ?.toString();

        await productProvider
            .updateSupplierProduct(
          productId: productId,
          categoryId: categoryId,
          name: name,
          description:
              description,
          nameEn: nameEn,
          nameAr: nameAr,
          descriptionEn:
              descriptionEn,
          descriptionAr:
              descriptionAr,
          plantingInstructions:
              plantingInstructions,
          plantingInstructionsEn:
              plantingInstructionsEn,
          plantingInstructionsAr:
              plantingInstructionsAr,
          irrigationInstructions:
              irrigationInstructions,
          irrigationInstructionsEn:
              irrigationInstructionsEn,
          irrigationInstructionsAr:
              irrigationInstructionsAr,
          usageInstructions:
              usageInstructions,
          usageInstructionsEn:
              usageInstructionsEn,
          usageInstructionsAr:
              usageInstructionsAr,
          price: price,
          quantity: quantity,
          unit: unit,
          imageUrl: imageUrl,
          status: status,
        );

        if (!mounted) {
          return;
        }

        _showMessage(
          l10n
              .supplierProductUpdatedSuccessfully,
        );

        Navigator.of(context).pop(
          true,
        );

        return;
      }

      await productProvider
          .createSupplierProduct(
        categoryId: categoryId,
        name: name,
        description: description,
        nameEn: nameEn,
        nameAr: nameAr,
        descriptionEn:
            descriptionEn,
        descriptionAr:
            descriptionAr,
        plantingInstructions:
            plantingInstructions,
        plantingInstructionsEn:
            plantingInstructionsEn,
        plantingInstructionsAr:
            plantingInstructionsAr,
        irrigationInstructions:
            irrigationInstructions,
        irrigationInstructionsEn:
            irrigationInstructionsEn,
        irrigationInstructionsAr:
            irrigationInstructionsAr,
        usageInstructions:
            usageInstructions,
        usageInstructionsEn:
            usageInstructionsEn,
        usageInstructionsAr:
            usageInstructionsAr,
        price: price,
        quantity: quantity,
        unit: unit,
        imageUrl: imageUrl,
      );

      if (!mounted) {
        return;
      }

      _showMessage(
        l10n
            .supplierProductAddedSuccessfully,
      );

      Navigator.of(context).pop(
        true,
      );
    } catch (error) {
      if (!mounted) {
        return;
      }

      final providerError =
          productProvider
              .errorMessage;

      final message =
          providerError != null &&
                  providerError
                      .trim()
                      .isNotEmpty
              ? providerError
              : _cleanError(
                  error,
                );

      _showMessage(
        '${l10n.failedToSaveSupplierProduct}: '
        '$message',
        isError: true,
      );
    } finally {
      if (mounted) {
        setState(
          () {
            isSaving = false;
          },
        );
      }
    }
  }

  String _cleanError(
    Object error,
  ) {
    return error
        .toString()
        .replaceFirst(
          'Exception: ',
          '',
        );
  }

  void _showMessage(
    String message, {
    bool isError = false,
  }) {
    final messenger =
        ScaffoldMessenger.of(
      context,
    );

    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content:
              Text(message),
          behavior:
              SnackBarBehavior.floating,
          backgroundColor:
              isError
                  ? Colors.red.shade700
                  : _darkGreen,
        ),
      );
  }

  InputDecoration _inputDecoration({
    required String label,
    String? hint,
    IconData? icon,
  }) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      prefixIcon:
          icon == null
              ? null
              : Icon(
                  icon,
                  color: _primary,
                ),
      filled: true,
      fillColor: Colors.white,
      labelStyle:
          const TextStyle(
        color: _muted,
        fontWeight:
            FontWeight.w600,
      ),
      hintStyle:
          TextStyle(
        color: Colors.grey.shade500,
        fontSize: 13,
      ),
      contentPadding:
          const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 17,
      ),
      border:
          OutlineInputBorder(
        borderRadius:
            BorderRadius.circular(
          14,
        ),
        borderSide:
            const BorderSide(
          color:
              Color(0xFFDDE5D9),
        ),
      ),
      enabledBorder:
          OutlineInputBorder(
        borderRadius:
            BorderRadius.circular(
          14,
        ),
        borderSide:
            const BorderSide(
          color:
              Color(0xFFDDE5D9),
        ),
      ),
      focusedBorder:
          OutlineInputBorder(
        borderRadius:
            BorderRadius.circular(
          14,
        ),
        borderSide:
            const BorderSide(
          color: _primary,
          width: 1.5,
        ),
      ),
    );
  }

  BoxDecoration
      _cardDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius:
          BorderRadius.circular(
        22,
      ),
      border: Border.all(
        color:
            const Color(
          0xFFE1E8DE,
        ),
      ),
      boxShadow: const [
        BoxShadow(
          color:
              Color(
            0x0A000000,
          ),
          blurRadius: 18,
          offset:
              Offset(
            0,
            7,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(
    BuildContext context,
  ) {
    final l10n =
        AppLocalizations.of(
      context,
    )!;

    return Scaffold(
      backgroundColor:
          _background,
      appBar: AppBar(
        backgroundColor:
            Colors.white,
        elevation: 0,
        surfaceTintColor:
            Colors.white,
        foregroundColor:
            _darkGreen,
        title: Text(
          widget.isEditing
              ? l10n
                  .editSupplierProduct
              : l10n
                  .addSupplierProduct,
          style:
              const TextStyle(
            fontWeight:
                FontWeight.w800,
          ),
        ),
      ),
      body:
          SafeArea(
        child:
            SingleChildScrollView(
          padding:
              const EdgeInsets.fromLTRB(
            18,
            18,
            18,
            32,
          ),
          child: Center(
            child:
                ConstrainedBox(
              constraints:
                  const BoxConstraints(
                maxWidth: 1050,
              ),
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment
                        .stretch,
                children: [
                  _buildHero(
                    l10n,
                  ),
                  const SizedBox(
                    height: 18,
                  ),
                  _buildInformationSection(
                    l10n,
                  ),
                  const SizedBox(
                    height: 18,
                  ),
                  _buildInstructionsSection(
                    l10n,
                  ),
                  const SizedBox(
                    height: 18,
                  ),
                  _buildImageSection(
                    l10n,
                  ),
                  const SizedBox(
                    height: 22,
                  ),
                  _buildSaveButton(
                    l10n,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHero(
    AppLocalizations l10n,
  ) {
    return Container(
      padding:
          const EdgeInsets.all(
        24,
      ),
      decoration:
          _cardDecoration(),
      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.center,
        children: [
          Container(
            width: 66,
            height: 66,
            decoration:
                BoxDecoration(
              color: _lightGreen,
              borderRadius:
                  BorderRadius
                      .circular(
                18,
              ),
            ),
            child: Icon(
              widget.isEditing
                  ? Icons
                      .edit_note_rounded
                  : Icons
                      .inventory_2_outlined,
              size: 32,
              color: _primary,
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
                  widget.isEditing
                      ? l10n
                          .editSupplierProduct
                      : l10n
                          .addSupplierProduct,
                  style:
                      const TextStyle(
                    color: _text,
                    fontSize: 24,
                    fontWeight:
                        FontWeight
                            .w800,
                  ),
                ),
                const SizedBox(
                  height: 5,
                ),
                Text(
                  widget.isEditing
                      ? l10n
                          .editSupplierProductSubtitle
                      : l10n
                          .addSupplierProductSubtitle,
                  style:
                      const TextStyle(
                    color: _muted,
                    fontSize: 13,
                    height: 1.45,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget
      _buildInformationSection(
    AppLocalizations l10n,
  ) {
    return Container(
      padding:
          const EdgeInsets.all(
        22,
      ),
      decoration:
          _cardDecoration(),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment
                .stretch,
        children: [
          _SectionTitle(
            icon: Icons
                .description_outlined,
            title: l10n
                .supplierProductInformation,
            subtitle: l10n
                .supplierProductInformationSubtitle,
          ),
          const SizedBox(
            height: 22,
          ),
          Consumer<
              SupplierCategoryProvider>(
            builder: (
              context,
              categoryProvider,
              child,
            ) {
              if (categoryProvider
                      .isLoading &&
                  categoryProvider
                      .supplierCategories
                      .isEmpty) {
                return Container(
                  height: 58,
                  alignment:
                      Alignment.center,
                  decoration:
                      BoxDecoration(
                    color:
                        Colors.white,
                    borderRadius:
                        BorderRadius
                            .circular(
                      14,
                    ),
                    border:
                        Border.all(
                      color:
                          const Color(
                        0xFFDDE5D9,
                      ),
                    ),
                  ),
                  child:
                      const SizedBox(
                    width: 22,
                    height: 22,
                    child:
                        CircularProgressIndicator(
                      strokeWidth: 2.4,
                      color: _primary,
                    ),
                  ),
                );
              }

              if (categoryProvider
                  .supplierCategories
                  .isEmpty) {
                return Container(
                  padding:
                      const EdgeInsets
                          .all(
                    16,
                  ),
                  decoration:
                      BoxDecoration(
                    color:
                        const Color(
                      0xFFFFF8E8,
                    ),
                    borderRadius:
                        BorderRadius
                            .circular(
                      14,
                    ),
                    border:
                        Border.all(
                      color:
                          const Color(
                        0xFFF0D9A4,
                      ),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons
                            .info_outline_rounded,
                        color:
                            Color(
                          0xFF9A6A16,
                        ),
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                      Expanded(
                        child: Text(
                          categoryProvider
                                      .errorMessage !=
                                  null
                              ? categoryProvider
                                  .errorMessage!
                              : l10n
                                  .noSupplierCategoriesFound,
                          style:
                              const TextStyle(
                            color:
                                Color(
                              0xFF76551D,
                            ),
                            fontWeight:
                                FontWeight
                                    .w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }

              final ids =
                  categoryProvider
                      .supplierCategories
                      .map(
                        (
                          category,
                        ) =>
                            category[
                                    'id']
                                ?.toString(),
                      )
                      .whereType<
                          String>()
                      .toSet();

              final currentValue =
                  ids.contains(
                categoryProvider
                    .selectedCategoryId,
              )
                      ? categoryProvider
                          .selectedCategoryId
                      : null;

              return DropdownButtonFormField<
                  String>(
                key: ValueKey(
                  currentValue,
                ),
                initialValue:
                    currentValue,
                isExpanded: true,
                decoration:
                    _inputDecoration(
                  label: l10n
                      .selectSupplierCategory,
                  icon: Icons
                      .category_outlined,
                ),
                items:
                    categoryProvider
                        .supplierCategories
                        .map<
                            DropdownMenuItem<
                                String>>(
                  (
                    category,
                  ) {
                    final id =
                        category['id']
                            ?.toString();

                    return DropdownMenuItem<
                        String>(
                      value: id,
                      child: Text(
                        _localizedCategoryName(
                          category,
                        ),
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
              );
            },
          ),
          const SizedBox(
            height: 16,
          ),
          TextField(
            controller:
                nameController,
            textInputAction:
                TextInputAction.next,
            decoration:
                _inputDecoration(
              label:
                  l10n.productName,
              icon: Icons
                  .inventory_2_outlined,
            ),
          ),
          const SizedBox(
            height: 16,
          ),
          TextField(
            controller:
                descriptionController,
            minLines: 3,
            maxLines: 6,
            decoration:
                _inputDecoration(
              label:
                  l10n.description,
              icon: Icons
                  .notes_rounded,
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
              final wide =
                  constraints.maxWidth >=
                      720;

              final priceField =
                  TextField(
                controller:
                    priceController,
                keyboardType:
                    const TextInputType
                        .numberWithOptions(
                  decimal: true,
                ),
                textInputAction:
                    TextInputAction.next,
                decoration:
                    _inputDecoration(
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
                textInputAction:
                    TextInputAction.next,
                decoration:
                    _inputDecoration(
                  label:
                      l10n.quantity,
                  icon: Icons
                      .production_quantity_limits_outlined,
                ),
              );

              final unitField =
                  TextField(
                controller:
                    unitController,
                textInputAction:
                    TextInputAction.done,
                decoration:
                    _inputDecoration(
                  label:
                      l10n.unit,
                  icon: Icons
                      .straighten_outlined,
                ),
              );

              if (!wide) {
                return Column(
                  children: [
                    priceField,
                    const SizedBox(
                      height: 16,
                    ),
                    quantityField,
                    const SizedBox(
                      height: 16,
                    ),
                    unitField,
                  ],
                );
              }

              return Row(
                crossAxisAlignment:
                    CrossAxisAlignment
                        .start,
                children: [
                  Expanded(
                    child:
                        priceField,
                  ),
                  const SizedBox(
                    width: 14,
                  ),
                  Expanded(
                    child:
                        quantityField,
                  ),
                  const SizedBox(
                    width: 14,
                  ),
                  Expanded(
                    child:
                        unitField,
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget
      _buildInstructionsSection(
    AppLocalizations l10n,
  ) {
    return Container(
      padding:
          const EdgeInsets.all(
        22,
      ),
      decoration:
          _cardDecoration(),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment
                .stretch,
        children: [
          _SectionTitle(
            icon: Icons
                .menu_book_outlined,
            title:
                l10n.productInstructions,
            subtitle: l10n
                .productInstructionsSubtitle,
          ),
          const SizedBox(
            height: 22,
          ),
          _InstructionField(
            controller:
                plantingInstructionsController,
            label: l10n
                .plantingInstructions,
            hint: l10n
                .plantingInstructionsHint,
            icon: Icons
                .grass_outlined,
            decorationBuilder:
                _inputDecoration,
          ),
          const SizedBox(
            height: 16,
          ),
          _InstructionField(
            controller:
                irrigationInstructionsController,
            label: l10n
                .irrigationInstructions,
            hint: l10n
                .irrigationInstructionsHint,
            icon: Icons
                .water_drop_outlined,
            decorationBuilder:
                _inputDecoration,
          ),
          const SizedBox(
            height: 16,
          ),
          _InstructionField(
            controller:
                usageInstructionsController,
            label:
                l10n.usageInstructions,
            hint: l10n
                .usageInstructionsHint,
            icon: Icons
                .fact_check_outlined,
            decorationBuilder:
                _inputDecoration,
          ),
        ],
      ),
    );
  }

  Widget _buildImageSection(
    AppLocalizations l10n,
  ) {
    return Container(
      padding:
          const EdgeInsets.all(
        22,
      ),
      decoration:
          _cardDecoration(),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment
                .stretch,
        children: [
          _SectionTitle(
            icon:
                Icons.image_outlined,
            title: l10n
                .supplierProductImage,
            subtitle: l10n
                .supplierProductImageSubtitle,
          ),
          const SizedBox(
            height: 20,
          ),
          if (selectedImageBytes !=
              null)
            _ImagePreview(
              onRemove:
                  _removeImage,
              child: Image.memory(
                selectedImageBytes!,
                fit: BoxFit.cover,
                errorBuilder: (
                  context,
                  error,
                  stackTrace,
                ) {
                  return const Center(
                    child: Icon(
                      Icons
                          .broken_image_outlined,
                      size: 48,
                      color: _muted,
                    ),
                  );
                },
              ),
            )
          else if (_getImageUrl(
                    currentImageUrl,
                  ) !=
                  null)
            _ImagePreview(
              onRemove:
                  _removeImage,
              child: Image.network(
                _getImageUrl(
                  currentImageUrl,
                )!,
                fit: BoxFit.cover,
                errorBuilder: (
                  context,
                  error,
                  stackTrace,
                ) {
                  return const Center(
                    child: Icon(
                      Icons
                          .broken_image_outlined,
                      size: 48,
                      color: _muted,
                    ),
                  );
                },
              ),
            )
          else
            Container(
              height: 220,
              decoration:
                  BoxDecoration(
                color:
                    const Color(
                  0xFFF2F6EE,
                ),
                borderRadius:
                    BorderRadius
                        .circular(
                  18,
                ),
                border:
                    Border.all(
                  color:
                      const Color(
                    0xFFD8E2D4,
                  ),
                ),
              ),
              child: const Center(
                child: Icon(
                  Icons
                      .add_photo_alternate_outlined,
                  size: 54,
                  color: _primary,
                ),
              ),
            ),
          const SizedBox(
            height: 16,
          ),
          OutlinedButton.icon(
            onPressed:
                isSaving
                    ? null
                    : _selectImage,
            icon: const Icon(
              Icons
                  .photo_library_outlined,
            ),
            label: Text(
              selectedImageBytes !=
                          null ||
                      (currentImageUrl !=
                              null &&
                          currentImageUrl!
                              .trim()
                              .isNotEmpty)
                  ? l10n
                      .changeProductImage
                  : l10n
                      .chooseProductImage,
            ),
            style:
                OutlinedButton.styleFrom(
              foregroundColor:
                  _primary,
              side:
                  const BorderSide(
                color: _primary,
              ),
              minimumSize:
                  const Size(
                double.infinity,
                52,
              ),
              shape:
                  RoundedRectangleBorder(
                borderRadius:
                    BorderRadius
                        .circular(
                  14,
                ),
              ),
              textStyle:
                  const TextStyle(
                fontWeight:
                    FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSaveButton(
    AppLocalizations l10n,
  ) {
    return SizedBox(
      height: 56,
      child:
          ElevatedButton.icon(
        onPressed:
            isSaving
                ? null
                : _saveProduct,
        icon: isSaving
            ? const SizedBox(
                width: 20,
                height: 20,
                child:
                    CircularProgressIndicator(
                  strokeWidth: 2.3,
                  color:
                      Colors.white,
                ),
              )
            : Icon(
                widget.isEditing
                    ? Icons
                        .save_outlined
                    : Icons
                        .add_circle_outline,
              ),
        label: Text(
          isSaving
              ? l10n.saving
              : widget.isEditing
                  ? l10n
                      .saveChanges
                  : l10n
                      .addSupplierProduct,
        ),
        style:
            ElevatedButton.styleFrom(
          backgroundColor:
              _primary,
          foregroundColor:
              Colors.white,
          disabledBackgroundColor:
              _primary.withValues(
            alpha: 0.65,
          ),
          disabledForegroundColor:
              Colors.white,
          elevation: 0,
          shape:
              RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(
              15,
            ),
          ),
          textStyle:
              const TextStyle(
            fontSize: 16,
            fontWeight:
                FontWeight.w800,
          ),
        ),
      ),
    );
  }
}

class _SectionTitle
    extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _SectionTitle({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    return Row(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        Container(
          width: 44,
          height: 44,
          decoration:
              BoxDecoration(
            color:
                const Color(
              0xFFEAF3E7,
            ),
            borderRadius:
                BorderRadius.circular(
              13,
            ),
          ),
          child: Icon(
            icon,
            size: 22,
            color:
                const Color(
              0xFF2F6B3D,
            ),
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
                      Color(
                    0xFF1D2A20,
                  ),
                  fontSize: 18,
                  fontWeight:
                      FontWeight
                          .w800,
                ),
              ),
              const SizedBox(
                height: 3,
              ),
              Text(
                subtitle,
                style:
                    const TextStyle(
                  color:
                      Color(
                    0xFF6D786F,
                  ),
                  fontSize: 12.5,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _InstructionField
    extends StatelessWidget {
  final TextEditingController
      controller;

  final String label;
  final String hint;
  final IconData icon;

  final InputDecoration Function({
    required String label,
    String? hint,
    IconData? icon,
  }) decorationBuilder;

  const _InstructionField({
    required this.controller,
    required this.label,
    required this.hint,
    required this.icon,
    required this.decorationBuilder,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    return TextField(
      controller: controller,
      minLines: 3,
      maxLines: 6,
      decoration:
          decorationBuilder(
        label: label,
        hint: hint,
        icon: icon,
      ),
    );
  }
}

class _ImagePreview
    extends StatelessWidget {
  final Widget child;
  final VoidCallback onRemove;

  const _ImagePreview({
    required this.child,
    required this.onRemove,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    final l10n =
        AppLocalizations.of(
      context,
    )!;

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
        border:
            Border.all(
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
          PositionedDirectional(
            top: 12,
            end: 12,
            child: Material(
              color:
                  const Color(
                0xE6FFFFFF,
              ),
              borderRadius:
                  BorderRadius.circular(
                12,
              ),
              child: IconButton(
                tooltip:
                    l10n.removeImage,
                onPressed:
                    onRemove,
                icon: const Icon(
                  Icons.delete_outline,
                  color:
                      Colors.red,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}