import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../constants/colors.dart';
import '../models/wallet_overview.dart';
import '../services/wallet_api.dart';
import '../utils/currency.dart';
import '../widgets/shared_taskbars.dart';
import '../widgets/shared_top_bars.dart';

// Brand palette has no green; matches HTML mock for the success indicator.
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

String _titleCase(String value) {
  if (value.isEmpty) return value;
  return value[0].toUpperCase() + value.substring(1).toLowerCase();
}

class WalletLoyaltyScreen extends StatefulWidget {
  const WalletLoyaltyScreen({super.key});

  @override
  State<WalletLoyaltyScreen> createState() => _WalletLoyaltyScreenState();
}

class _WalletLoyaltyScreenState extends State<WalletLoyaltyScreen> {
  final WalletApi _api = WalletApi();
  late Future<WalletOverview> _future;

  @override
  void initState() {
    super.initState();
    _future = _api.fetchWallet();
  }

  void _reload() {
    setState(() {
      _future = _api.fetchWallet();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TripwiseColors.surface,
      appBar: const PlannerAppBar(),
      body: SafeArea(
        top: false,
        child: FutureBuilder<WalletOverview>(
          future: _future,
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError || !snapshot.hasData) {
              return _ErrorView(
                error: snapshot.error,
                onRetry: _reload,
              );
            }
            return _WalletBody(data: snapshot.data!);
          },
        ),
      ),
      bottomNavigationBar: const PlannerTaskbar(
        currentTab: PlannerTaskbarTab.wallet,
      ),
    );
  }
}

class _WalletBody extends StatelessWidget {
  const _WalletBody({required this.data});

  final WalletOverview data;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _HeaderSection(userName: data.user?.name),
          const SizedBox(height: 24),
          _PrimaryWalletCard(balance: formatVnd(data.balance)),
          const SizedBox(height: 24),
          _LoyaltyPointsCard(
            points: data.loyaltyPoints,
            pointsValueVnd: data.pointsValueVnd,
            tier: data.tier,
          ),
          const SizedBox(height: 24),
          _TransactionsSection(transactions: data.transactions),
        ],
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.error, required this.onRetry});

  final Object? error;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.cloud_off_rounded,
              size: 48,
              color: TripwiseColors.onSurfaceVariant,
            ),
            const SizedBox(height: 16),
            Text(
              "Couldn't load your wallet",
              style: textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              error?.toString() ?? 'Unknown error',
              textAlign: TextAlign.center,
              style: textTheme.bodySmall?.copyWith(
                color: TripwiseColors.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: onRetry,
              child: const Text('Try again'),
            ),
          ],
        ),
      ),
    );
  }
}

class _HeaderSection extends StatelessWidget {
  const _HeaderSection({this.userName});

