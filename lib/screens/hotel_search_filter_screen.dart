import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../constants/colors.dart';

class HotelSearchFilterScreen extends StatefulWidget {
  const HotelSearchFilterScreen({super.key});

  @override
  State<HotelSearchFilterScreen> createState() =>
      _HotelSearchFilterScreenState();
}

class _HotelSearchFilterScreenState extends State<HotelSearchFilterScreen> {
  static const List<_FilterChipData> _filterChips = [
    _FilterChipData(label: 'Filters', icon: Icons.tune_rounded),
    _FilterChipData(label: 'Price'),
    _FilterChipData(label: 'Rating'),
    _FilterChipData(label: 'Popularity', trailingIcon: Icons.expand_more),
  ];

  static const List<_HotelImageCardData> _hotelCards = [
    _HotelImageCardData(
      name: 'The Kayon Jungle Resort',
      location: 'Ubud, Bali',
      price: '\$320',
      priceValue: 320,
      rating: '4.9',
      ratingValue: 4.9,
      popularityScore: 98,
      badge: 'TOP PICK',
      showFromLabel: true,
      isHighlighted: true,
      markerAlignment: Alignment(-0.42, -0.22),
      imageUrl:
          'https://images.unsplash.com/photo-1566073771259-6a8506099945?auto=format&fit=crop&w=1200&q=80',
    ),
    _HotelImageCardData(
      name: 'Seminyak Beach Resort',
      location: 'Seminyak, Bali',
      price: '\$185',
      priceValue: 185,
      rating: '4.7',
      ratingValue: 4.7,
      popularityScore: 91,
      markerAlignment: Alignment(0.1, -0.05),
      imageUrl:
          'https://images.unsplash.com/photo-1522708323590-d24dbb6b0267?auto=format&fit=crop&w=1200&q=80',
    ),
    _HotelImageCardData(
      name: 'Bambu Indah Eco Resort',
      location: 'Sayan, Bali',
      price: '\$210',
      priceValue: 210,
      rating: '4.8',
      ratingValue: 4.8,
      popularityScore: 95,
      isHighlighted: true,
      markerAlignment: Alignment(-0.08, 0.28),
      imageUrl:
          'https://images.unsplash.com/photo-1448630360428-65456885c650?auto=format&fit=crop&w=1200&q=80',
    ),
  ];

  static const _HotelDetailCardData _featuredHotel = _HotelDetailCardData(
    name: 'Ametis Villa Bali',
    location: 'Canggu, Bali',
    description:
        'Exclusive private villas with personalized butler service in the heart of Canggu.',
    rating: '4.6',
    ratingValue: 4.6,
    reviewSummary: '(1.2k reviews)',
    price: '\$155',
    priceValue: 155,
    popularityScore: 90,
    badge: 'POPULAR',
    isHighlighted: true,
    markerAlignment: Alignment(0.42, 0.18),
    imageUrl:
        'https://images.unsplash.com/photo-1505693416388-ac5ce068fe85?auto=format&fit=crop&w=1200&q=80',
    amenities: [
      _AmenityData(icon: Icons.pool_rounded, label: 'Pool'),
      _AmenityData(icon: Icons.wifi_rounded, label: 'Free WiFi'),
      _AmenityData(icon: Icons.spa_rounded, label: 'Spa'),
      _AmenityData(icon: Icons.restaurant_rounded, label: 'Dining'),
    ],
  );

  _FilterSettings _filterSettings = _FilterSettings.defaults;
  _SearchSortMode _sortMode = _SearchSortMode.popularity;
  String _searchQuery = '';
  bool _isMapView = false;
  int _selectedBottomNavIndex = 2;

  List<_HotelImageCardData> get _visibleHotels {
    final visibleHotels = _hotelCards.where(_matchesHotelCard).toList();

    switch (_sortMode) {
      case _SearchSortMode.price:
        visibleHotels.sort(
          (left, right) => left.priceValue.compareTo(right.priceValue),
        );
        break;
      case _SearchSortMode.rating:
        visibleHotels.sort(
          (left, right) => right.ratingValue.compareTo(left.ratingValue),
        );
        break;
      case _SearchSortMode.popularity:
        visibleHotels.sort(
          (left, right) => right.popularityScore.compareTo(left.popularityScore),
        );
        break;
    }

    return visibleHotels;
  }

  bool get _showFeaturedHotel => _matchesFeaturedHotel(_featuredHotel);

