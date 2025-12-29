// lib/ui/views/offline_movie_details_page.dart
import 'package:flutter/material.dart';
import 'package:cineflow/data/models/movie.dart';

class OfflineMovieDetailsPage extends StatelessWidget {
  final Movie movie;

  const OfflineMovieDetailsPage({super.key, required this.movie});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Stack(
        children: [
          // Fond (pas d'image réseau, on reste hors ligne)
          Container(
            height: 300,
            width: double.infinity,
            color: Colors.black,
          ),

          SafeArea(
            child: Column(
              children: [
                // Barre du haut : retour + badge "hors ligne"
                Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 10,
                    horizontal: 25,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      InkWell(
                        onTap: () => Navigator.pop(context),
                        child: Icon(
                          Icons.arrow_back,
                          color: isDark ? Colors.white : Colors.black,
                          size: 30,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.8),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Row(
                          children: [
                            Icon(
                              Icons.download_done,
                              size: 16,
                              color: Colors.white,
                            ),
                            SizedBox(width: 4),
                            Text(
                              "Disponible hors ligne",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Poster (placeholder, pas d'appel réseau)
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 15,
                    vertical: 0,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: const Color.fromARGB(
                                255,
                                229,
                                191,
                                188,
                              ).withOpacity(0.5),
                              spreadRadius: 1,
                              blurRadius: 8,
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: Container(
                            height: 250,
                            width: 180,
                            color: Colors.grey[800],
                            child: Icon(
                              Icons.movie,
                              color: isDark ? Colors.white : Colors.black,
                              size: 60,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                Expanded(
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 20,
                        horizontal: 10,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Titre + année
                          Text(
                            '${movie.title} (${movie.year})',
                            style: TextStyle(
                              color: isDark ? Colors.white : Colors.black,
                              fontSize: 26,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 10),

                          // Genre (si dispo)
                          if (movie.genre != null &&
                              movie.genre!.isNotEmpty)
                            Text(
                              movie.genre!,
                              style: TextStyle(
                                color: isDark
                                    ? Colors.grey[300]
                                    : Colors.grey[800],
                                fontSize: 14,
                              ),
                            ),

                          const SizedBox(height: 15),

                          // Note (si dispo)
                          if (movie.rating != null)
                            Row(
                              children: [
                                const Icon(
                                  Icons.star,
                                  color: Colors.amber,
                                  size: 20,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  movie.rating!.toString(),
                                  style: TextStyle(
                                    color: isDark
                                        ? Colors.white
                                        : Colors.black,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),

                          const SizedBox(height: 20),

                          // Texte explicatif
                          Text(
                            "Ce titre a été enregistré dans vos téléchargements.\n"
                            "En mode hors ligne, seules les informations de base "
                            "sont disponibles : titre, année, genre et note "
                            "(si elle a été enregistrée).",
                            style: TextStyle(
                              color: isDark
                                  ? Colors.white
                                  : Colors.black87,
                              fontSize: 15,
                            ),
                            textAlign: TextAlign.justify,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
