import '../../data/models/movie.dart';
import '../widgets/empty_state.dart';
import '../widgets/movie_card.dart';
import 'package:flutter/material.dart';

class MoviesPage extends StatelessWidget {
  final List<Movie> movies;

  const MoviesPage({super.key, required this.movies});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tous les films'),
      ),
      body: movies.isEmpty
          ? const Center(
              child: EmptyState(message: 'Aucun film à afficher.'),
            )
          : GridView.builder(
              padding: const EdgeInsets.all(8),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2, // 2 MovieCard par ligne (à adapter)
                childAspectRatio: 0.65,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
              ),
              itemCount: movies.length,
              itemBuilder: (context, index) {
                return MovieCard(movie: movies[index]);
              },
            ),
    );
  }
}
