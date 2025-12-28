import 'package:cineflow/data/models/movie.dart';
import 'package:cineflow/data/services/api_service.dart';
import 'package:cineflow/data/services/database_service.dart';
import 'package:flutter/src/widgets/framework.dart';

class RecommendationService {
  final ApiService _apiService = ApiService();

  Future<List<Movie>> getRecommendations(BuildContext context, {required int limit}) async {
    final history = await DatabaseService.getHistory();
    if (history.isEmpty) return [];

    final Map<String, int> genreCount = {};

    for (final movie in history) {
      final genreString = (movie['genre'] ?? '').toString().trim();
      if (genreString.isEmpty || genreString == 'N/A') continue;

      final genres = genreString
          .split(',')
          .map((g) => g.trim())
          .where((g) => g.isNotEmpty && g != 'N/A')
          .toList();

      for (final g in genres) {
        genreCount[g] = (genreCount[g] ?? 0) + 1;
      }
    }

    if (genreCount.isEmpty) return [];

    final sortedGenres = genreCount.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final topGenre = sortedGenres.first.key.trim();
    if (topGenre.isEmpty) return [];

    // on utilise la searchMovies TMDb qu'on a fusionnée
    final recos = await _apiService.searchMovies(topGenre);

    // attention : dans ta table history, la colonne id = tmdb id (imdbID dans Movie)
    final historyIds = history
        .map((e) => (e['id'] ?? '').toString())
        .where((id) => id.isNotEmpty)
        .toSet();

    final filtered =
        recos.where((m) => !historyIds.contains(m.imdbID)).toList();

    return filtered;
  }
}
