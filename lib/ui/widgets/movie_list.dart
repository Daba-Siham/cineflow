import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/movie_provider.dart';

class MovieList extends StatelessWidget {
  const MovieList({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<MovieProvider>();

    if (provider.isLoadingHome) {
      return const Center(child: CircularProgressIndicator());
    }

    
    final list = provider.filteredHomeMovies;

    if (list.isEmpty) {
      return const Center(child: Text("Aucun film à afficher"));
    }

    return ListView.builder(
      itemCount: list.length,
      itemBuilder: (context, index) {
        final movie = list[index];

        return ListTile(
          leading: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: (movie.poster.isNotEmpty && movie.poster != "N/A")
                ? Image.network(
                    movie.poster,
                    width: 50,
                    height: 70,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => const Icon(Icons.movie),
                  )
                : const Icon(Icons.movie),
          ),
          title: Text(movie.title),
          subtitle: Text('${movie.year} • ${movie.type}'),
        );
      },
    );
  }
}
