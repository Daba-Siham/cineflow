import 'package:flutter/foundation.dart';
import '../data/models/movie.dart';
import '../data/services/api_service.dart';
import '../data/services/database_service.dart';

class MovieProvider extends ChangeNotifier {
  final ApiService _api = ApiService();

  // =====================================================
  // 🔹 HISTORY
  // =====================================================
  List<Movie> _history = [];
  List<Movie> get history => _history;

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
    _history.removeWhere((m) => m.imdbID == movie.imdbID);
    _history.insert(0, movie);
    if (_history.length > 10) _history.removeLast();

    try {
      await DatabaseService.insertHistory(movie);
    } catch (_) {}

    notifyListeners();
  }

  // =====================================================
  // 🔹 SEARCH + PAGINATION
  // =====================================================
  List<Movie> _movies = [];
  bool _isLoading = false;

  int _currentPage = 1;
  int _totalPages = 1;
  String _currentQuery = "star";

  List<Movie> get movies => _movies;
  bool get isLoading => _isLoading;
  int get currentPage => _currentPage;
  int get totalPages => _totalPages;
  String get currentQuery => _currentQuery;

  Future<void> loadDefaultOnSearchOpen() async {
    await searchMovies("star", page: 1);
  }

  Future<void> searchMovies(String query, {int page = 1}) async {
    _isLoading = true;
    notifyListeners();

    _currentQuery = query.trim().isEmpty ? "star" : query.trim();
    _currentPage = page;

    try {
      final results = await _api.searchMovies(_currentQuery, page: page);
      final totalResults = await _api.getTotalResults(_currentQuery);

      final withDetails = await _attachDetails(results);

      _movies = withDetails;
      _totalPages = (totalResults / 10).ceil();
      if (_totalPages < 1) _totalPages = 1;
    } catch (_) {
      _movies = [];
      _totalPages = 1;
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> goToPage(int page) async {
    if (page < 1 || page > _totalPages) return;
    await searchMovies(_currentQuery, page: page);
  }

  // =====================================================
  // 🔹 HOME DISCOVER + FILTERS
  // =====================================================
  List<Movie> _homeMovies = [];
  bool _isLoadingHome = false;

  List<Movie> get homeMovies => _homeMovies;
  bool get isLoadingHome => _isLoadingHome;

  String _selectedType = "";
  String _selectedYear = "";
  String _selectedGenre = "";

  String get selectedType => _selectedType;
  String get selectedYear => _selectedYear;
  String get selectedGenre => _selectedGenre;

  void setType(String value) {
    _selectedType = value;
    notifyListeners();
  }

  void setYear(String value) {
    _selectedYear = value;
    notifyListeners();
  }

  void setGenre(String value) {
    _selectedGenre = value;
    notifyListeners();
  }

  
  List<String> get availableGenres {
    final set = <String>{};
    for (final m in _homeMovies) {
      final g = m.genre;
      if (g != null && g.trim().isNotEmpty) {
        set.addAll(
          g.split(",").map((e) => e.trim()).where((e) => e.isNotEmpty),
        );
      }
    }
    final list = set.toList()..sort();
    return list;
  }

  
  List<Movie> get filteredHomeMovies {
    var list = List<Movie>.from(_homeMovies);

    if (_selectedGenre.isNotEmpty) {
      list = list.where((m) {
        final g = (m.genre ?? "").toLowerCase();
        return g.contains(_selectedGenre.toLowerCase());
      }).toList();
    }

    return list;
  }

  
  Future<void> discoverOnHome({String query = "star", int page = 1}) async {
    _isLoadingHome = true;
    notifyListeners();

    try {
      final results = await _api.discoverMovies(
        query: query,
        type: _selectedType.isEmpty ? null : _selectedType,
        year: _selectedYear.isEmpty ? null : _selectedYear,
        page: page,
      );

      final withDetails = await _attachDetails(results);
      _homeMovies = withDetails;
    } catch (_) {
      _homeMovies = [];
    }

    _isLoadingHome = false;
    notifyListeners();
  }

  
  Future<void> applyFilters({String seedQuery = "star"}) async {
    await discoverOnHome(query: seedQuery, page: 1);
  }

  
  Future<void> resetHome({String seedQuery = "star"}) async {
    _selectedType = "";
    _selectedYear = "";
    _selectedGenre = "";

    await discoverOnHome(query: seedQuery, page: 1);
    notifyListeners();
  }

  // =====================================================
  // 🔹 DETAILS HELPER
  // =====================================================
  Future<List<Movie>> _attachDetails(List<Movie> list) async {
    if (list.isEmpty) return [];

    final futures = list.map((m) async {
      final details = await _api.getMovieDetailsMap(m.imdbID);
      return m.copyWith(
        genre: (details['Genre'] ?? '').toString(),
        imdbRating: (details['imdbRating'] ?? '').toString(),
      );
    }).toList();

    return Future.wait(futures);
  }
}
