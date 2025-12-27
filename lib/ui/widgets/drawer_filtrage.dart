// lib/ui/widgets/drawer_filtrage.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:cineflow/core/constants/tmdb_genres.dart';
import 'package:cineflow/providers/filtrage_provider.dart';

class DrawerFiltrage extends StatelessWidget {
  const DrawerFiltrage({super.key});

  @override
  Widget build(BuildContext context) {
    final p = context.watch<FiltrageProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final genreList = (p.type == "series")
        ? TmdbGenres.tvNames()
        : TmdbGenres.movieNames();

    return Drawer(
      backgroundColor: isDark ? const Color(0xFF0F0F0F) : Colors.white,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Filtres",
                style: TextStyle(
                  color: isDark ? Colors.white : Colors.black,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 18),

              // TYPE
              Text("Type", style: TextStyle(color: isDark ? Colors.white70 : Colors.black87)),
              const SizedBox(height: 6),
              DropdownButtonFormField<String>(
                initialValue: p.type,
                dropdownColor: isDark ? const Color(0xFF1A1A1A) : Colors.white,
                items: const [
                  DropdownMenuItem(value: "all", child: Text("All (mix)")),
                  DropdownMenuItem(value: "movie", child: Text("Movie")),
                  DropdownMenuItem(value: "series", child: Text("Series")),
                ],
                onChanged: (v) {
                  if (v == null) return;
                  context.read<FiltrageProvider>().setType(v);
                  // si on change type, on remet genre sur all pour éviter mismatch
                  context.read<FiltrageProvider>().setGenre("all");
                },
              ),

              const SizedBox(height: 16),

              // GENRE
              Text("Genre", style: TextStyle(color: isDark ? Colors.white70 : Colors.black87)),
              const SizedBox(height: 6),
              DropdownButtonFormField<String>(
                initialValue: genreList.contains(p.genre) ? p.genre : "all",
                dropdownColor: isDark ? const Color(0xFF1A1A1A) : Colors.white,
                items: genreList
                    .map((g) => DropdownMenuItem(value: g, child: Text(g)))
                    .toList(),
                onChanged: (v) {
                  if (v == null) return;
                  context.read<FiltrageProvider>().setGenre(v);
                },
              ),

              const SizedBox(height: 16),

              // YEAR
              Text("Année", style: TextStyle(color: isDark ? Colors.white70 : Colors.black87)),
              const SizedBox(height: 6),
              TextFormField(
                initialValue: p.year,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  hintText: "Ex: 2010",
                  border: OutlineInputBorder(),
                ),
                onChanged: (v) => context.read<FiltrageProvider>().setYear(v),
              ),

              const Spacer(),

              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => context.read<FiltrageProvider>().resetFilters(),
                      child: const Text("Reset"),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        Navigator.pop(context);
                        await context.read<FiltrageProvider>().search(reset: true);
                      },
                      child: const Text("Appliquer"),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
