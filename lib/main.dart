import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'constants/theme.dart';
import 'services/auth_session_store.dart';
import 'services/push_messaging_service.dart';
import 'services/devices_api.dart';
import 'screens/home_screen.dart';
import 'screens/add_activity_screen.dart';
import 'screens/add_location_search_screen.dart';
import 'screens/add_new_listing_form_screen.dart';
import 'screens/add_payment_screen.dart';
import 'screens/hotel_search_filter_screen.dart';
import 'screens/initial_registration_screen.dart';
import 'screens/my_trips_screen.dart';
import 'screens/booking_checkout_screen.dart';
import 'screens/direct_messaging_screen.dart';
import 'screens/elite_upgrade_confirmation_screen.dart';
import 'screens/order_manager_screen.dart';
import 'screens/plan_new_trip_form_screen.dart';
import 'screens/provider_dashboard_screen.dart';
import 'screens/provider_finance_payout_screen.dart';
import 'screens/provider_registration_screen.dart';
import 'screens/profile_registration_screen.dart';
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

// A deep link that arrived before the router was mounted (cold start from a
// killed-state notification tap). Flushed on the first frame.
String? _pendingDeepLink;

/// Navigates to a notification's `action_route`. Rejects anything that is not
/// an in-app absolute path (action_route safety). `go` (not `push`) so a tap
/// lands the user *on* the target rather than stacked on a random screen.
void handleDeepLink(String? route) {
  if (route == null || route.isEmpty || !route.startsWith('/')) return;
  if (rootNavigatorKey.currentContext == null) {
    _pendingDeepLink = route; // router not ready yet — defer
    return;
  }
  _router.go(route);
}

