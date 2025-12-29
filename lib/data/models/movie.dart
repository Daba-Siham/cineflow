class Movie {
  final String title;
  final String year;
  final String genre;
  final String imdbID; 
  final String type; 
  final String poster;
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
    final id = (map['tmdb_id'] ?? map['id'] ?? '').toString();
    return Movie(
      imdbID: id,
      title: (map['title'] ?? '').toString(),
      year: (map['year'] ?? '').toString(),
      genre: (map['genre'] ?? '').toString(),
      poster: (map['poster'] ?? '').toString(),
      type: (map['type'] ?? '').toString(),
      rating: map['rating'] is num ? (map['rating'] as num).toDouble() : null,
    );
  }
  Map<String, dynamic> toMap() {
    return {
      'id': imdbID,
      'title': title,
      'year': year,
      'genre': genre,
      'poster': poster,
      'type': type,
      'rating': rating,
    };
  }

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
      rating: voteAverage,
    );
  }
}
