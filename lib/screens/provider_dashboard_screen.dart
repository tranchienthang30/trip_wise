import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../constants/colors.dart';
import '../models/provider_dashboard.dart';
import '../services/provider_dashboard_api.dart';
import '../widgets/shared_taskbars.dart';
import '../widgets/shared_top_bars.dart';

class ProviderDashboardScreen extends StatefulWidget {
  const ProviderDashboardScreen({super.key});

  @override
  State<ProviderDashboardScreen> createState() =>
      _ProviderDashboardScreenState();
}

class _ProviderDashboardScreenState extends State<ProviderDashboardScreen> {
  final ProviderDashboardApi _api = ProviderDashboardApi();

  ProviderDashboardData? _data;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final data = await _api.fetchDashboard();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TripwiseColors.surface,
      appBar: const ProviderAppBar(),
      body: RefreshIndicator(
        onRefresh: _load,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 100),
          child: _buildBody(context),
        ),
      ),
      bottomNavigationBar: const ProviderTaskbar(
        currentTab: ProviderTaskbarTab.dashboard,
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    final data = _data;

    if (_isLoading && data == null) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.only(top: 140),
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_error != null && data == null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.only(top: 120),
          child: Column(
            children: [
              const Icon(Icons.cloud_off_rounded, size: 48),
              const SizedBox(height: 12),
              const Text(
                "Couldn't load dashboard",
                style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18),
              ),
              const SizedBox(height: 8),
              Text(
                _error!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: TripwiseColors.onSurfaceVariant),
              ),
              const SizedBox(height: 14),
              ElevatedButton(
                onPressed: _load,
                style: TripwiseButtonStyles.primaryElevated(radius: 12),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    final safe = data!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'GOOD DAY, ${safe.greeting.providerName.toUpperCase()}',
          style: const TextStyle(
            fontSize: 12,
            color: TripwiseColors.onSurfaceVariant,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.6,
          ),
        ),
        const SizedBox(height: 6),
        const Text(
          'Overview',
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.w900,
            color: TripwiseColors.onSurface,
          ),
        ),
        const SizedBox(height: 20),
        _buildRevenueCard(safe.revenue),
        const SizedBox(height: 16),
        _buildQuickActions(context, safe.orderStatus),
        const SizedBox(height: 24),
        Row(
          children: [
            const Text(
              'Recent Activity',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
            ),
            const Spacer(),
            if (_isLoading)
              const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            else
              TextButton(
                onPressed: _load,
                style: TripwiseButtonStyles.text(),
                child: const Text('Refresh'),
              ),
          ],
        ),
        if (_error != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: TripwiseColors.errorContainer,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                _error!,
                style: const TextStyle(
                  color: TripwiseColors.onErrorContainer,
                  fontSize: 12,
                ),
              ),
            ),
          ),
        _buildActivityList(safe.recentActivities),
      ],
    );
  }

  Widget _buildRevenueCard(ProviderRevenue revenue) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: TripwiseColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: TripwiseColors.primary.withOpacity(0.06),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Total Revenue',
                      style: TextStyle(
                        fontSize: 14,
                        color: TripwiseColors.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      revenue.totalRevenueLabel,
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w900,
                        color: TripwiseColors.onSurface,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: TripwiseColors.primaryFixed,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  revenue.deltaLabel,
                  style: const TextStyle(
                    color: TripwiseColors.onPrimaryFixedVariant,
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _MetricMini(
                  label: 'MONTH-TO-DATE',
                  value: revenue.monthToDateLabel,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _MetricMini(
                  label: 'PAYOUTS PENDING',
                  value: revenue.payoutsPendingLabel,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context, ProviderOrderStatus status) {
    return Column(
      children: [
        InkWell(
          onTap: () => context.push('/add_new_listing_form'),
          borderRadius: BorderRadius.circular(14),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: TripwiseColors.secondaryContainer,
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Row(
              children: [
                Icon(Icons.add_business, color: Colors.white, size: 28),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Add New Listing',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                Icon(Icons.chevron_right, color: Colors.white),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        InkWell(
          onTap: () => context.push('/order_manager'),
          borderRadius: BorderRadius.circular(14),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: TripwiseColors.surfaceContainerLow,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'ORDER STATUS',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: TripwiseColors.onSurfaceVariant,
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 12),
                _StatusRow(label: 'Pending', count: status.pending),
                const SizedBox(height: 8),
                _StatusRow(label: 'Confirmed', count: status.confirmed),
                const SizedBox(height: 8),
                _StatusRow(label: 'Completed', count: status.completed),
                const SizedBox(height: 8),
                _StatusRow(label: 'Cancelled', count: status.cancelled),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActivityList(List<ProviderActivityItem> activities) {
    if (activities.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: TripwiseColors.surfaceContainerLow,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Text(
          'No activity yet.',
          style: TextStyle(color: TripwiseColors.onSurfaceVariant),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: TripwiseColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: activities.asMap().entries.map((entry) {
          final index = entry.key;
          final item = entry.value;
          return Column(
            children: [
              ListTile(
                leading: _ActivityIcon(type: item.type, tone: item.amountTone),
                title: Text(
                  item.title,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                subtitle: Text(
                  '${item.subtitle}\n${item.timeLabel}',
                  style: const TextStyle(fontSize: 12),
                ),
                trailing: item.amountLabel == null
                    ? null
                    : Text(
                        item.amountLabel!,
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          color: _amountColor(item.amountTone),
                        ),
                      ),
                isThreeLine: true,
              ),
              if (index < activities.length - 1)
                const Divider(height: 1, color: TripwiseColors.outlineVariant),
            ],
          );
        }).toList(),
      ),
    );
  }

  Color _amountColor(String tone) {
    if (tone == 'negative') return TripwiseColors.error;
    if (tone == 'positive') return TripwiseColors.primary;
    return TripwiseColors.onSurfaceVariant;
  }
}

class _MetricMini extends StatelessWidget {
  const _MetricMini({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 10,
            color: TripwiseColors.onSurfaceVariant,
            letterSpacing: 0.8,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: TripwiseColors.onSurface,
          ),
        ),
      ],
    );
  }
}

class _StatusRow extends StatelessWidget {
  const _StatusRow({required this.label, required this.count});

  final String label;
  final int count;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: TripwiseColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
          Text(
            '$count',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: TripwiseColors.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}

class _ActivityIcon extends StatelessWidget {
  const _ActivityIcon({required this.type, required this.tone});

  final String type;
  final String tone;

  @override
  Widget build(BuildContext context) {
    IconData icon;
    if (type == 'payout') {
      icon = Icons.account_balance_wallet_outlined;
    } else if (type == 'review') {
      icon = Icons.reviews_outlined;
    } else if (type == 'booking') {
      icon = Icons.calendar_today_outlined;
    } else {
      icon = Icons.notifications_outlined;
    }

    Color color;
    if (tone == 'negative') {
      color = TripwiseColors.error;
    } else if (tone == 'positive') {
      color = TripwiseColors.primary;
    } else {
      color = TripwiseColors.onSurfaceVariant;
    }

    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(icon, color: color),
    );
  }
}
