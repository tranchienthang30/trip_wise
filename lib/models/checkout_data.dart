class CheckoutSummary {
  CheckoutSummary({
    required this.listing,
    required this.pricing,
    required this.guestPrefill,
    required this.paymentOptions,
  });

  final CheckoutListing listing;
  final CheckoutPricing pricing;
  final CheckoutGuestPrefill guestPrefill;
  final List<CheckoutPaymentOption> paymentOptions;

  factory CheckoutSummary.fromJson(Map<String, dynamic> json) {
    return CheckoutSummary(
      listing: CheckoutListing.fromJson(
        (json['listing'] as Map<String, dynamic>?) ?? const {},
      ),
      pricing: CheckoutPricing.fromJson(
        (json['pricing'] as Map<String, dynamic>?) ?? const {},
      ),
      guestPrefill: CheckoutGuestPrefill.fromJson(
        (json['guestPrefill'] as Map<String, dynamic>?) ?? const {},
      ),
      paymentOptions: (json['paymentOptions'] as List? ?? const [])
          .whereType<Map<String, dynamic>>()
          .map(CheckoutPaymentOption.fromJson)
          .toList(),
    );
  }
}

class CheckoutListing {
  CheckoutListing({
    required this.hotelId,
    required this.roomId,
    required this.title,
    required this.subtitle,
    required this.imageUrl,
    required this.startDate,
    required this.endDate,
    required this.nights,
    required this.guests,
  });

  final int hotelId;
  final int roomId;
  final String title;
  final String subtitle;
  final String? imageUrl;
  final String startDate;
  final String endDate;
  final int nights;
  final int guests;

  factory CheckoutListing.fromJson(Map<String, dynamic> json) {
    return CheckoutListing(
      hotelId: (json['hotelId'] as num?)?.toInt() ?? 0,
      roomId: (json['roomId'] as num?)?.toInt() ?? 0,
      title: json['title'] as String? ?? 'Listing',
      subtitle: json['subtitle'] as String? ?? '',
      imageUrl: json['imageUrl'] as String?,
      startDate: json['startDate'] as String? ?? '',
      endDate: json['endDate'] as String? ?? '',
      nights: (json['nights'] as num?)?.toInt() ?? 1,
      guests: (json['guests'] as num?)?.toInt() ?? 1,
    );
  }
}

class CheckoutPricing {
  CheckoutPricing({
    required this.currency,
    required this.subtotal,
    required this.taxes,
    required this.fees,
    required this.total,
    required this.subtotalLabel,
    required this.taxesLabel,
    required this.feesLabel,
    required this.totalLabel,
  });

  final String currency;
  final double subtotal;
  final double taxes;
  final double fees;
  final double total;
  final String subtotalLabel;
  final String taxesLabel;
  final String feesLabel;
  final String totalLabel;

  factory CheckoutPricing.fromJson(Map<String, dynamic> json) {
    return CheckoutPricing(
      currency: json['currency'] as String? ?? 'USD',
      subtotal: (json['subtotal'] as num?)?.toDouble() ?? 0,
      taxes: (json['taxes'] as num?)?.toDouble() ?? 0,
      fees: (json['fees'] as num?)?.toDouble() ?? 0,
      total: (json['total'] as num?)?.toDouble() ?? 0,
      subtotalLabel: json['subtotalLabel'] as String? ?? '',
      taxesLabel: json['taxesLabel'] as String? ?? '',
      feesLabel: json['feesLabel'] as String? ?? '',
      totalLabel: json['totalLabel'] as String? ?? '',
    );
  }
}

class CheckoutGuestPrefill {
  CheckoutGuestPrefill({
    required this.fullName,
    required this.email,
    required this.phone,
  });

  final String fullName;
  final String? email;
  final String? phone;

  factory CheckoutGuestPrefill.fromJson(Map<String, dynamic> json) {
    return CheckoutGuestPrefill(
      fullName: json['fullName'] as String? ?? '',
      email: json['email'] as String?,
      phone: json['phone'] as String?,
    );
  }
}

class CheckoutPaymentOption {
  CheckoutPaymentOption({
    required this.key,
    required this.title,
    required this.subtitle,
  });

  final String key;
  final String title;
  final String subtitle;

  factory CheckoutPaymentOption.fromJson(Map<String, dynamic> json) {
    return CheckoutPaymentOption(
      key: json['key'] as String? ?? 'card',
      title: json['title'] as String? ?? 'Payment',
      subtitle: json['subtitle'] as String? ?? '',
    );
  }
}

class CheckoutCompleteResult {
  CheckoutCompleteResult({
    required this.bookingId,
    required this.paymentId,
    required this.nextRoute,
    required this.statusLabel,
    required this.message,
  });

  final String bookingId;
  final String paymentId;
  final String nextRoute;
  final String statusLabel;
  final String message;

  factory CheckoutCompleteResult.fromJson(Map<String, dynamic> json) {
    return CheckoutCompleteResult(
      bookingId: json['bookingId'] as String? ?? '',
      paymentId: json['paymentId'] as String? ?? '',
      nextRoute: json['nextRoute'] as String? ?? '/payment_success',
      statusLabel: json['statusLabel'] as String? ?? 'CONFIRMED',
      message: json['message'] as String? ?? 'Booking completed.',
    );
  }
}
