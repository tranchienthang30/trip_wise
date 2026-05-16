class Review {
  Review({
    required this.id,
    required this.authorName,
    required this.authorImage,
    required this.rating,
    required this.comment,
    required this.tripType,
    required this.createdAt,
  });

  final int id;
  final String authorName;
  final String? authorImage;
  final int rating;
  final String comment;
  final String? tripType;
  final DateTime? createdAt;

  factory Review.fromJson(Map<String, dynamic> json) {
    final raw = json['createdAt'] as String?;
    return Review(
      id: json['id'] as int,
      authorName: json['authorName'] as String? ?? 'Guest',
      authorImage: json['authorImage'] as String?,
      rating: (json['rating'] as num?)?.round() ?? 0,
      comment: json['comment'] as String? ?? '',
      tripType: json['tripType'] as String?,
      createdAt: raw == null ? null : DateTime.tryParse(raw),
    );
  }
}

class ReviewsPage {
  ReviewsPage({
    required this.items,
    required this.total,
    required this.hasMore,
    required this.nextOffset,
  });

  final List<Review> items;
  final int total;
  final bool hasMore;
  final int nextOffset;

  factory ReviewsPage.fromJson(Map<String, dynamic> json) {
    return ReviewsPage(
      items: (json['items'] as List? ?? const [])
          .map((e) => Review.fromJson(e as Map<String, dynamic>))
          .toList(),
      total: json['total'] as int? ?? 0,
      hasMore: json['hasMore'] as bool? ?? false,
      nextOffset: json['nextOffset'] as int? ?? 0,
    );
  }
}

const _months = [
  'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
  'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
];

/// Short, friendly date label for a review (e.g. "Mar 2025").
String reviewDateLabel(DateTime? date) {
  if (date == null) return '';
  return '${_months[date.month - 1]} ${date.year}';
}
