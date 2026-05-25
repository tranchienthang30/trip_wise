enum AdminListingStatus { pending, approved, rejected, all }

AdminListingStatus adminListingStatusFromString(String? value) {
  switch ((value ?? '').trim().toUpperCase()) {
    case 'APPROVED':
      return AdminListingStatus.approved;
    case 'REJECTED':
      return AdminListingStatus.rejected;
    case 'ALL':
      return AdminListingStatus.all;
    default:
      return AdminListingStatus.pending;
  }
}

String adminListingStatusToApiValue(AdminListingStatus status) {
  switch (status) {
    case AdminListingStatus.pending:
      return 'PENDING';
    case AdminListingStatus.approved:
      return 'APPROVED';
    case AdminListingStatus.rejected:
      return 'REJECTED';
    case AdminListingStatus.all:
      return 'ALL';
  }
}

String adminListingStatusLabel(AdminListingStatus status) {
  switch (status) {
    case AdminListingStatus.pending:
      return 'Pending';
    case AdminListingStatus.approved:
      return 'Approved';
    case AdminListingStatus.rejected:
      return 'Rejected';
    case AdminListingStatus.all:
      return 'All';
  }
}

class AdminListingsResponse {
  const AdminListingsResponse({
    required this.status,
    required this.counts,
    required this.listings,
  });

  final AdminListingStatus status;
  final AdminListingCounts counts;
  final List<AdminListing> listings;

  factory AdminListingsResponse.fromJson(Map<String, dynamic> json) {
    return AdminListingsResponse(
      status: adminListingStatusFromString(json['status'] as String?),
      counts: AdminListingCounts.fromJson(
        (json['counts'] as Map<String, dynamic>?) ?? const {},
      ),
      listings: ((json['listings'] as List<dynamic>?) ?? const [])
          .whereType<Map<String, dynamic>>()
          .map(AdminListing.fromJson)
          .toList(),
    );
  }
}

class AdminListingCounts {
  const AdminListingCounts({
    required this.pending,
    required this.approved,
    required this.rejected,
  });

  final int pending;
  final int approved;
  final int rejected;

  int countFor(AdminListingStatus status) {
    switch (status) {
      case AdminListingStatus.pending:
        return pending;
      case AdminListingStatus.approved:
        return approved;
      case AdminListingStatus.rejected:
        return rejected;
      case AdminListingStatus.all:
        return pending + approved + rejected;
    }
  }

  factory AdminListingCounts.fromJson(Map<String, dynamic> json) {
    return AdminListingCounts(
      pending: (json['PENDING'] as num?)?.toInt() ?? 0,
      approved: (json['APPROVED'] as num?)?.toInt() ?? 0,
      rejected: (json['REJECTED'] as num?)?.toInt() ?? 0,
    );
  }
}

class AdminListing {
  const AdminListing({
    required this.id,
    required this.providerId,
    required this.providerName,
    required this.title,
    required this.location,
    required this.category,
    required this.status,
    required this.imageUrl,
    required this.description,
    required this.amenities,
    required this.bedrooms,
    required this.bathrooms,
    required this.maxGuests,
    required this.roomCount,
    required this.priceFrom,
    required this.priceTo,
    required this.priceRangeLabel,
    required this.totalAvailableQty,
    required this.rooms,
    required this.submittedAt,
    required this.reviewedAt,
    required this.reviewedBy,
    required this.rejectionReason,
  });

  final int id;
  final String providerId;
  final String providerName;
  final String title;
  final String location;
  final String category;
  final AdminListingStatus status;
  final String? imageUrl;
  final String? description;
  final List<String> amenities;
  final int? bedrooms;
  final int? bathrooms;
  final int? maxGuests;
  final int roomCount;
  final double? priceFrom;
  final double? priceTo;
  final String priceRangeLabel;
  final int? totalAvailableQty;
  final List<AdminListingRoom> rooms;
  final String? submittedAt;
  final String? reviewedAt;
  final String? reviewedBy;
  final String? rejectionReason;

  bool get isPending => status == AdminListingStatus.pending;

  factory AdminListing.fromJson(Map<String, dynamic> json) {
    return AdminListing(
      id: (json['id'] as num?)?.toInt() ?? 0,
      providerId: json['providerId'] as String? ?? '',
      providerName: json['providerName'] as String? ?? 'Tripwise Provider',
      title: json['title'] as String? ?? 'Untitled listing',
      location: json['location'] as String? ?? 'Tripwise location',
      category: json['category'] as String? ?? 'Hotel',
      status: adminListingStatusFromString(json['status'] as String?),
      imageUrl: json['imageUrl'] as String?,
      description: json['description'] as String?,
      amenities: ((json['amenities'] as List<dynamic>?) ?? const [])
          .whereType<String>()
          .toList(),
      bedrooms: (json['bedrooms'] as num?)?.toInt(),
      bathrooms: (json['bathrooms'] as num?)?.toInt(),
      maxGuests: (json['maxGuests'] as num?)?.toInt(),
      roomCount: (json['roomCount'] as num?)?.toInt() ?? 0,
      priceFrom: (json['priceFrom'] as num?)?.toDouble(),
      priceTo: (json['priceTo'] as num?)?.toDouble(),
      priceRangeLabel: json['priceRangeLabel'] as String? ?? 'No room price',
      totalAvailableQty: (json['totalAvailableQty'] as num?)?.toInt(),
      rooms: ((json['rooms'] as List<dynamic>?) ?? const [])
          .whereType<Map<String, dynamic>>()
          .map(AdminListingRoom.fromJson)
          .toList(),
      submittedAt: json['submittedAt'] as String?,
      reviewedAt: json['reviewedAt'] as String?,
      reviewedBy: json['reviewedBy'] as String?,
      rejectionReason: json['rejectionReason'] as String?,
    );
  }
}

class AdminListingRoom {
  const AdminListingRoom({
    required this.id,
    required this.roomType,
    required this.capacity,
    required this.basePrice,
    required this.basePriceLabel,
    required this.imageUrl,
    required this.availableQty,
    required this.availabilityDate,
  });

  final int id;
  final String roomType;
  final int? capacity;
  final double basePrice;
  final String basePriceLabel;
  final String? imageUrl;
  final int? availableQty;
  final String? availabilityDate;

  factory AdminListingRoom.fromJson(Map<String, dynamic> json) {
    return AdminListingRoom(
      id: (json['id'] as num?)?.toInt() ?? 0,
      roomType: json['roomType'] as String? ?? 'Room',
      capacity: (json['capacity'] as num?)?.toInt(),
      basePrice: (json['basePrice'] as num?)?.toDouble() ?? 0,
      basePriceLabel: json['basePriceLabel'] as String? ?? '',
      imageUrl: json['imageUrl'] as String?,
      availableQty: (json['availableQty'] as num?)?.toInt(),
      availabilityDate: json['availabilityDate'] as String?,
    );
  }
}
