import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/movie_provider.dart';

class HomeFilterBar extends StatelessWidget {
  const HomeFilterBar({super.key});

  Future<void> _openTypeDialog(BuildContext context) async {
    final provider = context.read<MovieProvider>();

    final types = const [
      ("", "Tous"),
      ("movie", "Film"),
      ("series", "Série"),
      ("episode", "Épisode"),
    ];

    final selected = await showDialog<String>(
      context: context,
      barrierDismissible: true,
      builder: (_) => _NetflixPickerDialog(
        title: "Type",
        items: types.map((t) => _PickItem(value: t.$1, label: t.$2)).toList(),
        initialValue: provider.selectedType,
      ),
    );

    if (selected != null) provider.setType(selected);
  }

  Future<void> _openYearDialog(BuildContext context) async {
    final provider = context.read<MovieProvider>();
    final controller = TextEditingController(text: provider.selectedYear);

    final year = await showDialog<String>(
      context: context,
      barrierDismissible: true,
      builder: (_) => _NetflixYearDialog(controller: controller),
    );

    if (year != null) provider.setYear(year.trim());
  }

  Future<void> _openGenreDialog(BuildContext context) async {
    final provider = context.read<MovieProvider>();
    final genres = provider.availableGenres;

    if (genres.isEmpty) {
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Chargement des genres… Essaie après quelques secondes."),
        ),
      );
      return;
    }

    final items = <_PickItem>[
      const _PickItem(value: "", label: "Tous"),
      ...genres.map((g) => _PickItem(value: g, label: g)),
    ];

    final selected = await showDialog<String>(
      context: context,
      barrierDismissible: true,
      builder: (_) => _NetflixPickerDialog(
        title: "Genre",
        items: items,
        initialValue: provider.selectedGenre,
        enableSearch: true, 
      ),
    );

    if (selected != null) provider.setGenre(selected);
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<MovieProvider>();

    String typeLabel() {
      switch (provider.selectedType) {
        case "movie":
          return "Film";
        case "series":
          return "Série";
        case "episode":
          return "Épisode";
        default:
          return "Type";
      }
    }

    String yearLabel() =>
        provider.selectedYear.isEmpty ? "Année" : provider.selectedYear;

    String genreLabel() =>
        provider.selectedGenre.isEmpty ? "Genre" : provider.selectedGenre;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _NetflixChip(
                label: typeLabel(),
                isActive: provider.selectedType.isNotEmpty,
                onTap: () => _openTypeDialog(context),
              ),
              const SizedBox(width: 10),
              _NetflixChip(
                label: yearLabel(),
                isActive: provider.selectedYear.isNotEmpty,
                onTap: () => _openYearDialog(context),
              ),
              const SizedBox(width: 10),
              _NetflixChip(
                label: genreLabel(),
                isActive: provider.selectedGenre.isNotEmpty,
                onTap: () => _openGenreDialog(context),
              ),
            ],
          ),
        ),

        const SizedBox(height: 12),

        // ✅ Buttons row
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                icon: const Icon(Icons.restart_alt),
                label: const Text("Réinitialiser"),
                onPressed: () async {
                  // reset fields
                  context.read<MovieProvider>().setType("");
                  context.read<MovieProvider>().setYear("");
                  context.read<MovieProvider>().setGenre("");
                  // reload default list
                  await context.read<MovieProvider>().discoverOnHome(query: "star", page: 1);
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton.icon(
                icon: const Icon(Icons.filter_alt),
                label: const Text("Appliquer"),
                onPressed: () async {
                  await context.read<MovieProvider>().applyFilters(seedQuery: "star");
                },
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// ==========================
// ==========================
class _NetflixChip extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _NetflixChip({
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final borderColor = isActive ? Colors.red : Colors.transparent;
    final bg = Colors.grey.withValues(alpha: 0.20);

    return InkWell(
      borderRadius: BorderRadius.circular(22),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: borderColor, width: 1.5),
          boxShadow: isActive
              ? [
                  BoxShadow(
                    color: Colors.red.withValues(alpha: 0.25),
                    blurRadius: 10,
                    spreadRadius: 1,
                  )
                ]
              : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: isActive ? Colors.white : Colors.white70,
          ),
        ),
      ),
    );
  }
}

// ==========================
// ✅ Reusable picker dialog
// ==========================
class _PickItem {
  final String value;
  final String label;
  const _PickItem({required this.value, required this.label});
}

class _NetflixPickerDialog extends StatefulWidget {
  final String title;
  final List<_PickItem> items;
  final String initialValue;
  final bool enableSearch;

  const _NetflixPickerDialog({
    required this.title,
    required this.items,
    required this.initialValue,
    this.enableSearch = false,
  });

  @override
  State<_NetflixPickerDialog> createState() => _NetflixPickerDialogState();
}

class _NetflixPickerDialogState extends State<_NetflixPickerDialog> {
  late List<_PickItem> filtered;
  String q = "";

  @override
  void initState() {
    super.initState();
    filtered = widget.items;
  }

  void _filter(String text) {
    setState(() {
      q = text;
      if (q.trim().isEmpty) {
        filtered = widget.items;
      } else {
        filtered = widget.items
            .where((e) => e.label.toLowerCase().contains(q.toLowerCase()))
            .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final selected = widget.initialValue;

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
      backgroundColor: Colors.transparent,
      child: Container(
        width: 420,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF151515),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Colors.white10),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.6),
              blurRadius: 18,
              offset: const Offset(0, 10),
            )
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // title
            Row(
              children: [
                Text(
                  widget.title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close, color: Colors.white70),
                )
              ],
            ),

            if (widget.enableSearch) ...[
              TextField(
                onChanged: _filter,
                decoration: InputDecoration(
                  hintText: "Rechercher...",
                  hintStyle: const TextStyle(color: Colors.white38),
                  prefixIcon: const Icon(Icons.search, color: Colors.white54),
                  filled: true,
                  fillColor: Colors.white.withValues(alpha: 0.06),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 10),
            ],

            ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 340),
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: filtered.length,
                separatorBuilder: (_, __) => const Divider(height: 1, color: Colors.white10),
                itemBuilder: (_, i) {
                  final it = filtered[i];
                  final isSel = it.value == selected;

                  return ListTile(
                    title: Text(
                      it.label,
                      style: const TextStyle(color: Colors.white),
                    ),
                    trailing: isSel
                        ? const Icon(Icons.check, color: Colors.red)
                        : null,
                    onTap: () => Navigator.pop(context, it.value),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ==========================
// ✅ Year dialog
// ==========================
class _NetflixYearDialog extends StatelessWidget {
  final TextEditingController controller;
  const _NetflixYearDialog({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: 360,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF151515),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Colors.white10),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.6),
              blurRadius: 18,
              offset: const Offset(0, 10),
            )
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                const Text(
                  "Année",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.white),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close, color: Colors.white70),
                )
              ],
            ),
            TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                hintText: "Ex: 2020",
                hintStyle: const TextStyle(color: Colors.white38),
                filled: true,
                fillColor: Colors.white.withValues(alpha: 0.06),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context, ""),
                    child: const Text("Effacer"),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context, controller.text),
                    child: const Text("OK"),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
