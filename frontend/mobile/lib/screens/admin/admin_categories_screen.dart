import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/category_provider.dart';

class AdminCategoriesScreen extends StatefulWidget {
  const AdminCategoriesScreen({
    super.key,
  });

  @override
  State<AdminCategoriesScreen> createState() =>
      _AdminCategoriesScreenState();
}

class _AdminCategoriesScreenState
    extends State<AdminCategoriesScreen> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback(
      (_) {
        if (!mounted) {
          return;
        }

        _loadCategories();
      },
    );
  }

  Future<void> _loadCategories() async {
    final provider =
        Provider.of<CategoryProvider>(
      context,
      listen: false,
    );

    await provider.loadCategories();
  }

  String? _optionalText(
    TextEditingController controller,
  ) {
    final value =
        controller.text.trim();

    return value.isEmpty
        ? null
        : value;
  }

  Future<void> _openCategoryDialog({
    Map<String, dynamic>? category,
  }) async {
    final nameEnController =
        TextEditingController(
      text:
          category?['nameEn']
                  ?.toString() ??
              category?['name']
                  ?.toString() ??
              '',
    );

    final nameArController =
        TextEditingController(
      text:
          category?['nameAr']
                  ?.toString() ??
              '',
    );

    final descriptionEnController =
        TextEditingController(
      text:
          category?['descriptionEn']
                  ?.toString() ??
              category?['description']
                  ?.toString() ??
              '',
    );

    final descriptionArController =
        TextEditingController(
      text:
          category?['descriptionAr']
                  ?.toString() ??
              '',
    );

    final isEditing =
        category != null;

    final result =
        await showDialog<bool>(
      context: context,
      builder: (
        dialogContext,
      ) {
        return AlertDialog(
          title: Text(
            isEditing
                ? 'Edit Category'
                : 'Add Category',
          ),
          content: SizedBox(
            width: 520,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize:
                    MainAxisSize.min,
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  const Text(
                    'English',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),
                  const SizedBox(
                    height: 12,
                  ),
                  TextField(
                    controller:
                        nameEnController,
                    textDirection:
                        TextDirection.ltr,
                    decoration:
                        const InputDecoration(
                      labelText:
                          'Category Name (English)',
                      border:
                          OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(
                    height: 14,
                  ),
                  TextField(
                    controller:
                        descriptionEnController,
                    textDirection:
                        TextDirection.ltr,
                    maxLines: 3,
                    decoration:
                        const InputDecoration(
                      labelText:
                          'Description (English)',
                      border:
                          OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(
                    height: 24,
                  ),
                  const Divider(),
                  const SizedBox(
                    height: 16,
                  ),
                  const Align(
                    alignment:
                        Alignment.centerRight,
                    child: Text(
                      'العربية',
                      textDirection:
                          TextDirection.rtl,
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight:
                            FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 12,
                  ),
                  TextField(
                    controller:
                        nameArController,
                    textDirection:
                        TextDirection.rtl,
                    textAlign:
                        TextAlign.right,
                    decoration:
                        const InputDecoration(
                      labelText:
                          'اسم التصنيف (العربية)',
                      border:
                          OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(
                    height: 14,
                  ),
                  TextField(
                    controller:
                        descriptionArController,
                    textDirection:
                        TextDirection.rtl,
                    textAlign:
                        TextAlign.right,
                    maxLines: 3,
                    decoration:
                        const InputDecoration(
                      labelText:
                          'الوصف (العربية)',
                      border:
                          OutlineInputBorder(),
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
                  false,
                );
              },
              child: const Text(
                'Cancel',
              ),
            ),
            ElevatedButton(
              onPressed: () {
                final nameEn =
                    nameEnController.text
                        .trim();

                final nameAr =
                    nameArController.text
                        .trim();

                if (nameEn.isEmpty ||
                    nameAr.isEmpty) {
                  ScaffoldMessenger.of(
                    dialogContext,
                  ).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'English and Arabic category names are required',
                      ),
                    ),
                  );

                  return;
                }

                Navigator.pop(
                  dialogContext,
                  true,
                );
              },
              style:
                  ElevatedButton.styleFrom(
                backgroundColor:
                    Colors.green,
                foregroundColor:
                    Colors.white,
              ),
              child: Text(
                isEditing
                    ? 'Save'
                    : 'Add',
              ),
            ),
          ],
        );
      },
    );

    if (result != true ||
        !mounted) {
      nameEnController.dispose();
      nameArController.dispose();
      descriptionEnController.dispose();
      descriptionArController.dispose();

      return;
    }

    final provider =
        Provider.of<CategoryProvider>(
      context,
      listen: false,
    );

    final nameEn =
        nameEnController.text.trim();

    final nameAr =
        nameArController.text.trim();

    final descriptionEn =
        _optionalText(
      descriptionEnController,
    );

    final descriptionAr =
        _optionalText(
      descriptionArController,
    );

    nameEnController.dispose();
    nameArController.dispose();
    descriptionEnController.dispose();
    descriptionArController.dispose();

    bool success;

    if (isEditing) {
      success =
          await provider.updateCategory(
        categoryId:
            category['id'].toString(),
        name: nameEn,
        nameEn: nameEn,
        nameAr: nameAr,
        description:
            descriptionEn,
        descriptionEn:
            descriptionEn,
        descriptionAr:
            descriptionAr,
      );
    } else {
      success =
          await provider.createCategory(
        name: nameEn,
        nameEn: nameEn,
        nameAr: nameAr,
        description:
            descriptionEn,
        descriptionEn:
            descriptionEn,
        descriptionAr:
            descriptionAr,
      );
    }

    if (!mounted) {
      return;
    }

    if (success) {
      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text(
            isEditing
                ? 'Category updated successfully'
                : 'Category added successfully',
          ),
          backgroundColor:
              Colors.green,
        ),
      );

      return;
    }

    ScaffoldMessenger.of(context)
        .showSnackBar(
      SnackBar(
        content: Text(
          provider.errorMessage ??
              'Failed to save category',
        ),
        backgroundColor:
            Colors.red,
      ),
    );
  }

  Future<void> _deleteCategory(
    Map<String, dynamic> category,
  ) async {
    final categoryName =
        category['nameEn']
                ?.toString() ??
            category['name']
                ?.toString() ??
            'Category';

    final productCount =
        _productCount(
      category,
    );

    final confirmed =
        await showDialog<bool>(
      context: context,
      builder: (
        dialogContext,
      ) {
        return AlertDialog(
          title: const Text(
            'Delete Category',
          ),
          content: Text(
            productCount > 0
                ? '"$categoryName" contains $productCount product(s). It cannot be deleted while products are linked to it.'
                : 'Are you sure you want to delete "$categoryName"?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(
                  dialogContext,
                  false,
                );
              },
              child: const Text(
                'Cancel',
              ),
            ),
            ElevatedButton(
              onPressed:
                  productCount > 0
                      ? null
                      : () {
                          Navigator.pop(
                            dialogContext,
                            true,
                          );
                        },
              style:
                  ElevatedButton.styleFrom(
                backgroundColor:
                    Colors.red,
                foregroundColor:
                    Colors.white,
              ),
              child: const Text(
                'Delete',
              ),
            ),
          ],
        );
      },
    );

    if (confirmed != true ||
        !mounted) {
      return;
    }

    final provider =
        Provider.of<CategoryProvider>(
      context,
      listen: false,
    );

    final success =
        await provider.deleteCategory(
      category['id'].toString(),
    );

    if (!mounted) {
      return;
    }

    if (success) {
      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            'Category deleted successfully',
          ),
          backgroundColor:
              Colors.green,
        ),
      );

      return;
    }

    ScaffoldMessenger.of(context)
        .showSnackBar(
      SnackBar(
        content: Text(
          provider.errorMessage ??
              'Failed to delete category',
        ),
        backgroundColor:
            Colors.red,
      ),
    );
  }

  int _productCount(
    Map<String, dynamic> category,
  ) {
    final countData =
        category['_count'];

    if (countData is Map) {
      return int.tryParse(
            countData['products']
                    ?.toString() ??
                '0',
          ) ??
          0;
    }

    return 0;
  }

  @override
  Widget build(
    BuildContext context,
  ) {
    final provider =
        Provider.of<CategoryProvider>(
      context,
    );

    return Scaffold(
      backgroundColor:
          const Color(
        0xFFF5F7F4,
      ),
      appBar: AppBar(
        title: const Text(
          'Manage Categories',
        ),
        backgroundColor:
            Colors.green,
        foregroundColor:
            Colors.white,
        actions: [
          IconButton(
            tooltip: 'Refresh',
            onPressed:
                provider.isLoading
                    ? null
                    : _loadCategories,
            icon: const Icon(
              Icons.refresh,
            ),
          ),
        ],
      ),
      floatingActionButton:
          FloatingActionButton.extended(
        onPressed:
            provider.isLoading
                ? null
                : () {
                    _openCategoryDialog();
                  },
        icon: const Icon(
          Icons.add,
        ),
        label: const Text(
          'Add Category',
        ),
      ),
      body:
          provider.isLoading &&
                  provider
                      .categories.isEmpty
              ? const Center(
                  child:
                      CircularProgressIndicator(),
                )
              : provider.errorMessage !=
                          null &&
                      provider
                          .categories.isEmpty
                  ? _buildError(
                      provider,
                    )
                  : provider
                          .categories.isEmpty
                      ? _buildEmpty()
                      : RefreshIndicator(
                          onRefresh:
                              _loadCategories,
                          child:
                              ListView.builder(
                            physics:
                                const AlwaysScrollableScrollPhysics(),
                            padding:
                                const EdgeInsets.fromLTRB(
                              16,
                              16,
                              16,
                              100,
                            ),
                            itemCount:
                                provider
                                    .categories
                                    .length,
                            itemBuilder: (
                              context,
                              index,
                            ) {
                              final category =
                                  Map<String,
                                      dynamic>.from(
                                provider
                                    .categories[
                                        index],
                              );

                              return _categoryCard(
                                category,
                              );
                            },
                          ),
                        ),
    );
  }

  Widget _buildError(
    CategoryProvider provider,
  ) {
    return RefreshIndicator(
      onRefresh: _loadCategories,
      child: ListView(
        physics:
            const AlwaysScrollableScrollPhysics(),
        padding:
            const EdgeInsets.all(
          24,
        ),
        children: [
          const SizedBox(
            height: 150,
          ),
          const Icon(
            Icons.error_outline,
            size: 75,
            color: Colors.red,
          ),
          const SizedBox(
            height: 16,
          ),
          Text(
            provider.errorMessage ??
                'Failed to load categories',
            textAlign:
                TextAlign.center,
            style:
                const TextStyle(
              fontSize: 17,
              fontWeight:
                  FontWeight.w600,
            ),
          ),
          const SizedBox(
            height: 18,
          ),
          Center(
            child:
                ElevatedButton.icon(
              onPressed:
                  _loadCategories,
              icon:
                  const Icon(
                Icons.refresh,
              ),
              label:
                  const Text(
                'Try Again',
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmpty() {
    return RefreshIndicator(
      onRefresh: _loadCategories,
      child: ListView(
        physics:
            const AlwaysScrollableScrollPhysics(),
        padding:
            const EdgeInsets.all(
          24,
        ),
        children: const [
          SizedBox(
            height: 150,
          ),
          Icon(
            Icons.category_outlined,
            size: 75,
            color: Colors.grey,
          ),
          SizedBox(
            height: 16,
          ),
          Center(
            child: Text(
              'No Categories Found',
              style:
                  TextStyle(
                fontSize: 18,
                fontWeight:
                    FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _categoryCard(
    Map<String, dynamic> category,
  ) {
    final nameEn =
        category['nameEn']
                ?.toString()
                .trim() ??
            '';

    final nameAr =
        category['nameAr']
                ?.toString()
                .trim() ??
            '';

    final fallbackName =
        category['name']
                ?.toString()
                .trim() ??
            '';

    final displayNameEn =
        nameEn.isNotEmpty
            ? nameEn
            : fallbackName.isNotEmpty
                ? fallbackName
                : 'Unnamed Category';

    final descriptionEn =
        category['descriptionEn']
                ?.toString()
                .trim() ??
            '';

    final descriptionAr =
        category['descriptionAr']
                ?.toString()
                .trim() ??
            '';

    final fallbackDescription =
        category['description']
                ?.toString()
                .trim() ??
            '';

    final displayDescriptionEn =
        descriptionEn.isNotEmpty
            ? descriptionEn
            : fallbackDescription;

    final productCount =
        _productCount(
      category,
    );

    return Card(
      elevation: 2,
      margin:
          const EdgeInsets.only(
        bottom: 14,
      ),
      shape:
          RoundedRectangleBorder(
        borderRadius:
            BorderRadius.circular(
          16,
        ),
      ),
      child: Padding(
        padding:
            const EdgeInsets.all(
          16,
        ),
        child: Row(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 26,
              backgroundColor:
                  Colors.green
                      .shade100,
              child: Icon(
                Icons.category_outlined,
                color: Colors.green
                    .shade700,
              ),
            ),
            const SizedBox(
              width: 14,
            ),
            Expanded(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Text(
                    displayNameEn,
                    style:
                        const TextStyle(
                      fontSize: 18,
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),
                  if (nameAr
                      .isNotEmpty) ...[
                    const SizedBox(
                      height: 4,
                    ),
                    Text(
                      nameAr,
                      textDirection:
                          TextDirection.rtl,
                      style:
                          const TextStyle(
                        fontSize: 16,
                        fontWeight:
                            FontWeight.w600,
                      ),
                    ),
                  ],
                  if (displayDescriptionEn
                      .isNotEmpty) ...[
                    const SizedBox(
                      height: 6,
                    ),
                    Text(
                      displayDescriptionEn,
                      style:
                          TextStyle(
                        color: Colors
                            .grey
                            .shade700,
                        height: 1.4,
                      ),
                    ),
                  ],
                  if (descriptionAr
                      .isNotEmpty) ...[
                    const SizedBox(
                      height: 4,
                    ),
                    Text(
                      descriptionAr,
                      textDirection:
                          TextDirection.rtl,
                      style:
                          TextStyle(
                        color: Colors
                            .grey
                            .shade700,
                        height: 1.4,
                      ),
                    ),
                  ],
                  const SizedBox(
                    height: 10,
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration:
                        BoxDecoration(
                      color: Colors.blue
                          .shade50,
                      borderRadius:
                          BorderRadius.circular(
                        20,
                      ),
                    ),
                    child: Text(
                      '$productCount product${productCount == 1 ? '' : 's'}',
                      style:
                          TextStyle(
                        color: Colors.blue
                            .shade700,
                        fontWeight:
                            FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(
              width: 8,
            ),
            Column(
              children: [
                IconButton(
                  tooltip:
                      'Edit Category',
                  onPressed: () {
                    _openCategoryDialog(
                      category:
                          category,
                    );
                  },
                  icon: const Icon(
                    Icons.edit_outlined,
                    color: Colors.blue,
                  ),
                ),
                IconButton(
                  tooltip:
                      productCount > 0
                          ? 'Category contains products'
                          : 'Delete Category',
                  onPressed: () {
                    _deleteCategory(
                      category,
                    );
                  },
                  icon: Icon(
                    Icons.delete_outline,
                    color:
                        productCount > 0
                            ? Colors.grey
                            : Colors.red,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}