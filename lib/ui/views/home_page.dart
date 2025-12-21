import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cineflow/ui/views/home_discover_page.dart';


import '../../providers/theme_provider.dart';


import 'favorites_page.dart';
import 'search_page.dart';
import 'settings_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int index = 0;

  final List<Widget> pages = const [
    HomeDiscoverPage(), // ✅ Accueil = filtrage + pagination + list
    SearchPage(),
    FavoritesPage(),
  ];

  @override
  Widget build(BuildContext context) {
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
              errorBuilder: (_, __, ___) => const Icon(Icons.movie),
            ),
            const SizedBox(width: 10),
            const Text(
              'CineFlow',
              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red),
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
              Provider.of<ThemeProvider>(context, listen: false).toggleTheme();
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SettingsPage()),
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
           
            // context.read<MovieProvider>().loadDefaultOnSearchOpen();
          }
          setState(() => index = i);
        },
        selectedItemColor: Colors.red,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Accueil"),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: "Recherche"),
          BottomNavigationBarItem(icon: Icon(Icons.favorite), label: "Favoris"),
        ],
      ),
    );
  }
}
