import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cineflow/providers/auth_provider.dart';
import 'package:cineflow/providers/theme_provider.dart';
import 'package:cineflow/ui/views/login_page.dart';
import 'package:cineflow/ui/views/register_page.dart';
import 'package:cineflow/core/constants/api_constants.dart';
import 'package:cineflow/providers/movie_provider.dart';
import 'package:cineflow/providers/favorites_provider.dart';



class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final themeProvider = context.watch<ThemeProvider>();

    Widget avatar;
    if (auth.imgProfile != null && auth.imgProfile!.isNotEmpty) {
      avatar = CircleAvatar(
        radius: 48,
        backgroundImage:
            NetworkImage('${ApiConstants.backendBase}${auth.imgProfile!}'),
        backgroundColor: Colors.grey[800],
      );
    } else {
      avatar = const CircleAvatar(
        radius: 48,
        child: Icon(Icons.person, size: 40),
      );
    }

    if (!auth.isLoggedIn) {
      return Scaffold(
        backgroundColor: isDark ? const Color(0xFF111111) : Colors.white,
        appBar: AppBar(
          title: const Text('Profil'),
          centerTitle: true,
        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 16),
              avatar, 
              const SizedBox(height: 24),
              Text(
                "Connectez-vous à cineFlow",
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                "Créez un compte ou connectez-vous pour voir vos statistiques et vos favoris.",
                style: theme.textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const LoginPage()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFE4573D),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Text(
                    "Se connecter",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: OutlinedButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const RegisterPage()),
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Text(
                    "S'inscrire",
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    final movieProvider = context.watch<MovieProvider>();
    final favProvider = context.watch<FavoritesProvider>();

    final int moviesWatched = movieProvider.history.length;
    final int favoritesCount = favProvider.favorites.length;


    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF111111) : Colors.white,
      appBar: AppBar(
        title: const Text('Profil'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 8),
            avatar, 
            const SizedBox(height: 16),
            Text(
              auth.username,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Statistiques",
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E1E1E) : Colors.grey[100],
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Column(
                    children: [
                      const Icon(Icons.local_movies, size: 28),
                      const SizedBox(height: 6),
                      Text(
                        '$moviesWatched',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 2),
                      const Text('Films vus'),
                    ],
                  ),
                  Container(
                    height: 48,
                    width: 1,
                    color: Colors.grey.withOpacity(0.4),
                  ),
                  Column(
                    children: [
                      const Icon(Icons.star, size: 28, color: Colors.redAccent),
                      const SizedBox(height: 6),
                      Text(
                        '$favoritesCount',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 2),
                      const Text('Films favoris'),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Paramètres",
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: ListView(
                children: [
                  SwitchListTile(
                    value: themeProvider.isDarkMode,
                    onChanged: (_) => themeProvider.toggleTheme(),
                    title: const Text("Mode sombre / clair"),
                  ),
                  const Divider(),
                  ListTile(
                    leading: const Icon(Icons.notifications_outlined),
                    title: const Text("Notifications"),
                    subtitle: const Text("Good story, bit slow."),
                    onTap: () {},
                  ),
                  const Divider(),
                  ListTile(
                    leading: const Icon(Icons.language_outlined),
                    title: const Text("Langue"),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Text("Français"),
                        SizedBox(width: 8),
                        Icon(Icons.chevron_right),
                      ],
                    ),
                    onTap: () {},
                  ),
                  const Divider(),
                  ListTile(
                    leading: const Icon(Icons.logout),
                    title: const Text(
                      "Se déconnecter",
                      style: TextStyle(color: Colors.redAccent),
                    ),
                    onTap: () async {
                      final auth = context.read<AuthProvider>();
                      final movieProvider = context.read<MovieProvider>();
                      final favProvider = context.read<FavoritesProvider>();

                      await auth.logout();                    
                      await movieProvider.loadHistory();      
                      favProvider.clear();                    

                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Déconnecté.")),
                        );
                      }
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
