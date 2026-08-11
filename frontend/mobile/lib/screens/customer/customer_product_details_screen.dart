import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_constants.dart';
import '../../providers/review_provider.dart';

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
                    backgroundColor: Colors.green,
                  ),
                );
            }

            return PopScope(
              canPop: !isSubmitting,
              child: AlertDialog(
                title: const Text(
                  'Write a Review',
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
                              FontWeight.bold,
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
                                    ? Icons.star
                                    : Icons.star_border,
                                color: Colors.amber,
                                size: 32,
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
                            const InputDecoration(
                          labelText:
                              'Comment (optional)',
                          hintText:
                              'Share your experience...',
                          border:
                              OutlineInputBorder(),
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
                    child: const Text(
                      'Cancel',
                    ),
                  ),
                  ElevatedButton(
                    onPressed:
                        isSubmitting
                            ? null
                            : submitReview,
                    child: isSubmitting
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child:
                                CircularProgressIndicator(
                              strokeWidth: 2,
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
  Widget build(BuildContext context) {
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
          const Color(0xFFF5F7F4),
      appBar: AppBar(
        title: Text(
          name,
        ),
        backgroundColor:
            Colors.green,
        foregroundColor:
            Colors.white,
      ),
      body: RefreshIndicator(
        onRefresh: _loadReviews,
        child: ListView(
          padding:
              const EdgeInsets.all(16),
          children: [
            _buildProductImage(
              imageUrl,
            ),
            const SizedBox(
              height: 18,
            ),
            Text(
              name,
              style:
                  const TextStyle(
                fontSize: 24,
                fontWeight:
                    FontWeight.bold,
              ),
            ),
            if (categoryName
                .isNotEmpty) ...[
              const SizedBox(
                height: 6,
              ),
              Text(
                categoryName,
                style: TextStyle(
                  fontSize: 14,
                  color:
                      Colors.green.shade700,
                  fontWeight:
                      FontWeight.w600,
                ),
              ),
            ],
            const SizedBox(
              height: 12,
            ),
            Text(
              '${price.toStringAsFixed(2)} ₪'
              '${unit.isEmpty ? '' : ' / $unit'}',
              style:
                  const TextStyle(
                color: Colors.green,
                fontSize: 22,
                fontWeight:
                    FontWeight.bold,
              ),
            ),
            const SizedBox(
              height: 8,
            ),
            Row(
              children: [
                Icon(
                  isAvailable
                      ? Icons
                          .check_circle_outline
                      : Icons
                          .cancel_outlined,
                  color: isAvailable
                      ? Colors.green
                      : Colors.red,
                  size: 20,
                ),
                const SizedBox(
                  width: 6,
                ),
                Text(
                  isAvailable
                      ? 'Available: $quantity'
                      : 'Out of stock',
                  style: TextStyle(
                    color: isAvailable
                        ? Colors
                            .grey.shade700
                        : Colors.red,
                    fontWeight:
                        FontWeight.w600,
                  ),
                ),
              ],
            ),
            if (farmerName
                .isNotEmpty) ...[
              const SizedBox(
                height: 12,
              ),
              Row(
                children: [
                  const Icon(
                    Icons.person_outline,
                    size: 20,
                  ),
                  const SizedBox(
                    width: 6,
                  ),
                  Expanded(
                    child: Text(
                      'Farmer: $farmerName',
                    ),
                  ),
                ],
              ),
            ],
            if (description
                .isNotEmpty) ...[
              const SizedBox(
                height: 18,
              ),
              const Text(
                'Description',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight:
                      FontWeight.bold,
                ),
              ),
              const SizedBox(
                height: 6,
              ),
              Text(
                description,
                style: TextStyle(
                  fontSize: 14,
                  height: 1.5,
                  color:
                      Colors.grey.shade800,
                ),
              ),
            ],
            const SizedBox(
              height: 24,
            ),
            const Divider(),
            const SizedBox(
              height: 12,
            ),
            _buildReviewsSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildProductImage(
    String? imageUrl,
  ) {
    return ClipRRect(
      borderRadius:
          BorderRadius.circular(18),
      child: Container(
        height: 260,
        width: double.infinity,
        color: Colors.green.shade50,
        child: imageUrl != null &&
                imageUrl.trim().isNotEmpty
            ? Image.network(
                _buildImageUrl(
                  imageUrl,
                ),
                fit: BoxFit.cover,
                errorBuilder: (
                  context,
                  error,
                  stackTrace,
                ) {
                  return const Center(
                    child: Icon(
                      Icons
                          .image_not_supported_outlined,
                      size: 70,
                      color: Colors.grey,
                    ),
                  );
                },
              )
            : const Center(
                child: Icon(
                  Icons.eco_outlined,
                  size: 80,
                  color: Colors.green,
                ),
              ),
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
        return Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Expanded(
                  child: Text(
                    'Reviews',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),
                ),
                ElevatedButton.icon(
                  onPressed:
                      reviewProvider
                              .isSubmitting
                          ? null
                          : _showAddReviewDialog,
                  icon: const Icon(
                    Icons.rate_review_outlined,
                    size: 18,
                  ),
                  label: const Text(
                    'Add Review',
                  ),
                ),
              ],
            ),
            const SizedBox(
              height: 12,
            ),
            if (reviewProvider
                .reviews.isNotEmpty)
              Row(
                children: [
                  const Icon(
                    Icons.star,
                    color: Colors.amber,
                  ),
                  const SizedBox(
                    width: 6,
                  ),
                  Text(
                    reviewProvider
                        .averageRating
                        .toStringAsFixed(1),
                    style:
                        const TextStyle(
                      fontSize: 18,
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),
                  const SizedBox(
                    width: 6,
                  ),
                  Text(
                    '(${reviewProvider.reviews.length} '
                    '${reviewProvider.reviews.length == 1 ? 'review' : 'reviews'})',
                    style: TextStyle(
                      color:
                          Colors.grey.shade700,
                    ),
                  ),
                ],
              ),
            const SizedBox(
              height: 14,
            ),
            if (reviewProvider.isLoading)
              const Center(
                child:
                    CircularProgressIndicator(),
              )
            else if (_reviewsLoadFailed)
              _buildReviewError()
            else if (reviewProvider
                .reviews.isEmpty)
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
        );
      },
    );
  }

  Widget _buildReviewError() {
    return Container(
      width: double.infinity,
      padding:
          const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius:
            BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.error_outline,
            color: Colors.red,
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
            onPressed: _loadReviews,
            child: const Text(
              'Try Again',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyReviews() {
    return Container(
      width: double.infinity,
      padding:
          const EdgeInsets.symmetric(
        vertical: 28,
        horizontal: 16,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(14),
      ),
      child: const Column(
        children: [
          Icon(
            Icons.rate_review_outlined,
            size: 45,
            color: Colors.grey,
          ),
          SizedBox(
            height: 10,
          ),
          Text(
            'No reviews yet',
            style: TextStyle(
              fontSize: 16,
              fontWeight:
                  FontWeight.bold,
            ),
          ),
          SizedBox(
            height: 4,
          ),
          Text(
            'Be the first customer to review this product.',
            textAlign:
                TextAlign.center,
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

    return Card(
      margin:
          const EdgeInsets.only(
        bottom: 12,
      ),
      elevation: 1,
      child: Padding(
        padding:
            const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor:
                      Colors.green.shade100,
                  child: Text(
                    customerName
                            .trim()
                            .isNotEmpty
                        ? customerName
                            .trim()[0]
                            .toUpperCase()
                        : 'C',
                    style:
                        const TextStyle(
                      color: Colors.green,
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
                        CrossAxisAlignment
                            .start,
                    children: [
                      Text(
                        customerName,
                        style:
                            const TextStyle(
                          fontWeight:
                              FontWeight
                                  .bold,
                        ),
                      ),
                      if (createdAt !=
                          null)
                        Text(
                          _formatDate(
                            createdAt,
                          ),
                          style:
                              TextStyle(
                            fontSize: 11,
                            color: Colors
                                .grey
                                .shade600,
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
                        ? Icons.star
                        : Icons
                            .star_border,
                    color: Colors.amber,
                    size: 20,
                  );
                },
              ),
            ),
            if (comment
                .trim()
                .isNotEmpty) ...[
              const SizedBox(
                height: 10,
              ),
              Text(
                comment,
                style:
                    const TextStyle(
                  height: 1.4,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _formatDate(
    String value,
  ) {
    final date =
        DateTime.tryParse(value);

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