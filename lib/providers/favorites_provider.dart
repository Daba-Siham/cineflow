import 'package:cineflow/data/services/favorite_api_service.dart';
import 'package:flutter/foundation.dart';
import 'package:cineflow/providers/auth_provider.dart';


class FavoritesProvider extends ChangeNotifier {
  final List<Map<String, dynamic>> _favorites = [];
  List<Map<String, dynamic>> get favorites => List.unmodifiable(_favorites);

  final Set<String> _favoriteIds = {};
  Set<String> get favoriteIds => _favoriteIds;

  Future<void> loadFavorites({required AuthProvider auth}) async {
    _favorites.clear();
    _favoriteIds.clear();

    if (!auth.isLoggedIn || auth.userId == null) {
      notifyListeners();
      return;
    }

    try {
      final data = await FavoritesApiService.fetchFavorites(auth.userId!);
      _favorites.addAll(data);
      _favoriteIds.addAll(
        data.map((m) => m['id'] as String),
      );
    } catch (e) {
      // tu peux logguer si besoin
    }

    notifyListeners();
  }

  bool isFavorite(String imdbId) {
    return _favoriteIds.contains(imdbId);
  }

  Future<void> addFavorite(
    Map<String, dynamic> movieMap, {
    required AuthProvider auth,
  }) async {
    if (!auth.isLoggedIn || auth.userId == null) return;

    await FavoritesApiService.addFavorite(auth.userId!, movieMap);

    final id = movieMap['id'] as String;
    _favoriteIds.add(id);
    _favorites.removeWhere((m) => m['id'] == id);
    _favorites.add(movieMap);

    notifyListeners();
  }

  Future<void> removeFavorite(
    String imdbId, {
    required AuthProvider auth,
  }) async {
    if (!auth.isLoggedIn || auth.userId == null) return;

    await FavoritesApiService.removeFavorite(auth.userId!, imdbId);

    _favoriteIds.remove(imdbId);
    _favorites.removeWhere((m) => m['id'] == imdbId);

    notifyListeners();
  }

  void clear() {
    _favorites.clear();
    _favoriteIds.clear();
    notifyListeners();
  }
}
