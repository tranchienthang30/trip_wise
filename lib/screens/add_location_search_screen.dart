import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../constants/colors.dart';
import '../models/search_data.dart';
import '../services/search_api.dart';
import '../utils/tripwise_image_provider.dart';

const String _flightTileAssetPath = 'assets/images/flight_plane_v2.jpg';
const double _searchTileImageWidth = 116;
const double _searchTileImageHeight = 116;
const double _flightTileCompactHeight = 132;
const double _flightTileZoom = 1.28;

class AddLocationSearchScreen extends StatefulWidget {
  const AddLocationSearchScreen({
    super.key,
    this.initialCategory = 'all',
    this.initialQuery = '',
    this.startDate,
    this.endDate,
    this.guests,
  });

  final String initialCategory;
  final String initialQuery;
  final String? startDate;
  final String? endDate;
  final String? guests;

  @override
  State<AddLocationSearchScreen> createState() => _AddLocationSearchScreenState();
}

class _AddLocationSearchScreenState extends State<AddLocationSearchScreen> {
  final SearchApi _api = SearchApi();
  late final TextEditingController _searchController;
  Timer? _debounce;
  late String _category;
  SearchData? _data;
  Object? _error;
  bool _isLoading = false;
  int _requestSerial = 0;

  @override
  void initState() {
    super.initState();
    _category = widget.initialCategory;
    _searchController = TextEditingController(text: widget.initialQuery);
    _refresh();
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

  Future<void> _refresh() async {
    final requestId = ++_requestSerial;
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final data = await _load();
      if (!mounted || requestId != _requestSerial) return;
      setState(() {
        _data = data;
        _isLoading = false;
      });
    } catch (error) {
      if (!mounted || requestId != _requestSerial) return;
      setState(() {
        _error = error;
        _isLoading = false;
      });
    }
  }

  void _onQueryChanged(String value) {
    _debounce?.cancel();
    setState(() {});
    _debounce = Timer(const Duration(milliseconds: 300), _refresh);
  }

  void _selectCategory(String category) {
    if (_category == category) {
      return;
    }

    setState(() {
      _category = category;
    });
    _refresh();
  }

  void _applyDestination(SearchDestinationItem item) {
    _searchController.text = item.queryValue;
    _searchController.selection = TextSelection.collapsed(
      offset: _searchController.text.length,
    );
    _refresh();
  }

  String _checkoutRoute({
    required String type,
    required int id,
  }) {
    final query = <String, String>{'type': type};
    if (type == 'flight') {
      query['flightId'] = id.toString();
    } else {
      query['activityId'] = id.toString();
    }

    final startDate = widget.startDate?.trim();
    final endDate = widget.endDate?.trim();
    final guests = widget.guests?.trim();
    if (startDate != null && startDate.isNotEmpty) query['startDate'] = startDate;
    if (endDate != null && endDate.isNotEmpty) query['endDate'] = endDate;
    if (guests != null && guests.isNotEmpty) query['guests'] = guests;

    return Uri(path: '/booking_checkout', queryParameters: query).toString();
  }

  String _routeWithTripParams(String route) {
    final uri = Uri.parse(route);
    final query = <String, String>{...uri.queryParameters};
    final startDate = widget.startDate?.trim();
    final endDate = widget.endDate?.trim();
    final guests = widget.guests?.trim();

    if (startDate != null && startDate.isNotEmpty) {
      query['startDate'] = startDate;
    }
    if (endDate != null && endDate.isNotEmpty) {
      query['endDate'] = endDate;
    }
    if (guests != null && guests.isNotEmpty) {
      query['guests'] = guests;
    }

    return uri.replace(queryParameters: query).toString();
  }

