import 'package:flutter/material.dart';

class PaginationBar extends StatelessWidget {
  final int currentPage;
  final int totalPages;
  final ValueChanged<int> onPageSelected;
  final int windowSize;

  const PaginationBar({
    super.key,
    required this.currentPage,
    required this.totalPages,
    required this.onPageSelected,
    this.windowSize = 10,
  });

  @override
  Widget build(BuildContext context) {
    if (totalPages <= 1) return const SizedBox.shrink();

    final start = _windowStart(currentPage, windowSize, totalPages);
    final end = (start + windowSize - 1).clamp(1, totalPages);

    final pages = <int>[for (int p = start; p <= end; p++) p];

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            onPressed:
                currentPage > 1 ? () => onPageSelected(currentPage - 1) : null,
            icon: const Icon(Icons.chevron_left),
          ),
          const SizedBox(width: 6),
          ...pages.map((p) => _pageChip(context, p)),
          const SizedBox(width: 6),
          IconButton(
            onPressed: currentPage < totalPages
                ? () => onPageSelected(currentPage + 1)
                : null,
            icon: const Icon(Icons.chevron_right),
          ),
        ],
      ),
    );
  }

  int _windowStart(int current, int window, int total) {
    final start = current - window + 1;
    if (start < 1) return 1;

    final maxStart = total - window + 1;
    if (maxStart < 1) return 1;
    if (start > maxStart) return maxStart;

    return start;
  }

  Widget _pageChip(BuildContext context, int page) {
    final isActive = page == currentPage;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => onPageSelected(page),
        child: Container(
          width: 40,
          height: 40,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isActive ? Colors.redAccent : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: Text(
            "$page",
            style: TextStyle(
              color: isActive ? Colors.white : Colors.black,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}
