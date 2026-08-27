class AppConstants {
  static const String baseUrl =
      'https://rogue-durable-hamburger.ngrok-free.dev';

  static String getImageUrl(String? imageUrl) {
    if (imageUrl == null || imageUrl.trim().isEmpty) {
      return '';
    }

    if (imageUrl.startsWith('http://') || imageUrl.startsWith('https://')) {
      return imageUrl;
    }

    if (imageUrl.startsWith('/')) {
      return '$baseUrl$imageUrl';
    }

    return '$baseUrl/$imageUrl';
  }
}
