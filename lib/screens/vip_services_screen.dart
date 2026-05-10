import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../constants/colors.dart';
import '../widgets/shared_taskbars.dart';
import '../widgets/shared_top_bars.dart';

class VipServicesScreen extends StatelessWidget {
  const VipServicesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FF),
      appBar: _buildAppBar(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 100),
        child: Column(
          children: [
            _buildHeroSection(),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 48, 24, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildUpgradePlanSection(context),
                  const SizedBox(height: 48),
                  _buildPromoteListingsSection(),
                  const SizedBox(height: 48),
                  _buildPromotionReachImpact(),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: _buildFab(),
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
      margin: const EdgeInsets.fromLTRB(24, 40, 24, 0),
      height: 400,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        image: const DecorationImage(
          image: NetworkImage(
            'https://lh3.googleusercontent.com/aida-public/AB6AXuC3kP04RDK6hlaAT2SauvpVLGlvFVNBjlTJszwmJmKLC9KvFj9x_FC6DKuSbi2vxkJTolgfn-NAWw10R4CT369wb6m84nRL3aQnf-H_1DoKB_bgFj5HOlWijdTDdv5n0lNsyLR0rNzC8KArQ6A7pb-i7mGeVF_-brei9iE_p837xWPYcqCIeAUdllOwVQnQpU_7HvshogninfM3BpIs6kQQ11ltWABJ1mpft-P_YbbF0Vo_eGoP0foKhQq4yMzfEfcbG2ylKK3sBIU',
          ),
          fit: BoxFit.cover,
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
            colors: [
              const Color(0xFF181C22).withOpacity(0.8),
              const Color(0xFF181C22).withOpacity(0.2),
              Colors.transparent,
            ],
          ),
        ),
        padding: const EdgeInsets.all(32),
        alignment: Alignment.bottomLeft,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFF0078C7),
                borderRadius: BorderRadius.circular(24),
              ),
              child: const Text(
                'VIP SERVICES',
                style: TextStyle(
                  color: Color(0xFFD1E4FF),
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Elevate Your Presence.',
              style: TextStyle(
                color: Colors.white,
                fontSize: 48,
                fontWeight: FontWeight.w900,
                height: 1.1,
                letterSpacing: -1.0,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Unlock premium tools, lower your commission rates, and feature your services to millions of global travelers.',
              style: TextStyle(
                color: Colors.white.withOpacity(0.8),
                fontSize: 16,
                fontWeight: FontWeight.w300,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUpgradePlanSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Upgrade Your Plan',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w800,
            color: Color(0xFF181C22),
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          'Select the tier that fits your growth ambitions.',
          style: TextStyle(
            fontSize: 16,
            color: Color(0xFF3F4752),
          ),
        ),
        const SizedBox(height: 32),
        _buildStandardPlan(),
        const SizedBox(height: 24),
        _buildElitePlan(context),
      ],
    );
  }

  Widget _buildStandardPlan() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F4FC),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Standard Provider',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF181C22)),
          ),
          const SizedBox(height: 8),
          const Text(
            'Your current operational baseline.',
            style: TextStyle(fontSize: 14, color: Color(0xFF3F4752)),
          ),
          const SizedBox(height: 24),
          _checkItem('15% Platform Commission'),
          const SizedBox(height: 16),
          _checkItem('Standard Support (24h)'),
          const SizedBox(height: 16),
          _checkItem('Basic Analytics'),
          const SizedBox(height: 40),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
            decoration: BoxDecoration(
              border: Border.all(color: const Color(0xFFBFC7D4)),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Text(
              'Current Active Plan',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF181C22)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _checkItem(String text) {
    return Row(
      children: [
        const Icon(Icons.check_circle, color: Color(0xFF005F9F), size: 20),
        const SizedBox(width: 12),
        Text(
          text,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Color(0xFF181C22)),
        ),
      ],
    );
  }

  Widget _buildElitePlan(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: const Color(0xFF181C22),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Stack(
        children: [
          Positioned(
            top: -20,
            right: -20,
            child: Icon(Icons.workspace_premium, size: 120, color: Colors.white.withOpacity(0.1)),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: const [
                  Icon(Icons.star, color: Color(0xFFAB3500)),
                  SizedBox(width: 12),
                  Text(
                    'ELITE PROVIDER',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: Color(0xFFAB3500), letterSpacing: 1.5),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                'The gold standard for high-volume agencies and luxury boutiques.',
                style: TextStyle(fontSize: 14, color: Colors.white.withOpacity(0.7)),
              ),
              const SizedBox(height: 32),
              Row(
                children: [
                  Expanded(child: _eliteStat('8%', 'Reduced Commission')),
                  Expanded(child: _eliteStat('24/7', 'Dedicated Concierge')),
                ],
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(child: _eliteStat('Verified', 'Premium Badge')),
                  Expanded(child: _eliteStat('Priority', 'Search Placement')),
                ],
              ),
              const SizedBox(height: 32),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Starting at', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white.withOpacity(0.6))),
                    const SizedBox(height: 4),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        const Text('\$', style: TextStyle(fontSize: 36, fontWeight: FontWeight.w900, color: Colors.white)),
                        const SizedBox(width: 4),
                        Text('/mo', style: TextStyle(fontSize: 14, color: Colors.white.withOpacity(0.6))),
                      ],
                    ),
                    const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () =>
                              context.push('/elite_upgrade_confirmation'),
                          style: TripwiseButtonStyles.primaryElevated(
                            radius: 12,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                        child: const Text('UPGRADE NOW', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900, letterSpacing: 1.5)),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _eliteStat(String value, String label) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(value, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: Color(0xFFFFDBD0))),
        const SizedBox(height: 8),
        Text(
          label.toUpperCase(),
          style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.2, color: Colors.white.withOpacity(0.5)),
        ),
      ],
    );
  }

  Widget _buildPromoteListingsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Promote Your Listings',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w800,
            color: Color(0xFF181C22),
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          'Boost your visibility and capture more bookings instantly.',
          style: TextStyle(
            fontSize: 16,
            color: Color(0xFF3F4752),
          ),
        ),
        const SizedBox(height: 32),
        _adSpotCard(
          imageUrl: 'https://lh3.googleusercontent.com/aida-public/AB6AXuAPzFbfkT0XP3cpi4TM9bp9ntpnMwFLK0lrCUIwONZrhlblvVwn3O6Y6ztjBsZlIiFNKO1hNCsOU4I4xxfGlptp2Y1JrS1wQc0JGP2tTBlBFdUuUErYsKRBgC7jW0LhUi-xsCOw4K_moOb1Fy1kOzqvTkT125Pd1hfEy4RTM6bAUBXAR9RTgZNfN9emUUNKsTia_6208TvjUI9N2bBPFZ-KMDd53MaNH89GgU3gxKui7qLOJl8jKiq7yfWvSwLgXY3SJniux9F8Ca4',
          icon: Icons.rocket_launch,
          title: 'Top of Search',
          description: 'Guarantee your listing appears in the first 3 results for your destination city.',
          price: '\$',
          priceUnit: '/ Day',
        ),
        const SizedBox(height: 24),
        _adSpotCard(
          imageUrl: 'https://lh3.googleusercontent.com/aida-public/AB6AXuDydowfdEAt6ARDm16dBoFbn1jnF2sBkvVr-kAIakXzL1nvQr3nUP6ZzrzFICYHtwSa1X3w0KPewTYiFCAF5-VMnWeMfNof2SqyDliGihPY-1TO8P1QOBRFRMLoeYUVeLF7xVn_K3uLAhbtwWpmWYKoei7Mi1EaQjpWdSI8fn1c2DFjTYVzvvvyrGeptccEMNz-Jq1mwZ84JOR7UOYq0zG5N5Ay72HYO1fL0yKyj5hv1gQQqAKfww8G-bYYnU46XiAt4fmqNbLBEiM',
          icon: Icons.featured_play_list,
          title: 'Featured Slots',
          description: "Get showcased in our 'Weekly Inspirations' email sent to 1.2M active users.",
          price: '\$',
          priceUnit: '/ Week',
        ),
        const SizedBox(height: 24),
        _adSpotCard(
          imageUrl: 'https://lh3.googleusercontent.com/aida-public/AB6AXuDJva_rKhWPoXH5qLx9opzkuvk8essRrZa9IfmVRNl-qaTRrYGEGEZKjZxx3OPb6sA7VebFL6vVbJ2ZYfU-GUGlCRBHNju8IsN041gsHturlDA1D3_clJqd728EsSXv1Ugb845_buh9bn3jqK0mNW4J5FyQDd1lGoBnrbcclNjMff7LX2tKC2nti3GrNkvpBbRVX_bnkdTRl2EFkT8EirQlGCQwUHBU-wHUGX-APcyXRKkvYlGRStfcNlxJFXBn50RcEz8qfxDUf4Y',
          icon: Icons.campaign,
          title: 'Social Push',
          description: 'Exclusive feature on Tripwise Instagram and TikTok partner networks.',
          price: '\$',
          priceUnit: '/ Post',
        ),
      ],
    );
  }

  Widget _adSpotCard({required String imageUrl, required IconData icon, required String title, required String description, required String price, required String priceUnit}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF005F9F).withOpacity(0.06),
            blurRadius: 40,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 192,
            width: double.infinity,
            child: Image.network(imageUrl, fit: BoxFit.cover),
          ),
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(icon, color: const Color(0xFF005F9F), size: 24),
                    const SizedBox(width: 8),
                    Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF181C22))),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  description,
                  style: const TextStyle(fontSize: 14, color: Color(0xFF3F4752), height: 1.5),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text(price, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: Color(0xFF005F9F))),
                        const SizedBox(width: 4),
                        Text(priceUnit.toUpperCase(), style: const TextStyle(fontSize: 10, color: Color(0xFF3F4752))),
                      ],
                    ),
                    ElevatedButton(
                      onPressed: () {},
                      style: TripwiseButtonStyles.surfaceElevated(
                        radius: 24,
                        backgroundColor: TripwiseColors.surfaceContainerHigh,
                        foregroundColor: TripwiseColors.onSurface,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                      ),
                      child: const Text('SELECT', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPromotionReachImpact() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F4FC),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          const Text(
            'Promotion Reach Impact',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF181C22)),
          ),
          const SizedBox(height: 24),
          Container(
            height: 12,
            width: double.infinity,
            decoration: BoxDecoration(
              color: const Color(0xFFD1E4FF),
              borderRadius: BorderRadius.circular(12),
            ),
            child: FractionallySizedBox(
              widthFactor: 0.72,
              alignment: Alignment.centerLeft,
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFAB3500), // bg-secondary
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Column(
                children: const [
                  Text('72%', style: TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: Color(0xFF005F9F))),
                  SizedBox(height: 4),
                  Text('REACH INCREASE', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.5, color: Color(0xFF3F4752))),
                ],
              ),
              const SizedBox(width: 48),
              Column(
                children: const [
                  Text('3.5x', style: TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: Color(0xFF005F9F))),
                  SizedBox(height: 4),
                  Text('BOOKING VELOCITY', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.5, color: Color(0xFF3F4752))),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFab() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24.0, right: 8.0),
      child: FloatingActionButton(
        onPressed: () {},
        child: const Icon(Icons.add_chart, size: 28),
      ),
    );
  }

  Widget _buildBottomNav(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF005F9F).withOpacity(0.08),
            blurRadius: 40,
            offset: const Offset(0, -10),
          ),
        ],
        borderRadius: const BorderRadius.vertical(top: Radius.circular(40)),
      ),
      clipBehavior: Clip.antiAlias,
      child: BottomNavigationBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFF005F9F),
        unselectedItemColor: const Color(0xFF3F4752),
        showUnselectedLabels: true,
        selectedLabelStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500, letterSpacing: 0.5),
        unselectedLabelStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500, letterSpacing: 0.5),
        currentIndex: 2, // VIP Services
        onTap: (index) {
          switch (index) {
            case 0:
              context.go('/provider_dashboard');
              break;
            case 1:
              context.go('/provider_listings');
              break;
            case 2:
              context.go('/vip_services');
              break;
            case 3:
              context.go('/provider_finance');
              break;
          }
        },
        items: [
          const BottomNavigationBarItem(
            icon: Icon(Icons.dashboard_outlined),
            label: 'Dashboard',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.list_alt),
            label: 'Listings',
          ),
          BottomNavigationBarItem(
            icon: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFD1E4FF),
                borderRadius: BorderRadius.circular(24),
              ),
              child: const Icon(Icons.workspace_premium, color: Color(0xFF005F9F)),
            ),
            label: 'VIP Services',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.payments_outlined),
            label: 'Finance',
          ),
        ],
      ),
    );
  }
}
