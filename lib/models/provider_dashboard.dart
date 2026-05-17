class ProviderDashboardData {
  ProviderDashboardData({
    required this.greeting,
    required this.revenue,
    required this.orderStatus,
    required this.recentActivities,
  });

  final ProviderGreeting greeting;
  final ProviderRevenue revenue;
  final ProviderOrderStatus orderStatus;
  final List<ProviderActivityItem> recentActivities;

  factory ProviderDashboardData.fromJson(Map<String, dynamic> json) {
    return ProviderDashboardData(
      greeting: ProviderGreeting.fromJson(
        (json['greeting'] as Map<String, dynamic>?) ?? const {},
      ),
      revenue: ProviderRevenue.fromJson(
        (json['revenue'] as Map<String, dynamic>?) ?? const {},
      ),
      orderStatus: ProviderOrderStatus.fromJson(
        (json['orderStatus'] as Map<String, dynamic>?) ?? const {},
      ),
      recentActivities: (json['recentActivities'] as List? ?? const [])
          .whereType<Map<String, dynamic>>()
          .map(ProviderActivityItem.fromJson)
          .toList(),
    );
  }
}

class ProviderGreeting {
  ProviderGreeting({required this.providerName});

  final String providerName;

  factory ProviderGreeting.fromJson(Map<String, dynamic> json) {
    return ProviderGreeting(
      providerName: json['providerName'] as String? ?? 'Provider',
    );
  }
}

class ProviderRevenue {
  ProviderRevenue({
    required this.totalRevenue,
    required this.totalRevenueLabel,
    required this.monthToDate,
    required this.monthToDateLabel,
    required this.payoutsPending,
    required this.payoutsPendingLabel,
    required this.deltaLabel,
  });

  final double totalRevenue;
  final String totalRevenueLabel;
  final double monthToDate;
  final String monthToDateLabel;
  final double payoutsPending;
  final String payoutsPendingLabel;
  final String deltaLabel;

  factory ProviderRevenue.fromJson(Map<String, dynamic> json) {
    return ProviderRevenue(
      totalRevenue: (json['totalRevenue'] as num?)?.toDouble() ?? 0,
      totalRevenueLabel: json['totalRevenueLabel'] as String? ?? '',
      monthToDate: (json['monthToDate'] as num?)?.toDouble() ?? 0,
      monthToDateLabel: json['monthToDateLabel'] as String? ?? '',
      payoutsPending: (json['payoutsPending'] as num?)?.toDouble() ?? 0,
      payoutsPendingLabel: json['payoutsPendingLabel'] as String? ?? '',
      deltaLabel: json['deltaLabel'] as String? ?? '',
    );
  }
}

class ProviderOrderStatus {
  ProviderOrderStatus({
    required this.pending,
    required this.confirmed,
    required this.completed,
    required this.cancelled,
  });

  final int pending;
  final int confirmed;
  final int completed;
  final int cancelled;

  factory ProviderOrderStatus.fromJson(Map<String, dynamic> json) {
    return ProviderOrderStatus(
      pending: (json['pending'] as num?)?.toInt() ?? 0,
      confirmed: (json['confirmed'] as num?)?.toInt() ?? 0,
      completed: (json['completed'] as num?)?.toInt() ?? 0,
      cancelled: (json['cancelled'] as num?)?.toInt() ?? 0,
    );
  }
}

class ProviderActivityItem {
  ProviderActivityItem({
    required this.id,
    required this.type,
    required this.title,
    required this.subtitle,
    required this.timeLabel,
    required this.amountLabel,
    required this.amountTone,
  });

  final String id;
  final String type;
  final String title;
  final String subtitle;
  final String timeLabel;
  final String? amountLabel;
  final String amountTone;

  factory ProviderActivityItem.fromJson(Map<String, dynamic> json) {
    return ProviderActivityItem(
      id: json['id'] as String? ?? '',
      type: json['type'] as String? ?? 'system',
      title: json['title'] as String? ?? '',
      subtitle: json['subtitle'] as String? ?? '',
      timeLabel: json['timeLabel'] as String? ?? '',
      amountLabel: json['amountLabel'] as String?,
      amountTone: json['amountTone'] as String? ?? 'neutral',
    );
  }
}
