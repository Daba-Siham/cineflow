import 'package:flutter/material.dart';

class AppTheme {
  static final darkTheme = ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: Colors.black,
    primaryColor: Colors.red,

    colorScheme: const ColorScheme.dark(
      primary: Colors.red,
      secondary: Colors.redAccent,
      surface: Color(0xFF1E1E1E), 
    ),

    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.black,
      elevation: 0,
      titleTextStyle: TextStyle(color: Colors.white, fontSize: 20),
      iconTheme: IconThemeData(color: Colors.white),
    ),

    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.grey[900],
      hintStyle: TextStyle(color: Colors.grey[400]),
      prefixIconColor: Colors.red,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(30),
        borderSide: BorderSide.none,
      ),
    ),

    textTheme: const TextTheme(
      bodyMedium: TextStyle(color: Colors.white),
    ),
  );

  // ☀️ MODE CLAIR
  static final lightTheme = ThemeData(
    brightness: Brightness.light,
    scaffoldBackgroundColor: Colors.white,
    primaryColor: Colors.red,

    colorScheme: const ColorScheme.light(
      primary: Colors.red,
      secondary: Colors.redAccent,
      surface: Color(0xFFF2F2F2), 
    ),

    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.white,
      elevation: 0,
      titleTextStyle: TextStyle(color: Colors.black, fontSize: 20),
      iconTheme: IconThemeData(color: Colors.black),
    ),

    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Color(0xFFF0F0F0), 
      hintStyle: TextStyle(color: Colors.grey),
      prefixIconColor: Colors.red,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(30),
        borderSide: BorderSide.none,
      ),
    ),

    textTheme: const TextTheme(
      bodyMedium: TextStyle(color: Colors.black),
    ),
  );
}
