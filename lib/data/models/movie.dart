class Movie {
  final String title;
  final String year;
  final String genre;
  final String imdbID; // id TMDb
  final String type;   // 'movie' ou 'series'
  final String poster;

  Movie({
    required this.title,
    required this.year,
    required this.genre,
    required this.imdbID,
    required this.type,
    required this.poster,
  });

  factory Movie.fromMap(Map<String, dynamic> map) {
    return Movie(
      imdbID: map['id'] ?? '',
      title: map['title'] ?? '',
      year: map['year'] ?? '',
      genre: map['genre'] ?? '',
      poster: map['poster'] ?? '',
      type: map['type'] ?? '',
    );
  }

  // isTv = true => JSON venant de /search/tv
  factory Movie.fromJson(
    Map<String, dynamic> json, {
    bool isTv = false,
  }) {
    final String date =
        isTv ? (json['first_air_date'] ?? '') : (json['release_date'] ?? '');
    final String year = date.isNotEmpty ? date.substring(0, 4) : '';

    final String title = isTv
        ? (json['name'] ?? json['original_name'] ?? '')
        : (json['title'] ?? '');

    return Movie(
      title: title,
      year: year,
      genre: '',
      imdbID: json['id']?.toString() ?? '',
      type: isTv ? 'series' : 'movie',
      poster: json['poster_path'] != null
          ? 'https://image.tmdb.org/t/p/w500${json['poster_path']}'
          : 'https://dummyimage.com/400x600/cccccc/000000&text=No+Image',
    );
  }
}
