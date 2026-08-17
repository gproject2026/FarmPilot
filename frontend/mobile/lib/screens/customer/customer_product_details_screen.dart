import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_constants.dart';
import '../../providers/review_provider.dart';

const Color _detailsDarkGreen = Color(0xFF173F24);
const Color _detailsPrimaryGreen = Color(0xFF2F6B3D);
const Color _detailsLightGreen = Color(0xFFDDECB8);
const Color _detailsBackground = Color(0xFFF8FAF4);
const Color _detailsTextPrimary = Color(0xFF1D2C21);
const Color _detailsTextSecondary = Color(0xFF68756B);

class CustomerProductDetailsScreen extends StatefulWidget {
  final Map<String, dynamic> product;

  const CustomerProductDetailsScreen({
    super.key,
    required this.product,
  });

  @override
  State<CustomerProductDetailsScreen> createState() =>
      _CustomerProductDetailsScreenState();
}

class _CustomerProductDetailsScreenState
    extends State<CustomerProductDetailsScreen> {
  bool _reviewsLoadFailed = false;
  String? _reviewsLoadError;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback(
      (_) {
        _loadReviews();
      },
    );
  }

  Future<void> _loadReviews() async {
    final productId =
        widget.product['id']?.toString() ?? '';

    if (productId.isEmpty) {
      return;
    }

    if (mounted) {
      setState(() {
        _reviewsLoadFailed = false;
        _reviewsLoadError = null;
      });
    }

    final reviewProvider =
        Provider.of<ReviewProvider>(
      context,
      listen: false,
    );

    try {
      await reviewProvider.loadProductReviews(
        productId,
      );

      if (!mounted) {
        return;
      }

      setState(() {
        _reviewsLoadFailed = false;
        _reviewsLoadError = null;
      });
    } catch (e) {
      if (!mounted) {
        return;
      }

      setState(() {
        _reviewsLoadFailed = true;
        _reviewsLoadError =
            reviewProvider.errorMessage ??
                e.toString().replaceFirst(
                      'Exception: ',
                      '',
                    );
      });
    }
  }

  Future<void> _showAddReviewDialog() async {
    final productId =
        widget.product['id']?.toString() ?? '';

    if (productId.isEmpty) {
      return;
    }

    final reviewProvider =
        Provider.of<ReviewProvider>(
      context,
      listen: false,
    );

    final commentController =
        TextEditingController();

    var selectedRating = 5;
    var isSubmitting = false;
    String? dialogError;

    await showDialog<void>(
      context: context,
      barrierDismissible: !isSubmitting,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (
            context,
            setDialogState,
          ) {
            Future<void> submitReview() async {
              if (isSubmitting) {
                return;
              }

              setDialogState(() {
                isSubmitting = true;
                dialogError = null;
              });

              final success =
                  await reviewProvider.createReview(
                productId: productId,
                rating: selectedRating,
                comment: commentController.text,
              );

              if (!dialogContext.mounted) {
                return;
              }

              if (!success) {
                setDialogState(() {
                  isSubmitting = false;
                  dialogError =
                      reviewProvider.errorMessage ??
                          'Failed to submit review';
                });

                return;
              }

              Navigator.of(dialogContext).pop();

              if (!mounted) {
                return;
              }

              ScaffoldMessenger.of(context)
                ..hideCurrentSnackBar()
                ..showSnackBar(
                  const SnackBar(
                    content: Text(
                      'Review submitted successfully',
                    ),
                    backgroundColor:
                        _detailsPrimaryGreen,
                  ),
                );
            }

            return PopScope(
              canPop: !isSubmitting,
              child: AlertDialog(
                backgroundColor:
                    const Color(0xFFFFFEFA),
                shape: RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(
                    24,
                  ),
                ),
                title: const Row(
                  children: [
                    Icon(
                      Icons.rate_review_outlined,
                      color:
                          _detailsPrimaryGreen,
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    Text(
                      'Write a Review',
                    ),
                  ],
                ),
                content: SingleChildScrollView(
                  child: Column(
                    mainAxisSize:
                        MainAxisSize.min,
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Rating',
                        style: TextStyle(
                          fontWeight:
                              FontWeight.w700,
                          color:
                              _detailsTextPrimary,
                        ),
                      ),
                      const SizedBox(
                        height: 8,
                      ),
                      Row(
                        mainAxisAlignment:
                            MainAxisAlignment.center,
                        children: List.generate(
                          5,
                          (index) {
                            final star =
                                index + 1;

                            return IconButton(
                              onPressed:
                                  isSubmitting
                                      ? null
                                      : () {
                                          setDialogState(
                                            () {
                                              selectedRating =
                                                  star;
                                            },
                                          );
                                        },
                              icon: Icon(
                                star <= selectedRating
                                    ? Icons.star_rounded
                                    : Icons.star_border_rounded,
                                color: Colors.amber,
                                size: 34,
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(
                        height: 16,
                      ),
                      TextField(
                        controller:
                            commentController,
                        enabled:
                            !isSubmitting,
                        maxLines: 4,
                        decoration:
                            InputDecoration(
                          labelText:
                              'Comment (optional)',
                          hintText:
                              'Share your experience...',
                          filled: true,
                          fillColor:
                              Colors.white,
                          border:
                              OutlineInputBorder(
                            borderRadius:
                                BorderRadius.circular(
                              16,
                            ),
                          ),
                          enabledBorder:
                              OutlineInputBorder(
                            borderRadius:
                                BorderRadius.circular(
                              16,
                            ),
                            borderSide:
                                const BorderSide(
                              color:
                                  Color(
                                0xFFDDE6D8,
                              ),
                            ),
                          ),
                        ),
                      ),
                      if (dialogError != null) ...[
                        const SizedBox(
                          height: 12,
                        ),
                        Text(
                          dialogError!,
                          style:
                              const TextStyle(
                            color: Colors.red,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed:
                        isSubmitting
                            ? null
                            : () {
                                Navigator.of(
                                  dialogContext,
                                ).pop();
                              },
                    child:
                        const Text(
                      'Cancel',
                    ),
                  ),
                  ElevatedButton(
                    onPressed:
                        isSubmitting
                            ? null
                            : submitReview,
                    style:
                        ElevatedButton.styleFrom(
                      backgroundColor:
                          _detailsPrimaryGreen,
                      foregroundColor:
                          Colors.white,
                      elevation: 0,
                      shape:
                          RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(
                          12,
                        ),
                      ),
                    ),
                    child: isSubmitting
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child:
                                CircularProgressIndicator(
                              strokeWidth: 2,
                              color:
                                  Colors.white,
                            ),
                          )
                        : const Text(
                            'Submit',
                          ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );

    commentController.dispose();
  }

  @override
  Widget build(
    BuildContext context,
  ) {
    final product = widget.product;

    final name =
        product['name']?.toString() ??
            'Product';

    final description =
        product['description']?.toString() ??
            '';

    final imageUrl =
        product['imageUrl']?.toString();

    final unit =
        product['unit']?.toString() ?? '';

    final status =
        product['status']?.toString() ?? '';

    final quantity =
        int.tryParse(
          product['quantity']?.toString() ??
              '0',
        ) ??
            0;

    final price =
        double.tryParse(
          product['price']?.toString() ??
              '0',
        ) ??
            0.0;

    final categoryName =
        product['category'] is Map
            ? product['category']['name']
                    ?.toString() ??
                ''
            : '';

    final farmerName =
        product['farmer'] is Map
            ? product['farmer']['fullName']
                    ?.toString() ??
                ''
            : '';

    final isAvailable =
        quantity > 0 &&
            status == 'AVAILABLE';

    return Scaffold(
      backgroundColor:
          _detailsBackground,
      body: Stack(
        children: [
          const Positioned.fill(
            child:
                _ProductDetailsBackdrop(),
          ),
          RefreshIndicator(
            onRefresh:
                _loadReviews,
            color:
                _detailsPrimaryGreen,
            child:
                CustomScrollView(
              physics:
                  const AlwaysScrollableScrollPhysics(),
              slivers: [
                SliverToBoxAdapter(
                  child: _buildHeader(
                    name,
                  ),
                ),
                SliverToBoxAdapter(
                  child: LayoutBuilder(
                    builder: (
                      context,
                      constraints,
                    ) {
                      final isWide =
                          constraints.maxWidth >=
                              900;

                      return Padding(
                        padding:
                            EdgeInsets.fromLTRB(
                          isWide
                              ? 42
                              : 18,
                          isWide
                              ? 30
                              : 20,
                          isWide
                              ? 42
                              : 18,
                          50,
                        ),
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            isWide
                                ? Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Expanded(
                                        flex: 11,
                                        child:
                                            _buildProductImageCard(
                                          imageUrl,
                                        ),
                                      ),
                                      const SizedBox(
                                        width: 24,
                                      ),
                                      Expanded(
                                        flex: 9,
                                        child:
                                            _buildProductInfoCard(
                                          name:
                                              name,
                                          categoryName:
                                              categoryName,
                                          farmerName:
                                              farmerName,
                                          price:
                                              price,
                                          unit:
                                              unit,
                                          quantity:
                                              quantity,
                                          isAvailable:
                                              isAvailable,
                                        ),
                                      ),
                                    ],
                                  )
                                : Column(
                                    children: [
                                      _buildProductImageCard(
                                        imageUrl,
                                      ),
                                      const SizedBox(
                                        height: 18,
                                      ),
                                      _buildProductInfoCard(
                                        name:
                                            name,
                                        categoryName:
                                            categoryName,
                                        farmerName:
                                            farmerName,
                                        price:
                                            price,
                                        unit:
                                            unit,
                                        quantity:
                                            quantity,
                                        isAvailable:
                                            isAvailable,
                                      ),
                                    ],
                                  ),
                            if (description
                                .isNotEmpty) ...[
                              const SizedBox(
                                height: 24,
                              ),
                              _buildDescriptionCard(
                                description,
                              ),
                            ],
                            const SizedBox(
                              height: 28,
                            ),
                            _buildReviewsSection(),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(
    String productName,
  ) {
    return Container(
      padding:
          const EdgeInsets.fromLTRB(
        20,
        16,
        20,
        18,
      ),
      decoration:
          BoxDecoration(
        gradient:
            const LinearGradient(
          begin:
              Alignment.topLeft,
          end:
              Alignment.bottomRight,
          colors: [
            Color(0xFF123A22),
            Color(0xFF205A34),
            Color(0xFF2E6F40),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color:
                _detailsDarkGreen.withValues(
              alpha: 0.18,
            ),
            blurRadius: 24,
            offset:
                const Offset(
              0,
              8,
            ),
          ),
        ],
      ),
      child: SafeArea(
        bottom:
            false,
        child: Row(
          children: [
            Material(
              color:
                  Colors.white.withValues(
                alpha: 0.10,
              ),
              borderRadius:
                  BorderRadius.circular(
                14,
              ),
              child: InkWell(
                onTap: () {
                  Navigator.pop(
                    context,
                  );
                },
                borderRadius:
                    BorderRadius.circular(
                  14,
                ),
                child:
                    const SizedBox(
                  width: 44,
                  height: 44,
                  child:
                      Icon(
                    Icons.arrow_back_rounded,
                    color:
                        Colors.white,
                  ),
                ),
              ),
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
                    _detailsLightGreen,
                borderRadius:
                    BorderRadius.circular(
                  13,
                ),
              ),
              child:
                  const Icon(
                Icons.eco_rounded,
                color:
                    _detailsDarkGreen,
                size: 24,
              ),
            ),
            const SizedBox(
              width: 10,
            ),
            Expanded(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  const Text(
                    'FarmPilot',
                    style:
                        TextStyle(
                      color:
                          Colors.white,
                      fontSize: 18,
                      fontWeight:
                          FontWeight.w800,
                    ),
                  ),
                  const SizedBox(
                    height: 2,
                  ),
                  Text(
                    productName,
                    maxLines: 1,
                    overflow:
                        TextOverflow.ellipsis,
                    style:
                        TextStyle(
                      color:
                          Colors.white.withValues(
                        alpha: 0.78,
                      ),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductImageCard(
    String? imageUrl,
  ) {
    return Container(
      width:
          double.infinity,
      decoration:
          BoxDecoration(
        color:
            Colors.white,
        borderRadius:
            BorderRadius.circular(
          26,
        ),
        border:
            Border.all(
          color:
              const Color(
            0xFFDDE6D8,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color:
                _detailsDarkGreen.withValues(
              alpha:
                  0.055,
            ),
            blurRadius:
                22,
            offset:
                const Offset(
              0,
              8,
            ),
          ),
        ],
      ),
      clipBehavior:
          Clip.antiAlias,
      child: AspectRatio(
        aspectRatio:
            16 / 9,
        child: Container(
          color:
              const Color(
            0xFFF0F5EB,
          ),
          child: imageUrl != null &&
                  imageUrl.trim().isNotEmpty
              ? Image.network(
                  _buildImageUrl(
                    imageUrl,
                  ),
                  fit:
                      BoxFit.cover,
                  errorBuilder: (
                    context,
                    error,
                    stackTrace,
                  ) {
                    return const Center(
                      child:
                          Icon(
                        Icons.image_not_supported_outlined,
                        size: 70,
                        color:
                            Color(
                          0xFF9AA59B,
                        ),
                      ),
                    );
                  },
                )
              : const Center(
                  child:
                      Icon(
                    Icons.eco_outlined,
                    size: 80,
                    color:
                        _detailsPrimaryGreen,
                  ),
                ),
        ),
      ),
    );
  }

  Widget _buildProductInfoCard({
    required String name,
    required String categoryName,
    required String farmerName,
    required double price,
    required String unit,
    required int quantity,
    required bool isAvailable,
  }) {
    return Container(
      width:
          double.infinity,
      padding:
          const EdgeInsets.all(
        24,
      ),
      decoration:
          BoxDecoration(
        gradient:
            const LinearGradient(
          begin:
              Alignment.topLeft,
          end:
              Alignment.bottomRight,
          colors: [
            Color(0xFFFFFFFF),
            Color(0xFFFFFEFA),
          ],
        ),
        borderRadius:
            BorderRadius.circular(
          26,
        ),
        border:
            Border.all(
          color:
              const Color(
            0xFFDDE6D8,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color:
                _detailsDarkGreen.withValues(
              alpha:
                  0.05,
            ),
            blurRadius:
                20,
            offset:
                const Offset(
              0,
              7,
            ),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          if (categoryName
              .isNotEmpty)
            Container(
              padding:
                  const EdgeInsets.symmetric(
                horizontal: 11,
                vertical: 6,
              ),
              decoration:
                  BoxDecoration(
                color:
                    const Color(
                  0xFFEAF3DF,
                ),
                borderRadius:
                    BorderRadius.circular(
                  20,
                ),
              ),
              child:
                  Text(
                categoryName,
                style:
                    const TextStyle(
                  color:
                      _detailsPrimaryGreen,
                  fontSize: 12,
                  fontWeight:
                      FontWeight.w700,
                ),
              ),
            ),
          if (categoryName
              .isNotEmpty)
            const SizedBox(
              height: 14,
            ),
          Text(
            name,
            style:
                const TextStyle(
              color:
                  _detailsTextPrimary,
              fontSize: 28,
              fontWeight:
                  FontWeight.w800,
              letterSpacing: -0.6,
            ),
          ),
          const SizedBox(
            height: 14,
          ),
          Text(
            '${price.toStringAsFixed(2)} ₪'
            '${unit.isEmpty ? '' : ' / $unit'}',
            style:
                const TextStyle(
              color:
                  _detailsPrimaryGreen,
              fontSize: 24,
              fontWeight:
                  FontWeight.w800,
            ),
          ),
          const SizedBox(
            height: 18,
          ),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _InfoPill(
                icon:
                    isAvailable
                        ? Icons.check_circle_outline_rounded
                        : Icons.cancel_outlined,
                label:
                    isAvailable
                        ? 'Available: $quantity'
                        : 'Out of stock',
                background:
                    isAvailable
                        ? const Color(
                            0xFFEAF3DF,
                          )
                        : const Color(
                            0xFFFCE7E7,
                          ),
                foreground:
                    isAvailable
                        ? _detailsPrimaryGreen
                        : const Color(
                            0xFFB44F4F,
                          ),
              ),
              if (farmerName
                  .isNotEmpty)
                _InfoPill(
                  icon:
                      Icons.person_outline_rounded,
                  label:
                      'Farmer: $farmerName',
                  background:
                      const Color(
                    0xFFF1F3EF,
                  ),
                  foreground:
                      const Color(
                    0xFF5F6B61,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDescriptionCard(
    String description,
  ) {
    return Container(
      width:
          double.infinity,
      padding:
          const EdgeInsets.all(
        22,
      ),
      decoration:
          BoxDecoration(
        color:
            Colors.white,
        borderRadius:
            BorderRadius.circular(
          22,
        ),
        border:
            Border.all(
          color:
              const Color(
            0xFFDDE6D8,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color:
                _detailsDarkGreen.withValues(
              alpha:
                  0.04,
            ),
            blurRadius: 16,
            offset:
                const Offset(
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
          const Row(
            children: [
              Icon(
                Icons.description_outlined,
                color:
                    _detailsPrimaryGreen,
                size: 22,
              ),
              SizedBox(
                width: 9,
              ),
              Text(
                'Description',
                style:
                    TextStyle(
                  color:
                      _detailsTextPrimary,
                  fontSize: 18,
                  fontWeight:
                      FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(
            height: 12,
          ),
          Text(
            description,
            style:
                const TextStyle(
              color:
                  _detailsTextSecondary,
              fontSize: 14,
              height: 1.55,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewsSection() {
    return Consumer<ReviewProvider>(
      builder: (
        context,
        reviewProvider,
        child,
      ) {
        return Container(
          width:
              double.infinity,
          padding:
              const EdgeInsets.all(
            22,
          ),
          decoration:
              BoxDecoration(
            gradient:
                const LinearGradient(
              begin:
                  Alignment.topLeft,
              end:
                  Alignment.bottomRight,
              colors: [
                Color(0xFFFFFFFF),
                Color(0xFFFFFEFA),
              ],
            ),
            borderRadius:
                BorderRadius.circular(
              24,
            ),
            border:
                Border.all(
              color:
                  const Color(
                0xFFDDE6D8,
              ),
            ),
            boxShadow: [
              BoxShadow(
                color:
                    _detailsDarkGreen.withValues(
                  alpha:
                      0.045,
                ),
                blurRadius: 18,
                offset:
                    const Offset(
                  0,
                  7,
                ),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Wrap(
                alignment:
                    WrapAlignment.spaceBetween,
                crossAxisAlignment:
                    WrapCrossAlignment.center,
                spacing: 14,
                runSpacing: 12,
                children: [
                  const Row(
                    mainAxisSize:
                        MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.star_rounded,
                        color:
                            Colors.amber,
                        size: 25,
                      ),
                      SizedBox(
                        width: 9,
                      ),
                      Text(
                        'Reviews',
                        style:
                            TextStyle(
                          color:
                              _detailsTextPrimary,
                          fontSize: 22,
                          fontWeight:
                              FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                  ElevatedButton.icon(
                    onPressed:
                        reviewProvider.isSubmitting
                            ? null
                            : _showAddReviewDialog,
                    style:
                        ElevatedButton.styleFrom(
                      backgroundColor:
                          _detailsPrimaryGreen,
                      foregroundColor:
                          Colors.white,
                      elevation: 0,
                      padding:
                          const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 13,
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
                        const Icon(
                      Icons.rate_review_outlined,
                      size: 18,
                    ),
                    label:
                        const Text(
                      'Write a Review',
                    ),
                  ),
                ],
              ),
              if (reviewProvider.reviews.isNotEmpty) ...[
                const SizedBox(
                  height: 16,
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 11,
                  ),
                  decoration:
                      BoxDecoration(
                    color:
                        const Color(
                      0xFFFFF8DF,
                    ),
                    borderRadius:
                        BorderRadius.circular(
                      16,
                    ),
                  ),
                  child: Row(
                    mainAxisSize:
                        MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.star_rounded,
                        color:
                            Colors.amber,
                      ),
                      const SizedBox(
                        width: 6,
                      ),
                      Text(
                        reviewProvider.averageRating
                            .toStringAsFixed(
                          1,
                        ),
                        style:
                            const TextStyle(
                          color:
                              _detailsTextPrimary,
                          fontSize: 18,
                          fontWeight:
                              FontWeight.w800,
                        ),
                      ),
                      const SizedBox(
                        width: 7,
                      ),
                      Text(
                        '(${reviewProvider.reviews.length} '
                        '${reviewProvider.reviews.length == 1 ? 'review' : 'reviews'})',
                        style:
                            const TextStyle(
                          color:
                              _detailsTextSecondary,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(
                height: 18,
              ),
              if (reviewProvider.isLoading)
                const Center(
                  child:
                      CircularProgressIndicator(
                    color:
                        _detailsPrimaryGreen,
                  ),
                )
              else if (_reviewsLoadFailed)
                _buildReviewError()
              else if (reviewProvider.reviews.isEmpty)
                _buildEmptyReviews()
              else
                ...reviewProvider.reviews.map(
                  (review) {
                    if (review is! Map) {
                      return const SizedBox
                          .shrink();
                    }

                    return _buildReviewCard(
                      Map<String, dynamic>.from(
                        review,
                      ),
                    );
                  },
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildReviewError() {
    return Container(
      width:
          double.infinity,
      padding:
          const EdgeInsets.all(
        18,
      ),
      decoration:
          BoxDecoration(
        color:
            const Color(
          0xFFFCE7E7,
        ),
        borderRadius:
            BorderRadius.circular(
          16,
        ),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.error_outline_rounded,
            color:
                Color(
              0xFFB44F4F,
            ),
          ),
          const SizedBox(
            height: 8,
          ),
          Text(
            _reviewsLoadError ??
                'Failed to load reviews',
            textAlign:
                TextAlign.center,
          ),
          const SizedBox(
            height: 8,
          ),
          TextButton(
            onPressed:
                _loadReviews,
            child:
                const Text(
              'Try Again',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyReviews() {
    return Container(
      width:
          double.infinity,
      padding:
          const EdgeInsets.symmetric(
        vertical: 30,
        horizontal: 16,
      ),
      decoration:
          BoxDecoration(
        color:
            const Color(
          0xFFF7F9F4,
        ),
        borderRadius:
            BorderRadius.circular(
          18,
        ),
      ),
      child:
          const Column(
        children: [
          Icon(
            Icons.rate_review_outlined,
            size: 46,
            color:
                Color(
              0xFF99A39A,
            ),
          ),
          SizedBox(
            height: 10,
          ),
          Text(
            'No reviews yet',
            style:
                TextStyle(
              color:
                  _detailsTextPrimary,
              fontSize: 16,
              fontWeight:
                  FontWeight.w800,
            ),
          ),
          SizedBox(
            height: 4,
          ),
          Text(
            'Be the first customer to review this product.',
            textAlign:
                TextAlign.center,
            style:
                TextStyle(
              color:
                  _detailsTextSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewCard(
    Map<String, dynamic> review,
  ) {
    final rating =
        int.tryParse(
          review['rating']?.toString() ??
              '0',
        ) ??
            0;

    final comment =
        review['comment']?.toString() ??
            '';

    final customer =
        review['customer'];

    final customerName =
        customer is Map
            ? customer['fullName']
                    ?.toString() ??
                'Customer'
            : 'Customer';

    final createdAt =
        review['createdAt']?.toString();

    return Container(
      margin:
          const EdgeInsets.only(
        bottom: 12,
      ),
      padding:
          const EdgeInsets.all(
        16,
      ),
      decoration:
          BoxDecoration(
        color:
            Colors.white,
        borderRadius:
            BorderRadius.circular(
          18,
        ),
        border:
            Border.all(
          color:
              const Color(
            0xFFE1E8DD,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor:
                    const Color(
                  0xFFEAF3DF,
                ),
                child:
                    Text(
                  customerName.trim().isNotEmpty
                      ? customerName
                          .trim()[0]
                          .toUpperCase()
                      : 'C',
                  style:
                      const TextStyle(
                    color:
                        _detailsPrimaryGreen,
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(
                width: 10,
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      customerName,
                      style:
                          const TextStyle(
                        color:
                            _detailsTextPrimary,
                        fontWeight:
                            FontWeight.w700,
                      ),
                    ),
                    if (createdAt != null)
                      Text(
                        _formatDate(
                          createdAt,
                        ),
                        style:
                            const TextStyle(
                          fontSize: 11,
                          color:
                              _detailsTextSecondary,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(
            height: 10,
          ),
          Row(
            children:
                List.generate(
              5,
              (index) {
                return Icon(
                  index < rating
                      ? Icons.star_rounded
                      : Icons.star_border_rounded,
                  color:
                      Colors.amber,
                  size: 20,
                );
              },
            ),
          ),
          if (comment.trim().isNotEmpty) ...[
            const SizedBox(
              height: 10,
            ),
            Text(
              comment,
              style:
                  const TextStyle(
                color:
                    _detailsTextPrimary,
                height: 1.4,
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _formatDate(
    String value,
  ) {
    final date =
        DateTime.tryParse(
      value,
    );

    if (date == null) {
      return '';
    }

    final localDate =
        date.toLocal();

    final day =
        localDate.day
            .toString()
            .padLeft(
              2,
              '0',
            );

    final month =
        localDate.month
            .toString()
            .padLeft(
              2,
              '0',
            );

    return '$day/$month/${localDate.year}';
  }

  String _buildImageUrl(
    String imageUrl,
  ) {
    final trimmedUrl =
        imageUrl.trim();

    if (trimmedUrl.isEmpty) {
      return '';
    }

    if (trimmedUrl.startsWith(
          'http://localhost:3000',
        ) ||
        trimmedUrl.startsWith(
          'http://127.0.0.1:3000',
        )) {
      return trimmedUrl.replaceFirst(
        RegExp(
          r'http://(localhost|127\.0\.0\.1):3000',
        ),
        AppConstants.baseUrl,
      );
    }

    if (trimmedUrl.startsWith(
          'http://',
        ) ||
        trimmedUrl.startsWith(
          'https://',
        )) {
      return trimmedUrl;
    }

    final normalizedPath =
        trimmedUrl.startsWith('/')
            ? trimmedUrl
            : '/$trimmedUrl';

    return '${AppConstants.baseUrl}$normalizedPath';
  }
}

class _InfoPill
    extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color background;
  final Color foreground;

  const _InfoPill({
    required this.icon,
    required this.label,
    required this.background,
    required this.foreground,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    return Container(
      padding:
          const EdgeInsets.symmetric(
        horizontal: 11,
        vertical: 8,
      ),
      decoration:
          BoxDecoration(
        color:
            background,
        borderRadius:
            BorderRadius.circular(
          18,
        ),
      ),
      child: Row(
        mainAxisSize:
            MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 17,
            color:
                foreground,
          ),
          const SizedBox(
            width: 6,
          ),
          Text(
            label,
            style:
                TextStyle(
              color:
                  foreground,
              fontSize: 12,
              fontWeight:
                  FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _ProductDetailsBackdrop
    extends StatelessWidget {
  const _ProductDetailsBackdrop();

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
                    Alignment.topCenter,
                end:
                    Alignment.bottomCenter,
                colors: [
                  Color(
                    0xFFF8FAF4,
                  ),
                  Color(
                    0xFFFFFCF5,
                  ),
                  Color(
                    0xFFF4F8ED,
                  ),
                ],
                stops: [
                  0.0,
                  0.50,
                  1.0,
                ],
              ),
            ),
          ),
          PositionedDirectional(
            end: -180,
            top: 200,
            child: Container(
              width: 460,
              height: 460,
              decoration:
                  BoxDecoration(
                shape:
                    BoxShape.circle,
                gradient:
                    RadialGradient(
                  colors: [
                    const Color(
                      0xFFCFE6B4,
                    ).withValues(
                      alpha: 0.28,
                    ),
                    const Color(
                      0xFFCFE6B4,
                    ).withValues(
                      alpha: 0.0,
                    ),
                  ],
                ),
              ),
            ),
          ),
          PositionedDirectional(
            start: -190,
            bottom: -220,
            child: Container(
              width: 520,
              height: 520,
              decoration:
                  BoxDecoration(
                shape:
                    BoxShape.circle,
                gradient:
                    RadialGradient(
                  colors: [
                    const Color(
                      0xFFE7DFAF,
                    ).withValues(
                      alpha: 0.22,
                    ),
                    const Color(
                      0xFFE7DFAF,
                    ).withValues(
                      alpha: 0.0,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