final GoRouter _router = GoRouter(
  initialLocation: '/home',
  navigatorKey: rootNavigatorKey,
  refreshListenable: _authSessionStore,
  redirect: (context, state) {
    final isLoggedIn = _authSessionStore.isAuthenticated;
    final onAuthScreen = state.matchedLocation == '/register';

    if (!isLoggedIn && !onAuthScreen) {
      return '/register';
    }
    if (isLoggedIn && onAuthScreen) {
      return _authSessionStore.landingRoute;
    }
    return null;
  },
  routes: [
    GoRoute(
      path: '/register',
      builder: (context, state) => const InitialRegistrationScreen(),
    ),
    GoRoute(path: '/home', builder: (context, state) => const HomeScreen()),
    GoRoute(
      path: '/search_filter',
      builder: (context, state) => const HotelSearchFilterScreen(),
    ),
    GoRoute(
      path: '/add_location_search',
      builder: (context, state) => AddLocationSearchScreen(
        initialCategory: state.uri.queryParameters['category'] ?? 'all',
        initialQuery: state.uri.queryParameters['query'] ?? '',
      ),
    ),
    GoRoute(
      path: '/trip_planner_dashboard',
      builder: (context, state) => const TripPlannerDashboardScreen(),
    ),
    GoRoute(
      path: '/trip_planner_timeline',
      builder: (context, state) =>
          TripPlannerTimelineScreen(tripId: state.uri.queryParameters['id']),
    ),
    GoRoute(
      path: '/plan_new_trip_form',
      builder: (context, state) => const PlanNewTripFormScreen(),
    ),
    GoRoute(
      path: '/my_trips',
      builder: (context, state) => MyTripsScreen(
        initialStatus: state.uri.queryParameters['status'],
        focusBookingId: state.uri.queryParameters['bookingId'],
      ),
    ),
    GoRoute(
      path: '/booking_checkout',
      builder: (context, state) => BookingCheckoutScreen(
        hotelId: state.uri.queryParameters['hotelId'],
        roomId: state.uri.queryParameters['roomId'],
        startDate: state.uri.queryParameters['startDate'],
        endDate: state.uri.queryParameters['endDate'],
        guests: state.uri.queryParameters['guests'],
      ),
    ),
    GoRoute(
      path: '/service_details/:id',
      builder: (context, state) =>
          ServiceDetailsScreen(hotelId: int.parse(state.pathParameters['id']!)),
    ),
    GoRoute(
      path: '/reviews/:id',
      builder: (context, state) {
        final q = state.uri.queryParameters;
        return ReviewsScreen(
          hotelId: int.parse(state.pathParameters['id']!),
          hotelName: q['name'] ?? 'this place',
          averageRating: double.tryParse(q['rating'] ?? '') ?? 0,
          reviewCount: int.tryParse(q['count'] ?? '') ?? 0,
        );
      },
    ),
    GoRoute(
      path: '/add_payment',
      builder: (context, state) => const AddPaymentScreen(),
    ),
    GoRoute(
      path: '/payment_success',
      builder: (context, state) => PaymentSuccessScreen(
        bookingId: state.uri.queryParameters['bookingId'],
        paymentId: state.uri.queryParameters['paymentId'],
      ),
    ),
    GoRoute(
      path: '/wallet_loyalty',
      builder: (context, state) => const WalletLoyaltyScreen(),
    ),
    GoRoute(
      path: '/wallet_transactions',
      builder: (context, state) => const WalletTransactionsScreen(),
    ),
    GoRoute(
      path: '/profile_registration',
      builder: (context, state) => const ProfileRegistrationScreen(),
    ),
    GoRoute(
      path: '/provider_finance',
      builder: (context, state) => const ProviderFinancePayoutScreen(),
    ),
    GoRoute(
      path: '/provider_registration',
      builder: (context, state) => const ProviderRegistrationScreen(),
    ),
    GoRoute(
      path: '/provider_dashboard',
      builder: (context, state) => const ProviderDashboardScreen(),
    ),
    GoRoute(
      path: '/provider_listings',
      builder: (context, state) => const ProviderListingManagementScreen(),
    ),
    GoRoute(
      path: '/add_new_listing_form',
      builder: (context, state) => const AddNewListingFormScreen(),
    ),
    GoRoute(
      path: '/order_manager',
      builder: (context, state) => const OrderManagerScreen(),
    ),
    GoRoute(
      path: '/direct_messaging',
      builder: (context, state) => DirectMessagingScreen(
        conversationId: state.uri.queryParameters['conversationId'],
        orderId: state.uri.queryParameters['orderId'],
        mode: state.uri.queryParameters['mode'],
      ),
    ),
    GoRoute(
      path: '/vip_services',
      builder: (context, state) => const VipServicesScreen(),
    ),
    GoRoute(
      path: '/elite_upgrade_confirmation',
      builder: (context, state) => const EliteUpgradeConfirmationScreen(),
    ),
    GoRoute(
      path: '/security_privacy',
      builder: (context, state) => const SecurityPrivacyScreen(),
    ),
    GoRoute(
      path: '/notifications',
      builder: (context, state) => const NotificationsScreen(),
    ),
    GoRoute(
      path: '/notification_inbox',
      builder: (context, state) => const NotificationInboxScreen(),
    ),
    GoRoute(
      path: '/help_center',
      builder: (context, state) => const HelpCenterScreen(),
    ),
    GoRoute(
      path: '/provider_listing_edit',
      builder: (context, state) {
        final listingId = state.uri.queryParameters['id'];
        final listingTitle = state.uri.queryParameters['title'];
        return ProviderListingEditScreen(
          listingId: listingId,
          listingTitle: listingTitle,
        );
      },
    ),
    GoRoute(
      path: '/provider_listing_add',
      builder: (context, state) => const ProviderListingAddScreen(),
    ),
    GoRoute(
      path: '/provider_analytics',
      builder: (context, state) {
        final listingId = state.uri.queryParameters['id'];
        final listingTitle = state.uri.queryParameters['title'];
        return ProviderAnalyticsScreen(
          listingId: listingId,
          listingTitle: listingTitle,
        );
      },
    ),
    GoRoute(
      path: '/add_activity',
      builder: (context, state) => AddActivityScreen(
        tripId: state.uri.queryParameters['tripId'],
        dayIndex: int.tryParse(state.uri.queryParameters['dayIndex'] ?? ''),
      ),
    ),
    GoRoute(
      path: '/inventory_pricing',
      builder: (context, state) => const InventoryPricingScreen(),
    ),
    GoRoute(
      path: '/provider_registration_form',
      builder: (context, state) => const ProviderRegistrationFormScreen(),
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
    await PushMessagingService.initialize(onDeepLink: handleDeepLink);
    await _authSessionStore.syncPushToken();
    PushMessagingService.onTokenRefresh.listen((t) {
      if (_authSessionStore.isAuthenticated) {
        DeviceApi().registerToken(t);
      }
    });
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

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
