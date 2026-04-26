import 'package:flutter/material.dart';

import '../constants/colors.dart';

class ServiceDetailsScreen extends StatefulWidget {
  const ServiceDetailsScreen({super.key});

  @override
  State<ServiceDetailsScreen> createState() => _ServiceDetailsScreenState();
}

class _ServiceDetailsScreenState extends State<ServiceDetailsScreen> {
  static const String _title = 'Azure Horizon Bay Resort';
  static const String _location = 'Portofino, Amalfi Coast, Italy';
  static const String _category = 'LUXURY RESORT';
  static const double _rating = 5.0;
  static const int _reviewCount = 2450;
  static const String _price = '\$1,250';
  static const String _description =
      'Experience the pinnacle of Mediterranean luxury at Azure Horizon Bay. '
      'Perched on the limestone cliffs of Portofino, our resort offers a '
      'seamless blend of heritage architecture and contemporary comfort. '
      'Every suite features floor-to-ceiling windows with panoramic views of '
      'the Ligurian Sea.';

  static const List<String> _heroImages = [
    'https://lh3.googleusercontent.com/aida-public/AB6AXuAzZUCpV6fH_eK8_MIYMXfndezjt66PvXt5ME_GSEvETX2gMh20hKAxWKGSz-R0aFp4CjgJzbLefOlibu_gCyo2XhzMC6YVtckfQHRxlFk9acqo2sOnvMQvB8Z0ulVidMV_yOhlYtWK6OopKBNWCm0g8fSPRpdRlouEDFqLNRTV4UkNZnozJDiut82zz7kriHpMmG0HucXSncoh-WNzC0C5a2volDlW_7YZ6VKwr7wx6mKHjlVchqnd2BhfPHQ4zDVlRE7BocliTOw',
    'https://lh3.googleusercontent.com/aida-public/AB6AXuCXTRASLOYGm4cMum2cirxnbJRNj3rwYKRvhQS1THV9PtN0xbuey6EVJQ94Dp2_GmAQ_V8-lnVorcBGFQJbF6z-pBosHCbF1uazVrOoJ__kLaIKemrCmIfgvXxxzJ4sLUBn3WKaJFONt-cXy5k0ChEQ6_NABa2Bwpmb17Tw2ERcmKqRW6oS1GWd38i7MksuIzGheGP1nlYdRxfD-uTuBRLAHXQHqADG8bNq8WlEhqiLrqSRp4Qswxr6FUm3RnNzx_YbCia6nDGHigw',
    'https://lh3.googleusercontent.com/aida-public/AB6AXuCpXNSwlx-TqVxN1uzTucDoHOXBSXZWRTuD_P-OCJEN-IFTeQTJt2BTlTPDqFSEwBscPRu0eSHbK_uOCp-jLNpHr90ElSKgHdYtcacMkjkS_tDPipT2eYZ1CBIyYB7sBq0K41RPHjnIrBHratReuo8p5yCHiN53mFl8RbmC1SrwC-ZSOHD-yfn1VAUd8hFLic1pX8WHTREq5eS3LcVb2RwgT9BavANIfn44djMP52kDLkZfVm9UZ5Q1XWElg0bNhFwXna0ZRgcwoUw',
  ];

  static const String _mapImage =
      'https://lh3.googleusercontent.com/aida-public/AB6AXuArbaD-G0BfCskeUujSGybgvBunBNkakLLAYCt0URf2pFAcyRHnSjSiww6oQwkPzh6ooHU9jz9TUXk9_2zHdvrYZ8JU46xwWWwcIAFzpzSOc2kHKElGBloZIHnAWV08f6D0WLbTzWyQeupXhBRYmaf97o1RtQeIAYOPuZQA4zTsfqfAi7mVTxF9KB5jfUsej55OHdUyNq12a9vkUMLFhGeZyi6He8522WUI-6dff7bFJtHM8OxE4mcBYenkn6aoO8yBSSvBgBOck_o';

  static const List<({IconData icon, String label})> _amenities = [
    (icon: Icons.wifi_rounded, label: 'Free Wi-Fi'),
    (icon: Icons.pool_rounded, label: 'Infinity Pool'),
    (icon: Icons.fitness_center_rounded, label: 'Modern Gym'),
    (icon: Icons.restaurant_rounded, label: 'Fine Dining'),
    (icon: Icons.spa_rounded, label: 'Luxury Spa'),
    (icon: Icons.ac_unit_rounded, label: 'Climate Control'),
  ];

