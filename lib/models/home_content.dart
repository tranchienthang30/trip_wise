class HomeContent {
  HomeContent({
    required this.searchCard,
    required this.categories,
    required this.sections,
    required this.featuredOffers,
    required this.recommendedDestinations,
    required this.trendingHotels,
  });

  final HomeSearchCard searchCard;
  final List<HomeCategoryItem> categories;
  final HomeSections sections;
  final List<HomeOfferItem> featuredOffers;
  final List<HomeRecommendedItem> recommendedDestinations;
  final List<HomeTrendingHotelItem> trendingHotels;

  factory HomeContent.fromJson(Map<String, dynamic> json) {
    return HomeContent(
      searchCard: HomeSearchCard.fromJson(
        (json['searchCard'] as Map<String, dynamic>?) ?? const {},
      ),
      categories: (json['categories'] as List?)
              ?.map((item) => HomeCategoryItem.fromJson(item as Map<String, dynamic>))
              .toList() ??
          const [],
      sections: HomeSections.fromJson(
        (json['sections'] as Map<String, dynamic>?) ?? const {},
      ),
      featuredOffers: (json['featuredOffers'] as List?)
              ?.map((item) => HomeOfferItem.fromJson(item as Map<String, dynamic>))
              .toList() ??
          const [],
      recommendedDestinations: (json['recommendedDestinations'] as List?)
              ?.map(
                (item) => HomeRecommendedItem.fromJson(item as Map<String, dynamic>),
              )
              .toList() ??
          const [],
      trendingHotels: (json['trendingHotels'] as List?)
              ?.map(
                (item) => HomeTrendingHotelItem.fromJson(item as Map<String, dynamic>),
              )
              .toList() ??
          const [],
    );
  }
}

class HomeSearchCard {
  HomeSearchCard({
    required this.headline,
    required this.destinationPlaceholder,
    required this.destinationRoute,
    required this.searchButtonLabel,
    required this.searchButtonRoute,
    required this.detailItems,
  });

  final String headline;
  final String destinationPlaceholder;
  final String destinationRoute;
  final String searchButtonLabel;
  final String searchButtonRoute;
  final List<HomeSearchDetailItem> detailItems;

  factory HomeSearchCard.fromJson(Map<String, dynamic> json) {
    return HomeSearchCard(
      headline: json['headline'] as String? ?? 'Where to next?',
      destinationPlaceholder: json['destinationPlaceholder'] as String? ?? 'Destination',
      destinationRoute: json['destinationRoute'] as String? ?? '/add_location_search',
      searchButtonLabel: json['searchButtonLabel'] as String? ?? 'Search Destinations',
      searchButtonRoute: json['searchButtonRoute'] as String? ?? '/search_filter',
      detailItems: (json['detailItems'] as List?)
              ?.map(
                (item) => HomeSearchDetailItem.fromJson(item as Map<String, dynamic>),
              )
              .toList() ??
          const [],
    );
  }
}

class HomeSearchDetailItem {
  HomeSearchDetailItem({
    required this.icon,
    required this.label,
    required this.value,
  });

  final String icon;
  final String label;
  final String value;

  factory HomeSearchDetailItem.fromJson(Map<String, dynamic> json) {
    return HomeSearchDetailItem(
      icon: json['icon'] as String? ?? 'calendar_today_rounded',
      label: json['label'] as String? ?? '',
      value: json['value'] as String? ?? '',
    );
  }
}

class HomeCategoryItem {
  HomeCategoryItem({
    required this.key,
    required this.icon,
    required this.label,
    required this.route,
    required this.backgroundTone,
    required this.iconTone,
  });

  final String key;
  final String icon;
  final String label;
  final String route;
  final String backgroundTone;
  final String iconTone;

  factory HomeCategoryItem.fromJson(Map<String, dynamic> json) {
    return HomeCategoryItem(
      key: json['key'] as String? ?? '',
      icon: json['icon'] as String? ?? 'explore_rounded',
      label: json['label'] as String? ?? '',
      route: json['route'] as String? ?? '/home',
      backgroundTone: json['backgroundTone'] as String? ?? 'primary_soft',
      iconTone: json['iconTone'] as String? ?? 'primary',
    );
  }
}

