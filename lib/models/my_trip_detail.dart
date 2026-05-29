class MyTripDetail {
  MyTripDetail({
    required this.id,
    required this.bookingId,
    required this.title,
    required this.subtitle,
    required this.locationLabel,
    required this.serviceType,
    required this.status,
    required this.rawStatus,
    required this.statusLabel,
    required this.imageUrl,
    required this.ticketCode,
    required this.cabinClass,
    required this.seatNumbers,
    required this.airlineName,
    required this.dateLabel,
    required this.startDate,
    required this.endDate,
    required this.startDateTitle,
    required this.endDateTitle,
    required this.startDateLabel,
    required this.endDateLabel,
    required this.nights,
    required this.nightsLabel,
    required this.quantity,
    required this.quantityTitle,
    required this.quantityLabel,
    required this.pricePerUnit,
    required this.pricePerUnitTitle,
    required this.pricePerUnitLabel,
    required this.totalAmount,
    required this.totalAmountLabel,
    required this.bookingCreatedAt,
    required this.bookingCreatedAtLabel,
    required this.canCancel,
    required this.isCancellationPending,
    required this.cancelDeadline,
    required this.cancelDeadlineLabel,
    required this.cancellationPolicyLabel,
  });

  final String id;
  final String bookingId;
  final String title;
  final String subtitle;
  final String locationLabel;
  final String serviceType;
  final String status;
  final String rawStatus;
  final String statusLabel;
  final String imageUrl;
  final String ticketCode;
  final String? cabinClass;
  final List<String> seatNumbers;
  final String? airlineName;
  final String dateLabel;
  final String? startDate;
  final String? endDate;
  final String startDateTitle;
  final String endDateTitle;
  final String startDateLabel;
  final String endDateLabel;
  final int? nights;
  final String nightsLabel;
  final int quantity;
  final String quantityTitle;
  final String quantityLabel;
  final double pricePerUnit;
  final String pricePerUnitTitle;
  final String pricePerUnitLabel;
  final double totalAmount;
  final String totalAmountLabel;
  final String? bookingCreatedAt;
  final String bookingCreatedAtLabel;
  final bool canCancel;
  final bool isCancellationPending;
  final String? cancelDeadline;
  final String? cancelDeadlineLabel;
  final String cancellationPolicyLabel;

  bool get hasTicketCode => ticketCode.trim().isNotEmpty;

  factory MyTripDetail.fromJson(Map<String, dynamic> json) {
    return MyTripDetail(
      id: json['id'] as String? ?? '',
      bookingId: json['bookingId'] as String? ?? '',
      title: json['title'] as String? ?? 'Trip booking',
      subtitle: json['subtitle'] as String? ?? '',
      locationLabel: json['locationLabel'] as String? ?? '',
      serviceType: json['serviceType'] as String? ?? 'hotel',
      status: json['status'] as String? ?? 'upcoming',
      rawStatus: json['rawStatus'] as String? ?? '',
      statusLabel: json['statusLabel'] as String? ?? 'Upcoming',
      imageUrl: json['imageUrl'] as String? ?? '',
      ticketCode: json['ticketCode'] as String? ?? '',
      cabinClass: json['cabinClass'] as String?,
      seatNumbers: (json['seatNumbers'] as List? ?? const [])
          .whereType<String>()
          .toList(),
      airlineName: json['airlineName'] as String?,
      dateLabel: json['dateLabel'] as String? ?? 'Dates not set',
      startDate: json['startDate'] as String?,
      endDate: json['endDate'] as String?,
      startDateTitle: json['startDateTitle'] as String? ?? 'Start',
      endDateTitle: json['endDateTitle'] as String? ?? 'End',
      startDateLabel: json['startDateLabel'] as String? ?? 'Not set',
      endDateLabel: json['endDateLabel'] as String? ?? 'Not set',
      nights: (json['nights'] as num?)?.toInt(),
      nightsLabel: json['nightsLabel'] as String? ?? 'Not applicable',
      quantity: (json['quantity'] as num?)?.toInt() ?? 1,
      quantityTitle: json['quantityTitle'] as String? ?? 'Guests',
      quantityLabel: json['quantityLabel'] as String? ?? '1 guest',
      pricePerUnit: (json['pricePerUnit'] as num?)?.toDouble() ?? 0,
      pricePerUnitTitle: json['pricePerUnitTitle'] as String? ??
          'Price per unit',
      pricePerUnitLabel: json['pricePerUnitLabel'] as String? ?? '\$0',
      totalAmount: (json['totalAmount'] as num?)?.toDouble() ?? 0,
      totalAmountLabel: json['totalAmountLabel'] as String? ?? '\$0',
      bookingCreatedAt: json['bookingCreatedAt'] as String?,
      bookingCreatedAtLabel: json['bookingCreatedAtLabel'] as String? ??
          'Not set',
      canCancel: json['canCancel'] as bool? ?? false,
      isCancellationPending: json['isCancellationPending'] as bool? ?? false,
      cancelDeadline: json['cancelDeadline'] as String?,
      cancelDeadlineLabel: json['cancelDeadlineLabel'] as String?,
      cancellationPolicyLabel:
          json['cancellationPolicyLabel'] as String? ??
          'Cancellation policy is not available.',
    );
  }
}
