import 'package:flutter/foundation.dart';
import 'package:cineflow/data/models/movie.dart';
import 'package:cineflow/data/services/api_service.dart';
import 'package:cineflow/data/services/database_service.dart';

class MovieProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();

  List<Movie> _history = [];
  List<Movie> get history => _history;

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

  Future<void> loadHistory() async {
    try {
      final data = await DatabaseService.getHistory();
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
      await DatabaseService.insertHistory(movie);
    } catch (_) {}

    notifyListeners();
  }

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
      final movies = await _apiService.searchMovies(_lastQuery, page: _currentPage);
      _results = movies;

      if (movies.isEmpty) {
        _errorMessage = 'Aucun film trouvé.';
        _hasMore = false;
      } else if (movies.length < 10) {
        _hasMore = false;
      }
    } catch (_) {
      _results = [];
      _errorMessage = 'Erreur lors de la recherche.';
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
      final movies = await _apiService.searchMovies(_lastQuery, page: _currentPage);

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
}
