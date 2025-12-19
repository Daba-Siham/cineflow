import 'package:flutter/foundation.dart';
import 'package:cineflow/data/models/movie.dart';
import 'package:cineflow/data/services/api_service.dart';

class MovieProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();

  List<Movie> _results = [];
  bool _isLoading = false;
  String? _errorMessage;

  String _lastQuery = '';
  int _currentPage = 1;
  bool _hasMore = true;

  List<Movie> get results => _results;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get hasMore => _hasMore;

  Future<void> search(String query) async {
    if (query.isEmpty) return;

    _isLoading = true;
    _errorMessage = null;
    _lastQuery = query;
    _currentPage = 1;
    _hasMore = true;
    notifyListeners();

    try {
      final movies = await _apiService.searchMovies(query, page: _currentPage);
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
}
