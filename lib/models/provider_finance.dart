class ProviderFinance {
  ProviderFinance({
    required this.provider,
    required this.overview,
    required this.earningsHistory,
    required this.growth,
    required this.recentTransactions,
  });

  final ProviderFinanceProvider provider;
  final ProviderFinanceOverview overview;
  final ProviderFinanceHistory earningsHistory;
  final ProviderFinanceGrowth growth;
  final ProviderFinanceTransactions recentTransactions;

  factory ProviderFinance.fromJson(Map<String, dynamic> json) {
    return ProviderFinance(
      provider: ProviderFinanceProvider.fromJson(
        (json['provider'] as Map<String, dynamic>?) ?? const {},
      ),
      overview: ProviderFinanceOverview.fromJson(
        (json['overview'] as Map<String, dynamic>?) ?? const {},
      ),
      earningsHistory: ProviderFinanceHistory.fromJson(
        (json['earningsHistory'] as Map<String, dynamic>?) ?? const {},
      ),
      growth: ProviderFinanceGrowth.fromJson(
        (json['growth'] as Map<String, dynamic>?) ?? const {},
      ),
      recentTransactions: ProviderFinanceTransactions.fromJson(
        (json['recentTransactions'] as Map<String, dynamic>?) ?? const {},
      ),
    );
  }
}

class ProviderFinanceProvider {
  ProviderFinanceProvider({required this.id, required this.businessName});

  final String id;
  final String businessName;

  factory ProviderFinanceProvider.fromJson(Map<String, dynamic> json) {
    return ProviderFinanceProvider(
      id: json['id'] as String? ?? '',
      businessName: json['businessName'] as String? ?? 'Provider',
    );
  }
}

class ProviderFinanceOverview {
  ProviderFinanceOverview({
    required this.availableForPayout,
    required this.displayAvailableForPayout,
    required this.totalLifetimeEarnings,
    required this.displayTotalLifetimeEarnings,
    required this.servicesProvided,
    required this.displayServicesProvided,
    required this.serviceFees,
    required this.displayServiceFees,
    required this.serviceFeePercentLabel,
  });

  final double availableForPayout;
  final String displayAvailableForPayout;
  final double totalLifetimeEarnings;
  final String displayTotalLifetimeEarnings;
  final double servicesProvided;
  final String displayServicesProvided;
  final double serviceFees;
  final String displayServiceFees;
  final String serviceFeePercentLabel;

  factory ProviderFinanceOverview.fromJson(Map<String, dynamic> json) {
    return ProviderFinanceOverview(
      availableForPayout: (json['availableForPayout'] as num?)?.toDouble() ?? 0,
      displayAvailableForPayout:
          json['displayAvailableForPayout'] as String? ?? '\$0',
      totalLifetimeEarnings:
          (json['totalLifetimeEarnings'] as num?)?.toDouble() ?? 0,
      displayTotalLifetimeEarnings:
          json['displayTotalLifetimeEarnings'] as String? ?? '\$0',
      servicesProvided: (json['servicesProvided'] as num?)?.toDouble() ?? 0,
      displayServicesProvided:
          json['displayServicesProvided'] as String? ?? '\$0',
      serviceFees: (json['serviceFees'] as num?)?.toDouble() ?? 0,
      displayServiceFees: json['displayServiceFees'] as String? ?? '-\$0',
      serviceFeePercentLabel:
          json['serviceFeePercentLabel'] as String? ?? '0%',
    );
  }
}

class ProviderFinanceHistory {
  ProviderFinanceHistory({
    required this.period,
    required this.peakLabel,
    required this.bars,
  });

  final String period;
  final String peakLabel;
  final List<ProviderFinanceBar> bars;

  factory ProviderFinanceHistory.fromJson(Map<String, dynamic> json) {
    return ProviderFinanceHistory(
      period: json['period'] as String? ?? 'monthly',
      peakLabel: json['peakLabel'] as String? ?? '0',
      bars: ((json['bars'] as List<dynamic>?) ?? const [])
          .map((item) => ProviderFinanceBar.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }
}

class ProviderFinanceBar {
  ProviderFinanceBar({
    required this.label,
    required this.displayValue,
    required this.heightFactor,
    required this.highlighted,
  });

  final String label;
  final String displayValue;
  final double heightFactor;
  final bool highlighted;

  factory ProviderFinanceBar.fromJson(Map<String, dynamic> json) {
    return ProviderFinanceBar(
      label: json['label'] as String? ?? '',
      displayValue: json['displayValue'] as String? ?? '\$0',
      heightFactor: (json['heightFactor'] as num?)?.toDouble() ?? 0.08,
      highlighted: json['highlighted'] as bool? ?? false,
    );
  }
}

class ProviderFinanceGrowth {
  ProviderFinanceGrowth({
    required this.displayPercent,
    required this.comparisonLabel,
  });

  final String displayPercent;
  final String comparisonLabel;

  factory ProviderFinanceGrowth.fromJson(Map<String, dynamic> json) {
    return ProviderFinanceGrowth(
      displayPercent: json['displayPercent'] as String? ?? '+0.0%',
      comparisonLabel: json['comparisonLabel'] as String? ?? '',
    );
  }
}

class ProviderFinanceTransactions {
  ProviderFinanceTransactions({required this.items});

  final List<ProviderFinanceTransaction> items;

  factory ProviderFinanceTransactions.fromJson(Map<String, dynamic> json) {
    return ProviderFinanceTransactions(
      items: ((json['items'] as List<dynamic>?) ?? const [])
          .map((item) => ProviderFinanceTransaction.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }
}

class ProviderFinanceTransaction {
  ProviderFinanceTransaction({
    required this.title,
    required this.subtitle,
    required this.date,
    required this.time,
    required this.displayAmount,
    required this.statusLabel,
    required this.iconKey,
  });

  final String title;
  final String subtitle;
  final String date;
  final String time;
  final String displayAmount;
  final String statusLabel;
  final String iconKey;

  factory ProviderFinanceTransaction.fromJson(Map<String, dynamic> json) {
    return ProviderFinanceTransaction(
      title: json['title'] as String? ?? 'Booking',
      subtitle: json['subtitle'] as String? ?? '',
      date: json['date'] as String? ?? '',
      time: json['time'] as String? ?? '',
      displayAmount: json['displayAmount'] as String? ?? '\$0',
      statusLabel: json['statusLabel'] as String? ?? 'PENDING',
      iconKey: json['iconKey'] as String? ?? 'hotel',
    );
  }
}
