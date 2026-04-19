import 'package:flutter/material.dart';
import 'constants/theme.dart';
import 'screens/my_trips_screen.dart';
import 'screens/booking_checkout_screen.dart';
import 'screens/profile_registration_screen.dart';
import 'screens/provider_listing_management_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tripwise',
      theme: TripwiseTheme.light,
      debugShowCheckedModeBanner: false,
      home: const MyTripsScreen(),
      routes: {
        '/my_trips': (context) => const MyTripsScreen(),
        '/booking_checkout': (context) => const BookingCheckoutScreen(),
        '/profile_registration': (context) => const ProfileRegistrationScreen(),
        '/provider_listings': (context) => const ProviderListingManagementScreen(),
      },
    );
  }
}

