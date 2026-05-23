import 'package:flutter/material.dart';
import '../constants/colors.dart';
import '../models/provider_finance.dart';
import '../services/provider_finance_api.dart';
import '../widgets/shared_taskbars.dart';
import '../widgets/shared_top_bars.dart';

class ProviderFinancePayoutScreen extends StatefulWidget {
  const ProviderFinancePayoutScreen({super.key});

  @override
  State<ProviderFinancePayoutScreen> createState() =>
      _ProviderFinancePayoutScreenState();
}

class _ProviderFinancePayoutScreenState
    extends State<ProviderFinancePayoutScreen> {
  static const List<String> _periods = ['Weekly', 'Monthly', 'Yearly'];

  final ProviderFinanceApi _api = ProviderFinanceApi();
  int _selectedPeriod = 1;
  ProviderFinance? _data;
  bool _isLoading = true;
  bool _isRequestingPayout = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadFinance();
  }

  String get _selectedPeriodValue => _periods[_selectedPeriod].toLowerCase();

  Future<void> _loadFinance() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final data = await _api.fetchFinance(period: _selectedPeriodValue);
      if (!mounted) return;
      setState(() {
        _data = data;
        _isLoading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _error = error.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _requestPayout() async {
    if (_isRequestingPayout) return;
    final available = _data?.overview.availableForPayout ?? 0;
    if (available <= 0) {
      _showSnackBar('No balance available for payout.');
      return;
    }
    setState(() => _isRequestingPayout = true);
    try {
      await _api.requestPayout();
      if (!mounted) return;
      _showSnackBar('Payout request submitted.');
      await _loadFinance();
    } catch (error) {
      if (!mounted) return;
      _showSnackBar(error.toString(), isError: true);
    } finally {
      if (mounted) {
        setState(() => _isRequestingPayout = false);
      }
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: isError
              ? TripwiseColors.error
              : TripwiseColors.primary,
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    final data = _data;
    return Scaffold(
      backgroundColor: TripwiseColors.surface,
      appBar: const ProviderAppBar(),
      bottomNavigationBar: const ProviderTaskbar(
        currentTab: ProviderTaskbarTab.finance,
      ),
      body: SafeArea(
        top: false,
        child: RefreshIndicator(
          onRefresh: _loadFinance,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
            children: [
              if (_isLoading && data == null)
                const Padding(
                  padding: EdgeInsets.only(top: 180),
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (_error != null && data == null)
                _FinanceErrorState(message: _error!, onRetry: _loadFinance)
              else if (data != null) ...[
                _PayoutSummaryCard(
                  overview: data.overview,
                  isRequesting: _isRequestingPayout,
                  onRequestPayout: _requestPayout,
                ),
                const SizedBox(height: 18),
                _LifetimeEarningsCard(overview: data.overview),
                const SizedBox(height: 18),
                _EarningsHistoryCard(
                  periods: _periods,
                  selectedPeriod: _selectedPeriod,
                  onPeriodSelected: (index) {
                    setState(() {
                      _selectedPeriod = index;
                    });
                    _loadFinance();
                  },
                  chartBars: data.earningsHistory.bars,
                  peakLabel: data.earningsHistory.peakLabel,
                ),
                const SizedBox(height: 18),
                _RevenueGrowthCard(growth: data.growth),
                const SizedBox(height: 18),
                _RecentTransactionsCard(
                  transactions: data.recentTransactions.items,
                ),
                if (_error != null) ...[
                  const SizedBox(height: 12),
                  _InlineFinanceError(message: _error!, onRetry: _loadFinance),
                ],
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _PayoutSummaryCard extends StatelessWidget {
  const _PayoutSummaryCard({
    required this.overview,
    required this.isRequesting,
    required this.onRequestPayout,
  });

  final ProviderFinanceOverview overview;
  final bool isRequesting;
  final VoidCallback onRequestPayout;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: TripwiseColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: TripwiseColors.primary.withValues(alpha: 0.05),
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
                color: Colors.white.withValues(alpha: 0.58),
                borderRadius: BorderRadius.circular(24),
              ),
            ),
          ),
          Positioned(
            right: 8,
            top: 82,
            child: Icon(
              Icons.crop_square_rounded,
              color: Colors.white.withValues(alpha: 0.65),
              size: 14,
            ),
          ),
          Positioned(
            right: 34,
            top: 38,
            child: Icon(
              Icons.crop_square_rounded,
              color: Colors.white.withValues(alpha: 0.65),
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
                overview.displayAvailableForPayout,
                style: Theme.of(context).textTheme.displayMedium?.copyWith(
                  color: TripwiseColors.primary,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 48,
                child: ElevatedButton.icon(
                  onPressed: isRequesting ? null : onRequestPayout,
                  style: TripwiseButtonStyles.primaryElevated(
                    radius: 24,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                  ),
                  iconAlignment: IconAlignment.end,
                  icon: isRequesting
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: TripwiseColors.onPrimary,
                          ),
                        )
                      : const Icon(Icons.content_copy_rounded, size: 16),
                  label: const Text(
                    'Request Payout',
                    style: TextStyle(fontWeight: FontWeight.w800),
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
  const _LifetimeEarningsCard({required this.overview});

  final ProviderFinanceOverview overview;

  @override
  Widget build(BuildContext context) {
    final netShare = overview.servicesProvided > 0
        ? ((overview.totalLifetimeEarnings / overview.servicesProvided) * 100)
              .clamp(1, 100)
              .round()
        : 1;
    final feeShare = overview.servicesProvided > 0
        ? (100 - netShare).clamp(1, 100).round()
        : 1;

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
            overview.displayTotalLifetimeEarnings,
            style: Theme.of(
              context,
            ).textTheme.displaySmall?.copyWith(fontWeight: FontWeight.w900),
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
                      overview.displayServicesProvided,
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
              children: [
                Expanded(
                  flex: netShare,
                  child: const SizedBox(
                    height: 8,
                    child: DecoratedBox(
                      decoration: BoxDecoration(color: TripwiseColors.primary),
                    ),
                  ),
                ),
                Expanded(
                  flex: feeShare,
                  child: const SizedBox(
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
                      'Service Fees (${overview.serviceFeePercentLabel})',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: TripwiseColors.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      overview.displayServiceFees,
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
                color: Color(0xFFC02A00),
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
    required this.peakLabel,
  });

  final List<String> periods;
  final int selectedPeriod;
  final ValueChanged<int> onPeriodSelected;
  final List<ProviderFinanceBar> chartBars;
  final String peakLabel;

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
                peakLabel,
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
              children: chartBars.map((bar) => _ChartBar(data: bar)).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class _RevenueGrowthCard extends StatelessWidget {
  const _RevenueGrowthCard({required this.growth});

  final ProviderFinanceGrowth growth;

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
            growth.displayPercent,
            style: Theme.of(
              context,
            ).textTheme.displaySmall?.copyWith(fontWeight: FontWeight.w900),
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
            growth.comparisonLabel,
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

  final List<ProviderFinanceTransaction> transactions;

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
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900),
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
                        color: TripwiseColors.onSurfaceVariant.withValues(
                          alpha: 0.65,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Search transactions...',
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(
                                color: TripwiseColors.onSurfaceVariant
                                    .withValues(alpha: 0.7),
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
          if (transactions.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 28),
              child: Center(
                child: Text(
                  'No recent transactions yet.',
                  style: TextStyle(color: TripwiseColors.onSurfaceVariant),
                ),
              ),
            )
          else
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

  final ProviderFinanceTransaction data;

  IconData get _icon {
    switch (data.iconKey) {
      case 'flight':
        return Icons.flight_takeoff_rounded;
      case 'activity':
        return Icons.explore_rounded;
      default:
        return Icons.flag_rounded;
    }
  }

  Color get _statusColor {
    switch (data.statusLabel.toUpperCase()) {
      case 'PAID OUT':
        return const Color(0xFFCFEFD8);
      case 'HELD':
      case 'PENDING':
        return const Color(0xFFFFE8B0);
      case 'CANCELLED':
        return TripwiseColors.errorContainer;
      default:
        return TripwiseColors.surfaceContainerLow;
    }
  }

  Color get _statusTextColor {
    switch (data.statusLabel.toUpperCase()) {
      case 'PAID OUT':
        return const Color(0xFF198754);
      case 'HELD':
      case 'PENDING':
        return const Color(0xFF9C6B00);
      case 'CANCELLED':
        return TripwiseColors.onErrorContainer;
      default:
        return TripwiseColors.onSurfaceVariant;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
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
                child: Icon(_icon, color: TripwiseColors.primary, size: 20),
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
                data.displayAmount,
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Align(
            alignment: Alignment.centerLeft,
            child: Container(
              decoration: BoxDecoration(
                color: _statusColor,
                borderRadius: BorderRadius.circular(14),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              child: Text(
                data.statusLabel,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: _statusTextColor,
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

class _FinanceErrorState extends StatelessWidget {
  const _FinanceErrorState({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 120),
      child: Column(
        children: [
          const Icon(
            Icons.cloud_off_rounded,
            size: 44,
            color: TripwiseColors.onSurfaceVariant,
          ),
          const SizedBox(height: 12),
          const Text(
            "Couldn't load finance",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 8),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(color: TripwiseColors.onSurfaceVariant),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: onRetry,
            style: TripwiseButtonStyles.primaryElevated(radius: 8),
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}

class _InlineFinanceError extends StatelessWidget {
  const _InlineFinanceError({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: TripwiseColors.errorContainer,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.warning_amber_rounded,
            color: TripwiseColors.onErrorContainer,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                color: TripwiseColors.onErrorContainer,
                fontSize: 12,
              ),
            ),
          ),
          TextButton(
            onPressed: onRetry,
            style: TripwiseButtonStyles.text(
              foregroundColor: TripwiseColors.onErrorContainer,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            ),
            child: const Text('Retry'),
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

  final ProviderFinanceBar data;

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
