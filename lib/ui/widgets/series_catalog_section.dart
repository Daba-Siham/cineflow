import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cineflow/providers/movie_provider.dart';
import '../../data/models/movie.dart';
import '../views/série_page.dart';
import 'movie_card.dart';
import 'empty_state.dart';


class SeriesCatalogSection extends StatelessWidget {
  const SeriesCatalogSection({super.key});

  @override
  Widget build(BuildContext context) {
    final movieProvider = context.watch<MovieProvider>();
    final series = List<Movie>.from(movieProvider.catalogSeries);
    series.shuffle();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Séries',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              if (series.isNotEmpty)
                InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => SeriesPage(series: series),
                      ),
                    );
                  },
                  child: const Icon(Icons.add, color: Colors.red),
                ),
            ],
          ),
        ),
        if (series.isEmpty)
          const SizedBox(
            height: 120,
            child: EmptyState(
              message: 'Aucune série à afficher pour le moment.',
            ),
          )
        else
          SizedBox(
            height: 200,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: series.length > 10 ? 10 : series.length,
              itemBuilder: (context, index) => MovieCard(movie: series[index]),
            ),
          ),
      ],
    );
  }
}
