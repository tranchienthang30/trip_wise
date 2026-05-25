import 'package:flutter/material.dart';

import '../constants/colors.dart';
import '../models/admin_listing.dart';
import '../services/admin_api.dart';
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
                    isReviewing: _reviewingIds.contains(listing.id),
                    onApprove: () =>
                        _reviewListing(listing, AdminListingStatus.approved),
                    onReject: () =>
                        _reviewListing(listing, AdminListingStatus.rejected),
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

    return Column(
      children: [
        Row(
          children: statuses
              .take(2)
              .map(
                (status) => Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(
                      right: status == AdminListingStatus.pending ? 8 : 0,
                    ),
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
                  ),
                ),
              )
              .toList(),
        ),
        const SizedBox(height: 8),
        Row(
          children: statuses
              .skip(2)
              .map(
                (status) => Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(
                      right: status == AdminListingStatus.rejected ? 8 : 0,
                    ),
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
                  ),
                ),
              )
              .toList(),
        ),
      ],
    );
  }

  IconData _statusIcon(AdminListingStatus status) {
    switch (status) {
      case AdminListingStatus.pending:
        return Icons.hourglass_top_rounded;
      case AdminListingStatus.approved:
        return Icons.public_rounded;
      case AdminListingStatus.rejected:
        return Icons.block_rounded;
      case AdminListingStatus.all:
        return Icons.list_alt_rounded;
    }
  }
}

class _ListingReviewTile extends StatelessWidget {
  const _ListingReviewTile({
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
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: TripwiseColors.surfaceContainerLowest,
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
                  child: listing.imageUrl == null || listing.imageUrl!.isEmpty
                      ? const ColoredBox(
                          color: TripwiseColors.surfaceContainerLow,
                          child: Icon(Icons.hotel_rounded),
                        )
                      : Image.network(listing.imageUrl!, fit: BoxFit.cover),
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
          if (listing.rejectionReason != null) ...[
            const SizedBox(height: 10),
            Text(
              'Reason: ${listing.rejectionReason}',
              style: const TextStyle(color: TripwiseColors.onSurfaceVariant),
            ),
          ],
          if (listing.isPending) ...[
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: isReviewing ? null : onReject,
                    style: TripwiseButtonStyles.destructiveOutlined(
                      radius: 8,
                      padding: const EdgeInsets.symmetric(vertical: 12),
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
                      padding: const EdgeInsets.symmetric(vertical: 12),
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
                        : const Icon(Icons.public_rounded, size: 18),
                    label: const Text('Approve'),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
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
      constraints: const BoxConstraints(minHeight: 78),
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
