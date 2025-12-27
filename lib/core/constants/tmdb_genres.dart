// lib/core/constants/tmdb_genres.dart

class TmdbGenres {
  // Genres MOVIE
  static const Map<String, int> movie = {
    "all": 0,
    "Action": 28,
    "Aventure": 12,
    "Animation": 16,
    "Comédie": 35,
    "Crime": 80,
    "Drame": 18,
    "Familial": 10751,
    "Fantasy": 14,
    "Horreur": 27,
    "Mystère": 9648,
    "Romance": 10749,
    "Science-Fiction": 878,
    "Thriller": 53,
  };

  // Genres TV (SERIES)
  static const Map<String, int> tv = {
    "all": 0,
    "Action & Adventure": 10759,
    "Animation": 16,
    "Comédie": 35,
    "Crime": 80,
    "Drame": 18,
    "Familial": 10751,
    "Mystère": 9648,
    "Romance": 10749,
    "Science-Fiction & Fantasy": 10765,
    "Thriller": 53,
  };

  static List<String> movieNames() => movie.keys.toList();
  static List<String> tvNames() => tv.keys.toList();
}
