import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../constants/colors.dart';
import '../widgets/shared_taskbars.dart';
import '../widgets/shared_top_bars.dart';

// Brand palette has no green; matches HTML mock for credit indicator.
const Color _creditGreenBg = Color(0xFFD7F4DD);
const Color _creditGreenFg = Color(0xFF1F8A3A);

void _showWalletFlowNotice(BuildContext context, String message) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
      ),
    );
}

class WalletLoyaltyScreen extends StatefulWidget {
  const WalletLoyaltyScreen({super.key});

  @override
  State<WalletLoyaltyScreen> createState() => _WalletLoyaltyScreenState();
}

class _WalletLoyaltyScreenState extends State<WalletLoyaltyScreen> {
  static const String _avatarUrl =
      'https://lh3.googleusercontent.com/aida-public/AB6AXuALZIBT2-LuMB5fbfNAKWbwU5ZDSc8OAem4TDyVV9OgjZtbsX2d8YpBANmsPQvRppBSRErwIJUrh1hGeFHZ9Lygs6EcXDS1XHfJRcMtzg1aStwe6DM5hanwhG8_ea9NP4UEp8-BoRF5LJxa0woPTcXrz4iGOS90SMJwLrVNFWNkJ-UZpfbwCAItlsRtxD0WEfSGB7ukos5JIw31qIRMjhG4EtF-BxenKP0os3YqvWOepZG42NYGgtHbvw6lENZ84K-qIkAvHqR5Jkg';

  static const String _balance = '\$12,450.80';
  static const String _points = '45,200';
  static const String _pointsValue = '\$452.00';
  static const String _pointsToGold = '4,800';
  static const int _progressFlexCurrent = 75;
  static const int _progressFlexRemaining = 25;

  static final List<_Transaction> _transactions = [
    _Transaction(
      icon: Icons.flight_takeoff_rounded,
      iconBg: TripwiseColors.primaryFixed,
      iconFg: TripwiseColors.primary,
      title: 'Flight to Santorini',
      subtitle: 'Oct 12, 2023 • Aegean Airlines',
      amount: '-\$840.00',
      amountColor: TripwiseColors.onSurface,
      pillText: '+120 pts',
      pillBg: TripwiseColors.primaryFixed,
      pillFg: TripwiseColors.primary,
    ),
    _Transaction(
      icon: Icons.restaurant_rounded,
      iconBg: TripwiseColors.secondaryFixed,
      iconFg: TripwiseColors.secondary,
      title: 'Le Petit Maison',
      subtitle: 'Oct 11, 2023 • Dining',
      amount: '-\$156.40',
      amountColor: TripwiseColors.onSurface,
      pillText: '+15 pts',
      pillBg: TripwiseColors.secondaryFixed,
      pillFg: TripwiseColors.secondary,
    ),
    _Transaction(
      icon: Icons.add_rounded,
      iconBg: _creditGreenBg,
      iconFg: _creditGreenFg,
      title: 'Wallet Top-up',
      subtitle: 'Oct 09, 2023 • Visa **** 4242',
      amount: '+\$2,000.00',
      amountColor: _creditGreenFg,
      pillText: 'Completed',
      pillBg: null,
      pillFg: TripwiseColors.onSurfaceVariant,
    ),
    _Transaction(
      icon: Icons.hotel_rounded,
      iconBg: TripwiseColors.tertiaryFixed,
      iconFg: TripwiseColors.tertiary,
      title: 'Grand Plaza Hotel',
      subtitle: 'Oct 05, 2023 • Accommodation',
      amount: '-\$1,200.00',
      amountColor: TripwiseColors.onSurface,
      pillText: '+400 pts',
      pillBg: TripwiseColors.primaryFixed,
      pillFg: TripwiseColors.primary,
    ),
  ];

  int _currentNavIndex = 3;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TripwiseColors.surface,
      appBar: const PlannerAppBar(),
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _HeaderSection(),
              const SizedBox(height: 24),
              const _PrimaryWalletCard(balance: _balance),
              const SizedBox(height: 24),
              const _LoyaltyPointsCard(
                points: _points,
                pointsValue: _pointsValue,
                pointsToGold: _pointsToGold,
                flexCurrent: _progressFlexCurrent,
                flexRemaining: _progressFlexRemaining,
              ),
              const SizedBox(height: 24),
              _TransactionsSection(transactions: _transactions),
              const SizedBox(height: 24),
              const _CardsSection(),
              const SizedBox(height: 24),
              const _LoyaltyPerkBanner(),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const PlannerTaskbar(
        currentTab: PlannerTaskbarTab.wallet,
      ),
    );
  }

  void _handleBottomNavTap(int index) {
    const routes = [
      '/home',
      '/my_trips',
      '/trip_planner_dashboard',
      '/wallet_loyalty',
      '/profile_registration',
    ];

    if (index == _currentNavIndex) {
      return;
    }

    context.go(routes[index]);
  }
}

