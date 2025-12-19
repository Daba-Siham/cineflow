import 'package:flutter/material.dart';
import 'package:cineflow/data/models/movie.dart';
import 'package:cineflow/data/models/movie_detail.dart';
import 'package:cineflow/data/services/api_service.dart';

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

  @override
  void initState() {
    super.initState();
    _loadDetails();
  }

  Future<void> _loadDetails() async {
    try {
      final data = await _apiService.getMovieDetail(widget.movie.imdbID);
      if (!mounted) return;
      setState(() {
        _details = data;
        if (data == null) {
          _errorMessage = 'Détails introuvables.';
        }
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Erreur lors du chargement des détails.';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(widget.movie.title)),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(child: Text(_errorMessage!))
              : _details == null
                  ? const Center(child: Text('Aucune donnée.'))
                  : SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Poster
                          Center(
                            child: _details!.poster.isNotEmpty
                                ? Image.network(
                                    _details!.poster,
                                    height: 300,
                                    fit: BoxFit.cover,
                                  )
                                : const Icon(Icons.movie, size: 100),
                          ),
                          const SizedBox(height: 16),

                          // Titre + année + note
                          Text(
                            '${_details!.title} (${_details!.year})',
                            style: theme.textTheme.titleLarge
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '${_details!.genre} • ${_details!.runtime} • ${_details!.rated}',
                            style: theme.textTheme.bodyMedium,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Note IMDb : ${_details!.imdbRating}',
                            style: theme.textTheme.bodyMedium
                                ?.copyWith(color: theme.colorScheme.primary),
                          ),
                          const SizedBox(height: 16),

                          // Réalisateur, acteurs
                          Text(
                            'Réalisateur : ${_details!.director}',
                            style: theme.textTheme.bodyMedium,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Acteurs : ${_details!.actors}',
                            style: theme.textTheme.bodyMedium,
                          ),
                          const SizedBox(height: 16),

                          // Synopsis
                          Text(
                            'Synopsis',
                            style: theme.textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _details!.plot,
                            style: theme.textTheme.bodyMedium,
                          ),
                        ],
                      ),
                    ),
    );
  }
}
