import 'review.dart';

class HotelDetail {
  HotelDetail({
    required this.id,
    required this.name,
    required this.category,
    required this.address,
    required this.locationPath,
    required this.starRating,
    required this.rating,
    required this.reviewCount,
    required this.latitude,
    required this.longitude,
    required this.description,
    required this.images,
    required this.amenities,
    required this.priceFrom,
    required this.currency,
    required this.host,
    required this.policies,
    required this.isFavoritedByMe,
    required this.googleMapUrl,
    required this.reviewsPreview,
  });

  final int id;
  final String name;
  final String category;
  final String address;
  final String locationPath;
  final int starRating;
  final double rating;
  final int reviewCount;
  final double? latitude;
  final double? longitude;
  final String? description;
  final List<String> images;
  final List<String> amenities;
  final double? priceFrom;
  final String currency;
  final HotelHost? host;
  final HotelPolicies policies;
  final bool isFavoritedByMe;
  final String? googleMapUrl;
  final List<Review> reviewsPreview;

  factory HotelDetail.fromJson(Map<String, dynamic> json) {
    return HotelDetail(
      id: json['id'] as int,
      name: json['name'] as String,
      category: json['category'] as String,
      address: json['address'] as String,
      locationPath: json['locationPath'] as String? ?? '',
      starRating: json['starRating'] as int,
      rating: (json['rating'] as num).toDouble(),
      reviewCount: json['reviewCount'] as int,
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      description: json['description'] as String?,
      images:
          (json['images'] as List?)?.map((e) => e as String).toList() ?? const [],
      amenities:
          (json['amenities'] as List?)?.map((e) => e as String).toList() ?? const [],
      priceFrom: (json['priceFrom'] as num?)?.toDouble(),
      currency: json['currency'] as String? ?? 'VND',
      host: json['host'] == null
          ? null
          : HotelHost.fromJson(json['host'] as Map<String, dynamic>),
      policies: HotelPolicies.fromJson(
        (json['policies'] as Map<String, dynamic>?) ?? const {},
      ),
      isFavoritedByMe: json['isFavoritedByMe'] as bool? ?? false,
      googleMapUrl: json['googleMapUrl'] as String?,
      reviewsPreview: (json['reviewsPreview'] as List? ?? const [])
          .map((e) => Review.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class HotelHost {
  HotelHost({required this.id, required this.name});

  final String id;
  final String name;

  factory HotelHost.fromJson(Map<String, dynamic> json) {
    return HotelHost(
      id: json['id'] as String,
      name: json['name'] as String,
    );
  }
}

class HotelPolicies {
  HotelPolicies({required this.freeCancellation});

  final bool freeCancellation;

  factory HotelPolicies.fromJson(Map<String, dynamic> json) {
    return HotelPolicies(
      freeCancellation: json['freeCancellation'] as bool? ?? false,
    );
  }
}
