import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:cineflow/data/models/movie.dart';

import '../../core/constants/api_constants.dart';

class HistoryApiService {
  static Future<void> addToHistory(int userId, Movie movie) async {
    final url = Uri.parse('${ApiConstants.historyBase}/$userId');

    final payload = {
      'imdbID': movie.imdbID,
      'Title': movie.title,
      'Year': movie.year,
      'Poster': movie.poster,
      'Type': movie.type,
      'Genre': movie.genre,
    };

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(payload),
    );

    if (response.statusCode != 201) {
      throw Exception('Erreur lors de l\'ajout dans l’historique');
    }
  }

  static Future<List<Movie>> fetchHistory(int userId) async {
    final url = Uri.parse('${ApiConstants.historyBase}/$userId');
    final response = await http.get(url);

    if (response.statusCode != 200) {
      throw Exception('Erreur lors de la récupération de l’historique');
    }

    final List<dynamic> data = jsonDecode(response.body);

    return data.map((e) {
      return Movie(
        imdbID: e['imdb_id'] ?? '',
        title: e['title'] ?? '',
        year: e['year'] ?? '',
        poster: e['poster'] ?? '',
        type: e['type'] ?? 'movie',
        genre: e['genre'] ?? '',
      );
    }).toList();
  }
}
