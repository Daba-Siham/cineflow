// lib/providers/downloads_provider.dart
import 'package:flutter/foundation.dart';
import 'package:cineflow/data/models/movie.dart';
import 'package:cineflow/data/services/database_service.dart';

class DownloadsProvider extends ChangeNotifier {
  List<Movie> _downloads = [];
  List<Movie> get downloads => _downloads;

  Future<void> loadDownloads() async {
    final rows = await DatabaseService.getDownloads();
    _downloads = rows.map((e) => Movie.fromMap(e)).toList();
    notifyListeners();
  }

  Future<void> addDownload(Movie movie) async {
    await DatabaseService.insertDownload(movie);
    await loadDownloads();
  }

  Future<void> removeDownload(String id) async {
    await DatabaseService.deleteDownload(id);
    await loadDownloads();
  }

  bool isDownloaded(String id) {
    return _downloads.any((m) => m.imdbID == id);
  }
}
