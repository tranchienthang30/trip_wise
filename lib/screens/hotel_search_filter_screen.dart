import 'package:flutter/material.dart';

import '../constants/colors.dart';

class HotelSearchFilterScreen extends StatefulWidget {
  const HotelSearchFilterScreen({super.key});

  @override
  State<HotelSearchFilterScreen> createState() =>
      _HotelSearchFilterScreenState();
}

class _HotelSearchFilterScreenState extends State<HotelSearchFilterScreen> {
  static const List<_FilterChipData> _filters = [
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
      rating: '4.9',
      badge: 'TOP PICK',
      showFromLabel: true,
      imageUrl:
          'https://images.unsplash.com/photo-1566073771259-6a8506099945?auto=format&fit=crop&w=1200&q=80',
    ),
    _HotelImageCardData(
      name: 'Seminyak Beach Resort',
      location: 'Seminyak, Bali',
      price: '\$185',
      rating: '4.7',
      imageUrl:
          'https://images.unsplash.com/photo-1522708323590-d24dbb6b0267?auto=format&fit=crop&w=1200&q=80',
    ),
    _HotelImageCardData(
      name: 'Bambu Indah Eco Resort',
      location: 'Sayan, Bali',
      price: '\$210',
      rating: '4.8',
      imageUrl:
          'https://images.unsplash.com/photo-1448630360428-65456885c650?auto=format&fit=crop&w=1200&q=80',
    ),
  ];

  static const _HotelDetailCardData _featuredHotel = _HotelDetailCardData(
    name: 'Ametis Villa Bali',
    description:
        'Exclusive private villas with personalized butler service in the heart of Canggu.',
    rating: '4.6',
    reviewSummary: '(1.2k reviews)',
    price: '\$155',
    badge: 'POPULAR',
    imageUrl:
        'https://images.unsplash.com/photo-1505693416388-ac5ce068fe85?auto=format&fit=crop&w=1200&q=80',
    amenities: [
      _AmenityData(icon: Icons.pool_rounded, label: 'Pool'),
      _AmenityData(icon: Icons.wifi_rounded, label: 'Free WiFi'),
      _AmenityData(icon: Icons.spa_rounded, label: 'Spa'),
      _AmenityData(icon: Icons.restaurant_rounded, label: 'Dining'),
    ],
  );

  int _selectedFilterIndex = 0;
  int _selectedBottomNavIndex = 1;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TripwiseColors.surface,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 18),
        child: SizedBox(
          height: 56,
          child: ElevatedButton.icon(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: TripwiseColors.secondaryContainer,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 28),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(28),
              ),
              elevation: 0,
            ),
            icon: const Icon(Icons.map_outlined, size: 18),
            label: const Text(
              'MAP VIEW',
              style: TextStyle(
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
        onTap: (index) {
          setState(() {
            _selectedBottomNavIndex = index;
          });
        },
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
              onBackPressed: () => Navigator.maybePop(context),
            ),
            const SizedBox(height: 22),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: List.generate(
                  _filters.length,
                  (index) => Padding(
                    padding: EdgeInsets.only(
                      right: index == _filters.length - 1 ? 0 : 10,
                    ),
                    child: _SearchFilterChip(
                      data: _filters[index],
                      isSelected: _selectedFilterIndex == index,
                      onTap: () {
                        setState(() {
                          _selectedFilterIndex = index;
                        });
                      },
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 28),
            ..._hotelCards.map(
              (hotel) => Padding(
                padding: const EdgeInsets.only(bottom: 28),
                child: _HotelImageCard(data: hotel),
              ),
            ),
            _HotelDetailCard(data: _featuredHotel),
          ],
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.onBackPressed});

  final VoidCallback onBackPressed;

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
                '142 PROPERTIES FOUND',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: TripwiseColors.onSurfaceVariant.withOpacity(0.7),
                      letterSpacing: 2,
                    ),
              ),
            ],
          ),
        ),
        IconButton(
          onPressed: () {},
          icon: const Icon(Icons.search_rounded),
          color: TripwiseColors.primary,
        ),
        Container(
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
    final bool isPrimaryChip = data.label == 'Filters';
    final Color backgroundColor = isSelected
        ? (isPrimaryChip
            ? TripwiseColors.secondaryContainer
            : TripwiseColors.surfaceContainerLowest)
        : TripwiseColors.surfaceContainerLowest;
    final Color foregroundColor = isSelected
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

class _HotelImageCard extends StatelessWidget {
  const _HotelImageCard({required this.data});

  final _HotelImageCardData data;

  @override
  Widget build(BuildContext context) {
    return Column(
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
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
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
    );
  }
}

class _HotelDetailCard extends StatelessWidget {
  const _HotelDetailCard({required this.data});

  final _HotelDetailCardData data;

  @override
  Widget build(BuildContext context) {
    return Container(
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
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
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
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
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
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
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
    required this.rating,
    required this.imageUrl,
    this.badge,
    this.showFromLabel = false,
  });

  final String name;
  final String location;
  final String price;
  final String rating;
  final String imageUrl;
  final String? badge;
  final bool showFromLabel;
}

class _HotelDetailCardData {
  const _HotelDetailCardData({
    required this.name,
    required this.description,
    required this.rating,
    required this.reviewSummary,
    required this.price,
    required this.badge,
    required this.imageUrl,
    required this.amenities,
  });

  final String name;
  final String description;
  final String rating;
  final String reviewSummary;
  final String price;
  final String badge;
  final String imageUrl;
  final List<_AmenityData> amenities;
}

class _AmenityData {
  const _AmenityData({required this.icon, required this.label});

  final IconData icon;
  final String label;
}
