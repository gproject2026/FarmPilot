import 'package:flutter/material.dart';

import '../services/review_service.dart';

class ReviewProvider extends ChangeNotifier {
  final ReviewService reviewService =
      ReviewService();

  bool isLoading = false;

  bool isSubmitting = false;

  List<dynamic> reviews = [];

  String? errorMessage;

  Future<void> loadProductReviews(
    String productId,
  ) async {
    if (productId.isEmpty) {
      return;
    }

    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      reviews =
          await reviewService.getProductReviews(
        productId,
      );
    } catch (e) {
      errorMessage = _cleanErrorMessage(e);
      rethrow;
    } finally {
      isLoading = false;
      notifyListeners();
    }
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
      final newReview =
          await reviewService.createReview(
        productId: productId,
        rating: rating,
        comment: comment,
      );

      reviews.insert(
        0,
        newReview,
      );

      return true;
    } catch (e) {
      errorMessage = _cleanErrorMessage(e);

      return false;
    } finally {
      isSubmitting = false;
      notifyListeners();
    }
  }

  Future<bool> deleteReview(
    String reviewId,
  ) async {
    if (reviewId.isEmpty) {
      return false;
    }

    errorMessage = null;

    try {
      await reviewService.deleteReview(
        reviewId,
      );

      reviews.removeWhere((review) {
        if (review is! Map) {
          return false;
        }

        final reviewMap =
            Map<String, dynamic>.from(review);

        return reviewMap['id']?.toString() ==
            reviewId;
      });

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

      final reviewMap =
          Map<String, dynamic>.from(review);

      final rating = int.tryParse(
        reviewMap['rating']?.toString() ?? '',
      );

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
    notifyListeners();
  }

  String _cleanErrorMessage(
    Object error,
  ) {
    return error
        .toString()
        .replaceFirst(
          'Exception: ',
          '',
        );
  }
}