  final String? userName;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (userName != null && userName!.isNotEmpty) ...[
          Text(
            'Hi, $userName 👋',
            style: textTheme.labelLarge?.copyWith(
              color: TripwiseColors.primary,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 4),
        ],
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
                            content:
                                Text('Withdrawal flow is not available yet.'),
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
    required this.pointsValueVnd,
    required this.tier,
  });

  final int points;
  final double pointsValueVnd;
  final WalletTier tier;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final progress = tier.progress; // already clamped to 0..1 in the model
    final hasNext = tier.next != null;
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
                'TRIP POINTS · ${tier.current}',
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
            formatInt(points),
            style: textTheme.displaySmall?.copyWith(
              fontWeight: FontWeight.w900,
              letterSpacing: -0.5,
            ),
          ),
          Text(
            '≈ ${formatVnd(pointsValueVnd)} value',
            style: textTheme.bodySmall?.copyWith(
              color: TripwiseColors.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 24),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: SizedBox(
              height: 8,
              child: Stack(
                children: [
                  Container(color: TripwiseColors.surfaceContainerHigh),
                  FractionallySizedBox(
                    widthFactor: progress == 0 ? 0.001 : progress,
                    child: Container(color: TripwiseColors.secondary),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          if (hasNext && tier.pointsToNext != null)
            RichText(
              text: TextSpan(
                style: textTheme.bodySmall?.copyWith(
                  color: TripwiseColors.onSurfaceVariant,
                ),
                children: [
                  TextSpan(
                    text: '${formatInt(tier.pointsToNext!)} points away from ',
                  ),
                  TextSpan(
                    text: '${_titleCase(tier.next!)} Tier',
                    style: const TextStyle(
                      color: TripwiseColors.primary,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            )
          else
            Text(
              "You're at our top tier — enjoy the perks!",
              style: textTheme.bodySmall?.copyWith(
                color: TripwiseColors.onSurfaceVariant,
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

  final List<WalletTransaction> transactions;

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
              style:
                  textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
            ),
            TextButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                        'Detailed transaction history is not available yet.'),
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
          child: transactions.isEmpty
              ? Padding(
                  padding: const EdgeInsets.symmetric(vertical: 28),
                  child: Center(
                    child: Text(
                      'No transactions yet.',
                      style: textTheme.bodyMedium?.copyWith(
                        color: TripwiseColors.onSurfaceVariant,
                      ),
                    ),
                  ),
                )
              : Column(
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

  final WalletTransaction transaction;

  ({IconData icon, Color bg, Color fg}) _methodVisual() {
    switch (transaction.method) {
      case 'VNPAY':
      case 'CREDIT_CARD':
        return (
          icon: Icons.credit_card_rounded,
          bg: TripwiseColors.primaryFixed,
          fg: TripwiseColors.primary,
        );
      case 'MOMO':
        return (
          icon: Icons.account_balance_wallet_rounded,
          bg: TripwiseColors.tertiaryFixed,
          fg: TripwiseColors.tertiary,
        );
      case 'WALLET':
        return (
          icon: Icons.account_balance_wallet_rounded,
          bg: TripwiseColors.secondaryFixed,
          fg: TripwiseColors.secondary,
        );
      case 'PAYLATER':
        return (
          icon: Icons.schedule_rounded,
          bg: TripwiseColors.secondaryFixed,
          fg: TripwiseColors.secondary,
        );
      default:
        return (
          icon: Icons.receipt_long_rounded,
          bg: TripwiseColors.surfaceContainerHigh,
          fg: TripwiseColors.onSurfaceVariant,
        );
    }
  }

  ({String label, Color? bg, Color fg}) _statusVisual() {
    switch (transaction.status) {
      case 'SUCCESS':
        return (label: 'Completed', bg: _creditGreenBg, fg: _creditGreenFg);
      case 'PENDING':
        return (
          label: 'Pending',
          bg: TripwiseColors.secondaryFixed,
          fg: TripwiseColors.secondary,
        );
      case 'FAILED':
        return (
          label: 'Failed',
          bg: TripwiseColors.errorContainer,
          fg: TripwiseColors.error,
        );
      default:
        return (
          label: transaction.status,
          bg: null,
          fg: TripwiseColors.onSurfaceVariant,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final visual = _methodVisual();
    final status = _statusVisual();
    final sign = transaction.amountVnd < 0 ? '-' : '+';
    final amountText = '$sign${formatVnd(transaction.amountVnd.abs())}';
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
              color: visual.bg,
              shape: BoxShape.circle,
            ),
            child: Icon(visual.icon, color: visual.fg, size: 22),
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
                amountText,
                style: textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w900,
                  color: TripwiseColors.onSurface,
                ),
              ),
              const SizedBox(height: 4),
              if (status.bg != null)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: status.bg,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    status.label,
                    style: textTheme.labelSmall?.copyWith(
                      color: status.fg,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                )
              else
                Text(
                  status.label,
                  style: textTheme.labelSmall?.copyWith(
                    color: status.fg,
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
