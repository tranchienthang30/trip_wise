import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../constants/colors.dart';
import '../models/my_trips.dart';
import '../services/my_trips_api.dart';
import '../utils/tripwise_image_provider.dart';
import '../widgets/shared_taskbars.dart';
import '../widgets/shared_top_bars.dart';

class MyTripsScreen extends StatefulWidget {
  const MyTripsScreen({super.key, this.initialStatus, this.focusBookingId});

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

  Future<void> _openTripDetails(String bookingItemId) async {
    await context.push(
      '/my_trip_booking_detail/${Uri.encodeComponent(bookingItemId)}',
    );
    if (!mounted) return;
    await _loadTrips(status: _selectedTab);
  }

  Future<void> _openProviderChat(MyTripCard item) async {
    await context.push(
      '/direct_messaging?mode=user&orderId=${Uri.encodeComponent(item.id)}',
    );
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
            padding: TripwiseInsets.screen,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
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
              Icons.luggage_rounded,
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
            onOpen: () => _openTripDetails(item.id),
            onMessage: () => _openProviderChat(item),
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
    required this.onMessage,
  });

  final MyTripCard item;
  final VoidCallback onOpen;
  final VoidCallback onMessage;

  @override
  Widget build(BuildContext context) {
    final isCancellationPending = item.isCancellationPending;

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
                    if (!isCancellationPending) ...[
                      const SizedBox(width: 8),
                      _StatusChip(label: item.statusLabel, status: item.status),
                    ],
                  ],
                ),
                if (isCancellationPending) ...[
                  const SizedBox(height: 8),
                  const Text(
                    'Waiting for admin cancellation',
                    style: TextStyle(
                      color: TripwiseColors.onPrimaryFixedVariant,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ] else ...[
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
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: TripwiseColors.onSurfaceVariant,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          item.amountLabel,
                          style: const TextStyle(
                            color: TripwiseColors.primary,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: onMessage,
                        tooltip: 'Message provider',
                        style: IconButton.styleFrom(
                          foregroundColor: TripwiseColors.primary,
                          backgroundColor: TripwiseColors.surfaceContainerLowest,
                          side: const BorderSide(
                            color: TripwiseColors.outlineVariant,
                          ),
                        ),
                        icon: const Icon(Icons.chat_bubble_rounded),
                      ),
                      const SizedBox(width: 8),
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
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CancellationPendingNote extends StatelessWidget {
  const _CancellationPendingNote();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: TripwiseColors.primaryFixed.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Text(
        'Waiting for admin cancellation approval',
        style: TextStyle(
          color: TripwiseColors.onPrimaryFixedVariant,
          fontSize: 12,
          fontWeight: FontWeight.w800,
        ),
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
        bg = TripwiseColors.error.withValues(alpha: 0.1);
        fg = TripwiseColors.error;
        break;
      case 'completed':
      case 'upcoming':
      case 'confirmed':
      case 'pending':
        bg = TripwiseColors.primaryFixed;
        fg = TripwiseColors.onPrimaryFixedVariant;
        break;
      default:
        bg = TripwiseColors.primaryFixed;
        fg = TripwiseColors.onPrimaryFixedVariant;
        break;
    }

    return Container(
      constraints: const BoxConstraints(maxWidth: 128),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
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
    final imageProvider = tripwiseImageProvider(url);
    if (imageProvider == null) {
      return Container(
        color: TripwiseColors.surfaceContainer,
        alignment: Alignment.center,
        child: const Icon(
          Icons.image_rounded,
          color: TripwiseColors.onSurfaceVariant,
        ),
      );
    }

    return Image(
      image: imageProvider,
      height: height,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => Container(
        color: TripwiseColors.surfaceContainer,
        alignment: Alignment.center,
        child: const Icon(
          Icons.broken_image_rounded,
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
            Icons.info_rounded,
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
