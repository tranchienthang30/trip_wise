import 'package:flutter/material.dart';

import '../constants/colors.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  static const _avatarUrl =
      'https://lh3.googleusercontent.com/aida-public/AB6AXuD59O85BxWYvpaeOBLKRHVJDl5xKk_FJK77zGka29CK_oQ1rOkOTPbkLfv5mZ2tk4SD93aU55v_9vSwY-8iZX87mDYD8LvaNn-UdHyoFg4bfL0xqZKHeriqkQd1SUKpeIE6gvVJ4QX_FawbPCT0y5pyTTOE8NETqEKIcfWrol-6cte2O7TlMuVWZmL-XT25F-nqWGLSrW9OOk7KIDBnYBgynVF0OgOioVdYbzo3IRETkhaSqqraHQeFRMQ2iFZihiTYLPIvigq3m8A';

  static const List<_TravelCategory> _categories = [
    _TravelCategory(
      icon: Icons.bed_rounded,
      label: 'HOTELS',
      backgroundColor: Color(0xFFE4F1FF),
      iconColor: TripwiseColors.primary,
    ),
    _TravelCategory(
      icon: Icons.flight_rounded,
      label: 'FLIGHTS',
      backgroundColor: Color(0xFFFBE6DF),
      iconColor: TripwiseColors.secondary,
    ),
    _TravelCategory(
      icon: Icons.explore_rounded,
      label: 'TOURS',
      backgroundColor: Color(0xFFE4F1FF),
      iconColor: TripwiseColors.primary,
    ),
    _TravelCategory(
      icon: Icons.train_rounded,
      label: 'TRAIN',
      backgroundColor: Color(0xFFE4F1FF),
      iconColor: TripwiseColors.primary,
    ),
  ];

  static const List<_OfferItem> _offers = [
    _OfferItem(
      title: 'Summer in Maldives',
      subtitle: 'Up to 40% off on luxury stays',
      buttonLabel: 'BOOK NOW',
      imageUrl:
          'https://images.unsplash.com/photo-1507525428034-b723cf961d3e?auto=format&fit=crop&w=1200&q=80',
      accentColor: TripwiseColors.primary,
    ),
    _OfferItem(
      title: 'Seoul City Break',
      subtitle: 'Early access to spring getaways',
      buttonLabel: 'RESERVE',
      imageUrl:
          'https://images.unsplash.com/photo-1549693578-d683be217e58?auto=format&fit=crop&w=1200&q=80',
      accentColor: TripwiseColors.secondary,
    ),
  ];

  static const List<_RecommendedItem> _recommendedLeftColumn = [
    _RecommendedItem(
      title: 'London',
      priceLabel: '\$840',
      durationLabel: '6 days',
      imageUrl:
          'https://images.unsplash.com/photo-1513635269975-59663e0ac1ad?auto=format&fit=crop&w=900&q=80',
      height: 240,
    ),
    _RecommendedItem(
      title: 'Vernazza',
      priceLabel: '\$1,200',
      durationLabel: '4 days',
      imageUrl:
          'https://images.unsplash.com/photo-1523906834658-6e24ef2386f9?auto=format&fit=crop&w=900&q=80',
      height: 180,
    ),
  ];

  static const List<_RecommendedItem> _recommendedRightColumn = [
    _RecommendedItem(
      title: 'Yosemite',
      priceLabel: '\$450',
      durationLabel: '3 days',
      imageUrl:
          'https://images.unsplash.com/photo-1500530855697-b586d89ba3ee?auto=format&fit=crop&w=900&q=80',
      height: 180,
    ),
    _RecommendedItem(
      title: 'Kyoto',
      priceLabel: '\$1,600',
      durationLabel: '8 days',
      imageUrl:
          'https://images.unsplash.com/photo-1493976040374-85c8e12f0c0e?auto=format&fit=crop&w=900&q=80',
      height: 240,
    ),
  ];

  static const List<_HotelItem> _hotels = [
    _HotelItem(
      name: 'The Azure Sanctuary',
      location: 'Bali, Indonesia',
      priceLabel: '\$299',
      ratingLabel: '4.9',
      imageUrl:
          'https://images.unsplash.com/photo-1507525428034-b723cf961d3e?auto=format&fit=crop&w=600&q=80',
    ),
    _HotelItem(
      name: 'Noir Boutique Hotel',
      location: 'Paris, France',
      priceLabel: '\$450',
      ratingLabel: '4.8',
      imageUrl:
          'https://images.unsplash.com/photo-1505693416388-ac5ce068fe85?auto=format&fit=crop&w=600&q=80',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TripwiseColors.surface,
      appBar: AppBar(
        toolbarHeight: 68,
        titleSpacing: 20,
        title: Text(
          'Tripwise',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: TripwiseColors.primary,
                fontWeight: FontWeight.w900,
              ),
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.search_rounded),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 20),
            child: CircleAvatar(
              radius: 18,
              backgroundColor: TripwiseColors.surfaceContainerHigh,
              backgroundImage: const NetworkImage(_avatarUrl),
            ),
          ),
        ],
      ),
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSearchCard(context),
              const SizedBox(height: 28),
              _buildCategoryRow(),
              const SizedBox(height: 28),
              _buildOfferScroller(),
              const SizedBox(height: 34),
              _buildSectionHeader(
                context,
                title: 'Recommended',
                subtitle: 'Curated escapes for your style',
                actionLabel: 'See all',
              ),
              const SizedBox(height: 18),
              _buildRecommendedGrid(),
              const SizedBox(height: 36),
              _buildSectionHeader(
                context,
                title: 'Trending Hotels',
              ),
              const SizedBox(height: 18),
              ..._hotels.map((hotel) => Padding(
                    padding: const EdgeInsets.only(bottom: 20),
                    child: _HotelTile(hotel: hotel),
                  )),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
        onTap: (index) {},
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_rounded),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.flight_rounded),
            label: 'My Trips',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.event_note_rounded),
            label: 'Planner',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_balance_wallet_outlined),
            label: 'Wallet',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_rounded),
            label: 'Profile',
          ),
        ],
      ),
    );
  }

  Widget _buildSearchCard(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: TripwiseColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: TripwiseColors.primary.withOpacity(0.06),
            blurRadius: 36,
            offset: const Offset(0, 18),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Where to next?',
            style: Theme.of(context).textTheme.displaySmall?.copyWith(
                  fontWeight: FontWeight.w900,
                  letterSpacing: -1,
                ),
          ),
          const SizedBox(height: 22),
          Container(
            decoration: BoxDecoration(
              color: TripwiseColors.surfaceContainer,
              borderRadius: BorderRadius.circular(18),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
            child: Row(
              children: [
                const Icon(
                  Icons.location_on_rounded,
                  color: TripwiseColors.primary,
                ),
                const SizedBox(width: 12),
                Text(
                  'Destination',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: TripwiseColors.onSurfaceVariant.withOpacity(0.65),
                      ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: const [
              Expanded(
                child: _SearchDetailCard(
                  icon: Icons.calendar_today_rounded,
                  label: 'DATES',
                  value: 'Oct 12 - 18',
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: _SearchDetailCard(
                  icon: Icons.group_rounded,
                  label: 'GUESTS',
                  value: '2 Adults',
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: TripwiseColors.secondaryContainer,
                foregroundColor: TripwiseColors.onSecondary,
                padding: const EdgeInsets.symmetric(vertical: 18),
                textStyle: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                elevation: 0,
              ),
              child: const Text('Search Destinations'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: _categories
          .map(
            (category) => Expanded(
              child: _CategoryChip(category: category),
            ),
          )
          .toList(),
    );
  }

  Widget _buildOfferScroller() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: _offers
            .map(
              (offer) => Padding(
                padding: const EdgeInsets.only(right: 14),
                child: _OfferCard(offer: offer),
              ),
            )
            .toList(),
      ),
    );
  }

  Widget _buildRecommendedGrid() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            children: _recommendedLeftColumn
                .map(
                  (item) => Padding(
                    padding: const EdgeInsets.only(bottom: 14),
                    child: _RecommendedCard(item: item),
                  ),
                )
                .toList(),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            children: _recommendedRightColumn
                .map(
                  (item) => Padding(
                    padding: const EdgeInsets.only(bottom: 14),
                    child: _RecommendedCard(item: item),
                  ),
                )
                .toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(
    BuildContext context, {
    required String title,
    String? subtitle,
    String? actionLabel,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.displaySmall?.copyWith(
                      fontWeight: FontWeight.w900,
                      letterSpacing: -1,
                    ),
              ),
              if (subtitle != null) ...[
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: TripwiseColors.onSurfaceVariant.withOpacity(0.75),
                      ),
                ),
              ],
            ],
          ),
        ),
        if (actionLabel != null)
          TextButton(
            onPressed: () {},
            child: Text(
              actionLabel,
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
      ],
    );
  }
}

