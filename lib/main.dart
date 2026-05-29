import 'dart:async';

import 'package:app_links/app_links.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'constants/theme.dart';
import 'services/auth_session_store.dart';
import 'services/notification_alert_service.dart';
import 'services/notifications_api.dart';
import 'services/push_messaging_service.dart';
import 'services/devices_api.dart';
import 'widgets/in_app_push_banner.dart';
import 'screens/admin_provider_approvals_screen.dart';
import 'screens/admin_listing_approvals_screen.dart';
import 'screens/admin_provider_payouts_screen.dart';
import 'screens/admin_refunds_screen.dart';
import 'screens/home_screen.dart';
import 'screens/add_activity_screen.dart';
import 'screens/add_location_search_screen.dart';
import 'screens/add_new_listing_form_screen.dart';
import 'screens/add_payment_screen.dart';
import 'screens/hotel_search_filter_screen.dart';
import 'screens/initial_registration_screen.dart';
import 'screens/my_trip_booking_detail_screen.dart';
import 'screens/my_trips_screen.dart';
import 'screens/booking_checkout_screen.dart';
import 'screens/direct_messaging_screen.dart';
import 'screens/elite_upgrade_confirmation_screen.dart';
import 'screens/order_manager_screen.dart';
import 'screens/plan_new_trip_form_screen.dart';
import 'screens/provider_dashboard_screen.dart';
import 'screens/provider_finance_payout_screen.dart';
import 'screens/profile_registration_screen.dart';
import 'screens/profile_verification_screen.dart';
import 'screens/provider_listing_management_screen.dart';
import 'screens/security_privacy_screen.dart';
import 'screens/notifications_screen.dart';
import 'screens/notification_inbox_screen.dart';
import 'screens/help_center_screen.dart';
import 'screens/provider_listing_edit_screen.dart';
import 'screens/provider_listing_add_screen.dart';
import 'screens/provider_analytics_screen.dart';
import 'screens/payment_success_screen.dart';
import 'screens/inventory_pricing_screen.dart';
import 'screens/service_details_screen.dart';
import 'screens/reviews_screen.dart';
import 'screens/trip_planner_dashboard_screen.dart';
import 'screens/trip_planner_timeline_screen.dart';
import 'screens/vip_services_screen.dart';
import 'screens/wallet_loyalty_screen.dart';
import 'screens/wallet_transactions_screen.dart';
import 'screens/provider_registration_form_screen.dart';

/// Root navigator key so push-notification taps can deep-link without a
/// BuildContext (FCM handlers run outside the widget tree).
final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>();
final AuthSessionStore _authSessionStore = AuthSessionStore.instance;

const Set<String> _providerOnlyRoutes = {
  '/provider_dashboard',
  '/provider_finance',
  '/provider_listings',
  '/provider_listing_edit',
  '/provider_listing_add',
  '/provider_analytics',
  '/add_new_listing_form',
  '/order_manager',
  '/vip_services',
  '/elite_upgrade_confirmation',
  '/inventory_pricing',
};

const Set<String> _plannerOnlyRoutes = {
  '/home',
  '/search_filter',
  '/add_location_search',
  '/trip_planner_dashboard',
  '/trip_planner_timeline',
  '/plan_new_trip_form',
  '/my_trip_booking_detail',
  '/my_trips',
  '/booking_checkout',
  '/payment_success',
  '/wallet_loyalty',
  '/wallet_transactions',
  '/service_details',
  '/reviews',
};

// A deep link that arrived before the router was mounted (cold start from a
// killed-state notification tap). Flushed on the first frame.
String? _pendingDeepLink;

String? _logicalBackRouteFor(String path) {
  if (path == '/trip_planner_timeline') return '/trip_planner_dashboard';
  if (path.startsWith('/my_trip_booking_detail/')) return '/my_trips';
  if (path == '/profile_verification') return '/profile_registration';
  if (path == '/provider_registration_form') return '/profile_registration';
  if (path == '/elite_upgrade_confirmation') return '/vip_services';
  return null;
}

