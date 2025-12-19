import 'package:cineflow/data/models/movie.dart';
import 'package:cineflow/data/services/api_service.dart';
import 'package:cineflow/data/services/database_service.dart';

class RecommendationService {
  final ApiService _apiService = ApiService();

  Future<List<Movie>> getRecommendations() async {
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

    final recos = await _apiService.searchMovies(topGenre);

    final historyIds = history.map((e) => (e['imdbID'] ?? '').toString()).toSet();
    final filtered = recos.where((m) => !historyIds.contains(m.imdbID)).toList();

    return filtered;
  }
}
