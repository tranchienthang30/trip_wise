import 'dart:async';

import 'package:flutter/material.dart';

import '../constants/colors.dart';
import '../services/push_messaging_service.dart';

/// Top-of-screen banner shown when an FCM push arrives while the app is in
/// the foreground. Replaces the OS-tray notification for that case — see the
/// `onMessage` handler in push_messaging_service.dart.
///
/// Single-banner model: a new push replaces the previous banner so they don't
/// stack. Tapping the banner runs [onTap] (deep-link handler) and dismisses;
/// otherwise it auto-dismisses after 5 seconds.
void showInAppPushBanner({
  required NavigatorState navigator,
  required IncomingPushPayload payload,
  required VoidCallback? onTap,
}) {
  _InAppPushBannerController.instance.show(
    navigator: navigator,
    payload: payload,
    onTap: onTap,
  );
}

class _InAppPushBannerController {
  _InAppPushBannerController._();
  static final _InAppPushBannerController instance =
      _InAppPushBannerController._();

  OverlayEntry? _current;
  Timer? _dismissTimer;

  void show({
    required NavigatorState navigator,
    required IncomingPushPayload payload,
    required VoidCallback? onTap,
  }) {
    _dismiss();

    final overlay = navigator.overlay;
    if (overlay == null) return;

    late final OverlayEntry entry;
    entry = OverlayEntry(
      builder: (context) => _InAppPushBanner(
        payload: payload,
        onTap: () {
          _dismiss();
          onTap?.call();
        },
        onDismiss: _dismiss,
      ),
    );
    _current = entry;
    overlay.insert(entry);

    _dismissTimer = Timer(const Duration(seconds: 5), _dismiss);
  }

  void _dismiss() {
    _dismissTimer?.cancel();
    _dismissTimer = null;
    _current?.remove();
    _current = null;
  }
}

class _InAppPushBanner extends StatefulWidget {
  const _InAppPushBanner({
    required this.payload,
    required this.onTap,
    required this.onDismiss,
  });

  final IncomingPushPayload payload;
  final VoidCallback onTap;
  final VoidCallback onDismiss;

  @override
  State<_InAppPushBanner> createState() => _InAppPushBannerState();
}

class _InAppPushBannerState extends State<_InAppPushBanner>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<Offset> _slide;
  late final Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 280),
    );
    _slide = Tween<Offset>(
      begin: const Offset(0, -1),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );
    _fade = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  ({IconData icon, Color bg, Color fg}) _typeVisual(String type) {
    switch (type) {
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
          icon: Icons.notifications_active_rounded,
          bg: TripwiseColors.surfaceContainerHigh,
          fg: TripwiseColors.primary,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final visual = _typeVisual(widget.payload.type);

    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: FadeTransition(
        opacity: _fade,
        child: SlideTransition(
          position: _slide,
          child: SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: widget.onTap,
                  borderRadius: BorderRadius.circular(18),
                  child: Container(
                    decoration: BoxDecoration(
                      color: TripwiseColors.surfaceContainerLowest,
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.12),
                          blurRadius: 24,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: visual.bg,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(visual.icon, color: visual.fg, size: 20),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.payload.title.isNotEmpty
                                    ? widget.payload.title
                                    : 'Tripwise',
                                style: textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.w800,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              if (widget.payload.body.isNotEmpty) ...[
                                const SizedBox(height: 2),
                                Text(
                                  widget.payload.body,
                                  style: textTheme.bodySmall?.copyWith(
                                    color: TripwiseColors.onSurfaceVariant,
                                    height: 1.3,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          tooltip: 'Dismiss',
                          icon: const Icon(
                            Icons.close_rounded,
                            size: 18,
                            color: TripwiseColors.onSurfaceVariant,
                          ),
                          onPressed: widget.onDismiss,
                          visualDensity: VisualDensity.compact,
                          padding: EdgeInsets.zero,
                          constraints:
                              const BoxConstraints(minWidth: 32, minHeight: 32),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