  static const List<({String name, String avatar, String quote})> _reviews = [
    (
      name: 'Elena Rossi',
      avatar:
          'https://lh3.googleusercontent.com/aida-public/AB6AXuBWja-gFW6N2pDpVrK082sODzjlflLqy1-9_564J0-6C9j1J8j2wyDPEqdUIDEf2Bf4uE0ralhY4rG_v7fIB39vcxt9bHxGP9JWnjIahqjAajsQdnKYaFMDConC2bZYQ7wuQ1yGT876Qkv6iLDJZawIqsU60ZpiScS6F7W7oc-cUBlnsTNgGg1sTJaEHYyPe8FTwOcrqptEsEoxpOfimJpG2JTaOZh_BWpwkm6i5jbcwGDaXvKWsXaVTMsYEEIXtPPaoH4Xdisv1js',
      quote:
          '"Unmatched views and incredible service. The spa treatment was the highlight of our entire trip. Truly a 5-star experience."',
    ),
    (
      name: 'Marcus Sterling',
      avatar:
          'https://lh3.googleusercontent.com/aida-public/AB6AXuC___bvwgnv8lKHLdD0DfKtGEf_68o9GG4FAIpOCF6OviU_Iec70T-F6O0zzz4wUnoH1T8Q59z-lKM_mJRqTscMNVSXwzKoz-6qc2C34juEFddUrtgcI1fpeeciB1T7Wnp9nWhkmjn5F7L4m3TmbhJ56CCsergtcx58WB0F2SkhMowxuVeUkUzKHcpiUhxFjFKTfKDbRDI3UcpSfYW6rBvjc70akd7EYa5aW3Lc7Tx-J-JiZmXaqmX2CWTBFBM_tq5EZu1NmlwqSnY',
      quote:
          '"The location is breathtaking. Watching the sunset from the balcony with a glass of local wine was a dream. Can\'t wait to return."',
    ),
  ];

  bool _isFavorited = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TripwiseColors.surface,
      appBar: _buildAppBar(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _HeroGrid(images: _heroImages),
            const SizedBox(height: 28),
            _IdentityHeader(
              category: _category,
              title: _title,
              location: _location,
              rating: _rating,
              reviewCount: _reviewCount,
            ),
            const SizedBox(height: 32),
            const _SectionHeader('About this place'),
            const SizedBox(height: 12),
            _AboutBlock(description: _description),
            const SizedBox(height: 32),
            const _SectionHeader('What this place offers'),
            const SizedBox(height: 12),
            _AmenitiesGrid(amenities: _amenities),
            const SizedBox(height: 32),
            _MapPreviewCard(mapImage: _mapImage, location: _location),
            const SizedBox(height: 24),
            const _HostCard(),
            const SizedBox(height: 32),
            _ReviewsSection(reviews: _reviews),
          ],
        ),
      ),
      bottomNavigationBar: _BookingBar(
        price: _price,
        onBookNow: () =>
            Navigator.pushNamed(context, '/booking_checkout'),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: TripwiseColors.surface,
      elevation: 0,
      scrolledUnderElevation: 0,
      toolbarHeight: 64,
      leading: IconButton(
        icon: const Icon(
          Icons.arrow_back_ios_new_rounded,
          color: TripwiseColors.primary,
        ),
        onPressed: () => Navigator.maybePop(context),
      ),
      title: const Text(
        'Tripwise',
        style: TextStyle(
          color: TripwiseColors.primary,
          fontWeight: FontWeight.w800,
          fontSize: 18,
          letterSpacing: -0.3,
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(
            Icons.ios_share_rounded,
            color: TripwiseColors.primary,
          ),
          onPressed: () {},
        ),
        IconButton(
          icon: Icon(
            _isFavorited
                ? Icons.favorite_rounded
                : Icons.favorite_border_rounded,
            color: TripwiseColors.primary,
          ),
          onPressed: () => setState(() => _isFavorited = !_isFavorited),
        ),
        const SizedBox(width: 4),
      ],
    );
  }
}

// ---------- Hero asymmetric grid ----------

class _HeroGrid extends StatelessWidget {
  const _HeroGrid({required this.images});

  final List<String> images;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 280,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            flex: 3,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Image.network(images[0], fit: BoxFit.cover),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            flex: 1,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.network(images[1], fit: BoxFit.cover),
                  ),
                ),
                const SizedBox(height: 10),
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        Image.network(images[2], fit: BoxFit.cover),
                        Container(
                          color: Colors.black.withOpacity(0.4),
                          alignment: Alignment.center,
                          child: const Text(
                            '+12 Photos',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                              fontSize: 13,
                              letterSpacing: 0.6,
                            ),
                          ),
                        ),
                      ],
                    ),
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

// ---------- Identity header ----------

