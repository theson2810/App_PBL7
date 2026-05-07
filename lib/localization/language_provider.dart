import 'package:flutter/material.dart';

class LanguageProvider extends ChangeNotifier {
  Locale _locale = const Locale('en');

  Locale get locale => _locale;

  bool get isVietnamese => _locale.languageCode == 'vi';

  void setLanguage(String languageCode) {
    _locale = Locale(languageCode);
    notifyListeners();
  }

  void toggleLanguage() {
    _locale = isVietnamese ? const Locale('en') : const Locale('vi');
    notifyListeners();
  }
}
