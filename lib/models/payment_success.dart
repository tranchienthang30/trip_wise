class PaymentSuccess {
  PaymentSuccess({
    required this.bookingId,
    required this.bookingCode,
    required this.destination,
    required this.destinationSubtitle,
    required this.arrivalDate,
    required this.arrivalDateLabel,
    required this.imageUrl,
    required this.status,
    required this.statusLabel,
    required this.message,
    required this.emailSentTo,
    required this.amount,
    required this.displayAmount,
    required this.currency,
    required this.payment,
    required this.ticket,
    required this.items,
  });

  final String bookingId;
  final String bookingCode;
  final String destination;
  final String? destinationSubtitle;
  final String? arrivalDate;
  final String arrivalDateLabel;
  final String imageUrl;
  final String status;
  final String statusLabel;
  final String message;
  final String? emailSentTo;
  final double amount;
  final String displayAmount;
  final String currency;
  final PaymentSuccessPayment payment;
  final PaymentSuccessTicket ticket;
  final List<PaymentSuccessItem> items;

  factory PaymentSuccess.fromJson(Map<String, dynamic> json) {
    return PaymentSuccess(
      bookingId: json['bookingId'] as String? ?? '',
      bookingCode: json['bookingCode'] as String? ?? '',
      destination: json['destination'] as String? ?? 'Tripwise booking',
      destinationSubtitle: json['destinationSubtitle'] as String?,
      arrivalDate: json['arrivalDate'] as String?,
      arrivalDateLabel: json['arrivalDateLabel'] as String? ?? 'Date not set',
      imageUrl: json['imageUrl'] as String? ?? '',
      status: json['status'] as String? ?? 'CONFIRMED',
      statusLabel: json['statusLabel'] as String? ?? 'CONFIRMED',
      message: json['message'] as String? ??
          'Your trip has been confirmed. E-ticket has been sent to your email.',
      emailSentTo: json['emailSentTo'] as String?,
      amount: (json['amount'] as num?)?.toDouble() ?? 0,
      displayAmount: json['displayAmount'] as String? ?? '',
      currency: json['currency'] as String? ?? 'VND',
      payment: PaymentSuccessPayment.fromJson(
        (json['payment'] as Map<String, dynamic>?) ?? const {},
      ),
      ticket: PaymentSuccessTicket.fromJson(
        (json['ticket'] as Map<String, dynamic>?) ?? const {},
      ),
      items: (json['items'] as List? ?? const [])
          .map((item) => PaymentSuccessItem.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }
}

class PaymentSuccessPayment {
  PaymentSuccessPayment({
    required this.id,
    required this.method,
    required this.status,
    required this.transactionId,
    required this.paidAt,
  });

  final String? id;
  final String? method;
  final String? status;
  final String? transactionId;
  final String? paidAt;

  factory PaymentSuccessPayment.fromJson(Map<String, dynamic> json) {
    return PaymentSuccessPayment(
      id: json['id'] as String?,
      method: json['method'] as String?,
      status: json['status'] as String?,
      transactionId: json['transactionId'] as String?,
      paidAt: json['paidAt'] as String?,
    );
  }
}

class PaymentSuccessTicket {
  PaymentSuccessTicket({
    required this.code,
    required this.downloadUrl,
  });

  final String code;
  final String downloadUrl;

  factory PaymentSuccessTicket.fromJson(Map<String, dynamic> json) {
    return PaymentSuccessTicket(
      code: json['code'] as String? ?? '',
      downloadUrl: json['downloadUrl'] as String? ?? '',
    );
  }
}

class PaymentSuccessItem {
  PaymentSuccessItem({
    required this.id,
    required this.serviceType,
    required this.title,
    required this.subtitle,
    required this.startDate,
    required this.endDate,
    required this.dateLabel,
    required this.guests,
    required this.ticketCode,
    required this.imageUrl,
    required this.amount,
    required this.displayAmount,
  });

  final String id;
  final String serviceType;
  final String title;
  final String? subtitle;
  final String? startDate;
  final String? endDate;
  final String dateLabel;
  final int? guests;
  final String ticketCode;
  final String imageUrl;
  final double amount;
  final String displayAmount;

  factory PaymentSuccessItem.fromJson(Map<String, dynamic> json) {
    return PaymentSuccessItem(
      id: json['id'] as String? ?? '',
      serviceType: json['serviceType'] as String? ?? 'hotel',
      title: json['title'] as String? ?? 'Tripwise booking',
      subtitle: json['subtitle'] as String?,
      startDate: json['startDate'] as String?,
      endDate: json['endDate'] as String?,
      dateLabel: json['dateLabel'] as String? ?? 'Date not set',
      guests: (json['guests'] as num?)?.toInt(),
      ticketCode: json['ticketCode'] as String? ?? '',
      imageUrl: json['imageUrl'] as String? ?? '',
      amount: (json['amount'] as num?)?.toDouble() ?? 0,
      displayAmount: json['displayAmount'] as String? ?? '',
    );
  }
}
