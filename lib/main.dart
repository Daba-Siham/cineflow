import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:cineflow/providers/auth_provider.dart';
import 'package:cineflow/providers/theme_provider.dart';
import 'package:cineflow/providers/movie_provider.dart';
import 'package:cineflow/providers/favorites_provider.dart';
import 'package:cineflow/providers/search_history_provider.dart';
import 'package:cineflow/providers/downloads_provider.dart';

import 'package:cineflow/ui/views/home_page.dart';
import 'package:cineflow/ui/views/splash_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final authProvider = AuthProvider();
  await authProvider.init();

  final themeProvider = ThemeProvider();
  await themeProvider.init();

  runApp(
    MultiProvider(
      providers: [
        // Auth + thème initialisés
        ChangeNotifierProvider<AuthProvider>.value(value: authProvider),
        ChangeNotifierProvider<ThemeProvider>.value(value: themeProvider),

        // MovieProvider (catalogue + history chargés dans MainWelcomePage)
        ChangeNotifierProvider<MovieProvider>(
          create: (_) => MovieProvider(),
        ),

        // FavoritesProvider backend (loadFavorites appelé dans FavoritesPage)
        ChangeNotifierProvider<FavoritesProvider>(
          create: (_) => FavoritesProvider(),
        ),

        // Historique de recherche local
        ChangeNotifierProvider<SearchHistoryProvider>(
          create: (_) => SearchHistoryProvider(),
        ),

        // Téléchargements locaux (SQLite)
        ChangeNotifierProvider<DownloadsProvider>(
          create: (_) => DownloadsProvider()..loadDownloads(),
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
      title: 'CineFlow',
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      themeMode: themeProvider.themeMode,
      home: const CineFlowSplashPage(),
      routes: {
        '/home': (_) => const HomePage(),
      },
    );
  }
}
