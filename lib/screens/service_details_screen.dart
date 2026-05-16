import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../constants/colors.dart';
import '../models/hotel_detail.dart';
import '../services/hotels_api.dart';
import '../utils/currency.dart';
import '../widgets/review_card.dart';
import 'image_gallery_screen.dart';

class ServiceDetailsScreen extends StatefulWidget {
  const ServiceDetailsScreen({super.key, required this.hotelId});

  final int hotelId;

  @override
  State<ServiceDetailsScreen> createState() => _ServiceDetailsScreenState();
}

class _ServiceDetailsScreenState extends State<ServiceDetailsScreen> {
  final HotelsApi _api = HotelsApi();
  late Future<HotelDetail> _future;
  HotelDetail? _data;

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() {
    _future = _api.fetchHotelDetail(widget.hotelId);
    _future.then((data) {
      if (!mounted) return;
      setState(() => _data = data);
    }).catchError((_) {});
  }

  void _retry() {
    setState(() {
      _data = null;
      _load();
    });
  }

  Future<void> _onShare() async {
    final data = _data;
    if (data == null) return;
    final price = data.priceFrom == null
        ? ''
        : '\nFrom ${formatVnd(data.priceFrom)} / night';
    await Share.share(
      'Check out ${data.name} on Tripwise.\n${data.address}$price',
      subject: data.name,
    );
  }

  Future<void> _onOpenExternalMap() async {
    final url = _data?.googleMapUrl;
    if (url == null || url.isEmpty) return;
    await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
  }

  void _onContactSupport() => context.push('/direct_messaging');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TripwiseColors.surface,
      appBar: _buildAppBar(),
      body: FutureBuilder<HotelDetail>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return _ErrorView(
              error: snapshot.error,
              onRetry: _retry,
            );
          }
          final data = snapshot.data!;
          return _DetailBody(
            data: data,
            onOpenExternalMap: _onOpenExternalMap,
            onContactSupport: _onContactSupport,
          );
        },
      ),
      bottomNavigationBar: FutureBuilder<HotelDetail>(
        future: _future,
        builder: (context, snapshot) {
          final data = snapshot.data;
          return _BookingBar(
            price: data == null ? '—' : formatVnd(data.priceFrom),
            freeCancellation: data?.policies.freeCancellation ?? false,
            onBookNow: data == null ? null : () => context.push('/booking_checkout'),
          );
        },
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
        onPressed: () => context.pop(),
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
          onPressed: _data == null ? null : _onShare,
        ),
        const SizedBox(width: 4),
      ],
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.error, required this.onRetry});

  final Object? error;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
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
              "Couldn't load this place",
              style: textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              error?.toString() ?? 'Unknown error',
              textAlign: TextAlign.center,
              style: textTheme.bodySmall?.copyWith(
                color: TripwiseColors.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: onRetry,
              child: const Text('Try again'),
            ),
          ],
        ),
      ),
    );
  }
}

class _DetailBody extends StatelessWidget {
  const _DetailBody({
    required this.data,
    required this.onOpenExternalMap,
    required this.onContactSupport,
  });

  final HotelDetail data;
  final VoidCallback onOpenExternalMap;
  final VoidCallback onContactSupport;