class _SearchDetailCard extends StatelessWidget {
  const _SearchDetailCard({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: TripwiseColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(18),
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Icon(
              icon,
              size: 20,
              color: TripwiseColors.primary,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        letterSpacing: 1.4,
                        color: TripwiseColors.onSurfaceVariant,
                      ),
                ),
                const SizedBox(height: 6),
                Text(
                  value,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
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

class _CategoryChip extends StatelessWidget {
  const _CategoryChip({required this.category});

  final _TravelCategory category;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 58,
          height: 58,
          decoration: BoxDecoration(
            color: category.backgroundColor,
            shape: BoxShape.circle,
          ),
          child: Icon(
            category.icon,
            color: category.iconColor,
            size: 28,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          category.label,
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
                letterSpacing: 1.1,
                fontWeight: FontWeight.w800,
              ),
        ),
      ],
    );
  }
}

class _OfferCard extends StatelessWidget {
  const _OfferCard({required this.offer});

  final _OfferItem offer;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 290,
      height: 168,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(26),
        image: DecorationImage(
          image: NetworkImage(offer.imageUrl),
          fit: BoxFit.cover,
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(26),
          gradient: LinearGradient(
            colors: [
              Colors.black.withOpacity(0.42),
              Colors.black.withOpacity(0.08),
            ],
            begin: Alignment.bottomLeft,
            end: Alignment.topRight,
          ),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'LIMITED OFFER',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: Colors.white.withOpacity(0.75),
                    letterSpacing: 1.1,
                  ),
            ),
            const SizedBox(height: 6),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 185),
              child: Text(
                offer.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                      height: 1.0,
                    ),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              offer.subtitle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.white.withOpacity(0.9),
                  ),
            ),
            const Spacer(),
            FilledButton(
              onPressed: () {},
              style: FilledButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: offer.accentColor,
                padding:
                    const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                minimumSize: const Size(0, 38),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                textStyle: Theme.of(context).textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
              ),
              child: Text(offer.buttonLabel),
            ),
          ],
        ),
      ),
    );
  }
}

