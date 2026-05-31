import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../constants/colors.dart';
import '../constants/icons.dart';
import '../models/provider_listing.dart';
import '../models/review.dart';
import '../services/provider_listings_api.dart';
import '../widgets/review_card.dart';
import '../widgets/shared_taskbars.dart';
import '../widgets/shared_top_bars.dart';
import '../widgets/tripwise_network_image.dart';

class ProviderListingManagementScreen extends StatefulWidget {
  const ProviderListingManagementScreen({super.key});

  @override
  State<ProviderListingManagementScreen> createState() =>
      _ProviderListingManagementScreenState();
}

class _ProviderListingManagementScreenState
    extends State<ProviderListingManagementScreen> {
  final ProviderListingsApi _api = ProviderListingsApi();
  final TextEditingController _searchController = TextEditingController();

  String _status = 'all';
  ProviderListingsResponse? _data;
  bool _isLoading = true;
  int? _actionListingId;
  String? _error;
  Timer? _searchDebounce;

  static const List<_ListingTab> _tabs = [
    _ListingTab(status: 'all', label: 'All'),
    _ListingTab(status: 'active', label: 'Active'),
    _ListingTab(status: 'pending', label: 'Pending'),
    _ListingTab(status: 'inactive', label: 'Inactive'),
  ];

  @override
  void initState() {
    super.initState();
    _loadListings();
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadListings({bool keepOldData = true}) async {
    if (!keepOldData || _data == null) {
      setState(() {
        _isLoading = true;
        _error = null;
      });
    } else {
      setState(() {
        _isLoading = true;
        _error = null;
      });
    }

    try {
      final response = await _api.fetchListings(
        query: _searchController.text.trim(),
        status: _status,
      );
      if (!mounted) return;
      setState(() {
        _data = response;
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

  void _onSearchChanged(String _) {
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 350), () {
      _loadListings();
    });
  }

  @override
  Widget build(BuildContext context) {
    final data = _data;
    final items = data?.items ?? const <ProviderListingSummary>[];

    return Scaffold(
      backgroundColor: TripwiseColors.surface,
      appBar: const ProviderAppBar(),
      body: RefreshIndicator(
        onRefresh: () => _loadListings(keepOldData: false),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Padding(
            padding: TripwiseInsets.screen,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSearchAndFilterBar(data),
                const SizedBox(height: 20),
                if (_isLoading && data == null)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 60),
                      child: CircularProgressIndicator(),
                    ),
                  )
                else if (_error != null && data == null)
                  _buildErrorState()
                else ...[
                  if (_error != null)
                    _InlineError(message: _error!, onRetry: _loadListings),
                  if (_error != null) const SizedBox(height: 12),
                  _buildListingCollection(items: items),
                ],
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/add_new_listing_form'),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Add Listing'),
      ),
      bottomNavigationBar: const ProviderTaskbar(
        currentTab: ProviderTaskbarTab.listings,
      ),
    );
  }

  Widget _buildSearchAndFilterBar(ProviderListingsResponse? data) {
    final counts = data?.counts;

    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: _searchController,
            onChanged: _onSearchChanged,
            decoration: InputDecoration(
              hintText: 'Search your listings...',
              prefixIcon: const Icon(Icons.search_rounded),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: TripwiseColors.surfaceContainerLow,
              contentPadding: const EdgeInsets.all(16),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Container(
          decoration: BoxDecoration(
            color: TripwiseColors.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: TripwiseColors.outlineVariant),
          ),
          child: PopupMenuButton<String>(
            tooltip: 'Filter status',
            onSelected: _selectStatus,
            icon: Icon(
              TripwiseIcons.filter,
              color: _status == 'all'
                  ? TripwiseColors.onSurfaceVariant
                  : TripwiseColors.primary,
            ),
            itemBuilder: (context) {
              return _tabs.map((tab) {
                final isSelected = _status == tab.status;
                final count = counts?.valueFor(tab.status) ?? 0;
                return PopupMenuItem<String>(
                  value: tab.status,
                  child: Row(
                    children: [
                      Icon(
                        _statusIcon(tab.status),
                        size: 18,
                        color: isSelected
                            ? TripwiseColors.primary
                            : TripwiseColors.onSurfaceVariant,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          '${tab.label} ($count)',
                          style: TextStyle(
                            fontWeight: isSelected
                                ? FontWeight.w800
                                : FontWeight.w500,
                          ),
                        ),
                      ),
                      if (isSelected)
                        const Icon(
                          TripwiseIcons.selected,
                          size: 18,
                          color: TripwiseColors.primary,
                        ),
                    ],
                  ),
                );
              }).toList();
            },
          ),
        ),
      ],
    );
  }

  void _selectStatus(String status) {
    if (_status == status) return;
    setState(() => _status = status);
    _loadListings();
  }

  Future<void> _handleListingAction(
    ProviderListingSummary item,
    _ListingCardAction action,
  ) async {
    if (_actionListingId != null) return;
    if (action == _ListingCardAction.edit) {
      await context.push(item.editRoute);
      if (!mounted) return;
      await _loadListings();
      return;
    }
    if (action == _ListingCardAction.analytics) {
      await context.push(item.analyticsRoute);
      if (!mounted) return;
      await _loadListings();
      return;
    }

    if (action == _ListingCardAction.delete) {
      final shouldDelete = await showDialog<bool>(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Delete listing'),
            content: Text('Delete "${item.title}"? This action cannot be undone.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                style: TextButton.styleFrom(foregroundColor: TripwiseColors.error),
                child: const Text('Delete'),
              ),
            ],
          );
        },
      );
      if (shouldDelete != true) return;
      setState(() => _actionListingId = item.id);
      try {
        await _api.deleteListing(item.id);
        if (!mounted) return;
        _showSnack('Listing deleted.');
        await _loadListings();
      } catch (error) {
        if (!mounted) return;
        _showSnack(error.toString(), isError: true);
      } finally {
        if (mounted) setState(() => _actionListingId = null);
      }
      return;
    }

    final targetStatus = action == _ListingCardAction.activate
        ? 'active'
        : 'inactive';
    setState(() => _actionListingId = item.id);
    try {
      await _api.updateListing(id: item.id, status: targetStatus);
      if (!mounted) return;
      _showSnack(
        targetStatus == 'inactive'
            ? 'Listing closed for new orders.'
            : 'Listing submitted for review.',
      );
      await _loadListings();
    } catch (error) {
      if (!mounted) return;
      _showSnack(error.toString(), isError: true);
    } finally {
      if (mounted) setState(() => _actionListingId = null);
    }
  }

  Future<void> _openListingDetail(ProviderListingSummary item) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return _ProviderListingDetailSheet(
          api: _api,
          listingId: item.id,
          fallbackImageUrl: item.imageUrl,
        );
      },
    );
  }

  void _showSnack(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor:
              isError ? TripwiseColors.error : TripwiseColors.primary,
        ),
      );
  }

  IconData _statusIcon(String status) {
    switch (status) {
      case 'active':
        return TripwiseIcons.active;
      case 'pending':
        return TripwiseIcons.pending;
      case 'inactive':
        return TripwiseIcons.inactive;
      case 'all':
      default:
        return TripwiseIcons.all;
    }
  }

  Widget _buildListingCollection({
    required List<ProviderListingSummary> items,
  }) {
    if (items.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 24),
        decoration: BoxDecoration(
          color: TripwiseColors.surfaceContainerLow,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: TripwiseColors.outlineVariant.withValues(alpha: 0.35),
            width: 1.5,
          ),
        ),
        child: const Column(
          children: [
            Icon(
              Icons.add_business_rounded,
              size: 48,
              color: TripwiseColors.onSurfaceVariant,
            ),
            SizedBox(height: 10),
            Text(
              'No listings found',
              style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18),
            ),
            SizedBox(height: 8),
            Text(
              'Try a different search or add your first listing.',
              textAlign: TextAlign.center,
              style: TextStyle(color: TripwiseColors.onSurfaceVariant),
            ),
          ],
        ),
      );
    }

    return Column(
      children: items
          .map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _ListingRowCard(
                item: item,
                isBusy: _actionListingId == item.id,
                onTap: () => _openListingDetail(item),
                onActionSelected: (action) => _handleListingAction(item, action),
              ),
            ),
          )
          .toList(),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 60),
        child: Column(
          children: [
            const Icon(
              Icons.cloud_off_rounded,
              size: 44,
              color: TripwiseColors.onSurfaceVariant,
            ),
            const SizedBox(height: 10),
            const Text(
              "Couldn't load listings",
              style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18),
            ),
            const SizedBox(height: 6),
            Text(
              _error!,
              textAlign: TextAlign.center,
              style: const TextStyle(color: TripwiseColors.onSurfaceVariant),
            ),
            const SizedBox(height: 14),
            ElevatedButton(
              onPressed: _loadListings,
              style: TripwiseButtonStyles.primaryElevated(radius: 12),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}

class _ListingRowCard extends StatelessWidget {
  const _ListingRowCard({
    required this.item,
    required this.onTap,
    required this.onActionSelected,
    this.isBusy = false,
  });

  final ProviderListingSummary item;
  final VoidCallback onTap;
  final ValueChanged<_ListingCardAction> onActionSelected;
  final bool isBusy;

  @override
  Widget build(BuildContext context) {
    final shortTitle = _compactTitle(item.title);

    return GestureDetector(
      onTap: onTap,
      child: Container(
      decoration: BoxDecoration(
        color: TripwiseColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: TripwiseColors.outlineVariant.withValues(alpha: 0.7),
        ),
      ),
      padding: const EdgeInsets.all(10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: _ListingImagePreview(
              imageUrl: item.imageUrl,
              fallbackSeed: 'hotel-${item.id}',
              width: 92,
              height: 92,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Text(
                        shortTitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          color: TripwiseColors.onSurface,
                        ),
                      ),
                    ),
                    const SizedBox(width: 4),
                    if (isBusy)
                      const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    else
                      _ListingCardMenu(
                        item: item,
                        onSelected: onActionSelected,
                      ),
                  ],
                ),
                const SizedBox(height: 1),
                Text(
                  item.location,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: TripwiseColors.onSurfaceVariant,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 1),
                Text(
                  '${item.category} • ${item.roomType}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: TripwiseColors.onSurfaceVariant,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    _StatusBadge(status: item.statusLabel, raw: item.status),
                    const Spacer(),
                    Text(
                      item.priceLabel,
                      style: const TextStyle(
                        color: TripwiseColors.primary,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
      ),
    );
  }

  String _compactTitle(String title) {
    final words = title
        .trim()
        .split(RegExp(r'\s+'))
        .where((word) => word.isNotEmpty)
        .toList();
    if (words.length <= 2) return title.trim();
    return '${words[0]} ${words[1]}';
  }
}

class _ProviderListingDetailSheet extends StatefulWidget {
  const _ProviderListingDetailSheet({
    required this.api,
    required this.listingId,
    required this.fallbackImageUrl,
  });

  final ProviderListingsApi api;
  final int listingId;
  final String fallbackImageUrl;

  @override
  State<_ProviderListingDetailSheet> createState() =>
      _ProviderListingDetailSheetState();
}

class _ProviderListingDetailSheetState
    extends State<_ProviderListingDetailSheet> {
  late Future<ProviderListingDetail> _future;
  int? _replyingReviewId;

  @override
  void initState() {
    super.initState();
    _future = widget.api.fetchDetail(widget.listingId);
  }

  void _reload() {
    setState(() {
      _future = widget.api.fetchDetail(widget.listingId);
    });
  }

  Future<void> _replyToReview(Review review) async {
    final controller = TextEditingController(text: review.providerReply ?? '');
    final reply = await showDialog<String>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(
            review.providerReply?.trim().isNotEmpty == true
                ? 'Edit reply'
                : 'Reply to review',
          ),
          content: TextField(
            controller: controller,
            autofocus: true,
            maxLines: 5,
            maxLength: 1000,
            decoration: const InputDecoration(
              hintText: 'Write a clear response for this guest review.',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () =>
                  Navigator.of(dialogContext).pop(controller.text.trim()),
              style: TripwiseButtonStyles.primaryElevated(radius: 8),
              child: const Text('Save reply'),
            ),
          ],
        );
      },
    );
    controller.dispose();

    if (reply == null) return;
    if (reply.trim().isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(content: Text('Reply cannot be empty.')),
        );
      return;
    }

    setState(() => _replyingReviewId = review.id);
    try {
      await widget.api.replyToReview(
        listingId: widget.listingId,
        reviewId: review.id,
        reply: reply,
      );
      if (!mounted) return;
      _reload();
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(const SnackBar(content: Text('Reply saved.')));
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
      if (mounted) setState(() => _replyingReviewId = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.86,
      minChildSize: 0.5,
      maxChildSize: 0.94,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: TripwiseColors.surfaceContainerLowest,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: FutureBuilder<ProviderListingDetail>(
            future: _future,
            builder: (context, snapshot) {
              final detail = snapshot.data;
              return ListView(
                controller: scrollController,
                padding: const EdgeInsets.fromLTRB(18, 12, 18, 24),
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
                    child: _ListingImagePreview(
                      imageUrl: detail?.imageUrl ?? widget.fallbackImageUrl,
                      fallbackSeed: 'hotel-${widget.listingId}',
                      width: double.infinity,
                      height: 190,
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (snapshot.connectionState != ConnectionState.done)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 32),
                        child: CircularProgressIndicator(),
                      ),
                    )
                  else if (snapshot.hasError)
                    _DetailLoadError(error: snapshot.error)
                  else if (detail != null) ...[
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            detail.title,
                            style: Theme.of(context)
                                .textTheme
                                .headlineSmall
                                ?.copyWith(fontWeight: FontWeight.w900),
                          ),
                        ),
                        const SizedBox(width: 10),
                        _StatusBadge(
                          status: _statusLabel(detail.status),
                          raw: detail.status,
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      detail.location,
                      style: const TextStyle(
                        color: TripwiseColors.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _ListingDetailMetrics(detail: detail),
                    const SizedBox(height: 18),
                    Row(
                      children: [
                        const Expanded(
                          child: _SheetSectionTitle('Guest reviews'),
                        ),
                        if (detail.reviewCount > 0)
                          Text(
                            '${detail.rating.toStringAsFixed(1)} / 5',
                            style: const TextStyle(
                              color: TripwiseColors.primary,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    if (detail.reviews.isEmpty)
                      const _NoReviewsCard()
                    else
                      for (final review in detail.reviews) ...[
                        _ProviderReviewItem(
                          review: review,
                          isSaving: _replyingReviewId == review.id,
                          onReply: () => _replyToReview(review),
                        ),
                        const SizedBox(height: 10),
                      ],
                  ] else
                    _DetailLoadError(error: 'Listing not found'),
                ],
              );
            },
          ),
        );
      },
    );
  }
}

