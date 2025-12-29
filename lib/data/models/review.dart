class Review {
  final String id;
  final String author;
  final String? username;
  final String? avatarPath;
  final double? rating;
  final DateTime createdAt;
  final String content;
  final String url;

  Review({
    required this.id,
    required this.author,
    required this.createdAt,
    required this.content,
    required this.url,
    this.username,
    this.avatarPath,
    this.rating,
  });

  factory Review.fromJson(Map<String, dynamic> json) {
    final details = json['author_details'] as Map<String, dynamic>? ?? {};
    final ratingRaw = details['rating'];
    double? parsedRating;
    if (ratingRaw is num) parsedRating = ratingRaw.toDouble();

    return Review(
      id: json['id'] ?? '',
      author: json['author'] ?? '',
      username: details['username'] as String?,
      avatarPath: details['avatar_path'] as String?,
      rating: parsedRating,
      createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
      content: json['content'] ?? '',
      url: json['url'] ?? '',
    );
  }
}