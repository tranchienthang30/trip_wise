class AdminProviderPayoutsResponse {
  const AdminProviderPayoutsResponse({
    required this.period,
    required this.periodStart,
    required this.periodEnd,
    required this.commissionLabel,
    required this.adminWallet,
    required this.totals,
    required this.providers,
  });

  final String period;
  final String periodStart;
  final String periodEnd;
  final String commissionLabel;
  final AdminWalletSummary adminWallet;
  final AdminPayoutTotals totals;
  final List<AdminProviderPayoutSummary> providers;

  factory AdminProviderPayoutsResponse.fromJson(Map<String, dynamic> json) {
    final rawProviders = json['providers'];
    return AdminProviderPayoutsResponse(
      period: json['period'] as String? ?? 'monthly',
      periodStart: json['periodStart'] as String? ?? '',
      periodEnd: json['periodEnd'] as String? ?? '',
      commissionLabel: json['commissionLabel'] as String? ?? '8%',
      adminWallet: AdminWalletSummary.fromJson(
        (json['adminWallet'] as Map<String, dynamic>?) ?? const {},
      ),
      totals: AdminPayoutTotals.fromJson(
        (json['totals'] as Map<String, dynamic>?) ?? const {},
      ),
      providers: rawProviders is List
          ? rawProviders
              .whereType<Map<String, dynamic>>()
              .map(AdminProviderPayoutSummary.fromJson)
              .toList()
          : const [],
    );
  }
}

class AdminWalletSummary {
  const AdminWalletSummary({
    required this.userId,
    required this.balance,
    required this.displayBalance,
  });

  final String userId;
  final num balance;
  final String displayBalance;

  factory AdminWalletSummary.fromJson(Map<String, dynamic> json) {
    return AdminWalletSummary(
      userId: json['userId'] as String? ?? '',
      balance: json['balance'] as num? ?? 0,
      displayBalance: json['displayBalance'] as String? ?? '\$0',
    );
  }
}

class AdminPayoutTotals {
  const AdminPayoutTotals({
    required this.bookingCount,
    required this.displayGrossAmount,
    required this.displayCommissionAmount,
    required this.displayProviderNetAmount,
  });

  final int bookingCount;
  final String displayGrossAmount;
  final String displayCommissionAmount;
  final String displayProviderNetAmount;

  factory AdminPayoutTotals.fromJson(Map<String, dynamic> json) {
    return AdminPayoutTotals(
      bookingCount: (json['bookingCount'] as num?)?.toInt() ?? 0,
      displayGrossAmount: json['displayGrossAmount'] as String? ?? '\$0',
      displayCommissionAmount:
          json['displayCommissionAmount'] as String? ?? '\$0',
      displayProviderNetAmount:
          json['displayProviderNetAmount'] as String? ?? '\$0',
    );
  }
}

class AdminProviderPayoutSummary {
  const AdminProviderPayoutSummary({
    required this.providerId,
    required this.providerName,
    required this.bookingCount,
    required this.displayGrossAmount,
    required this.displayCommissionAmount,
    required this.displayProviderNetAmount,
  });

  final String providerId;
  final String providerName;
  final int bookingCount;
  final String displayGrossAmount;
  final String displayCommissionAmount;
  final String displayProviderNetAmount;

  factory AdminProviderPayoutSummary.fromJson(Map<String, dynamic> json) {
    return AdminProviderPayoutSummary(
      providerId: json['providerId'] as String? ?? '',
      providerName: json['providerName'] as String? ?? 'Tripwise Provider',
      bookingCount: (json['bookingCount'] as num?)?.toInt() ?? 0,
      displayGrossAmount: json['displayGrossAmount'] as String? ?? '\$0',
      displayCommissionAmount:
          json['displayCommissionAmount'] as String? ?? '\$0',
      displayProviderNetAmount:
          json['displayProviderNetAmount'] as String? ?? '\$0',
    );
  }
}
