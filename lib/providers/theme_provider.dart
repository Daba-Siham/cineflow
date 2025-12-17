import 'package:flutter/material.dart';

class ThemeProvider extends ChangeNotifier {
  // Par défaut, on commence en mode sombre (style Netflix)
  ThemeMode _themeMode = ThemeMode.dark;

  ThemeMode get themeMode => _themeMode;

  bool get isDarkMode => _themeMode == ThemeMode.dark;

  void toggleTheme() {
    _themeMode = isDarkMode ? ThemeMode.light : ThemeMode.dark;
    notifyListeners(); // Informe l'app de se reconstruire
  }
}