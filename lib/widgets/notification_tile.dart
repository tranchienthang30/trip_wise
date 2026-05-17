import 'package:flutter/material.dart';

import '../constants/colors.dart';
import '../models/notification_feed.dart';

class NotificationTile extends StatelessWidget {
  const NotificationTile({
    super.key,
    required this.notification,
    this.onTap,
  });

  final AppNotification notification;
  final VoidCallback? onTap;

  ({IconData icon, Color bg, Color fg}) _typeVisual() {
    switch (notification.type) {
      case 'BOOKING':
        return (
          icon: Icons.confirmation_number_rounded,
          bg: TripwiseColors.primaryFixed,
          fg: TripwiseColors.primary,
        );
      case 'TRIP':
        return (
          icon: Icons.luggage_rounded,
          bg: TripwiseColors.tertiaryFixed,
          fg: TripwiseColors.tertiary,
        );
      case 'MESSAGE':
        return (
          icon: Icons.chat_bubble_rounded,
          bg: TripwiseColors.secondaryFixed,
          fg: TripwiseColors.secondary,
        );
      case 'PROMO':
        return (
          icon: Icons.local_offer_rounded,
          bg: TripwiseColors.secondaryFixed,
          fg: TripwiseColors.secondary,
        );
      default: // SYSTEM
        return (
          icon: Icons.info_rounded,
          bg: TripwiseColors.surfaceContainerHigh,
          fg: TripwiseColors.onSurfaceVariant,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final visual = _typeVisual();
    final unread = !notification.read;
    return Material(
      color: unread
          ? TripwiseColors.primaryFixed.withOpacity(0.35)
          : TripwiseColors.surfaceContainerLowest,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: visual.bg,
                  shape: BoxShape.circle,
                ),
                child: Icon(visual.icon, color: visual.fg, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      notification.title,
                      style: textTheme.titleSmall?.copyWith(
                        fontWeight:
                            unread ? FontWeight.w900 : FontWeight.w700,
                      ),
                    ),
                    if (notification.body.isNotEmpty) ...[
                      const SizedBox(height: 3),
                      Text(
                        notification.body,
                        style: textTheme.bodySmall?.copyWith(
                          color: TripwiseColors.onSurfaceVariant,
                          height: 1.35,
                        ),
                      ),
                    ],
                    const SizedBox(height: 6),
                    Text(
                      notification.timeLabel,
                      style: textTheme.labelSmall?.copyWith(
                        color: TripwiseColors.onSurfaceVariant,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              // Unread dot.
              SizedBox(
                width: 10,
                child: unread
                    ? Container(
                        width: 10,
                        height: 10,
                        margin: const EdgeInsets.only(top: 4),
                        decoration: const BoxDecoration(
                          color: TripwiseColors.secondaryContainer,
                          shape: BoxShape.circle,
                        ),
                      )
                    : null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
