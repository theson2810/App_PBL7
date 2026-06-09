import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppSettingsProvider extends ChangeNotifier {
  static const _darkModeKey = 'app_dark_mode';
  static const _textScaleKey = 'app_text_scale';

  bool _darkMode = false;
  double _textScale = 1.0;

  bool get darkMode => _darkMode;
  double get textScale => _textScale;
  ThemeMode get themeMode => _darkMode ? ThemeMode.dark : ThemeMode.light;

  AppSettingsProvider() {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    _darkMode = prefs.getBool(_darkModeKey) ?? false;
    _textScale = prefs.getDouble(_textScaleKey) ?? 1.0;
    notifyListeners();
  }

  Future<void> setDarkMode(bool value) async {
    _darkMode = value;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_darkModeKey, value);
  }

  Future<void> setTextScale(double value) async {
    _textScale = value.clamp(0.9, 1.25);
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_textScaleKey, _textScale);
  }
}
