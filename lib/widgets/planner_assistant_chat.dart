import 'package:flutter/material.dart';

import '../constants/colors.dart';

void showPlannerAssistantSheet(BuildContext context) {
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (sheetContext) {
      return const _PlannerAssistantSheet();
    },
  );
}

class PlannerAssistantHeaderButton extends StatelessWidget {
  const PlannerAssistantHeaderButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, right: 2),
      child: Tooltip(
        message: 'Open planner assistant',
        child: InkWell(
          onTap: () => showPlannerAssistantSheet(context),
          borderRadius: BorderRadius.circular(999),
          child: Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                colors: [
                  Color(0xFFBEE1FF),
                  TripwiseColors.primary,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: TripwiseColors.primary.withOpacity(0.18),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: 21,
                  height: 21,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.96),
                    shape: BoxShape.circle,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          _MascotEye(width: 3, height: 4.2),
                          SizedBox(width: 3),
                          _MascotEye(width: 3, height: 4.2),
                        ],
                      ),
                      const SizedBox(height: 2.4),
                      Container(
                        width: 8,
                        height: 3,
                        decoration: const BoxDecoration(
                          color: TripwiseColors.primary,
                          borderRadius: BorderRadius.vertical(
                            bottom: Radius.circular(6),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Positioned(
                  top: 2,
                  right: 2,
                  child: Container(
                    width: 10,
                    height: 10,
                    decoration: const BoxDecoration(
                      color: TripwiseColors.secondaryContainer,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.auto_awesome,
                      size: 6,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _MascotEye extends StatelessWidget {
  const _MascotEye({
    this.width = 6,
    this.height = 8,
  });

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
  const _PlannerAssistantSheet();

  @override
  State<_PlannerAssistantSheet> createState() => _PlannerAssistantSheetState();
}

class _PlannerAssistantSheetState extends State<_PlannerAssistantSheet> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  late final List<_PlannerAssistantMessage> _messages = [
    const _PlannerAssistantMessage(
      text:
          'Hi, I am Lumi. I can help sketch itineraries, suggest stays, and turn ideas into a day-by-day plan.',
      isUser: false,
    ),
    const _PlannerAssistantMessage(
      text: 'I want a 4-day Bali plan with beach clubs and one quiet day.',
      isUser: true,
    ),
    const _PlannerAssistantMessage(
      text:
          'Lovely choice. I would balance Seminyak, Uluwatu, and one slower Ubud day. Want me to break it into morning, afternoon, and evening?',
      isUser: false,
    ),
  ];

  int _replyIndex = 0;

  static const List<String> _quickPrompts = [
    'Create a 3-day itinerary',
    'Suggest hotels near the beach',
    'Estimate my travel budget',
    'Find family-friendly activities',
  ];

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

  void _sendMessage([String? presetText]) {
    final text = (presetText ?? _controller.text).trim();
    if (text.isEmpty) {
      return;
    }

    setState(() {
      _messages.add(_PlannerAssistantMessage(text: text, isUser: true));
      _messages.add(
        _PlannerAssistantMessage(
          text: _buildAssistantReply(text),
          isUser: false,
        ),
      );
    });
    _controller.clear();
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
  }

  String _buildAssistantReply(String text) {
    final normalized = text.toLowerCase();
    if (normalized.contains('budget')) {
      return 'I can split the budget into hotel, transport, food, and activities so your trip stays easier to control.';
    }
    if (normalized.contains('hotel')) {
      return 'I can shortlist stays by vibe, area, and nightly budget, then slot the best options directly into your plan.';
    }
    if (normalized.contains('family')) {
      return 'I will keep the pacing light, add kid-friendly stops, and avoid long transfer blocks where possible.';
    }
    if (normalized.contains('itinerary') || normalized.contains('day')) {
      return 'I can turn that into a clear day-by-day schedule with travel time, meal ideas, and backup options.';
    }

    const replies = [
      'I can organize that into a cleaner planner flow with destinations, timing, and booking ideas.',
      'That works. I would next group the trip by area so each day feels smoother and less rushed.',
      'I can help shape that into a realistic route with stays, activities, and spacing between each stop.',
    ];
    final reply = replies[_replyIndex % replies.length];
    _replyIndex++;
    return reply;
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
          colors: [
            Color(0xFF0E6AAC),
            TripwiseColors.primary,
          ],
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
            child: const Icon(
              Icons.smart_toy_rounded,
              color: Colors.white,
              size: 28,
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
                  'Travel ideas, schedules, and trip planning support',
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
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
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
                'Try a prompt',
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
            'Tap a suggestion below to preview how the planner assistant can start a conversation.',
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
                    onPressed: () => _sendMessage(prompt),
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
      padding: const EdgeInsets.fromLTRB(18, 14, 18, 18),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.98),
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
            child: Container(
              decoration: BoxDecoration(
                color: TripwiseColors.surfaceContainerLow,
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: TripwiseColors.outlineVariant),
              ),
              child: TextField(
                controller: _controller,
                minLines: 1,
                maxLines: 4,
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => _sendMessage(),
                decoration: const InputDecoration(
                  hintText: 'Ask Lumi to plan your next step...',
                  hintStyle: TextStyle(color: Color(0xFF94A3B8)),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 14,
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
                colors: [
                  TripwiseColors.secondaryContainer,
                  Color(0xFFFF814E),
                ],
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
              onPressed: _sendMessage,
              icon: const Icon(Icons.send_rounded, color: Colors.white),
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
              decoration: const BoxDecoration(
                color: TripwiseColors.primaryFixed,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.smart_toy_rounded,
                size: 16,
                color: TripwiseColors.primary,
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
                        colors: [
                          Color(0xFF0B6CAD),
                          TripwiseColors.primary,
                        ],
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
              child: Text(
                message.text,
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

class _PlannerAssistantMessage {
  const _PlannerAssistantMessage({
    required this.text,
    required this.isUser,
  });

  final String text;
  final bool isUser;
}
