enum AuthAccessRole { admin, provider, planner }

AuthAccessRole authAccessRoleFromString(String? value) {
  final normalized = (value ?? '').trim().toUpperCase();
  if (normalized == 'ADMIN') {
    return AuthAccessRole.admin;
  }
  if (normalized == 'PROVIDER') {
    return AuthAccessRole.provider;
  }
  return AuthAccessRole.planner;
}

String authAccessRoleToApiValue(AuthAccessRole role) {
  switch (role) {
    case AuthAccessRole.admin:
      return 'ADMIN';
    case AuthAccessRole.provider:
      return 'PROVIDER';
    case AuthAccessRole.planner:
      return 'PLANNER';
  }
}

class AuthUser {
  const AuthUser({
    required this.id,
    required this.fullName,
    required this.email,
    required this.phone,
    required this.image,
    required this.role,
    required this.status,
  });

  final String id;
  final String fullName;
  final String? email;
  final String? phone;
  final String? image;
  final String role;
  final String status;

  AuthAccessRole get authAccessRole => authAccessRoleFromString(role);
  bool get isAdmin => authAccessRole == AuthAccessRole.admin;
  bool get isProvider => authAccessRole == AuthAccessRole.provider;
  bool get isPlanner => authAccessRole == AuthAccessRole.planner;
  String get landingRoute {
    if (isAdmin) return '/admin_provider_approvals';
    if (isProvider) return '/provider_dashboard';
    return '/home';
  }

  factory AuthUser.fromJson(Map<String, dynamic> json) {
    return AuthUser(
      id: json['id'] as String? ?? '',
      fullName: json['fullName'] as String? ?? 'Tripwise Traveler',
      email: json['email'] as String?,
      phone: json['phone'] as String?,
      image: json['image'] as String?,
      role: json['role'] as String? ?? 'USER',
      status: json['status'] as String? ?? 'ACTIVE',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fullName': fullName,
      'email': email,
      'phone': phone,
      'image': image,
      'role': role,
      'status': status,
    };
  }
}

class AuthSessionData {
  const AuthSessionData({
    required this.user,
    required this.token,
    required this.expiresAt,
    required this.ttlDays,
  });

  final AuthUser user;
  final String token;
  final DateTime expiresAt;
  final int ttlDays;

  bool get isExpired => DateTime.now().isAfter(expiresAt);
  String get landingRoute => user.landingRoute;
  bool get isAdmin => user.isAdmin;
  bool get isProvider => user.isProvider;
  bool get isPlanner => user.isPlanner;

  factory AuthSessionData.fromAuthResponse(Map<String, dynamic> json) {
    final session = (json['session'] as Map<String, dynamic>?) ?? const {};
    return AuthSessionData(
      user: AuthUser.fromJson(
        (json['user'] as Map<String, dynamic>?) ?? const {},
      ),
      token: session['token'] as String? ?? '',
      expiresAt:
          DateTime.tryParse(session['expiresAt'] as String? ?? '') ??
          DateTime.now(),
      ttlDays: (session['ttlDays'] as num?)?.toInt() ?? 14,
    );
  }

  factory AuthSessionData.fromMeResponse(
    Map<String, dynamic> json, {
    required String token,
  }) {
    final session = (json['session'] as Map<String, dynamic>?) ?? const {};
    return AuthSessionData(
      user: AuthUser.fromJson(
        (json['user'] as Map<String, dynamic>?) ?? const {},
      ),
      token: token,
      expiresAt:
          DateTime.tryParse(session['expiresAt'] as String? ?? '') ??
          DateTime.now(),
      ttlDays: (session['ttlDays'] as num?)?.toInt() ?? 14,
    );
  }

  factory AuthSessionData.fromStoredJson(Map<String, dynamic> json) {
    return AuthSessionData(
      user: AuthUser.fromJson(
        (json['user'] as Map<String, dynamic>?) ?? const {},
      ),
      token: json['token'] as String? ?? '',
      expiresAt:
          DateTime.tryParse(json['expiresAt'] as String? ?? '') ??
          DateTime.now(),
      ttlDays: (json['ttlDays'] as num?)?.toInt() ?? 14,
    );
  }

  Map<String, dynamic> toStoredJson() {
    return {
      'user': user.toJson(),
      'token': token,
      'expiresAt': expiresAt.toIso8601String(),
      'ttlDays': ttlDays,
    };
  }
}
