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
      poster: json['Poster'] != 'N/A' 
          ? json['Poster'] 
          : 'https://via.placeholder.com/400x600?text=No+Image',
    );
  }
}