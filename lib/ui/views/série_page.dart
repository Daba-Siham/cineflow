import '../../data/models/movie.dart';
import '../widgets/empty_state.dart';
import '../widgets/movie_card.dart';
import 'package:flutter/material.dart';

class SeriesPage extends StatelessWidget {
  final List<Movie> series;

  const SeriesPage({super.key, required this.series});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Toutes les séries'),
      ),
      body: series.isEmpty
          ? const Center(
              child: EmptyState(message: 'Aucune série à afficher.'),
            )
          : GridView.builder(
              padding: const EdgeInsets.all(8),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.65,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
              ),
              itemCount: series.length,
              itemBuilder: (context, index) {
                return MovieCard(movie: series[index]);
              },
            ),
    );
  }
}
