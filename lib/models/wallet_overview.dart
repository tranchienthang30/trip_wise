class WalletOverview {
  WalletOverview({
    required this.user,
    required this.balance,
    required this.currency,
    required this.loyaltyPoints,
    required this.pointsValueVnd,
    required this.tier,
    required this.transactions,
  });

  final WalletUser? user;
  final double balance;
  final String currency;
  final int loyaltyPoints;
  final double pointsValueVnd;
  final WalletTier tier;
  final List<WalletTransaction> transactions;

  factory WalletOverview.fromJson(Map<String, dynamic> json) {
    return WalletOverview(
      user: json['user'] == null
          ? null
          : WalletUser.fromJson(json['user'] as Map<String, dynamic>),
      balance: (json['balance'] as num?)?.toDouble() ?? 0,
      currency: json['currency'] as String? ?? 'VND',
      loyaltyPoints: (json['loyaltyPoints'] as num?)?.toInt() ?? 0,
      pointsValueVnd: (json['pointsValueVnd'] as num?)?.toDouble() ?? 0,
      tier: WalletTier.fromJson(
        (json['tier'] as Map<String, dynamic>?) ?? const {},
      ),
      transactions: ((json['transactions'] as List<dynamic>?) ?? const [])
          .map((e) => WalletTransaction.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class WalletUser {
  WalletUser({required this.id, required this.name, required this.image});

  final String id;
  final String name;
  final String? image;

  factory WalletUser.fromJson(Map<String, dynamic> json) => WalletUser(
        id: json['id'] as String? ?? '',
        name: json['name'] as String? ?? 'Traveler',
        image: json['image'] as String?,
      );
}

class WalletTier {
  WalletTier({
    required this.current,
    required this.next,
    required this.pointsToNext,
    required this.progress,
  });

  final String current;
  final String? next;
  final int? pointsToNext;
  final double progress;

  factory WalletTier.fromJson(Map<String, dynamic> json) => WalletTier(
        current: json['current'] as String? ?? '—',
        next: json['next'] as String?,
        pointsToNext: (json['pointsToNext'] as num?)?.toInt(),
        progress:
            ((json['progress'] as num?)?.toDouble() ?? 0).clamp(0.0, 1.0).toDouble(),
      );
}

class WalletTransaction {
  WalletTransaction({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.method,
    required this.amountVnd,
    required this.status,
  });

  final String id;
  final String title;
  final String subtitle;
  final String method;
  final double amountVnd;
  final String status;

  factory WalletTransaction.fromJson(Map<String, dynamic> json) =>
      WalletTransaction(
        id: json['id'] as String? ?? '',
        title: json['title'] as String? ?? 'Payment',
        subtitle: json['subtitle'] as String? ?? '',
        method: json['method'] as String? ?? 'UNKNOWN',
        amountVnd: (json['amountVnd'] as num?)?.toDouble() ?? 0,
        status: json['status'] as String? ?? 'UNKNOWN',
      );
}
