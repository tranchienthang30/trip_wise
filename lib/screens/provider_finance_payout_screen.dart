import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../constants/colors.dart';

class ProviderFinancePayoutScreen extends StatefulWidget {
  const ProviderFinancePayoutScreen({super.key});

  @override
  State<ProviderFinancePayoutScreen> createState() =>
      _ProviderFinancePayoutScreenState();
}

class _ProviderFinancePayoutScreenState
    extends State<ProviderFinancePayoutScreen> {
  static const List<String> _periods = ['Weekly', 'Monthly', 'Yearly'];

  static const List<_ChartBarData> _chartBars = [
    _ChartBarData(label: 'JAN', heightFactor: 0.34),
    _ChartBarData(label: 'FEB', heightFactor: 0.58),
    _ChartBarData(label: 'MAR', heightFactor: 0.44),
    _ChartBarData(label: 'APR', heightFactor: 0.94, highlighted: true),
    _ChartBarData(label: 'MAY', heightFactor: 0.25),
    _ChartBarData(label: 'JUN', heightFactor: 0.68),
  ];

  static const List<_TransactionData> _transactions = [
    _TransactionData(
      title: 'Booking #TW-9482',
      subtitle: 'Round-trip: Paris to Tokyo Premium',
      date: 'Oct 24, 2023',
      time: '14:20',
      amount: '\$2,450.00',
      status: 'PAID',
      statusColor: Color(0xFFCFEFD8),
      statusTextColor: Color(0xFF198754),
      icon: Icons.flight_takeoff_rounded,
    ),
    _TransactionData(
      title: 'Booking #TW-9480',
      subtitle: '3 Nights: The Ritz-Carlton Kyoto',
      date: 'Oct 23, 2023',
      time: '09:15',
      amount: '\$1,120.00',
      status: 'PENDING',
      statusColor: Color(0xFFFFE8B0),
      statusTextColor: Color(0xFF9C6B00),
      icon: Icons.flag_rounded,
    ),
    _TransactionData(
      title: 'Booking #TW-9478',
      subtitle: 'Private Heli-Tour: Mount Fuji',
      date: 'Oct 21, 2023',
      time: '18:45',
      amount: '\$3,800.00',
      status: 'PAID',
      statusColor: Color(0xFFCFEFD8),
      statusTextColor: Color(0xFF198754),
      icon: Icons.explore_rounded,
    ),
  ];

  int _selectedPeriod = 1;
  int _selectedNavIndex = 3;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TripwiseColors.surface,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leadingWidth: 58,
        leading: Padding(
          padding: const EdgeInsets.only(left: 14, top: 10, bottom: 10),
          child: CircleAvatar(
            backgroundColor: TripwiseColors.primaryFixed,
            backgroundImage: const NetworkImage(
              'https://lh3.googleusercontent.com/aida-public/AB6AXuBaszrIEZvetULMLtB4tGcayxtAiexPhLYVbVFR6IEPCOIXRLJpZzksMaf692woplhhlPAKnn5KaSkQbxtMSMmQF98rKS4m9WFG3pxEmLoHhVr2pRwShaZOIB11tl30K8z6Rrs08ECf0KPACkwUfZv5FJHN3wFJnFAahMaUNVlh1g1F60132JmcIEEPjecY7be3nn6f90BMysvWRRUC5MqdN1O-LypaVFCKjBTUtV0A5CnBBWi-UKvZLOCvb1elu0MgPd-h-dNilNE',
            ),
          ),
        ),
        centerTitle: false,
        title: Text(
          'TRIPWISE PROVIDER',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w900,
              ),
        ),
        actions: [
          IconButton(
            onPressed: () => context.go('/trip_planner_dashboard'),
            icon: const Icon(Icons.swap_horiz_rounded),
            color: TripwiseColors.primary,
            tooltip: 'Back to Planner',
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.notifications_none_rounded),
            color: TripwiseColors.onSurface,
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedNavIndex,
        selectedItemColor: TripwiseColors.primary,
        unselectedItemColor: TripwiseColors.onSurfaceVariant.withOpacity(0.72),
        selectedFontSize: 11,
        unselectedFontSize: 11,
        onTap: (index) {
          setState(() {
            _selectedNavIndex = index;
          });
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
            icon: Icon(Icons.dashboard_customize_rounded),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.grid_view_rounded),
            label: 'Listings',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.receipt_long_rounded),
            label: 'Orders',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_balance_wallet_rounded),
            label: 'Finance',
          ),
        ],
      ),
      body: SafeArea(
        top: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
          children: [
            _PayoutSummaryCard(),
            const SizedBox(height: 18),
            _LifetimeEarningsCard(),
            const SizedBox(height: 18),
            _EarningsHistoryCard(
              periods: _periods,
              selectedPeriod: _selectedPeriod,
              onPeriodSelected: (index) {
                setState(() {
                  _selectedPeriod = index;
                });
              },
              chartBars: _chartBars,
            ),
            const SizedBox(height: 18),
            const _RevenueGrowthCard(),
            const SizedBox(height: 18),
            _RecentTransactionsCard(transactions: _transactions),
          ],
        ),
      ),
    );
  }
}