  int get _visiblePropertyCount =>
      _visibleHotels.length + (_showFeaturedHotel ? 1 : 0);

  bool _matchesHotelCard(_HotelImageCardData hotel) {
    return _matchesSearchTokens([hotel.name, hotel.location]) &&
        hotel.priceValue <= _filterSettings.maxPrice &&
        hotel.ratingValue >= _filterSettings.minRating &&
        (!_filterSettings.onlyHighlighted || hotel.isHighlighted);
  }

  bool _matchesFeaturedHotel(_HotelDetailCardData hotel) {
    return _matchesSearchTokens([
          hotel.name,
          hotel.location,
          hotel.description,
          ...hotel.amenities.map((amenity) => amenity.label),
        ]) &&
        hotel.priceValue <= _filterSettings.maxPrice &&
        hotel.ratingValue >= _filterSettings.minRating &&
        (!_filterSettings.onlyHighlighted || hotel.isHighlighted);
  }

  bool _matchesSearchTokens(List<String> values) {
    final query = _searchQuery.trim().toLowerCase();
    if (query.isEmpty) {
      return true;
    }

    return values.any((value) => value.toLowerCase().contains(query));
  }

  bool _isChipSelected(int index) {
    switch (index) {
      case 0:
        return _filterSettings.hasActiveFilters;
      case 1:
        return _sortMode == _SearchSortMode.price;
      case 2:
        return _sortMode == _SearchSortMode.rating;
      case 3:
        return _sortMode == _SearchSortMode.popularity;
    }

    return false;
  }

