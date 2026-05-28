import 'package:flutter/material.dart';

import '../constants/colors.dart';
import '../constants/icons.dart';
import '../models/admin_listing.dart';
import '../services/admin_api.dart';
import '../utils/tripwise_image_provider.dart';
import '../widgets/shared_taskbars.dart';

class AdminListingApprovalsScreen extends StatefulWidget {
  const AdminListingApprovalsScreen({super.key});

  @override
  State<AdminListingApprovalsScreen> createState() =>
      _AdminListingApprovalsScreenState();
}

class _AdminListingApprovalsScreenState
    extends State<AdminListingApprovalsScreen> {
  final AdminApi _api = AdminApi();
  final Set<int> _reviewingIds = {};

  AdminListingsResponse? _data;
  AdminListingStatus _status = AdminListingStatus.pending;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadListings();
  }

  Future<void> _loadListings() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final data = await _api.fetchListings(status: _status);
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

  Future<void> _changeStatus(AdminListingStatus status) async {
    if (_status == status) return;
    setState(() => _status = status);
    await _loadListings();
  }

  Future<void> _reviewListing(
    AdminListing listing,
    AdminListingStatus decision,
  ) async {
    if (_reviewingIds.contains(listing.id)) return;
    setState(() => _reviewingIds.add(listing.id));
    try {
      final reviewed = await _api.reviewListing(
        listingId: listing.id,
        decision: decision,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(
              decision == AdminListingStatus.approved
                  ? '${reviewed.title} is now public.'
                  : '${reviewed.title} was rejected.',
            ),
            backgroundColor: decision == AdminListingStatus.approved
                ? TripwiseColors.primary
                : TripwiseColors.error,
          ),
        );
      await _loadListings();
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(error.toString()),
            backgroundColor: TripwiseColors.error,
          ),
        );
    } finally {
      if (mounted) setState(() => _reviewingIds.remove(listing.id));
    }
  }

  void _openListingDetails(AdminListing listing) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return _ListingDetailsSheet(
          listing: listing,
          isReviewing: _reviewingIds.contains(listing.id),
          onApprove: () {
            Navigator.of(sheetContext).pop();
            _reviewListing(listing, AdminListingStatus.approved);
          },
          onReject: () {
            Navigator.of(sheetContext).pop();
            _reviewListing(listing, AdminListingStatus.rejected);
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final data = _data;
    final listings = data?.listings ?? const <AdminListing>[];

    return Scaffold(
      backgroundColor: TripwiseColors.surface,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        automaticallyImplyLeading: false,
        titleSpacing: 20,
        title: Text(
          'TRIP WISE ADMIN',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: TripwiseColors.primary,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _loadListings,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: TripwiseInsets.screen,
          children: [
            Text(
              'Listing approvals',
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 8),
            const Text(
              'Provider listings stay hidden from search until approved.',
              style: TextStyle(
                color: TripwiseColors.onSurfaceVariant,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 16),
            _buildStatusFilters(data?.counts),
            const SizedBox(height: 16),
            if (_isLoading && data == null)
              const Padding(
                padding: EdgeInsets.only(top: 120),
                child: Center(child: CircularProgressIndicator()),
              )
            else if (_error != null && data == null)
              _ErrorState(message: _error!, onRetry: _loadListings)
            else if (listings.isEmpty)
              const _EmptyState()
            else
              ...listings.map(
                (listing) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _ListingReviewTile(
                    listing: listing,
                    onTap: () => _openListingDetails(listing),
                  ),
                ),
              ),
          ],
        ),
      ),
      bottomNavigationBar: const AdminTaskbar(
        currentTab: AdminTaskbarTab.listings,
      ),
    );
  }

  Widget _buildStatusFilters(AdminListingCounts? counts) {
    const statuses = [
      AdminListingStatus.pending,
      AdminListingStatus.approved,
      AdminListingStatus.rejected,
      AdminListingStatus.all,
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        const gap = 12.0;
        final tileWidth = (constraints.maxWidth - gap) / 2;

        return Wrap(
          spacing: gap,
          runSpacing: gap,
          children: statuses.map((status) {
            return SizedBox(
              width: tileWidth,
              child: _ListingStatusFilterTile(
                icon: _statusIcon(status),
                label: adminListingStatusLabel(status),
                value: counts?.countFor(status) ?? 0,
                accentColor: status == AdminListingStatus.rejected
                    ? TripwiseColors.error
                    : TripwiseColors.primary,
                isSelected: _status == status,
                onTap: () => _changeStatus(status),
              ),
            );
          }).toList(),
        );
      },
    );
  }

  IconData _statusIcon(AdminListingStatus status) {
    switch (status) {
      case AdminListingStatus.pending:
        return TripwiseIcons.pending;
      case AdminListingStatus.approved:
        return TripwiseIcons.approved;
      case AdminListingStatus.rejected:
        return TripwiseIcons.rejected;
      case AdminListingStatus.all:
        return TripwiseIcons.all;
    }
  }
}