class _IdentityHeader extends StatelessWidget {
  const _IdentityHeader({
    required this.category,
    required this.title,
    required this.location,
    required this.rating,
    required this.reviewCount,
  });

  final String category;
  final String title;
  final String location;
  final double rating;
  final int reviewCount;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 12,
          runSpacing: 8,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            _Pill(label: category),
            _StarRow(rating: rating, reviewCount: reviewCount),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          title,
          style: textTheme.displaySmall?.copyWith(
            fontWeight: FontWeight.w900,
            height: 1.05,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            const Icon(
              Icons.location_on_rounded,
              color: TripwiseColors.primary,
              size: 18,
            ),
            const SizedBox(width: 4),
            Expanded(
              child: Text(
                location,
                style: textTheme.bodyMedium?.copyWith(
                  color: TripwiseColors.onSurfaceVariant,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: TripwiseColors.primaryFixed,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: TripwiseColors.onPrimaryFixed,
          fontSize: 10,
          fontWeight: FontWeight.w800,
          letterSpacing: 1.5,
        ),
      ),
    );
  }
}

class _StarRow extends StatelessWidget {
  const _StarRow({
    required this.rating,
    required this.reviewCount,
  });

  final double rating;
  final int reviewCount;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (int i = 0; i < 5; i++)
          const Icon(
            Icons.star_rounded,
            size: 16,
            color: TripwiseColors.secondary,
          ),
        const SizedBox(width: 6),
        Text(
          '${rating.toStringAsFixed(1)} (${_formatCount(reviewCount)} Reviews)',
          style: textTheme.bodySmall?.copyWith(
            fontWeight: FontWeight.w700,
            color: TripwiseColors.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  static String _formatCount(int count) {
    final s = count.toString();
    final buffer = StringBuffer();
    for (int i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) buffer.write(',');
      buffer.write(s[i]);
    }
    return buffer.toString();
  }
}

// ---------- Section header ----------

class _SectionHeader extends StatelessWidget {
  const _SectionHeader(this.title, {this.trailing});

  final String title;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: Text(
            title,
            style: textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w800,
              letterSpacing: -0.2,
            ),
          ),
        ),
        if (trailing != null) trailing!,
      ],
    );
  }
}

// ---------- About block ----------

class _AboutBlock extends StatelessWidget {
  const _AboutBlock({required this.description});

  final String description;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          description,
          style: textTheme.bodyLarge?.copyWith(
            color: TripwiseColors.onSurfaceVariant,
            height: 1.5,
          ),
        ),
        const SizedBox(height: 4),
        TextButton(
          style: TextButton.styleFrom(
            padding: EdgeInsets.zero,
            minimumSize: const Size(0, 36),
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            foregroundColor: TripwiseColors.primary,
          ),
          onPressed: () {},
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Read more',
                style: TextStyle(fontWeight: FontWeight.w800),
              ),
              Icon(Icons.keyboard_arrow_down_rounded, size: 18),
            ],
          ),
        ),
      ],
    );
  }
}

// ---------- Amenities ----------

class _AmenitiesGrid extends StatelessWidget {
  const _AmenitiesGrid({required this.amenities});

