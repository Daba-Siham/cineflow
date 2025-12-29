import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../data/models/review.dart';
import '../../core/constants/api_constants.dart';

class ReviewCard extends StatelessWidget {
  final Review review;

  const ReviewCard({super.key, required this.review});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final dateStr = DateFormat('yyyy-MM-dd').format(review.createdAt);

    String? avatarUrl;
    if (review.avatarPath != null && review.avatarPath!.isNotEmpty) {
      if (review.avatarPath!.startsWith('/https')) {
        avatarUrl = review.avatarPath!.substring(1);
      } else {
        avatarUrl =
            '${ApiConstants.tmdbImageBaseUrl}${review.avatarPath}';
      }
    }

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF181A20) : Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: Colors.grey.shade400,
                backgroundImage:
                    avatarUrl != null ? NetworkImage(avatarUrl) : null,
                child: avatarUrl == null
                    ? const Icon(Icons.person,
                        color: Colors.white, size: 20)
                    : null,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      review.author,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white : Colors.black,
                      ),
                    ),
                    Text(
                      dateStr,
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark
                            ? Colors.grey.shade400
                            : Colors.grey.shade700,
                      ),
                    ),
                  ],
                ),
              ),
              if (review.rating != null)
                Row(
                  children: [
                    const Icon(Icons.star,
                        color: Colors.amber, size: 18),
                    const SizedBox(width: 4),
                    Text(
                      review.rating!.toStringAsFixed(1),
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white : Colors.white,
                      ),
                    ),
                  ],
                ),
            ],
          ),
          const SizedBox(height: 8),
          if (review.url.isNotEmpty)
            Text(
              'FULL REVIEW @ ${review.url}',
              style: TextStyle(
                fontSize: 12,
                color: Colors.blue.shade300,
                decoration: TextDecoration.underline,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          const SizedBox(height: 6),
          Text(
            review.content,
            style: TextStyle(
              fontSize: 13,
              color: isDark ? Colors.white : Colors.black87,
            ),
            maxLines: 6,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}