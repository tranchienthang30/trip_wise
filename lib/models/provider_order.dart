class ProviderOrdersResponse {
  ProviderOrdersResponse({
    required this.status,
    required this.counts,
    required this.orders,
  });

  final String status;
  final ProviderOrderCounts counts;
  final List<ProviderOrder> orders;

  factory ProviderOrdersResponse.fromJson(Map<String, dynamic> json) {
    return ProviderOrdersResponse(
      status: json['status'] as String? ?? 'pending',
      counts: ProviderOrderCounts.fromJson(
        (json['counts'] as Map<String, dynamic>?) ?? const {},
      ),
      orders: (json['orders'] as List? ?? const [])
          .map((item) => ProviderOrder.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }
}

class ProviderOrderCounts {
  ProviderOrderCounts({
    required this.pending,
    required this.confirmed,
    required this.completed,
    required this.cancelled,
  });

  final int pending;
  final int confirmed;
  final int completed;
  final int cancelled;

  factory ProviderOrderCounts.fromJson(Map<String, dynamic> json) {
    return ProviderOrderCounts(
      pending: json['pending'] as int? ?? 0,
      confirmed: json['confirmed'] as int? ?? 0,
      completed: json['completed'] as int? ?? 0,
      cancelled: json['cancelled'] as int? ?? 0,
    );
  }

  int valueFor(String status) {
    switch (status) {
      case 'confirmed':
        return confirmed;
      case 'completed':
        return completed;
      case 'cancelled':
        return cancelled;
      case 'pending':
      default:
        return pending;
    }
  }
}

class ProviderOrder {
  ProviderOrder({
    required this.id,
    required this.bookingId,
    required this.status,
    required this.statusLabel,
    required this.title,
    required this.guestName,
    required this.guestAvatarUrl,
    required this.dates,
    required this.checkIn,
    required this.checkOut,
    required this.nights,
    required this.guests,
    required this.totalPrice,
    required this.currency,
    required this.displayPrice,
    required this.bookingType,
    required this.imageUrl,
    required this.roomType,
    required this.serviceType,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String bookingId;
  final String status;
  final String statusLabel;
  final String title;
  final String guestName;
  final String? guestAvatarUrl;
  final String dates;
  final String? checkIn;
  final String? checkOut;
  final int? nights;
  final int? guests;
  final double totalPrice;
  final String currency;
  final String displayPrice;
  final String bookingType;
  final String imageUrl;
  final String? roomType;
  final String serviceType;
  final String? createdAt;
  final String? updatedAt;

  bool get isPending => status == 'pending';
  bool get isPremium => bookingType == 'premium';

  factory ProviderOrder.fromJson(Map<String, dynamic> json) {
    return ProviderOrder(
      id: json['id'] as String,
      bookingId: json['bookingId'] as String? ?? '',
      status: json['status'] as String? ?? 'pending',
      statusLabel: json['statusLabel'] as String? ?? 'PENDING',
      title: json['title'] as String? ?? 'Untitled order',
      guestName: json['guestName'] as String? ?? 'Guest',
      guestAvatarUrl: json['guestAvatarUrl'] as String?,
      dates: json['dates'] as String? ?? 'Dates not set',
      checkIn: json['checkIn'] as String?,
      checkOut: json['checkOut'] as String?,
      nights: json['nights'] as int?,
      guests: json['guests'] as int?,
      totalPrice: (json['totalPrice'] as num? ?? 0).toDouble(),
      currency: json['currency'] as String? ?? 'VND',
      displayPrice: json['displayPrice'] as String? ?? '',
      bookingType: json['bookingType'] as String? ?? 'standard',
      imageUrl: json['imageUrl'] as String? ?? '',
      roomType: json['roomType'] as String?,
      serviceType: json['serviceType'] as String? ?? 'hotel',
      createdAt: json['createdAt'] as String?,
      updatedAt: json['updatedAt'] as String?,
    );
  }
}
