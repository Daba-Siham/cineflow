// lib/data/services/tmdb_filtrage_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;

import 'package:cineflow/core/constants/api_constants.dart';
import 'package:cineflow/data/models/movie.dart';
import 'package:cineflow/data/models/movie_detail.dart';

class TmdbFiltrageService {
  Future<List<Movie>> discover({
    required String type, // "movie" | "series"
    required int page,
    int? genreId,
    String? year,
    String? query, // optionnel (si tu veux mot-clé)
  }) async {
    final isTv = type.toLowerCase() == "series";
    final endpoint = isTv ? "discover/tv" : "discover/movie";

    final params = <String, String>{
      "api_key": ApiConstants.tmdbApiKey,
      "language": "fr-FR",
      "page": page.toString(),
      "include_adult": "false",
      "sort_by": "popularity.desc",
    };

    // Genre (TMDb retourne genre_ids comme [12,14] etc) :contentReference[oaicite:0]{index=0}
    if (genreId != null && genreId > 0) {
      params["with_genres"] = genreId.toString();
    }

    // Année
    final y = (year ?? "").trim();
    if (y.isNotEmpty) {
      if (isTv) {
        params["first_air_date_year"] = y;
      } else {
        params["primary_release_year"] = y;
      }
    }

    // Mot-clé (facultatif)
    final q = (query ?? "").trim();
    if (q.isNotEmpty) {
      // Astuce: discover supporte with_keywords mais nécessite des IDs keywords,
      // donc on fait simple: on utilise search quand query existe (géré dans provider).
      // Ici on ignore query si tu passes discover.
    }

    final uri = Uri.parse("${ApiConstants.tmdbBaseUrl}/$endpoint")
        .replace(queryParameters: params);

    final res = await http.get(uri);
    if (res.statusCode != 200) {
      throw Exception("Erreur TMDb (${res.statusCode})");
    }

    final data = jsonDecode(res.body) as Map<String, dynamic>;
    final list = (data["results"] as List?) ?? [];

    return list
        .map((e) => Movie.fromJson(e as Map<String, dynamic>, isTv: isTv))
        .toList();
  }

  /// Recherche texte (si l’utilisateur tape un mot)
  Future<List<Movie>> searchText({
    required String type, // movie | series
    required String query,
    required int page,
  }) async {
    final isTv = type.toLowerCase() == "series";
    final endpoint = isTv ? "search/tv" : "search/movie";

    final uri = Uri.parse("${ApiConstants.tmdbBaseUrl}/$endpoint").replace(
      queryParameters: {
        "api_key": ApiConstants.tmdbApiKey,
        "language": "fr-FR",
        "page": page.toString(),
        "include_adult": "false",
        "query": query.trim(),
      },
    );

    final res = await http.get(uri);
    if (res.statusCode != 200) {
      throw Exception("Erreur TMDb (${res.statusCode})");
    }

    final data = jsonDecode(res.body) as Map<String, dynamic>;
    final list = (data["results"] as List?) ?? [];

    return list
        .map((e) => Movie.fromJson(e as Map<String, dynamic>, isTv: isTv))
        .toList();
  }

  /// Genres
  Future<List<Map<String, dynamic>>> getGenres(String type) async {
    final isTv = type.toLowerCase() == "series";
    final endpoint = isTv ? "genre/tv/list" : "genre/movie/list";

    final uri = Uri.parse("${ApiConstants.tmdbBaseUrl}/$endpoint").replace(
      queryParameters: {
        "api_key": ApiConstants.tmdbApiKey,
        "language": "fr-FR",
      },
    );

    final res = await http.get(uri);
    if (res.statusCode != 200) {
      throw Exception("Erreur TMDb (${res.statusCode})");
    }

    final data = jsonDecode(res.body) as Map<String, dynamic>;
    final list = (data["genres"] as List?) ?? [];
    return list.cast<Map<String, dynamic>>();
  }

  /// Détails (MovieDetailsPage peut continuer comme chez toi)
  Future<MovieDetail> getDetail({
    required String id,
    required String type, // movie | series
  }) async {
    final isTv = type.toLowerCase() == "series";
    final endpoint = isTv ? "tv" : "movie";

    final uri = Uri.parse("${ApiConstants.tmdbBaseUrl}/$endpoint/$id").replace(
      queryParameters: {
        "api_key": ApiConstants.tmdbApiKey,
        "language": "fr-FR",
      },
    );

    final res = await http.get(uri);
    if (res.statusCode != 200) {
      throw Exception("Erreur TMDb (${res.statusCode})");
    }

    final data = jsonDecode(res.body) as Map<String, dynamic>;
    return isTv ? MovieDetail.fromTvJson(data) : MovieDetail.fromMovieJson(data);
  }
}