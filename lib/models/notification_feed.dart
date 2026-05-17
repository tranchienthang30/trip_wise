// In-app notification inbox + preferences. Backed by GET/POST/PUT
// `/api/notifications*` (mirrors the wallet slice's model shape).

class AppNotification {
  AppNotification({
    required this.id,
    required this.type,
    required this.title,
    required this.body,
    required this.read,
    required this.actionRoute,
    required this.createdAt,
    required this.timeLabel,
  });

  final String id;

  /// BOOKING | TRIP | MESSAGE | PROMO | SYSTEM
  final String type;
  final String title;
  final String body;
  final bool read;

  /// Optional in-app GoRouter path to navigate to when tapped.
  final String? actionRoute;
  final String createdAt;

  /// Relative, server-formatted (e.g. "2h ago", "Yesterday", "May 12").
  final String timeLabel;

  AppNotification copyWith({bool? read}) => AppNotification(
        id: id,
        type: type,
        title: title,
        body: body,
        read: read ?? this.read,
        actionRoute: actionRoute,
        createdAt: createdAt,
        timeLabel: timeLabel,
      );

  factory AppNotification.fromJson(Map<String, dynamic> json) =>
      AppNotification(
        id: json['id'] as String? ?? '',
        type: json['type'] as String? ?? 'SYSTEM',
        title: json['title'] as String? ?? '',
        body: json['body'] as String? ?? '',
        read: json['read'] as bool? ?? false,
        actionRoute: json['actionRoute'] as String?,
        createdAt: json['createdAt'] as String? ?? '',
        timeLabel: json['timeLabel'] as String? ?? '',
      );
}

class NotificationPage {
  NotificationPage({
    required this.items,
    required this.total,
    required this.unreadCount,
    required this.hasMore,
    required this.nextOffset,
  });

  final List<AppNotification> items;
  final int total;
  final int unreadCount;
  final bool hasMore;
  final int nextOffset;

  factory NotificationPage.fromJson(Map<String, dynamic> json) =>
      NotificationPage(
        items: ((json['items'] as List<dynamic>?) ?? const [])
            .map((e) => AppNotification.fromJson(e as Map<String, dynamic>))
            .toList(),
        total: (json['total'] as num?)?.toInt() ?? 0,
        unreadCount: (json['unreadCount'] as num?)?.toInt() ?? 0,
        hasMore: json['hasMore'] as bool? ?? false,
        nextOffset: (json['nextOffset'] as num?)?.toInt() ?? 0,
      );
}

class NotificationSummary {
  NotificationSummary({required this.unreadCount, required this.total});

  final int unreadCount;
  final int total;

  factory NotificationSummary.fromJson(Map<String, dynamic> json) =>
      NotificationSummary(
        unreadCount: (json['unreadCount'] as num?)?.toInt() ?? 0,
        total: (json['total'] as num?)?.toInt() ?? 0,
      );
}

class NotificationPreferences {
  NotificationPreferences({
    required this.push,
    required this.email,
    required this.tripReminders,
    required this.bookingUpdates,
    required this.messages,
    required this.promotions,
  });

  final bool push;
  final bool email;
  final bool tripReminders;
  final bool bookingUpdates;
  final bool messages;
  final bool promotions;

  NotificationPreferences copyWith({
    bool? push,
    bool? email,
    bool? tripReminders,
    bool? bookingUpdates,
    bool? messages,
    bool? promotions,
  }) =>
      NotificationPreferences(
        push: push ?? this.push,
        email: email ?? this.email,
        tripReminders: tripReminders ?? this.tripReminders,
        bookingUpdates: bookingUpdates ?? this.bookingUpdates,
        messages: messages ?? this.messages,
        promotions: promotions ?? this.promotions,
      );

  Map<String, dynamic> toJson() => {
        'push': push,
        'email': email,
        'tripReminders': tripReminders,
        'bookingUpdates': bookingUpdates,
        'messages': messages,
        'promotions': promotions,
      };

  factory NotificationPreferences.fromJson(Map<String, dynamic> json) =>
      NotificationPreferences(
        push: json['push'] as bool? ?? true,
        email: json['email'] as bool? ?? true,
        tripReminders: json['tripReminders'] as bool? ?? true,
        bookingUpdates: json['bookingUpdates'] as bool? ?? true,
        messages: json['messages'] as bool? ?? true,
        promotions: json['promotions'] as bool? ?? false,
      );
}
