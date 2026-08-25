import 'package:flutter/material.dart';

import '../services/review_service.dart';

class ReviewProvider extends ChangeNotifier {
  final ReviewService reviewService = ReviewService();

  bool isLoading = false;
  bool isSubmitting = false;

  List<dynamic> reviews = [];

  String? errorMessage;

  String? _currentProductId;

  final Map<String, double> _averageRatings = {};
  final Map<String, int> _reviewCounts = {};

  double averageRatingFor(String productId) {
    return _averageRatings[productId] ?? 0;
  }

  int reviewCountFor(String productId) {
    return _reviewCounts[productId] ?? 0;
  }

  Future<void> loadProductReviews(String productId) async {
    if (productId.isEmpty) {
      return;
    }

    isLoading = true;
    errorMessage = null;
    _currentProductId = productId;
    notifyListeners();

    try {
      reviews = await reviewService.getProductReviews(productId);

      _updateProductRating(productId, reviews);
    } catch (e) {
      errorMessage = _cleanErrorMessage(e);
      rethrow;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadMarketplaceRatings(List<String> productIds) async {
    final uniqueIds = productIds
        .where((id) => id.trim().isNotEmpty)
        .toSet()
        .toList();

    if (uniqueIds.isEmpty) {
      return;
    }

    final idsToLoad = uniqueIds
        .where((id) => !_averageRatings.containsKey(id))
        .toList();

    if (idsToLoad.isEmpty) {
      return;
    }

    try {
      await Future.wait(
        idsToLoad.map((productId) async {
          try {
            final productReviews = await reviewService.getProductReviews(
              productId,
            );

            _updateProductRating(productId, productReviews);
          } catch (_) {
            _averageRatings[productId] = 0;
            _reviewCounts[productId] = 0;
          }
        }),
      );

      notifyListeners();
    } catch (_) {}
  }

  Future<bool> createReview({
    required String productId,
    required int rating,
    String? comment,
  }) async {
    if (productId.isEmpty) {
      return false;
    }

    isSubmitting = true;
    errorMessage = null;
    notifyListeners();

    try {
      final newReview = await reviewService.createReview(
        productId: productId,
        rating: rating,
        comment: comment,
      );

      reviews.insert(0, newReview);

      _currentProductId = productId;

      _updateProductRating(productId, reviews);

      return true;
    } catch (e) {
      errorMessage = _cleanErrorMessage(e);

      return false;
    } finally {
      isSubmitting = false;
      notifyListeners();
    }
  }

  Future<bool> deleteReview(String reviewId) async {
    if (reviewId.isEmpty) {
      return false;
    }

    errorMessage = null;

    try {
      await reviewService.deleteReview(reviewId);

      reviews.removeWhere((review) {
        if (review is! Map) {
          return false;
        }

        final reviewMap = Map<String, dynamic>.from(review);

        return reviewMap['id']?.toString() == reviewId;
      });

      final productId = _currentProductId;

      if (productId != null && productId.isNotEmpty) {
        _updateProductRating(productId, reviews);
      }

      notifyListeners();

      return true;
    } catch (e) {
      errorMessage = _cleanErrorMessage(e);
      notifyListeners();

      return false;
    }
  }

  double get averageRating {
    if (reviews.isEmpty) {
      return 0;
    }

    var total = 0;
    var count = 0;

    for (final review in reviews) {
      if (review is! Map) {
        continue;
      }

      final reviewMap = Map<String, dynamic>.from(review);

      final rating = int.tryParse(reviewMap['rating']?.toString() ?? '');

      if (rating == null) {
        continue;
      }

      total += rating;
      count++;
    }

    if (count == 0) {
      return 0;
    }

    return total / count;
  }

  void clearReviews() {
    reviews = [];
    errorMessage = null;
    _currentProductId = null;
    notifyListeners();
  }

  void clearMarketplaceRatings() {
    _averageRatings.clear();
    _reviewCounts.clear();
    notifyListeners();
  }

  void _updateProductRating(String productId, List<dynamic> productReviews) {
    var total = 0;
    var count = 0;

    for (final review in productReviews) {
      if (review is! Map) {
        continue;
      }

      final reviewMap = Map<String, dynamic>.from(review);

      final rating = int.tryParse(reviewMap['rating']?.toString() ?? '');

      if (rating == null) {
        continue;
      }

      total += rating;
      count++;
    }

    _reviewCounts[productId] = count;
    _averageRatings[productId] = count == 0 ? 0 : total / count;
  }

  String _cleanErrorMessage(Object error) {
    return error.toString().replaceFirst('Exception: ', '');
  }
}
