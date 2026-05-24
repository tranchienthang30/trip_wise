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
    required this.existingBooking,
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
  final HotelExistingBooking? existingBooking;

  factory HotelDetail.fromJson(Map<String, dynamic> json) {
    return HotelDetail(
      id: _intValue(json['id']),
      name: json['name'] as String? ?? 'Tripwise stay',
      category: json['category'] as String? ?? 'HOTEL',
      address: json['address'] as String? ?? '',
      locationPath: json['locationPath'] as String? ?? '',
      starRating: _intValue(json['starRating']),
      rating: _doubleValue(json['rating']),
      reviewCount: _intValue(json['reviewCount']),
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      description: json['description'] as String?,
      images:
          (json['images'] as List?)?.map((e) => e as String).toList() ?? const [],
      amenities:
          (json['amenities'] as List?)?.map((e) => e as String).toList() ?? const [],
      priceFrom: (json['priceFrom'] as num?)?.toDouble(),
      currency: json['currency'] as String? ?? 'USD',
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
      existingBooking: json['existingBooking'] is Map<String, dynamic>
          ? HotelExistingBooking.fromJson(
              json['existingBooking'] as Map<String, dynamic>,
            )
          : null,
    );
  }
}

int _intValue(Object? value, [int fallback = 0]) {
  if (value is num) return value.round();
  if (value is String) return int.tryParse(value) ?? fallback;
  return fallback;
}

double _doubleValue(Object? value, [double fallback = 0]) {
  if (value is num) return value.toDouble();
  if (value is String) return double.tryParse(value) ?? fallback;
  return fallback;
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

class HotelExistingBooking {
  HotelExistingBooking({
    required this.bookingId,
    required this.bookingItemId,
    required this.status,
    required this.canCancel,
    required this.isCancellationPending,
    required this.cancelDeadline,
    required this.cancelDeadlineLabel,
  });

  final String bookingId;
  final String bookingItemId;
  final String status;
  final bool canCancel;
  final bool isCancellationPending;
  final String? cancelDeadline;
  final String? cancelDeadlineLabel;

  factory HotelExistingBooking.fromJson(Map<String, dynamic> json) {
    return HotelExistingBooking(
      bookingId: json['bookingId'] as String? ?? '',
      bookingItemId: json['bookingItemId'] as String? ?? '',
      status: json['status'] as String? ?? 'CONFIRMED',
      canCancel: json['canCancel'] as bool? ?? false,
      isCancellationPending: json['isCancellationPending'] as bool? ?? false,
      cancelDeadline: json['cancelDeadline'] as String?,
      cancelDeadlineLabel: json['cancelDeadlineLabel'] as String?,
    );
  }
}
