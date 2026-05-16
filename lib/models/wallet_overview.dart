class WalletOverview {
  WalletOverview({
    required this.user,
    required this.balance,
    required this.currency,
    required this.loyaltyPoints,
    required this.pointsValueVnd,
    required this.tier,
    required this.cards,
    required this.transactions,
  });

  final WalletUser? user;
  final double balance;
  final String currency;
  final int loyaltyPoints;
  final double pointsValueVnd;
  final WalletTier tier;
  final List<WalletCard> cards;
  final List<WalletTransaction> transactions;

  WalletCard? get defaultCard {
    if (cards.isEmpty) return null;
    for (final c in cards) {
      if (c.isDefault) return c;
    }
    return cards.first;
  }

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
      cards: ((json['cards'] as List<dynamic>?) ?? const [])
          .map((e) => WalletCard.fromJson(e as Map<String, dynamic>))
          .toList(),
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

class WalletCard {
  WalletCard({
    required this.id,
    required this.brand,
    required this.last4,
    required this.holderName,
    required this.balance,
    required this.isDefault,
  });

  final String id;
  final String brand;
  final String last4;
  final String? holderName;
  final double balance;
  final bool isDefault;

  factory WalletCard.fromJson(Map<String, dynamic> json) => WalletCard(
        id: json['id'] as String? ?? '',
        brand: json['brand'] as String? ?? 'CARD',
        last4: json['last4'] as String? ?? '••••',
        holderName: json['holderName'] as String?,
        balance: (json['balance'] as num?)?.toDouble() ?? 0,
        isDefault: json['isDefault'] as bool? ?? false,
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

class WalletTransactionPage {
  WalletTransactionPage({
    required this.items,
    required this.total,
    required this.hasMore,
    required this.nextOffset,
  });

  final List<WalletTransaction> items;
  final int total;
  final bool hasMore;
  final int nextOffset;

  factory WalletTransactionPage.fromJson(Map<String, dynamic> json) =>
      WalletTransactionPage(
        items: ((json['items'] as List<dynamic>?) ?? const [])
            .map((e) => WalletTransaction.fromJson(e as Map<String, dynamic>))
            .toList(),
        total: (json['total'] as num?)?.toInt() ?? 0,
        hasMore: json['hasMore'] as bool? ?? false,
        nextOffset: (json['nextOffset'] as num?)?.toInt() ?? 0,
      );
}
