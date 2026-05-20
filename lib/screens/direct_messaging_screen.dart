import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../models/direct_message.dart';
import '../services/chat_api.dart';
import '../services/direct_messages_api.dart';
import '../services/rule_based_chatbot_service.dart';
import '../widgets/shared_top_bars.dart';

class DirectMessagingScreen extends StatefulWidget {
  const DirectMessagingScreen({
    super.key,
    this.conversationId,
    this.orderId,
    this.mode,
  });

  final String? conversationId;
  final String? orderId;
  final String? mode;

  @override
  State<DirectMessagingScreen> createState() => _DirectMessagingScreenState();
}

class _DirectMessagingScreenState extends State<DirectMessagingScreen> {
  final DirectMessagesApi _api = DirectMessagesApi();
  final ChatApi _chatApi = ChatApi();
  final RuleBasedChatbotService _chatbot = RuleBasedChatbotService();
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  DirectConversation? _conversation;
  List<DirectMessage> _messages = const [];
  bool _isLoading = true;
  bool _isSending = false;
  String? _error;

  bool get _isProviderMode => widget.mode?.trim().toLowerCase() != 'user';
  bool get _hasRemoteTarget =>
      (widget.conversationId?.trim().isNotEmpty ?? false) ||
      (widget.orderId?.trim().isNotEmpty ?? false);
  bool get _isLocalAssistantMode => !_isProviderMode && !_hasRemoteTarget;

  @override
  void initState() {
    super.initState();
    _loadConversation();
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadConversation() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    if (_isLocalAssistantMode) {
      setState(() {
        _conversation = _assistantConversation();
        _messages = [
          _localMessage(body: RuleBasedChatbotService.greeting, isMine: false),
        ];
        _isLoading = false;
      });
      _scrollToBottom();
      return;
    }

    try {
      final detail = await _initialConversationDetail();
      await _api.markRead(detail.conversation.id);
      if (!mounted) return;
      setState(() {
        _conversation = detail.conversation;
        _messages = detail.messages;
        _isLoading = false;
      });
      _scrollToBottom();
    } catch (error) {
      if (!mounted) return;
      if (error is _NoConversationsException) {
        setState(() {
          _conversation = null;
          _messages = const [];
          _isLoading = false;
          _error = null;
        });
        return;
      }
      setState(() {
        _error = error.toString();
        _isLoading = false;
      });
    }
  }

  Future<DirectConversationDetail> _initialConversationDetail() async {
    final orderId = widget.orderId?.trim();
    if (orderId != null && orderId.isNotEmpty) {
      return _api.openOrderConversation(orderId);
    }

    final conversationId = widget.conversationId?.trim();
    if (conversationId != null && conversationId.isNotEmpty) {
      return _api.fetchConversation(conversationId);
    }

    final page = await _api.fetchConversations();
    if (page.items.isEmpty) {
      throw const _NoConversationsException();
    }
    return _api.fetchConversation(page.items.first.id);
  }

