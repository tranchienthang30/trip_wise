import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../constants/colors.dart';
import '../services/notifications_api.dart';
import 'planner_assistant_chat.dart';

const String _sharedAvatarUrl =
    'https://lh3.googleusercontent.com/aida-public/AB6AXuD59O85BxWYvpaeOBLKRHVJDl5xKk_FJK77zGka29CK_oQ1rOkOTPbkLfv5mZ2tk4SD93aU55v_9vSwY-8iZX87mDYD8LvaNn-UdHyoFg4bfL0xqZKHeriqkQd1SUKpeIE6gvVJ4QX_FawbPCT0y5pyTTOE8NETqEKIcfWrol-6cte2O7TlMuVWZmL-XT25F-nqWGLSrW9OOk7KIDBnYBgynVF0OgOioVdYbzo3IRETkhaSqqraHQeFRMQ2iFZihiTYLPIvigq3m8A';

class PlannerAppBar extends StatelessWidget implements PreferredSizeWidget {
  const PlannerAppBar({super.key, this.backRoute});

  final String? backRoute;

  @override
  Size get preferredSize => const Size.fromHeight(68);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      automaticallyImplyLeading: false,
      leading: backRoute == null
          ? null
          : IconButton(
              onPressed: () => context.go(backRoute!),
              tooltip: 'Back',
              icon: const Icon(
                Icons.arrow_back_rounded,
                color: TripwiseColors.primary,
              ),
            ),
      titleSpacing: 20,
      title: Text(
        'TRIP WISE',
        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: TripwiseColors.primary,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.5,
            ),
      ),
      actions: [
        const PlannerAssistantHeaderButton(),
        const NotificationBellButton(),
        Padding(
          padding: const EdgeInsets.only(right: 20),
          child: GestureDetector(
            onTap: () => context.go('/profile_registration'),
            child: Container(
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: TripwiseColors.primaryContainer,
                  width: 2,
                ),
              ),
              child: const CircleAvatar(
                radius: 18,
                backgroundImage: NetworkImage(_sharedAvatarUrl),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class ProviderAppBar extends StatelessWidget implements PreferredSizeWidget {
  const ProviderAppBar({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(68);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      automaticallyImplyLeading: false,
      titleSpacing: 20,
      title: Text(
        'TRIP WISE  BUSINESS',
        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: TripwiseColors.primary,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.5,
              fontSize: 16,
            ),
      ),
      actions: [
        IconButton(
          onPressed: () => context.go('/trip_planner_dashboard'),
          tooltip: 'Switch to Planner',
          icon: const Icon(
            Icons.swap_horiz_rounded,
            color: TripwiseColors.primary,
          ),
        ),
        const NotificationBellButton(),
        Padding(
          padding: const EdgeInsets.only(right: 20),
          child: GestureDetector(
            onTap: () => context.go('/profile_registration'),
            child: Container(
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: TripwiseColors.primaryContainer,
                  width: 2,
                ),
              ),
              child: const CircleAvatar(
                radius: 18,
                backgroundImage: NetworkImage(_sharedAvatarUrl),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Bell icon with an unread-count badge. Self-contained (no app-wide state
/// store, per the project's StatefulWidget+setState convention): it loads
/// the unread summary on mount and again whenever the inbox is popped, so
/// the badge reflects reads made there.
class NotificationBellButton extends StatefulWidget {
  const NotificationBellButton({super.key});

  @override
  State<NotificationBellButton> createState() => _NotificationBellButtonState();
}

class _NotificationBellButtonState extends State<NotificationBellButton> {
  final NotificationApi _api = NotificationApi();
  int _unread = 0;

  @override
  void initState() {
    super.initState();
    _loadUnread();
  }

  Future<void> _loadUnread() async {
    try {
      final summary = await _api.fetchSummary();
      if (!mounted) return;
      setState(() => _unread = summary.unreadCount);
    } catch (_) {
      // Badge just stays hidden if the count can't be fetched.
    }
  }

  Future<void> _openInbox() async {
    await context.push('/notification_inbox');
    await _loadUnread();
  }

  @override
  Widget build(BuildContext context) {
    const icon = Icon(
      Icons.notifications_none_rounded,
      color: TripwiseColors.primary,
    );
    return IconButton(
      onPressed: _openInbox,
      tooltip: 'Notifications',
      icon: _unread > 0
          ? Badge(
              label: Text(_unread > 99 ? '99+' : '$_unread'),
              backgroundColor: TripwiseColors.secondaryContainer,
              child: icon,
            )
          : icon,
    );
  }
}
