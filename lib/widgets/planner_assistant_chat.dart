import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../constants/colors.dart';
import '../services/chat_api.dart';

void showPlannerAssistantSheet(BuildContext context) {
  final route = _currentRouteOf(context);
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (sheetContext) {
      return _PlannerAssistantSheet(currentRoute: route);
    },
  );
}

String _currentRouteOf(BuildContext context) {
  try {
    return GoRouterState.of(context).uri.toString();
  } catch (_) {
    return '';
  }
}

class PlannerAssistantHeaderButton extends StatelessWidget {
  const PlannerAssistantHeaderButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: 'Open planner assistant',
      child: SizedBox(
        width: 40,
        height: 40,
        child: Center(
          child: InkWell(
            onTap: () => showPlannerAssistantSheet(context),
            borderRadius: BorderRadius.circular(999),
            child: const _PlannerAssistantMascot(size: 34),
          ),
        ),
      ),
    );
  }
}

class _PlannerAssistantMascot extends StatelessWidget {
  const _PlannerAssistantMascot({
    required this.size,
    this.showSparkle = true,
    this.shadow = true,
  });

  final double size;
  final bool showSparkle;
  final bool shadow;

  @override
  Widget build(BuildContext context) {
    final faceSize = size * 0.62;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const LinearGradient(
          colors: [Color(0xFFBEE1FF), TripwiseColors.primary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: shadow
            ? [
                BoxShadow(
                  color: TripwiseColors.primary.withOpacity(0.18),
                  blurRadius: size * 0.3,
                  offset: Offset(0, size * 0.12),
                ),
              ]
            : null,
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: faceSize,
            height: faceSize,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.96),
              shape: BoxShape.circle,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _MascotEye(width: size * 0.09, height: size * 0.12),
                    SizedBox(width: size * 0.09),
                    _MascotEye(width: size * 0.09, height: size * 0.12),
                  ],
                ),
                SizedBox(height: size * 0.07),
                Container(
                  width: size * 0.24,
                  height: size * 0.09,
                  decoration: const BoxDecoration(
                    color: TripwiseColors.primary,
                    borderRadius: BorderRadius.vertical(
                      bottom: Radius.circular(99),
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (showSparkle)
            Positioned(
              top: size * 0.06,
              right: size * 0.06,
              child: Container(
                width: size * 0.29,
                height: size * 0.29,
                decoration: const BoxDecoration(
                  color: TripwiseColors.secondaryContainer,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.auto_awesome_rounded,
                  size: size * 0.18,
                  color: Colors.white,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _MascotEye extends StatelessWidget {
  const _MascotEye({this.width = 6, this.height = 8});

  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: TripwiseColors.onPrimaryFixed,
        borderRadius: BorderRadius.circular(99),
      ),
    );
  }
}

class _PlannerAssistantSheet extends StatefulWidget {
  const _PlannerAssistantSheet({required this.currentRoute});

  final String currentRoute;

  @override
  State<_PlannerAssistantSheet> createState() => _PlannerAssistantSheetState();
}

class _PlannerAssistantSheetState extends State<_PlannerAssistantSheet> {
  final ChatApi _chatApi = ChatApi();
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isSending = false;

  static const String _greeting =
      'Hello! I am Lumi Planner. Ask me anything about your next Tripwise plan.';

  static const List<String> _quickPrompts = [
    'I want to book a trip',
    'Suggest destinations',
    'Ask about tour prices',
    'Cancellation policy',
    'Payment methods',
    'Check my booking',
  ];

  static final List<_PlannerAssistantMessage> _persistedMessages = [
    const _PlannerAssistantMessage(text: _greeting, isUser: false),
  ];
  late final List<_PlannerAssistantMessage> _messages = _persistedMessages;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    if (!_scrollController.hasClients) {
      return;
    }

    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent,
      duration: const Duration(milliseconds: 260),
      curve: Curves.easeOut,
    );
  }

  Future<void> _sendMessage([String? presetText]) async {
    final text = (presetText ?? _controller.text).trim();
    if (text.isEmpty || _isSending) {
      return;
    }

    setState(() {
      _messages.add(_PlannerAssistantMessage(text: text, isUser: true));
      _isSending = true;
    });
    _controller.clear();
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());

    final reply = await _assistantReply(text);
    if (!mounted) return;
    setState(() {
      _messages.add(_PlannerAssistantMessage(text: reply, isUser: false));
      _isSending = false;
    });
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
  }

  Future<String> _assistantReply(String text) async {
    try {
      final response = await _chatApi.sendMessage(
        text,
        context: _chatContext(),
      );
      if (response.reply.trim().isNotEmpty) {
        return response.reply.trim();
      }
      return 'Lumi did not return a reply. Please try again.';
    } catch (error) {
      return 'Could not reach Lumi API: $error';
    }
  }

  Map<String, dynamic> _chatContext() {
    return {
      'route': widget.currentRoute,
      'screenTitle': 'Lumi Planner',
      'locale': Localizations.localeOf(context).toLanguageTag(),
      'history': _messages
          .take(_messages.length - 1)
          .toList()
          .reversed
          .take(8)
          .toList()
          .reversed
          .map(
            (message) => {
              'role': message.isUser ? 'user' : 'assistant',
              'text': message.text,
            },
          )
          .toList(),
    };
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(12, 12, 12, bottomInset + 12),
        child: Container(
          height: MediaQuery.of(context).size.height * 0.82,
          decoration: BoxDecoration(
            color: const Color(0xFFF7FAFF),
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.14),
                blurRadius: 30,
                offset: const Offset(0, 18),
              ),
            ],
          ),
          child: Column(
            children: [
              _buildHeader(context),
              Expanded(
                child: ListView(
                  controller: _scrollController,
                  padding: const EdgeInsets.fromLTRB(18, 12, 18, 20),
                  children: [
                    _buildIntroCard(),
                    const SizedBox(height: 18),
                    for (final message in _messages) ...[
                      _MessageBubble(message: message),
                      const SizedBox(height: 14),
                    ],
                  ],
                ),
              ),
              _buildComposer(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 18, 12, 16),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF0E6AAC), TripwiseColors.primary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.18),
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: _PlannerAssistantMascot(
                size: 38,
                shadow: false,
              ),
            ),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Lumi Planner',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'API-powered travel planning assistant',
                  style: TextStyle(
                    color: Color(0xFFD9EDFF),
                    fontSize: 13,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.close_rounded, color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildIntroCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: TripwiseColors.primary.withOpacity(0.06),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color: TripwiseColors.primaryFixed,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: const Text(
                  'Quick Start',
                  style: TextStyle(
                    color: TripwiseColors.primary,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const Spacer(),
              const Text(
                'Try a message',
                style: TextStyle(
                  color: Color(0xFF6A7381),
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          const Text(
            'Tap a suggestion below to chat with Lumi.',
            style: TextStyle(
              color: TripwiseColors.onSurfaceVariant,
              fontSize: 14,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: _quickPrompts
                .map(
                  (prompt) => ActionChip(
                    label: Text(prompt),
                    labelStyle: const TextStyle(
                      color: TripwiseColors.primary,
                      fontWeight: FontWeight.w700,
                    ),
                    backgroundColor: const Color(0xFFEFF6FF),
                    side: BorderSide.none,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(999),
                    ),
                    onPressed: _isSending ? null : () => _sendMessage(prompt),
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildComposer() {
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 12, 18, 18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(30)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 20,
            offset: const Offset(0, -6),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              minLines: 1,
              maxLines: 4,
              textInputAction: TextInputAction.send,
              onSubmitted: (_) => _sendMessage(),
              decoration: InputDecoration(
                hintText: 'Ask Lumi to plan your next step...',
                hintStyle: const TextStyle(color: Color(0xFF94A3B8)),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 15,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(18),
                  borderSide: const BorderSide(
                    color: TripwiseColors.outlineVariant,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(18),
                  borderSide: const BorderSide(
                    color: TripwiseColors.primary,
                    width: 1.4,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [TripwiseColors.secondaryContainer, Color(0xFFFF814E)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: TripwiseColors.secondaryContainer.withOpacity(0.28),
                  blurRadius: 18,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: IconButton(
              onPressed: _isSending ? null : _sendMessage,
              icon: _isSending
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.send_rounded, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  const _MessageBubble({required this.message});

  final _PlannerAssistantMessage message;

  @override
  Widget build(BuildContext context) {
    final isUser = message.isUser;

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isUser) ...[
            Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                color: TripwiseColors.primary.withOpacity(0.08),
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: _PlannerAssistantMascot(
                  size: 24,
                  showSparkle: false,
                  shadow: false,
                ),
              ),
            ),
            const SizedBox(width: 8),
          ],
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 280),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                gradient: isUser
                    ? const LinearGradient(
                        colors: [Color(0xFF0B6CAD), TripwiseColors.primary],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      )
                    : null,
                color: isUser ? null : Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(20),
                  topRight: const Radius.circular(20),
                  bottomLeft: Radius.circular(isUser ? 20 : 6),
                  bottomRight: Radius.circular(isUser ? 6 : 20),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 16,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: _FormattedAssistantText(
                text: message.text,
                style: TextStyle(
                  color: isUser ? Colors.white : TripwiseColors.onSurface,
                  fontSize: 14.5,
                  height: 1.45,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FormattedAssistantText extends StatelessWidget {
  const _FormattedAssistantText({
    required this.text,
    required this.style,
  });

  final String text;
  final TextStyle style;

  @override
  Widget build(BuildContext context) {
    final displayText = _cleanDisplayText(text);
    final spans = <TextSpan>[];
    const boldPattern = r'\*\*(.+?)\*\*';
    var cursor = 0;

    for (final match
        in RegExp(boldPattern, dotAll: true).allMatches(displayText)) {
      if (match.start > cursor) {
        spans.add(TextSpan(text: displayText.substring(cursor, match.start)));
      }

      spans.add(
        TextSpan(
          text: match.group(1) ?? '',
          style: style.copyWith(fontWeight: FontWeight.w800),
        ),
      );
      cursor = match.end;
    }

    if (cursor < displayText.length) {
      spans.add(TextSpan(text: displayText.substring(cursor)));
    }

    return RichText(
      text: TextSpan(
        style: style,
        children: spans.isEmpty ? [TextSpan(text: displayText)] : spans,
      ),
    );
  }

  String _cleanDisplayText(String value) {
    return value
        .replaceAll('`', '')
        .replaceAll(
          RegExp(r'\s*\([^)]*\/[A-Za-z0-9_/?=&.-]+[^)]*\)'),
          '',
        )
        .replaceAll(RegExp(r'(^|\s)\/[A-Za-z0-9_/?=&.-]+'), ' ')
        .replaceAll(RegExp(r'^\s*\*\s+', multiLine: true), '- ')
        .replaceAll(RegExp(r'[ \t]+\n'), '\n')
        .replaceAll(RegExp(r'\n{3,}'), '\n\n')
        .trim();
  }
}

class _PlannerAssistantMessage {
  const _PlannerAssistantMessage({required this.text, required this.isUser});

  final String text;
  final bool isUser;
}
