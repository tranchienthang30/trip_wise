import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ProviderDashboardScreen extends StatelessWidget {
  const ProviderDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FF),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF8F9FF).withOpacity(0.9),
        elevation: 0,
        scrolledUnderElevation: 0,
        titleSpacing: 24,
        title: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFFD1E4FF), width: 2),
                image: const DecorationImage(
                  image: NetworkImage(
                      'https://lh3.googleusercontent.com/aida-public/AB6AXuDUvf8uuK4F3LArKzVHGi4IFD-nhEZGzVjlexLUPeABs04M6yguIdknSYKfaDF-RW5UWMmLb919NX4Ny_pL0L03-0uFS1ytHE4JgG3uDEJ8LFUlzIT6N9STaRkFnTBtZOytTChv5LHFkcGpZtlQq8blB2a5g0BPnhdwHy9WDFyNpO-alAbroUki6iUD61g1C-PWNfM4jUtbO_GQCA78pRCG0nAV8abXI6enryYAQ5PQmyeFMSU_A-1zo17kGpNThVHxGFeHiVzu6J0'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(width: 12),
            const Text(
              'Tripwise Business',
              style: TextStyle(
                color: Color(0xFF005F9F),
                fontSize: 20,
                fontWeight: FontWeight.bold,
                letterSpacing: -0.5,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.swap_horiz_rounded,
              color: Color(0xFF005F9F),
            ),
            tooltip: 'Back to Planner',
            onPressed: () => context.go('/trip_planner_dashboard'),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: IconButton(
              icon: const Icon(Icons.notifications, color: Color(0xFF005F9F)),
              onPressed: () {},
            ),
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 100),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'GOOD MORNING, JAMES',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Color(0xFF3F4752),
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Overview',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.w800,
                color: Color(0xFF181C22),
                letterSpacing: -1.0,
              ),
            ),
            const SizedBox(height: 24),
            _buildRevenueCard(),
            const SizedBox(height: 24),
            // In Flutter, we'll stack "Add New Listing" and "Order Status" side-by-side on desktop, or down on mobile
            // We'll stack them vertically for mobile flow as per typical flutter views
            _buildQuickActionCard(context),
            const SizedBox(height: 24),
            _buildOrderStatusCard(context),
            const SizedBox(height: 32),
            _buildRecentActivityHeader(),
            const SizedBox(height: 16),
            _buildActivityList(),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNav(context),
    );
  }

  Widget _buildRevenueCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF005F9F).withOpacity(0.04),
            blurRadius: 40,
            offset: const Offset(0, 10),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'Total Revenue',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Color(0xFF3F4752)),
                  ),
                  SizedBox(height: 4),
                  Text(
                    '\,850.00',
                    style: TextStyle(fontSize: 36, fontWeight: FontWeight.w800, color: Color(0xFF181C22)),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFD1E4FF),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  '+12.5% this month',
                  style: TextStyle(color: Color(0xFF00497C), fontSize: 12, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'MONTH-TO-DATE',
                      style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, letterSpacing: 1.5, color: Color(0xFF3F4752)),
                    ),
                    SizedBox(height: 4),
                    Text(
                      '\,240.00',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF181C22)),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'PAYOUTS PENDING',
                      style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, letterSpacing: 1.5, color: Color(0xFF3F4752)),
                    ),
                    SizedBox(height: 4),
                    Text(
                      '\,150.00',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF181C22)),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),
          // Simplified Sparkline
          SizedBox(
            height: 80,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                _bar(40, false), _bar(55, false), _bar(45, false), _bar(70, false),
                _bar(60, false), _bar(85, false), _bar(100, false), _bar(75, false),
                _bar(90, false), _bar(65, false), _bar(80, false), _bar(95, true),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _bar(double percent, bool isLast) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 2),
        height: 80 * (percent / 100),
        decoration: BoxDecoration(
          color: isLast ? const Color(0xFF005F9F) : const Color(0xFFD1E4FF).withOpacity(0.3),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(2)),
        ),
      ),
    );
  }

  Widget _buildQuickActionCard(BuildContext context) {
    return InkWell(
      onTap: () => context.push('/add_new_listing_form'),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: const Color(0xFFFF5E1F),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Icon(Icons.add_circle, color: Colors.white, size: 40),
            SizedBox(height: 12),
            Text(
              'Add New Listing',
              style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 4),
            Text(
              'Scale your business by adding new destinations.',
              style: TextStyle(color: Colors.white70, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderStatusCard(BuildContext context) {
    return InkWell(
      onTap: () => context.push('/order_manager'),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: const Color(0xFFF0F4FC),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'ORDER STATUS',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.5, color: Color(0xFF3F4752)),
            ),
            const SizedBox(height: 16),
            _orderStatusRow('Pending', '04', Icons.pending, const Color(0xFFAB3500)),
            const SizedBox(height: 12),
            _orderStatusRow('Confirmed', '12', Icons.check_circle, const Color(0xFF005F9F), isPrimary: true),
            const SizedBox(height: 12),
            _orderStatusRow('Completed', '89', Icons.task_alt, const Color(0xFF3F4752)),
          ],
        ),
      ),
    );
  }

  Widget _orderStatusRow(String label, String count, IconData icon, Color iconColor, {bool isPrimary = false}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: isPrimary ? const Border(left: BorderSide(color: Color(0xFF005F9F), width: 4)) : null,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(icon, color: iconColor, size: 24),
              const SizedBox(width: 12),
              Text(label, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 16)),
            ],
          ),
          Text(count, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Color(0xFF181C22))),
        ],
      ),
    );
  }

  Widget _buildRecentActivityHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'Recent Activity',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF181C22), letterSpacing: -0.5),
        ),
        TextButton(
          onPressed: () {},
          style: TextButton.styleFrom(
            foregroundColor: const Color(0xFF005F9F),
          ),
          child: const Text('View All Notifications', style: TextStyle(fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }

  Widget _buildActivityList() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF0F4FC),
        borderRadius: BorderRadius.circular(16),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          _buildActivityItem(
            icon: Icons.hotel,
            iconColor: const Color(0xFF005F9F),
            iconBg: const Color(0xFFD1E4FF),
            title: 'New booking for Azure Horizon Bay',
            subtitle: 'Customer: Elena Gilbert � 4 nights',
            time: '2 MINS AGO',
            amount: '+\$',
            amountColor: const Color(0xFF005F9F),
          ),
          Divider(color: const Color(0xFFBFC7D4).withOpacity(0.3), height: 1),
          _buildActivityItem(
            icon: Icons.reviews,
            iconColor: const Color(0xFFAB3500),
            iconBg: const Color(0xFFFFDBD0),
            title: 'New 5-star review received',
            subtitle: '"Incredible service and stunning views..."',
            time: '1 HOUR AGO',
          ),
          Divider(color: const Color(0xFFBFC7D4).withOpacity(0.3), height: 1),
          _buildActivityItem(
            icon: Icons.account_balance_wallet,
            iconColor: const Color(0xFF005F9D),
            iconBg: const Color(0xFFD0E4FF),
            title: 'Payout Processed',
            subtitle: 'Funds transferred to bank account ending 4492',
            time: '3 HOURS AGO',
            amount: '-\,400',
            amountColor: const Color(0xFF181C22),
          ),
        ],
      ),
    );
  }

  Widget _buildActivityItem({
    required IconData icon,
    required Color iconColor,
    required Color iconBg,
    required String title,
    required String subtitle,
    required String time,
    String? amount,
    Color? amountColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      color: Colors.white,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: iconColor),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16, color: Color(0xFF181C22)),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(fontSize: 14, color: Color(0xFF3F4752)),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                time,
                style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF3F4752), letterSpacing: -0.5),
              ),
              if (amount != null) ...[
                const SizedBox(height: 4),
                Text(
                  amount,
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: amountColor),
                ),
              ]
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNav(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
      ),
      child: BottomNavigationBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        type: BottomNavigationBarType.fixed,
        currentIndex: 0,
        selectedItemColor: const Color(0xFFFF5E1F),
        unselectedItemColor: const Color(0xFF3F4752).withOpacity(0.7),
        showUnselectedLabels: true,
        selectedLabelStyle: const TextStyle(fontSize: 10, fontWeight: FontWeight.w500, letterSpacing: 0.5),
        unselectedLabelStyle: const TextStyle(fontSize: 10, fontWeight: FontWeight.w500, letterSpacing: 0.5),
        onTap: (index) {
          switch (index) {
            case 0:
              context.go('/provider_dashboard');
              break;
            case 1:
              context.go('/provider_listings');
              break;
            case 2:
              context.go('/order_manager');
              break;
            case 3:
              context.go('/provider_finance');
              break;
          }
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'DASHBOARD',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.inventory_2),
            label: 'LISTINGS',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.receipt_long),
            label: 'ORDERS',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.payments),
            label: 'FINANCE',
          ),
        ],
      ),
    );
  }
}
