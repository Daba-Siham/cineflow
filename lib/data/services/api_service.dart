// Convertir le JSON (texte) reçu de l’API en objet Dart (jsonDecode).
import 'dart:convert';
// On va transformer les données JSON en objets Movie.
import '../models/movie.dart';
// Permet d’envoyer des requêtes (GET, POST, …)
import 'package:http/http.dart' as http;
// Importe la classe ApiConstants Contient l’URL Et la clé API
import '../../core/constants/api_constants.dart';
import '../models/movie_detail.dart';


class ApiService {
  // Pour search des Films
  Future<List<Movie>> searchMovies(String query, {int page = 1}) async {
    final uri = Uri.parse(
      '${ApiConstants.omdbBaseUrl}?apikey=${ApiConstants.omdbApiKey}&s=$query&page=$page',
    );

    final response = await http.get(uri);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      if (data['Response'] == 'True') {
        final List results = data['Search'];
        return results.map((e) => Movie.fromJson(e)).toList();
      } else {
        return [];
      }
    } else {
      throw Exception('Erreur de connexion à OMDb');
    }
  }

  // Pour Détails d'un Film
  Future<MovieDetail?> getMovieDetail(String imdbId) async {
  final uri = Uri.parse(
    '${ApiConstants.omdbBaseUrl}?apikey=${ApiConstants.omdbApiKey}&i=$imdbId&plot=full',
  );

  final response = await http.get(uri);

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);

    if (data['Response'] == 'True') {
      return MovieDetail.fromJson(data);
    } else {
      return null; // film non trouvé
    }
  } else {
    throw Exception('Erreur de connexion à OMDb');
  }
}

}
