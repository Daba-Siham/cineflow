class Movie {
  final String title;
  final String year;
  final String imdbID;
  final String type;
  final String poster;

  final String? genre;
  final String? imdbRating;

  Movie({
    required this.title,
    required this.year,
    required this.imdbID,
    required this.type,
    required this.poster,
    this.genre,
    this.imdbRating,
  });

  factory Movie.fromJson(Map<String, dynamic> json) {
    final poster = (json['Poster'] ?? '').toString();
    return Movie(
      title: (json['Title'] ?? '').toString(),
      year: (json['Year'] ?? '').toString(),
      imdbID: (json['imdbID'] ?? '').toString(),
      type: (json['Type'] ?? '').toString(),
      poster: (poster.isNotEmpty && poster != 'N/A')
          ? poster
          : 'https://via.placeholder.com/400x600?text=No+Image',
    );
  }

  factory Movie.fromMap(Map<String, dynamic> map) {
    return Movie(
      imdbID: (map['id'] ?? '').toString(),
      title: (map['title'] ?? '').toString(),
      year: (map['year'] ?? '').toString(),
      poster: (map['poster'] ?? '').toString(),
      type: (map['type'] ?? '').toString(),
      genre: (map['genre'] ?? '').toString(),
      imdbRating: (map['imdbRating'] ?? '').toString(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': imdbID,
      'title': title,
      'year': year,
      'poster': poster,
      'type': type,
      'genre': genre ?? '',
      'imdbRating': imdbRating ?? '',
    };
  }

  Movie copyWith({String? genre, String? imdbRating}) {
    return Movie(
      title: title,
      year: year,
      imdbID: imdbID,
      type: type,
      poster: poster,
      genre: genre ?? this.genre,
      imdbRating: imdbRating ?? this.imdbRating,
    );
  }
}