  Future<void> _sendMessage() async {
    final conversation = _conversation;
    final text = _messageController.text.trim();
    if (conversation == null || text.isEmpty || _isSending) return;

    if (_isLocalAssistantMode) {
      _sendAssistantMessage(conversation.id, text);
      return;
    }

    setState(() => _isSending = true);
    try {
      final message = await _api.sendMessage(conversation.id, text);
      if (!mounted) return;
      _messageController.clear();
      setState(() {
        _messages = [..._messages, message];
        _isSending = false;
      });
      _scrollToBottom();
    } catch (error) {
      if (!mounted) return;
      setState(() => _isSending = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Could not send message: $error')));
    }
  }

  void _sendAssistantMessage(String conversationId, String text) {
    _messageController.clear();
    setState(() {
      _messages = [
        ..._messages,
        _localMessage(conversationId: conversationId, body: text, isMine: true),
      ];
      _isSending = true;
    });
    _scrollToBottom();

    Future.delayed(const Duration(milliseconds: 450), () async {
      if (!mounted) return;
      final reply = await _assistantReply(text);
      if (!mounted) return;
      setState(() {
        _messages = [
          ..._messages,
          _localMessage(
            conversationId: conversationId,
            body: reply,
            isMine: false,
          ),
        ];
        _isSending = false;
      });
      _scrollToBottom();
    });
  }

  Future<String> _assistantReply(String text) async {
    try {
      final response = await _chatApi.sendMessage(text);
      if (response.reply.trim().isNotEmpty) {
        return response.reply.trim();
      }
    } catch (_) {
      // Keep the assistant usable when the backend or LLM provider is offline.
    }
    return _chatbot.respondTo(text);
  }

  DirectConversation _assistantConversation() {
    final now = DateTime.now().toIso8601String();
    return DirectConversation(
      id: 'local-rule-based-assistant',
      title: 'TripWise Assistant',
      subtitle: 'Rule-based chatbot',
      avatarUrl: null,
      providerId: null,
      bookingId: null,
      listingId: null,
      lastMessage: RuleBasedChatbotService.greeting,
      lastMessageAt: now,
      unread: false,
      createdAt: now,
      updatedAt: now,
    );
  }

  DirectMessage _localMessage({
    String conversationId = 'local-rule-based-assistant',
    required String body,
    required bool isMine,
  }) {
    final now = DateTime.now();
    final hour = now.hour.toString().padLeft(2, '0');
    final minute = now.minute.toString().padLeft(2, '0');
    return DirectMessage(
      id: 'local-${now.microsecondsSinceEpoch}-${isMine ? 'user' : 'bot'}',
      conversationId: conversationId,
      senderUserId: isMine ? 'current-user' : 'tripwise-assistant',
      body: body,
      isMine: isMine,
      read: true,
      createdAt: now.toIso8601String(),
      timeLabel: '$hour:$minute',
      dateLabel: 'TODAY',
    );
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isDesktop = constraints.maxWidth > 768;
        return Scaffold(
          backgroundColor: const Color(0xFFF8F9FF),
          appBar: _isProviderMode
              ? const ProviderAppBar()
              : const PlannerAppBar(backRoute: '/my_trips'),
          body: Row(
            children: [
              if (isDesktop && _isProviderMode) _buildSideNav(),
              Expanded(
                child: Column(
                  children: [
                    Expanded(child: _buildContent()),
                    _buildMessageInput(),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.cloud_off_rounded,
                size: 44,
                color: Color(0xFF64748B),
              ),
              const SizedBox(height: 16),
              const Text(
                'Unable to load messages',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 8),
              Text(
                _error!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Color(0xFF64748B)),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _loadConversation,
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    if (_conversation == null) {
      return Column(
        children: [
          _buildBackBar(),
          const Expanded(
            child: Center(
              child: Text(
                'No conversations yet',
                style: TextStyle(
                  color: Color(0xFF64748B),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      );
    }

    return Column(
      children: [
        _buildBackBar(),
        Expanded(child: _buildChatList()),
      ],
    );
  }

  Widget _buildBackBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 18, 24, 0),
      child: Align(
        alignment: Alignment.centerLeft,
        child: TextButton.icon(
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go(_isProviderMode ? '/order_manager' : '/my_trips');
            }
          },
          icon: const Icon(Icons.arrow_back_rounded),
          label: const Text('Back'),
          style: TextButton.styleFrom(
            foregroundColor: const Color(0xFF004779),
            textStyle: const TextStyle(fontWeight: FontWeight.w800),
          ),
        ),
      ),
    );
  }

  Widget _buildSideNav() {
    return Container(
      width: 80,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          right: BorderSide(
            color: const Color(0xFFEFF6FF).withValues(alpha: 0.1),
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF005F9F).withValues(alpha: 0.02),
            blurRadius: 20,
            offset: const Offset(4, 0),
          ),
        ],
      ),
      child: Column(
        children: [
          const SizedBox(height: 32),
          _buildNavItem(Icons.dashboard, 'DASH', false, '/provider_dashboard'),
          const SizedBox(height: 32),
          _buildNavItem(Icons.calendar_month, 'BOOK', false, '/order_manager'),
          const SizedBox(height: 32),
          _buildNavItem(Icons.chat, 'CHAT', true, '/direct_messaging'),
        ],
      ),
    );
  }

  Widget _buildNavItem(
    IconData icon,
    String label,
    bool isSelected,
    String route,
  ) {
    return InkWell(
      onTap: isSelected ? null : () => context.go(route),
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected
                  ? const Color(0xFFF97316)
                  : const Color(0xFF94A3B8),
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: isSelected
                    ? const Color(0xFFF97316)
                    : const Color(0xFF94A3B8),
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChatList() {
    final children = <Widget>[
      _buildConversationHeader(_conversation!),
      const SizedBox(height: 24),
    ];

    if (_isLocalAssistantMode) {
      children.add(_buildAssistantQuickPrompts());
      children.add(const SizedBox(height: 24));
    }

    String? currentDateLabel;
    for (final message in _messages) {
      if (message.dateLabel != currentDateLabel) {
        currentDateLabel = message.dateLabel;
        children.add(
          _buildDateHeader(
            currentDateLabel.isEmpty ? 'MESSAGES' : currentDateLabel,
          ),
        );
        children.add(const SizedBox(height: 16));
      }
      children.add(
        message.isMine
            ? _buildSentMessage(message)
            : _buildReceivedMessage(message),
      );
      children.add(const SizedBox(height: 24));
    }

    children.add(const SizedBox(height: 32));

    return RefreshIndicator(
      onRefresh: _loadConversation,
      child: ListView(
        controller: _scrollController,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
        children: children,
      ),
    );
  }

  Widget _buildAssistantQuickPrompts() {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: RuleBasedChatbotService.quickPrompts.map((prompt) {
        return ActionChip(
          avatar: const Icon(
            Icons.auto_awesome_rounded,
            size: 16,
            color: Color(0xFF004779),
          ),
          label: Text(prompt),
          labelStyle: const TextStyle(
            color: Color(0xFF004779),
            fontWeight: FontWeight.w700,
          ),
          backgroundColor: Colors.white,
          side: const BorderSide(color: Color(0xFFE0ECF8)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(999),
          ),
          onPressed: _isSending
              ? null
              : () => _sendAssistantMessage(_conversation!.id, prompt),
        );
      }).toList(),
    );
  }

  Widget _buildConversationHeader(DirectConversation conversation) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF005F9F).withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: const Color(0xFFE5E8F0),
            backgroundImage: conversation.avatarUrl == null
                ? null
                : NetworkImage(conversation.avatarUrl!),
            child: conversation.avatarUrl == null
                ? Icon(
                    _isLocalAssistantMode
                        ? Icons.smart_toy_rounded
                        : Icons.person,
                    color: const Color(0xFF64748B),
                  )
                : null,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  conversation.title,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF004779),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  conversation.subtitle.toUpperCase(),
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF64748B),
                    letterSpacing: 0.4,
                  ),
                ),
              ],
            ),
          ),
          if (!_isLocalAssistantMode) ...[
            IconButton(
              icon: const Icon(Icons.call, color: Color(0xFF64748B)),
              onPressed: () {},
            ),
            IconButton(
              icon: const Icon(Icons.more_vert, color: Color(0xFF64748B)),
              onPressed: () {},
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDateHeader(String text) {
    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: const Color(0xFFECEEF4),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Color(0xFF414750),
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }

  Widget _buildReceivedMessage(DirectMessage message) {
    return Align(
      alignment: Alignment.centerLeft,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 400),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.zero,
                  topRight: Radius.circular(16),
                  bottomLeft: Radius.circular(16),
                  bottomRight: Radius.circular(16),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Color(0x0A005F9F),
                    blurRadius: 40,
                    offset: Offset(0, 10),
                  ),
                ],
              ),
              child: Text(
                message.body,
                style: const TextStyle(
                  fontSize: 16,
                  color: Color(0xFF191C20),
                  height: 1.5,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.only(left: 4),
              child: Text(
                message.timeLabel,
                style: const TextStyle(fontSize: 10, color: Color(0xFF94A3B8)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSentMessage(DirectMessage message) {
    return Align(
      alignment: Alignment.centerRight,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 400),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF004779), Color(0xFF005F9F)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.zero,
                  bottomLeft: Radius.circular(16),
                  bottomRight: Radius.circular(16),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Color(0x1A005F9F),
                    blurRadius: 40,
                    offset: Offset(0, 10),
                  ),
                ],
              ),
              child: Text(
                message.body,
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.white,
                  height: 1.5,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.only(right: 4),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    message.timeLabel,
                    style: const TextStyle(
                      fontSize: 10,
                      color: Color(0xFF94A3B8),
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Icon(
                    Icons.done_all,
                    size: 12,
                    color: Color(0xFF004779),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageInput() {
    final enabled = !_isLoading && _conversation != null && !_isSending;

    return Container(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.9),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF005F9F).withValues(alpha: 0.04),
            blurRadius: 40,
            offset: const Offset(0, -10),
          ),
        ],
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 896),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: const BoxDecoration(
                  color: Color(0xFFF2F3F9),
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: const Icon(Icons.add, color: Color(0xFF004779)),
                  onPressed: enabled ? () {} : null,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Container(
                  height: 48,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x0A000000),
                        blurRadius: 2,
                        offset: Offset(0, 1),
                        blurStyle: BlurStyle.inner,
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: _messageController,
                    enabled: enabled,
                    textInputAction: TextInputAction.send,
                    onSubmitted: (_) => _sendMessage(),
                    decoration: InputDecoration(
                      hintText: _isLocalAssistantMode
                          ? 'Ask about tours, prices, or cancellation...'
                          : 'Type your message...',
                      hintStyle: const TextStyle(
                        fontSize: 16,
                        color: Color(0xFF94A3B8),
                      ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Container(
                width: 48,
                height: 48,
                decoration: const BoxDecoration(
                  color: Color(0xFFFF5E1F),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Color(0x33000000),
                      blurRadius: 15,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: IconButton(
                  icon: _isSending
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.send, color: Colors.white, size: 20),
                  onPressed: enabled ? _sendMessage : null,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NoConversationsException implements Exception {
  const _NoConversationsException();
}
