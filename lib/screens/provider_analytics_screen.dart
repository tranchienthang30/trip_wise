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
          padding: TripwiseInsets.screen,
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
                icon: Icons.visibility_rounded,
                positive: data.kpis.viewsDeltaPct >= 0,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildKpiCard(
                title: 'Bookings',
                value: '${data.kpis.bookings}',
                change: _delta(data.kpis.bookingsDeltaPct),
                icon: Icons.calendar_today_rounded,
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
                icon: Icons.trending_up_rounded,
                positive: data.kpis.revenueDeltaPct >= 0,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildKpiCard(
                title: 'Avg Rating',
                value: data.kpis.averageRating.toStringAsFixed(1),
                change: _delta(data.kpis.ratingDelta),
                icon: Icons.star_rounded,
                positive: data.kpis.ratingDelta >= 0,
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
          BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 10),
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
              color: (positive ? Colors.green : Colors.red).withValues(alpha: 0.1),
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
            const Icon(Icons.analytics_rounded, size: 48),
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
