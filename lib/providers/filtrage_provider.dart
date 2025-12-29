// lib/providers/filtrage_provider.dart
import 'package:cineflow/data/services/api_filtrage_service.dart';
import 'package:flutter/foundation.dart';
import 'package:cineflow/data/models/movie.dart';

class FiltrageProvider extends ChangeNotifier {
  final ApiFiltrageService _api = ApiFiltrageService();

  // Filters
  String type = "all";   // all | movie | series
  String year = "";
  String genre = "all";

  // Results
  List<Movie> results = [];
  bool isLoading = false;
  String? errorMessage;

  // Pagination
  int _page = 1;
  int _groupStart = 1;
  int totalPages = 1;

  int get currentPage => _page;
  int get groupStart => _groupStart;

  // Genres
  final Map<String, int> _movieGenres = {};
  final Map<String, int> _tvGenres = {};
  bool _genresReady = false;

  Future<void> init() async {
    await _loadGenres();
    await search(reset: true);
  }

  Future<void> _loadGenres() async {
    if (_genresReady) return;
    try {
      _movieGenres.addAll(await _api.fetchMovieGenres());
      _tvGenres.addAll(await _api.fetchTvGenres());
      _genresReady = true;
    } catch (_) {
      _genresReady = false;
    }
  }

  void setType(String v) {
    type = v;
    notifyListeners();
  }

  void setYear(String v) {
    year = v.trim();
    notifyListeners();
  }

  void setGenre(String v) {
    genre = v;
    notifyListeners();
  }

  void resetFilters() {
    type = "all";
    year = "";
    genre = "all";
    _page = 1;
    _groupStart = 1;
    notifyListeners();
  }


  void _syncGroupFromPage() {
    _groupStart = (((_page - 1) ~/ 5) * 5) + 1; // 1, 6, 11...
  }

  Future<void> nextGroup() async {
    final nextStart = _groupStart + 5;
    if (nextStart > totalPages) return;

    _groupStart = nextStart;
    _page = _groupStart;
    await search(reset: true);
  }

  Future<void> prevGroup() async {
    final prevStart = _groupStart - 5;
    if (prevStart < 1) return;

    _groupStart = prevStart;
    _page = _groupStart;
    await search(reset: true);
  }

  Future<void> goToPage(int page) async {
    if (page < 1) page = 1;
    if (page > totalPages) page = totalPages;

    _page = page;
    _syncGroupFromPage();
    await search(reset: true);
  }

  Future<void> search({bool reset = true}) async {
    if (isLoading) return;

    isLoading = true;
    errorMessage = null;
    if (reset) results = [];
    notifyListeners();

    try {
      await _loadGenres();

      final y = year.trim().isEmpty ? null : year.trim();
      final movieGenreId = (genre == "all") ? null : _movieGenres[genre.toLowerCase().trim()];
      final tvGenreId = (genre == "all") ? null : _tvGenres[genre.toLowerCase().trim()];

      if (type == "movie") {
        final r = await _api.discover(
          type: "movie",
          page: _page,
          genreId: movieGenreId,
          year: y,
        );
        results = r.items;
        totalPages = r.totalPages;
      } else if (type == "series") {
        final r = await _api.discover(
          type: "series",
          page: _page,
          genreId: tvGenreId,
          year: y,
        );
        results = r.items;
        totalPages = r.totalPages;
      } else {
        final movieRes = await _api.discover(
          type: "movie",
          page: _page,
          genreId: movieGenreId,
          year: y,
        );
        final tvRes = await _api.discover(
          type: "series",
          page: _page,
          genreId: tvGenreId,
          year: y,
        );

        // mix
        results = [...movieRes.items, ...tvRes.items];
        totalPages = (movieRes.totalPages > tvRes.totalPages)
            ? movieRes.totalPages
            : tvRes.totalPages;
      }

      if (totalPages < 1) totalPages = 1;
      if (_page > totalPages) _page = totalPages;

      _syncGroupFromPage();

      if (results.isEmpty) {
        errorMessage = "Aucun résultat pour ces filtres.";
      }
    } catch (_) {
      errorMessage = "Erreur lors du filtrage (TMDb).";
      results = [];
      totalPages = 1;
      _page = 1;
      _groupStart = 1;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}