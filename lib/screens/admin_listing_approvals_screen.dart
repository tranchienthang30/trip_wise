import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../constants/colors.dart';
import '../models/admin_listing.dart';
import '../services/admin_api.dart';
import '../services/auth_session_store.dart';

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

  Future<void> _signOut() async {
    await AuthSessionStore.instance.logout();
    if (!mounted) return;
    context.go('/register');
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
        actions: [
          IconButton(
            onPressed: () => context.go('/admin_provider_approvals'),
            tooltip: 'Provider applications',
            icon: const Icon(
              Icons.verified_user_rounded,
              color: TripwiseColors.primary,
            ),
          ),
          IconButton(
            onPressed: () => context.go('/admin_provider_payouts'),
            tooltip: 'Provider payouts',
            icon: const Icon(
              Icons.payments_rounded,
              color: TripwiseColors.primary,
            ),
          ),
          IconButton(
            onPressed: _isLoading ? null : _loadListings,
            tooltip: 'Refresh',
            icon: const Icon(
              Icons.refresh_rounded,
              color: TripwiseColors.primary,
            ),
          ),
          IconButton(
            onPressed: _signOut,
            tooltip: 'Sign out',
            icon: const Icon(Icons.logout_rounded, color: TripwiseColors.error),
          ),
          const SizedBox(width: 12),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadListings,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
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
            _buildStatusTabs(data?.counts),
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
    );
  }

  Widget _buildStatusTabs(AdminListingCounts? counts) {
    const statuses = [
      AdminListingStatus.pending,
      AdminListingStatus.approved,
      AdminListingStatus.rejected,
      AdminListingStatus.all,
    ];
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: SegmentedButton<AdminListingStatus>(
        showSelectedIcon: false,
        segments: statuses
            .map(
              (status) => ButtonSegment(
                value: status,
                icon: Icon(_statusIcon(status)),
                label: Text(
                  '${adminListingStatusLabel(status)} (${counts?.countFor(status) ?? 0})',
                ),
              ),
            )
            .toList(),
        selected: {_status},
        onSelectionChanged: (selection) => _changeStatus(selection.first),
      ),
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
