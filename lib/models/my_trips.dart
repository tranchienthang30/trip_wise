class MyTripsResponse {
  MyTripsResponse({
    required this.selectedTab,
    required this.counts,
    required this.featured,
    required this.items,
  });

  final String selectedTab;
  final MyTripsCounts counts;
  final MyTripCard? featured;
  final List<MyTripCard> items;

  factory MyTripsResponse.fromJson(Map<String, dynamic> json) {
    return MyTripsResponse(
      selectedTab: json['selectedTab'] as String? ?? 'upcoming',
      counts: MyTripsCounts.fromJson(
        (json['counts'] as Map<String, dynamic>?) ?? const {},
      ),
      featured: json['featured'] is Map<String, dynamic>
          ? MyTripCard.fromJson(json['featured'] as Map<String, dynamic>)
          : null,
      items: (json['items'] as List? ?? const [])
          .whereType<Map<String, dynamic>>()
          .map(MyTripCard.fromJson)
          .toList(),
    );
  }
}

class MyTripsCounts {
  MyTripsCounts({
    required this.upcoming,
    required this.completed,
    required this.cancelled,
  });

  final int upcoming;
  final int completed;
  final int cancelled;

  factory MyTripsCounts.fromJson(Map<String, dynamic> json) {
    return MyTripsCounts(
      upcoming: (json['upcoming'] as num?)?.toInt() ?? 0,
      completed: (json['completed'] as num?)?.toInt() ?? 0,
      cancelled: (json['cancelled'] as num?)?.toInt() ?? 0,
    );
  }

  int valueFor(String tab) {
    switch (tab) {
      case 'completed':
        return completed;
      case 'cancelled':
        return cancelled;
      case 'upcoming':
      default:
        return upcoming;
    }
  }
}

class MyTripCard {
  MyTripCard({
    required this.id,
    required this.bookingId,
    required this.title,
    required this.subtitle,
    required this.serviceType,
    required this.status,
    required this.rawStatus,
    required this.statusLabel,
    required this.dateLabel,
    required this.amount,
    required this.amountLabel,
    required this.imageUrl,
    required this.route,
    required this.ticketCode,
    required this.canCancel,
    required this.isCancellationPending,
    required this.cancelDeadline,
    required this.cancelDeadlineLabel,
  });

  final String id;
  final String bookingId;
  final String title;
  final String subtitle;
  final String serviceType;
  final String status;
  final String rawStatus;
  final String statusLabel;
  final String dateLabel;
  final double amount;
  final String amountLabel;
  final String imageUrl;
  final String route;
  final String ticketCode;
  final bool canCancel;
  final bool isCancellationPending;
  final String? cancelDeadline;
  final String? cancelDeadlineLabel;

  factory MyTripCard.fromJson(Map<String, dynamic> json) {
    return MyTripCard(
      id: json['id'] as String? ?? '',
      bookingId: json['bookingId'] as String? ?? '',
      title: json['title'] as String? ?? 'Trip',
      subtitle: json['subtitle'] as String? ?? '',
      serviceType: json['serviceType'] as String? ?? 'hotel',
      status: json['status'] as String? ?? 'upcoming',
      rawStatus: json['rawStatus'] as String? ?? '',
      statusLabel: json['statusLabel'] as String? ?? 'Upcoming',
      dateLabel: json['dateLabel'] as String? ?? 'Date not set',
      amount: (json['amount'] as num?)?.toDouble() ?? 0,
      amountLabel: json['amountLabel'] as String? ?? '',
      imageUrl: json['imageUrl'] as String? ?? '',
      route: json['route'] as String? ?? '/my_trips',
      ticketCode: json['ticketCode'] as String? ?? '',
      canCancel: json['canCancel'] as bool? ?? false,
      isCancellationPending: json['isCancellationPending'] as bool? ?? false,
      cancelDeadline: json['cancelDeadline'] as String?,
      cancelDeadlineLabel: json['cancelDeadlineLabel'] as String?,
    );
  }
}
