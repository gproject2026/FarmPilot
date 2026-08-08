import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_constants.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../providers/category_provider.dart';
import '../../providers/dashboard_provider.dart';
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

    final language =
        Localizations.localeOf(
      context,
    ).languageCode;

    try {
      final result =
          await productProvider
              .generateMarketingContent(
        productName: productName,
        productDetails:
            productDetails.isEmpty
                ? l10n
                    .freshFarmProduct
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

    final languageCode =
        Localizations.localeOf(
      context,
    ).languageCode;

    final isArabic =
        languageCode == 'ar';

    final nameAr =
        isArabic
            ? name
            : '';

    final descriptionAr =
        isArabic
            ? description
            : '';

    final nameEn =
        isArabic
            ? ''
            : name;

    final descriptionEn =
        isArabic
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

    final oldImageUrl =
        _buildImageUrl(
      currentImageUrl,
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.isEditing
              ? l10n.editProduct
              : l10n.addProduct,
        ),
      ),
      body: SingleChildScrollView(
        padding:
            const EdgeInsets.all(
          20,
        ),
        child: Column(
          children: [
            categoryProvider.isLoading
                ? const CircularProgressIndicator()
                : DropdownButtonFormField<
                    String>(
                    initialValue:
                        categoryProvider
                            .selectedCategoryId,
                    decoration:
                        InputDecoration(
                      labelText:
                          l10n.category,
                      border:
                          const OutlineInputBorder(),
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
                          value:
                              category['id']
                                  .toString(),
                          child: Text(
                            categoryName,
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
                  InputDecoration(
                labelText:
                    l10n.productName,
                border:
                    const OutlineInputBorder(),
              ),
            ),

            const SizedBox(
              height: 12,
            ),

            SizedBox(
              width:
                  double.infinity,
              child:
                  OutlinedButton.icon(
                onPressed:
                    productProvider
                            .isLoading
                        ? null
                        : _generateMarketingContent,
                icon: const Icon(
                  Icons.auto_awesome,
                ),
                label: Text(
                  l10n
                      .generateMarketingContent,
                ),
              ),
            ),

            const SizedBox(
              height: 16,
            ),

            TextField(
              controller:
                  descriptionController,
              maxLines: 3,
              decoration:
                  InputDecoration(
                labelText:
                    l10n.description,
                border:
                    const OutlineInputBorder(),
              ),
            ),

            const SizedBox(
              height: 16,
            ),

            TextField(
              controller:
                  priceController,
              keyboardType:
                  const TextInputType
                      .numberWithOptions(
                decimal: true,
              ),
              decoration:
                  InputDecoration(
                labelText:
                    l10n.price,
                border:
                    const OutlineInputBorder(),
              ),
            ),

            const SizedBox(
              height: 16,
            ),

            TextField(
              controller:
                  quantityController,
              keyboardType:
                  TextInputType.number,
              decoration:
                  InputDecoration(
                labelText:
                    l10n.quantity,
                border:
                    const OutlineInputBorder(),
              ),
            ),

            const SizedBox(
              height: 16,
            ),

            TextField(
              controller:
                  unitController,
              decoration:
                  InputDecoration(
                labelText:
                    l10n.unit,
                hintText: 'kg',
                border:
                    const OutlineInputBorder(),
              ),
            ),

            const SizedBox(
              height: 20,
            ),

            if (selectedImageBytes !=
                null)
              Stack(
                children: [
                  Container(
                    width:
                        double.infinity,
                    height: 260,
                    padding:
                        const EdgeInsets.all(
                      8,
                    ),
                    decoration:
                        BoxDecoration(
                      border:
                          Border.all(
                        color:
                            Colors.grey,
                      ),
                      borderRadius:
                          BorderRadius.circular(
                        12,
                      ),
                    ),
                    child:
                        ClipRRect(
                      borderRadius:
                          BorderRadius.circular(
                        8,
                      ),
                      child:
                          Image.memory(
                        selectedImageBytes!,
                        fit:
                            BoxFit.contain,
                      ),
                    ),
                  ),
                  PositionedDirectional(
                    top: 8,
                    end: 8,
                    child:
                        IconButton.filled(
                      onPressed:
                          _removeSelectedImage,
                      icon:
                          const Icon(
                        Icons.close,
                      ),
                    ),
                  ),
                ],
              )
            else if (oldImageUrl !=
                null)
              Container(
                width:
                    double.infinity,
                height: 260,
                padding:
                    const EdgeInsets.all(
                  8,
                ),
                decoration:
                    BoxDecoration(
                  border: Border.all(
                    color:
                        Colors.grey,
                  ),
                  borderRadius:
                      BorderRadius.circular(
                    12,
                  ),
                ),
                child: ClipRRect(
                  borderRadius:
                      BorderRadius.circular(
                    8,
                  ),
                  child: Image.network(
                    oldImageUrl,
                    fit:
                        BoxFit.contain,
                    errorBuilder: (
                      context,
                      error,
                      stackTrace,
                    ) {
                      return const Center(
                        child: Icon(
                          Icons
                              .broken_image_outlined,
                          size: 60,
                        ),
                      );
                    },
                  ),
                ),
              ),

            if (selectedImageBytes !=
                    null ||
                oldImageUrl != null)
              const SizedBox(
                height: 12,
              ),

            SizedBox(
              width:
                  double.infinity,
              child:
                  OutlinedButton.icon(
                onPressed:
                    productProvider
                            .isLoading
                        ? null
                        : _pickImage,
                icon: const Icon(
                  Icons
                      .add_photo_alternate,
                ),
                label: Text(
                  selectedImageBytes ==
                          null
                      ? l10n
                          .chooseProductImage
                      : l10n
                          .changeProductImage,
                ),
              ),
            ),

            const SizedBox(
              height: 24,
            ),

            SizedBox(
              width:
                  double.infinity,
              child: ElevatedButton(
                onPressed:
                    productProvider
                            .isLoading
                        ? null
                        : _saveProduct,
                child:
                    productProvider
                            .isLoading
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child:
                                CircularProgressIndicator(
                              strokeWidth:
                                  2,
                            ),
                          )
                        : Text(
                            widget
                                    .isEditing
                                ? l10n
                                    .saveChanges
                                : l10n
                                    .addProduct,
                          ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}