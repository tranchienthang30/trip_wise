import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'constants/theme.dart';
import 'screens/home_screen.dart';
import 'screens/hotel_search_filter_screen.dart';
import 'screens/my_trips_screen.dart';
import 'screens/booking_checkout_screen.dart';
import 'screens/provider_finance_payout_screen.dart';
import 'screens/profile_registration_screen.dart';
import 'screens/provider_listing_management_screen.dart';
import 'screens/security_privacy_screen.dart';
import 'screens/notifications_screen.dart';
import 'screens/help_center_screen.dart';

final GoRouter _router = GoRouter(
  initialLocation: '/home',
  routes: [
    GoRoute(
      path: '/home',
      builder: (context, state) => const HomeScreen(),
    ),
    GoRoute(
      path: '/search_filter',
      builder: (context, state) => const HotelSearchFilterScreen(),
    ),
    GoRoute(
      path: '/my_trips',
      builder: (context, state) => const MyTripsScreen(),
    ),
    GoRoute(
      path: '/booking_checkout',
      builder: (context, state) => const BookingCheckoutScreen(),
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
      path: '/provider_listings',
      builder: (context, state) => const ProviderListingManagementScreen(),
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
      path: '/help_center',
      builder: (context, state) => const HelpCenterScreen(),
    ),
  ],
);

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Tripwise',
      theme: TripwiseTheme.light,
      debugShowCheckedModeBanner: false,
      routerConfig: _router,
    );
  }
}
