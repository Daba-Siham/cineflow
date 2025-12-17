import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cineflow/providers/movie_provider.dart';
import 'package:cineflow/providers/favorites_provider.dart';
import 'package:cineflow/ui/views/home_page.dart';
import 'package:cineflow/core/theme/app_theme.dart';
import 'package:cineflow/providers/theme_provider.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => MovieProvider()),
        ChangeNotifierProvider(create: (_) => FavoritesProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
      ],
      child: const CineFlowApp(),
    ),
  );
}

class CineFlowApp extends StatelessWidget {
  const CineFlowApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return MaterialApp(
      title: 'CineFlow',
      debugShowCheckedModeBanner: false,
      themeMode: themeProvider.themeMode, 
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme, 
      home: const HomePage(),
    );
  }
}