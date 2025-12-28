// lib/data/services/api_filtrage_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;

import 'package:cineflow/core/constants/api_constants.dart';
import 'package:cineflow/data/models/movie.dart';

class DiscoverResponse {
  final List<Movie> items;
  final int totalPages;
  DiscoverResponse({required this.items, required this.totalPages});
}

class ApiFiltrageService {
  Future<Map<String, int>> fetchMovieGenres() async {
    final uri = Uri.parse(
      '${ApiConstants.tmdbBaseUrl}/genre/movie/list'
      '?api_key=${ApiConstants.tmdbApiKey}&language=fr-FR',
    );

    final res = await http.get(uri);
    if (res.statusCode != 200) throw Exception("Erreur genres movie");

    final data = jsonDecode(res.body) as Map<String, dynamic>;
    final List genres = (data['genres'] as List?) ?? [];

    // name(lowercase) -> id
    return {
      for (final g in genres)
        ((g['name'] ?? '').toString().toLowerCase().trim()): (g['id'] as int),
    };
  }

  Future<Map<String, int>> fetchTvGenres() async {
    final uri = Uri.parse(
      '${ApiConstants.tmdbBaseUrl}/genre/tv/list'
      '?api_key=${ApiConstants.tmdbApiKey}&language=fr-FR',
    );

    final res = await http.get(uri);
    if (res.statusCode != 200) throw Exception("Erreur genres tv");

    final data = jsonDecode(res.body) as Map<String, dynamic>;
    final List genres = (data['genres'] as List?) ?? [];

    return {
      for (final g in genres)
        ((g['name'] ?? '').toString().toLowerCase().trim()): (g['id'] as int),
    };
  }

  /// type: "movie" ou "series"
  Future<DiscoverResponse> discover({
    required String type,
    int page = 1,
    int? genreId,
    String? year, // "2019"
  }) async {
    final bool isTv = (type == "series");
    final endpoint = isTv ? "discover/tv" : "discover/movie";

    final params = <String, String>{
      "api_key": ApiConstants.tmdbApiKey,
      "language": "fr-FR",
      "page": page.toString(),
      "sort_by": "popularity.desc",
      "include_adult": "false",
    };

    if (genreId != null) {
      params["with_genres"] = genreId.toString();
    }

    final y = (year ?? "").trim();
    if (y.isNotEmpty) {
      // TMDb: movie -> primary_release_year, tv -> first_air_date_year
      params[isTv ? "first_air_date_year" : "primary_release_year"] = y;
    }

    final uri = Uri.parse('${ApiConstants.tmdbBaseUrl}/$endpoint')
        .replace(queryParameters: params);

    final res = await http.get(uri);
    if (res.statusCode != 200) {
      throw Exception("Erreur TMDb discover (${res.statusCode})");
    }

    final data = jsonDecode(res.body) as Map<String, dynamic>;
    final List results = (data["results"] as List?) ?? [];
    final int totalPages = (data["total_pages"] as int?) ?? 1;

    final items = results
        .map((e) => Movie.fromJson(e as Map<String, dynamic>, isTv: isTv))
        .toList();

    return DiscoverResponse(items: items, totalPages: totalPages);
  }
}