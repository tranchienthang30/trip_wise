enum ProviderApplicationStatus { pending, approved, rejected, all }

ProviderApplicationStatus providerApplicationStatusFromString(String? value) {
  switch ((value ?? '').trim().toUpperCase()) {
    case 'APPROVED':
      return ProviderApplicationStatus.approved;
    case 'REJECTED':
      return ProviderApplicationStatus.rejected;
    case 'ALL':
      return ProviderApplicationStatus.all;
    case 'PENDING':
    default:
      return ProviderApplicationStatus.pending;
  }
}

String providerApplicationStatusToApiValue(ProviderApplicationStatus status) {
  switch (status) {
    case ProviderApplicationStatus.pending:
      return 'PENDING';
    case ProviderApplicationStatus.approved:
      return 'APPROVED';
    case ProviderApplicationStatus.rejected:
      return 'REJECTED';
    case ProviderApplicationStatus.all:
      return 'ALL';
  }
}

String providerApplicationStatusLabel(ProviderApplicationStatus status) {
  switch (status) {
    case ProviderApplicationStatus.pending:
      return 'Pending';
    case ProviderApplicationStatus.approved:
      return 'Approved';
    case ProviderApplicationStatus.rejected:
      return 'Rejected';
    case ProviderApplicationStatus.all:
      return 'All';
  }
}

class ProviderApplicationsResponse {
  const ProviderApplicationsResponse({
    required this.status,
    required this.counts,
    required this.applications,
  });

  final ProviderApplicationStatus status;
  final ProviderApplicationCounts counts;
  final List<ProviderApplication> applications;

  factory ProviderApplicationsResponse.fromJson(Map<String, dynamic> json) {
    final rawApplications = json['applications'];
    return ProviderApplicationsResponse(
      status: providerApplicationStatusFromString(json['status'] as String?),
      counts: ProviderApplicationCounts.fromJson(
        (json['counts'] as Map<String, dynamic>?) ?? const {},
      ),
      applications: rawApplications is List
          ? rawApplications
              .whereType<Map<String, dynamic>>()
              .map(ProviderApplication.fromJson)
              .toList()
          : const [],
    );
  }
}

class ProviderApplicationCounts {
  const ProviderApplicationCounts({
    required this.pending,
    required this.approved,
    required this.rejected,
  });

  final int pending;
  final int approved;
  final int rejected;

  int get all => pending + approved + rejected;

  int countFor(ProviderApplicationStatus status) {
    switch (status) {
      case ProviderApplicationStatus.pending:
        return pending;
      case ProviderApplicationStatus.approved:
        return approved;
      case ProviderApplicationStatus.rejected:
        return rejected;
      case ProviderApplicationStatus.all:
        return all;
    }
  }

  factory ProviderApplicationCounts.fromJson(Map<String, dynamic> json) {
    return ProviderApplicationCounts(
      pending: (json['PENDING'] as num?)?.toInt() ?? 0,
      approved: (json['APPROVED'] as num?)?.toInt() ?? 0,
      rejected: (json['REJECTED'] as num?)?.toInt() ?? 0,
    );
  }
}

class ProviderApplication {
  const ProviderApplication({
    required this.id,
    required this.userId,
    required this.applicantName,
    required this.email,
    required this.phone,
    required this.image,
    required this.role,
    required this.status,
    required this.specialty,
    required this.yearsExperience,
    required this.bio,
    required this.submittedAt,
    required this.reviewedAt,
    required this.reviewedBy,
    required this.rejectionReason,
  });

  final String id;
  final String userId;
  final String applicantName;
  final String? email;
  final String? phone;
  final String? image;
  final String role;
  final ProviderApplicationStatus status;
  final String specialty;
  final int? yearsExperience;
  final String bio;
  final String? submittedAt;
  final String? reviewedAt;
  final String? reviewedBy;
  final String? rejectionReason;

  bool get isPending => status == ProviderApplicationStatus.pending;
  bool get isApproved => status == ProviderApplicationStatus.approved;
  bool get isRejected => status == ProviderApplicationStatus.rejected;

  String get initials {
    final parts = applicantName
        .trim()
        .split(RegExp(r'\s+'))
        .where((part) => part.isNotEmpty)
        .toList();
    if (parts.isEmpty) return 'TW';
    if (parts.length == 1) {
      return parts.first.substring(0, parts.first.length >= 2 ? 2 : 1);
    }
    return '${parts.first[0]}${parts.last[0]}';
  }

  String get contactLabel {
    final emailValue = email?.trim();
    final phoneValue = phone?.trim();
    if (emailValue != null && emailValue.isNotEmpty) {
      if (phoneValue != null && phoneValue.isNotEmpty) {
        return '$emailValue - $phoneValue';
      }
      return emailValue;
    }
    if (phoneValue != null && phoneValue.isNotEmpty) return phoneValue;
    return 'No contact';
  }

  String get experienceLabel {
    final years = yearsExperience;
    if (years == null) return 'Experience not set';
    if (years == 1) return '1 year experience';
    return '$years years experience';
  }

  factory ProviderApplication.fromJson(Map<String, dynamic> json) {
    return ProviderApplication(
      id: json['id'] as String? ?? '',
      userId: json['userId'] as String? ?? '',
      applicantName: json['applicantName'] as String? ?? 'Tripwise Traveler',
      email: json['email'] as String?,
      phone: json['phone'] as String?,
      image: json['image'] as String?,
      role: json['role'] as String? ?? 'PLANNER',
      status: providerApplicationStatusFromString(json['status'] as String?),
      specialty: json['specialty'] as String? ?? 'Provider',
      yearsExperience: (json['yearsExperience'] as num?)?.toInt(),
      bio: json['bio'] as String? ?? '',
      submittedAt: json['submittedAt'] as String?,
      reviewedAt: json['reviewedAt'] as String?,
      reviewedBy: json['reviewedBy'] as String?,
      rejectionReason: json['rejectionReason'] as String?,
    );
  }
}
