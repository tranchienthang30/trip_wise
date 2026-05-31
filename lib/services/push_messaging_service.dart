import 'dart:async';
import 'dart:convert';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

/// FCM push, Android-first. The backend sends a DATA-ONLY message (keys:
/// type/title/body/action_route/notification_id) so we render it ourselves
/// in every app state with [flutter_local_notifications] and always have the
/// deep-link route. iOS/web are intentionally out of scope.

/// Domain-friendly view of an incoming foreground push. Mirrors the server's
/// data-message payload keys (`push.service.ts` → `sendPushToUser`).
class IncomingPushPayload {
  IncomingPushPayload({
    required this.type,
    required this.title,
    required this.body,
    required this.actionRoute,
    required this.notificationId,
  });

  final String type;
  final String title;
  final String body;
  final String? actionRoute;
  final String? notificationId;

  factory IncomingPushPayload.fromRemoteMessage(RemoteMessage m) {
    final d = m.data;
    String? str(Object? v) {
      if (v is String && v.trim().isNotEmpty) return v;
      return null;
    }

    return IncomingPushPayload(
      type: str(d['type']) ?? 'SYSTEM',
      title: str(d['title']) ?? (m.notification?.title ?? ''),
      body: str(d['body']) ?? (m.notification?.body ?? ''),
      actionRoute: str(d['action_route']),
      notificationId: str(d['notification_id']),
    );
  }
}

/// Per-category channels so a user can mute e.g. promos or chats without
/// losing booking/payment alerts at the OS level — the OS toggles mirror the
/// in-app NotificationPreference categories. Channel ids are PERMANENT
/// on-device: renaming one orphans the user's settings, so migrate, never
/// rename.
const AndroidNotificationChannel _txChannel = AndroidNotificationChannel(
  'tripwise_transactions',
  'Bookings & payments',
  description: 'Booking updates, wallet and account alerts',
  importance: Importance.high,
);
const AndroidNotificationChannel _chatChannel = AndroidNotificationChannel(
  'tripwise_chats',
  'Messages',
  description: 'Direct messages from hosts and travellers',
  importance: Importance.high,
);
const AndroidNotificationChannel _tripChannel = AndroidNotificationChannel(
  'tripwise_trips',
  'Trip reminders',
  description: 'Upcoming trips and itinerary reminders',
  importance: Importance.high,
);
const AndroidNotificationChannel _promoChannel = AndroidNotificationChannel(
  'tripwise_promos',
  'Promotions',
  description: 'Deals, offers and product news',
  importance: Importance.defaultImportance,
);

const List<AndroidNotificationChannel> _channels = <AndroidNotificationChannel>[
  _txChannel,
  _chatChannel,
  _tripChannel,
  _promoChannel,
];

/// Maps a server notification `type` to its channel. Mirrors
/// notifications.service.ts TYPE_TO_PREF; SYSTEM/unknown fall back to the
/// transactions channel (account + wallet alerts).
AndroidNotificationChannel _channelForType(String? type) {
  switch (type) {
    case 'MESSAGE':
      return _chatChannel;
    case 'TRIP':
      return _tripChannel;
    case 'PROMO':
      return _promoChannel;
    case 'BOOKING':
    case 'SYSTEM':
    default:
      return _txChannel;
  }
}

/// (Re)create every channel and drop the legacy single channel so it no longer
/// lingers in the user's notification settings. Idempotent.
Future<void> _registerChannels(FlutterLocalNotificationsPlugin plugin) async {
  final android = plugin.resolvePlatformSpecificImplementation<
      AndroidFlutterLocalNotificationsPlugin>();
  if (android == null) return;
  await android.deleteNotificationChannel('tripwise_default');
  for (final channel in _channels) {
    await android.createNotificationChannel(channel);
  }
}

const AndroidInitializationSettings _androidInit =
    AndroidInitializationSettings('@mipmap/ic_launcher');

int _idFor(RemoteMessage m) =>
    (m.data['notification_id'] ?? m.messageId ?? m.hashCode.toString())
        .hashCode;

Future<void> _showLocal(
  FlutterLocalNotificationsPlugin plugin,
  RemoteMessage m,
) async {
  final data = m.data;
  final title = (data['title'] as String?)?.trim().isNotEmpty == true
      ? data['title'] as String
      : (m.notification?.title ?? 'Tripwise');
  final body = (data['body'] as String?) ?? m.notification?.body ?? '';
  final channel = _channelForType(data['type'] as String?);

  // collapse_key (set by the server, e.g. one per chat conversation) gives a
  // stable tray id + tag so a newer message REPLACES the previous one for that
  // conversation instead of stacking another row. Without it each notification
  // gets a unique id (the original behaviour). groupKey stacks same-channel
  // rows under one summary.
  final collapseKey = (data['collapse_key'] as String?)?.trim();
  final hasCollapseKey = collapseKey != null && collapseKey.isNotEmpty;
  final notificationId = hasCollapseKey ? collapseKey.hashCode : _idFor(m);

  await plugin.show(
    notificationId,
    title,
    body,
    NotificationDetails(
      android: AndroidNotificationDetails(
        channel.id,
        channel.name,
        channelDescription: channel.description,
        importance: channel.importance,
        priority: Priority.high,
        icon: '@mipmap/ic_launcher',
        groupKey: channel.id,
        tag: hasCollapseKey ? collapseKey : null,
      ),
    ),
    // Carry BOTH the route and the notification id so a tray tap can mark the
    // notification read (not just navigate). Encoded as JSON; _decodeTapPayload
    // also accepts a bare route string for back-compat with older payloads.
    payload: jsonEncode({
      'route': (data['action_route'] as String?) ?? '',
      'id': (data['notification_id'] as String?) ?? '',
    }),
  );
}

