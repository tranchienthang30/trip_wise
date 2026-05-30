import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../constants/colors.dart';
import '../models/provider_listing.dart';
import '../services/provider_listings_api.dart';
import '../widgets/shared_taskbars.dart';

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
      appBar: _buildAppBar(),
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

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: TripwiseColors.surface,
      elevation: 0,
      scrolledUnderElevation: 0,
      toolbarHeight: 64,
      titleSpacing: 0,
      leading: IconButton(
        icon: const Icon(
          Icons.arrow_back_rounded,
          color: TripwiseColors.primary,
        ),
        onPressed: () {
          if (context.canPop()) {
            context.pop();
            return;
          }
          context.go('/provider_listings');
        },
      ),
      title: Text(
        'TRIP WISE BUSINESS',
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: TripwiseColors.primary,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.2,
            ),
      ),
    );
  }

  Widget _buildAnalytics(ProviderListingAnalytics data) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHeader(),
        const SizedBox(height: 16),
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
        GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          childAspectRatio: 1.08,
          children: [
            _buildKpiCard(
              title: 'Total Views',
              value: '${data.kpis.totalViews}',
              change: _delta(data.kpis.viewsDeltaPct),
              icon: Icons.visibility_rounded,
              positive: data.kpis.viewsDeltaPct >= 0,
            ),
            _buildKpiCard(
              title: 'Bookings',
              value: '${data.kpis.bookings}',
              change: _delta(data.kpis.bookingsDeltaPct),
              icon: Icons.calendar_today_rounded,
              positive: data.kpis.bookingsDeltaPct >= 0,
            ),
            _buildKpiCard(
              title: 'Revenue',
              value: '\$${data.kpis.revenue.toStringAsFixed(0)}',
              change: _delta(data.kpis.revenueDeltaPct),
              icon: Icons.trending_up_rounded,
              positive: data.kpis.revenueDeltaPct >= 0,
            ),
            _buildKpiCard(
              title: 'Avg Rating',
              value: data.kpis.averageRating.toStringAsFixed(1),
              change: _delta(data.kpis.ratingDelta),
              icon: Icons.star_rounded,
              positive: data.kpis.ratingDelta >= 0,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildHeader() {
    final listingTitle = _cleanListingTitle();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF0066A8),
            Color(0xFF047FC4),
          ],
        ),
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: TripwiseColors.primary.withValues(alpha: 0.18),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -28,
            bottom: -34,
            child: Container(
              width: 118,
              height: 118,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.08),
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Text(
                      'LISTING ANALYTICS',
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                            color: Colors.white.withValues(alpha: 0.72),
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.9,
                          ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  _buildPeriodSelector(),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                _balancedTitle(listingTitle),
                softWrap: true,
                overflow: TextOverflow.visible,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                      fontSize: _titleFontSize(listingTitle),
                      height: 1.02,
                      letterSpacing: -0.35,
                    ),
              ),
              const SizedBox(height: 8),
              Container(
                width: 42,
                height: 3,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.45),
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _cleanListingTitle() {
    final title = widget.listingTitle?.trim();
    return title == null || title.isEmpty ? 'Listing Analytics' : title;
  }

  String _balancedTitle(String title) {
    final words = title.split(RegExp(r'\s+')).where((w) => w.isNotEmpty).toList();
    if (words.length <= 3) return title;

    final lineCount = title.length > 48 && words.length >= 6 ? 3 : 2;
    final targetLength = title.length / lineCount;
    final lines = <List<String>>[<String>[]];

    for (var i = 0; i < words.length; i++) {
      final current = lines.last;
      final currentLength = current.join(' ').length;
      final nextLength = current.isEmpty
          ? words[i].length
          : currentLength + 1 + words[i].length;
      final remainingWords = words.length - i;
      final remainingLines = lineCount - lines.length;
      final shouldWrap =
          current.isNotEmpty &&
          nextLength > targetLength &&
          remainingLines > 0 &&
          remainingWords > remainingLines;

      if (shouldWrap) {
        lines.add(<String>[words[i]]);
      } else {
        current.add(words[i]);
      }
    }

    if (lines.length > 1 && lines.last.length == 1) {
      final previous = lines[lines.length - 2];
      if (previous.length > 1) {
        lines.last.insert(0, previous.removeLast());
      }
    }

    return lines.map((line) => line.join(' ')).join('\n');
  }

  double _titleFontSize(String title) {
    if (title.length > 70) return 17.5;
    if (title.length > 48) return 18.5;
    if (title.length > 34) return 20;
    return 22.5;
  }

  Widget _buildPeriodSelector() {
    return Container(
      height: 36,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white.withValues(alpha: 0.28)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _period,
          dropdownColor: TripwiseColors.surfaceContainerLowest,
          iconEnabledColor: Colors.white,
          style: const TextStyle(
            color: TripwiseColors.onSurface,
            fontWeight: FontWeight.w800,
          ),
          selectedItemBuilder: (context) => _periodOptions
              .map(
                (option) => Align(
                  alignment: Alignment.center,
                  child: Text(
                    option.label,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              )
              .toList(),
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
      ),
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
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: TripwiseColors.outlineVariant.withValues(alpha: 0.35),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.045),
            blurRadius: 14,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
              Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: TripwiseColors.primaryFixed.withValues(alpha: 0.7),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, size: 16, color: TripwiseColors.primary),
              ),
            ],
          ),
          Text(
            value,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color:
                  (positive ? Colors.green : Colors.red).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(999),
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