  void _openGallery(BuildContext context, List<String> images, int index) {
    Navigator.of(context).push(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (_) => ImageGalleryScreen(
          images: images,
          initialIndex: index,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _HeroGrid(
            images: data.images,
            onTapImage: (i) => _openGallery(context, data.images, i),
          ),
          const SizedBox(height: 28),
          _IdentityHeader(
            category: data.category,
            title: data.name,
            location: data.locationPath.isEmpty ? data.address : data.locationPath,
            rating: data.rating,
            reviewCount: data.reviewCount,
          ),
          const SizedBox(height: 32),
          const _SectionHeader('About this place'),
          const SizedBox(height: 12),
          _AboutBlock(
            description: data.description ?? 'No description yet for this place.',
          ),
          if (data.amenities.isNotEmpty) ...[
            const SizedBox(height: 32),
            const _SectionHeader('What this place offers'),
            const SizedBox(height: 12),
            _AmenitiesGrid(amenities: data.amenities),
          ],
          const SizedBox(height: 32),
          _MapPreviewCard(
            location: data.address,
            hasMapUrl: data.googleMapUrl != null,
            onOpenExternalMap: onOpenExternalMap,
          ),
          if (data.host != null) ...[
            const SizedBox(height: 24),
            _HostCard(hostName: data.host!.name, onContactSupport: onContactSupport),
          ],
          if (data.reviewCount > 0) ...[
            const SizedBox(height: 32),
            _ReviewsSection(data: data),
          ],
        ],
      ),
    );
  }
}

// ---------- Network image with graceful fallback ----------

class _NetImage extends StatelessWidget {
  const _NetImage(this.url);

  final String url;

  @override
  Widget build(BuildContext context) {
    return Image.network(
      url,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => Container(
        color: TripwiseColors.surfaceContainerLow,
        alignment: Alignment.center,
        child: const Icon(
          Icons.broken_image_rounded,
          size: 36,
          color: TripwiseColors.onSurfaceVariant,
        ),
      ),
      loadingBuilder: (context, child, progress) {
        if (progress == null) return child;
        return Container(
          color: TripwiseColors.surfaceContainerLow,
          alignment: Alignment.center,
          child: const SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        );
      },
    );
  }
}

// ---------- Hero grid (adapts to 1 / 2 / 3+ images) ----------

class _HeroGrid extends StatelessWidget {
  const _HeroGrid({required this.images, required this.onTapImage});

  final List<String> images;
  final ValueChanged<int> onTapImage;

