import 'package:flutter/material.dart';

import '../constants/colors.dart';
import '../models/provider_listing.dart';
import '../services/provider_listings_api.dart';
import '../widgets/shared_taskbars.dart';
import '../widgets/shared_top_bars.dart';

class ProviderAnalyticsScreen extends StatefulWidget {
  const ProviderAnalyticsScreen({super.key, this.listingId, this.listingTitle});

  final String? listingId;
  final String? listingTitle;

  @override
  State<ProviderAnalyticsScreen> createState() =>
      _ProviderAnalyticsScreenState();
}

class _ProviderAnalyticsScreenState extends State<ProviderAnalyticsScreen> {
  final ProviderListingsApi _api = ProviderListingsApi();

  ProviderListingAnalytics? _data;
  bool _isLoading = true;
  String? _error;
  String _period = '30d';

  int? get _listingId => int.tryParse(widget.listingId ?? '');

  static const List<_PeriodOption> _periodOptions = [
    _PeriodOption(value: '7d', label: '7 days'),
    _PeriodOption(value: '30d', label: '30 days'),
    _PeriodOption(value: '90d', label: '90 days'),
    _PeriodOption(value: '1y', label: '1 year'),
  ];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final id = _listingId;
    if (id == null) {
      setState(() {
        _isLoading = false;
        _error = 'Missing listing id.';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final data = await _api.fetchAnalytics(id: id, period: _period);
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
    final data = _data;

    return Scaffold(
      backgroundColor: TripwiseColors.surface,
      appBar: const ProviderAppBar(),
      body: RefreshIndicator(
        onRefresh: _load,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(24),
          child: _isLoading && data == null
              ? const Padding(
                  padding: EdgeInsets.only(top: 120),
                  child: Center(child: CircularProgressIndicator()),
                )
              : _error != null && data == null
              ? _buildErrorState()
              : _buildAnalytics(data!),
        ),
      ),
      bottomNavigationBar: const ProviderTaskbar(
        currentTab: ProviderTaskbarTab.listings,
      ),
    );
  }

  Widget _buildAnalytics(ProviderListingAnalytics data) {
    final trend = data.trend;
    final maxViews = trend.isEmpty
        ? 1
        : trend
              .map((e) => e.views)
              .reduce((a, b) => a > b ? a : b)
              .clamp(1, 1 << 30);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.listingTitle ?? 'Listing Analytics',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Performance by period',
                    style: TextStyle(color: TripwiseColors.onSurfaceVariant),
                  ),
                ],
              ),
            ),
            DropdownButton<String>(
              value: _period,
              underline: const SizedBox.shrink(),
              items: _periodOptions
                  .map(
                    (option) => DropdownMenuItem(
                      value: option.value,
                      child: Text(option.label),
                    ),
                  )
                  .toList(),
              onChanged: (value) {
                if (value != null && value != _period) {
                  setState(() => _period = value);
                  _load();
                }
              },
            ),
          ],
        ),
        const SizedBox(height: 18),
        if (_error != null)
          Container(
            width: double.infinity,
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: TripwiseColors.errorContainer,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              _error!,
              style: const TextStyle(
                color: TripwiseColors.onErrorContainer,
                fontSize: 12,
              ),
            ),
          ),
        Row(
          children: [
            Expanded(
              child: _buildKpiCard(
                title: 'Total Views',
                value: '${data.kpis.totalViews}',
                change: _delta(data.kpis.viewsDeltaPct),
                icon: Icons.visibility,
                positive: data.kpis.viewsDeltaPct >= 0,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildKpiCard(
                title: 'Bookings',
                value: '${data.kpis.bookings}',
                change: _delta(data.kpis.bookingsDeltaPct),
                icon: Icons.calendar_today,
                positive: data.kpis.bookingsDeltaPct >= 0,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _buildKpiCard(
                title: 'Revenue',
                value: '\$${data.kpis.revenue.toStringAsFixed(0)}',
                change: _delta(data.kpis.revenueDeltaPct),
                icon: Icons.trending_up,
                positive: data.kpis.revenueDeltaPct >= 0,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildKpiCard(
                title: 'Avg Rating',
                value: data.kpis.averageRating.toStringAsFixed(1),
                change: _delta(data.kpis.ratingDelta),
                icon: Icons.star,
                positive: data.kpis.ratingDelta >= 0,
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        Text(
          'Performance Trend',
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: TripwiseColors.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(12),
          ),
          child: SizedBox(
            height: 160,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: trend.map((point) {
                final ratio = maxViews == 0 ? 0.0 : point.views / maxViews;
                final barHeight = (ratio * 100).clamp(6, 100).toDouble();
                return Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      '${point.bookings}',
                      style: const TextStyle(fontSize: 10),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      width: 22,
                      height: barHeight,
                      decoration: BoxDecoration(
                        color: TripwiseColors.primary.withOpacity(0.75),
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(8),
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(point.label, style: const TextStyle(fontSize: 11)),
                  ],
                );
              }).toList(),
            ),
          ),
        ),
        const SizedBox(height: 24),
        Text(
          'Top Performing Days',
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900),
        ),
        const SizedBox(height: 10),
        ...data.topDays.map((day) {
          return Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: TripwiseColors.surfaceContainerLow,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      day.day,
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${day.views} views • ${day.bookings} bookings',
                      style: const TextStyle(
                        fontSize: 12,
                        color: TripwiseColors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
                Text(
                  '\$${day.revenue.toStringAsFixed(0)}',
                  style: const TextStyle(
                    color: TripwiseColors.primary,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          );
        }),
        const SizedBox(height: 18),
        Text(
          'Booking Source',
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900),
        ),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: TripwiseColors.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: data.bookingSources
                .map(
                  (source) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _buildSourceItem(source),
                  ),
                )
                .toList(),
          ),
        ),
        const SizedBox(height: 18),
        Text(
          'Guest Statistics',
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _StatCard(
                title: 'Repeat Guests',
                value: '${data.guestStats.repeatGuestsPct}%',
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _StatCard(
                title: 'Avg Stay',
                value:
                    '${data.guestStats.averageStayNights.toStringAsFixed(1)} nights',
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildKpiCard({
    required String title,
    required String value,
    required String change,
    required IconData icon,
    required bool positive,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: TripwiseColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 12,
                  color: TripwiseColors.onSurfaceVariant,
                ),
              ),
              Icon(icon, size: 16, color: TripwiseColors.primary),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: (positive ? Colors.green : Colors.red).withOpacity(0.1),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              change,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: positive ? Colors.green : Colors.red,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSourceItem(ProviderBookingSource source) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              source.label,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            Text(
              '${source.percentage}% (${source.count})',
              style: const TextStyle(color: TripwiseColors.onSurfaceVariant),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: SizedBox(
            height: 8,
            child: LinearProgressIndicator(
              value: source.percentage / 100,
              backgroundColor: TripwiseColors.surfaceContainerHigh,
              valueColor: const AlwaysStoppedAnimation<Color>(
                TripwiseColors.primary,
              ),
            ),
          ),
        ),
      ],
    );
  }

  String _delta(double value) {
    final sign = value >= 0 ? '+' : '';
    return '$sign${value.toStringAsFixed(1)}%';
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.only(top: 120),
        child: Column(
          children: [
            const Icon(Icons.analytics_outlined, size: 48),
            const SizedBox(height: 12),
            Text(
              _error ?? 'Unable to load analytics',
              textAlign: TextAlign.center,
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
}

class _PeriodOption {
  const _PeriodOption({required this.value, required this.label});

  final String value;
  final String label;
}

class _StatCard extends StatelessWidget {
  const _StatCard({required this.title, required this.value});

  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: TripwiseColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: TripwiseColors.onSurfaceVariant,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 20),
          ),
        ],
      ),
    );
  }
}
