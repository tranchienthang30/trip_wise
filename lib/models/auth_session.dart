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
