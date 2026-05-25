import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../constants/colors.dart';
import '../services/auth_session_store.dart';

enum PlannerTaskbarTab { home, myTrips, planner, wallet, profile }

enum ProviderTaskbarTab { dashboard, listings, orders, vip, finance }

enum AdminTaskbarTab { providers, listings, payouts, refunds }

class PlannerTaskbar extends StatelessWidget {
  const PlannerTaskbar({super.key, required this.currentTab});

  final PlannerTaskbarTab currentTab;

  static const _routes = [
    '/home',
    '/my_trips',
    '/trip_planner_dashboard',
    '/wallet_loyalty',
    '/profile_registration',
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.92),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 18,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: BottomNavigationBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        type: BottomNavigationBarType.fixed,
        currentIndex: currentTab.index,
        selectedItemColor: TripwiseColors.primary,
        unselectedItemColor: TripwiseColors.outline,
        showUnselectedLabels: true,
        selectedLabelStyle: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
        unselectedLabelStyle: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
        onTap: (index) => context.go(_routes[index]),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_rounded),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.flight_rounded),
            label: 'My Trips',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.event_note_rounded),
            label: 'Planner',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_balance_wallet_rounded),
            label: 'Wallet',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_rounded),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

class ProviderTaskbar extends StatelessWidget {
  const ProviderTaskbar({super.key, required this.currentTab});

  final ProviderTaskbarTab currentTab;

  static const _routes = [
    '/provider_dashboard',
    '/provider_listings',
    '/order_manager',
    '/vip_services',
    '/provider_finance',
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.92),
        boxShadow: [
          BoxShadow(
            color: TripwiseColors.primary.withOpacity(0.06),
            blurRadius: 24,
            offset: const Offset(0, -8),
          ),
        ],
      ),
      child: BottomNavigationBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        type: BottomNavigationBarType.fixed,
        currentIndex: currentTab.index,
        selectedItemColor: TripwiseColors.primary,
        unselectedItemColor: TripwiseColors.onSurfaceVariant,
        showUnselectedLabels: true,
        selectedLabelStyle: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
        unselectedLabelStyle: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
        onTap: (index) => context.go(_routes[index]),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard_rounded),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.list_alt_rounded),
            label: 'Listings',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.receipt_long_rounded),
            label: 'Orders',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.workspace_premium_rounded),
            label: 'VIP',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.payments_rounded),
            label: 'Finance',
          ),
        ],
      ),
    );
  }
}

class AdminTaskbar extends StatelessWidget {
  const AdminTaskbar({super.key, required this.currentTab});

  final AdminTaskbarTab currentTab;

  static const _routes = [
    '/admin_provider_approvals',
    '/admin_listing_approvals',
    '/admin_provider_payouts',
    '/admin_refunds',
  ];

  Future<void> _signOut(BuildContext context) async {
    await AuthSessionStore.instance.logout();
    if (!context.mounted) return;
    context.go('/register');
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.92),
        boxShadow: [
          BoxShadow(
            color: TripwiseColors.primary.withOpacity(0.06),
            blurRadius: 24,
            offset: const Offset(0, -8),
          ),
        ],
      ),
      child: BottomNavigationBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        type: BottomNavigationBarType.fixed,
        currentIndex: currentTab.index,
        selectedItemColor: TripwiseColors.primary,
        unselectedItemColor: TripwiseColors.onSurfaceVariant,
        showUnselectedLabels: true,
        selectedLabelStyle: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
        unselectedLabelStyle: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
        onTap: (index) {
          if (index < _routes.length) {
            context.go(_routes[index]);
          } else {
            _signOut(context);
          }
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.verified_user_rounded),
            label: 'Providers',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.hotel_rounded),
            label: 'Listings',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.payments_rounded),
            label: 'Payouts',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.assignment_return_rounded),
            label: 'Refunds',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.logout_rounded),
            label: 'Logout',
          ),
        ],
      ),
    );
  }
}