  void _showTravelPreview({
    required String typeLabel,
    required IconData icon,
    required String title,
    required String subtitle,
    required String valueLabel,
    required String metaLabel,
    required String checkoutRoute,
  }) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return SafeArea(
          child: Container(
            margin: const EdgeInsets.all(12),
            padding: const EdgeInsets.fromLTRB(18, 12, 18, 18),
            decoration: BoxDecoration(
              color: TripwiseColors.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(26),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.14),
                  blurRadius: 26,
                  offset: const Offset(0, 14),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 38,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 14),
                    decoration: BoxDecoration(
                      color: TripwiseColors.outlineVariant,
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: TripwiseColors.primaryFixed,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(icon, color: TripwiseColors.primary),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            typeLabel.toUpperCase(),
                            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                  color: TripwiseColors.primary,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 1.1,
                                ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            title,
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.w900,
                                  height: 1.08,
                                ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            subtitle,
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: TripwiseColors.onSurfaceVariant,
                                  height: 1.35,
                                ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    _PreviewPill(
                      icon: Icons.payments_rounded,
                      label: valueLabel,
                    ),
                    _PreviewPill(
                      icon: Icons.schedule_rounded,
                      label: metaLabel,
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(sheetContext).pop();
                      context.push(checkoutRoute);
                    },
                    style: TripwiseButtonStyles.primaryElevated(radius: 14),
                    child: const Text('Continue to booking'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  List<SearchCategoryChip> get _fallbackCategories {
    return [
      SearchCategoryChip(key: 'all', label: 'All', enabled: true),
      SearchCategoryChip(key: 'hotels', label: 'Hotels', enabled: true),
      SearchCategoryChip(key: 'flights', label: 'Flights', enabled: true),
      SearchCategoryChip(key: 'tours', label: 'Tours', enabled: true),
      SearchCategoryChip(key: 'train', label: 'Train', enabled: false),
    ];
  }

  List<Widget> _buildResultWidgets(SearchData data) {
    return [
      // Destinations are generic location suggestions and only make sense on
      // the unfiltered ("All") tab. Hiding them on category tabs keeps results
      // focused on the chosen category.
      if (_category == 'all' && data.destinations.isNotEmpty) ...[
        const _SearchSectionHeader(
          title: 'Popular Destinations',
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
        ),
        const SizedBox(height: 14),
        ...data.hotels.map(
          (item) => Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: _HotelResultTile(
              item: item,
              onTap: () => context.push(_routeWithTripParams(item.route)),
            ),
          ),
        ),
        const SizedBox(height: 20),
      ],
      if (data.flights.isNotEmpty) ...[
        const _SearchSectionHeader(
          title: 'Flight Matches',
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
              usePlaneImage: true,
              onTap: () => _showTravelPreview(
                typeLabel: 'Flight',
                icon: Icons.flight_takeoff_rounded,
                title: item.title,
                subtitle: item.subtitle,
                valueLabel: item.valueLabel,
                metaLabel: item.metaLabel,
                checkoutRoute: _checkoutRoute(type: 'flight', id: item.id),
              ),
            ),
          ),
        ),
        const SizedBox(height: 20),
      ],
      if (data.tours.isNotEmpty) ...[
        const _SearchSectionHeader(
          title: 'Tour Matches',
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
              onTap: () => _showTravelPreview(
                typeLabel: 'Tour',
                icon: Icons.explore_rounded,
                title: item.title,
                subtitle: item.subtitle,
                valueLabel: item.valueLabel,
                metaLabel: item.metaLabel,
                checkoutRoute: _checkoutRoute(type: 'activity', id: item.id),
              ),
            ),
          ),
        ),
        const SizedBox(height: 20),
      ],
      if (_category == 'train' || _hasNoResults(data))
        _SearchEmptyState(category: _category),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final data = _data;
    final categories =
        data?.categories.isNotEmpty == true ? data!.categories : _fallbackCategories;

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
      body: SafeArea(
        top: false,
        child: ListView(
          padding: TripwiseInsets.screen,
          children: [
            _SearchInput(
              controller: _searchController,
              hintText: _searchHint(_category),
              onChanged: _onQueryChanged,
              onClear: () {
                _debounce?.cancel();
                _searchController.clear();
                setState(() {});
                _refresh();
              },
            ),
            const SizedBox(height: 18),
            _CategoryFilterBar(
              items: categories,
              selectedCategory: _category,
              onSelect: _selectCategory,
            ),
            const SizedBox(height: 18),
            if (_isLoading) const _SearchLoadingNotice(),
            if (_error != null && data != null) ...[
              _SearchInlineError(error: _error, onRetry: _refresh),
              const SizedBox(height: 14),
            ],
            if (data == null && _isLoading) const _SearchInitialLoading()
            else if (data == null && _error != null)
              _SearchErrorView(error: _error, onRetry: _refresh)
            else if (data != null) ...[
              const SizedBox(height: 6),
              ..._buildResultWidgets(data),
            ],
          ],
        ),
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

class _PreviewPill extends StatelessWidget {
  const _PreviewPill({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      decoration: BoxDecoration(
        color: TripwiseColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: TripwiseColors.primary),
          const SizedBox(width: 6),
          Text(
            label,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
          ),
        ],
      ),
    );
  }
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

class _CategoryFilterBar extends StatelessWidget {
  const _CategoryFilterBar({
    required this.items,
    required this.selectedCategory,
    required this.onSelect,
  });

