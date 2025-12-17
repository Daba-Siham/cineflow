import 'package:flutter/material.dart';
import 'package:cineflow/ui/views/search_page.dart';
import 'package:cineflow/ui/views/favorites_page.dart';
import 'package:provider/provider.dart';
import 'package:cineflow/providers/theme_provider.dart';
import 'package:cineflow/ui/views/settings_page.dart';

// Une page d'accueil simple pour la section "Accueil"
class MainWelcomePage extends StatelessWidget {
  const MainWelcomePage({super.key});
  @override
  Widget build(BuildContext context) {
    return const Center(child: Text("Bienvenue sur CineFlow !"));
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int index = 0;

  // Structure des pages demandée
  final List<Widget> pages = [
    const MainWelcomePage(), // Page Accueil
    const SearchPage(),      // Page Recherche
    const FavoritesPage(),   // Page Favoris
  ];

  @override
  Widget build(BuildContext context) {
    // Vérifier si on est en mode sombre ou clair pour le logo
    bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    String logoPath = isDarkMode ? 'assets/logo_sombre.png' : 'assets/logo_claire.png';

    return Scaffold(
      appBar: AppBar(
        // Section Logo + Nom à côté
        title: Row(
          children: [
            Image.asset(
              logoPath,
              height: 55, // Augmenté de 40 à 55
              fit: BoxFit.contain, // S'assure que le logo ne dépasse pas
              errorBuilder: (context, error, stackTrace) => const Icon(Icons.movie), 
            ),
            const SizedBox(width: 10),
            const Text(
              'CineFlow',
              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red),
            ),
          ],
        ),
        actions: [
          // Bouton pour changer le thème (Sombre/Clair)
          IconButton(
            icon: Icon(Theme.of(context).brightness == Brightness.dark ? Icons.light_mode : Icons.dark_mode),
            onPressed: () {
              Provider.of<ThemeProvider>(context, listen: false).toggleTheme();
            },
          ),
          // Bouton pour les paramètres
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsPage()),
              );
            },
          ),
        ],
      ),

      // Affichage de la page selon l'index
      body: pages[index],

      // Barre de navigation
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: index,
        onTap: (i) => setState(() => index = i),
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