class HomeSections {
  HomeSections({
    required this.offers,
    required this.recommended,
    required this.trending,
  });

  final HomeOffersSection offers;
  final HomeRecommendedSection recommended;
  final HomeTrendingSection trending;

  factory HomeSections.fromJson(Map<String, dynamic> json) {
    return HomeSections(
      offers: HomeOffersSection.fromJson(
        (json['offers'] as Map<String, dynamic>?) ?? const {},
      ),
      recommended: HomeRecommendedSection.fromJson(
        (json['recommended'] as Map<String, dynamic>?) ?? const {},
      ),
      trending: HomeTrendingSection.fromJson(
        (json['trending'] as Map<String, dynamic>?) ?? const {},
      ),
    );
  }
}

class HomeOffersSection {
  HomeOffersSection({required this.badgeLabel});

  final String badgeLabel;

  factory HomeOffersSection.fromJson(Map<String, dynamic> json) {
    return HomeOffersSection(
      badgeLabel: json['badgeLabel'] as String? ?? 'LIMITED OFFER',
    );
  }
}

class HomeRecommendedSection {
  HomeRecommendedSection({
    required this.title,
    required this.subtitle,
    required this.actionLabel,
    required this.actionRoute,
  });

  final String title;
  final String subtitle;
  final String actionLabel;
  final String actionRoute;

  factory HomeRecommendedSection.fromJson(Map<String, dynamic> json) {
    return HomeRecommendedSection(
      title: json['title'] as String? ?? 'Recommended',
      subtitle: json['subtitle'] as String? ?? '',
      actionLabel: json['actionLabel'] as String? ?? 'See all',
      actionRoute: json['actionRoute'] as String? ?? '/search_filter',
    );
  }
}

class HomeTrendingSection {
  HomeTrendingSection({
    required this.title,
    required this.detailsActionLabel,
    required this.actionLabel,
    required this.actionRoute,
  });

  final String title;
  final String detailsActionLabel;
  final String? actionLabel;
  final String? actionRoute;

  factory HomeTrendingSection.fromJson(Map<String, dynamic> json) {
    return HomeTrendingSection(
      title: json['title'] as String? ?? 'Trending Hotels',
      detailsActionLabel: json['detailsActionLabel'] as String? ?? 'DETAILS',
      actionLabel: json['actionLabel'] as String?,
      actionRoute: json['actionRoute'] as String?,
    );
  }
}

class HomeOfferItem {
  HomeOfferItem({
    required this.hotelId,
    required this.hotelName,
    required this.imageUrl,
    required this.destinationName,
    required this.locationLabel,
    required this.priceFrom,
    required this.priceLabel,
    required this.currency,
    required this.rating,
    required this.ratingLabel,
    required this.title,
    required this.subtitle,
    required this.badgeLabel,
    required this.ctaLabel,
    required this.accentTone,
    required this.route,
  });

  final int hotelId;
  final String hotelName;
  final String? imageUrl;
  final String destinationName;
  final String locationLabel;
  final double? priceFrom;
  final String? priceLabel;
  final String currency;
  final double rating;
  final String ratingLabel;
  final String title;
  final String subtitle;
  final String badgeLabel;
  final String ctaLabel;
  final String accentTone;
  final String route;

  factory HomeOfferItem.fromJson(Map<String, dynamic> json) {
    return HomeOfferItem(
      hotelId: json['hotelId'] as int? ?? 0,
      hotelName: json['hotelName'] as String? ?? '',
      imageUrl: json['imageUrl'] as String?,
      destinationName: json['destinationName'] as String? ?? '',
      locationLabel: json['locationLabel'] as String? ?? '',
      priceFrom: (json['priceFrom'] as num?)?.toDouble(),
      priceLabel: json['priceLabel'] as String?,
      currency: json['currency'] as String? ?? 'VND',
      rating: (json['rating'] as num?)?.toDouble() ?? 0,
      ratingLabel: json['ratingLabel'] as String? ?? '0.0',
      title: json['title'] as String? ?? '',
      subtitle: json['subtitle'] as String? ?? '',
      badgeLabel: json['badgeLabel'] as String? ?? 'LIMITED OFFER',
      ctaLabel: json['ctaLabel'] as String? ?? 'BOOK NOW',
      accentTone: json['accentTone'] as String? ?? 'primary',
      route: json['route'] as String? ?? '/home',
    );
  }
}

