import 'package:flutter/material.dart';
import 'package:cineflow/data/services/recommendation_service.dart';
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
      body: FutureBuilder(
        future: RecommendationService().getRecommendations(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final recos = snapshot.data ?? [];

          if (recos.isEmpty) {
            return const Center(
              child: EmptyState(
                message: "Consulte au moins un film pour avoir des recommandations.",
              ),
            );
          }

          return Padding(
            padding: const EdgeInsets.all(16),
            child: GridView.builder(
              itemCount: recos.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 0.7,
              ),
              itemBuilder: (context, index) {
                return MovieCard(movie: recos[index]);
              },
            ),
          );
        },
      ),
    );
  }
}
