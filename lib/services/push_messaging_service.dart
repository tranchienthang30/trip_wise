import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

/// FCM push, Android-first. The backend sends a DATA-ONLY message (keys:
/// type/title/body/action_route/notification_id) so we render it ourselves
/// in every app state with [flutter_local_notifications] and always have the
/// deep-link route. iOS/web are intentionally out of scope.

const AndroidNotificationChannel _channel = AndroidNotificationChannel(
  'tripwise_default',
  'Tripwise notifications',
  description: 'Bookings, trips and account alerts',
  importance: Importance.high,
);

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
  await plugin.show(
    _idFor(m),
    title,
    body,
    NotificationDetails(
      android: AndroidNotificationDetails(
        _channel.id,
        _channel.name,
        channelDescription: _channel.description,
        importance: Importance.high,
        priority: Priority.high,
        icon: '@mipmap/ic_launcher',
      ),
    ),
    payload: (data['action_route'] as String?) ?? '',
  );
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
  await plugin
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(_channel);
  await _showLocal(plugin, message);
}

class PushMessagingService {
  static final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();
  static bool _ready = false;

  static bool get _supported =>
      !kIsWeb && defaultTargetPlatform == TargetPlatform.android;

  /// One-time setup. [onDeepLink] receives the tapped notification's
  /// `action_route` (a GoRouter path) and is responsible for navigating.
  static Future<void> initialize({
    required void Function(String? route) onDeepLink,
  }) async {
    if (!_supported || _ready) return;
    _ready = true;

    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp();
    }

    await _plugin.initialize(
      const InitializationSettings(android: _androidInit),
      onDidReceiveNotificationResponse: (resp) => onDeepLink(resp.payload),
    );
    await _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(_channel);

    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

    // Android 13+: shows the POST_NOTIFICATIONS runtime dialog. Denial is
    // fine — the app keeps working, banners just won't appear.
    await FirebaseMessaging.instance.requestPermission();

    // Foreground: the OS does NOT auto-display data messages — render one.
    FirebaseMessaging.onMessage.listen((m) => _showLocal(_plugin, m));

    // Tapped a tray notification while the app was alive (backgrounded).
    FirebaseMessaging.onMessageOpenedApp.listen(
      (m) => onDeepLink(m.data['action_route'] as String?),
    );

    // Tapped a tray notification that cold-started the app.
    final initial = await FirebaseMessaging.instance.getInitialMessage();
    if (initial != null) {
      onDeepLink(initial.data['action_route'] as String?);
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

  static Stream<String> get onTokenRefresh =>
      FirebaseMessaging.instance.onTokenRefresh;
}
