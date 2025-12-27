import '../../core/constants/api_constants.dart';

class MovieDetail {
  final String title;
  final String year;
  final String rated;
  final String released;
  final String runtime;
  final String genre;
  final String director;
  final String actors;
  final String plot;
  final String poster;
  final String imdbRating;
  final String type; // 'movie' ou 'series'

  MovieDetail({
    required this.title,
    required this.year,
    required this.rated,
    required this.released,
    required this.runtime,
    required this.genre,
    required this.director,
    required this.actors,
    required this.plot,
    required this.poster,
    required this.imdbRating,
    required this.type,
  });

  static const String kDefaultPlot =
      'Lorem ipsum dolor sit amet, consectetur adipiscing elit. '
      'Curabitur sit amet lacus vel justo malesuada viverra. '
      'Integer a nisl vel dui finibus aliquet. '
      'Sed eget dolor ut orci dictum placerat.';

  factory MovieDetail.fromMovieJson(Map<String, dynamic> json) {
    final genres = (json['genres'] as List<dynamic>?)
            ?.map((g) => g['name'] as String?)
            .whereType<String>()
            .toList() ??
        [];

    final String releaseDate = json['release_date'] ?? '';
    final String year =
        releaseDate.isNotEmpty ? releaseDate.substring(0, 4) : '';

    final String overview = (json['overview'] as String? ?? '').trim();

    return MovieDetail(
      title: json['title'] ?? '',
      year: year,
      rated: '',
      released: releaseDate,
      runtime: json['runtime'] != null ? '${json['runtime']} min' : '',
      genre: genres.join(', '),
      director: '',
      actors: '',
      plot: overview.isNotEmpty ? overview : kDefaultPlot,
      poster: json['poster_path'] != null
          ? '${ApiConstants.tmdbImageBaseUrl}${json['poster_path']}'
          : 'https://dummyimage.com/400x600/cccccc/000000&text=No+Image',
      imdbRating: json['vote_average'] != null
          ? json['vote_average'].toString()
          : '',
      type: 'movie',
    );
  }

  factory MovieDetail.fromTvJson(Map<String, dynamic> json) {
    final genres = (json['genres'] as List<dynamic>?)
            ?.map((g) => g['name'] as String?)
            .whereType<String>()
            .toList() ??
        [];

    final String firstAir = json['first_air_date'] ?? '';
    final String year = firstAir.isNotEmpty ? firstAir.substring(0, 4) : '';

    final String name =
        json['name'] ?? json['original_name'] ?? json['original_title'] ?? '';

    final int? episodeRunTime =
        (json['episode_run_time'] as List?)?.isNotEmpty == true
            ? (json['episode_run_time'][0] as int?)
            : null;

    final String overview = (json['overview'] as String? ?? '').trim();

    return MovieDetail(
      title: name,
      year: year,
      rated: '',
      released: firstAir,
      runtime: episodeRunTime != null ? '$episodeRunTime min' : '',
      genre: genres.join(', '),
      director: '',
      actors: '',
      plot: overview.isNotEmpty ? overview : kDefaultPlot,
      poster: json['poster_path'] != null
          ? '${ApiConstants.tmdbImageBaseUrl}${json['poster_path']}'
          : 'https://dummyimage.com/400x600/cccccc/000000&text=No+Image',
      imdbRating: json['vote_average'] != null
          ? json['vote_average'].toString()
          : '',
      type: 'series',
    );
  }
}
