import 'package:flutter/material.dart';
import 'dart:ui';

class DirectMessagingScreen extends StatelessWidget {
  const DirectMessagingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        bool isDesktop = constraints.maxWidth > 768;
        return Scaffold(
          backgroundColor: const Color(0xFFF8F9FF),
          appBar: _buildAppBar(),
          body: Row(
            children: [
              if (isDesktop) _buildSideNav(),
              Expanded(
                child: Column(
                  children: [
                    Expanded(
                      child: _buildChatList(),
                    ),
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

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white.withOpacity(0.8),
      elevation: 0,
      scrolledUnderElevation: 0,
      flexibleSpace: ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
          child: Container(color: Colors.transparent),
        ),
      ),
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(
          color: const Color(0xFFEFF6FF).withOpacity(0.1),
          height: 1,
        ),
      ),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Color(0xFF004779)),
        onPressed: () {},
      ),
      titleSpacing: 0,
      title: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundImage: const NetworkImage(
              'https://lh3.googleusercontent.com/aida-public/AB6AXuAwkgKjIfjQRXJZ0Upbvg11Xt6wr7eenGCFU5mpvHG6_qmCR0v2N9E2yHgTxSP1W2OJk1JZxvXesiRwXJ2u1Pek91eYIwmO2vy-_mg6XEbh3AtUNvRq_RPZzaHrP3wUmHVywTauMyQlV6tg-Me_NRKpEWVRuuEprdb7lCvW1g7DmfRJYIsdR_6PN-GCng9QnmMQWIXCaIFeM4C2yB-SMSUs69idNPcPMj2PrhuKiHcyhj7b2OjMKjiBVQFqNcd3vXzPxzQF7hlANwkW',
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text(
                'Elena Rossi',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF004779),
                  letterSpacing: -0.5,
                ),
              ),
              Text(
                'AZURE HORIZON BAY RESORT',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF64748B), // slate-500
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.call, color: Color(0xFF64748B)),
          onPressed: () {},
        ),
        IconButton(
          icon: const Icon(Icons.more_vert, color: Color(0xFF64748B)),
          onPressed: () {},
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildSideNav() {
    return Container(
      width: 80,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          right: BorderSide(
            color: const Color(0xFFEFF6FF).withOpacity(0.1),
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF005F9F).withOpacity(0.02),
            blurRadius: 20,
            offset: const Offset(4, 0),
          )
        ],
      ),
      child: Column(
        children: [
          const SizedBox(height: 32),
          _buildNavItem(Icons.dashboard, 'DASH', false),
          const SizedBox(height: 32),
          _buildNavItem(Icons.calendar_month, 'BOOK', false),
          const SizedBox(height: 32),
          _buildNavItem(Icons.chat, 'CHAT', true),
          const SizedBox(height: 32),
          _buildNavItem(Icons.settings, 'SET', false),
        ],
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, bool isSelected) {
    return Column(
      children: [
        Icon(
          icon,
          color: isSelected ? const Color(0xFFF97316) : const Color(0xFF94A3B8),
          size: 24,
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            color: isSelected ? const Color(0xFFF97316) : const Color(0xFF94A3B8),
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }

  Widget _buildChatList() {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      children: [
        _buildDateHeader('YESTERDAY'),
        const SizedBox(height: 16),
        _buildReceivedMessage(
          "Hello! I'm interested in booking the private sunset boat tour for next Tuesday. Is there still availability for a group of four?",
          "6:45 PM",
        ),
        const SizedBox(height: 24),
        _buildSentMessage(
          "Hi Elena! Yes, we still have two slots open for the Tuesday tour. It would be our pleasure to host your group at Azure Horizon.",
          "7:02 PM",
        ),
        const SizedBox(height: 24),
        _buildDateHeader('TODAY'),
        const SizedBox(height: 16),
        _buildReceivedMessage(
          "That's wonderful! Can you tell me if dinner is included in the package, or should we plan to eat afterwards?",
          "10:15 AM",
        ),
        const SizedBox(height: 24),
        _buildSentMessage(
          "The package includes artisan appetizers and a selection of local wines. For a full dinner, most guests prefer visiting the Pier Restaurant right after we dock at 8:00 PM. I can make a reservation for you!",
          "10:28 AM",
        ),
        const SizedBox(height: 24),
        _buildReceivedMessage(
          "That would be perfect. Please go ahead and reserve a table for four at 8:15 PM. Thank you so much for the help!",
          "11:02 AM",
        ),
        const SizedBox(height: 32), // spacer for bottom nav input
      ],
    );
  }

  Widget _buildDateHeader(String text) {
    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: const Color(0xFFECEEF4), // surface-container
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Color(0xFF414750), // on-surface-variant
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }

  Widget _buildReceivedMessage(String message, String time) {
    return Align(
      alignment: Alignment.centerLeft,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 320), // 85% approx
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
                message,
                style: const TextStyle(
                  fontSize: 16,
                  color: Color(0xFF191C20), // on-surface
                  height: 1.5,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.only(left: 4),
              child: Text(
                time,
                style: const TextStyle(
                  fontSize: 10,
                  color: Color(0xFF94A3B8), // slate-400
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSentMessage(String message, String time) {
    return Align(
      alignment: Alignment.centerRight,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 320), // 85% approx
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF004779), Color(0xFF005F9F)], // primary to primary-container
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
                message,
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.white, // on-primary
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
                    time,
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
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF005F9F).withOpacity(0.04), // shadow-[0px_-10px_40px_rgba(0,95,159,0.04)]
            blurRadius: 40,
            offset: const Offset(0, -10),
          ),
        ],
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 896), // max-w-5xl approx
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: const BoxDecoration(
                  color: Color(0xFFF2F3F9), // surface-container-low
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: const Icon(Icons.add, color: Color(0xFF004779)),
                  onPressed: () {},
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Container(
                  height: 48,
                  decoration: BoxDecoration(
                    color: Colors.white, // surface-container-lowest equivalent bg
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
                  child: const TextField(
                    decoration: InputDecoration(
                      hintText: 'Type your message...',
                      hintStyle: TextStyle(
                        fontSize: 16,
                        color: Color(0xFF94A3B8),
                      ),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Container(
                width: 48,
                height: 48,
                decoration: const BoxDecoration(
                  color: Color(0xFFFF5E1F), // secondary-container
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Color(0x33000000),
                      blurRadius: 15,
                      offset: Offset(0, 4), // shadow-lg approx
                    ),
                  ],
                ),
                child: IconButton(
                  icon: const Icon(Icons.send, color: Colors.white, size: 20),
                  onPressed: () {},
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
