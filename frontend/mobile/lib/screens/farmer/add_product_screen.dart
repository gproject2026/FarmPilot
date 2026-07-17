import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_constants.dart';
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

class _AddProductScreenState extends State<AddProductScreen> {
  final nameController = TextEditingController();
  final descriptionController = TextEditingController();
  final priceController = TextEditingController();
  final quantityController = TextEditingController();
  final unitController = TextEditingController();

  final ImagePicker imagePicker = ImagePicker();

  Uint8List? selectedImageBytes;
  String? selectedImageName;
  String? currentImageUrl;

  @override
  void initState() {
    super.initState();

    _fillProductData();

    Future.microtask(() async {
      final categoryProvider = Provider.of<CategoryProvider>(
        context,
        listen: false,
      );

      await categoryProvider.loadCategories();

      if (!mounted || !widget.isEditing) {
        return;
      }

      final product = widget.product!;

      final categoryId =
          product['categoryId']?.toString() ??
          product['category']?['id']?.toString();

      if (categoryId != null) {
        categoryProvider.selectCategory(categoryId);
      }
    });
  }

  void _fillProductData() {
    if (!widget.isEditing) {
      return;
    }

    final product = widget.product!;

    nameController.text =
        product['name']?.toString() ?? '';

    descriptionController.text =
        product['description']?.toString() ?? '';

    priceController.text =
        product['price']?.toString() ?? '';

    quantityController.text =
        product['quantity']?.toString() ?? '';

    unitController.text =
        product['unit']?.toString() ?? '';

    currentImageUrl =
        product['imageUrl']?.toString();
  }

  String? _buildImageUrl(String? imageUrl) {
    if (imageUrl == null || imageUrl.trim().isEmpty) {
      return null;
    }

    final value = imageUrl.trim();

    if (value.startsWith('http://') ||
        value.startsWith('https://')) {
      return value;
    }

    if (value.startsWith('/')) {
      return '${AppConstants.baseUrl}$value';
    }

    return '${AppConstants.baseUrl}/$value';
  }

  Future<void> _pickImage() async {
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

      setState(() {
        selectedImageBytes = imageBytes;
        selectedImageName = pickedImage.name;
      });
    } catch (e) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Failed to select image: $e',
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _removeSelectedImage() {
    setState(() {
      selectedImageBytes = null;
      selectedImageName = null;
    });
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

  Future<void> _saveProduct() async {
    final productProvider = Provider.of<ProductProvider>(
      context,
      listen: false,
    );

    final categoryProvider = Provider.of<CategoryProvider>(
      context,
      listen: false,
    );

    final categoryId =
        categoryProvider.selectedCategoryId;

    if (categoryId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Please select a category',
          ),
        ),
      );

      return;
    }

    final name = nameController.text.trim();

    final description =
        descriptionController.text.trim();

    final price = double.tryParse(
      priceController.text.trim(),
    );

    final quantity = int.tryParse(
      quantityController.text.trim(),
    );

    final unit = unitController.text.trim();

    if (name.isEmpty ||
        price == null ||
        price <= 0 ||
        quantity == null ||
        quantity < 0 ||
        unit.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Please enter valid product data',
          ),
        ),
      );

      return;
    }

    try {
      String? imageUrl = currentImageUrl;

      if (selectedImageBytes != null &&
          selectedImageName != null) {
        imageUrl =
            await productProvider.uploadProductImage(
          imageBytes: selectedImageBytes!,
          fileName: selectedImageName!,
        );
      }

      if (widget.isEditing) {
        final productId =
            widget.product!['id']?.toString();

        if (productId == null || productId.isEmpty) {
          throw Exception(
            'Product ID was not found',
          );
        }

        await productProvider.updateProduct(
          productId: productId,
          categoryId: categoryId,
          name: name,
          description: description,
          price: price,
          quantity: quantity,
          unit: unit,
          imageUrl: imageUrl,
        );
      } else {
        await productProvider.createProduct(
          categoryId: categoryId,
          name: name,
          description: description,
          price: price,
          quantity: quantity,
          unit: unit,
          imageUrl: imageUrl,
        );
      }

      await Provider.of<DashboardProvider>(
        context,
        listen: false,
      ).loadFarmerDashboard();

      if (!mounted) {
        return;
      }

      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            e.toString(),
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final productProvider =
        Provider.of<ProductProvider>(context);

    final categoryProvider =
        Provider.of<CategoryProvider>(context);

    final oldImageUrl =
        _buildImageUrl(currentImageUrl);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.isEditing
              ? 'Edit Product'
              : 'Add Product',
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            categoryProvider.isLoading
                ? const CircularProgressIndicator()
                : DropdownButtonFormField<String>(
                    initialValue:
                        categoryProvider.selectedCategoryId,
                    decoration: const InputDecoration(
                      labelText: 'Category',
                      border: OutlineInputBorder(),
                    ),
                    items:
                        categoryProvider.categories.map(
                      (category) {
                        return DropdownMenuItem<String>(
                          value:
                              category['id'].toString(),
                          child: Text(
                            category['name'].toString(),
                          ),
                        );
                      },
                    ).toList(),
                    onChanged:
                        categoryProvider.selectCategory,
                  ),
            const SizedBox(height: 16),
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Product Name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: descriptionController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Description',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: priceController,
              keyboardType:
                  const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: const InputDecoration(
                labelText: 'Price',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: quantityController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Quantity',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: unitController,
              decoration: const InputDecoration(
                labelText: 'Unit',
                hintText: 'kg',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),

            if (selectedImageBytes != null)
              Stack(
                children: [
                  Container(
                    width: double.infinity,
                    height: 260,
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Colors.grey,
                      ),
                      borderRadius:
                          BorderRadius.circular(12),
                    ),
                    child: ClipRRect(
                      borderRadius:
                          BorderRadius.circular(8),
                      child: Image.memory(
                        selectedImageBytes!,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: IconButton.filled(
                      onPressed:
                          _removeSelectedImage,
                      icon: const Icon(
                        Icons.close,
                      ),
                    ),
                  ),
                ],
              )
            else if (oldImageUrl != null)
              Container(
                width: double.infinity,
                height: 260,
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.grey,
                  ),
                  borderRadius:
                      BorderRadius.circular(12),
                ),
                child: ClipRRect(
                  borderRadius:
                      BorderRadius.circular(8),
                  child: Image.network(
                    oldImageUrl,
                    fit: BoxFit.contain,
                    errorBuilder: (
                      context,
                      error,
                      stackTrace,
                    ) {
                      return const Center(
                        child: Icon(
                          Icons.broken_image_outlined,
                          size: 60,
                        ),
                      );
                    },
                  ),
                ),
              ),

            if (selectedImageBytes != null ||
                oldImageUrl != null)
              const SizedBox(height: 12),

            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: productProvider.isLoading
                    ? null
                    : _pickImage,
                icon: const Icon(
                  Icons.add_photo_alternate,
                ),
                label: Text(
                  selectedImageBytes == null
                      ? 'Choose Product Image'
                      : 'Change Product Image',
                ),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: productProvider.isLoading
                    ? null
                    : _saveProduct,
                child: productProvider.isLoading
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child:
                            CircularProgressIndicator(
                          strokeWidth: 2,
                        ),
                      )
                    : Text(
                        widget.isEditing
                            ? 'Save Changes'
                            : 'Add Product',
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}