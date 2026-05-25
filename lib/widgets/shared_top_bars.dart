import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../constants/colors.dart';
import '../constants/icons.dart';
import '../services/notifications_api.dart';
import 'planner_assistant_chat.dart';

class PlannerAppBar extends StatelessWidget implements PreferredSizeWidget {
  const PlannerAppBar({super.key, this.backRoute, this.titleText, this.onBack});

  final String? backRoute;
  final String? titleText;
  final VoidCallback? onBack;

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
              onPressed: onBack ?? () => context.go(backRoute!),
              tooltip: 'Back',
              icon: const Icon(
                TripwiseIcons.back,
                color: TripwiseColors.primary,
              ),
            ),
      titleSpacing: 20,
      title: Text(
        titleText ?? 'TRIP WISE',
        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
          color: TripwiseColors.primary,
          fontWeight: FontWeight.w900,
          letterSpacing: -0.5,
        ),
      ),
      actions: const [_PlannerHeaderActions()],
    );
  }
}

class ProviderAppBar extends StatelessWidget implements PreferredSizeWidget {
  const ProviderAppBar({
    super.key,
    this.backRoute,
    this.titleText,
    this.onBack,
  });

  final String? backRoute;
  final String? titleText;
  final VoidCallback? onBack;

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
              onPressed: onBack ?? () => context.go(backRoute!),
              tooltip: 'Back',
              icon: const Icon(
                TripwiseIcons.back,
                color: TripwiseColors.primary,
              ),
            ),
      titleSpacing: 20,
      title: Text(
        titleText ?? 'TRIP WISE  BUSINESS',
        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
          color: TripwiseColors.primary,
          fontWeight: FontWeight.w900,
          letterSpacing: -0.5,
          fontSize: 16,
        ),
      ),
      actions: const [_ProviderHeaderActions()],
    );
  }
}

class _PlannerHeaderActions extends StatelessWidget {
  const _PlannerHeaderActions();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.only(right: 16),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          PlannerAssistantHeaderButton(),
          SizedBox(width: 8),
          NotificationBellButton(),
        ],
      ),
    );
  }
}

class _ProviderHeaderActions extends StatelessWidget {
  const _ProviderHeaderActions();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.only(right: 16),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          NotificationBellButton(),
          SizedBox(width: 8),
          _ProviderProfileButton(),
        ],
      ),
    );
  }
}

class _ProviderProfileButton extends StatelessWidget {
  const _ProviderProfileButton();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 40,
      height: 40,
      child: IconButton(
        onPressed: () => context.go('/profile_registration'),
        tooltip: 'Profile',
        visualDensity: VisualDensity.compact,
        padding: EdgeInsets.zero,
        style: IconButton.styleFrom(
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          minimumSize: const Size(40, 40),
          shape: const CircleBorder(),
        ),
        icon: const Icon(
          TripwiseIcons.profile,
          color: TripwiseColors.primary,
          size: 28,
        ),
      ),
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
      TripwiseIcons.notifications,
      color: TripwiseColors.primary,
      size: 28,
    );
    return SizedBox(
      width: 40,
      height: 40,
      child: IconButton(
        onPressed: _openInbox,
        tooltip: 'Notifications',
        visualDensity: VisualDensity.compact,
        padding: EdgeInsets.zero,
        style: IconButton.styleFrom(
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          minimumSize: const Size(40, 40),
          shape: const CircleBorder(),
        ),
        icon: _unread > 0
            ? Badge(
                smallSize: 8,
                largeSize: 16,
                padding: const EdgeInsets.symmetric(horizontal: 4),
                label: Text(
                  _unread > 99 ? '99+' : '$_unread',
                  style: const TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w800,
                    height: 1,
                  ),
                ),
                backgroundColor: TripwiseColors.secondaryContainer,
                alignment: Alignment.topRight,
                offset: const Offset(2, -3),
                child: icon,
              )
            : icon,
      ),
    );
  }
}
