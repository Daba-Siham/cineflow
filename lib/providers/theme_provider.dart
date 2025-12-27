import 'package:flutter/material.dart';
import 'package:cineflow/core/storage/prefs.dart';

class ThemeProvider extends ChangeNotifier {

  ThemeMode _themeMode = ThemeMode.dark;

  ThemeMode get themeMode => _themeMode;
  bool get isDarkMode => _themeMode == ThemeMode.dark;

  Future<void> init() async {
    final prefs = await AppPrefs.instance;
    final isDark = prefs.getBool(AppPrefs.keyIsDarkMode) ?? true; 

    _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
  }

  Future<void> toggleTheme() async {
    _themeMode = isDarkMode ? ThemeMode.light : ThemeMode.dark;

    final prefs = await AppPrefs.instance;
    await prefs.setBool(AppPrefs.keyIsDarkMode, isDarkMode);

    notifyListeners();
  }
}
