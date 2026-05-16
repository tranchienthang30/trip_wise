import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../constants/colors.dart';
import '../models/search_data.dart';
import '../services/search_api.dart';

class AddLocationSearchScreen extends StatefulWidget {
  const AddLocationSearchScreen({
    super.key,
    this.initialCategory = 'all',
    this.initialQuery = '',
  });

  final String initialCategory;
  final String initialQuery;

  @override
  State<AddLocationSearchScreen> createState() => _AddLocationSearchScreenState();
}

class _AddLocationSearchScreenState extends State<AddLocationSearchScreen> {
  final SearchApi _api = SearchApi();
  late final TextEditingController _searchController;
  Timer? _debounce;
  late String _category;
  late Future<SearchData> _future;

  @override
  void initState() {
    super.initState();
    _category = widget.initialCategory;
    _searchController = TextEditingController(text: widget.initialQuery);
    _future = _load();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  Future<SearchData> _load() {
    return _api.fetchSearch(
      query: _searchController.text,
      category: _category,
    );
  }

  void _refresh() {
    setState(() {
      _future = _load();
    });
  }

  void _onQueryChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), _refresh);
  }

  void _selectCategory(String category) {
    if (_category == category) {
      return;
    }

    setState(() {
      _category = category;
      _future = _load();
    });
  }

  void _applyDestination(SearchDestinationItem item) {
    _searchController.text = item.queryValue;
    _searchController.selection = TextSelection.collapsed(
      offset: _searchController.text.length,
    );
    _refresh();
  }

  void _showComingSoon(String label) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text('$label details will be available soon.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TripwiseColors.surface,
      appBar: AppBar(
        backgroundColor: TripwiseColors.surface,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: TripwiseColors.primary),
          onPressed: () => context.canPop() ? context.pop() : context.go('/home'),
        ),
        title: Text(
          _screenTitle(_category),
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: TripwiseColors.primary,
                fontWeight: FontWeight.w800,
              ),
        ),
      ),
      body: FutureBuilder<SearchData>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return _SearchErrorView(
              error: snapshot.error,
              onRetry: _refresh,
            );
          }

          final data = snapshot.data!;

          return SafeArea(
            top: false,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
              children: [
                _SearchInput(
                  controller: _searchController,
                  hintText: _searchHint(_category),
                  onChanged: _onQueryChanged,
                  onClear: () {
                    _searchController.clear();
                    _refresh();
                  },
                ),
                const SizedBox(height: 18),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: data.categories
                      .map(
                        (item) => _CategoryFilterChip(
                          item: item,
                          isSelected: item.key == _category,
                          onTap: item.enabled ? () => _selectCategory(item.key) : null,
                        ),
                      )
                      .toList(),
                ),
                const SizedBox(height: 24),
                if (data.destinations.isNotEmpty) ...[
                  const _SearchSectionHeader(
                    title: 'Popular Destinations',
                    subtitle: 'Suggestions pulled from real location data',
                  ),
                  const SizedBox(height: 14),
                  ...data.destinations.map(
                    (item) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _DestinationTile(
                        item: item,
                        onTap: () => _applyDestination(item),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
                if (data.hotels.isNotEmpty) ...[
                  const _SearchSectionHeader(
                    title: 'Hotel Matches',
                    subtitle: 'Backed by hotels and room prices from the database',
                  ),
                  const SizedBox(height: 14),
                  ...data.hotels.map(
                    (item) => Padding(
                      padding: const EdgeInsets.only(bottom: 14),
                      child: _HotelResultTile(
                        item: item,
                        onTap: () => context.push(item.route),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
                if (data.flights.isNotEmpty) ...[
                  const _SearchSectionHeader(
                    title: 'Flight Matches',
                    subtitle: 'Showing real flights from the flights collection',
                  ),
                  const SizedBox(height: 14),
                  ...data.flights.map(
                    (item) => Padding(
                      padding: const EdgeInsets.only(bottom: 14),
                      child: _TravelResultTile(
                        icon: Icons.flight_takeoff_rounded,
                        title: item.title,
                        subtitle: item.subtitle,
                        valueLabel: item.valueLabel,
                        metaLabel: item.metaLabel,
                        imageUrl: item.imageUrl,
                        onTap: () => _showComingSoon('Flight'),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
                if (data.tours.isNotEmpty) ...[
                  const _SearchSectionHeader(
                    title: 'Tour Matches',
                    subtitle: 'Showing real tour/activity records from the database',
                  ),
                  const SizedBox(height: 14),
                  ...data.tours.map(
                    (item) => Padding(
                      padding: const EdgeInsets.only(bottom: 14),
                      child: _TravelResultTile(
                        icon: Icons.explore_rounded,
                        title: item.title,
                        subtitle: item.subtitle,
                        valueLabel: item.valueLabel,
                        metaLabel: item.metaLabel,
                        imageUrl: item.imageUrl,
                        onTap: () => _showComingSoon('Tour'),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
                if (_category == 'train' || _hasNoResults(data))
                  _SearchEmptyState(category: _category),
              ],
            ),
          );
        },
      ),
    );
  }
}

bool _hasNoResults(SearchData data) {
  return data.destinations.isEmpty &&
      data.hotels.isEmpty &&
      data.flights.isEmpty &&
      data.tours.isEmpty;
}

String _screenTitle(String category) {
  switch (category) {
    case 'hotels':
      return 'Hotel Search';
    case 'flights':
      return 'Flight Search';
    case 'tours':
      return 'Tour Search';
    case 'train':
      return 'Train Search';
    default:
      return 'Trip Search';
  }
}

String _searchHint(String category) {
  switch (category) {
    case 'hotels':
      return 'Search hotels or destinations';
    case 'flights':
      return 'Search routes, airports, or flight numbers';
    case 'tours':
      return 'Search tours or activities';
    case 'train':
      return 'Train data will be added soon';
    default:
      return 'Search hotels, flights, tours, or destinations';
  }
}

class _SearchInput extends StatelessWidget {
  const _SearchInput({
    required this.controller,
    required this.hintText,
    required this.onChanged,
    required this.onClear,
  });

  final TextEditingController controller;
  final String hintText;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: TripwiseColors.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(28),
      ),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        decoration: InputDecoration(
          hintText: hintText,
          prefixIcon: const Icon(Icons.search_rounded),
          suffixIcon: controller.text.isEmpty
              ? null
              : IconButton(
                  onPressed: onClear,
                  icon: const Icon(Icons.close_rounded),
                ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(28),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }
}

class _CategoryFilterChip extends StatelessWidget {
  const _CategoryFilterChip({
    required this.item,
    required this.isSelected,
    required this.onTap,
  });

  final SearchCategoryChip item;
  final bool isSelected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      label: Text(item.label),
      selected: isSelected,
      onSelected: item.enabled && onTap != null ? (_) => onTap!() : null,
      labelStyle: Theme.of(context).textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w700,
            color: isSelected
                ? TripwiseColors.onPrimary
                : item.enabled
                    ? TripwiseColors.primary
                    : TripwiseColors.outline,
          ),
      selectedColor: TripwiseColors.primary,
      backgroundColor: TripwiseColors.surfaceContainerLow,
      disabledColor: TripwiseColors.surfaceContainerHigh,
      side: BorderSide(
        color: isSelected ? TripwiseColors.primary : TripwiseColors.outlineVariant,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
      ),
    );
  }
}

class _SearchSectionHeader extends StatelessWidget {
  const _SearchSectionHeader({
    required this.title,
    required this.subtitle,
  });

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
              ),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: TripwiseColors.onSurfaceVariant,
              ),
        ),
      ],
    );
  }
}

