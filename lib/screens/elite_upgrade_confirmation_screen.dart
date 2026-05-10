import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../constants/colors.dart';
import '../widgets/shared_taskbars.dart';
import '../widgets/shared_top_bars.dart';

class EliteUpgradeConfirmationScreen extends StatelessWidget {
  const EliteUpgradeConfirmationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FF),
      appBar: _buildAppBar(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 120),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 896), // max-w-4xl
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 32, 24, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildHeroSection(),
                  const SizedBox(height: 32),
                  _buildPlanDetailsGrid(context),
                ],
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: const ProviderTaskbar(
        currentTab: ProviderTaskbarTab.vip,
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return const ProviderAppBar();
  }

  Widget _buildHeroSection() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF005F9F).withOpacity(0.04),
            blurRadius: 40,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Background blurs representation
          Positioned(
            top: -50,
            right: -50,
            child: Container(
              width: 256,
              height: 256,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFFD1E4FF).withOpacity(0.2), // primary-fixed/20
              ),
            ),
          ),
          Positioned(
            bottom: -50,
            left: -50,
            child: Container(
              width: 256,
              height: 256,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFFFFDBD0).withOpacity(0.2), // secondary-fixed/20
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 24),
            child: Column(
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF5E1F), // secondary-container
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Icon(Icons.stars, color: Colors.white, size: 36),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Ready for the Next Level?',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 32, // display-xl equivalent approx
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF004779), // primary
                    letterSpacing: -1.0,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  "You're one step away from unlocking premium tools designed for industry leaders.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: Color(0xFF414750), // on-surface-variant
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlanDetailsGrid(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth > 768) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(flex: 2, child: _buildPlanIdentityCard()),
              const SizedBox(width: 24),
              Expanded(
                flex: 1,
                child: Column(
                  children: [
                    _buildConfirmationActionCard(context),
                    const SizedBox(height: 24),
                    _buildSecondaryPreviewCard(),
                  ],
                ),
              ),
            ],
          );
        } else {
          return Column(
            children: [
              _buildPlanIdentityCard(),
              const SizedBox(height: 24),
              _buildConfirmationActionCard(context),
              const SizedBox(height: 24),
              _buildSecondaryPreviewCard(),
            ],
          );
        }
      },
    );
  }

  Widget _buildPlanIdentityCard() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF005F9F).withOpacity(0.04),
            blurRadius: 40,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFDBD0), // secondary-fixed
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text('CURRENT SELECTION', style: TextStyle(color: Color(0xFFAB3500), fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
                    ),
                    const SizedBox(height: 12),
                    const Text('Elite Provider', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: Color(0xFF004779), letterSpacing: -0.5)),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: const [
                  Text('\$', style: TextStyle(fontSize: 32, fontWeight: FontWeight.w800, color: Color(0xFF191C20), letterSpacing: -1.0)),
                  Text('/month', style: TextStyle(fontSize: 16, color: Color(0xFF414750))),
                ],
              ),
            ],
          ),
          const SizedBox(height: 32),
          _buildFeatureItem(Icons.percent, '8% Reduced Commission', 'Keep more of your hard-earned revenue.'),
          const SizedBox(height: 16),
          _buildFeatureItem(Icons.support_agent, '24/7 Dedicated Concierge', 'Priority support whenever you need it.'),
          const SizedBox(height: 16),
          _buildFeatureItem(Icons.verified, 'Verified Premium Badge', 'Build instant trust with elite clients.'),
          const SizedBox(height: 16),
          _buildFeatureItem(Icons.bolt, 'Priority Search Placement', 'Appear at the top of client searches.'),
        ],
      ),
    );
  }

  Widget _buildFeatureItem(IconData icon, String title, String description) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF2F3F9), // surface-container-low
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFF004779).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: const Color(0xFF004779), size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF191C20))),
                const SizedBox(height: 2),
                Text(description, style: const TextStyle(fontSize: 14, color: Color(0xFF414750))),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConfirmationActionCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: const Color(0xFF004779), // primary
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Icon(Icons.check_circle, color: Colors.white, size: 48),
          const SizedBox(height: 16),
          const Text('Ready to Upgrade?', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
          const SizedBox(height: 8),
          const Text('Your benefits will activate immediately upon confirmation.', textAlign: TextAlign.center, style: TextStyle(fontSize: 14, color: Color(0xFF9ECAFF))),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => context.go('/vip_services'),
              style: TripwiseButtonStyles.primaryElevated(
                radius: 32,
                padding: const EdgeInsets.symmetric(vertical: 20),
              ),
              child: const Text('Confirm Upgrade', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ),
          const SizedBox(height: 16),
          InkWell(
            onTap: () {},
            child: const Text(
              'View Payment Details & Terms',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Color(0xFFD1E4FF), // primary-fixed
                decoration: TextDecoration.underline,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSecondaryPreviewCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFD1E4FF).withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF005F9F).withOpacity(0.04),
            blurRadius: 40,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Network Growth', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF004779))),
          const SizedBox(height: 16),
          SizedBox(
            height: 96,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(child: Container(margin: const EdgeInsets.symmetric(horizontal: 2), height: 32, decoration: BoxDecoration(color: const Color(0xFF004779).withOpacity(0.3), borderRadius: const BorderRadius.vertical(top: Radius.circular(16))))),
                Expanded(child: Container(margin: const EdgeInsets.symmetric(horizontal: 2), height: 48, decoration: BoxDecoration(color: const Color(0xFF004779).withOpacity(0.3), borderRadius: const BorderRadius.vertical(top: Radius.circular(16))))),
                Expanded(child: Container(margin: const EdgeInsets.symmetric(horizontal: 2), height: 64, decoration: BoxDecoration(color: const Color(0xFF004779).withOpacity(0.3), borderRadius: const BorderRadius.vertical(top: Radius.circular(16))))),
                Expanded(child: Container(margin: const EdgeInsets.symmetric(horizontal: 2), height: 96, decoration: BoxDecoration(color: const Color(0xFF004779), borderRadius: const BorderRadius.vertical(top: Radius.circular(16))))),
              ],
            ),
          ),
          const SizedBox(height: 16),
          const Text('Elite providers see 40% more engagement on average.', textAlign: TextAlign.center, style: TextStyle(fontSize: 12, color: Color(0xFF414750))),
        ],
      ),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9), // bg-white/80
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF005F9F).withOpacity(0.04), // shadow-[0px_-10px_40px_rgba(0,95,159,0.04)]
            blurRadius: 40,
            offset: const Offset(0, -10),
          ),
        ],
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)), // rounded-t-[2rem]
      ),
      clipBehavior: Clip.antiAlias,
      child: BottomNavigationBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: TripwiseColors.primary,
        unselectedItemColor: const Color(0xFF94A3B8), // text-slate-400
        showUnselectedLabels: true,
        selectedLabelStyle: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600, letterSpacing: 0.5),
        unselectedLabelStyle: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600, letterSpacing: 0.5),
        currentIndex: 3, // Plans
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.payments),
            label: 'Earnings',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
            label: 'Bookings',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.stars),
            label: 'Plans',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Account',
          ),
        ],
      ),
    );
  }
}
