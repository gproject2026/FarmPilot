import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../l10n/generated/app_localizations.dart';
import '../../providers/supplier_category_provider.dart';

class SupplierCategoriesScreen extends StatefulWidget {
  const SupplierCategoriesScreen({super.key});

  @override
  State<SupplierCategoriesScreen> createState() =>
      _SupplierCategoriesScreenState();
}

class _SupplierCategoriesScreenState
    extends State<SupplierCategoriesScreen> {
  static const Color _primary = Color(0xFF2F6B3D);
  static const Color _darkGreen = Color(0xFF1F5130);
  static const Color _lightGreen = Color(0xFFEAF3E7);
  static const Color _text = Color(0xFF1D2A20);
  static const Color _muted = Color(0xFF6D786F);

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback(
      (_) {
        _loadCategories();
      },
    );
  }

  Future<void> _loadCategories() async {
    await context
        .read<SupplierCategoryProvider>()
        .loadSupplierCategories();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    final categoryProvider =
        context.watch<SupplierCategoryProvider>();

    final categories =
        categoryProvider.supplierCategories;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F9F4),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: _darkGreen,
        foregroundColor: Colors.white,
        title: Text(
          l10n.supplierCategories,
          style: const TextStyle(
            fontWeight: FontWeight.w800,
          ),
        ),
        actions: [
          IconButton(
            tooltip: l10n.refresh,
            onPressed: categoryProvider.isLoading
                ? null
                : _loadCategories,
            icon: const Icon(
              Icons.refresh_rounded,
            ),
          ),
          const SizedBox(
            width: 6,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadCategories,
        color: _primary,
        child: _buildBody(
          l10n,
          categoryProvider,
          categories,
        ),
      ),
    );
  }

  Widget _buildBody(
    AppLocalizations l10n,
    SupplierCategoryProvider categoryProvider,
    List categories,
  ) {
    if (categoryProvider.isLoading &&
        categories.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(
          color: _primary,
        ),
      );
    }

    if (categoryProvider.errorMessage != null &&
        categories.isEmpty) {
      return _buildErrorState(
        l10n,
        categoryProvider.errorMessage!,
      );
    }

    if (categories.isEmpty) {
      return _buildEmptyState(
        l10n,
      );
    }

    return LayoutBuilder(
      builder: (
        context,
        constraints,
      ) {
        final isWide =
            constraints.maxWidth >= 900;

        return ListView(
          physics:
              const AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.symmetric(
            horizontal: isWide ? 32 : 18,
            vertical: 22,
          ),
          children: [
            _buildHeader(
              l10n,
              categories.length,
              categoryProvider.isLoading,
            ),
            const SizedBox(
              height: 22,
            ),
            _buildCategoriesGrid(
              l10n,
              categories,
              constraints.maxWidth,
            ),
            const SizedBox(
              height: 24,
            ),
          ],
        );
      },
    );
  }

  Widget _buildHeader(
    AppLocalizations l10n,
    int categoryCount,
    bool isRefreshing,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(
        24,
      ),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: AlignmentDirectional.centerStart,
          end: AlignmentDirectional.centerEnd,
          colors: [
            Color(0xFF245D35),
            Color(0xFF397B48),
          ],
        ),
        borderRadius: BorderRadius.circular(
          24,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x16000000),
            blurRadius: 18,
            offset: Offset(
              0,
              7,
            ),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 62,
            height: 62,
            decoration: BoxDecoration(
              color: Colors.white.withValues(
                alpha: 0.13,
              ),
              borderRadius: BorderRadius.circular(
                18,
              ),
            ),
            child: const Icon(
              Icons.category_outlined,
              color: Colors.white,
              size: 32,
            ),
          ),
          const SizedBox(
            width: 18,
          ),
          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.supplierCategories,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 23,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(
                  height: 5,
                ),
                Text(
                  l10n.browseSupplierCategories,
                  style: TextStyle(
                    color: Colors.white.withValues(
                      alpha: 0.82,
                    ),
                    fontSize: 13,
                    height: 1.4,
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(
                    horizontal: 11,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(
                      alpha: 0.13,
                    ),
                    borderRadius:
                        BorderRadius.circular(
                      20,
                    ),
                  ),
                  child: Text(
                    categoryCount.toString(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (isRefreshing)
            const Padding(
              padding: EdgeInsetsDirectional.only(
                start: 12,
              ),
              child: SizedBox(
                width: 22,
                height: 22,
                child:
                    CircularProgressIndicator(
                  strokeWidth: 2.2,
                  color: Colors.white,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCategoriesGrid(
    AppLocalizations l10n,
    List categories,
    double availableWidth,
  ) {
    final columns = availableWidth >= 1150
        ? 3
        : availableWidth >= 700
            ? 2
            : 1;

    const spacing = 16.0;

    final horizontalPadding =
        availableWidth >= 900 ? 64.0 : 36.0;

    final usableWidth =
        availableWidth - horizontalPadding;

    final cardWidth =
        (usableWidth -
                (spacing * (columns - 1))) /
            columns;

    return Wrap(
      spacing: spacing,
      runSpacing: spacing,
      children: categories.map<Widget>(
        (rawCategory) {
          final category =
              Map<String, dynamic>.from(
            rawCategory as Map,
          );

          return SizedBox(
            width: cardWidth,
            child: _buildCategoryCard(
              l10n,
              category,
            ),
          );
        },
      ).toList(),
    );
  }

  Widget _buildCategoryCard(
    AppLocalizations l10n,
    Map<String, dynamic> category,
  ) {
    final name = _localizedName(
      category,
    );

    final description =
        _localizedDescription(
      category,
    );

    final productCount =
        _productCount(
      category,
    );

    return Container(
      constraints: const BoxConstraints(
        minHeight: 205,
      ),
      padding: const EdgeInsets.all(
        20,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(
          22,
        ),
        border: Border.all(
          color: const Color(
            0xFFE1E8DE,
          ),
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(
              0x0A000000,
            ),
            blurRadius: 16,
            offset: Offset(
              0,
              6,
            ),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Container(
                width: 54,
                height: 54,
                decoration: BoxDecoration(
                  color: _lightGreen,
                  borderRadius:
                      BorderRadius.circular(
                    16,
                  ),
                ),
                child: const Icon(
                  Icons.eco_outlined,
                  color: _primary,
                  size: 27,
                ),
              ),
              const SizedBox(
                width: 14,
              ),
              Expanded(
                child: Padding(
                  padding:
                      const EdgeInsets.only(
                    top: 5,
                  ),
                  child: Text(
                    name.isEmpty
                        ? l10n.category
                        : name,
                    maxLines: 2,
                    overflow:
                        TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: _text,
                      fontSize: 18,
                      height: 1.25,
                      fontWeight:
                          FontWeight.w800,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(
            height: 17,
          ),
          Row(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              const Icon(
                Icons.notes_rounded,
                size: 18,
                color: _primary,
              ),
              const SizedBox(
                width: 7,
              ),
              Expanded(
                child: Text(
                  description.isEmpty
                      ? l10n.noData
                      : description,
                  maxLines: 3,
                  overflow:
                      TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: _muted,
                    fontSize: 13,
                    height: 1.5,
                  ),
                ),
              ),
            ],
          ),

          // Spacer removed because this card is
          // inside a Wrap with unbounded height.
          const SizedBox(
            height: 20,
          ),

          Container(
            width: double.infinity,
            padding:
                const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 12,
            ),
            decoration: BoxDecoration(
              color: const Color(
                0xFFF5F8F2,
              ),
              borderRadius:
                  BorderRadius.circular(
                14,
              ),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.inventory_2_outlined,
                  size: 18,
                  color: _primary,
                ),
                const SizedBox(
                  width: 8,
                ),
                Expanded(
                  child: Text(
                    l10n.productsCount(
                      productCount,
                    ),
                    style: const TextStyle(
                      color: _darkGreen,
                      fontSize: 12.5,
                      fontWeight:
                          FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(
    AppLocalizations l10n,
  ) {
    return ListView(
      physics:
          const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(
        24,
      ),
      children: [
        const SizedBox(
          height: 80,
        ),
        Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: 480,
            ),
            child: Container(
              padding: const EdgeInsets.all(
                30,
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius:
                    BorderRadius.circular(
                  24,
                ),
                border: Border.all(
                  color: const Color(
                    0xFFE1E8DE,
                  ),
                ),
              ),
              child: Column(
                children: [
                  Container(
                    width: 84,
                    height: 84,
                    decoration: BoxDecoration(
                      color: _lightGreen,
                      borderRadius:
                          BorderRadius.circular(
                        24,
                      ),
                    ),
                    child: const Icon(
                      Icons.category_outlined,
                      size: 42,
                      color: _primary,
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Text(
                    l10n
                        .noSupplierCategoriesFound,
                    textAlign:
                        TextAlign.center,
                    style: const TextStyle(
                      color: _text,
                      fontSize: 20,
                      fontWeight:
                          FontWeight.w800,
                    ),
                  ),
                  const SizedBox(
                    height: 8,
                  ),
                  Text(
                    l10n
                        .browseSupplierCategories,
                    textAlign:
                        TextAlign.center,
                    style: const TextStyle(
                      color: _muted,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildErrorState(
    AppLocalizations l10n,
    String message,
  ) {
    return ListView(
      physics:
          const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(
        24,
      ),
      children: [
        const SizedBox(
          height: 90,
        ),
        Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: 480,
            ),
            child: Container(
              padding: const EdgeInsets.all(
                28,
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius:
                    BorderRadius.circular(
                  22,
                ),
                border: Border.all(
                  color: const Color(
                    0xFFE1E8DE,
                  ),
                ),
              ),
              child: Column(
                children: [
                  const Icon(
                    Icons.error_outline_rounded,
                    size: 50,
                    color: Color(
                      0xFFC8433A,
                    ),
                  ),
                  const SizedBox(
                    height: 16,
                  ),
                  Text(
                    message,
                    textAlign:
                        TextAlign.center,
                    style: const TextStyle(
                      color: _muted,
                      height: 1.45,
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  ElevatedButton.icon(
                    onPressed:
                        _loadCategories,
                    icon: const Icon(
                      Icons.refresh_rounded,
                    ),
                    label: Text(
                      l10n.tryAgain,
                    ),
                    style:
                        ElevatedButton.styleFrom(
                      backgroundColor:
                          _primary,
                      foregroundColor:
                          Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  String _localizedName(
    Map<String, dynamic> category,
  ) {
    final isArabic =
        Localizations.localeOf(
              context,
            ).languageCode ==
            'ar';

    final primary = isArabic
        ? category['nameAr']
        : category['nameEn'];

    final secondary = isArabic
        ? category['nameEn']
        : category['nameAr'];

    return _firstText(
      [
        primary,
        category['name'],
        secondary,
      ],
    );
  }

  String _localizedDescription(
    Map<String, dynamic> category,
  ) {
    final isArabic =
        Localizations.localeOf(
              context,
            ).languageCode ==
            'ar';

    final primary = isArabic
        ? category['descriptionAr']
        : category['descriptionEn'];

    final secondary = isArabic
        ? category['descriptionEn']
        : category['descriptionAr'];

    return _firstText(
      [
        primary,
        category['description'],
        secondary,
      ],
    );
  }

  String _firstText(
    List<dynamic> values,
  ) {
    for (final value in values) {
      final text =
          value?.toString().trim() ?? '';

      if (text.isNotEmpty) {
        return text;
      }
    }

    return '';
  }

  int _productCount(
    Map<String, dynamic> category,
  ) {
    final rawCount =
        category['_count'];

    if (rawCount is Map) {
      final products =
          rawCount['products'];

      if (products is int) {
        return products;
      }

      return int.tryParse(
            products?.toString() ?? '',
          ) ??
          0;
    }

    return 0;
  }
}