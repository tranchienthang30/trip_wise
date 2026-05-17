class InventoryOverview {
  InventoryOverview({
    required this.listing,
    required this.currency,
    required this.month,
    required this.monthLabel,
    required this.leadingBlanks,
    required this.days,
    required this.pricingRules,
    required this.analytics,
  });

  final InventoryListing listing;
  final String currency;
  final String month;
  final String monthLabel;
  final int leadingBlanks;
  final List<InventoryDay> days;
  final List<PricingRule> pricingRules;
  final InventoryAnalytics analytics;

  factory InventoryOverview.fromJson(Map<String, dynamic> json) {
    return InventoryOverview(
      listing: InventoryListing.fromJson(
        (json['listing'] as Map<String, dynamic>?) ?? const {},
      ),
      currency: json['currency'] as String? ?? 'VND',
      month: json['month'] as String? ?? '',
      monthLabel: json['monthLabel'] as String? ?? '',
      leadingBlanks: (json['leadingBlanks'] as num?)?.toInt() ?? 0,
      days: ((json['days'] as List<dynamic>?) ?? const [])
          .map((e) => InventoryDay.fromJson(e as Map<String, dynamic>))
          .toList(),
      pricingRules: ((json['pricingRules'] as List<dynamic>?) ?? const [])
          .map((e) => PricingRule.fromJson(e as Map<String, dynamic>))
          .toList(),
      analytics: InventoryAnalytics.fromJson(
        (json['analytics'] as Map<String, dynamic>?) ?? const {},
      ),
    );
  }
}

class InventoryListing {
  InventoryListing({
    required this.roomId,
    required this.roomType,
    required this.hotelId,
    required this.hotelName,
    required this.basePrice,
  });

  final int roomId;
  final String roomType;
  final int hotelId;
  final String hotelName;
  final double basePrice;

  factory InventoryListing.fromJson(Map<String, dynamic> json) =>
      InventoryListing(
        roomId: (json['roomId'] as num?)?.toInt() ?? 0,
        roomType: json['roomType'] as String? ?? 'Room',
        hotelId: (json['hotelId'] as num?)?.toInt() ?? 0,
        hotelName: json['hotelName'] as String? ?? 'Listing',
        basePrice: (json['basePrice'] as num?)?.toDouble() ?? 0,
      );
}

class InventoryDay {
  InventoryDay({
    required this.day,
    required this.date,
    required this.price,
    required this.status,
    required this.availableQty,
  });

  /// One of `available`, `highPrice`, `closed`.
  final int day;
  final String date;
  final double price;
  final String status;
  final int availableQty;

  factory InventoryDay.fromJson(Map<String, dynamic> json) => InventoryDay(
        day: (json['day'] as num?)?.toInt() ?? 0,
        date: json['date'] as String? ?? '',
        price: (json['price'] as num?)?.toDouble() ?? 0,
        status: json['status'] as String? ?? 'closed',
        availableQty: (json['availableQty'] as num?)?.toInt() ?? 0,
      );
}

class PricingRule {
  PricingRule({
    required this.label,
    required this.value,
    required this.tone,
  });

  final String label;
  final String value;

  /// One of `primary`, `secondary` — maps to a brand color on screen.
  final String tone;

  factory PricingRule.fromJson(Map<String, dynamic> json) => PricingRule(
        label: json['label'] as String? ?? '',
        value: json['value'] as String? ?? '',
        tone: json['tone'] as String? ?? 'secondary',
      );
}

class InventoryAnalytics {
  InventoryAnalytics({
    required this.occupancyPct,
    required this.revenueForecast,
    required this.revenueDeltaLabel,
    required this.demandLevel,
    required this.demandNote,
  });

  final int occupancyPct;
  final double revenueForecast;
  final String revenueDeltaLabel;
  final String demandLevel;
  final String demandNote;

  factory InventoryAnalytics.fromJson(Map<String, dynamic> json) =>
      InventoryAnalytics(
        occupancyPct: (json['occupancyPct'] as num?)?.toInt() ?? 0,
        revenueForecast: (json['revenueForecast'] as num?)?.toDouble() ?? 0,
        revenueDeltaLabel: json['revenueDeltaLabel'] as String? ?? '',
        demandLevel: json['demandLevel'] as String? ?? '—',
        demandNote: json['demandNote'] as String? ?? '',
      );
}
