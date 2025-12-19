class Movie {
  final String title;
  final String year;
  final String genre;
  final String imdbID;
  final String type;
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

  factory Movie.fromJson(Map<String, dynamic> json) {
    return Movie(
      title: json['Title'] ?? '',
      year: json['Year'] ?? '',
      genre: json['Genre'] ?? '',
      imdbID: json['imdbID'] ?? '',
      type: json['Type'] ?? '',
      // si il n'y a pas de poster, la valeur et N/A
      poster: json['Poster'] != 'N/A' 
          // S'il existe, on affiche Poster
          ? json['Poster'] 
          // Sinon on affiche cette image dans cet URL
          : 'https://dummyimage.com/400x600/cccccc/000000&text=No+Image',
    );
  }
}