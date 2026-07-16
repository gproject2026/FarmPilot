import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/category_provider.dart';
import '../../providers/product_provider.dart';
import '../../providers/dashboard_provider.dart';

class AddProductScreen extends StatefulWidget {
  const AddProductScreen({super.key});

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

  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      Provider.of<CategoryProvider>(
        context,
        listen: false,
      ).loadCategories();
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

  @override
  Widget build(BuildContext context) {
    final productProvider =
        Provider.of<ProductProvider>(context);

    final categoryProvider =
        Provider.of<CategoryProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Product'),
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
                    items: categoryProvider.categories.map(
                      (category) {
                        return DropdownMenuItem<String>(
                          value: category['id'].toString(),
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
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: productProvider.isLoading
                    ? null
                    : () async {
                        final categoryId =
                            categoryProvider.selectedCategoryId;

                        if (categoryId == null) {
                          ScaffoldMessenger.of(context)
                              .showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Please select a category',
                              ),
                            ),
                          );
                          return;
                        }

                        final price =
                            double.tryParse(priceController.text);

                        final quantity =
                            int.tryParse(quantityController.text);

                        if (nameController.text.trim().isEmpty ||
                            price == null ||
                            quantity == null ||
                            unitController.text.trim().isEmpty) {
                          ScaffoldMessenger.of(context)
                              .showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Please enter valid product data',
                              ),
                            ),
                          );
                          return;
                        }

                        try {
                          await productProvider.createProduct(
                            categoryId: categoryId,
                            name: nameController.text.trim(),
                            description:
                                descriptionController.text.trim(),
                            price: price,
                            quantity: quantity,
                            unit: unitController.text.trim(),
                          );

                          await Provider.of<DashboardProvider>(
                          context,
                          listen: false,
                           ).loadFarmerDashboard();

                          if (!context.mounted) return;

                          Navigator.pop(context);

                          ScaffoldMessenger.of(context)
                              .showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Product added successfully',
                              ),
                            ),
                          );
                        } catch (e) {
                          if (!context.mounted) return;

                          ScaffoldMessenger.of(context)
                              .showSnackBar(
                            SnackBar(
                              content: Text(e.toString()),
                            ),
                          );
                        }
                      },
                child: productProvider.isLoading
                    ? const CircularProgressIndicator()
                    : const Text('Add Product'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}