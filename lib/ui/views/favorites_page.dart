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
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    leading: SizedBox(
                      width: 60,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          movie['poster'].replaceAll('_SX300', '_SX600'),
                          fit: BoxFit.cover,
                          loadingBuilder: (context, child, progress) {
                            if (progress == null) return child;
                            return const Center(
                              child: SizedBox(
                                height: 24,
                                width: 24,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              ),
                            );
                          },
                          errorBuilder: (context, error, stack) =>
                              const Icon(Icons.movie),
                        ),
                      ),
                    ),
                    title: Text(
                      movie['title'],
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    subtitle: Text("${movie['year']} • ${movie['type']}"),
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