  Widget _tile({
    required int index,
    required double radius,
    Widget? overlay,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => onTapImage(index),
          child: Stack(
            fit: StackFit.expand,
            children: [
              _NetImage(images[index]),
              if (overlay != null) overlay,
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (images.isEmpty) {
      return Container(
        height: 220,
        decoration: BoxDecoration(
          color: TripwiseColors.surfaceContainerLow,
          borderRadius: BorderRadius.circular(20),
        ),
        alignment: Alignment.center,
        child: const Icon(
          Icons.image_rounded,
          size: 48,
          color: TripwiseColors.onSurfaceVariant,
        ),
      );
    }
    if (images.length == 1) {
      return SizedBox(
        height: 260,
        width: double.infinity,
        child: _tile(index: 0, radius: 20),
      );
    }
    return SizedBox(
      height: 280,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            flex: 3,
            child: _tile(index: 0, radius: 20),
          ),
          const SizedBox(width: 10),
          Expanded(
            flex: 1,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(child: _tile(index: 1, radius: 16)),
                if (images.length >= 3) ...[
                  const SizedBox(height: 10),
                  Expanded(
                    child: _tile(
                      index: 2,
                      radius: 16,
                      overlay: images.length > 3
                          ? Container(
                              color: Colors.black.withOpacity(0.4),
                              alignment: Alignment.center,
                              child: Text(
                                '+${images.length - 2} Photos',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 13,
                                  letterSpacing: 0.6,
                                ),
                              ),
                            )
                          : null,
                    ),
                  ),
                ],
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
  const _StarRow({required this.rating, required this.reviewCount});

  final double rating;
  final int reviewCount;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final filled = rating.round().clamp(0, 5);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (int i = 0; i < 5; i++)
          Icon(
            i < filled ? Icons.star_rounded : Icons.star_outline_rounded,
            size: 16,
            color: TripwiseColors.secondary,
          ),
        const SizedBox(width: 6),
        Text(
          reviewCount == 0
              ? rating.toStringAsFixed(1)
              : '${rating.toStringAsFixed(1)} (${_formatCount(reviewCount)} Reviews)',
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
  const _SectionHeader(this.title);

  final String title;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Text(
      title,
      style: textTheme.titleMedium?.copyWith(
        fontWeight: FontWeight.w800,
        letterSpacing: -0.2,
      ),
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
    return Text(
      description,
      style: textTheme.bodyLarge?.copyWith(
        color: TripwiseColors.onSurfaceVariant,
        height: 1.5,
      ),
    );
  }
}

// ---------- Amenities ----------

class _AmenitiesGrid extends StatelessWidget {
  const _AmenitiesGrid({required this.amenities});

  final List<String> amenities;

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
                      const Icon(
                        Icons.check_circle_rounded,
                        color: TripwiseColors.primary,
                        size: 22,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          a,
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
  const _MapPreviewCard({
    required this.location,
    required this.hasMapUrl,
    required this.onOpenExternalMap,
  });

  final String location;
  final bool hasMapUrl;
  final VoidCallback onOpenExternalMap;

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
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: TripwiseColors.primaryFixed,
              borderRadius: BorderRadius.circular(16),
            ),
            alignment: Alignment.center,
            child: const Icon(
              Icons.location_on_rounded,
              color: TripwiseColors.primary,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
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
                  location,
                  style: textTheme.bodySmall?.copyWith(
                    color: TripwiseColors.onSurfaceVariant,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          TextButton(
            onPressed: hasMapUrl ? onOpenExternalMap : null,
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'OPEN',
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.2,
                    fontSize: 12,
                  ),
                ),
                SizedBox(width: 4),
                Icon(Icons.open_in_new_rounded, size: 16),
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
  const _HostCard({required this.hostName, required this.onContactSupport});

  final String hostName;
  final VoidCallback onContactSupport;

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
                child: Text(
                  hostName,
                  style: textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              style: TripwiseButtonStyles.outlined(
                radius: 12,
                foregroundColor: TripwiseColors.onSurface,
                borderColor: TripwiseColors.outlineVariant,
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              onPressed: onContactSupport,
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

// ---------- Reviews (preview + See All) ----------

class _ReviewsSection extends StatelessWidget {
  const _ReviewsSection({required this.data});

  final HotelDetail data;

  void _seeAll(BuildContext context) {
    final qs = Uri(
      queryParameters: {
        'name': data.name,
        'rating': data.rating.toString(),
        'count': data.reviewCount.toString(),
      },
    ).query;
    context.push('/reviews/${data.id}?$qs');
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final preview = data.reviewsPreview;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const _SectionHeader('Guest Reviews'),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.star_rounded,
                  size: 18,
                  color: TripwiseColors.secondary,
                ),
                const SizedBox(width: 4),
                Text(
                  data.rating.toStringAsFixed(1),
                  style: textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 14),
        for (int i = 0; i < preview.length; i++) ...[
          ReviewCard(review: preview[i]),
          if (i != preview.length - 1) const SizedBox(height: 12),
        ],
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            style: TripwiseButtonStyles.outlined(
              radius: 12,
              foregroundColor: TripwiseColors.onSurface,
              borderColor: TripwiseColors.outlineVariant,
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            onPressed: () => _seeAll(context),
            child: Text(
              'See All ${data.reviewCount} Reviews',
              style: const TextStyle(fontWeight: FontWeight.w800),
            ),
          ),
        ),
      ],
    );
  }
}

// ---------- Sticky booking bar ----------

class _BookingBar extends StatelessWidget {
  const _BookingBar({
    required this.price,
    required this.freeCancellation,
    required this.onBookNow,
  });

  final String price;
  final bool freeCancellation;
  final VoidCallback? onBookNow;

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
                  if (freeCancellation) ...[
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
                ],
              ),
              ElevatedButton(
                style: TripwiseButtonStyles.primaryElevated(
                  radius: 14,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 28,
                    vertical: 16,
                  ),
                  elevation: 10,
                  shadowColor: TripwiseColors.primary.withOpacity(0.4),
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
