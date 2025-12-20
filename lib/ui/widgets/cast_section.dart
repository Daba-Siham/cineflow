// cast_section.dart
import 'package:flutter/material.dart';

class CastSection extends StatelessWidget {
  final String actors; // chaîne venant de MovieDetail.actors

  const CastSection({super.key, required this.actors});

  @override
  Widget build(BuildContext context) {
    if (actors.isEmpty) return const SizedBox.shrink();

    // On découpe "A, B, C" en liste
    final List<String> names = actors.split(',').map((e) => e.trim()).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.0),
          child: Text(
            'CAST',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 130,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: names.length,
            itemBuilder: (context, index) {
              final name = names[index];

              return Padding(
                padding: EdgeInsets.only(
                  left: index == 0 ? 1 : 10,
                  right: index == names.length - 1 ? 1 : 0,
                ),
                child: Column(
                  children: [
                    // Pour l’instant, avatar générique (pas de photo dans OMDb pour chaque acteur) [web:13]
                    CircleAvatar(
                      radius: 35,
                      backgroundColor: Colors.red.withOpacity(0.7),
                      child: Text(
                        name.isNotEmpty ? name[0] : '?',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      width: 80,
                      child: Text(
                        name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
