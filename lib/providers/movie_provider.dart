import 'package:flutter/foundation.dart';
import 'package:cineflow/data/models/movie.dart';
import 'package:cineflow/data/services/api_service.dart';
import 'package:cineflow/data/services/history_service.dart';
import '../core/constants/movie_queries.dart';

class MovieProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  final HistoryService _historyService = HistoryService();

  List<Movie> _history = [];
  List<Movie> get history => _history;

  Future<void> loadHistory() async {
    try {
      final data = await _historyService.getHistory(1);
      _history = data.map((e) => Movie.fromMap(e)).toList();
    } catch (_) {
      _history = [];
    }
    notifyListeners();
  }

  Future<void> addToHistory(Movie movie) async {
    _history.removeWhere((item) => item.imdbID == movie.imdbID);
    _history.insert(0, movie);
    if (_history.length > 10) {
      _history.removeLast();
    }

    try {
      await _historyService.addHistory(1, {
        'imdbID': movie.imdbID,
        'title': movie.title,
        'year': movie.year,
        'poster': movie.poster,
        'type': movie.type,
        'genre': movie.genre,
      });
    } catch (_) {}

    notifyListeners();
  }

  List<Movie> _results = [];
  List<Movie> get results => _results;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  String _lastQuery = '';
  int _currentPage = 1;

  bool _hasMore = true;
  bool get hasMore => _hasMore;

  void clearSearch() {
    _results = [];
    _errorMessage = null;
    _isLoading = false;
    _lastQuery = '';
    _currentPage = 1;
    _hasMore = true;
    notifyListeners();
  }

  Future<void> search(String query) async {
    final q = query.trim();
    if (q.isEmpty) return;

    _isLoading = true;
    _errorMessage = null;
    _lastQuery = q;
    _currentPage = 1;
    _hasMore = true;
    notifyListeners();

    try {
      final movies =
          await _apiService.searchMovies(_lastQuery, page: _currentPage);
      _results = movies;

      if (movies.isEmpty) {
        _errorMessage = 'Aucun film trouvé.';
        _hasMore = false;
      } else if (movies.length < 10) {
        _hasMore = false;
      }
    } catch (e) {
      print('MovieProvider.search ERROR: $e');
      _results = [];
      _errorMessage = e.toString(); // ⭐ affiche "Invalid API key" ou autre
      _hasMore = false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }


  Future<void> loadMore() async {
    if (!_hasMore || _isLoading || _lastQuery.isEmpty) return;

    _isLoading = true;
    notifyListeners();

    try {
      _currentPage++;
      final movies =
          await _apiService.searchMovies(_lastQuery, page: _currentPage);
      if (movies.isEmpty) {
        _hasMore = false;
      } else {
        _results.addAll(movies);
        if (movies.length < 10) {
          _hasMore = false;
        }
      }
    } catch (_) {
      _hasMore = false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  List<Movie> _catalog = [];
  List<Movie> get catalog => _catalog;

  List<Movie> get catalogMovies =>
      _catalog.where((m) => m.type.toLowerCase() == 'movie').toList();

  List<Movie> get catalogSeries =>
      _catalog.where((m) => m.type.toLowerCase() == 'series').toList();

  bool _isCatalogLoading = false;
  bool get isCatalogLoading => _isCatalogLoading;

  Future<void> loadCatalog() async {
    if (_isCatalogLoading) return;

    _isCatalogLoading = true;
    notifyListeners();

    try {
      final Map<String, Movie> tmp = {};

      for (final q in kCatalogQueries) {
        final results = await _apiService.searchMovies(q);
        for (final m in results) {
          tmp[m.imdbID] = m;
        }
      }

      _catalog = tmp.values.toList();
    } catch (_) {
      _catalog = [];
    }

    _isCatalogLoading = false;
    notifyListeners();
  }

  Future<List<Movie>> getTopRatedFromCatalog({int limit = 5}) async {
    if (catalog.isEmpty) {
      await loadCatalog();
    }

    final moviesOnly = catalogMovies;
    if (moviesOnly.isEmpty) return [];

    final List<MapEntry<Movie, double>> withRatings = [];
    final subset = moviesOnly.take(20).toList();

    for (final m in subset) {
      try {
        final detail = await _apiService.getMovieDetail(m.imdbID);
        if (detail != null && detail.imdbRating.isNotEmpty) {
          final rating = double.tryParse(detail.imdbRating) ?? 0.0;
          withRatings.add(MapEntry(m, rating));
        }
      } catch (_) {}
    }

    withRatings.sort((a, b) => b.value.compareTo(a.value));
    return withRatings.take(limit).map((e) => e.key).toList();
  }
}
