import 'package:flutter/material.dart';
import 'package:cineflow/data/services/recommendation_service.dart';
import 'package:cineflow/ui/widgets/movie_card.dart';
import 'empty_state.dart';

class RecommendationSection extends StatelessWidget {
  const RecommendationSection({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: RecommendationService().getRecommendations(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox(
            height: 120,
            child: Center(child: CircularProgressIndicator()),
          );
        }

        final recos = snapshot.data ?? [];

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
              child: Text(
                "Suggestions automatiques",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            if (recos.isEmpty)
              const SizedBox(
                height: 120,
                child: EmptyState(
                  message: "Consulte au moins un film pour avoir des recommandations.",
                ),
              )
            else
              SizedBox(
                height: 200,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: recos.length,
                  itemBuilder: (context, index) {
                    return MovieCard(movie: recos[index]);
                  },
                ),
              ),
          ],
        );
      },
    );
  }
}
