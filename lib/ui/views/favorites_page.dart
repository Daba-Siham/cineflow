import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cineflow/providers/favorites_provider.dart';
import 'package:cineflow/providers/auth_provider.dart';
import 'package:cineflow/ui/views/profile_page.dart';
import 'package:cineflow/ui/views/movie_details_page.dart';
import 'package:cineflow/data/models/movie.dart';


class FavoritesPage extends StatefulWidget {
  const FavoritesPage({super.key});

  @override
  State<FavoritesPage> createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      final auth = context.read<AuthProvider>();
      context.read<FavoritesProvider>().loadFavorites(auth: auth);
    });
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    if (!auth.isLoggedIn) {
      return Scaffold(
        appBar: AppBar(title: const Text("Mes Favoris")),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "Connecte-toi ou crée un compte pour utiliser les favoris.",
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const ProfilePage(),
                    ),
                  );
                },
                child: const Text("Aller à la page Profil"),
              ),
            ],
          ),
        ),
      );
    }

    final provider = context.watch<FavoritesProvider>();
    final favorites = provider.favorites;

    return Scaffold(
      appBar: AppBar(title: const Text("Mes Favoris")),
      body: favorites.isEmpty
          ? const Center(child: Text("Aucun film favori"))
          : ListView.builder(
              itemCount: favorites.length,
              itemBuilder: (context, index) {
                final movie = favorites[index];

                return Card(
                  child: ListTile(
                    onTap: () {
                      final movieObj = Movie(
                        imdbID: movie['id'],
                        title: movie['title'],
                        year: movie['year'] ?? '',
                        poster: movie['poster'] ?? '',
                        type: movie['type'] ?? '',
                        genre: '',
                      );

                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => MovieDetailsPage(movie: movieObj),
                        ),
                      );
                    },
                    leading: Image.network(
                      movie['poster'].toString().replaceAll('_SX300', '_SX600'),
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, progress) {
                        if (progress == null) return child;
                        return const Center(child: CircularProgressIndicator());
                      },
                    ),
                    title: Text(movie['title']),
                    subtitle: Text("${movie['year']} • ${movie['type']}"),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () {
                        provider.removeFavorite(
                          movie['id'],
                          auth: auth,
                        );
                      },
                    ),
                  ),
                );

              },
            ),
    );
  }
}