class _PayoutSummaryCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: TripwiseColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: TripwiseColors.primary.withOpacity(0.05),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Stack(
        children: [
          Positioned(
            right: -6,
            top: 34,
            child: Container(
              width: 120,
              height: 80,
              decoration: BoxDecoration(
                color: TripwiseColors.surfaceContainerLow,
                borderRadius: BorderRadius.circular(24),
              ),
            ),
          ),
          Positioned(
            right: 20,
            top: 48,
            child: Container(
              width: 70,
              height: 48,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.58),
                borderRadius: BorderRadius.circular(24),
              ),
            ),
          ),
          Positioned(
            right: 8,
            top: 82,
            child: Icon(
              Icons.crop_square_rounded,
              color: Colors.white.withOpacity(0.65),
              size: 14,
            ),
          ),
          Positioned(
            right: 34,
            top: 38,
            child: Icon(
              Icons.crop_square_rounded,
              color: Colors.white.withOpacity(0.65),
              size: 14,
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Available for Payout',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: TripwiseColors.onSurface,
                    ),
              ),
              const SizedBox(height: 6),
              Text(
                '\$12,480.00',
                style: Theme.of(context).textTheme.displayMedium?.copyWith(
                      color: TripwiseColors.primary,
                      fontWeight: FontWeight.w900,
                    ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 48,
                child: ElevatedButton.icon(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: TripwiseColors.secondaryContainer,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    elevation: 0,
                  ),
                  iconAlignment: IconAlignment.end,
                  icon: const Icon(Icons.content_copy_rounded, size: 16),
                  label: const Text(
                    'Request Payout',
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Padding(
                padding: const EdgeInsets.only(left: 18),
                child: Text(
                  'View Payout Schedule',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: TripwiseColors.primary,
                        fontWeight: FontWeight.w700,
                      ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _LifetimeEarningsCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5FF),
        borderRadius: BorderRadius.circular(28),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'TOTAL LIFETIME EARNINGS',
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: TripwiseColors.onSurfaceVariant,
                  letterSpacing: 2.2,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            '\$142,900.50',
            style: Theme.of(context).textTheme.displaySmall?.copyWith(
                  fontWeight: FontWeight.w900,
                ),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Services Provided',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: TripwiseColors.onSurfaceVariant,
                          ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '\$156,200.00',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.flag_rounded,
                color: TripwiseColors.primary,
                size: 20,
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Row(
              children: const [
                Expanded(
                  flex: 84,
                  child: SizedBox(
                    height: 8,
                    child: DecoratedBox(
                      decoration: BoxDecoration(color: TripwiseColors.primary),
                    ),
                  ),
                ),
                Expanded(
                  flex: 16,
                  child: SizedBox(
                    height: 8,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: TripwiseColors.secondaryContainer,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Service Fees (8%)',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: TripwiseColors.onSurfaceVariant,
                          ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '-\$13,299.50',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: const Color(0xFFC02A00),
                            fontWeight: FontWeight.w800,
                          ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.percent_rounded,
                color: const Color(0xFFC02A00),
                size: 22,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _EarningsHistoryCard extends StatelessWidget {
  const _EarningsHistoryCard({
    required this.periods,
    required this.selectedPeriod,
    required this.onPeriodSelected,
    required this.chartBars,
  });

  final List<String> periods;
  final int selectedPeriod;
  final ValueChanged<int> onPeriodSelected;
  final List<_ChartBarData> chartBars;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: TripwiseColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(28),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  'Earnings\nHistory',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w900,
                        height: 1.1,
                      ),
                ),
              ),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: List.generate(
                  periods.length,
                  (index) => _SegmentChip(
                    label: periods[index],
                    isSelected: index == selectedPeriod,
                    onTap: () => onPeriodSelected(index),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Center(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: Text(
                '\$5.2k',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                    ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 142,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: chartBars
                  .map(
                    (bar) => _ChartBar(data: bar),
                  )
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class _RevenueGrowthCard extends StatelessWidget {
  const _RevenueGrowthCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5FF),
        borderRadius: BorderRadius.circular(28),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 22),
      child: Column(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: const BoxDecoration(
              color: Color(0xFFD9E8FF),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.trending_up_rounded,
              color: TripwiseColors.primary,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            '14.2%',
            style: Theme.of(context).textTheme.displaySmall?.copyWith(
                  fontWeight: FontWeight.w900,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            'Revenue Growth',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: TripwiseColors.onSurfaceVariant,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            '+2.4% from last month',
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: TripwiseColors.primary,
                  fontWeight: FontWeight.w700,
                ),
          ),
        ],
      ),
    );
  }
}

class _RecentTransactionsCard extends StatelessWidget {
  const _RecentTransactionsCard({required this.transactions});

  final List<_TransactionData> transactions;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: TripwiseColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(28),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Recent Transactions',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w900,
                ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: TripwiseColors.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 12,
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.search_rounded,
                        size: 18,
                        color: TripwiseColors.onSurfaceVariant.withOpacity(0.65),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Search transactions...',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: TripwiseColors.onSurfaceVariant
                                    .withOpacity(0.7),
                              ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: TripwiseColors.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: const Icon(Icons.tune_rounded, size: 18),
              ),
            ],
          ),
          const SizedBox(height: 18),
          ...transactions.map(
            (transaction) => Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: _TransactionCard(data: transaction),
            ),
          ),
          const SizedBox(height: 6),
          Center(
            child: TextButton(
              onPressed: () {},
              child: const Text(
                'View all transactions',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TransactionCard extends StatelessWidget {
  const _TransactionCard({required this.data});

  final _TransactionData data;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 14,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: const BoxDecoration(
                  color: Color(0xFFE5F0FF),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  data.icon,
                  color: TripwiseColors.primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      data.title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      data.subtitle,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: TripwiseColors.onSurfaceVariant,
                            height: 1.35,
                          ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Text(
                '${data.date} • ${data.time}',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: TripwiseColors.onSurface,
                    ),
              ),
              const Spacer(),
              Text(
                data.amount,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Align(
            alignment: Alignment.centerLeft,
            child: Container(
              decoration: BoxDecoration(
                color: data.statusColor,
                borderRadius: BorderRadius.circular(14),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              child: Text(
                data.status,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: data.statusTextColor,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.8,
                    ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SegmentChip extends StatelessWidget {
  const _SegmentChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Ink(
          decoration: BoxDecoration(
            color: isSelected
                ? TripwiseColors.primary
                : TripwiseColors.surfaceContainerLow,
            borderRadius: BorderRadius.circular(14),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
          child: Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: isSelected ? Colors.white : TripwiseColors.onSurface,
                  fontWeight: FontWeight.w700,
                ),
          ),
        ),
      ),
    );
  }
}

class _ChartBar extends StatelessWidget {
  const _ChartBar({required this.data});

  final _ChartBarData data;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 30,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Container(
            height: 98 * data.heightFactor + 10,
            decoration: BoxDecoration(
              color: data.highlighted
                  ? TripwiseColors.primary
                  : const Color(0xFFE9EEF8),
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            data.label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: TripwiseColors.onSurfaceVariant,
                  fontWeight: data.highlighted ? FontWeight.w800 : FontWeight.w600,
                ),
          ),
        ],
      ),
    );
  }
}

class _ChartBarData {
  const _ChartBarData({
    required this.label,
    required this.heightFactor,
    this.highlighted = false,
  });

  final String label;
  final double heightFactor;
  final bool highlighted;
}

class _TransactionData {
  const _TransactionData({
    required this.title,
    required this.subtitle,
    required this.date,
    required this.time,
    required this.amount,
    required this.status,
    required this.statusColor,
    required this.statusTextColor,
    required this.icon,
  });

  final String title;
  final String subtitle;
  final String date;
  final String time;
  final String amount;
  final String status;
  final Color statusColor;
  final Color statusTextColor;
  final IconData icon;
}