class HomeRecommendedItem {
  HomeRecommendedItem({
    required this.hotelId,
    required this.hotelName,
    required this.imageUrl,
    required this.destinationName,
    required this.locationLabel,
    required this.priceFrom,
    required this.priceLabel,
    required this.currency,
    required this.rating,
    required this.ratingLabel,
    required this.title,
    required this.caption,
    required this.cardHeight,
    required this.route,
  });

  final int hotelId;
  final String hotelName;
  final String? imageUrl;
  final String destinationName;
  final String locationLabel;
  final double? priceFrom;
  final String? priceLabel;
  final String currency;
  final double rating;
  final String ratingLabel;
  final String title;
  final String caption;
  final double cardHeight;
  final String route;

  factory HomeRecommendedItem.fromJson(Map<String, dynamic> json) {
    return HomeRecommendedItem(
      hotelId: json['hotelId'] as int? ?? 0,
      hotelName: json['hotelName'] as String? ?? '',
      imageUrl: json['imageUrl'] as String?,
      destinationName: json['destinationName'] as String? ?? '',
      locationLabel: json['locationLabel'] as String? ?? '',
      priceFrom: (json['priceFrom'] as num?)?.toDouble(),
      priceLabel: json['priceLabel'] as String?,
      currency: json['currency'] as String? ?? 'VND',
      rating: (json['rating'] as num?)?.toDouble() ?? 0,
      ratingLabel: json['ratingLabel'] as String? ?? '0.0',
      title: json['title'] as String? ?? '',
      caption: json['caption'] as String? ?? '',
      cardHeight: (json['cardHeight'] as num?)?.toDouble() ?? 220,
      route: json['route'] as String? ?? '/home',
    );
  }
}

class HomeTrendingHotelItem {
  HomeTrendingHotelItem({
    required this.hotelId,
    required this.hotelName,
    required this.imageUrl,
    required this.destinationName,
    required this.locationLabel,
    required this.priceFrom,
    required this.priceLabel,
    required this.currency,
    required this.rating,
    required this.ratingLabel,
    required this.name,
    required this.location,
    required this.detailsLabel,
    required this.route,
  });

  final int hotelId;
  final String hotelName;
  final String? imageUrl;
  final String destinationName;
  final String locationLabel;
  final double? priceFrom;
  final String? priceLabel;
  final String currency;
  final double rating;
  final String ratingLabel;
  final String name;
  final String location;
  final String detailsLabel;
  final String route;

  factory HomeTrendingHotelItem.fromJson(Map<String, dynamic> json) {
    return HomeTrendingHotelItem(
      hotelId: json['hotelId'] as int? ?? 0,
      hotelName: json['hotelName'] as String? ?? '',
      imageUrl: json['imageUrl'] as String?,
      destinationName: json['destinationName'] as String? ?? '',
      locationLabel: json['locationLabel'] as String? ?? '',
      priceFrom: (json['priceFrom'] as num?)?.toDouble(),
      priceLabel: json['priceLabel'] as String?,
      currency: json['currency'] as String? ?? 'VND',
      rating: (json['rating'] as num?)?.toDouble() ?? 0,
      ratingLabel: json['ratingLabel'] as String? ?? '0.0',
      name: json['name'] as String? ?? '',
      location: json['location'] as String? ?? '',
      detailsLabel: json['detailsLabel'] as String? ?? 'DETAILS',
      route: json['route'] as String? ?? '/home',
    );
  }
}
