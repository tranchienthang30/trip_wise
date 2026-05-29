import 'dart:async';

import '../models/notification_feed.dart';
import 'notifications_api.dart';
import 'push_messaging_service.dart';

/// Platform-independent source of in-app notification banners.
///
/// The FCM foreground stream ([PushMessagingService.onForegroundPush]) only
/// fires on Android with Firebase delivery. To make the in-app banner work
/// everywhere (iOS, web, Android-without-a-live-push), this service polls the
/// notification feed while the app is foregrounded and emits any row it hasn't
/// seen before. main.dart listens to BOTH this stream and the FCM one,
/// deduping by notification id so a single notification never banners twice.
class NotificationAlertService {
  NotificationAlertService._();

  static const Duration _interval = Duration(seconds: 20);
  static const int _pageSize = 10;

  static final NotificationApi _api = NotificationApi();
  static final StreamController<IncomingPushPayload> _controller =
      StreamController<IncomingPushPayload>.broadcast();

  /// Newly-detected notifications (not present on the baseline poll).
  static Stream<IncomingPushPayload> get onNewNotification =>
      _controller.stream;

  static Timer? _timer;
  static bool _baselineSet = false;
  static bool _polling = false;
  static final Set<String> _seenIds = <String>{};

  /// Begin polling. Call after the user is authenticated. Idempotent. The
  /// first poll only records the existing inbox as a baseline — it does NOT
  /// banner the backlog; only notifications that arrive afterward pop.
  static void start() {
    if (_timer != null) return;
    _baselineSet = false;
    _seenIds.clear();
    unawaited(_poll());
    _timer = Timer.periodic(_interval, (_) => unawaited(_poll()));
  }

  /// Stop polling and reset state. Call on logout.
  static void stop() {
    _timer?.cancel();
    _timer = null;
    _baselineSet = false;
    _seenIds.clear();
  }

  /// Poll immediately (e.g. on app resume) for snappier feedback. No-op if the
  /// poller hasn't been started.
  static void pollNow() {
    if (_timer == null) return;
    unawaited(_poll());
  }

  static Future<void> _poll() async {
    if (_polling) return; // avoid overlapping requests on slow networks
    _polling = true;
    try {
      final page = await _api.fetchFeed(limit: _pageSize);
      final items = page.items;

      if (!_baselineSet) {
        // First successful poll: record the current inbox so we don't banner
        // the backlog the user already had.
        for (final n in items) {
          _seenIds.add(n.id);
        }
        _baselineSet = true;
        return;
      }

      final fresh = items.where((n) => !_seenIds.contains(n.id)).toList();
      for (final n in fresh) {
        _seenIds.add(n.id);
      }

      // Feed is newest-first; emit oldest-first so the most recent banner
      // lands last (and therefore replaces the older one on top).
      for (final n in fresh.reversed) {
        _controller.add(_toPayload(n));
      }
    } catch (_) {
      // Best-effort: a failed poll (offline, 401 mid-logout) just means no
      // banner this tick. Baseline stays as-is.
    } finally {
      _polling = false;
    }
  }

  static IncomingPushPayload _toPayload(AppNotification n) => IncomingPushPayload(
        type: n.type,
        title: n.title,
        body: n.body,
        actionRoute: n.actionRoute,
        notificationId: n.id,
      );
}