class _RecommendedCard extends StatelessWidget {
  const _RecommendedCard({required this.item});

  final _RecommendedItem item;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: item.height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        image: DecorationImage(
          image: NetworkImage(item.imageUrl),
          fit: BoxFit.cover,
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28),
          gradient: LinearGradient(
            colors: [
              Colors.black.withOpacity(0.55),
              Colors.black.withOpacity(0.02),
            ],
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
          ),
        ),
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text(
              item.title,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                  ),
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: TripwiseColors.secondary,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  child: Text(
                    item.priceLabel,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                        ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  item.durationLabel,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.white.withOpacity(0.82),
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

class _HotelTile extends StatelessWidget {
  const _HotelTile({required this.hotel});

  final _HotelItem hotel;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Image.network(
            hotel.imageUrl,
            width: 82,
            height: 82,
            fit: BoxFit.cover,
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      hotel.name,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Icon(
                    Icons.star_rounded,
                    size: 16,
                    color: TripwiseColors.secondary,
                  ),
                  const SizedBox(width: 2),
                  Text(
                    hotel.ratingLabel,
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: TripwiseColors.secondary,
                          fontWeight: FontWeight.w800,
                        ),
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
                    hotel.location,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: TripwiseColors.onSurfaceVariant,
                        ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  RichText(
                    text: TextSpan(
                      text: hotel.priceLabel,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: TripwiseColors.primary,
                            fontWeight: FontWeight.w900,
                          ),
                      children: [
                        TextSpan(
                          text: ' /night',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: TripwiseColors.onSurfaceVariant,
                              ),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: () {},
                    child: const Text(
                      'DETAILS',
                      style: TextStyle(fontWeight: FontWeight.w800),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _TravelCategory {
  const _TravelCategory({
    required this.icon,
    required this.label,
    required this.backgroundColor,
    required this.iconColor,
  });

  final IconData icon;
  final String label;
  final Color backgroundColor;
  final Color iconColor;
}

class _OfferItem {
  const _OfferItem({
    required this.title,
    required this.subtitle,
    required this.buttonLabel,
    required this.imageUrl,
    required this.accentColor,
  });

  final String title;
  final String subtitle;
  final String buttonLabel;
  final String imageUrl;
  final Color accentColor;
}

class _RecommendedItem {
  const _RecommendedItem({
    required this.title,
    required this.priceLabel,
    required this.durationLabel,
    required this.imageUrl,
    required this.height,
  });

  final String title;
  final String priceLabel;
  final String durationLabel;
  final String imageUrl;
  final double height;
}

class _HotelItem {
  const _HotelItem({
    required this.name,
    required this.location,
    required this.priceLabel,
    required this.ratingLabel,
    required this.imageUrl,
  });

  final String name;
  final String location;
  final String priceLabel;
  final String ratingLabel;
  final String imageUrl;
}
