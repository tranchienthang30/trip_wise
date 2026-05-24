import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../constants/colors.dart';
import '../services/auth_session_store.dart';
import '../services/notifications_api.dart';
import '../utils/tripwise_image_provider.dart';
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
                Icons.arrow_back_rounded,
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
      actions: [
        const PlannerAssistantHeaderButton(),
        const NotificationBellButton(),
        const _HeaderAvatarButton(),
      ],
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
                Icons.arrow_back_rounded,
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
      actions: [const NotificationBellButton(), const _HeaderAvatarButton()],
    );
  }
}

class _HeaderAvatarButton extends StatelessWidget {
  const _HeaderAvatarButton();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 20),
      child: GestureDetector(
        onTap: () => context.go('/profile_registration'),
        child: AnimatedBuilder(
          animation: AuthSessionStore.instance,
          builder: (context, _) {
            final avatarProvider = tripwiseImageProvider(
              AuthSessionStore.instance.session?.user.image,
            );
            return Container(
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: TripwiseColors.primaryContainer,
                  width: 2,
                ),
              ),
              child: CircleAvatar(
                radius: 18,
                backgroundColor: TripwiseColors.surfaceContainerLow,
                backgroundImage: avatarProvider,
                child: avatarProvider == null
                    ? const Icon(
                        Icons.person_outline_rounded,
                        size: 18,
                        color: TripwiseColors.onSurfaceVariant,
                      )
                    : null,
              ),
            );
          },
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
