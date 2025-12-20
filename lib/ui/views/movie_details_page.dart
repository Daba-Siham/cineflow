import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cineflow/providers/movie_provider.dart';
import 'package:cineflow/data/models/movie.dart';
import 'package:cineflow/data/models/movie_detail.dart';
import 'package:cineflow/data/services/api_service.dart';
import 'package:cineflow/ui/widgets/movie_page_buttons.dart';
import 'package:cineflow/ui/widgets/recommendation_section.dart';

import '../widgets/cast_section.dart';
import '../views/favorites_page.dart'; // adapte le chemin si besoin

class MovieDetailsPage extends StatefulWidget {
  final Movie movie;

  const MovieDetailsPage({super.key, required this.movie});

  @override
  State<MovieDetailsPage> createState() => _MovieDetailsPageState();
}

class _MovieDetailsPageState extends State<MovieDetailsPage> {
  final ApiService _apiService = ApiService();
  MovieDetail? _details;
  bool _isLoading = true;
  String? _errorMessage;

  bool isFavorite = false;

  @override
  void initState() {
    super.initState();
    _loadDetails();
    _refreshFavoriteState();
  }

  void _refreshFavoriteState() {
    final exists =
        favorites.any((movie) => movie['id'] == widget.movie.imdbID);
    isFavorite = exists;
  }

  Future<void> _loadDetails() async {
    MovieDetail? data;

    try {
      data = await _apiService.getMovieDetail(widget.movie.imdbID);

      if (!mounted) return;

      setState(() {
        _details = data;
        if (data == null) {
          _errorMessage = 'Détails introuvables.';
        }
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Erreur lors du chargement des détails.';
        _isLoading = false;
      });
      return;
    }

    if (!mounted || data == null) return;

    final movieForHistory = Movie(
      imdbID: widget.movie.imdbID,
      title: widget.movie.title,
      year: widget.movie.year,
      poster: widget.movie.poster,
      type: widget.movie.type,
      genre: data.genre,
    );

    await context.read<MovieProvider>().addToHistory(movieForHistory);
  }

  void _toggleFavorite() {
    setState(() {
      if (isFavorite) {
        favorites.removeWhere(
          (movie) => movie['id'] == widget.movie.imdbID,
        );
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Retiré des favoris")),
        );
      } else {
        favorites.add({
          'id': widget.movie.imdbID,
          'title': widget.movie.title,
          'poster': widget.movie.poster,
          'year': widget.movie.year,
          'type': widget.movie.type,
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Ajouté aux favoris")),
        );
      }
      isFavorite = !isFavorite;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (_errorMessage != null) {
      return Scaffold(
        appBar: AppBar(),
        body: Center(child: Text(_errorMessage!)),
      );
    }

    if (_details == null) {
      return Scaffold(
        appBar: AppBar(),
        body: Center(child: Text('Aucune donnée.')),
      );
    }

    return Scaffold(
      body: Stack(
        children: [
          // Background image
          Opacity(
            opacity: 0.4,
            child: _details!.poster.isNotEmpty
                ? Image.network(
                    _details!.poster,
                    height: 300,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  )
                : Container(
                    height: 280,
                    width: double.infinity,
                    color: Colors.black,
                  ),
          ),

          SafeArea(
            child: Column(
              children: [
                // ==== PARTIE FIXE (haut) ====
                Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 10,
                    horizontal: 25,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      InkWell(
                        onTap: () => Navigator.pop(context),
                        child: const Icon(
                          Icons.arrow_back,
                          color: Colors.white,
                          size: 30,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Poster
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 15,
                    vertical: 0,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: const Color.fromARGB(255, 229, 191, 188)
                                  .withOpacity(0.5),
                              spreadRadius: 1,
                              blurRadius: 8,
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: _details!.poster.isNotEmpty
                              ? Image.network(
                                  _details!.poster,
                                  height: 250,
                                  width: 180,
                                  fit: BoxFit.cover,
                                )
                              : Container(
                                  height: 250,
                                  width: 180,
                                  color: Colors.grey[800],
                                  child: const Icon(
                                    Icons.movie,
                                    color: Colors.white,
                                    size: 60,
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                MoviePageButtons(
                  isFavorite: isFavorite,
                  onToggleFavorite: _toggleFavorite,
                ),

                const SizedBox(height: 10),

                // ==== PARTIE QUI SCROLLE ====
                Expanded(
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 20,
                        horizontal: 10,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${_details!.title} (${_details!.year})',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 26,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            '${_details!.genre} • ${_details!.runtime} • ${_details!.rated}',
                            style: TextStyle(
                              color: Colors.grey[300],
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 15),
                          Row(
                            children: [
                              const Icon(
                                Icons.star,
                                color: Colors.amber,
                                size: 20,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                _details!.imdbRating,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 15),
                          CastSection(actors: _details!.actors),
                          const SizedBox(height: 10),
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 16.0),
                            child: Text(
                              'Description',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _details!.plot,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                            ),
                            textAlign: TextAlign.justify,
                          ),
                          const SizedBox(height: 20),

                          const RecommendationSection(),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