  Future<void> _openSearchSheet() async {
    final controller = TextEditingController(text: _searchQuery);
    final result = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(sheetContext).viewInsets.bottom,
          ),
          child: _SheetShell(
            title: 'Search stays',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: controller,
                  autofocus: true,
                  textInputAction: TextInputAction.search,
                  onSubmitted: (value) =>
                      Navigator.of(sheetContext).pop(value.trim()),
                  decoration: InputDecoration(
                    hintText: 'Search hotels or destinations...',
                    prefixIcon: const Icon(Icons.search_rounded),
                    suffixIcon: controller.text.isEmpty
                        ? null
                        : IconButton(
                            onPressed: () {
                              controller.clear();
                            },
                            icon: const Icon(Icons.close_rounded),
                          ),
                  ),
                ),
                const SizedBox(height: 18),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.of(sheetContext).pop(''),
                        child: const Text('Clear'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => Navigator.of(sheetContext)
                            .pop(controller.text.trim()),
                        child: const Text('Apply'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
    controller.dispose();

    if (!mounted || result == null) {
      return;
    }

    setState(() {
      _searchQuery = result;
    });

    _showActionFeedback(
      result.isEmpty ? 'Search cleared.' : 'Showing results for "$result".',
    );
  }

  Future<void> _openFilterSheet() async {
    final result = await showModalBottomSheet<_FilterSettings>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        double draftMaxPrice = _filterSettings.maxPrice;
        double draftMinRating = _filterSettings.minRating;
        bool draftOnlyHighlighted = _filterSettings.onlyHighlighted;

        return StatefulBuilder(
          builder: (modalContext, setModalState) {
            return _SheetShell(
              title: 'Filter stays',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  _SheetValueRow(
                    label: 'Max price',
                    value: '\$${draftMaxPrice.round()}/night',
                  ),
                  Slider(
                    value: draftMaxPrice,
                    min: 150,
                    max: 400,
                    divisions: 10,
                    label: '\$${draftMaxPrice.round()}',
                    onChanged: (value) {
                      setModalState(() {
                        draftMaxPrice = value;
                      });
                    },
                  ),
                  const SizedBox(height: 10),
                  _SheetValueRow(
                    label: 'Minimum rating',
                    value: draftMinRating.toStringAsFixed(1),
                  ),
                  Slider(
                    value: draftMinRating,
                    min: 4.0,
                    max: 5.0,
                    divisions: 10,
                    label: draftMinRating.toStringAsFixed(1),
                    onChanged: (value) {
                      setModalState(() {
                        draftMinRating = value;
                      });
                    },
                  ),
                  const SizedBox(height: 8),
                  SwitchListTile.adaptive(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Highlighted stays only'),
                    subtitle: const Text('Top picks and popular properties'),
                    value: draftOnlyHighlighted,
                    activeColor: TripwiseColors.secondaryContainer,
                    onChanged: (value) {
                      setModalState(() {
                        draftOnlyHighlighted = value;
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            setModalState(() {
                              draftMaxPrice = _FilterSettings.defaults.maxPrice;
                              draftMinRating = _FilterSettings.defaults.minRating;
                              draftOnlyHighlighted =
                                  _FilterSettings.defaults.onlyHighlighted;
                            });
                          },
                          child: const Text('Reset'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => Navigator.of(sheetContext).pop(
                            _FilterSettings(
                              maxPrice: draftMaxPrice,
                              minRating: draftMinRating,
                              onlyHighlighted: draftOnlyHighlighted,
                            ),
                          ),
                          child: const Text('Apply'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );

    if (!mounted || result == null) {
      return;
    }

    setState(() {
      _filterSettings = result;
    });

    _showActionFeedback(
      result.hasActiveFilters
          ? 'Filters applied to hotel results.'
          : 'Filters reset to default.',
    );
  }

  void _applySort(_SearchSortMode mode) {
    setState(() {
      _sortMode = mode;
    });

    switch (mode) {
      case _SearchSortMode.price:
        _showActionFeedback('Sorted by price.');
        break;
      case _SearchSortMode.rating:
        _showActionFeedback('Sorted by rating.');
        break;
      case _SearchSortMode.popularity:
        _showActionFeedback('Sorted by popularity.');
        break;
    }
  }

  void _handleChipTap(int index) {
    switch (index) {
      case 0:
        _openFilterSheet();
        break;
      case 1:
        _applySort(_SearchSortMode.price);
        break;
      case 2:
        _applySort(_SearchSortMode.rating);
        break;
      case 3:
        _applySort(_SearchSortMode.popularity);
        break;
    }
  }

  void _toggleMapView() {
    setState(() {
      _isMapView = !_isMapView;
    });

    _showActionFeedback(
      _isMapView ? 'Map view enabled.' : 'List view enabled.',
    );
  }

  void _resetSearchAndFilters() {
    setState(() {
      _searchQuery = '';
      _filterSettings = _FilterSettings.defaults;
      _sortMode = _SearchSortMode.popularity;
      _isMapView = false;
    });

    _showActionFeedback('Search, filters, and view were reset.');
  }

  void _showHotelActions({
    required String name,
    required String location,
    required String price,
    required String rating,
  }) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return _SheetShell(
          title: name,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                location,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: TripwiseColors.onSurfaceVariant,
                    ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  _MiniInfoPill(
                    icon: Icons.star_rounded,
                    label: rating,
                    color: TripwiseColors.secondaryContainer,
                  ),
                  const SizedBox(width: 10),
                  _MiniInfoPill(
                    icon: Icons.account_balance_wallet_outlined,
                    label: '$price / night',
                    color: TripwiseColors.primary,
                  ),
                ],
              ),
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(sheetContext).pop();
                    context.push('/booking_checkout');
                  },
                  child: const Text('Continue To Booking'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _handleBackPressed() {
    if (context.canPop()) {
      context.pop();
      return;
    }

    context.go('/add_location_search');
  }

  void _handleBottomNavigationTap(int index) {
    setState(() {
      _selectedBottomNavIndex = index;
    });

    String routeName;

    switch (index) {
      case 0:
        routeName = '/home';
        break;
      case 1:
        routeName = '/my_trips';
        break;
      case 2:
        routeName = '/trip_planner_dashboard';
        break;
      case 3:
        routeName = '/wallet_loyalty';
        break;
      case 4:
        routeName = '/profile_registration';
        break;
      default:
        routeName = '/search_filter';
        break;
    }

    context.go(routeName);
  }

  void _showActionFeedback(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          behavior: SnackBarBehavior.floating,
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    final visibleHotels = _visibleHotels;
    final hasResults = visibleHotels.isNotEmpty || _showFeaturedHotel;

    return Scaffold(
      backgroundColor: TripwiseColors.surface,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 18),
        child: SizedBox(
          height: 56,
          child: ElevatedButton.icon(
            onPressed: _toggleMapView,
            style: ElevatedButton.styleFrom(
              backgroundColor: TripwiseColors.secondaryContainer,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 28),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(28),
              ),
              elevation: 0,
            ),
            icon: Icon(
              _isMapView ? Icons.view_agenda_outlined : Icons.map_outlined,
              size: 18,
            ),
            label: Text(
              _isMapView ? 'LIST VIEW' : 'MAP VIEW',
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.2,
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedBottomNavIndex,
        selectedItemColor: TripwiseColors.secondaryContainer,
        unselectedItemColor: TripwiseColors.onSurfaceVariant.withOpacity(0.6),
        selectedFontSize: 11,
        unselectedFontSize: 11,
        onTap: _handleBottomNavigationTap,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_rounded),
            label: 'HOME',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.flight_rounded),
            label: 'MY TRIPS',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.event_note_rounded),
            label: 'PLANNER',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_balance_wallet_outlined),
            label: 'WALLET',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_rounded),
            label: 'PROFILE',
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 132),
          children: [
            _Header(
              propertyCount: _visiblePropertyCount,
              onBackPressed: _handleBackPressed,
              onSearchPressed: _openSearchSheet,
              onFilterPressed: _openFilterSheet,
            ),
            const SizedBox(height: 22),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: List.generate(
                  _filterChips.length,
                  (index) => Padding(
                    padding: EdgeInsets.only(
                      right: index == _filterChips.length - 1 ? 0 : 10,
                    ),
                    child: _SearchFilterChip(
                      data: _filterChips[index],
                      isSelected: _isChipSelected(index),
                      onTap: () => _handleChipTap(index),
                    ),
                  ),
                ),
              ),
            ),
            if (_searchQuery.isNotEmpty || _filterSettings.hasActiveFilters) ...[
              const SizedBox(height: 14),
              _ActiveSearchSummary(
                searchQuery: _searchQuery,
                hasFilters: _filterSettings.hasActiveFilters,
                onClearAll: _resetSearchAndFilters,
              ),
            ],
            const SizedBox(height: 28),
            if (!hasResults)
              _EmptyStateCard(onReset: _resetSearchAndFilters)
            else if (_isMapView)
              _MapViewCard(
                markers: [
                  ...visibleHotels.map(
                    (hotel) => _MapMarkerData(
                      label: hotel.price,
                      alignment: hotel.markerAlignment,
                      highlighted: hotel.isHighlighted,
                    ),
                  ),
                  if (_showFeaturedHotel)
                    _MapMarkerData(
                      label: _featuredHotel.price,
                      alignment: _featuredHotel.markerAlignment,
                      highlighted: _featuredHotel.isHighlighted,
                    ),
                ],
                primaryHotelName: visibleHotels.isNotEmpty
                    ? visibleHotels.first.name
                    : _featuredHotel.name,
                primaryHotelLocation: visibleHotels.isNotEmpty
                    ? visibleHotels.first.location
                    : _featuredHotel.location,
                resultCount: _visiblePropertyCount,
              )
            else ...[
              ...visibleHotels.map(
                (hotel) => Padding(
                  padding: const EdgeInsets.only(bottom: 28),
                  child: _HotelImageCard(
                    data: hotel,
                    onTap: () => _showHotelActions(
                      name: hotel.name,
                      location: hotel.location,
                      price: hotel.price,
                      rating: hotel.rating,
                    ),
                  ),
                ),
              ),
              if (_showFeaturedHotel)
                _HotelDetailCard(
                  data: _featuredHotel,
                  onTap: () => _showHotelActions(
                    name: _featuredHotel.name,
                    location: _featuredHotel.location,
                    price: _featuredHotel.price,
                    rating: _featuredHotel.rating,
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }
}

enum _SearchSortMode {
  price,
  rating,
  popularity,
}

class _Header extends StatelessWidget {
  const _Header({
    required this.propertyCount,
    required this.onBackPressed,
    required this.onSearchPressed,
    required this.onFilterPressed,
  });

  final int propertyCount;
  final VoidCallback onBackPressed;
  final VoidCallback onSearchPressed;
  final VoidCallback onFilterPressed;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton(
          onPressed: onBackPressed,
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          color: TripwiseColors.primary,
          visualDensity: VisualDensity.compact,
        ),
        const SizedBox(width: 2),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Hotels in Bali',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: TripwiseColors.primary,
                      fontWeight: FontWeight.w800,
                    ),
              ),
              const SizedBox(height: 2),
              Text(
                '$propertyCount PROPERTIES FOUND',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: TripwiseColors.onSurfaceVariant.withOpacity(0.7),
                      letterSpacing: 2,
                    ),
              ),
            ],
          ),
        ),
        IconButton(
          onPressed: onSearchPressed,
          icon: const Icon(Icons.search_rounded),
          color: TripwiseColors.primary,
        ),
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onFilterPressed,
            borderRadius: BorderRadius.circular(21),
            child: Ink(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: const Color(0xFF121A24),
                shape: BoxShape.circle,
                border: Border.all(color: TripwiseColors.primary, width: 2),
              ),
              child: const Icon(
                Icons.tune_rounded,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _SearchFilterChip extends StatelessWidget {
  const _SearchFilterChip({
    required this.data,
    required this.isSelected,
    required this.onTap,
  });

  final _FilterChipData data;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isPrimaryChip = data.label == 'Filters';
    final backgroundColor = isSelected
        ? (isPrimaryChip
            ? TripwiseColors.secondaryContainer
            : TripwiseColors.surfaceContainerLowest)
        : TripwiseColors.surfaceContainerLowest;
    final foregroundColor = isSelected
        ? (isPrimaryChip ? Colors.white : TripwiseColors.primary)
        : TripwiseColors.onSurface;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Ink(
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isSelected
                  ? backgroundColor
                  : TripwiseColors.surfaceContainerHigh,
            ),
            boxShadow: isSelected && isPrimaryChip
                ? [
                    BoxShadow(
                      color: TripwiseColors.secondaryContainer.withOpacity(0.3),
                      blurRadius: 16,
                      offset: const Offset(0, 8),
                    ),
                  ]
                : null,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (data.icon != null) ...[
                Icon(data.icon, size: 18, color: foregroundColor),
                const SizedBox(width: 8),
              ],
              Text(
                data.label,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: foregroundColor,
                      fontWeight: FontWeight.w700,
                    ),
              ),
              if (data.trailingIcon != null) ...[
                const SizedBox(width: 6),
                Icon(data.trailingIcon, size: 18, color: foregroundColor),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _ActiveSearchSummary extends StatelessWidget {
  const _ActiveSearchSummary({
    required this.searchQuery,
    required this.hasFilters,
    required this.onClearAll,
  });

  final String searchQuery;
  final bool hasFilters;
  final VoidCallback onClearAll;

  @override
  Widget build(BuildContext context) {
    final summaryParts = <String>[
      if (searchQuery.isNotEmpty) 'Search: "$searchQuery"',
      if (hasFilters) 'Custom filters applied',
    ];

    return Container(
      decoration: BoxDecoration(
        color: TripwiseColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(18),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        children: [
          Expanded(
            child: Text(
              summaryParts.join('  |  '),
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: TripwiseColors.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ),
          const SizedBox(width: 12),
          TextButton(
            onPressed: onClearAll,
            child: const Text('Clear all'),
          ),
        ],
      ),
    );
  }
}

class _HotelImageCard extends StatelessWidget {
  const _HotelImageCard({
    required this.data,
    required this.onTap,
  });

  final _HotelImageCardData data;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(32),
              child: Stack(
                children: [
                  AspectRatio(
                    aspectRatio: 1.08,
                    child: Image.network(
                      data.imageUrl,
                      fit: BoxFit.cover,
                    ),
                  ),
                  Positioned(
                    top: 14,
                    right: 14,
                    child: _RatingBadge(rating: data.rating),
                  ),
                  if (data.badge != null)
                    Positioned(
                      left: 14,
                      bottom: 14,
                      child: Container(
                        decoration: BoxDecoration(
                          color: TripwiseColors.primary,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        child: Text(
                          data.badge!,
                          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 1,
                              ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    data.name,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w900,
                          height: 1.1,
                        ),
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    if (data.showFromLabel)
                      Text(
                        'from',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: TripwiseColors.onSurfaceVariant,
                            ),
                      ),
                    RichText(
                      text: TextSpan(
                        text: data.price,
                        style:
                            Theme.of(context).textTheme.headlineSmall?.copyWith(
                                  color: TripwiseColors.primary,
                                  fontWeight: FontWeight.w900,
                                ),
                        children: [
                          TextSpan(
                            text: '/night',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: TripwiseColors.onSurface,
                                ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(
                  Icons.location_on_rounded,
                  size: 16,
                  color: TripwiseColors.onSurfaceVariant,
                ),
                const SizedBox(width: 4),
                Text(
                  data.location,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: TripwiseColors.onSurfaceVariant,
                      ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _HotelDetailCard extends StatelessWidget {
  const _HotelDetailCard({
    required this.data,
    required this.onTap,
  });

  final _HotelDetailCardData data;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(32),
        child: Container(
          decoration: BoxDecoration(
            color: TripwiseColors.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(32),
            boxShadow: [
              BoxShadow(
                color: TripwiseColors.primary.withOpacity(0.08),
                blurRadius: 32,
                offset: const Offset(0, 14),
              ),
            ],
          ),
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(18),
                child: AspectRatio(
                  aspectRatio: 1.55,
                  child: Image.network(
                    data.imageUrl,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      data.name,
                      style:
                          Theme.of(context).textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.w900,
                              ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFE0D6),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    child: Text(
                      data.badge,
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: TripwiseColors.secondary,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.7,
                          ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                data.description,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: TripwiseColors.onSurfaceVariant,
                      height: 1.45,
                    ),
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 14,
                runSpacing: 10,
                children: data.amenities
                    .map(
                      (amenity) => Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            amenity.icon,
                            size: 18,
                            color: TripwiseColors.onSurface,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            amenity.label,
                            style:
                                Theme.of(context).textTheme.bodyMedium?.copyWith(
                                      fontWeight: FontWeight.w500,
                                    ),
                          ),
                        ],
                      ),
                    )
                    .toList(),
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  const Icon(
                    Icons.star_rounded,
                    size: 18,
                    color: TripwiseColors.secondaryContainer,
                  ),
                  const SizedBox(width: 4),
                  RichText(
                    text: TextSpan(
                      text: data.rating,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                      children: [
                        TextSpan(
                          text: ' ${data.reviewSummary}',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: TripwiseColors.onSurfaceVariant,
                              ),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  RichText(
                    text: TextSpan(
                      text: data.price,
                      style:
                          Theme.of(context).textTheme.headlineSmall?.copyWith(
                                color: TripwiseColors.primary,
                                fontWeight: FontWeight.w900,
                              ),
                      children: [
                        TextSpan(
                          text: '/night',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: TripwiseColors.onSurface,
                              ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MapViewCard extends StatelessWidget {
  const _MapViewCard({
    required this.markers,
    required this.primaryHotelName,
    required this.primaryHotelLocation,
    required this.resultCount,
  });

  final List<_MapMarkerData> markers;
  final String primaryHotelName;
  final String primaryHotelLocation;
  final int resultCount;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: 420,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(32),
            gradient: const LinearGradient(
              colors: [
                Color(0xFFD7E9FF),
                Color(0xFFF5F8FF),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Stack(
            children: [
              Positioned(
                top: 40,
                left: 18,
                right: 32,
                child: Container(
                  height: 14,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.36),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              Positioned(
                top: 112,
                left: 26,
                right: 16,
                child: Container(
                  height: 16,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.26),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              Positioned(
                bottom: 108,
                left: 30,
                right: 20,
                child: Container(
                  height: 18,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.32),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              Positioned(
                top: 20,
                right: 20,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.06),
                        blurRadius: 12,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  child: Text(
                    '$resultCount stays',
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                  ),
                ),
              ),
              ...markers.map(
                (marker) => Align(
                  alignment: marker.alignment,
                  child: _MapMarker(marker: marker),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        Container(
          decoration: BoxDecoration(
            color: TripwiseColors.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: TripwiseColors.primary.withOpacity(0.06),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: const BoxDecoration(
                  color: Color(0xFFE5F0FF),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.place_rounded,
                  color: TripwiseColors.primary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      primaryHotelName,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      primaryHotelLocation,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: TripwiseColors.onSurfaceVariant,
                          ),
                    ),
                  ],
                ),
              ),
              Text(
                'Pinned',
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: TripwiseColors.primary,
                      fontWeight: FontWeight.w800,
                    ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _MapMarker extends StatelessWidget {
  const _MapMarker({required this.marker});

  final _MapMarkerData marker;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          decoration: BoxDecoration(
            color: marker.highlighted
                ? TripwiseColors.secondaryContainer
                : TripwiseColors.primary,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.14),
                blurRadius: 14,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
          child: Text(
            marker.label,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                ),
          ),
        ),
        Container(
          width: 14,
          height: 14,
          margin: const EdgeInsets.only(top: 6),
          decoration: BoxDecoration(
            color: marker.highlighted
                ? TripwiseColors.secondaryContainer
                : TripwiseColors.primary,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 2),
          ),
        ),
      ],
    );
  }
}

class _EmptyStateCard extends StatelessWidget {
  const _EmptyStateCard({required this.onReset});

  final VoidCallback onReset;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: TripwiseColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: TripwiseColors.primary.withOpacity(0.05),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: const BoxDecoration(
              color: Color(0xFFE5F0FF),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.search_off_rounded,
              color: TripwiseColors.primary,
              size: 30,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'No stays found',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w900,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Try adjusting your search or clearing the current filters.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: TripwiseColors.onSurfaceVariant,
                  height: 1.4,
                ),
          ),
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onReset,
              child: const Text('Reset Search'),
            ),
          ),
        ],
      ),
    );
  }
}

class _RatingBadge extends StatelessWidget {
  const _RatingBadge({required this.rating});

  final String rating;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.96),
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.star_rounded,
            size: 16,
            color: TripwiseColors.secondaryContainer,
          ),
          const SizedBox(width: 4),
          Text(
            rating,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
          ),
        ],
      ),
    );
  }
}

class _SheetShell extends StatelessWidget {
  const _SheetShell({
    required this.title,
    required this.child,
  });

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 24),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 42,
                height: 4,
                decoration: BoxDecoration(
                  color: TripwiseColors.surfaceContainerHigh,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
            ),
            const SizedBox(height: 18),
            child,
          ],
        ),
      ),
    );
  }
}

class _SheetValueRow extends StatelessWidget {
  const _SheetValueRow({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w800,
              ),
        ),
        const Spacer(),
        Text(
          value,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                color: TripwiseColors.primary,
                fontWeight: FontWeight.w800,
              ),
        ),
      ],
    );
  }
}

