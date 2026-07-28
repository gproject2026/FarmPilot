import 'package:flutter/material.dart';

import '../services/favorite_service.dart';

class FavoriteProvider extends ChangeNotifier {
  final FavoriteService favoriteService =
      FavoriteService();

  bool isLoading = false;

  List<dynamic> favorites = [];

  String? errorMessage;

  Future<void> loadFavorites() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      favorites =
          await favoriteService.getFavorites();
    } catch (e) {
      errorMessage = _cleanErrorMessage(e);
      rethrow;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  bool isFavorite(
    String productId,
  ) {
    return favorites.any((favorite) {
      if (favorite is! Map) {
        return false;
      }

      final favoriteMap =
          Map<String, dynamic>.from(favorite);

      final savedProductId =
          favoriteMap['productId']?.toString() ??
              favoriteMap['product']?['id']
                  ?.toString() ??
              '';

      return savedProductId == productId;
    });
  }

  Future<bool> addFavorite(
    String productId,
  ) async {
    if (productId.isEmpty) {
      return false;
    }

    if (isFavorite(productId)) {
      return true;
    }

    errorMessage = null;

    try {
      final newFavorite =
          await favoriteService.addFavorite(
        productId,
      );

      favorites.add(newFavorite);
      notifyListeners();

      return true;
    } catch (e) {
      errorMessage = _cleanErrorMessage(e);
      notifyListeners();

      return false;
    }
  }

  Future<bool> removeFavorite(
    String productId,
  ) async {
    if (productId.isEmpty) {
      return false;
    }

    errorMessage = null;

    try {
      await favoriteService.removeFavorite(
        productId,
      );

      favorites.removeWhere((favorite) {
        if (favorite is! Map) {
          return false;
        }

        final favoriteMap =
            Map<String, dynamic>.from(favorite);

        final savedProductId =
            favoriteMap['productId']?.toString() ??
                favoriteMap['product']?['id']
                    ?.toString() ??
                '';

        return savedProductId == productId;
      });

      notifyListeners();

      return true;
    } catch (e) {
      errorMessage = _cleanErrorMessage(e);
      notifyListeners();

      return false;
    }
  }

  Future<bool> toggleFavorite(
    String productId,
  ) async {
    if (isFavorite(productId)) {
      return removeFavorite(productId);
    }

    return addFavorite(productId);
  }

  void clearFavorites() {
    favorites = [];
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