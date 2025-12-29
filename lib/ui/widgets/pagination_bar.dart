import 'package:flutter/material.dart';

class PaginationBar extends StatelessWidget {
  final int currentPage;
  final int totalPages;

  final int groupStart;
  final bool isDark;

  final VoidCallback onPrevGroup;
  final VoidCallback onNextGroup;
  final ValueChanged<int> onPageSelected;

  const PaginationBar({
    super.key,
    required this.currentPage,
    required this.totalPages,
    required this.groupStart,
    required this.isDark,
    required this.onPrevGroup,
    required this.onNextGroup,
    required this.onPageSelected,
  });

  @override
  Widget build(BuildContext context) {
    final bg = isDark ? Colors.white.withOpacity(0.06) : Colors.black.withOpacity(0.05);
    final border = isDark ? Colors.white.withOpacity(0.12) : Colors.black.withOpacity(0.10);
    final text = isDark ? Colors.white : Colors.black;
    final muted = isDark ? Colors.white.withOpacity(0.35) : Colors.black.withOpacity(0.35);

    final int end = (groupStart + 4) > totalPages ? totalPages : (groupStart + 4);
    final pages = <int>[];
    for (int p = groupStart; p <= end; p++) {
      pages.add(p);
    }

    final bool canPrev = groupStart > 1;
    final bool canNext = end < totalPages;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: border),
        ),
        child: Row(
          children: [
            IconButton(
              onPressed: canPrev ? onPrevGroup : null,
              icon: Icon(Icons.chevron_left, color: canPrev ? text : muted),
            ),

            const SizedBox(width: 6),

            Expanded(
              child: Wrap(
                alignment: WrapAlignment.center,
                spacing: 8,
                runSpacing: 8,
                children: pages.map((p) {
                  final selected = p == currentPage;

                  return InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () => onPageSelected(p),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: selected
                            ? Colors.redAccent
                            : (isDark ? Colors.white.withOpacity(0.08) : Colors.white),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: selected
                              ? Colors.redAccent
                              : (isDark
                                  ? Colors.white.withOpacity(0.12)
                                  : Colors.black.withOpacity(0.08)),
                        ),
                        boxShadow: selected
                            ? [
                                BoxShadow(
                                  color: Colors.redAccent.withOpacity(0.25),
                                  blurRadius: 10,
                                  offset: const Offset(0, 6),
                                )
                              ]
                            : [],
                      ),
                      child: Text(
                        "$p",
                        style: TextStyle(
                          color: selected ? Colors.white : text,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),

            const SizedBox(width: 6),

            IconButton(
              onPressed: canNext ? onNextGroup : null,
              icon: Icon(Icons.chevron_right, color: canNext ? text : muted),
            ),
          ],
        ),
      ),
    );
  }
}