class _MiniInfoPill extends StatelessWidget {
  const _MiniInfoPill({
    required this.icon,
    required this.label,
    required this.color,
  });

  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 6),
          Text(
            label,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: color,
                  fontWeight: FontWeight.w800,
                ),
          ),
        ],
      ),
    );
  }
}

class _FilterChipData {
  const _FilterChipData({
    required this.label,
    this.icon,
    this.trailingIcon,
  });

  final String label;
  final IconData? icon;
  final IconData? trailingIcon;
}

class _HotelImageCardData {
  const _HotelImageCardData({
    required this.name,
    required this.location,
    required this.price,
    required this.priceValue,
    required this.rating,
    required this.ratingValue,
    required this.popularityScore,
    required this.markerAlignment,
    required this.imageUrl,
    this.badge,
    this.showFromLabel = false,
    this.isHighlighted = false,
  });

  final String name;
  final String location;
  final String price;
  final double priceValue;
  final String rating;
  final double ratingValue;
  final int popularityScore;
  final Alignment markerAlignment;
  final String imageUrl;
  final String? badge;
  final bool showFromLabel;
  final bool isHighlighted;
}

class _HotelDetailCardData {
  const _HotelDetailCardData({
    required this.name,
    required this.location,
    required this.description,
    required this.rating,
    required this.ratingValue,
    required this.reviewSummary,
    required this.price,
    required this.priceValue,
    required this.popularityScore,
    required this.badge,
    required this.markerAlignment,
    required this.imageUrl,
    required this.amenities,
    this.isHighlighted = false,
  });

  final String name;
  final String location;
  final String description;
  final String rating;
  final double ratingValue;
  final String reviewSummary;
  final String price;
  final double priceValue;
  final int popularityScore;
  final String badge;
  final Alignment markerAlignment;
  final String imageUrl;
  final List<_AmenityData> amenities;
  final bool isHighlighted;
}

class _AmenityData {
  const _AmenityData({required this.icon, required this.label});

  final IconData icon;
  final String label;
}

class _FilterSettings {
  const _FilterSettings({
    required this.maxPrice,
    required this.minRating,
    required this.onlyHighlighted,
  });

  static const defaults = _FilterSettings(
    maxPrice: 400,
    minRating: 4.0,
    onlyHighlighted: false,
  );

  final double maxPrice;
  final double minRating;
  final bool onlyHighlighted;

  bool get hasActiveFilters {
    return maxPrice < defaults.maxPrice ||
        minRating > defaults.minRating ||
        onlyHighlighted;
  }
}

class _MapMarkerData {
  const _MapMarkerData({
    required this.label,
    required this.alignment,
    required this.highlighted,
  });

  final String label;
  final Alignment alignment;
  final bool highlighted;
}