class _ListingReviewTile extends StatelessWidget {
  const _ListingReviewTile({
    required this.listing,
    required this.onTap,
  });

  final AdminListing listing;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final imageProvider = tripwiseImageProvider(listing.imageUrl);
    return Material(
      color: TripwiseColors.surfaceContainerLowest,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: TripwiseColors.outlineVariant),
          ),
          child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: SizedBox(
                  width: 72,
                  height: 72,
                  child: imageProvider == null
                      ? const ColoredBox(
                          color: TripwiseColors.surfaceContainerLow,
                          child: Icon(Icons.hotel_rounded),
                        )
                      : Image(
                          image: imageProvider,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => const ColoredBox(
                            color: TripwiseColors.surfaceContainerLow,
                            child: Icon(Icons.hotel_rounded),
                          ),
                        ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      listing.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${listing.providerName} • ${listing.category}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: TripwiseColors.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      listing.location,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: TripwiseColors.onSurfaceVariant,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              _StatusBadge(status: listing.status),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(
                Icons.visibility_rounded,
                size: 18,
                color: TripwiseColors.primary,
              ),
              const SizedBox(width: 6),
              Text(
                listing.isPending ? 'View details to review' : 'View details',
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: TripwiseColors.primary,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const Spacer(),
              const Icon(
                Icons.chevron_right_rounded,
                color: TripwiseColors.primary,
              ),
            ],
          ),
          if (listing.rejectionReason != null) ...[
            const SizedBox(height: 10),
            Text(
              'Reason: ${listing.rejectionReason}',
              style: const TextStyle(color: TripwiseColors.onSurfaceVariant),
            ),
          ],
        ],
      ),
        ),
      ),
    );
  }
}

class _ListingDetailsSheet extends StatelessWidget {
  const _ListingDetailsSheet({
    required this.listing,
    required this.isReviewing,
    required this.onApprove,
    required this.onReject,
  });

  final AdminListing listing;
  final bool isReviewing;
  final VoidCallback onApprove;
  final VoidCallback onReject;

