import 'package:flutter/foundation.dart';
import 'package:cineflow/data/models/movie.dart';
import 'package:cineflow/data/services/database_service.dart';

class DownloadsProvider extends ChangeNotifier {
  List<Movie> _downloads = [];
  List<Movie> get downloads => _downloads;

  int? _userId;
  int? get userId => _userId;

  // à appeler quand le user change (login / logout / init)
  Future<void> setUser(int? userId) async {
    _userId = userId;
    if (_userId == null) {
      _downloads = [];
      notifyListeners();
    } else {
      await loadDownloads();
    }
  }

  Future<void> loadDownloads() async {
    if (_userId == null) {
      _downloads = [];
      notifyListeners();
      return;
    }

    final rows = await DatabaseService.getDownloads(_userId!);
    _downloads = rows.map((e) => Movie.fromMap(e)).toList();
    notifyListeners();
  }

  Future<void> addDownload(Movie movie) async {
    if (_userId == null) {
      debugPrint('addDownload: _userId est null → rien enregistré');
      return;
    }
    debugPrint('addDownload: user=$_userId, movie=${movie.imdbID}');
    await DatabaseService.insertDownload(_userId!, movie);
    await loadDownloads();
  }


  Future<void> removeDownload(String id) async {
    if (_userId == null) return;

    await DatabaseService.deleteDownload(_userId!, id);
    await loadDownloads();
  }

  bool isDownloaded(String id) {
    return _downloads.any((m) => m.imdbID == id);
  }
}
