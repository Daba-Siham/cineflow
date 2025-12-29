import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:cineflow/providers/movie_provider.dart';
import 'package:cineflow/data/models/movie.dart';
import '../views/movie_page.dart';
import 'movie_card.dart';
import 'empty_state.dart';


class MoviesCatalogSection extends StatelessWidget {
  const MoviesCatalogSection({super.key});

  @override
  Widget build(BuildContext context) {
    final movieProvider = context.watch<MovieProvider>();
    final movies = List<Movie>.from(movieProvider.catalogMovies);
    movies.shuffle(); 

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Films',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              if (movies.isNotEmpty)
                InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => MoviesPage(movies: movies),
                      ),
                    );
                  },
                  child: const Icon(Icons.add, color: Colors.red),
                ),
            ],
          ),
        ),
        if (movies.isEmpty)
          const SizedBox(
            height: 120,
            child:
                EmptyState(message: 'Aucun film à afficher pour le moment.'),
          )
        else
          SizedBox(
            height: 200,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: movies.length > 10 ? 10 : movies.length, 
              itemBuilder: (context, index) => MovieCard(movie: movies[index]),
            ),
          ),
      ],
    );
  }
}
