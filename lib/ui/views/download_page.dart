// lib/ui/views/downloads_page.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:cineflow/providers/downloads_provider.dart';
import 'package:cineflow/ui/widgets/movie_card.dart';
import 'package:cineflow/ui/widgets/empty_state.dart';

class DownloadsPage extends StatelessWidget {
  const DownloadsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final dProvider = context.watch<DownloadsProvider>();
    final downloads = dProvider.downloads;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Téléchargements'),
      ),
      body: downloads.isEmpty
          ? const Center(
              child: EmptyState(
                message: 'Aucun film téléchargé.',
              ),
            )
          : GridView.builder(
              padding: const EdgeInsets.all(8),
              gridDelegate:
                  const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.65,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
              ),
              itemCount: downloads.length,
              itemBuilder: (context, index) {
                return MovieCard(movie: downloads[index]);
              },
            ),
    );
  }
}
