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
    required this.pointsAvailable,
    required this.pointsMaxRedeem,
    required this.total,
    required this.subtotalLabel,
    required this.taxesLabel,
    required this.feesLabel,
    required this.pointsAvailableLabel,
    required this.pointsMaxRedeemLabel,
    required this.totalLabel,
  });

  final String currency;
  final double subtotal;
  final double taxes;
  final double fees;
  final int pointsAvailable;
  final double pointsMaxRedeem;
  final double total;
  final String subtotalLabel;
  final String taxesLabel;
  final String feesLabel;
  final String pointsAvailableLabel;
  final String pointsMaxRedeemLabel;
  final String totalLabel;

  factory CheckoutPricing.fromJson(Map<String, dynamic> json) {
    return CheckoutPricing(
      currency: json['currency'] as String? ?? 'USD',
      subtotal: (json['subtotal'] as num?)?.toDouble() ?? 0,
      taxes: (json['taxes'] as num?)?.toDouble() ?? 0,
      fees: (json['fees'] as num?)?.toDouble() ?? 0,
      pointsAvailable: (json['pointsAvailable'] as num?)?.toInt() ?? 0,
      pointsMaxRedeem: (json['pointsMaxRedeem'] as num?)?.toDouble() ?? 0,
      total: (json['total'] as num?)?.toDouble() ?? 0,
      subtotalLabel: json['subtotalLabel'] as String? ?? '',
      taxesLabel: json['taxesLabel'] as String? ?? '',
      feesLabel: json['feesLabel'] as String? ?? '',
      pointsAvailableLabel: json['pointsAvailableLabel'] as String? ?? '0 points',
      pointsMaxRedeemLabel: json['pointsMaxRedeemLabel'] as String? ?? '',
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
    required this.payos,
  });

  final String bookingId;
  final String paymentId;
  final String nextRoute;
  final String statusLabel;
  final String message;
  final CheckoutPayOSLink? payos;

  factory CheckoutCompleteResult.fromJson(Map<String, dynamic> json) {
    return CheckoutCompleteResult(
      bookingId: json['bookingId'] as String? ?? '',
      paymentId: json['paymentId'] as String? ?? '',
      nextRoute: json['nextRoute'] as String? ?? '/payment_success',
      statusLabel: json['statusLabel'] as String? ?? 'CONFIRMED',
      message: json['message'] as String? ?? 'Booking completed.',
      payos: json['payos'] is Map
          ? CheckoutPayOSLink.fromJson(
              (json['payos'] as Map).cast<String, dynamic>(),
            )
          : null,
    );
  }
}

class CheckoutPayOSLink {
  CheckoutPayOSLink({
    required this.paymentLinkId,
    required this.orderCode,
    required this.checkoutUrl,
    required this.qrCode,
    required this.status,
    required this.expiresAt,
  });

  final String paymentLinkId;
  final int orderCode;
  final String checkoutUrl;
  final String qrCode;
  final String status;
  final int? expiresAt;

  factory CheckoutPayOSLink.fromJson(Map<String, dynamic> json) {
    return CheckoutPayOSLink(
      paymentLinkId: json['paymentLinkId'] as String? ?? '',
      orderCode: (json['orderCode'] as num?)?.toInt() ?? 0,
      checkoutUrl: json['checkoutUrl'] as String? ?? '',
      qrCode: json['qrCode'] as String? ?? '',
      status: json['status'] as String? ?? 'PENDING',
      expiresAt: (json['expiresAt'] as num?)?.toInt(),
    );
  }
}

class CheckoutPayOSSession {
  CheckoutPayOSSession({
    required this.bookingId,
    required this.paymentId,
    required this.status,
    required this.amount,
    required this.paymentLinkId,
    required this.orderCode,
    required this.checkoutUrl,
    required this.qrCode,
    required this.expiresAt,
  });

  final String bookingId;
  final String paymentId;
  final String status;
  final double amount;
  final String paymentLinkId;
  final int orderCode;
  final String checkoutUrl;
  final String qrCode;
  final int? expiresAt;

  factory CheckoutPayOSSession.fromJson(Map<String, dynamic> json) {
    return CheckoutPayOSSession(
      bookingId: json['bookingId'] as String? ?? '',
      paymentId: json['paymentId'] as String? ?? '',
      status: json['status'] as String? ?? 'PENDING',
      amount: (json['amount'] as num?)?.toDouble() ?? 0,
      paymentLinkId: json['paymentLinkId'] as String? ?? '',
      orderCode: (json['orderCode'] as num?)?.toInt() ?? 0,
      checkoutUrl: json['checkoutUrl'] as String? ?? '',
      qrCode: json['qrCode'] as String? ?? '',
      expiresAt: (json['expiresAt'] as num?)?.toInt(),
    );
  }
}

class CheckoutPayOSConfirmResult {
  CheckoutPayOSConfirmResult({
    required this.bookingId,
    required this.paymentId,
    required this.paymentStatus,
    required this.bookingStatus,
    required this.nextRoute,
    required this.isPaid,
    required this.message,
  });

  final String bookingId;
  final String paymentId;
  final String paymentStatus;
  final String bookingStatus;
  final String nextRoute;
  final bool isPaid;
  final String message;

  factory CheckoutPayOSConfirmResult.fromJson(Map<String, dynamic> json) {
    return CheckoutPayOSConfirmResult(
      bookingId: json['bookingId'] as String? ?? '',
      paymentId: json['paymentId'] as String? ?? '',
      paymentStatus: json['paymentStatus'] as String? ?? 'PENDING',
      bookingStatus: json['bookingStatus'] as String? ?? 'PENDING_PAYMENT',
      nextRoute: json['nextRoute'] as String? ?? '/payment_success',
      isPaid: json['isPaid'] as bool? ?? false,
      message: json['message'] as String? ?? 'Payment status checked.',
    );
  }
}