  @override
  Widget build(BuildContext context) {
    final imageProvider = tripwiseImageProvider(listing.imageUrl);
    return DraggableScrollableSheet(
      initialChildSize: 0.86,
      minChildSize: 0.55,
      maxChildSize: 0.94,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: TripwiseColors.surfaceContainerLowest,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: ListView(
            controller: scrollController,
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
            children: [
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: TripwiseColors.outlineVariant,
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: AspectRatio(
                  aspectRatio: 16 / 10,
                  child: imageProvider == null
                      ? const ColoredBox(
                          color: TripwiseColors.surfaceContainerLow,
                          child: Center(
                            child: Icon(Icons.hotel_rounded, size: 42),
                          ),
                        )
                      : Image(
                          image: imageProvider,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => const ColoredBox(
                            color: TripwiseColors.surfaceContainerLow,
                            child: Center(
                              child: Icon(Icons.hotel_rounded, size: 42),
                            ),
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      listing.title,
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(fontWeight: FontWeight.w900),
                    ),
                  ),
                  const SizedBox(width: 12),
                  _StatusBadge(status: listing.status),
                ],
              ),
              const SizedBox(height: 16),
              _ListingDetailRow(
                icon: Icons.business_rounded,
                label: 'Provider',
                value: listing.providerName,
              ),
              _ListingDetailRow(
                icon: Icons.category_rounded,
                label: 'Category',
                value: listing.category,
              ),
              _ListingDetailRow(
                icon: Icons.location_on_rounded,
                label: 'Location',
                value: listing.location,
              ),
              const SizedBox(height: 4),
              _ListingMetricGrid(listing: listing),
              if (listing.description != null &&
                  listing.description!.trim().isNotEmpty) ...[
                const SizedBox(height: 16),
                Text(
                  'Description',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  listing.description!,
                  style: const TextStyle(
                    color: TripwiseColors.onSurfaceVariant,
                    height: 1.35,
                  ),
                ),
              ],
              if (listing.amenities.isNotEmpty) ...[
                const SizedBox(height: 16),
                Text(
                  'Amenities',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final amenity in listing.amenities)
                      Chip(
                        label: Text(amenity),
                        backgroundColor: TripwiseColors.surfaceContainerLow,
                        side: BorderSide.none,
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                  ],
                ),
              ],
              const SizedBox(height: 16),
              Text(
                'Rooms & pricing',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 8),
              if (listing.rooms.isEmpty)
                const Text(
                  'No rooms configured for this listing.',
                  style: TextStyle(color: TripwiseColors.onSurfaceVariant),
                )
              else
                for (final room in listing.rooms) _RoomSummaryCard(room: room),
              const SizedBox(height: 4),
              if (listing.submittedAt != null)
                _ListingDetailRow(
                  icon: Icons.schedule_rounded,
                  label: 'Submitted',
                  value: listing.submittedAt!,
                ),
              if (listing.reviewedAt != null)
                _ListingDetailRow(
                  icon: Icons.fact_check_rounded,
                  label: 'Reviewed',
                  value: listing.reviewedAt!,
                ),
              if (listing.reviewedBy != null)
                _ListingDetailRow(
                  icon: Icons.admin_panel_settings_rounded,
                  label: 'Reviewed by',
                  value: listing.reviewedBy!,
                ),
              if (listing.rejectionReason != null)
                _ListingDetailRow(
                  icon: Icons.report_problem_rounded,
                  label: 'Reason',
                  value: listing.rejectionReason!,
                ),
              if (listing.isPending) ...[
                const SizedBox(height: 18),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: isReviewing ? null : onReject,
                        style: TripwiseButtonStyles.destructiveOutlined(
                          radius: 8,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        icon: const Icon(Icons.close_rounded, size: 18),
                        label: const Text('Reject'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: isReviewing ? null : onApprove,
                        style: TripwiseButtonStyles.primaryElevated(
                          radius: 8,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          elevation: 0,
                        ),
                        icon: isReviewing
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: TripwiseColors.onPrimary,
                                ),
                              )
                            : const Icon(TripwiseIcons.approved, size: 18),
                        label: const Text('Approve'),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}

class _ListingDetailRow extends StatelessWidget {
  const _ListingDetailRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: TripwiseColors.primaryFixed,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 18, color: TripwiseColors.primary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: TripwiseColors.onSurfaceVariant,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  value,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ListingMetricGrid extends StatelessWidget {
  const _ListingMetricGrid({required this.listing});

  final AdminListing listing;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _ListingMetric(
                label: 'Price',
                value: listing.priceRangeLabel,
                icon: Icons.payments_rounded,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _ListingMetric(
                label: 'Rooms',
                value: '${listing.roomCount}',
                icon: Icons.meeting_room_rounded,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _ListingMetric(
                label: 'Guests/room',
                value: listing.maxGuests != null
                    ? '${listing.maxGuests}'
                    : _capacityRangeLabel(listing.rooms),
                icon: Icons.group_rounded,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _ListingMetric(
                label: 'Available',
                value: listing.totalAvailableQty?.toString() ?? 'N/A',
                icon: Icons.inventory_2_rounded,
              ),
            ),
          ],
        ),
        if (listing.bedrooms != null || listing.bathrooms != null) ...[
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _ListingMetric(
                  label: 'Bedrooms',
                  value: listing.bedrooms?.toString() ?? 'N/A',
                  icon: Icons.bed_rounded,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _ListingMetric(
                  label: 'Bathrooms',
                  value: listing.bathrooms?.toString() ?? 'N/A',
                  icon: Icons.bathtub_rounded,
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}

String _capacityRangeLabel(List<AdminListingRoom> rooms) {
  final capacities = rooms
      .map((room) => room.capacity)
      .whereType<int>()
      .where((value) => value > 0)
      .toList();
  if (capacities.isEmpty) return 'N/A';
  final min = capacities.reduce((a, b) => a < b ? a : b);
  final max = capacities.reduce((a, b) => a > b ? a : b);
  return min == max ? '$min' : '$min-$max';
}

class _ListingMetric extends StatelessWidget {
  const _ListingMetric({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: TripwiseColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: TripwiseColors.primary),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: TripwiseColors.onSurfaceVariant,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RoomSummaryCard extends StatelessWidget {
  const _RoomSummaryCard({required this.room});

  final AdminListingRoom room;

  @override
  Widget build(BuildContext context) {
    final imageProvider = tripwiseImageProvider(room.imageUrl);
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: TripwiseColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: TripwiseColors.outlineVariant),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: SizedBox(
              width: 54,
              height: 54,
              child: imageProvider == null
                  ? const ColoredBox(
                      color: TripwiseColors.surfaceContainerHigh,
                      child: Icon(Icons.meeting_room_rounded),
                    )
                  : Image(
                      image: imageProvider,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => const ColoredBox(
                        color: TripwiseColors.surfaceContainerHigh,
                        child: Icon(Icons.meeting_room_rounded),
                      ),
                    ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  room.roomType,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  [
                    room.capacity != null
                        ? '${room.capacity} guests/room'
                        : 'Capacity N/A',
                    _roomAvailabilityLabel(room),
                  ].join(' • '),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: TripwiseColors.onSurfaceVariant,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            room.basePriceLabel,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: TripwiseColors.primary,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

String _roomAvailabilityLabel(AdminListingRoom room) {
  final qty = room.availableQty;
  if (qty == null) return 'Inventory N/A';
  final date = room.availabilityDate;
  if (date == null || date.isEmpty) return '$qty available';
  return '$qty available on $date';
}

class _ListingStatusFilterTile extends StatelessWidget {
  const _ListingStatusFilterTile({
    required this.icon,
    required this.label,
    required this.value,
    required this.accentColor,
    required this.isSelected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final int value;
  final Color accentColor;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final foregroundColor =
        isSelected ? TripwiseColors.onPrimary : TripwiseColors.onSurface;
    final supportingColor = isSelected
        ? TripwiseColors.onPrimary
        : TripwiseColors.onSurfaceVariant;
    final iconBackground = isSelected
        ? TripwiseColors.primaryContainer
        : accentColor == TripwiseColors.error
        ? TripwiseColors.errorContainer
        : TripwiseColors.primaryFixed;
    final iconColor = isSelected ? TripwiseColors.onPrimary : accentColor;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOut,
      height: 78,
      decoration: BoxDecoration(
        color: isSelected
            ? TripwiseColors.primary
            : TripwiseColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isSelected
              ? TripwiseColors.primary
              : TripwiseColors.outlineVariant,
        ),
        boxShadow: isSelected
            ? [
                BoxShadow(
                  color: TripwiseColors.primary.withOpacity(0.16),
                  blurRadius: 14,
                  offset: const Offset(0, 6),
                ),
              ]
            : const [],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
            child: Row(
              children: [
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: iconBackground,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, size: 18, color: iconColor),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.labelSmall
                            ?.copyWith(
                              color: supportingColor,
                              fontWeight: FontWeight.w900,
                            ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        value.toString(),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.titleLarge
                            ?.copyWith(
                              color: foregroundColor,
                              fontWeight: FontWeight.w900,
                            ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status});

  final AdminListingStatus status;

  @override
  Widget build(BuildContext context) {
    final label = adminListingStatusLabel(status);
    final color = switch (status) {
      AdminListingStatus.approved => TripwiseColors.primaryFixed,
      AdminListingStatus.rejected => TripwiseColors.errorContainer,
      AdminListingStatus.pending ||
      AdminListingStatus.all => TripwiseColors.surfaceContainerHigh,
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(label, style: const TextStyle(fontWeight: FontWeight.w900)),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 96),
      child: Column(
        children: [
          const Icon(
            Icons.cloud_off_rounded,
            size: 44,
            color: TripwiseColors.onSurfaceVariant,
          ),
          const SizedBox(height: 12),
          const Text(
            "Couldn't load listings",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 8),
          Text(message, textAlign: TextAlign.center),
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

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.only(top: 96),
      child: Center(
        child: Text(
          'No listings in this view.',
          style: TextStyle(
            color: TripwiseColors.onSurfaceVariant,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}
