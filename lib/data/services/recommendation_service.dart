import 'dart:math';

import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

import 'package:cineflow/data/models/movie.dart';
import 'package:cineflow/data/services/api_service.dart';
import 'package:cineflow/providers/auth_provider.dart';
import 'package:cineflow/providers/movie_provider.dart';
import 'package:cineflow/providers/favorites_provider.dart';

class RecommendationService {
  final ApiService _api = ApiService();
  final Random _random = Random();

  Future<List<Movie>> getRecommendations(
    BuildContext context, {
    int limit = 10,
  }) async {
    final auth = context.read<AuthProvider>();
    final movieProvider = context.read<MovieProvider>();
    final favoritesProvider = context.read<FavoritesProvider>();

    await _ensureCatalogLoaded(movieProvider);

    List<Movie> seedMovies = [];

    if (!auth.isLoggedIn) {
      if (movieProvider.history.isNotEmpty) {
        seedMovies = List<Movie>.from(movieProvider.history);
      }
    } else {
      if (favoritesProvider.favorites.isNotEmpty) {
        seedMovies = favoritesProvider.favorites.map((f) {
          return Movie(
            imdbID: f['id'] as String,
            title: (f['title'] ?? '') as String,
            year: (f['year'] ?? '') as String,
            poster: (f['poster'] ?? '') as String,
            type: (f['type'] ?? '') as String,
            genre: '',
          );
        }).toList();
      } else if (movieProvider.history.isNotEmpty) {
        seedMovies = List<Movie>.from(movieProvider.history);
      }
    }

    if (seedMovies.isEmpty) {
      return _pickRandomFromCatalog(movieProvider.catalog, limit: limit);
    }

    final List<Movie> recos = [];
    final Set<String> usedIds = {};

    for (final seed in seedMovies.take(5)) {
      final candidates = _findSimilarMovies(seed, movieProvider.catalog);
      for (final c in candidates) {
        if (recos.length >= limit) break;
        if (usedIds.contains(c.imdbID)) continue;
        usedIds.add(c.imdbID);
        recos.add(c);
      }
      if (recos.length >= limit) break;
    }

    if (recos.isEmpty) {
      return _pickRandomFromCatalog(movieProvider.catalog, limit: limit);
    }

    recos.shuffle(_random);
    if (recos.length > limit) {
      return recos.take(limit).toList();
    }
    return recos;
  }

  Future<void> _ensureCatalogLoaded(MovieProvider provider) async {
    if (provider.catalog.isEmpty) {
      await provider.loadCatalog();
    }
  }

  List<Movie> _pickRandomFromCatalog(
    List<Movie> catalog, {
    int limit = 10,
  }) {
    if (catalog.isEmpty) return [];
    final List<Movie> shuffled = List<Movie>.from(catalog);
    shuffled.shuffle(_random);
    return shuffled.take(limit).toList();
  }

  List<Movie> _findSimilarMovies(Movie seed, List<Movie> catalog) {
    final List<String> seedGenres = seed.genre
        .split(',')
        .map((g) => g.trim().toLowerCase())
        .where((g) => g.isNotEmpty)
        .toList();

    final bool hasGenres = seedGenres.isNotEmpty;

    final List<Movie> filtered = catalog.where((m) {
      if (m.imdbID == seed.imdbID) return false;
      if (m.type.toLowerCase() != seed.type.toLowerCase()) return false;

      if (!hasGenres) return true;

      final movieGenres = m.genre
          .split(',')
          .map((g) => g.trim().toLowerCase())
          .where((g) => g.isNotEmpty)
          .toList();

      return movieGenres.any((g) => seedGenres.contains(g));
    }).toList();

    filtered.shuffle(_random);
    return filtered;
  }
}