  static const double _chipGap = 8;

  final List<SearchCategoryChip> items;
  final String selectedCategory;
  final ValueChanged<String> onSelect;

  List<SearchCategoryChip> get _primaryItems {
    const keys = ['all', 'hotels', 'flights'];
    final byKey = {for (final item in items) item.key: item};
    final primary = [
      for (final key in keys)
        if (byKey[key] != null) byKey[key]!,
    ];
    if (primary.length >= 3) return primary;
    return [
      ...primary,
      for (final item in items)
        if (!primary.any((p) => p.key == item.key)) item,
    ].take(3).toList();
  }

  List<SearchCategoryChip> get _moreItems {
    final primaryKeys = _primaryItems.map((item) => item.key).toSet();
    return [
      for (final item in items)
        if (!primaryKeys.contains(item.key)) item,
    ];
  }

  void _openMoreCategories(BuildContext context) {
    final moreItems = _moreItems;
    if (moreItems.isEmpty) return;

    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return SafeArea(
          child: Container(
            margin: const EdgeInsets.all(12),
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
            decoration: BoxDecoration(
              color: TripwiseColors.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.12),
                  blurRadius: 24,
                  offset: const Offset(0, 12),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 36,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 10),
                  decoration: BoxDecoration(
                    color: TripwiseColors.outlineVariant,
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
                for (final item in moreItems)
                  _MoreCategoryTile(
                    item: item,
                    isSelected: item.key == selectedCategory,
                    onTap: item.enabled
                        ? () {
                            Navigator.of(sheetContext).pop();
                            onSelect(item.key);
                          }
                        : null,
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final primaryItems = _primaryItems;
    final moreItems = _moreItems;
    final isMoreSelected = moreItems.any(
      (item) => item.key == selectedCategory,
    );

    return Row(
      children: [
        for (final item in primaryItems) ...[
          Expanded(
            child: _CategoryFilterChip(
              item: item,
              isSelected: item.key == selectedCategory,
              onTap: item.enabled ? () => onSelect(item.key) : null,
            ),
          ),
          const SizedBox(width: _chipGap),
        ],
        Expanded(
          child: _MoreFilterChip(
            isSelected: isMoreSelected,
            onTap: moreItems.isEmpty ? null : () => _openMoreCategories(context),
          ),
        ),
      ],
    );
  }
}

class _MoreCategoryTile extends StatelessWidget {
  const _MoreCategoryTile({
    required this.item,
    required this.isSelected,
    required this.onTap,
  });

  final SearchCategoryChip item;
  final bool isSelected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final enabled = item.enabled && onTap != null;
    final foreground = enabled
        ? TripwiseColors.onSurface
        : TripwiseColors.outline;

    return ListTile(
      enabled: enabled,
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 4),
      leading: Icon(
        _categoryIcon(item.key),
        color: enabled ? TripwiseColors.primary : TripwiseColors.outline,
      ),
      title: Text(
        item.label,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: foreground,
              fontWeight: FontWeight.w800,
            ),
      ),
      trailing: isSelected
          ? const Icon(
              Icons.check_circle_rounded,
              color: TripwiseColors.primary,
            )
          : item.enabled
              ? null
              : const Icon(
                  Icons.lock_rounded,
                  color: TripwiseColors.outline,
                  size: 20,
                ),
    );
  }
}

IconData _categoryIcon(String key) {
  switch (key) {
    case 'tours':
      return Icons.explore_rounded;
    case 'train':
      return Icons.train_rounded;
    case 'hotels':
      return Icons.hotel_rounded;
    case 'flights':
      return Icons.flight_takeoff_rounded;
    default:
      return Icons.grid_view_rounded;
  }
}

class _MoreFilterChip extends StatelessWidget {
  const _MoreFilterChip({
    required this.isSelected,
    required this.onTap,
  });

