import 'package:flutter/material.dart';
import 'package:cineflow/data/models/movie.dart';

class MovieDetailsPage extends StatelessWidget {
  final Movie movie;
  const MovieDetailsPage({super.key, required this.movie});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(movie.title)),
      body: const Center(child: Text("Détails du film bientôt disponibles")),
    );
  }
}