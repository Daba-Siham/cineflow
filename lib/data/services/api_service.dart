import 'dart:convert';
import 'package:http/http.dart' as http;

import '../../core/constants/api_constants.dart';
import '../models/cast_member.dart';
import '../models/movie.dart';
import '../models/movie_detail.dart';
import '../models/review.dart';

class ApiService {
  Future<Map<String, dynamic>> _getJson(Uri uri) async {
    final res = await http.get(uri);
    if (res.statusCode != 200) {
      throw Exception('Erreur réseau: ${res.statusCode}');
    }
    final data = jsonDecode(res.body);
    if (data is Map<String, dynamic>) return data;
    throw Exception('Réponse invalide');
  }

  // -------- SEARCH (TMDb) --------

  // Compatibilité: ancien code qui appelait searchMovies (films seuls)
  Future<List<Movie>> searchMovies(String query, {int page = 1}) async {
    final q = query.trim().isEmpty ? 'star' : query.trim();

    final uri = Uri.parse(
      '${ApiConstants.tmdbBaseUrl}/search/movie'
      '?api_key=${ApiConstants.tmdbApiKey}'
      '&query=$q'
      '&page=$page'
      '&language=fr-FR',
    );

    final data = await _getJson(uri);
    final list = (data['results'] as List? ?? []);
    return list.map((e) => Movie.fromJson(e, isTv: false)).toList();
  }

  // Recherche séries seules (optionnel mais pratique)
  Future<List<Movie>> searchSeries(String query, {int page = 1}) async {
    final q = query.trim().isEmpty ? 'star' : query.trim();

    final uri = Uri.parse(
      '${ApiConstants.tmdbBaseUrl}/search/tv'
      '?api_key=${ApiConstants.tmdbApiKey}'
      '&query=$q'
      '&page=$page'
      '&language=fr-FR',
    );

    final data = await _getJson(uri);
    final list = (data['results'] as List? ?? []);
    return list.map((e) => Movie.fromJson(e, isTv: true)).toList();
  }

  // Recherche mixte (films + séries)
  Future<List<Movie>> searchMulti(String query, {int page = 1}) async {
    final q = query.trim().isEmpty ? 'star' : query.trim();

    final uri = Uri.parse(
      '${ApiConstants.tmdbBaseUrl}/search/multi'
      '?api_key=${ApiConstants.tmdbApiKey}'
      '&query=$q'
      '&page=$page'
      '&language=fr-FR',
    );

    final data = await _getJson(uri);
    final list = (data['results'] as List? ?? []);

    final List<Movie> results = [];

    for (final raw in list) {
      final mediaType = raw['media_type'];
      if (mediaType == 'movie') {
        results.add(Movie.fromJson(raw, isTv: false));
      } else if (mediaType == 'tv') {
        results.add(Movie.fromJson(raw, isTv: true));
      } else {
        // on ignore 'person' et autres
        continue;
      }
    }

    return results;
  }

  // -------- DETAILS (TMDb) --------

  Future<MovieDetail?> getMovieDetail(String tmdbId) async {
    final uri = Uri.parse(
      '${ApiConstants.tmdbBaseUrl}/movie/$tmdbId'
      '?api_key=${ApiConstants.tmdbApiKey}'
      '&language=fr-FR',
    );

    final data = await _getJson(uri);
    if (data.isEmpty || data['id'] == null) return null;
    return MovieDetail.fromMovieJson(data);
  }

  Future<MovieDetail?> getTvDetail(String tmdbId) async {
    final uri = Uri.parse(
      '${ApiConstants.tmdbBaseUrl}/tv/$tmdbId'
      '?api_key=${ApiConstants.tmdbApiKey}'
      '&language=fr-FR',
    );

    final data = await _getJson(uri);
    if (data.isEmpty || data['id'] == null) return null;
    return MovieDetail.fromTvJson(data);
  }

  // -------- CAST (TMDb) --------

  Future<List<String>> getCastNames(String tmdbId, {required bool isTv}) async {
    final uri = Uri.parse(
      '${ApiConstants.tmdbBaseUrl}/${isTv ? 'tv' : 'movie'}/$tmdbId/credits'
      '?api_key=${ApiConstants.tmdbApiKey}'
      '&language=fr-FR',
    );

    final data = await _getJson(uri);
    final List cast = data['cast'] as List? ?? [];

    return cast
        .take(10)
        .map((e) => e['name'] as String? ?? '')
        .where((name) => name.isNotEmpty)
        .toList();
  }

  Future<List<CastMember>> getCast(
    String tmdbId, {
    required bool isTv,
  }) async {
    final uri = Uri.parse(
      '${ApiConstants.tmdbBaseUrl}/${isTv ? 'tv' : 'movie'}/$tmdbId/credits'
      '?api_key=${ApiConstants.tmdbApiKey}'
      '&language=fr-FR',
    );

    final data = await _getJson(uri);
    final List castJson = data['cast'] as List? ?? [];

    return castJson
        .take(10)
        .map((e) => CastMember.fromJson(e))
        .where((c) => c.name.isNotEmpty)
        .toList();
  }

  // -------- REVIEWS (TMDb) --------

  Future<List<Review>> getReviews(String tmdbId, {required bool isTv}) async {
    final uri = Uri.parse(
      '${ApiConstants.tmdbBaseUrl}/${isTv ? 'tv' : 'movie'}/$tmdbId/reviews'
      '?api_key=${ApiConstants.tmdbApiKey}'
      '&language=en-US',
    );

    final data = await _getJson(uri);
    final List results = data['results'] as List? ?? [];
    return results.map((e) => Review.fromJson(e)).toList();
  }
}
