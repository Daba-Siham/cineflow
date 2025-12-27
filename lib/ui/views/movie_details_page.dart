// lib/ui/views/movie_details_page.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'package:cineflow/core/constants/api_constants.dart';
import 'package:cineflow/data/models/movie.dart';
import 'package:cineflow/data/models/movie_detail.dart';

class MovieDetailsPage extends StatefulWidget {
  final Movie movie;
  const MovieDetailsPage({super.key, required this.movie});

  @override
  State<MovieDetailsPage> createState() => _MovieDetailsPageState();
}

class _MovieDetailsPageState extends State<MovieDetailsPage> {
  late Future<MovieDetail> _future;

  @override
  void initState() {
    super.initState();
    _future = _fetchDetails();
  }

  Future<MovieDetail> _fetchDetails() async {
    final id = widget.movie.imdbID.trim(); // chez toi = id TMDb
    if (id.isEmpty) throw Exception("ID TMDb vide");

    final isTv = widget.movie.type.toLowerCase() == 'series';
    final endpoint = isTv ? 'tv' : 'movie';

    final uri = Uri.parse('${ApiConstants.tmdbBaseUrl}/$endpoint/$id').replace(
      queryParameters: {
        'api_key': ApiConstants.tmdbApiKey,
        'language': 'fr-FR',
      },
    );

    final res = await http.get(uri);

    if (res.statusCode != 200) {
      throw Exception("Erreur TMDb (${res.statusCode})");
    }

    final data = jsonDecode(res.body) as Map<String, dynamic>;
    return isTv ? MovieDetail.fromTvJson(data) : MovieDetail.fromMovieJson(data);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? Colors.black : Colors.white,
      appBar: AppBar(
        backgroundColor: isDark ? Colors.black : Colors.white,
        elevation: 0,
        iconTheme: IconThemeData(color: isDark ? Colors.white : Colors.black),
        title: Text("Détails", style: TextStyle(color: isDark ? Colors.white : Colors.black)),
      ),
      body: FutureBuilder<MovieDetail>(
        future: _future,
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.hasError) {
            return Center(
              child: Text(
                "Erreur lors du chargement des détails.",
                style: TextStyle(color: isDark ? Colors.white70 : Colors.black87),
              ),
            );
          }

          final d = snap.data!;
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: AspectRatio(
                    aspectRatio: 2 / 3,
                    child: Image.network(
                      d.poster,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        color: Colors.grey.shade800,
                        alignment: Alignment.center,
                        child: const Icon(Icons.image_not_supported),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                Text(
                  "${d.title} ${d.year.isNotEmpty ? "(${d.year})" : ""}",
                  style: TextStyle(
                    color: isDark ? Colors.white : Colors.black,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),

                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    _chip(isDark, "Type: ${d.type}"),
                    if (d.genre.isNotEmpty) _chip(isDark, "Genre: ${d.genre}"),
                    if (d.runtime.isNotEmpty) _chip(isDark, "Durée: ${d.runtime}"),
                    if (d.imdbRating.isNotEmpty) _chip(isDark, "Note: ${d.imdbRating}"),
                  ],
                ),

                const SizedBox(height: 16),

                Text(
                  "Synopsis",
                  style: TextStyle(
                    color: isDark ? Colors.white : Colors.black,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  d.plot,
                  style: TextStyle(color: isDark ? Colors.white70 : Colors.black87, height: 1.4),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _chip(bool isDark, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withAlpha(18) : Colors.black.withAlpha(8),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: isDark ? Colors.white.withAlpha(30) : Colors.black.withAlpha(20)),
      ),
      child: Text(text, style: TextStyle(color: isDark ? Colors.white70 : Colors.black87, fontSize: 12)),
    );
  }
}
