import 'package:flutter/material.dart';
import 'package:cineflow/data/services/recommendation_service.dart';
import 'package:cineflow/data/models/movie.dart';
import 'package:cineflow/ui/widgets/movie_card.dart';
import 'package:cineflow/ui/widgets/empty_state.dart';


class RecommendationsPage extends StatelessWidget {
  const RecommendationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Suggestions automatiques"),
      ),
      body: FutureBuilder<List<Movie>>(
        future: RecommendationService().getRecommendations(context, limit: 20),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return const EmptyState(
              message: "Impossible de charger les recommandations.",
            );
          }

          final recos = snapshot.data ?? [];

          if (recos.isEmpty) {
            return const EmptyState(
              message: "Pas encore de recommandations disponibles.",
            );
          }

          return GridView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: recos.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 0.65,
            ),
            itemBuilder: (context, index) {
              final movie = recos[index];
              return MovieCard(movie: movie);
            },
          );
        },
      ),
    );
  }
}
