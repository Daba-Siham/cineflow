import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:cineflow/providers/auth_provider.dart';
import 'package:cineflow/providers/theme_provider.dart';
import 'package:cineflow/providers/movie_provider.dart';
import 'package:cineflow/providers/favorites_provider.dart';

import 'package:cineflow/ui/views/home_page.dart';
import 'package:cineflow/ui/views/splash_page.dart';
import 'package:cineflow/providers/downloads_provider.dart';
import 'package:cineflow/providers/search_history_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final authProvider = AuthProvider();
  
  await authProvider.init();

  final themeProvider = ThemeProvider();
  await themeProvider.init();

  final movieProvider = MovieProvider();
  await movieProvider.loadHistory(auth: authProvider);

  final favoritesProvider = FavoritesProvider();
  await favoritesProvider.loadFavorites(auth: authProvider);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthProvider>.value(value: authProvider),
        ChangeNotifierProvider<ThemeProvider>.value(value: themeProvider),

        ChangeNotifierProvider<MovieProvider>(
          create: (_) => MovieProvider(),
        ),
        ChangeNotifierProvider<FavoritesProvider>(
          create: (_) => FavoritesProvider(),
        ),
        ChangeNotifierProvider(create: (_) => DownloadsProvider()),
        ChangeNotifierProvider<SearchHistoryProvider>(
          create: (_) => SearchHistoryProvider(),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      themeMode: themeProvider.themeMode,
      home: const CineFlowSplashPage(),
      routes: {'/home': (_) => const HomePage()},
    );
  }
}

