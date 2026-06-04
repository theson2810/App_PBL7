import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _kLocaleKey = 'app_locale';

class LanguageProvider extends ChangeNotifier {
  Locale _locale = const Locale('en');
  bool _loaded = false;

  Locale get locale => _locale;
  bool get isLoaded => _loaded;
  bool get isVietnamese => _locale.languageCode == 'vi';

  LanguageProvider() {
    _loadSavedLocale();
  }

  Future<void> _loadSavedLocale() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final code = prefs.getString(_kLocaleKey);
      if (code == 'vi' || code == 'en') {
        _locale = Locale(code!);
        await _syncFirebaseAuthLocale();
      }
    } catch (_) {}
    _loaded = true;
    notifyListeners();
  }

  Future<void> _persistLocale() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_kLocaleKey, _locale.languageCode);
    } catch (_) {}
  }

  Future<void> _syncFirebaseAuthLocale() async {
    try {
      await FirebaseAuth.instance.setLanguageCode(_locale.languageCode);
    } catch (_) {}
  }

  void setLanguage(String languageCode) {
    _locale = Locale(languageCode);
    _syncFirebaseAuthLocale();
    _persistLocale();
    notifyListeners();
  }

  void toggleLanguage() {
    _locale = isVietnamese ? const Locale('en') : const Locale('vi');
    _syncFirebaseAuthLocale();
    _persistLocale();
    notifyListeners();
  }
}
