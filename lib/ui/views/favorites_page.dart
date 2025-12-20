import 'package:flutter/material.dart';

List<Map<String, dynamic>> favorites = [];

class FavoritesPage extends StatefulWidget {
  const FavoritesPage({super.key});

  @override
  State<FavoritesPage> createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Mes Favoris")),
      body: favorites.isEmpty
          ? const Center(child: Text("Aucun film favori"))
          : ListView.builder(
              itemCount: favorites.length,
              itemBuilder: (context, index) {
                final movie = favorites[index];

                return Card(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  child: ListTile(
                    leading: Image.network(
                      movie['poster'],
                      width: 50,
                      height: 70,
                      fit: BoxFit.cover,
                    ),
                    title: Text(movie['title']),
                    subtitle: Text("${movie['year']} • ${movie['type']}"),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () {
                        setState(() {
                          favorites.removeAt(index);
                        });

                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Film supprimé des favoris "),
                          ),
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
