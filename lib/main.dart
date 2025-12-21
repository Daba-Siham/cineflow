import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'providers/favorites_provider.dart';
import 'providers/theme_provider.dart';
import 'providers/movie_provider.dart';

import 'ui/views/home_page.dart';
import 'core/theme/app_theme.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => FavoritesProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => MovieProvider()..loadHistory()),
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
