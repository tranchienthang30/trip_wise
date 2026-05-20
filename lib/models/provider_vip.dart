class ProviderVipData {
  ProviderVipData({
    required this.hero,
    required this.plans,
    required this.promotions,
    required this.impact,
  });

  final ProviderVipHero hero;
  final List<ProviderVipPlan> plans;
  final List<ProviderVipPromotion> promotions;
  final ProviderVipImpact impact;

  factory ProviderVipData.fromJson(Map<String, dynamic> json) {
    return ProviderVipData(
      hero: ProviderVipHero.fromJson(
        (json['hero'] as Map<String, dynamic>?) ?? const {},
      ),
      plans: ((json['plans'] as List<dynamic>?) ?? const [])
          .whereType<Map<String, dynamic>>()
          .map(ProviderVipPlan.fromJson)
          .toList(),
      promotions: ((json['promotions'] as List<dynamic>?) ?? const [])
          .whereType<Map<String, dynamic>>()
          .map(ProviderVipPromotion.fromJson)
          .toList(),
      impact: ProviderVipImpact.fromJson(
        (json['impact'] as Map<String, dynamic>?) ?? const {},
      ),
    );
  }
}

class ProviderVipHero {
  ProviderVipHero({
    required this.badge,
    required this.title,
    required this.description,
    required this.imageUrl,
  });

  final String badge;
  final String title;
  final String description;
  final String imageUrl;

  factory ProviderVipHero.fromJson(Map<String, dynamic> json) {
    return ProviderVipHero(
      badge: json['badge'] as String? ?? 'VIP SERVICES',
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      imageUrl: json['imageUrl'] as String? ?? '',
    );
  }
}

class ProviderVipPlan {
  ProviderVipPlan({
    required this.id,
    required this.name,
    required this.description,
    required this.isCurrent,
    required this.features,
    required this.stats,
    required this.priceLabel,
    required this.priceUnit,
    required this.ctaLabel,
    required this.ctaRoute,
  });

  final String id;
  final String name;
  final String description;
  final bool isCurrent;
  final List<String> features;
  final List<ProviderVipStat> stats;
  final String priceLabel;
  final String priceUnit;
  final String ctaLabel;
  final String? ctaRoute;

  factory ProviderVipPlan.fromJson(Map<String, dynamic> json) {
    return ProviderVipPlan(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      description: json['description'] as String? ?? '',
      isCurrent: json['isCurrent'] as bool? ?? false,
      features: ((json['features'] as List<dynamic>?) ?? const [])
          .whereType<String>()
          .toList(),
      stats: ((json['stats'] as List<dynamic>?) ?? const [])
          .whereType<Map<String, dynamic>>()
          .map(ProviderVipStat.fromJson)
          .toList(),
      priceLabel: json['priceLabel'] as String? ?? '',
      priceUnit: json['priceUnit'] as String? ?? '',
      ctaLabel: json['ctaLabel'] as String? ?? '',
      ctaRoute: json['ctaRoute'] as String?,
    );
  }
}

class ProviderVipStat {
  ProviderVipStat({required this.value, required this.label});

  final String value;
  final String label;

  factory ProviderVipStat.fromJson(Map<String, dynamic> json) {
    return ProviderVipStat(
      value: json['value'] as String? ?? '',
      label: json['label'] as String? ?? '',
    );
  }
}

class ProviderVipPromotion {
  ProviderVipPromotion({
    required this.id,
    required this.icon,
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.priceLabel,
    required this.priceUnit,
    required this.isSelected,
  });

  final String id;
  final String icon;
  final String title;
  final String description;
  final String imageUrl;
  final String priceLabel;
  final String priceUnit;
  final bool isSelected;

  factory ProviderVipPromotion.fromJson(Map<String, dynamic> json) {
    return ProviderVipPromotion(
      id: json['id'] as String? ?? '',
      icon: json['icon'] as String? ?? 'campaign',
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      imageUrl: json['imageUrl'] as String? ?? '',
      priceLabel: json['priceLabel'] as String? ?? '',
      priceUnit: json['priceUnit'] as String? ?? '',
      isSelected: json['isSelected'] as bool? ?? false,
    );
  }
}

class ProviderVipImpact {
  ProviderVipImpact({
    required this.reachIncreasePct,
    required this.bookingVelocityLabel,
  });

  final int reachIncreasePct;
  final String bookingVelocityLabel;

  factory ProviderVipImpact.fromJson(Map<String, dynamic> json) {
    return ProviderVipImpact(
      reachIncreasePct: (json['reachIncreasePct'] as num?)?.toInt() ?? 0,
      bookingVelocityLabel: json['bookingVelocityLabel'] as String? ?? '0x',
    );
  }
}
