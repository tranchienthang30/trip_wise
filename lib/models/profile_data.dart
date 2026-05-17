class ProfileData {
  ProfileData({
    required this.user,
    required this.provider,
    required this.verification,
  });

  final ProfileUser user;
  final ProfileProvider provider;
  final ProfileVerification verification;

  factory ProfileData.fromJson(Map<String, dynamic> json) {
    return ProfileData(
      user: ProfileUser.fromJson(
        (json['user'] as Map<String, dynamic>?) ?? const {},
      ),
      provider: ProfileProvider.fromJson(
        (json['provider'] as Map<String, dynamic>?) ?? const {},
      ),
      verification: ProfileVerification.fromJson(
        (json['verification'] as Map<String, dynamic>?) ?? const {},
      ),
    );
  }
}

class ProfileUser {
  ProfileUser({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.image,
    required this.tierLabel,
    required this.countriesVisited,
  });

  final String id;
  final String name;
  final String? email;
  final String? phone;
  final String? image;
  final String tierLabel;
  final int countriesVisited;

  factory ProfileUser.fromJson(Map<String, dynamic> json) {
    return ProfileUser(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? 'Tripwise Traveler',
      email: json['email'] as String?,
      phone: json['phone'] as String?,
      image: json['image'] as String?,
      tierLabel: json['tierLabel'] as String? ?? 'Premium Voyager',
      countriesVisited: (json['countriesVisited'] as num?)?.toInt() ?? 0,
    );
  }
}

class ProfileProvider {
  ProfileProvider({
    required this.isRegistered,
    required this.ctaLabel,
    required this.ctaRoute,
    required this.dashboardRoute,
  });

  final bool isRegistered;
  final String ctaLabel;
  final String ctaRoute;
  final String dashboardRoute;

  factory ProfileProvider.fromJson(Map<String, dynamic> json) {
    return ProfileProvider(
      isRegistered: json['isRegistered'] as bool? ?? false,
      ctaLabel: json['ctaLabel'] as String? ?? 'Start Registration',
      ctaRoute: json['ctaRoute'] as String? ?? '/provider_registration_form',
      dashboardRoute:
          json['dashboardRoute'] as String? ?? '/provider_dashboard',
    );
  }
}

class ProfileVerification {
  ProfileVerification({
    required this.passportUploaded,
    required this.passportNote,
    required this.addressUploaded,
    required this.addressNote,
    required this.updatedAt,
  });

  final bool passportUploaded;
  final String passportNote;
  final bool addressUploaded;
  final String addressNote;
  final String? updatedAt;

  factory ProfileVerification.fromJson(Map<String, dynamic> json) {
    return ProfileVerification(
      passportUploaded: json['passportUploaded'] as bool? ?? false,
      passportNote: json['passportNote'] as String? ?? 'Not submitted',
      addressUploaded: json['addressUploaded'] as bool? ?? false,
      addressNote: json['addressNote'] as String? ?? 'Not submitted',
      updatedAt: json['updatedAt'] as String?,
    );
  }
}
