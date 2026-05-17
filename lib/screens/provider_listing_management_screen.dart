import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../constants/colors.dart';
import '../models/provider_listing.dart';
import '../services/provider_listings_api.dart';
import '../widgets/shared_taskbars.dart';
import '../widgets/shared_top_bars.dart';

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
    final featured = data?.featured;

    return Scaffold(
      backgroundColor: TripwiseColors.surface,
      appBar: const ProviderAppBar(),
      body: RefreshIndicator(
        onRefresh: () => _loadListings(keepOldData: false),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Your Properties',
                        style: Theme.of(context).textTheme.displayMedium
                            ?.copyWith(fontWeight: FontWeight.w900),
                      ),
                    ),
                    IconButton(
                      onPressed: _isLoading ? null : _loadListings,
                      icon: _isLoading
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.refresh),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _searchController,
                  onChanged: _onSearchChanged,
                  decoration: InputDecoration(
                    hintText: 'Search your listings...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: TripwiseColors.surfaceContainerLow,
                    contentPadding: const EdgeInsets.all(16),
                  ),
                ),
                const SizedBox(height: 12),
                _buildStatusTabs(data),
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
                  if (featured != null) ...[
                    _FeaturedListingCard(listing: featured),
                    const SizedBox(height: 16),
                  ],
                  _buildListingCollection(
                    featuredId: featured?.id,
                    items: items,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/add_new_listing_form'),
        icon: const Icon(Icons.add),
        label: const Text('Add Listing'),
      ),
      bottomNavigationBar: const ProviderTaskbar(
        currentTab: ProviderTaskbarTab.listings,
      ),
    );
  }

  Widget _buildStatusTabs(ProviderListingsResponse? data) {
    final counts = data?.counts;

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: _tabs.map((tab) {
        final isSelected = _status == tab.status;
        final count = counts?.valueFor(tab.status) ?? 0;

        return ChoiceChip(
          selected: isSelected,
          label: Text('${tab.label} ($count)'),
          onSelected: (_) {
            if (_status == tab.status) return;
            setState(() => _status = tab.status);
            _loadListings();
          },
          selectedColor: TripwiseColors.primary,
          labelStyle: TextStyle(
            color: isSelected
                ? TripwiseColors.onPrimary
                : TripwiseColors.onSurfaceVariant,
            fontWeight: FontWeight.w700,
          ),
          backgroundColor: TripwiseColors.surfaceContainerLow,
          side: BorderSide(
            color: isSelected
                ? TripwiseColors.primary
                : TripwiseColors.outlineVariant,
          ),
        );
      }).toList(),
    );
  }

  Widget _buildListingCollection({
    required int? featuredId,
    required List<ProviderListingSummary> items,
  }) {
    final rows = items.where((item) => item.id != featuredId).toList();

    if (items.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 24),
        decoration: BoxDecoration(
          color: TripwiseColors.surfaceContainerLow,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: TripwiseColors.outlineVariant.withOpacity(0.35),
            width: 1.5,
          ),
        ),
        child: const Column(
          children: [
            Icon(
              Icons.add_business,
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

    if (rows.isEmpty) return const SizedBox.shrink();

    return Column(
      children: rows
          .map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _ListingRowCard(item: item),
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

class _FeaturedListingCard extends StatelessWidget {
  const _FeaturedListingCard({required this.listing});

  final ProviderListingSummary listing;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: TripwiseColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: TripwiseColors.primary.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            child: Image.network(
              listing.imageUrl,
              height: 180,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                height: 180,
                color: TripwiseColors.surfaceContainer,
                alignment: Alignment.center,
                child: const Icon(Icons.image_not_supported_outlined),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _StatusBadge(
                      status: listing.statusLabel,
                      raw: listing.status,
                    ),
                    Text(
                      listing.priceLabel,
                      style: const TextStyle(
                        color: TripwiseColors.primary,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  listing.title,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${listing.location} • ${listing.tierLabel}',
                  style: const TextStyle(
                    color: TripwiseColors.onSurfaceVariant,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => context.push(listing.editRoute),
                        style: TripwiseButtonStyles.surfaceElevated(
                          radius: 10,
                          foregroundColor: TripwiseColors.primary,
                          padding: const EdgeInsets.symmetric(vertical: 10),
                        ),
                        icon: const Icon(Icons.edit, size: 16),
                        label: const Text('Edit Listing'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => context.push(listing.analyticsRoute),
                        style: TripwiseButtonStyles.outlined(
                          radius: 10,
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          foregroundColor: TripwiseColors.onSurfaceVariant,
                          borderColor: TripwiseColors.outlineVariant,
                        ),
                        icon: const Icon(Icons.analytics_outlined, size: 16),
                        label: const Text('Analytics'),
                      ),
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

class _ListingRowCard extends StatelessWidget {
  const _ListingRowCard({required this.item});

  final ProviderListingSummary item;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: TripwiseColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.network(
              item.imageUrl,
              width: 84,
              height: 84,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                width: 84,
                height: 84,
                color: TripwiseColors.surfaceContainer,
                alignment: Alignment.center,
                child: const Icon(Icons.image_not_supported_outlined),
              ),
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
                    _StatusBadge(status: item.statusLabel, raw: item.status),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  item.location,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: TripwiseColors.onSurfaceVariant,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${item.category} • ${item.roomType}',
                  style: const TextStyle(
                    color: TripwiseColors.onSurfaceVariant,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Text(
                      item.priceLabel,
                      style: const TextStyle(
                        color: TripwiseColors.primary,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const Spacer(),
                    OutlinedButton(
                      onPressed: () => context.push(item.editRoute),
                      style: TripwiseButtonStyles.outlined(
                        radius: 8,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        foregroundColor: TripwiseColors.primary,
                        borderColor: TripwiseColors.primary,
                      ),
                      child: const Text('Edit'),
                    ),
                    const SizedBox(width: 8),
                    OutlinedButton(
                      onPressed: () => context.push(item.analyticsRoute),
                      style: TripwiseButtonStyles.outlined(
                        radius: 8,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        foregroundColor: TripwiseColors.onSurfaceVariant,
                        borderColor: TripwiseColors.outlineVariant,
                      ),
                      child: const Text('Analytics'),
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
