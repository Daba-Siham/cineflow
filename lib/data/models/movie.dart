class Movie {
  final String title;
  final String year;
  final String imdbID;
  final String type;
  final String poster;

  Movie({
    required this.title,
    required this.year,
    required this.imdbID,
    required this.type,
    required this.poster,
  });

  factory Movie.fromJson(Map<String, dynamic> json) {
    return Movie(
      title: json['Title'] ?? '',
      year: json['Year'] ?? '',
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