import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../constants/colors.dart';
import 'planner_assistant_chat.dart';

const String _sharedAvatarUrl =
    'https://lh3.googleusercontent.com/aida-public/AB6AXuD59O85BxWYvpaeOBLKRHVJDl5xKk_FJK77zGka29CK_oQ1rOkOTPbkLfv5mZ2tk4SD93aU55v_9vSwY-8iZX87mDYD8LvaNn-UdHyoFg4bfL0xqZKHeriqkQd1SUKpeIE6gvVJ4QX_FawbPCT0y5pyTTOE8NETqEKIcfWrol-6cte2O7TlMuVWZmL-XT25F-nqWGLSrW9OOk7KIDBnYBgynVF0OgOioVdYbzo3IRETkhaSqqraHQeFRMQ2iFZihiTYLPIvigq3m8A';

class PlannerAppBar extends StatelessWidget implements PreferredSizeWidget {
  const PlannerAppBar({super.key});

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
        'TRIP WISE',
        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: TripwiseColors.primary,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.5,
            ),
      ),
      actions: [
        const PlannerAssistantHeaderButton(),
        IconButton(
          onPressed: () => context.push('/notifications'),
          icon: const Icon(
            Icons.notifications_none_rounded,
            color: TripwiseColors.primary,
          ),
        ),
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
              fontSize: 24,
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
        IconButton(
          onPressed: () => context.push('/notifications'),
          icon: const Icon(
            Icons.notifications_none_rounded,
            color: TripwiseColors.primary,
          ),
        ),
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
