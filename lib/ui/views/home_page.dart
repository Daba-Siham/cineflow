// lib/ui/views/home_page.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:cineflow/ui/views/search_page.dart';
import 'package:cineflow/ui/views/favorites_page.dart';
import 'package:cineflow/ui/views/settings_page.dart';
import 'package:cineflow/ui/views/filtrage_page.dart';

import '../widgets/carousel_slider.dart';
import '../widgets/history_section.dart';
import '../widgets/movie_catalog_section.dart';
import '../widgets/recommendation_section.dart';
import '../widgets/series_catalog_section.dart';

import 'package:cineflow/providers/movie_provider.dart';
import 'package:cineflow/providers/theme_provider.dart';

// ----------------- PAGE ACCUEIL (MAINWELCOME) -----------------

class MainWelcomePage extends StatefulWidget {
  const MainWelcomePage({super.key});

  @override
  State<MainWelcomePage> createState() => _MainWelcomePageState();
}

class _MainWelcomePageState extends State<MainWelcomePage> {
  @override
  void initState() {
    super.initState();
    // Charge le catalogue une seule fois quand la page s'affiche
    Future.microtask(
      () => context.read<MovieProvider>().loadCatalog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return const SingleChildScrollView(
      child: Column(
        children: [
          SizedBox(height: 12),
          CarouselSliderHome(),
          SizedBox(height: 12),
          HistorySection(),
          SizedBox(height: 20),
          RecommendationSection(),
          SizedBox(height: 20),
          MoviesCatalogSection(),   // Films du catalogue
          SizedBox(height: 20),
          SeriesCatalogSection(),   // Séries du catalogue
          SizedBox(height: 20),
        ],
      ),
    );
  }
}

// ----------------- HOME PAGE (NAVIGATION) -----------------

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int index = 0;

  final List<Widget> pages = const [
    MainWelcomePage(), // Page Accueil
    SearchPage(),      // Page Recherche
    FavoritesPage(),   // Page Favoris
  ];

  @override
  Widget build(BuildContext context) {
    // Vérifier si on est en mode sombre ou clair pour le logo
    bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    String logoPath =
        isDarkMode ? 'assets/logo_sombre.png' : 'assets/logo_claire.png';

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Image.asset(
              logoPath,
              height: 55,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) =>
                  const Icon(Icons.movie),
            ),
            const SizedBox(width: 10),
            const Text(
              'CineFlow',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.red,
              ),
            ),
          ],
        ),
        actions: [
          // Bouton thème
          IconButton(
            icon: Icon(
              Theme.of(context).brightness == Brightness.dark
                  ? Icons.light_mode
                  : Icons.dark_mode,
            ),
            onPressed: () {
              Provider.of<ThemeProvider>(context, listen: false).toggleTheme();
            },
          ),
          // Bouton paramètres
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const SettingsPage(),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.tune),
            tooltip: "Filtrer",
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const FiltragePage()),
              );
            },
          ),
        ],
      ),
      body: pages[index],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: index,
        onTap: (i) {
          if (index == 1 && i != 1) {
            context.read<MovieProvider>().clearSearch();
          }
          setState(() => index = i);
        },
        selectedItemColor: Colors.red,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: "Accueil",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: "Recherche",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite),
            label: "Favoris",
          ),
        ],
      ),
    );
  }
}
