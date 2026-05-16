class CatalogActivity {
  CatalogActivity({
    required this.id,
    required this.title,
    required this.description,
    required this.rating,
    required this.image,
    required this.category,
    required this.location,
  });

  final int id;
  final String title;
  final String? description;
  final double rating;
  final String? image;
  final String category;
  final String location;

  factory CatalogActivity.fromJson(Map<String, dynamic> json) {
    return CatalogActivity(
      id: (json['id'] as num?)?.toInt() ?? 0,
      title: json['title'] as String? ?? '',
      description: json['description'] as String?,
      rating: (json['rating'] as num?)?.toDouble() ?? 0,
      image: json['image'] as String?,
      category: json['category'] as String? ?? 'SIGHTSEEING',
      location: json['location'] as String? ?? '',
    );
  }
}

class ActivityCatalog {
  ActivityCatalog({
    required this.categories,
    required this.recommended,
    required this.popular,
  });

  final List<String> categories;
  final CatalogActivity? recommended;
  final List<CatalogActivity> popular;

  factory ActivityCatalog.fromJson(Map<String, dynamic> json) {
    return ActivityCatalog(
      categories: ((json['categories'] as List<dynamic>?) ?? const [])
          .map((e) => e as String)
          .toList(),
      recommended: json['recommended'] == null
          ? null
          : CatalogActivity.fromJson(
              json['recommended'] as Map<String, dynamic>,
            ),
      popular: ((json['popular'] as List<dynamic>?) ?? const [])
          .map((e) => CatalogActivity.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}
