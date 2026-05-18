import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../constants/colors.dart';
import '../models/my_trips.dart';
import '../services/my_trips_api.dart';
import '../widgets/shared_taskbars.dart';
import '../widgets/shared_top_bars.dart';

class MyTripsScreen extends StatefulWidget {
  const MyTripsScreen({
    super.key,
    this.initialStatus,
    this.focusBookingId,
  });

  final String? initialStatus;
  final String? focusBookingId;

  @override
  State<MyTripsScreen> createState() => _MyTripsScreenState();
}

class _MyTripsScreenState extends State<MyTripsScreen> {
  final MyTripsApi _api = MyTripsApi();

  String _selectedTab = 'upcoming';
  String? _focusBookingId;
  MyTripsResponse? _data;
  bool _isLoading = true;
  String? _error;

  static const List<_TripTab> _tabs = [
    _TripTab(key: 'upcoming', label: 'Upcoming'),
    _TripTab(key: 'completed', label: 'Completed'),
    _TripTab(key: 'cancelled', label: 'Cancelled'),
  ];

  @override
  void initState() {
    super.initState();
    _selectedTab = _normalizeTab(widget.initialStatus);
    _focusBookingId = _normalizeBookingId(widget.focusBookingId);
    _loadTrips(status: _selectedTab);
  }