/// Parse the local-notification payload written by [_showLocal]. Falls back to
/// treating the whole string as a route (older payloads were a bare route).
({String? route, String? id}) _decodeTapPayload(String? raw) {
  if (raw == null || raw.isEmpty) return (route: null, id: null);
  try {
    final decoded = jsonDecode(raw);
    if (decoded is Map) {
      final r = decoded['route'];
      final i = decoded['id'];
      return (
        route: r is String && r.isNotEmpty ? r : null,
        id: i is String && i.isNotEmpty ? i : null,
      );
    }
  } catch (_) {
    // Not JSON — treat as a bare route (back-compat).
  }
  return (route: raw, id: null);
}

/// Runs in a separate isolate when a message arrives while the app is
/// backgrounded or killed — must do its own Firebase + plugin setup.
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  final plugin = FlutterLocalNotificationsPlugin();
  await plugin.initialize(
    const InitializationSettings(android: _androidInit),
  );
  await _registerChannels(plugin);
  await _showLocal(plugin, message);
}

class PushMessagingService {
  static final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();
  static bool _ready = false;

  /// Fires whenever a foreground push is received. Consumers (e.g. the bell
  /// badge, an open chat screen) subscribe to react without re-fetching the
  /// inbox. Broadcast so multiple listeners can coexist. Empty on platforms
  /// where push is unsupported.
  static final StreamController<IncomingPushPayload> _onForegroundPush =
      StreamController<IncomingPushPayload>.broadcast();
  static Stream<IncomingPushPayload> get onForegroundPush =>
      _onForegroundPush.stream;

  static bool get _supported =>
      !kIsWeb && defaultTargetPlatform == TargetPlatform.android;
  static bool get isSupported => _supported;

  /// True when the OS-level permission for notifications is denied (Android
  /// 13+ POST_NOTIFICATIONS). Returns false on unsupported platforms — there
  /// is no banner UX to block in those cases. Used by the Preferences screen
  /// to surface a "blocked at the system level" banner.
  static Future<bool> isPushBlocked() async {
    if (!_supported) return false;
    try {
      final settings = await FirebaseMessaging.instance.getNotificationSettings();
      return settings.authorizationStatus == AuthorizationStatus.denied;
    } catch (_) {
      return false;
    }
  }

  /// One-time setup. [onNotificationTap] fires when the user taps a tray
  /// notification (foreground-rendered, backgrounded, or cold-start). It
  /// receives the `action_route` to navigate to AND the `notification_id` so
  /// the caller can mark it read — tapping a notification is engagement, so it
  /// should clear the unread state just like tapping the in-app banner or an
  /// inbox row.
  static Future<void> initialize({
    required void Function({String? route, String? notificationId})
        onNotificationTap,
  }) async {
    if (!_supported || _ready) return;
    _ready = true;

    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp();
    }

    await _plugin.initialize(
      const InitializationSettings(android: _androidInit),
      onDidReceiveNotificationResponse: (resp) {
        final p = _decodeTapPayload(resp.payload);
        onNotificationTap(route: p.route, notificationId: p.id);
      },
    );
    await _registerChannels(_plugin);

    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

    // Android 13+: shows the POST_NOTIFICATIONS runtime dialog. Denial is
    // fine — the app keeps working, banners just won't appear.
    await FirebaseMessaging.instance.requestPermission();

    // Foreground: skip the OS tray notification entirely — the in-app banner
    // (see InAppPushBanner / main.dart) renders the alert inside the app so
    // the user isn't distracted by a system heads-up while they're actively
    // using Tripwise. Background / killed-state still fire the OS tray via
    // firebaseMessagingBackgroundHandler above.
    FirebaseMessaging.onMessage.listen((m) {
      _onForegroundPush.add(IncomingPushPayload.fromRemoteMessage(m));
    });

    // Tapped a tray notification while the app was alive (backgrounded).
    FirebaseMessaging.onMessageOpenedApp.listen(
      (m) => onNotificationTap(
        route: m.data['action_route'] as String?,
        notificationId: m.data['notification_id'] as String?,
      ),
    );

    // Tapped a tray notification that cold-started the app.
    final initial = await FirebaseMessaging.instance.getInitialMessage();
    if (initial != null) {
      onNotificationTap(
        route: initial.data['action_route'] as String?,
        notificationId: initial.data['notification_id'] as String?,
      );
    }
  }

  static Future<String?> getToken() async {
    if (!_supported) return null;
    try {
      return await FirebaseMessaging.instance.getToken();
    } catch (e) {
      if (kDebugMode) debugPrint('[push] getToken failed: $e');
      return null;
    }
  }

  static Stream<String> get onTokenRefresh {
    if (!_supported) return const Stream<String>.empty();
    return FirebaseMessaging.instance.onTokenRefresh;
  }
}