  final List<({IconData icon, String label})> amenities;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return LayoutBuilder(
      builder: (context, constraints) {
        const spacing = 12.0;
        final tileWidth = (constraints.maxWidth - spacing) / 2;
        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: [
            for (final a in amenities)
              SizedBox(
                width: tileWidth,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 14,
                  ),
                  decoration: BoxDecoration(
                    color: TripwiseColors.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      Icon(a.icon, color: TripwiseColors.primary, size: 22),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          a.label,
                          style: textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

// ---------- Map preview ----------

class _MapPreviewCard extends StatelessWidget {
  const _MapPreviewCard({required this.mapImage, required this.location});

  final String mapImage;
  final String location;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Container(
      decoration: BoxDecoration(
        color: TripwiseColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: TripwiseColors.primary.withOpacity(0.06),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      padding: const EdgeInsets.all(8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: AspectRatio(
              aspectRatio: 16 / 10,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  ColorFiltered(
                    colorFilter: const ColorFilter.matrix(<double>[
                      0.2126, 0.7152, 0.0722, 0, 0,
                      0.2126, 0.7152, 0.0722, 0, 0,
                      0.2126, 0.7152, 0.0722, 0, 0,
                      0, 0, 0, 0.85, 0,
                    ]),
                    child: Image.network(mapImage, fit: BoxFit.cover),
                  ),
                  Center(
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: TripwiseColors.primary,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: TripwiseColors.primary.withOpacity(0.35),
                            blurRadius: 14,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.location_on_rounded,
                        color: Colors.white,
                        size: 22,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 16, 12, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Where you'll be",
                  style: textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$location • 10 mins from Piazza Martiri',
                  style: textTheme.bodySmall?.copyWith(
                    color: TripwiseColors.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 14),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: TripwiseColors.primary,
                      backgroundColor: TripwiseColors.surfaceContainerLow,
                      side: BorderSide.none,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () {},
                    child: const Text(
                      'VIEW ON MAP',
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.2,
                        fontSize: 12,
                      ),
                    ),
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

// ---------- Host card ----------

class _HostCard extends StatelessWidget {
  const _HostCard();

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: TripwiseColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'MANAGED BY',
            style: textTheme.labelSmall?.copyWith(
              color: TripwiseColors.onSurfaceVariant,
              letterSpacing: 1.5,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: const BoxDecoration(
                  color: TripwiseColors.primaryContainer,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.verified_user_rounded,
                  color: Colors.white,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Tripwise Concierge',
                      style: textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'GOLD TIER SERVICE',
                      style: textTheme.labelSmall?.copyWith(
                        color: TripwiseColors.onSurfaceVariant,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              style: OutlinedButton.styleFrom(
                foregroundColor: TripwiseColors.onSurface,
                side: const BorderSide(color: TripwiseColors.outlineVariant),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () {},
              child: const Text(
                'Contact Support',
                style: TextStyle(fontWeight: FontWeight.w800),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------- Reviews ----------

class _ReviewsSection extends StatelessWidget {
  const _ReviewsSection({required this.reviews});

  final List<({String name, String avatar, String quote})> reviews;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionHeader(
          'Guest Reviews',
          trailing: TextButton(
            style: TextButton.styleFrom(
              padding: EdgeInsets.zero,
              minimumSize: const Size(0, 32),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              foregroundColor: TripwiseColors.primary,
            ),
            onPressed: () {},
            child: const Text(
              'SEE ALL',
              style: TextStyle(
                fontWeight: FontWeight.w800,
                letterSpacing: 1.2,
                fontSize: 12,
              ),
            ),
          ),
        ),
        const SizedBox(height: 14),
        for (int i = 0; i < reviews.length; i++) ...[
          _ReviewCard(review: reviews[i]),
          if (i != reviews.length - 1) const SizedBox(height: 14),
        ],
      ],
    );
  }
}

class _ReviewCard extends StatelessWidget {
  const _ReviewCard({required this.review});

  final ({String name, String avatar, String quote}) review;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Container(
      decoration: BoxDecoration(
        color: TripwiseColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(20),
        border: Border(
          left: BorderSide(
            color: TripwiseColors.primary.withOpacity(0.2),
            width: 4,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: TripwiseColors.primary.withOpacity(0.04),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 22,
                backgroundImage: NetworkImage(review.avatar),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    review.name,
                    style: textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: const [
                      Icon(Icons.star_rounded,
                          size: 14, color: TripwiseColors.secondary),
                      Icon(Icons.star_rounded,
                          size: 14, color: TripwiseColors.secondary),
                      Icon(Icons.star_rounded,
                          size: 14, color: TripwiseColors.secondary),
                      Icon(Icons.star_rounded,
                          size: 14, color: TripwiseColors.secondary),
                      Icon(Icons.star_rounded,
                          size: 14, color: TripwiseColors.secondary),
                    ],
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            review.quote,
            style: textTheme.bodyMedium?.copyWith(
              color: TripwiseColors.onSurfaceVariant,
              fontStyle: FontStyle.italic,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

// ---------- Sticky booking bar ----------

class _BookingBar extends StatelessWidget {
  const _BookingBar({required this.price, required this.onBookNow});

  final String price;
  final VoidCallback onBookNow;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Container(
      decoration: BoxDecoration(
        color: TripwiseColors.surface,
        border: const Border(
          top: BorderSide(color: TripwiseColors.surfaceContainer),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 24,
            offset: const Offset(0, -8),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 14),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        price,
                        style: textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w900,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '/ night',
                        style: textTheme.bodySmall?.copyWith(
                          color: TripwiseColors.onSurfaceVariant,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'FREE CANCELLATION',
                    style: TextStyle(
                      color: TripwiseColors.secondaryContainer,
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.5,
                    ),
                  ),
                ],
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: TripwiseColors.secondaryContainer,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 28,
                    vertical: 16,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 10,
                  shadowColor:
                      TripwiseColors.secondaryContainer.withOpacity(0.4),
                ),
                onPressed: onBookNow,
                child: const Text(
                  'Book Now',
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 15,
                    letterSpacing: -0.2,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
