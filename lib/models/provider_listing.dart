class ProviderListingsResponse {
  ProviderListingsResponse({
    required this.query,
    required this.status,
    required this.counts,
    required this.featured,
    required this.items,
  });

  final String query;
  final String status;
  final ProviderListingsCounts counts;
  final ProviderListingSummary? featured;
  final List<ProviderListingSummary> items;

  factory ProviderListingsResponse.fromJson(Map<String, dynamic> json) {
    return ProviderListingsResponse(
      query: json['query'] as String? ?? '',
      status: json['status'] as String? ?? 'all',
      counts: ProviderListingsCounts.fromJson(
        (json['counts'] as Map<String, dynamic>?) ?? const {},
      ),
      featured: json['featured'] is Map<String, dynamic>
          ? ProviderListingSummary.fromJson(
              json['featured'] as Map<String, dynamic>,
            )
          : null,
      items: (json['items'] as List? ?? const [])
          .whereType<Map<String, dynamic>>()
          .map(ProviderListingSummary.fromJson)
          .toList(),
    );
  }
}

class ProviderListingsCounts {
  ProviderListingsCounts({
    required this.all,
    required this.active,
    required this.inactive,
    required this.pending,
  });

  final int all;
  final int active;
  final int inactive;
  final int pending;

  factory ProviderListingsCounts.fromJson(Map<String, dynamic> json) {
    return ProviderListingsCounts(
      all: (json['all'] as num?)?.toInt() ?? 0,
      active: (json['active'] as num?)?.toInt() ?? 0,
      inactive: (json['inactive'] as num?)?.toInt() ?? 0,
      pending: (json['pending'] as num?)?.toInt() ?? 0,
    );
  }

  int valueFor(String status) {
    switch (status) {
      case 'active':
        return active;
      case 'inactive':
        return inactive;
      case 'pending':
        return pending;
      case 'all':
      default:
        return all;
    }
  }
}

class ProviderListingSummary {
  ProviderListingSummary({
    required this.id,
    required this.title,
    required this.location,
    required this.status,
    required this.statusLabel,
    required this.imageUrl,
    required this.category,
    required this.tierLabel,
    required this.roomType,
    required this.pricePerNight,
    required this.priceLabel,
    required this.editRoute,
    required this.analyticsRoute,
  });

  final int id;
  final String title;
  final String location;
  final String status;
  final String statusLabel;
  final String imageUrl;
  final String category;
  final String tierLabel;
  final String roomType;
  final double pricePerNight;
  final String priceLabel;
  final String editRoute;
  final String analyticsRoute;

  bool get isActive => status == 'active';

  factory ProviderListingSummary.fromJson(Map<String, dynamic> json) {
    return ProviderListingSummary(
      id: (json['id'] as num?)?.toInt() ?? 0,
      title: json['title'] as String? ?? 'Untitled listing',
      location: json['location'] as String? ?? '',
      status: json['status'] as String? ?? 'active',
      statusLabel: json['statusLabel'] as String? ?? 'Active',
      imageUrl: json['imageUrl'] as String? ?? '',
      category: json['category'] as String? ?? 'Hotel',
      tierLabel: json['tierLabel'] as String? ?? 'Standard',
      roomType: json['roomType'] as String? ?? 'Room',
      pricePerNight: (json['pricePerNight'] as num?)?.toDouble() ?? 0,
      priceLabel: json['priceLabel'] as String? ?? '',
      editRoute: json['editRoute'] as String? ?? '/provider_listings',
      analyticsRoute: json['analyticsRoute'] as String? ?? '/provider_listings',
    );
  }
}

class ProviderListingDetail {
  ProviderListingDetail({
    required this.id,
    required this.title,
    required this.description,
    required this.location,
    required this.address,
    required this.status,
    required this.category,
    required this.imageUrl,
    required this.images,
    required this.pricePerNight,
    required this.currency,
    required this.roomType,
    required this.bedrooms,
    required this.bathrooms,
    required this.maxGuests,
    required this.amenities,
  });

  final int id;
  final String title;
  final String description;
  final String location;
  final String address;
  final String status;
  final String category;
  final String imageUrl;
  final List<String> images;
  final double pricePerNight;
  final String currency;
  final String roomType;
  final int bedrooms;
  final int bathrooms;
  final int maxGuests;
  final List<String> amenities;

  factory ProviderListingDetail.fromJson(Map<String, dynamic> json) {
    return ProviderListingDetail(
      id: (json['id'] as num?)?.toInt() ?? 0,
      title: json['title'] as String? ?? 'Untitled listing',
      description: json['description'] as String? ?? '',
      location: json['location'] as String? ?? '',
      address: json['address'] as String? ?? '',
      status: json['status'] as String? ?? 'active',
      category: json['category'] as String? ?? 'Hotel',
      imageUrl: json['imageUrl'] as String? ?? '',
      images: (json['images'] as List? ?? const [])
          .map((e) => e.toString())
          .toList(),
      pricePerNight: (json['pricePerNight'] as num?)?.toDouble() ?? 0,
      currency: json['currency'] as String? ?? 'USD',
      roomType: json['roomType'] as String? ?? 'Room',
      bedrooms: (json['bedrooms'] as num?)?.toInt() ?? 1,
      bathrooms: (json['bathrooms'] as num?)?.toInt() ?? 1,
      maxGuests: (json['maxGuests'] as num?)?.toInt() ?? 2,
      amenities: (json['amenities'] as List? ?? const [])
          .map((e) => e.toString())
          .toList(),
    );
  }
}

