class DirectConversationPage {
  DirectConversationPage({required this.items, required this.total});

  final List<DirectConversation> items;
  final int total;

  factory DirectConversationPage.fromJson(Map<String, dynamic> json) {
    return DirectConversationPage(
      items: ((json['items'] as List<dynamic>?) ?? const [])
          .map(
            (item) => DirectConversation.fromJson(item as Map<String, dynamic>),
          )
          .toList(),
      total: (json['total'] as num?)?.toInt() ?? 0,
    );
  }
}

class DirectConversationDetail {
  DirectConversationDetail({
    required this.conversation,
    required this.messages,
  });

  final DirectConversation conversation;
  final List<DirectMessage> messages;

  factory DirectConversationDetail.fromJson(Map<String, dynamic> json) {
    return DirectConversationDetail(
      conversation: DirectConversation.fromJson(
        (json['conversation'] as Map<String, dynamic>?) ?? const {},
      ),
      messages: ((json['messages'] as List<dynamic>?) ?? const [])
          .map((item) => DirectMessage.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }
}

class DirectConversation {
  DirectConversation({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.avatarUrl,
    required this.providerId,
    required this.bookingId,
    required this.listingId,
    required this.lastMessage,
    required this.lastMessageAt,
    required this.unread,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String title;
  final String subtitle;
  final String? avatarUrl;
  final String? providerId;
  final String? bookingId;
  final int? listingId;
  final String lastMessage;
  final String? lastMessageAt;
  final bool unread;
  final String? createdAt;
  final String? updatedAt;

  factory DirectConversation.fromJson(Map<String, dynamic> json) {
    return DirectConversation(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? 'Tripwise guest',
      subtitle: json['subtitle'] as String? ?? 'Direct message',
      avatarUrl: json['avatarUrl'] as String?,
      providerId: json['providerId'] as String?,
      bookingId: json['bookingId'] as String?,
      listingId: (json['listingId'] as num?)?.toInt(),
      lastMessage: json['lastMessage'] as String? ?? '',
      lastMessageAt: json['lastMessageAt'] as String?,
      unread: json['unread'] as bool? ?? false,
      createdAt: json['createdAt'] as String?,
      updatedAt: json['updatedAt'] as String?,
    );
  }
}

class DirectMessage {
  DirectMessage({
    required this.id,
    required this.conversationId,
    required this.senderUserId,
    required this.body,
    required this.isMine,
    required this.read,
    required this.createdAt,
    required this.timeLabel,
    required this.dateLabel,
  });

  final String id;
  final String conversationId;
  final String senderUserId;
  final String body;
  final bool isMine;
  final bool read;
  final String? createdAt;
  final String timeLabel;
  final String dateLabel;

  factory DirectMessage.fromJson(Map<String, dynamic> json) {
    return DirectMessage(
      id: json['id'] as String? ?? '',
      conversationId: json['conversationId'] as String? ?? '',
      senderUserId: json['senderUserId'] as String? ?? '',
      body: json['body'] as String? ?? '',
      isMine: json['isMine'] as bool? ?? false,
      read: json['read'] as bool? ?? false,
      createdAt: json['createdAt'] as String?,
      timeLabel: json['timeLabel'] as String? ?? '',
      dateLabel: json['dateLabel'] as String? ?? '',
    );
  }
}
