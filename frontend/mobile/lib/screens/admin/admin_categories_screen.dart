import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/category_provider.dart';
import '../../providers/locale_provider.dart';

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
  bool get _isArabic =>
      Localizations.localeOf(context).languageCode == 'ar';

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
                ? (_isArabic ? 'تعديل التصنيف' : 'Edit Category')
                : (_isArabic ? 'إضافة تصنيف' : 'Add Category'),
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
              child: Text(
                _isArabic ? 'إلغاء' : 'Cancel',
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
                    SnackBar(
                      content: Text(
                        _isArabic
                            ? 'اسم التصنيف بالإنجليزية والعربية مطلوبان'
                            : 'English and Arabic category names are required',
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
                    const Color(0xFF2F743F),
                foregroundColor:
                    Colors.white,
              ),
              child: Text(
                isEditing
                    ? (_isArabic ? 'حفظ' : 'Save')
                    : (_isArabic ? 'إضافة' : 'Add'),
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
                ? (_isArabic
                    ? 'تم تحديث التصنيف بنجاح'
                    : 'Category updated successfully')
                : (_isArabic
                    ? 'تمت إضافة التصنيف بنجاح'
                    : 'Category added successfully'),
          ),
          backgroundColor:
              const Color(0xFF2F743F),
        ),
      );

      return;
    }

    ScaffoldMessenger.of(context)
        .showSnackBar(
      SnackBar(
        content: Text(
          provider.errorMessage ??
              (_isArabic
                  ? 'فشل حفظ التصنيف'
                  : 'Failed to save category'),
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
          title: Text(
            _isArabic ? 'حذف التصنيف' : 'Delete Category',
          ),
          content: Text(
            productCount > 0
                ? (_isArabic
                    ? 'يحتوي "$categoryName" على $productCount منتج/منتجات، ولا يمكن حذفه ما دامت هناك منتجات مرتبطة به.'
                    : '"$categoryName" contains $productCount product(s). It cannot be deleted while products are linked to it.')
                : (_isArabic
                    ? 'هل أنت متأكد من حذف "$categoryName"؟'
                    : 'Are you sure you want to delete "$categoryName"?'),
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
                _isArabic ? 'إلغاء' : 'Cancel',
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
              child: Text(
                _isArabic ? 'حذف' : 'Delete',
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
        SnackBar(
          content: Text(
            _isArabic
                ? 'تم حذف التصنيف بنجاح'
                : 'Category deleted successfully',
          ),
          backgroundColor:
              const Color(0xFF2F743F),
        ),
      );

      return;
    }

    ScaffoldMessenger.of(context)
        .showSnackBar(
      SnackBar(
        content: Text(
          provider.errorMessage ??
              (_isArabic
                  ? 'فشل حذف التصنيف'
                  : 'Failed to delete category'),
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

    final categories =
        provider.categories;

    final totalProducts =
        categories.fold<int>(
      0,
      (
        total,
        rawCategory,
      ) {
        if (rawCategory is! Map) {
          return total;
        }

        final category =
            Map<String, dynamic>.from(
          rawCategory,
        );

        return total +
            _productCount(
              category,
            );
      },
    );

    return Scaffold(
      backgroundColor:
          const Color(
        0xFFF8FAF4,
      ),
      body: Stack(
        children: [
          const Positioned.fill(
            child:
                _AdminCategoriesBackdrop(),
          ),
          Column(
            children: [
              _AdminCategoriesTopBar(
                isArabic: _isArabic,
                onChangeLanguage: _changeLanguage,
                onBack: () =>
                    Navigator.pop(
                  context,
                ),
                onRefresh:
                    provider.isLoading
                        ? null
                        : _loadCategories,
              ),
              Expanded(
                child:
                    RefreshIndicator(
                  onRefresh:
                      _loadCategories,
                  color:
                      _adminCategoriesPrimary,
                  child:
                      CustomScrollView(
                    physics:
                        const AlwaysScrollableScrollPhysics(),
                    slivers: [
                      SliverToBoxAdapter(
                        child: Center(
                          child:
                              ConstrainedBox(
                            constraints:
                                const BoxConstraints(
                              maxWidth:
                                  1320,
                            ),
                            child:
                                Padding(
                              padding:
                                  const EdgeInsets
                                      .fromLTRB(
                                24,
                                26,
                                24,
                                18,
                              ),
                              child:
                                  _AdminCategoriesHero(
                                isArabic: _isArabic,
                                totalCategories:
                                    categories
                                        .length,
                                totalProducts:
                                    totalProducts,
                                isLoading:
                                    provider
                                        .isLoading,
                                onAddCategory:
                                    provider
                                            .isLoading
                                        ? null
                                        : () {
                                            _openCategoryDialog();
                                          },
                              ),
                            ),
                          ),
                        ),
                      ),
                      if (provider.isLoading &&
                          categories.isEmpty)
                        const SliverFillRemaining(
                          hasScrollBody:
                              false,
                          child: Center(
                            child:
                                CircularProgressIndicator(
                              color:
                                  _adminCategoriesPrimary,
                            ),
                          ),
                        )
                      else if (provider.errorMessage !=
                              null &&
                          categories.isEmpty)
                        SliverFillRemaining(
                          hasScrollBody:
                              false,
                          child:
                              _AdminCategoriesErrorState(
                            isArabic: _isArabic,
                            message:
                                provider.errorMessage ??
                                    (_isArabic
                                        ? 'فشل تحميل التصنيفات'
                                        : 'Failed to load categories'),
                            onRetry:
                                _loadCategories,
                          ),
                        )
                      else if (categories.isEmpty)
                        SliverFillRemaining(
                          hasScrollBody:
                              false,
                          child:
                              _AdminCategoriesEmptyState(
                            isArabic: _isArabic,
                            onAddCategory: () {
                              _openCategoryDialog();
                            },
                          ),
                        )
                      else
                        SliverPadding(
                          padding:
                              const EdgeInsets
                                  .fromLTRB(
                            24,
                            0,
                            24,
                            42,
                          ),
                          sliver:
                              SliverLayoutBuilder(
                            builder: (
                              context,
                              constraints,
                            ) {
                              final width =
                                  constraints
                                      .crossAxisExtent;

                              final crossAxisCount =
                                  width >= 1180
                                      ? 3
                                      : width >= 760
                                          ? 2
                                          : 1;

                              return SliverGrid(
                                delegate:
                                    SliverChildBuilderDelegate(
                                  (
                                    context,
                                    index,
                                  ) {
                                    final category =
                                        Map<String,
                                                dynamic>.from(
                                      categories[index]
                                          as Map,
                                    );

                                    return _AdminCategoryCard(
                                      isArabic: _isArabic,
                                      category:
                                          category,
                                      productCount:
                                          _productCount(
                                        category,
                                      ),
                                      onEdit: () {
                                        _openCategoryDialog(
                                          category:
                                              category,
                                        );
                                      },
                                      onDelete: () {
                                        _deleteCategory(
                                          category,
                                        );
                                      },
                                    );
                                  },
                                  childCount:
                                      categories
                                          .length,
                                ),
                                gridDelegate:
                                    SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount:
                                      crossAxisCount,
                                  crossAxisSpacing:
                                      16,
                                  mainAxisSpacing:
                                      16,
                                  mainAxisExtent:
                                      320,
                                ),
                              );
                            },
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          if (provider.isLoading &&
              categories.isNotEmpty)
            const Positioned(
              top: 0,
              left: 0,
              right: 0,
              child:
                  LinearProgressIndicator(
                color:
                    _adminCategoriesPrimary,
              ),
            ),
        ],
      ),
    );
  }
}

const _adminCategoriesDark =
    Color(0xFF173F24);
const _adminCategoriesPrimary =
    Color(0xFF2F743F);
const _adminCategoriesLight =
    Color(0xFFEAF3DF);
const _adminCategoriesText =
    Color(0xFF1D2C21);
const _adminCategoriesMuted =
    Color(0xFF6C786E);

class _AdminCategoriesTopBar
    extends StatelessWidget {
  final bool isArabic;
  final ValueChanged<String> onChangeLanguage;
  final VoidCallback onBack;
  final Future<void> Function()?
      onRefresh;

  const _AdminCategoriesTopBar({
    required this.isArabic,
    required this.onChangeLanguage,
    required this.onBack,
    required this.onRefresh,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    return Container(
      decoration:
          const BoxDecoration(
        gradient:
            LinearGradient(
          colors: [
            Color(
              0xFF123A22,
            ),
            Color(
              0xFF205A34,
            ),
            Color(
              0xFF2E6F40,
            ),
          ],
        ),
      ),
      padding:
          const EdgeInsets
              .fromLTRB(
        18,
        12,
        18,
        14,
      ),
      child: SafeArea(
        bottom: false,
        child: Row(
          children: [
            _AdminCategoriesHeaderButton(
              icon: Icons
                  .arrow_back_rounded,
              tooltip:
                  isArabic ? 'رجوع' : 'Back',
              onTap:
                  onBack,
            ),
            const SizedBox(
              width: 12,
            ),
            Container(
              width: 44,
              height: 44,
              decoration:
                  BoxDecoration(
                color:
                    const Color(
                  0xFFDDECB8,
                ),
                borderRadius:
                    BorderRadius
                        .circular(
                  13,
                ),
              ),
              child:
                  const Icon(
                Icons.eco_rounded,
                color:
                    _adminCategoriesDark,
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
                    isArabic
                        ? 'إدارة التصنيفات'
                        : 'Manage Categories',
                    style:
                        const TextStyle(
                      color:
                          Color(
                        0xCCFFFFFF,
                      ),
                      fontSize:
                          12,
                    ),
                  ),
                ],
              ),
            ),
            PopupMenuButton<String>(
              tooltip:
                  isArabic ? 'تغيير اللغة' : 'Change Language',
              color: Colors.white,
              onSelected: onChangeLanguage,
              icon: const Icon(
                Icons.language_rounded,
                color: Colors.white,
              ),
              itemBuilder: (context) {
                return [
                  PopupMenuItem<String>(
                    value: 'en',
                    child: Row(
                      children: [
                        Icon(
                          Icons.check_rounded,
                          color: !isArabic
                              ? _adminCategoriesPrimary
                              : Colors.transparent,
                        ),
                        const SizedBox(width: 8),
                        const Text('English'),
                      ],
                    ),
                  ),
                  PopupMenuItem<String>(
                    value: 'ar',
                    child: Row(
                      children: [
                        Icon(
                          Icons.check_rounded,
                          color: isArabic
                              ? _adminCategoriesPrimary
                              : Colors.transparent,
                        ),
                        const SizedBox(width: 8),
                        const Text('Arabic'),
                      ],
                    ),
                  ),
                ];
              },
            ),
            _AdminCategoriesHeaderButton(
              icon: Icons.refresh_rounded,
              tooltip:
                  isArabic ? 'تحديث' : 'Refresh',
              onTap:
                  onRefresh,
            ),
          ],
        ),
      ),
    );
  }
}

class _AdminCategoriesHeaderButton
    extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback? onTap;

  const _AdminCategoriesHeaderButton({
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
          alpha:
              onTap == null
                  ? 0.05
                  : 0.10,
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
              size: 21,
              color:
                  onTap == null
                      ? Colors.white54
                      : Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}

class _AdminCategoriesHero
    extends StatelessWidget {
  final bool isArabic;
  final int totalCategories;
  final int totalProducts;
  final bool isLoading;
  final VoidCallback? onAddCategory;

  const _AdminCategoriesHero({
    required this.isArabic,
    required this.totalCategories,
    required this.totalProducts,
    required this.isLoading,
    required this.onAddCategory,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    return Container(
      width:
          double.infinity,
      padding:
          const EdgeInsets.all(
        24,
      ),
      decoration:
          _adminCategoriesCardDecoration(
        24,
      ),
      child: LayoutBuilder(
        builder: (
          context,
          constraints,
        ) {
          final heading =
              Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration:
                    BoxDecoration(
                  color:
                      _adminCategoriesLight,
                  borderRadius:
                      BorderRadius
                          .circular(
                    18,
                  ),
                ),
                child:
                    const Icon(
                  Icons
                      .category_outlined,
                  color:
                      _adminCategoriesPrimary,
                  size: 30,
                ),
              ),
              const SizedBox(
                width: 16,
              ),
              Expanded(
                child:
                    Column(
                  crossAxisAlignment:
                      CrossAxisAlignment
                          .start,
                  children: [
                    Text(
                      isArabic
                          ? 'إدارة التصنيفات'
                          : 'Manage Categories',
                      style:
                          const TextStyle(
                        color:
                            _adminCategoriesText,
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
                      isArabic
                          ? 'تنظيم تصنيفات المتجر باللغتين العربية والإنجليزية.'
                          : 'Organize marketplace categories in English and Arabic.',
                      style:
                          const TextStyle(
                        color:
                            _adminCategoriesMuted,
                        fontSize: 13,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );

          final actions =
              Wrap(
            spacing: 10,
            runSpacing: 10,
            crossAxisAlignment:
                WrapCrossAlignment
                    .center,
            children: [
              _AdminCategoryStatChip(
                label:
                    isArabic ? 'التصنيفات' : 'Categories',
                value:
                    totalCategories,
              ),
              _AdminCategoryStatChip(
                label:
                    isArabic ? 'المنتجات' : 'Products',
                value:
                    totalProducts,
              ),
              ElevatedButton.icon(
                onPressed:
                    onAddCategory,
                style:
                    ElevatedButton
                        .styleFrom(
                  backgroundColor:
                      _adminCategoriesPrimary,
                  foregroundColor:
                      Colors.white,
                  disabledBackgroundColor:
                      const Color(
                    0xFF9FB5A4,
                  ),
                  elevation: 0,
                  padding:
                      const EdgeInsets
                          .symmetric(
                    horizontal:
                        18,
                    vertical:
                        15,
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
                icon: isLoading
                    ? const SizedBox(
                        width: 18,
                        height: 18,
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
                            .add_rounded,
                      ),
                label:
                    Text(
                  isArabic ? 'إضافة تصنيف' : 'Add Category',
                  style:
                      const TextStyle(
                    fontWeight:
                        FontWeight
                            .w700,
                  ),
                ),
              ),
            ],
          );

          if (constraints
                  .maxWidth <
              760) {
            return Column(
              crossAxisAlignment:
                  CrossAxisAlignment
                      .start,
              children: [
                heading,
                const SizedBox(
                  height: 18,
                ),
                actions,
              ],
            );
          }

          return Row(
            children: [
              Expanded(
                child:
                    heading,
              ),
              const SizedBox(
                width: 18,
              ),
              actions,
            ],
          );
        },
      ),
    );
  }
}

class _AdminCategoryStatChip
    extends StatelessWidget {
  final String label;
  final int value;

  const _AdminCategoryStatChip({
    required this.label,
    required this.value,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    return Container(
      padding:
          const EdgeInsets
              .symmetric(
        horizontal: 13,
        vertical: 10,
      ),
      decoration:
          BoxDecoration(
        color:
            const Color(
          0xFFF1F6E9,
        ),
        borderRadius:
            BorderRadius
                .circular(
          15,
        ),
      ),
      child: Text(
        '$label $value',
        style:
            const TextStyle(
          color:
              _adminCategoriesPrimary,
          fontSize: 12,
          fontWeight:
              FontWeight.w700,
        ),
      ),
    );
  }
}

class _AdminCategoryCard
    extends StatelessWidget {
  final bool isArabic;
  final Map<String, dynamic>
      category;
  final int productCount;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _AdminCategoryCard({
    required this.isArabic,
    required this.category,
    required this.productCount,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(
    BuildContext context,
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

    final displayNameAr =
        nameAr.isNotEmpty
            ? nameAr
            : fallbackName.isNotEmpty
                ? fallbackName
                : 'تصنيف بدون اسم';

    final displayDescriptionAr =
        descriptionAr.isNotEmpty
            ? descriptionAr
            : fallbackDescription;

    return Container(
      padding:
          const EdgeInsets.all(
        18,
      ),
      decoration:
          _adminCategoriesCardDecoration(
        22,
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment
                .start,
        children: [
          Row(
            crossAxisAlignment:
                CrossAxisAlignment
                    .start,
            children: [
              Container(
                width: 54,
                height: 54,
                decoration:
                    BoxDecoration(
                  color:
                      _adminCategoriesLight,
                  borderRadius:
                      BorderRadius
                          .circular(
                    15,
                  ),
                ),
                child:
                    const Icon(
                  Icons
                      .category_outlined,
                  color:
                      _adminCategoriesPrimary,
                  size: 27,
                ),
              ),
              const SizedBox(
                width: 12,
              ),
              Expanded(
                child:
                    Column(
                  crossAxisAlignment:
                      CrossAxisAlignment
                          .start,
                  children: [
                    Text(
                      isArabic
                          ? displayNameAr
                          : displayNameEn,
                      maxLines: 1,
                      overflow:
                          TextOverflow.ellipsis,
                      textDirection:
                          isArabic
                              ? TextDirection.rtl
                              : TextDirection.ltr,
                      style: const TextStyle(
                        color:
                            _adminCategoriesText,
                        fontSize: 17,
                        fontWeight:
                            FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets
                        .symmetric(
                  horizontal:
                      10,
                  vertical:
                      6,
                ),
                decoration:
                    BoxDecoration(
                  color:
                      const Color(
                    0xFFF1F6E9,
                  ),
                  borderRadius:
                      BorderRadius
                          .circular(
                    16,
                  ),
                ),
                child: Text(
                  isArabic
                      ? '$productCount ${productCount == 1 ? 'منتج' : 'منتجات'}'
                      : '$productCount ${productCount == 1 ? 'product' : 'products'}',
                  style:
                      const TextStyle(
                    color:
                        _adminCategoriesPrimary,
                    fontSize:
                        10,
                    fontWeight:
                        FontWeight
                            .w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(
            height: 16,
          ),
          if ((isArabic
                  ? displayDescriptionAr
                  : displayDescriptionEn)
              .isNotEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFFBFCF9),
                borderRadius: BorderRadius.circular(13),
                border: Border.all(
                  color: const Color(0xFFE3E9DF),
                ),
              ),
              child: Text(
                isArabic
                    ? displayDescriptionAr
                    : displayDescriptionEn,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                textDirection:
                    isArabic
                        ? TextDirection.rtl
                        : TextDirection.ltr,
                style: const TextStyle(
                  color: _adminCategoriesMuted,
                  fontSize: 12,
                  height: 1.4,
                ),
              ),
            ),
          const Spacer(),
          Row(
            children: [
              Expanded(
                child:
                    ElevatedButton.icon(
                  onPressed:
                      onEdit,
                  style:
                      ElevatedButton
                          .styleFrom(
                    backgroundColor:
                        _adminCategoriesPrimary,
                    foregroundColor:
                        Colors.white,
                    elevation: 0,
                    padding:
                        const EdgeInsets
                            .symmetric(
                      vertical:
                          13,
                    ),
                    shape:
                        RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius
                              .circular(
                        13,
                      ),
                    ),
                  ),
                  icon:
                      const Icon(
                    Icons
                        .edit_outlined,
                    size: 18,
                  ),
                  label:
                      Text(
                    isArabic ? 'تعديل' : 'Edit',
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
                width: 10,
              ),
              SizedBox(
                width: 48,
                height: 48,
                child:
                    IconButton(
                  tooltip:
                      productCount > 0
                          ? (isArabic
                              ? 'التصنيف يحتوي على منتجات'
                              : 'Category contains products')
                          : (isArabic
                              ? 'حذف التصنيف'
                              : 'Delete Category'),
                  onPressed:
                      onDelete,
                  style:
                      IconButton
                          .styleFrom(
                    backgroundColor:
                        const Color(
                      0xFFFFF3F3,
                    ),
                    foregroundColor:
                        productCount >
                                0
                            ? Colors
                                .grey
                            : const Color(
                                0xFFC65353,
                              ),
                    shape:
                        RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius
                              .circular(
                        13,
                      ),
                    ),
                  ),
                  icon:
                      const Icon(
                    Icons
                        .delete_outline,
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

class _AdminCategoriesEmptyState
    extends StatelessWidget {
  final bool isArabic;
  final VoidCallback onAddCategory;

  const _AdminCategoriesEmptyState({
    required this.isArabic,
    required this.onAddCategory,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    return Center(
      child: Container(
        constraints:
            const BoxConstraints(
          maxWidth: 460,
        ),
        margin:
            const EdgeInsets.all(
          24,
        ),
        padding:
            const EdgeInsets.all(
          30,
        ),
        decoration:
            _adminCategoriesCardDecoration(
          24,
        ),
        child: Column(
          mainAxisSize:
              MainAxisSize.min,
          children: [
            Container(
              width: 82,
              height: 82,
              decoration:
                  const BoxDecoration(
                color:
                    _adminCategoriesLight,
                shape:
                    BoxShape.circle,
              ),
              child:
                  const Icon(
                Icons
                    .category_outlined,
                size: 38,
                color:
                    _adminCategoriesPrimary,
              ),
            ),
            const SizedBox(
              height: 16,
            ),
            Text(
              isArabic
                  ? 'لا توجد تصنيفات'
                  : 'No Categories Found',
              textAlign:
                  TextAlign.center,
              style:
                  const TextStyle(
                color:
                    _adminCategoriesText,
                fontSize: 20,
                fontWeight:
                    FontWeight
                        .w800,
              ),
            ),
            const SizedBox(
              height: 8,
            ),
            Text(
              isArabic
                  ? 'أضف أول تصنيف في المتجر لتنظيم المنتجات.'
                  : 'Add the first marketplace category to organize products.',
              textAlign:
                  TextAlign.center,
              style:
                  const TextStyle(
                color:
                    _adminCategoriesMuted,
                fontSize: 13,
                height: 1.4,
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            ElevatedButton.icon(
              onPressed:
                  onAddCategory,
              style:
                  ElevatedButton
                      .styleFrom(
                backgroundColor:
                    _adminCategoriesPrimary,
                foregroundColor:
                    Colors.white,
                elevation: 0,
                padding:
                    const EdgeInsets
                        .symmetric(
                  horizontal:
                      18,
                  vertical:
                      14,
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
                    .add_rounded,
              ),
              label:
                  Text(
                isArabic ? 'إضافة تصنيف' : 'Add Category',
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AdminCategoriesErrorState
    extends StatelessWidget {
  final bool isArabic;
  final String message;
  final Future<void> Function()
      onRetry;

  const _AdminCategoriesErrorState({
    required this.isArabic,
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    return Center(
      child: Container(
        constraints:
            const BoxConstraints(
          maxWidth: 440,
        ),
        margin:
            const EdgeInsets.all(
          24,
        ),
        padding:
            const EdgeInsets.all(
          28,
        ),
        decoration:
            _adminCategoriesCardDecoration(
          24,
        ),
        child: Column(
          mainAxisSize:
              MainAxisSize.min,
          children: [
            const Icon(
              Icons
                  .error_outline_rounded,
              size: 56,
              color:
                  Color(
                0xFFC65353,
              ),
            ),
            const SizedBox(
              height: 14,
            ),
            Text(
              message,
              textAlign:
                  TextAlign.center,
              style:
                  const TextStyle(
                color:
                    _adminCategoriesText,
                fontSize: 14,
              ),
            ),
            const SizedBox(
              height: 18,
            ),
            ElevatedButton.icon(
              onPressed:
                  onRetry,
              style:
                  ElevatedButton
                      .styleFrom(
                backgroundColor:
                    _adminCategoriesPrimary,
                foregroundColor:
                    Colors.white,
                elevation: 0,
              ),
              icon:
                  const Icon(
                Icons
                    .refresh_rounded,
              ),
              label:
                  Text(
                isArabic ? 'حاول مرة أخرى' : 'Try Again',
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AdminCategoriesBackdrop
    extends StatelessWidget {
  const _AdminCategoriesBackdrop();

  @override
  Widget build(
    BuildContext context,
  ) {
    return IgnorePointer(
      child: Stack(
        fit:
            StackFit.expand,
        children: [
          const DecoratedBox(
            decoration:
                BoxDecoration(
              gradient:
                  LinearGradient(
                begin:
                    Alignment
                        .topCenter,
                end:
                    Alignment
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
            top: 190,
            child:
                _AdminCategoriesGlow(
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
                _AdminCategoriesGlow(
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

class _AdminCategoriesGlow
    extends StatelessWidget {
  final double size;
  final Color color;

  const _AdminCategoriesGlow({
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
    _adminCategoriesCardDecoration(
  double radius,
) {
  return BoxDecoration(
    color:
        Colors.white,
    borderRadius:
        BorderRadius.circular(
      radius,
    ),
    border:
        Border.all(
      color:
          const Color(
        0xFFDCE5D8,
      ),
    ),
    boxShadow: [
      BoxShadow(
        color:
            _adminCategoriesDark
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