class ProviderListingAnalytics {
  ProviderListingAnalytics({
    required this.listingId,
    required this.period,
    required this.kpis,
    required this.trend,
    required this.topDays,
    required this.bookingSources,
    required this.guestStats,
  });

  final int listingId;
  final String period;
  final ProviderListingKpis kpis;
  final List<ProviderTrendPoint> trend;
  final List<ProviderTopDay> topDays;
  final List<ProviderBookingSource> bookingSources;
  final ProviderGuestStats guestStats;

  factory ProviderListingAnalytics.fromJson(Map<String, dynamic> json) {
    return ProviderListingAnalytics(
      listingId: (json['listingId'] as num?)?.toInt() ?? 0,
      period: json['period'] as String? ?? '30d',
      kpis: ProviderListingKpis.fromJson(
        (json['kpis'] as Map<String, dynamic>?) ?? const {},
      ),
      trend: (json['trend'] as List? ?? const [])
          .whereType<Map<String, dynamic>>()
          .map(ProviderTrendPoint.fromJson)
          .toList(),
      topDays: (json['topDays'] as List? ?? const [])
          .whereType<Map<String, dynamic>>()
          .map(ProviderTopDay.fromJson)
          .toList(),
      bookingSources: (json['bookingSources'] as List? ?? const [])
          .whereType<Map<String, dynamic>>()
          .map(ProviderBookingSource.fromJson)
          .toList(),
      guestStats: ProviderGuestStats.fromJson(
        (json['guestStats'] as Map<String, dynamic>?) ?? const {},
      ),
    );
  }
}

class ProviderListingKpis {
  ProviderListingKpis({
    required this.totalViews,
    required this.viewsDeltaPct,
    required this.bookings,
    required this.bookingsDeltaPct,
    required this.revenue,
    required this.revenueDeltaPct,
    required this.averageRating,
    required this.ratingDelta,
  });

  final int totalViews;
  final double viewsDeltaPct;
  final int bookings;
  final double bookingsDeltaPct;
  final double revenue;
  final double revenueDeltaPct;
  final double averageRating;
  final double ratingDelta;

  factory ProviderListingKpis.fromJson(Map<String, dynamic> json) {
    return ProviderListingKpis(
      totalViews: (json['totalViews'] as num?)?.toInt() ?? 0,
      viewsDeltaPct: (json['viewsDeltaPct'] as num?)?.toDouble() ?? 0,
      bookings: (json['bookings'] as num?)?.toInt() ?? 0,
      bookingsDeltaPct: (json['bookingsDeltaPct'] as num?)?.toDouble() ?? 0,
      revenue: (json['revenue'] as num?)?.toDouble() ?? 0,
      revenueDeltaPct: (json['revenueDeltaPct'] as num?)?.toDouble() ?? 0,
      averageRating: (json['averageRating'] as num?)?.toDouble() ?? 0,
      ratingDelta: (json['ratingDelta'] as num?)?.toDouble() ?? 0,
    );
  }
}

class ProviderTrendPoint {
  ProviderTrendPoint({
    required this.label,
    required this.views,
    required this.bookings,
  });

  final String label;
  final int views;
  final int bookings;

  factory ProviderTrendPoint.fromJson(Map<String, dynamic> json) {
    return ProviderTrendPoint(
      label: json['label'] as String? ?? '-',
      views: (json['views'] as num?)?.toInt() ?? 0,
      bookings: (json['bookings'] as num?)?.toInt() ?? 0,
    );
  }
}

class ProviderTopDay {
  ProviderTopDay({
    required this.day,
    required this.views,
    required this.bookings,
    required this.revenue,
  });

  final String day;
  final int views;
  final int bookings;
  final double revenue;

  factory ProviderTopDay.fromJson(Map<String, dynamic> json) {
    return ProviderTopDay(
      day: json['day'] as String? ?? '-',
      views: (json['views'] as num?)?.toInt() ?? 0,
      bookings: (json['bookings'] as num?)?.toInt() ?? 0,
      revenue: (json['revenue'] as num?)?.toDouble() ?? 0,
    );
  }
}

class ProviderBookingSource {
  ProviderBookingSource({
    required this.label,
    required this.percentage,
    required this.count,
  });

  final String label;
  final int percentage;
  final int count;

  factory ProviderBookingSource.fromJson(Map<String, dynamic> json) {
    return ProviderBookingSource(
      label: json['label'] as String? ?? '',
      percentage: (json['percentage'] as num?)?.toInt() ?? 0,
      count: (json['count'] as num?)?.toInt() ?? 0,
    );
  }
}

class ProviderGuestStats {
  ProviderGuestStats({
    required this.repeatGuestsPct,
    required this.averageStayNights,
  });

  final int repeatGuestsPct;
  final double averageStayNights;

  factory ProviderGuestStats.fromJson(Map<String, dynamic> json) {
    return ProviderGuestStats(
      repeatGuestsPct: (json['repeatGuestsPct'] as num?)?.toInt() ?? 0,
      averageStayNights: (json['averageStayNights'] as num?)?.toDouble() ?? 0,
    );
  }
}
