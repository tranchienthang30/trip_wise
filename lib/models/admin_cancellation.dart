class AdminCancellationRequestsResponse {
  const AdminCancellationRequestsResponse({
    required this.pendingCount,
    required this.totalRefundAmount,
    required this.displayTotalRefundAmount,
    required this.requests,
  });

  final int pendingCount;
  final num totalRefundAmount;
  final String displayTotalRefundAmount;
  final List<AdminCancellationRequest> requests;

  factory AdminCancellationRequestsResponse.fromJson(
    Map<String, dynamic> json,
  ) {
    final rawRequests = json['requests'];
    return AdminCancellationRequestsResponse(
      pendingCount: (json['pendingCount'] as num?)?.toInt() ?? 0,
      totalRefundAmount: json['totalRefundAmount'] as num? ?? 0,
      displayTotalRefundAmount:
          json['displayTotalRefundAmount'] as String? ?? '\$0',
      requests: rawRequests is List
          ? rawRequests
              .whereType<Map<String, dynamic>>()
              .map(AdminCancellationRequest.fromJson)
              .toList()
          : const [],
    );
  }
}

class AdminCancellationRequest {
  const AdminCancellationRequest({
    required this.id,
    required this.bookingId,
    required this.userId,
    required this.userName,
    required this.userEmail,
    required this.providerId,
    required this.providerName,
    required this.title,
    required this.subtitle,
    required this.dateLabel,
    required this.requestedAt,
    required this.cancelDeadline,
    required this.amount,
    required this.displayAmount,
  });

  final String id;
  final String bookingId;
  final String userId;
  final String userName;
  final String? userEmail;
  final String providerId;
  final String providerName;
  final String title;
  final String subtitle;
  final String dateLabel;
  final String? requestedAt;
  final String? cancelDeadline;
  final num amount;
  final String displayAmount;

  factory AdminCancellationRequest.fromJson(Map<String, dynamic> json) {
    return AdminCancellationRequest(
      id: json['id'] as String? ?? '',
      bookingId: json['bookingId'] as String? ?? '',
      userId: json['userId'] as String? ?? '',
      userName: json['userName'] as String? ?? 'Tripwise user',
      userEmail: json['userEmail'] as String?,
      providerId: json['providerId'] as String? ?? '',
      providerName: json['providerName'] as String? ?? 'Tripwise provider',
      title: json['title'] as String? ?? 'Tripwise booking',
      subtitle: json['subtitle'] as String? ?? '',
      dateLabel: json['dateLabel'] as String? ?? 'Dates not set',
      requestedAt: json['requestedAt'] as String?,
      cancelDeadline: json['cancelDeadline'] as String?,
      amount: json['amount'] as num? ?? 0,
      displayAmount: json['displayAmount'] as String? ?? '\$0',
    );
  }
}