String? _systemBackTargetFor(String path) {
  if (path == '/register') return null;

  final logicalBackRoute = _logicalBackRouteFor(path);
  if (logicalBackRoute != null) return logicalBackRoute;

  final landingRoute = _authSessionStore.landingRoute;
  if (path == landingRoute) return null;
  return landingRoute;
}

Widget _withSystemBack(GoRouterState state, Widget child) {
  return _SystemBackRouteScope(path: state.uri.path, child: child);
}

class _SystemBackRouteScope extends StatelessWidget {
  const _SystemBackRouteScope({required this.path, required this.child});

  final String path;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final targetRoute = _systemBackTargetFor(path);

    return PopScope(
      canPop: targetRoute == null,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;

        final currentPath =
            _router.routerDelegate.currentConfiguration.uri.path;
        final target = _systemBackTargetFor(currentPath);
        if (target == null) {
          SystemNavigator.pop();
          return;
        }
        _router.go(target);
      },
      child: child,
    );
  }
}

/// Navigates to a notification's `action_route`. Rejects anything that is not
/// an in-app absolute path (action_route safety).
///
/// Cold start (router not mounted yet): defer; the post-frame flush in
/// `MyApp.build` uses `go` so the destination lands as the root entry.
/// Warm tap (router mounted): `push` so the user's existing nav stack is
/// preserved and the destination screen's back button returns them to where
/// they were. Using `go` here destroys the stack and causes "nothing to pop"
/// crashes in deep-link target screens.
void handleDeepLink(String? route) {
  if (route == null || route.isEmpty) return;

  String normalizedRoute = route;
  bool shouldReplaceStack = false;
  if (normalizedRoute == '/') {
    normalizedRoute = '/home';
    shouldReplaceStack = true;
  }
  if (!route.startsWith('/')) {
    shouldReplaceStack = true;
    final uri = Uri.tryParse(route);
    if (uri == null) return;
    if (uri.scheme == 'tripwise' && uri.host == 'payos') {
      final status = (uri.queryParameters['status'] ?? '').toUpperCase();
      final code = (uri.queryParameters['code'] ?? '').trim();
      final bookingId = uri.queryParameters['bookingId'] ?? '';
      if (uri.path == '/return' && (status == 'PAID' || code == '00')) {
        normalizedRoute = '/my_trips?status=upcoming'
            '${bookingId.isEmpty ? '' : '&bookingId=${Uri.encodeQueryComponent(bookingId)}'}';
      } else {
        normalizedRoute = '/home';
      }
    } else if (uri.scheme == 'tripwise' && uri.host == 'app') {
      // Shareable in-app links: tripwise://app/<route>. The path (and any
      // query) IS the GoRouter destination, so any screen can be shared —
      // e.g. tripwise://app/service_details/38 → /service_details/38.
      final path = uri.path.isEmpty ? '/home' : uri.path;
      normalizedRoute = uri.hasQuery ? '$path?${uri.query}' : path;
    } else {
      return;
    }
  }

  if (!normalizedRoute.startsWith('/')) return;
  if (rootNavigatorKey.currentContext == null) {
    _pendingDeepLink = normalizedRoute; // router not ready yet — defer
    return;
  }
  if (shouldReplaceStack) {
    _router.go(normalizedRoute);
    return;
  }
  _router.push(normalizedRoute);
}

final NotificationApi _pushNotificationApi = NotificationApi();

/// Handles a tap on a system-tray notification (backgrounded, cold-start, or
/// foreground-rendered). Tapping is engagement, so mark the notification read
/// — otherwise the inbox stays unread and the bell keeps its +1 even though
/// the user clearly saw and acted on it. Then deep-link as usual.
void handleNotificationTap({String? route, String? notificationId}) {
  if (notificationId != null && notificationId.isNotEmpty) {
    unawaited(_markTrayNotificationRead(notificationId));
  }
  handleDeepLink(route);
}

