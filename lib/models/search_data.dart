class SearchData {
  SearchData({
    required this.query,
    required this.category,
    required this.categories,
    required this.destinations,
    required this.hotels,
    required this.flights,
    required this.tours,
    required this.trains,
  });

  final String query;
  final String category;
  final List<SearchCategoryChip> categories;
  final List<SearchDestinationItem> destinations;
  final List<SearchHotelItem> hotels;
  final List<SearchFlightItem> flights;
  final List<SearchTourItem> tours;
  final List<dynamic> trains;

  factory SearchData.fromJson(Map<String, dynamic> json) {
    return SearchData(
      query: json['query'] as String? ?? '',
      category: json['category'] as String? ?? 'all',
      categories: (json['categories'] as List?)
              ?.map(
                (item) => SearchCategoryChip.fromJson(item as Map<String, dynamic>),
              )
              .toList() ??
          const [],
      destinations: (json['destinations'] as List?)
              ?.map(
                (item) => SearchDestinationItem.fromJson(item as Map<String, dynamic>),
              )
              .toList() ??
          const [],
      hotels: (json['hotels'] as List?)
              ?.map((item) => SearchHotelItem.fromJson(item as Map<String, dynamic>))
              .toList() ??
          const [],
      flights: (json['flights'] as List?)
              ?.map((item) => SearchFlightItem.fromJson(item as Map<String, dynamic>))
              .toList() ??
          const [],
      tours: (json['tours'] as List?)
              ?.map((item) => SearchTourItem.fromJson(item as Map<String, dynamic>))
              .toList() ??
          const [],
      trains: (json['trains'] as List?) ?? const [],
    );
  }
}

class SearchCategoryChip {
  SearchCategoryChip({
    required this.key,
    required this.label,
    required this.enabled,
  });

  final String key;
  final String label;
  final bool enabled;

  factory SearchCategoryChip.fromJson(Map<String, dynamic> json) {
    return SearchCategoryChip(
      key: json['key'] as String? ?? 'all',
      label: json['label'] as String? ?? '',
      enabled: json['enabled'] as bool? ?? true,
    );
  }
}

class SearchDestinationItem {
  SearchDestinationItem({
    required this.id,
    required this.name,
    required this.subtitle,
    required this.queryValue,
  });

  final int id;
  final String name;
  final String subtitle;
  final String queryValue;

  factory SearchDestinationItem.fromJson(Map<String, dynamic> json) {
    return SearchDestinationItem(
      id: json['id'] as int? ?? 0,
      name: json['name'] as String? ?? '',
      subtitle: json['subtitle'] as String? ?? '',
      queryValue: json['queryValue'] as String? ?? '',
    );
  }
}

class SearchHotelItem {
  SearchHotelItem({
    required this.id,
    required this.name,
    required this.locationLabel,
    required this.imageUrl,
    required this.ratingLabel,
    required this.priceLabel,
    required this.route,
  });

  final int id;
  final String name;
  final String locationLabel;
  final String? imageUrl;
  final String ratingLabel;
  final String? priceLabel;
  final String route;

  factory SearchHotelItem.fromJson(Map<String, dynamic> json) {
    return SearchHotelItem(
      id: json['id'] as int? ?? 0,
      name: json['name'] as String? ?? '',
      locationLabel: json['locationLabel'] as String? ?? '',
      imageUrl: json['imageUrl'] as String?,
      ratingLabel: json['ratingLabel'] as String? ?? '0.0',
      priceLabel: json['priceLabel'] as String?,
      route: json['route'] as String? ?? '/home',
    );
  }
}

class SearchFlightItem {
  SearchFlightItem({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.valueLabel,
    required this.metaLabel,
    required this.imageUrl,
  });

  final int id;
  final String title;
  final String subtitle;
  final String valueLabel;
  final String metaLabel;
  final String? imageUrl;

  factory SearchFlightItem.fromJson(Map<String, dynamic> json) {
    return SearchFlightItem(
      id: json['id'] as int? ?? 0,
      title: json['title'] as String? ?? '',
      subtitle: json['subtitle'] as String? ?? '',
      valueLabel: json['valueLabel'] as String? ?? '',
      metaLabel: json['metaLabel'] as String? ?? '',
      imageUrl: json['imageUrl'] as String?,
    );
  }
}

class SearchTourItem {
  SearchTourItem({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.valueLabel,
    required this.metaLabel,
    required this.imageUrl,
  });

  final int id;
  final String title;
  final String subtitle;
  final String valueLabel;
  final String metaLabel;
  final String? imageUrl;

  factory SearchTourItem.fromJson(Map<String, dynamic> json) {
    return SearchTourItem(
      id: json['id'] as int? ?? 0,
      title: json['title'] as String? ?? '',
      subtitle: json['subtitle'] as String? ?? '',
      valueLabel: json['valueLabel'] as String? ?? '',
      metaLabel: json['metaLabel'] as String? ?? '',
      imageUrl: json['imageUrl'] as String?,
    );
  }
}