class _HeaderSection extends StatelessWidget {
  const _HeaderSection();

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Wallet & Loyalty',
          style: textTheme.displaySmall?.copyWith(
            fontWeight: FontWeight.w900,
            letterSpacing: -0.5,
            height: 1.05,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Manage your travel funds and rewards points in one place.',
          style: textTheme.bodyLarge?.copyWith(
            color: TripwiseColors.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

class _PrimaryWalletCard extends StatelessWidget {
  const _PrimaryWalletCard({required this.balance});

  final String balance;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Container(
      decoration: BoxDecoration(
        color: TripwiseColors.primaryContainer,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: TripwiseColors.primary.withOpacity(0.18),
            blurRadius: 32,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      clipBehavior: Clip.hardEdge,
      child: Stack(
        children: [
          Positioned(
            top: -60,
            right: -60,
            child: Container(
              width: 180,
              height: 180,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.10),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            bottom: -40,
            left: -30,
            child: Container(
              width: 140,
              height: 140,
              decoration: BoxDecoration(
                color: TripwiseColors.secondaryContainer.withOpacity(0.20),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'AVAILABLE BALANCE',
                      style: textTheme.labelMedium?.copyWith(
                        color: Colors.white.withOpacity(0.85),
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.5,
                      ),
                    ),
                    Icon(
                      Icons.account_balance_wallet_rounded,
                      color: Colors.white.withOpacity(0.85),
                      size: 24,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  balance,
                  style: textTheme.displayMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -1.0,
                  ),
                ),
                const SizedBox(height: 32),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    ElevatedButton.icon(
                      onPressed: () => context.push('/add_payment'),
                      style: TripwiseButtonStyles.primaryElevated(
                        radius: 14,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 14,
                        ),
                        textStyle: const TextStyle(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      icon: const Icon(Icons.add_circle_rounded, size: 20),
                      label: const Text('Top-up'),
                    ),
                    OutlinedButton.icon(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Withdrawal flow is not available yet.'),
                          ),
                        );
                      },
                      style: TripwiseButtonStyles.outlined(
                        radius: 14,
                        foregroundColor: Colors.white,
                        backgroundColor: Colors.white.withOpacity(0.10),
                        borderColor: Colors.white.withOpacity(0.30),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 14,
                        ),
                        textStyle: const TextStyle(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      icon: const Icon(Icons.payments_rounded, size: 20),
                      label: const Text('Withdraw'),
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
}

class _LoyaltyPointsCard extends StatelessWidget {
  const _LoyaltyPointsCard({
    required this.points,
    required this.pointsValue,
    required this.pointsToGold,
    required this.flexCurrent,
    required this.flexRemaining,
  });

  final String points;
  final String pointsValue;
  final String pointsToGold;
  final int flexCurrent;
  final int flexRemaining;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Container(
      decoration: BoxDecoration(
        color: TripwiseColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: TripwiseColors.primary.withOpacity(0.06),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'TRIP POINTS',
                style: textTheme.labelMedium?.copyWith(
                  color: TripwiseColors.onSurfaceVariant,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.5,
                ),
              ),
              const Icon(
                Icons.stars_rounded,
                color: TripwiseColors.secondary,
                size: 24,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            points,
            style: textTheme.displaySmall?.copyWith(
              fontWeight: FontWeight.w900,
              letterSpacing: -0.5,
            ),
          ),
          Text(
            '≈ $pointsValue value',
            style: textTheme.bodySmall?.copyWith(
              color: TripwiseColors.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 24),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: SizedBox(
              height: 8,
              child: Row(
                children: [
                  Expanded(
                    flex: flexCurrent,
                    child: Container(color: TripwiseColors.secondary),
                  ),
                  Expanded(
                    flex: flexRemaining,
                    child: Container(
                      color: TripwiseColors.surfaceContainerHigh,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          RichText(
            text: TextSpan(
              style: textTheme.bodySmall?.copyWith(
                color: TripwiseColors.onSurfaceVariant,
              ),
              children: [
                TextSpan(text: '$pointsToGold points away from '),
                const TextSpan(
                  text: 'Gold Tier',
                  style: TextStyle(
                    color: TripwiseColors.primary,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton(
              onPressed: () => _showWalletFlowNotice(
                context,
                'Rewards catalog will be available here soon.',
              ),
              style: TripwiseButtonStyles.text(
                padding: EdgeInsets.zero,
                minimumSize: const Size(0, 0),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Explore Rewards',
                    style: textTheme.labelLarge?.copyWith(
                      color: TripwiseColors.primary,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Icon(
                    Icons.arrow_forward_rounded,
                    size: 18,
                    color: TripwiseColors.primary,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TransactionsSection extends StatelessWidget {
  const _TransactionsSection({required this.transactions});

  final List<_Transaction> transactions;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Recent Transactions',
              style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
            ),
            TextButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Detailed transaction history is not available yet.'),
                  ),
                );
              },
              child: Text(
                'SEE ALL',
                style: textTheme.labelMedium?.copyWith(
                  color: TripwiseColors.primary,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.5,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: TripwiseColors.surfaceContainerLow,
            borderRadius: BorderRadius.circular(20),
          ),
          padding: const EdgeInsets.all(8),
          child: Column(
            children: [
              for (int i = 0; i < transactions.length; i++) ...[
                if (i > 0) const SizedBox(height: 4),
                _TransactionRow(transaction: transactions[i]),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _TransactionRow extends StatelessWidget {
  const _TransactionRow({required this.transaction});

  final _Transaction transaction;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Container(
      decoration: BoxDecoration(
        color: TripwiseColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: transaction.iconBg,
              shape: BoxShape.circle,
            ),
            child: Icon(
              transaction.icon,
              color: transaction.iconFg,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  transaction.title,
                  style: textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  transaction.subtitle,
                  style: textTheme.bodySmall?.copyWith(
                    color: TripwiseColors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                transaction.amount,
                style: textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w900,
                  color: transaction.amountColor,
                ),
              ),
              const SizedBox(height: 4),
              if (transaction.pillBg != null)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: transaction.pillBg,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    transaction.pillText ?? '',
                    style: textTheme.labelSmall?.copyWith(
                      color: transaction.pillFg,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                )
              else
                Text(
                  transaction.pillText ?? '',
                  style: textTheme.labelSmall?.copyWith(
                    color: transaction.pillFg,
                    fontWeight: FontWeight.w600,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CardsSection extends StatelessWidget {
  const _CardsSection();

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Your Cards',
          style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: TripwiseColors.surfaceContainerHigh,
            borderRadius: BorderRadius.circular(20),
          ),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Icon(
                    Icons.credit_card_rounded,
                    color: TripwiseColors.primary,
                    size: 24,
                  ),
                  Text(
                    'VISA',
                    style: textTheme.titleMedium?.copyWith(
                      color: TripwiseColors.onSurfaceVariant,
                      fontWeight: FontWeight.w900,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              Text(
                'Primary Card',
                style: textTheme.bodySmall?.copyWith(
                  color: TripwiseColors.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '**** **** **** 4242',
                style: textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  letterSpacing: 2,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        InkWell(
          onTap: () => context.push('/add_payment'),
          borderRadius: BorderRadius.circular(20),
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(
                color: TripwiseColors.outlineVariant,
                width: 2,
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            padding: const EdgeInsets.symmetric(vertical: 24),
            width: double.infinity,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.add_card_rounded,
                  size: 28,
                  color: TripwiseColors.onSurfaceVariant,
                ),
                const SizedBox(height: 8),
                Text(
                  'Add Payment Method',
                  style: textTheme.labelLarge?.copyWith(
                    color: TripwiseColors.onSurfaceVariant,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _LoyaltyPerkBanner extends StatelessWidget {
  const _LoyaltyPerkBanner();

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            TripwiseColors.secondary,
            TripwiseColors.onSecondaryContainer,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: TripwiseColors.secondary.withOpacity(0.25),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      clipBehavior: Clip.hardEdge,
      child: Stack(
        children: [
          Positioned(
            right: -16,
            bottom: -16,
            child: Icon(
              Icons.loyalty_rounded,
              size: 140,
              color: Colors.white.withOpacity(0.10),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Exclusive Upgrade!',
                  style: textTheme.titleLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Redeem 5,000 points for Premium Lounge access on your next trip.',
                  style: textTheme.bodyMedium?.copyWith(
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => _showWalletFlowNotice(
                    context,
                    'Reward redemption will be available in Wallet soon.',
                  ),
                  style: TripwiseButtonStyles.surfaceElevated(
                    radius: 999,
                    backgroundColor: Colors.white,
                    foregroundColor: TripwiseColors.secondary,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                    textStyle: const TextStyle(
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.5,
                    ),
                  ),
                  child: const Text('CLAIM NOW'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Transaction {
  const _Transaction({
    required this.icon,
    required this.iconBg,
    required this.iconFg,
    required this.title,
    required this.subtitle,
    required this.amount,
    required this.amountColor,
    required this.pillText,
    required this.pillBg,
    required this.pillFg,
  });

  final IconData icon;
  final Color iconBg;
  final Color iconFg;
  final String title;
  final String subtitle;
  final String amount;
  final Color amountColor;
  final String? pillText;
  final Color? pillBg;
  final Color? pillFg;
}