  static const double _height = 38;
  static const double _horizontalPadding = 8;
  static const double _iconTextGap = 4;

  final bool isSelected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final foreground =
        isSelected ? TripwiseColors.onPrimary : TripwiseColors.primary;

    return Material(
      color: isSelected
          ? TripwiseColors.primary
          : TripwiseColors.surfaceContainerLow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(22),
        side: BorderSide(
          color: isSelected
              ? TripwiseColors.primary
              : TripwiseColors.outlineVariant,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(22),
        child: SizedBox(
          height: _height,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: _horizontalPadding,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.add_rounded, size: 15, color: foreground),
                const SizedBox(width: _iconTextGap),
                Flexible(
                  child: Text(
                    'More',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: foreground,
                        ),
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

class _CategoryFilterChip extends StatelessWidget {
  const _CategoryFilterChip({
    required this.item,
    required this.isSelected,
    required this.onTap,
  });

  static const double _height = 38;
  static const double _horizontalPadding = 8;
  static const double _iconTextGap = 4;

  final SearchCategoryChip item;
  final bool isSelected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final enabled = item.enabled && onTap != null;
    final foreground = isSelected
        ? TripwiseColors.onPrimary
        : enabled
            ? TripwiseColors.primary
            : TripwiseColors.outline;

    return Material(
      color: isSelected
          ? TripwiseColors.primary
          : enabled
              ? TripwiseColors.surfaceContainerLow
              : TripwiseColors.surfaceContainerHigh,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(22),
        side: BorderSide(
          color: isSelected
              ? TripwiseColors.primary
              : TripwiseColors.outlineVariant,
        ),
      ),
      child: InkWell(
        onTap: enabled ? onTap : null,
        borderRadius: BorderRadius.circular(22),
        child: SizedBox(
          height: _height,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: _horizontalPadding,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (isSelected) ...[
                  Icon(Icons.check_rounded, size: 14, color: foreground),
                  const SizedBox(width: _iconTextGap),
                ],
                Flexible(
                  child: Text(
                    item.label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: foreground,
                        ),
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

class _SearchSectionHeader extends StatelessWidget {
  const _SearchSectionHeader({
    required this.title,
  });

  final String title;

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
      ],
    );
  }
}

String _compactFlightMetaLabel(String value) {
  final parts = value
      .split('•')
      .map((e) => e.trim())
      .where((e) => e.isNotEmpty)
      .toList();
  if (parts.isEmpty) return value;
  if (parts.length == 1) return parts.first;
  final timePart = parts[1].split('-').first.trim();
  return '${parts.first} • $timePart';
}

String _flightMetaLabelForCard(String value) {
  final normalized = value.replaceAll('â€¢', '•');
  final parts = normalized
      .split('•')
      .map((e) => e.trim())
      .where((e) => e.isNotEmpty)
      .toList();
  if (parts.isEmpty) return normalized;
  if (parts.length == 1) return parts.first;
  final timePart = parts[1].split('-').first.trim();
  return '${parts.first} • $timePart';
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
    this.usePlaneImage = false,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final String valueLabel;
  final String metaLabel;
  final String? imageUrl;
  final VoidCallback onTap;
  final bool usePlaneImage;

  @override
  Widget build(BuildContext context) {
    const double? tileHeight = null;
    final imageHeight =
        usePlaneImage ? _flightTileCompactHeight : _searchTileImageHeight;
    final contentPadding = usePlaneImage
        ? const EdgeInsets.symmetric(horizontal: 14, vertical: 8)
        : const EdgeInsets.all(16);
    final displayMetaLabel = usePlaneImage
        ? _flightMetaLabelForCard(metaLabel)
        : metaLabel;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        height: tileHeight,
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
            _SearchTileImage(
              imageUrl: imageUrl,
              forcePlaneImage: usePlaneImage,
              height: imageHeight,
            ),
            Expanded(
              child: Padding(
                padding: contentPadding,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
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
                    SizedBox(height: usePlaneImage ? 4 : 6),
                    Text(
                      subtitle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: TripwiseColors.onSurfaceVariant,
                          ),
                    ),
                    SizedBox(height: usePlaneImage ? 6 : 10),
                    if (usePlaneImage)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            valueLabel,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                  color: TripwiseColors.primary,
                                  fontWeight: FontWeight.w900,
                                ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            displayMetaLabel,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: TripwiseColors.onSurfaceVariant,
                                ),
                          ),
                        ],
                      )
                    else
                      Row(
                        children: [
                          Flexible(
                            fit: FlexFit.loose,
                            child: Text(
                              valueLabel,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                    color: TripwiseColors.primary,
                                    fontWeight: FontWeight.w900,
                                  ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              displayMetaLabel,
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
  const _SearchTileImage({
    required this.imageUrl,
    this.forcePlaneImage = false,
    this.height = _searchTileImageHeight,
  });

  final String? imageUrl;
  final bool forcePlaneImage;
  final double height;

  @override
  Widget build(BuildContext context) {
    if (forcePlaneImage) {
      return ClipRRect(
        borderRadius: const BorderRadius.horizontal(left: Radius.circular(20)),
        child: SizedBox(
          width: _searchTileImageWidth,
          height: height,
          child: Transform.scale(
            scale: _flightTileZoom,
            child: Image.asset(
              _flightTileAssetPath,
              width: _searchTileImageWidth,
              height: height,
              fit: BoxFit.cover,
              alignment: Alignment.center,
              errorBuilder: (_, __, ___) => Container(
                width: _searchTileImageWidth,
                height: height,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Color(0xFFB3E5FC),
                      Color(0xFFE3F2FD),
                    ],
                  ),
                ),
                alignment: Alignment.center,
                child: const Icon(
                  Icons.flight_rounded,
                  size: 42,
                  color: TripwiseColors.primary,
                ),
              ),
            ),
          ),
        ),
      );
    }

    final imageProvider = tripwiseImageProvider(imageUrl);
    if (imageProvider == null) {
      return Container(
        width: _searchTileImageWidth,
        height: height,
        color: TripwiseColors.surfaceContainerLow,
        alignment: Alignment.center,
        child: const Icon(
          Icons.image_rounded,
          color: TripwiseColors.onSurfaceVariant,
        ),
      );
    }

    return Image(
      image: imageProvider,
      width: _searchTileImageWidth,
      height: height,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => Container(
        width: _searchTileImageWidth,
        height: height,
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

class _SearchLoadingNotice extends StatelessWidget {
  const _SearchLoadingNotice();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        children: [
          const SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
          const SizedBox(width: 8),
          Text(
            'Updating results...',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: TripwiseColors.onSurfaceVariant,
                  fontWeight: FontWeight.w700,
                ),
          ),
        ],
      ),
    );
  }
}

class _SearchInitialLoading extends StatelessWidget {
  const _SearchInitialLoading();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.only(top: 80),
      child: Center(
        child: SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(strokeWidth: 2.4),
        ),
      ),
    );
  }
}

class _SearchInlineError extends StatelessWidget {
  const _SearchInlineError({
    required this.error,
    required this.onRetry,
  });

  final Object? error;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: TripwiseColors.errorContainer,
        borderRadius: BorderRadius.circular(12),
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
              error?.toString() ?? 'Unable to update results',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
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