class _ListingDetailMetrics extends StatelessWidget {
  const _ListingDetailMetrics({required this.detail});

  final ProviderListingDetail detail;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        _MetricPill(icon: Icons.meeting_room_rounded, label: detail.roomType),
        _MetricPill(
          icon: Icons.group_rounded,
          label: '${detail.maxGuests} guests',
        ),
        _MetricPill(
          icon: Icons.payments_rounded,
          label: '\$${detail.pricePerNight.round()}/night',
        ),
      ],
    );
  }
}

class _ProviderReviewItem extends StatelessWidget {
  const _ProviderReviewItem({
    required this.review,
    required this.isSaving,
    required this.onReply,
  });

  final Review review;
  final bool isSaving;
  final VoidCallback onReply;

  @override
  Widget build(BuildContext context) {
    final hasReply = review.providerReply?.trim().isNotEmpty == true;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ReviewCard(review: review),
        const SizedBox(height: 8),
        Align(
          alignment: Alignment.centerRight,
          child: OutlinedButton.icon(
            onPressed: isSaving ? null : onReply,
            icon: isSaving
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.reply_rounded, size: 18),
            label: Text(hasReply ? 'Edit reply' : 'Reply'),
          ),
        ),
      ],
    );
  }
}

class _MetricPill extends StatelessWidget {
  const _MetricPill({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: TripwiseColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: TripwiseColors.primary),
          const SizedBox(width: 6),
          Text(label, style: const TextStyle(fontWeight: FontWeight.w800)),
        ],
      ),
    );
  }
}

