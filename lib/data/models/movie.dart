class Movie {
  final String title;
  final String year;
  final String genre;
  final String imdbID; // id TMDb
  final String type;   // 'movie' ou 'series'
  final String poster;

  // ⭐ Champ optionnel pour stocker la note (par ex. TMDb vote_average)
  double? rating;

  Movie({
    required this.title,
    required this.year,
    required this.genre,
    required this.imdbID,
    required this.type,
    required this.poster,
    this.rating,
  });

  factory Movie.fromMap(Map<String, dynamic> map) {
    return Movie(
      imdbID: map['id'] ?? '',
      title: map['title'] ?? '',
      year: map['year'] ?? '',
      genre: map['genre'] ?? '',
      poster: map['poster'] ?? '',
      type: map['type'] ?? '',
      rating: (map['rating'] is num) ? (map['rating'] as num).toDouble() : null,
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

    // Si tu veux déjà récupérer une note rapide depuis TMDb:
    final double? voteAverage = (json['vote_average'] is num)
        ? (json['vote_average'] as num).toDouble()
        : null;

    return Movie(
      title: title,
      year: year,
      genre: '',
      imdbID: json['id']?.toString() ?? '',
      type: isTv ? 'series' : 'movie',
      poster: json['poster_path'] != null
          ? 'https://image.tmdb.org/t/p/w500${json['poster_path']}'
          : 'https://dummyimage.com/400x600/cccccc/000000&text=No+Image',
      rating: voteAverage, // note de base pour le carrousel
    );
  }
}