  @override
  void didUpdateWidget(covariant MyTripsScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialStatus != widget.initialStatus ||
        oldWidget.focusBookingId != widget.focusBookingId) {
      _selectedTab = _normalizeTab(widget.initialStatus);
      _focusBookingId = _normalizeBookingId(widget.focusBookingId);
      _loadTrips(status: _selectedTab);
    }
  }

  String _normalizeTab(String? value) {
    switch (value) {
      case 'completed':
      case 'cancelled':
      case 'upcoming':
        return value!;
      default:
        return 'upcoming';
    }
  }

  String? _normalizeBookingId(String? value) {
    if (value == null) return null;
    final trimmed = value.trim();
    return trimmed.isEmpty ? null : trimmed;
  }

  Future<void> _loadTrips({String? status}) async {
    final nextStatus = status ?? _selectedTab;
    setState(() {
      _selectedTab = nextStatus;
      _isLoading = true;
      _error = null;
    });

    try {
      final data = await _api.fetchTrips(
        status: nextStatus,
        bookingId: _focusBookingId,
      );
      if (!mounted) return;
      setState(() {
        _data = data;
        _selectedTab = data.selectedTab;
        _focusBookingId = null;
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

  Future<void> _openTripDetails(String route) async {
    await context.push(route);
    if (!mounted) return;
    await _loadTrips(status: _selectedTab);
  }

  @override
  Widget build(BuildContext context) {
    final data = _data;
    final visibleItems = data?.items ?? const <MyTripCard>[];

    return Scaffold(
      backgroundColor: TripwiseColors.surface,
      appBar: const PlannerAppBar(),
      body: RefreshIndicator(
        onRefresh: () => _loadTrips(status: _selectedTab),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'My Trips',
                  style: Theme.of(context).textTheme.displaySmall?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 16),
                _buildTabs(data),
                const SizedBox(height: 20),
                if (_isLoading && data == null)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 48),
                      child: CircularProgressIndicator(),
                    ),
                  )
                else if (_error != null && data == null)
                  _buildErrorState()
                else ...[
                  if (_error != null)
                    _InlineError(
                      message: _error!,
                      onRetry: () => _loadTrips(status: _selectedTab),
                    ),
                  if (_error != null) const SizedBox(height: 16),
                  _buildTripList(visibleItems),
                ],
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: const PlannerTaskbar(
        currentTab: PlannerTaskbarTab.myTrips,
      ),
    );
  }

  Widget _buildTabs(MyTripsResponse? data) {
    final counts = data?.counts;

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: TripwiseColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: _tabs.map((tab) {
          final isSelected = _selectedTab == tab.key;
          final count = counts?.valueFor(tab.key) ?? 0;
          return Expanded(
            child: GestureDetector(
              onTap: () => _loadTrips(status: tab.key),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected
                      ? TripwiseColors.surfaceContainerLowest
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '${tab.label} ($count)',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: isSelected
                        ? TripwiseColors.primary
                        : TripwiseColors.onSurfaceVariant,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildFeaturedCard(MyTripCard card) {
    return Container(
      decoration: BoxDecoration(
        color: TripwiseColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: TripwiseColors.primary.withOpacity(0.06),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            child: _TripImage(url: card.imageUrl, height: 180),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _StatusChip(label: card.statusLabel, status: card.status),
                    Text(
                      card.amountLabel,
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        color: TripwiseColors.primary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  card.title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: TripwiseColors.onSurface,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  card.subtitle,
                  style: const TextStyle(
                    fontSize: 13,
                    color: TripwiseColors.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  card.dateLabel,
                  style: const TextStyle(
                    fontSize: 12,
                    color: TripwiseColors.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 14),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => context.push(card.route),
                    style: TripwiseButtonStyles.primaryElevated(
                      radius: 12,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    icon: const Icon(
                      Icons.confirmation_number_outlined,
                      size: 18,
                    ),
                    label: Text(_actionLabel(card.serviceType)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTripList(List<MyTripCard> items) {
    if (items.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: TripwiseColors.surfaceContainerLow,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          children: [
            const Icon(
              Icons.luggage_outlined,
              size: 38,
              color: TripwiseColors.onSurfaceVariant,
            ),
            const SizedBox(height: 10),
            Text(
              'No trips in this tab yet',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 6),
            const Text(
              'Your bookings will appear here after confirmation.',
              textAlign: TextAlign.center,
              style: TextStyle(color: TripwiseColors.onSurfaceVariant),
            ),
          ],
        ),
      );
    }

    return Column(
      children: items.map((item) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: _TripListCard(
            item: item,
            onOpen: () => _openTripDetails(item.route),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 48),
        child: Column(
          children: [
            const Icon(
              Icons.cloud_off_rounded,
              size: 40,
              color: TripwiseColors.onSurfaceVariant,
            ),
            const SizedBox(height: 10),
            const Text(
              "Couldn't load trips",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 6),
            Text(
              _error!,
              textAlign: TextAlign.center,
              style: const TextStyle(color: TripwiseColors.onSurfaceVariant),
            ),
            const SizedBox(height: 14),
            ElevatedButton(
              onPressed: () => _loadTrips(status: _selectedTab),
              style: TripwiseButtonStyles.primaryElevated(radius: 12),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  String _actionLabel(String serviceType) {
    if (serviceType == 'flight') return 'View Ticket';
    if (serviceType == 'activity') return 'View Pass';
    return 'View Booking';
  }
}

class _TripTab {
  const _TripTab({required this.key, required this.label});

  final String key;
  final String label;
}

class _TripListCard extends StatelessWidget {
  const _TripListCard({
    required this.item,
    required this.onOpen,
  });

  final MyTripCard item;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: TripwiseColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(14),
      ),
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: SizedBox(
              width: 92,
              height: 92,
              child: _TripImage(url: item.imageUrl, height: 92),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        item.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          color: TripwiseColors.onSurface,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    _StatusChip(label: item.statusLabel, status: item.status),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  item.subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: TripwiseColors.onSurfaceVariant,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  item.dateLabel,
                  style: const TextStyle(
                    color: TripwiseColors.onSurfaceVariant,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      item.amountLabel,
                      style: const TextStyle(
                        color: TripwiseColors.primary,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    OutlinedButton(
                      onPressed: onOpen,
                      style: TripwiseButtonStyles.outlined(
                        radius: 10,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        foregroundColor: TripwiseColors.primary,
                        borderColor: TripwiseColors.primary,
                      ),
                      child: const Text('Details'),
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

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.label, required this.status});

  final String label;
  final String status;

  @override
  Widget build(BuildContext context) {
    final Color bg;
    final Color fg;
    switch (status) {
      case 'cancelled':
        bg = TripwiseColors.error.withOpacity(0.1);
        fg = TripwiseColors.error;
        break;
      case 'completed':
        bg = TripwiseColors.primaryFixed;
        fg = TripwiseColors.onPrimaryFixedVariant;
        break;
      default:
        bg = TripwiseColors.secondaryFixed;
        fg = TripwiseColors.onSecondaryFixedVariant;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: TextStyle(color: fg, fontSize: 11, fontWeight: FontWeight.w700),
      ),
    );
  }
}

class _TripImage extends StatelessWidget {
  const _TripImage({required this.url, required this.height});

  final String url;
  final double height;

  @override
  Widget build(BuildContext context) {
    if (url.trim().isEmpty) {
      return Container(
        color: TripwiseColors.surfaceContainer,
        alignment: Alignment.center,
        child: const Icon(
          Icons.image_outlined,
          color: TripwiseColors.onSurfaceVariant,
        ),
      );
    }

    return Image.network(
      url,
      height: height,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => Container(
        color: TripwiseColors.surfaceContainer,
        alignment: Alignment.center,
        child: const Icon(
          Icons.broken_image_outlined,
          color: TripwiseColors.onSurfaceVariant,
        ),
      ),
    );
  }
}

class _InlineError extends StatelessWidget {
  const _InlineError({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: TripwiseColors.errorContainer,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.info_outline,
            color: TripwiseColors.onErrorContainer,
          ),
          const SizedBox(width: 10),
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
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            ),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}