class _SheetSectionTitle extends StatelessWidget {
  const _SheetSectionTitle(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: Theme.of(context)
          .textTheme
          .titleMedium
          ?.copyWith(fontWeight: FontWeight.w900),
    );
  }
}

class _NoReviewsCard extends StatelessWidget {
  const _NoReviewsCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: TripwiseColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Text(
        'No guest reviews yet.',
        style: TextStyle(color: TripwiseColors.onSurfaceVariant),
      ),
    );
  }
}

class _DetailLoadError extends StatelessWidget {
  const _DetailLoadError({required this.error});

  final Object? error;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 28),
      child: Column(
        children: [
          const Icon(
            Icons.cloud_off_rounded,
            color: TripwiseColors.onSurfaceVariant,
            size: 40,
          ),
          const SizedBox(height: 10),
          Text(
            error?.toString() ?? 'Could not load listing details.',
            textAlign: TextAlign.center,
            style: const TextStyle(color: TripwiseColors.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}

String _statusLabel(String status) {
  if (status == 'inactive') return 'Inactive';
  if (status == 'pending') return 'Pending Review';
  return 'Active';
}

class _ListingImagePreview extends StatelessWidget {
  const _ListingImagePreview({
    required this.imageUrl,
    required this.fallbackSeed,
    required this.width,
    required this.height,
  });

  final String imageUrl;
  final String fallbackSeed;
  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    final url = imageUrl.trim();
    if (url.isEmpty) {
      return _fallback();
    }
    if (url.startsWith('data:image')) {
      final commaIdx = url.indexOf(',');
      if (commaIdx <= 0) return _fallback();
      try {
        final bytes = base64Decode(url.substring(commaIdx + 1));
        return Image.memory(
          bytes,
          width: width,
          height: height,
          fit: BoxFit.cover,
        );
      } catch (_) {
        return _fallback();
      }
    }
    return TripwiseNetworkImage(
      imageUrl: url,
      fallbackSeed: fallbackSeed,
      width: width,
      height: height,
      fit: BoxFit.cover,
      placeholderColor: TripwiseColors.surfaceContainerLow,
    );
  }

  Widget _fallback() {
    return TripwiseNetworkImage(
      imageUrl: null,
      fallbackSeed: fallbackSeed,
      width: width,
      height: height,
      fit: BoxFit.cover,
      placeholderColor: TripwiseColors.surfaceContainerLow,
    );
  }
}

class _ListingCardMenu extends StatelessWidget {
  const _ListingCardMenu({
    required this.item,
    required this.onSelected,
  });

  final ProviderListingSummary item;
  final ValueChanged<_ListingCardAction> onSelected;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<_ListingCardAction>(
      tooltip: 'Listing actions',
      onSelected: onSelected,
      padding: EdgeInsets.zero,
      child: const SizedBox(
        width: 18,
        height: 18,
        child: Icon(
          Icons.more_vert_rounded,
          size: 16,
          color: TripwiseColors.onSurfaceVariant,
        ),
      ),
      itemBuilder: (context) => [
        const PopupMenuItem<_ListingCardAction>(
          value: _ListingCardAction.edit,
          child: _MenuLabel(
            icon: Icons.edit_rounded,
            label: 'Edit listing',
          ),
        ),
        const PopupMenuItem<_ListingCardAction>(
          value: _ListingCardAction.analytics,
          child: _MenuLabel(
            icon: Icons.analytics_rounded,
            label: 'View analytics',
          ),
        ),
        if (item.status == 'inactive')
          const PopupMenuItem<_ListingCardAction>(
            value: _ListingCardAction.activate,
            child: _MenuLabel(
              icon: Icons.publish_rounded,
              label: 'Reopen receiving orders',
            ),
          )
        else
          const PopupMenuItem<_ListingCardAction>(
            value: _ListingCardAction.deactivate,
            child: _MenuLabel(
              icon: Icons.visibility_off_rounded,
              label: 'Close receiving orders',
            ),
          ),
        const PopupMenuDivider(height: 8),
        const PopupMenuItem<_ListingCardAction>(
          value: _ListingCardAction.delete,
          child: _MenuLabel(
            icon: Icons.delete_rounded,
            label: 'Delete listing',
            danger: true,
          ),
        ),
      ],
    );
  }
}

class _MenuLabel extends StatelessWidget {
  const _MenuLabel({
    required this.icon,
    required this.label,
    this.danger = false,
  });

  final IconData icon;
  final String label;
  final bool danger;

  @override
  Widget build(BuildContext context) {
    final color = danger ? TripwiseColors.error : TripwiseColors.onSurface;
    return Row(
      children: [
        Icon(icon, size: 18, color: color),
        const SizedBox(width: 8),
        Text(label, style: TextStyle(color: color)),
      ],
    );
  }
}

enum _ListingCardAction {
  edit,
  analytics,
  activate,
  deactivate,
  delete,
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status, required this.raw});

  final String status;
  final String raw;

  @override
  Widget build(BuildContext context) {
    final Color bg;
    final Color fg;
    if (raw == 'inactive') {
      bg = TripwiseColors.surfaceContainerHighest;
      fg = TripwiseColors.onSurfaceVariant;
    } else if (raw == 'pending') {
      bg = TripwiseColors.secondaryFixed;
      fg = TripwiseColors.onSecondaryFixedVariant;
    } else {
      bg = TripwiseColors.primaryFixed;
      fg = TripwiseColors.onPrimaryFixedVariant;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        status,
        style: TextStyle(color: fg, fontSize: 11, fontWeight: FontWeight.w700),
      ),
    );
  }
}

class _ListingTab {
  const _ListingTab({required this.status, required this.label});

  final String status;
  final String label;
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
