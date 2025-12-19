import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cineflow/providers/movie_provider.dart';
import 'movie_card.dart';
import 'empty_state.dart';
import 'package:cineflow/ui/views/history_page.dart';


class HistorySection extends StatelessWidget {
  const HistorySection({super.key});

  @override
  Widget build(BuildContext context) {
    final movieProvider = context.watch<MovieProvider?>();
    final history = movieProvider?.history ?? const [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Historique",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              if (history.isNotEmpty)
                InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const HistoryPage()),
                    );
                  },
                  child: Text(
                    "Voir plus",
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),
        ),


        if (history.isEmpty)
          const SizedBox(
            height: 120,
            child: EmptyState(message: "Aucun film consulté pour le moment."),
          )
        else
          SizedBox(
            height: 200,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: history.length,
              itemBuilder: (context, index) => MovieCard(movie: history[index]),
            ),
          ),
      ],
    );
  }
}