Future<void> _markTrayNotificationRead(String id) async {
  try {
    await _pushNotificationApi.markRead(id);
    // Tell any mounted bell to refetch so the badge clears deterministically
    // instead of racing the app-resume refresh.
    NotificationAlertService.notifyChanged();
  } catch (_) {
    // Best-effort: the inbox reconciles on its next fetch.
  }
}

class _RouteRecoveryScreen extends StatefulWidget {
  const _RouteRecoveryScreen({required this.rawLocation});

  final String rawLocation;

  @override
  State<_RouteRecoveryScreen> createState() => _RouteRecoveryScreenState();
}

class _RouteRecoveryScreenState extends State<_RouteRecoveryScreen> {
  bool _redirected = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_redirected) return;
    _redirected = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (rootNavigatorKey.currentContext == null) return;
      if (widget.rawLocation.startsWith('tripwise://')) {
        handleDeepLink(widget.rawLocation);
        return;
      }
      // Unknown/invalid route fallback.
      _router.go('/home');
    });
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}

final GoRouter _router = GoRouter(
  initialLocation: '/home',
  overridePlatformDefaultLocation: true,
  navigatorKey: rootNavigatorKey,
  refreshListenable: _authSessionStore,
  errorBuilder: (context, state) =>
      _RouteRecoveryScreen(rawLocation: state.uri.toString()),
  redirect: (context, state) {
    final isLoggedIn = _authSessionStore.isAuthenticated;
    final onAuthScreen = state.matchedLocation == '/register';
    final isAdminRoute = state.matchedLocation.startsWith('/admin');
    final isProviderOnlyRoute = _providerOnlyRoutes.contains(
      state.matchedLocation,
    );
    final isPlannerOnlyRoute =
        _plannerOnlyRoutes.contains(state.matchedLocation) ||
        state.matchedLocation.startsWith('/my_trip_booking_detail/') ||
        state.matchedLocation.startsWith('/service_details/') ||
        state.matchedLocation.startsWith('/reviews/');

    if (!isLoggedIn && !onAuthScreen) {
      return '/register';
    }
    if (isLoggedIn && onAuthScreen) {
      return _authSessionStore.landingRoute;
    }
    if (isLoggedIn && _authSessionStore.isAdmin && !isAdminRoute) {
      return _authSessionStore.landingRoute;
    }
    if (isLoggedIn && !_authSessionStore.isAdmin && isAdminRoute) {
      return _authSessionStore.landingRoute;
    }
    if (isLoggedIn && !_authSessionStore.isProvider && isProviderOnlyRoute) {
      return _authSessionStore.landingRoute;
    }
    if (isLoggedIn && _authSessionStore.isProvider && isPlannerOnlyRoute) {
      return _authSessionStore.landingRoute;
    }
    return null;
  },
  routes: [
    GoRoute(path: '/', redirect: (context, state) => '/home'),
    GoRoute(
      path: '/register',
      builder: (context, state) =>
          _withSystemBack(state, const InitialRegistrationScreen()),
    ),
    GoRoute(
      path: '/admin_provider_approvals',
      builder: (context, state) =>
          _withSystemBack(state, const AdminProviderApprovalsScreen()),
    ),
    GoRoute(
      path: '/admin_provider_payouts',
      builder: (context, state) =>
          _withSystemBack(state, const AdminProviderPayoutsScreen()),
    ),
    GoRoute(
      path: '/admin_refunds',
      builder: (context, state) =>
          _withSystemBack(state, const AdminRefundsScreen()),
    ),
    GoRoute(
      path: '/admin_listing_approvals',
      builder: (context, state) =>
          _withSystemBack(state, const AdminListingApprovalsScreen()),
    ),
    GoRoute(
      path: '/home',
      builder: (context, state) => _withSystemBack(state, const HomeScreen()),
    ),
    GoRoute(
      path: '/search_filter',
      builder: (context, state) {
        final q = state.uri.queryParameters;
        return _withSystemBack(
          state,
          HotelSearchFilterScreen(
            initialQuery: q['query'] ?? '',
            startDate: q['startDate'],
            endDate: q['endDate'],
            guests: q['guests'],
          ),
        );
      },
    ),
    GoRoute(
      path: '/add_location_search',
      builder: (context, state) {
        final q = state.uri.queryParameters;
        return _withSystemBack(
          state,
          AddLocationSearchScreen(
            initialCategory: q['category'] ?? 'all',
            initialQuery: q['query'] ?? '',
            startDate: q['startDate'],
            endDate: q['endDate'],
            guests: q['guests'],
          ),
        );
      },
    ),
    GoRoute(
      path: '/trip_planner_dashboard',
      builder: (context, state) =>
          _withSystemBack(state, const TripPlannerDashboardScreen()),
    ),
    GoRoute(
      path: '/trip_planner_timeline',
      builder: (context, state) => _withSystemBack(
        state,
        TripPlannerTimelineScreen(tripId: state.uri.queryParameters['id']),
      ),
    ),
    GoRoute(
      path: '/plan_new_trip_form',
      builder: (context, state) =>
          _withSystemBack(state, const PlanNewTripFormScreen()),
    ),
    GoRoute(
      path: '/my_trips',
      builder: (context, state) => _withSystemBack(
        state,
        MyTripsScreen(
          initialStatus: state.uri.queryParameters['status'],
          focusBookingId: state.uri.queryParameters['bookingId'],
        ),
      ),
    ),
    GoRoute(
      path: '/my_trip_booking_detail/:id',
      builder: (context, state) => _withSystemBack(
        state,
        MyTripBookingDetailScreen(bookingItemId: state.pathParameters['id']!),
      ),
    ),
    GoRoute(
      path: '/booking_checkout',
      builder: (context, state) => _withSystemBack(
        state,
        BookingCheckoutScreen(
          type: state.uri.queryParameters['type'],
          hotelId: state.uri.queryParameters['hotelId'],
          roomId: state.uri.queryParameters['roomId'],
          flightId: state.uri.queryParameters['flightId'],
          activityId: state.uri.queryParameters['activityId'],
          startDate: state.uri.queryParameters['startDate'],
          endDate: state.uri.queryParameters['endDate'],
          guests: state.uri.queryParameters['guests'],
        ),
      ),
    ),
    GoRoute(
      path: '/service_details/:id',
      builder: (context, state) {
        final q = state.uri.queryParameters;
        return _withSystemBack(
          state,
          ServiceDetailsScreen(
            hotelId: int.parse(state.pathParameters['id']!),
            startDate: q['startDate'],
            endDate: q['endDate'],
            guests: q['guests'],
          ),
        );
      },
    ),
    GoRoute(
      path: '/reviews/:id',
      builder: (context, state) {
        final q = state.uri.queryParameters;
        return _withSystemBack(
          state,
          ReviewsScreen(
            hotelId: int.parse(state.pathParameters['id']!),
            hotelName: q['name'] ?? 'this place',
            averageRating: double.tryParse(q['rating'] ?? '') ?? 0,
            reviewCount: int.tryParse(q['count'] ?? '') ?? 0,
          ),
        );
      },
    ),
    GoRoute(
      path: '/add_payment',
      builder: (context, state) =>
          _withSystemBack(state, const AddPaymentScreen()),
    ),
    GoRoute(
      path: '/payment_success',
      builder: (context, state) => _withSystemBack(
        state,
        PaymentSuccessScreen(
          bookingId: state.uri.queryParameters['bookingId'],
          paymentId: state.uri.queryParameters['paymentId'],
        ),
      ),
    ),
    GoRoute(
      path: '/wallet_loyalty',
      builder: (context, state) =>
          _withSystemBack(state, const WalletLoyaltyScreen()),
    ),
    GoRoute(
      path: '/wallet_transactions',
      builder: (context, state) =>
          _withSystemBack(state, const WalletTransactionsScreen()),
    ),
    GoRoute(
      path: '/profile_registration',
      builder: (context, state) =>
          _withSystemBack(state, const ProfileRegistrationScreen()),
    ),
    GoRoute(
      path: '/profile_verification',
      builder: (context, state) =>
          _withSystemBack(state, const ProfileVerificationScreen()),
    ),
    GoRoute(
      path: '/provider_finance',
      builder: (context, state) =>
          _withSystemBack(state, const ProviderFinancePayoutScreen()),
    ),
    GoRoute(
      path: '/provider_registration',
      builder: (context, state) =>
          _withSystemBack(state, const ProviderRegistrationFormScreen()),
    ),
    GoRoute(
      path: '/provider_dashboard',
      builder: (context, state) =>
          _withSystemBack(state, const ProviderDashboardScreen()),
    ),
    GoRoute(
      path: '/provider_listings',
      builder: (context, state) =>
          _withSystemBack(state, const ProviderListingManagementScreen()),
    ),
    GoRoute(
      path: '/add_new_listing_form',
      builder: (context, state) =>
          _withSystemBack(state, const AddNewListingFormScreen()),
    ),
    GoRoute(
      path: '/order_manager',
      builder: (context, state) =>
          _withSystemBack(state, const OrderManagerScreen()),
    ),
    GoRoute(
      path: '/direct_messaging',
      builder: (context, state) => _withSystemBack(
        state,
        DirectMessagingScreen(
          conversationId: state.uri.queryParameters['conversationId'],
          orderId: state.uri.queryParameters['orderId'],
          mode: state.uri.queryParameters['mode'],
        ),
      ),
    ),
    GoRoute(
      path: '/vip_services',
      builder: (context, state) =>
          _withSystemBack(state, const VipServicesScreen()),
    ),
    GoRoute(
      path: '/elite_upgrade_confirmation',
      builder: (context, state) =>
          _withSystemBack(state, const EliteUpgradeConfirmationScreen()),
    ),
    GoRoute(
      path: '/security_privacy',
      builder: (context, state) =>
          _withSystemBack(state, const SecurityPrivacyScreen()),
    ),
    GoRoute(
      path: '/notifications',
      builder: (context, state) =>
          _withSystemBack(state, const NotificationsScreen()),
    ),
    GoRoute(
      path: '/notification_inbox',
      builder: (context, state) =>
          _withSystemBack(state, const NotificationInboxScreen()),
    ),
    GoRoute(
      path: '/help_center',
      builder: (context, state) =>
          _withSystemBack(state, const HelpCenterScreen()),
    ),
    GoRoute(
      path: '/provider_listing_edit',
      builder: (context, state) {
        final listingId = state.uri.queryParameters['id'];
        final listingTitle = state.uri.queryParameters['title'];
        return _withSystemBack(
          state,
          ProviderListingEditScreen(
            listingId: listingId,
            listingTitle: listingTitle,
          ),
        );
      },
    ),
    GoRoute(
      path: '/provider_listing_add',
      builder: (context, state) =>
          _withSystemBack(state, const ProviderListingAddScreen()),
    ),
    GoRoute(
      path: '/provider_analytics',
      builder: (context, state) {
        final listingId = state.uri.queryParameters['id'];
        final listingTitle = state.uri.queryParameters['title'];
        return _withSystemBack(
          state,
          ProviderAnalyticsScreen(
            listingId: listingId,
            listingTitle: listingTitle,
          ),
        );
      },
    ),
    GoRoute(
      path: '/add_activity',
      builder: (context, state) => _withSystemBack(
        state,
        AddActivityScreen(
          tripId: state.uri.queryParameters['tripId'],
          dayIndex: int.tryParse(state.uri.queryParameters['dayIndex'] ?? ''),
        ),
      ),
    ),
    GoRoute(
      path: '/inventory_pricing',
      builder: (context, state) =>
          _withSystemBack(state, const InventoryPricingScreen()),
    ),
    GoRoute(
      path: '/provider_registration_form',
      builder: (context, state) =>
          _withSystemBack(state, const ProviderRegistrationFormScreen()),
    ),
  ],
);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await _authSessionStore.initialize();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      statusBarBrightness: Brightness.light,
      systemNavigationBarColor: Colors.white,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );
  // Render UI first: keeps cold start snappy and guarantees the router is
  // mounted so a deferred deep link can flush. Push init is best-effort and
  // must never blank the app.
  runApp(const MyApp());

  if (PushMessagingService.isSupported) {
    await PushMessagingService.initialize(onNotificationTap: handleNotificationTap);
    await _authSessionStore.syncPushToken();
    PushMessagingService.onTokenRefresh.listen((t) {
      if (_authSessionStore.isAuthenticated) {
        DeviceApi().registerToken(t);
      }
    });
  }
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  StreamSubscription<IncomingPushPayload>? _fcmSub;
  StreamSubscription<IncomingPushPayload>? _pollSub;
  StreamSubscription<Uri>? _appLinksSub;
  final AppLinks _appLinks = AppLinks();
  final NotificationApi _notificationApi = NotificationApi();

  // Notifications already shown as a banner this session. Both the FCM
  // foreground stream (Android) and the polling fallback (all platforms) feed
  // banners — dedupe by notification id so the same one never pops twice.
  final Set<String> _banneredIds = <String>{};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    _appLinks.getInitialLink().then((uri) {
      if (uri != null) handleDeepLink(uri.toString());
    }).catchError((_) {});
    _appLinksSub = _appLinks.uriLinkStream.listen(
      (uri) => handleDeepLink(uri.toString()),
      onError: (_) {},
    );

    // Source 1: FCM foreground pushes (Android, instant). push_messaging_
    // service.dart no longer renders the OS tray for these — we banner instead.
    _fcmSub = PushMessagingService.onForegroundPush.listen(_showBanner);

    // Source 2: polling fallback so the in-app banner works on iOS / web /
    // Android-without-a-live-push. Only runs while authenticated.
    _pollSub = NotificationAlertService.onNewNotification.listen(_showBanner);

    _authSessionStore.addListener(_syncPollerToAuth);
    _syncPollerToAuth();
  }

  void _syncPollerToAuth() {
    if (_authSessionStore.isAuthenticated) {
      NotificationAlertService.start();
    } else {
      NotificationAlertService.stop();
      _banneredIds.clear();
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Returning to the foreground: poll immediately rather than waiting for the
    // next tick, so a notification that arrived while backgrounded shows soon.
    if (state == AppLifecycleState.resumed) {
      NotificationAlertService.pollNow();
    }
  }

  void _showBanner(IncomingPushPayload payload) {
    final id = payload.notificationId;
    if (id != null && id.isNotEmpty) {
      if (_banneredIds.contains(id)) return;
      _banneredIds.add(id);
    }
    final navigator = rootNavigatorKey.currentState;
    if (navigator == null) return;
    showInAppPushBanner(
      navigator: navigator,
      payload: payload,
      onTap: () => _onBannerTap(payload),
    );
  }

  // Tapping a banner is explicit engagement, so mark the notification read
  // (mirrors an inbox-row tap) before deep-linking. Merely *showing* the
  // banner does NOT mark read — a glance the user may have missed shouldn't
  // silently clear the unread badge.
  void _onBannerTap(IncomingPushPayload payload) {
    final id = payload.notificationId;
    if (id != null && id.isNotEmpty) {
      unawaited(_markReadQuietly(id));
    }
    handleDeepLink(payload.actionRoute);
  }

  Future<void> _markReadQuietly(String id) async {
    try {
      await _notificationApi.markRead(id);
    } catch (_) {
      // Best-effort: the deep-link still happens; the inbox will reconcile on
      // its next fetch.
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _authSessionStore.removeListener(_syncPollerToAuth);
    _fcmSub?.cancel();
    _pollSub?.cancel();
    _appLinksSub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Flush a deep link captured before the router existed (killed-state tap).
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final pending = _pendingDeepLink;
      if (pending != null) {
        _pendingDeepLink = null;
        _router.go(pending);
      }
    });
    return MaterialApp.router(
      title: 'Tripwise',
      theme: TripwiseTheme.light,
      debugShowCheckedModeBanner: false,
      routerConfig: _router,
    );
  }
}
