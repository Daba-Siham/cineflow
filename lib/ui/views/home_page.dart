import 'package:flutter/material.dart';

import 'package:cineflow/ui/views/search_page.dart';
import 'package:cineflow/ui/views/favorites_page.dart';
import 'package:provider/provider.dart';
import 'package:cineflow/providers/theme_provider.dart';
import 'package:cineflow/ui/views/settings_page.dart';
import '../widgets/carousel_slider.dart';
import '../widgets/history_section.dart';
import '../widgets/movie_catalog_section.dart';
import '../widgets/recommendation_section.dart';
import '../widgets/series_catalog_section.dart';
import 'package:cineflow/providers/movie_provider.dart';
import 'package:cineflow/ui/views/profile_page.dart';
import 'package:cineflow/providers/auth_provider.dart';
import 'package:cineflow/ui/views/downloads_page.dart';
import 'package:cineflow/ui/views/filtrage_page.dart';
import 'package:cineflow/providers/downloads_provider.dart';


class MainWelcomePage extends StatefulWidget {
  const MainWelcomePage({super.key});

  @override
  State<MainWelcomePage> createState() => _MainWelcomePageState();
}

class _MainWelcomePageState extends State<MainWelcomePage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(
      () {
        final movieProvider = context.read<MovieProvider>();
        final auth = context.read<AuthProvider>();
        movieProvider.loadCatalog();
        movieProvider.loadHistory(auth: auth);
      }
    );
    Future.microtask(() => context.read<MovieProvider>().loadCatalog());
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
          MoviesCatalogSection(),   
          SizedBox(height: 20),
          SeriesCatalogSection(),   
          SizedBox(height: 20),
        ],
      ),
    );
  }
}


// ----------------- HOME PAGE (NAVIGATION) -----------------

class HomePage extends StatefulWidget {
  final int initialIndex;
  const HomePage({super.key,
  this.initialIndex = 0,});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late int index;

  @override
  void initState() {
    super.initState();
    index = widget.initialIndex; 
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final auth = context.read<AuthProvider>();
      final downloads = context.read<DownloadsProvider>();

      await downloads.setUser(auth.userId);
    });
  }


  final List<Widget> pages = const [
    MainWelcomePage(), 
    SearchPage(),      
    FavoritesPage(),  
    ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    final safeIndex = index.clamp(0, pages.length - 1);
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
              style:
                  TextStyle(fontWeight: FontWeight.bold, color: Colors.red),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(
              Theme.of(context).brightness == Brightness.dark
                  ? Icons.light_mode
                  : Icons.dark_mode,
            ),
            onPressed: () {
              Provider.of<ThemeProvider>(context, listen: false)
                  .toggleTheme();
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const SettingsPage()),
              );
            },
          ),
          // IconButton(
          //   icon: const Icon(Icons.download),
          //   tooltip: 'Téléchargements',
          //   onPressed: () {
          //     Navigator.push(
          //       context,
          //       MaterialPageRoute(builder: (_) => const DownloadsPage()),
          //     );
          //   },
          // ),
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
      
      body: pages[safeIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: safeIndex,
        onTap: (i) {
          if (safeIndex == 1 && i != 1) {
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
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profil"),
        ],
      ),
    );
  }
}
