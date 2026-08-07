import 'package:flutter/material.dart';

class LocaleProvider extends ChangeNotifier {
  Locale _locale = const Locale('en');

  Locale get locale => _locale;

  void setLocale(
    Locale locale,
  ) {
    if (!const [
      'en',
      'ar',
    ].contains(
      locale.languageCode,
    )) {
      return;
    }

    _locale = locale;
    notifyListeners();
  }

  void toggleLanguage() {
    if (_locale.languageCode == 'en') {
      setLocale(
        const Locale('ar'),
      );
    } else {
      setLocale(
        const Locale('en'),
      );
    }
  }
}