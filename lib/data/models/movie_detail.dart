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
  });

  factory MovieDetail.fromJson(Map<String, dynamic> json) {
    return MovieDetail(
      title: (json['Title'] ?? '').toString(),
      year: (json['Year'] ?? '').toString(),
      rated: (json['Rated'] ?? '').toString(),
      released: (json['Released'] ?? '').toString(),
      runtime: (json['Runtime'] ?? '').toString(),
      genre: (json['Genre'] ?? '').toString(),
      director: (json['Director'] ?? '').toString(),
      actors: (json['Actors'] ?? '').toString(),
      plot: (json['Plot'] ?? '').toString(),
      poster: (json['Poster'] ?? '').toString(),
      imdbRating: (json['imdbRating'] ?? '').toString(),
    );
  }
}
