import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cineflow/providers/favorites_provider.dart';

class FavoritesPage extends StatelessWidget {
  const FavoritesPage({super.key});

  @override
  Widget build(BuildContext context) {
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
                    leading: Image.network(
  movie['poster'].replaceAll('_SX300', '_SX600'),
  fit: BoxFit.cover,
  loadingBuilder: (context, child, progress) {
    if (progress == null) return child;
    return const Center(child: CircularProgressIndicator());
  },
),

                    title: Text(movie['title']),
                    subtitle:
                        Text("${movie['year']} • ${movie['type']}"),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () {
                        provider.removeFavorite(movie['id']);
                      },
                    ),
                  ),
                );
              },
            ),
    );
  }
}