class _DestinationTile extends StatelessWidget {
  const _DestinationTile({
    required this.item,
    required this.onTap,
  });

  final SearchDestinationItem item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: TripwiseColors.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: TripwiseColors.primary.withOpacity(0.05),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: TripwiseColors.primaryFixed,
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(
                Icons.location_on_rounded,
                color: TripwiseColors.primary,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item.subtitle,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: TripwiseColors.onSurfaceVariant,
                        ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.north_west_rounded,
              color: TripwiseColors.primary,
            ),
          ],
        ),
      ),
    );
  }
}

class _HotelResultTile extends StatelessWidget {
  const _HotelResultTile({
    required this.item,
    required this.onTap,
  });

  final SearchHotelItem item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        decoration: BoxDecoration(
          color: TripwiseColors.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: TripwiseColors.primary.withOpacity(0.05),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Row(
          children: [
            _SearchTileImage(imageUrl: item.imageUrl),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      item.locationLabel,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: TripwiseColors.onSurfaceVariant,
                          ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        const Icon(
                          Icons.star_rounded,
                          size: 16,
                          color: TripwiseColors.secondary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          item.ratingLabel,
                          style: Theme.of(context).textTheme.labelLarge?.copyWith(
                                color: TripwiseColors.secondary,
                                fontWeight: FontWeight.w800,
                              ),
                        ),
                        const Spacer(),
                        Text(
                          item.priceLabel ?? 'Price unavailable',
                          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                color: TripwiseColors.primary,
                                fontWeight: FontWeight.w900,
                              ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TravelResultTile extends StatelessWidget {
  const _TravelResultTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.valueLabel,
    required this.metaLabel,
    required this.imageUrl,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final String valueLabel;
  final String metaLabel;
  final String? imageUrl;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        decoration: BoxDecoration(
          color: TripwiseColors.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: TripwiseColors.primary.withOpacity(0.05),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Row(
          children: [
            _SearchTileImage(imageUrl: imageUrl),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          icon,
                          size: 15,
                          color: TripwiseColors.primary,
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w800,
                                ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      subtitle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: TripwiseColors.onSurfaceVariant,
                          ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Text(
                          valueLabel,
                          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                color: TripwiseColors.primary,
                                fontWeight: FontWeight.w900,
                              ),
                        ),
                        const Spacer(),
                        Expanded(
                          child: Text(
                            metaLabel,
                            textAlign: TextAlign.end,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: TripwiseColors.onSurfaceVariant,
                                ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SearchTileImage extends StatelessWidget {
  const _SearchTileImage({required this.imageUrl});

  final String? imageUrl;

  @override
  Widget build(BuildContext context) {
    if (imageUrl == null || imageUrl!.isEmpty) {
      return Container(
        width: 116,
        height: 116,
        color: TripwiseColors.surfaceContainerLow,
        alignment: Alignment.center,
        child: const Icon(
          Icons.image_rounded,
          color: TripwiseColors.onSurfaceVariant,
        ),
      );
    }

    return Image.network(
      imageUrl!,
      width: 116,
      height: 116,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => Container(
        width: 116,
        height: 116,
        color: TripwiseColors.surfaceContainerLow,
        alignment: Alignment.center,
        child: const Icon(
          Icons.broken_image_rounded,
          color: TripwiseColors.onSurfaceVariant,
        ),
      ),
    );
  }
}

class _SearchEmptyState extends StatelessWidget {
  const _SearchEmptyState({required this.category});

  final String category;

  @override
  Widget build(BuildContext context) {
    final title = category == 'train'
        ? 'Train data not available yet'
        : 'No matches found';
    final subtitle = category == 'train'
        ? 'The database currently has no train collection, so this category is temporarily disabled.'
        : 'Try another keyword or switch to a different category.';

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: TripwiseColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: TripwiseColors.primaryFixed,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.search_off_rounded,
              color: TripwiseColors.primary,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: TripwiseColors.onSurfaceVariant,
                ),
          ),
        ],
      ),
    );
  }
}

class _SearchErrorView extends StatelessWidget {
  const _SearchErrorView({
    required this.error,
    required this.onRetry,
  });

  final Object? error;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.cloud_off_rounded,
              size: 48,
              color: TripwiseColors.onSurfaceVariant,
            ),
            const SizedBox(height: 16),
            Text(
              'Unable to load search data',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              error?.toString() ?? 'Unknown error',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: TripwiseColors.onSurfaceVariant,
                  ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: onRetry,
              style: TripwiseButtonStyles.primaryElevated(),
              child: const Text('Try again'),
            ),
          ],
        ),
      ),
    );
  }
}
