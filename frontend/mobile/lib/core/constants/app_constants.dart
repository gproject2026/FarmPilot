class AppConstants {
  static const String serverIp = '192.168.88.9';

  static const String baseUrl =
      'http://$serverIp:3000';

  static String getImageUrl(
    String? imageUrl,
  ) {
    if (imageUrl == null ||
        imageUrl.trim().isEmpty) {
      return '';
    }

    if (imageUrl.startsWith('http://') ||
        imageUrl.startsWith('https://')) {
      return imageUrl;
    }

    if (imageUrl.startsWith('/')) {
      return '$baseUrl$imageUrl';
    }

    return '$baseUrl/$imageUrl';
  }
}