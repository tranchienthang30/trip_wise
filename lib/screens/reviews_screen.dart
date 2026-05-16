import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../constants/colors.dart';
import '../models/review.dart';
import '../services/reviews_api.dart';
import '../widgets/review_card.dart';

class ReviewsScreen extends StatefulWidget {
  const ReviewsScreen({
    super.key,
    required this.hotelId,
    required this.hotelName,
    required this.averageRating,
    required this.reviewCount,
  });

  final int hotelId;
  final String hotelName;
  final double averageRating;
  final int reviewCount;

  @override
  State<ReviewsScreen> createState() => _ReviewsScreenState();
}

class _ReviewsScreenState extends State<ReviewsScreen> {
  static const _pageSize = 10;

  final ReviewsApi _api = ReviewsApi();
  final ScrollController _scroll = ScrollController();
  final List<Review> _reviews = [];

  int _offset = 0;
  int _total = 0;
  bool _hasMore = true;
  bool _loading = false;
  Object? _error;

  @override
  void initState() {
    super.initState();
    _total = widget.reviewCount;
    _scroll.addListener(_onScroll);
    _loadMore();
  }

  @override
  void dispose() {
    _scroll.removeListener(_onScroll);
    _scroll.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scroll.hasClients) return;
    final remaining = _scroll.position.maxScrollExtent - _scroll.position.pixels;
    if (remaining < 400 && _hasMore && !_loading && _error == null) {
      _loadMore();
    }
  }

  Future<void> _loadMore() async {
    if (_loading || !_hasMore) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final page = await _api.fetchReviews(
        widget.hotelId,
        limit: _pageSize,
        offset: _offset,
      );
      if (!mounted) return;
      setState(() {
        _reviews.addAll(page.items);
        _offset = page.nextOffset;
        _hasMore = page.hasMore;
        _total = page.total;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e;
        _loading = false;
      });
    }
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
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: TripwiseColors.primary,
          ),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          'Guest Reviews',
          style: TextStyle(
            color: TripwiseColors.primary,
            fontWeight: FontWeight.w800,
            fontSize: 18,
          ),
        ),
      ),
      body: ListView.separated(
        controller: _scroll,
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
        itemCount: _reviews.length + 2,
        separatorBuilder: (_, i) =>
            SizedBox(height: i == 0 ? 20 : 14),
        itemBuilder: (context, i) {
          if (i == 0) return _buildHeader(context);
          if (i <= _reviews.length) {
            return ReviewCard(review: _reviews[i - 1]);
          }
          return _buildFooter(context);
        },
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: TripwiseColors.primaryFixed,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.averageRating.toStringAsFixed(1),
                style: textTheme.displaySmall?.copyWith(
                  fontWeight: FontWeight.w900,
                  color: TripwiseColors.onPrimaryFixed,
                  height: 1,
                ),
              ),
              const SizedBox(height: 6),
              ReviewStars(rating: widget.averageRating.round(), size: 16),
            ],
          ),
          const SizedBox(width: 18),
          Expanded(
            child: Text(
              'Based on $_total verified ${_total == 1 ? 'review' : 'reviews'} for ${widget.hotelName}',
              style: textTheme.bodyMedium?.copyWith(
                color: TripwiseColors.onPrimaryFixed,
                fontWeight: FontWeight.w600,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter(BuildContext context) {
    if (_error != null) {
      return Padding(
        padding: const EdgeInsets.only(top: 16),
        child: Column(
          children: [
            Text(
              "Couldn't load more reviews",
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: TripwiseColors.onSurfaceVariant,
                  ),
            ),
            const SizedBox(height: 8),
            OutlinedButton(
              onPressed: _loadMore,
              child: const Text('Try again'),
            ),
          ],
        ),
      );
    }
    if (_loading) {
      return const Padding(
        padding: EdgeInsets.only(top: 20),
        child: Center(
          child: SizedBox(
            width: 22,
            height: 22,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
      );
    }
    if (!_hasMore && _reviews.isNotEmpty) {
      return Padding(
        padding: const EdgeInsets.only(top: 20),
        child: Center(
          child: Text(
            "You've reached the end · $_total reviews",
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: TripwiseColors.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                ),
          ),
        ),
      );
    }
    if (_reviews.isEmpty && !_loading) {
      return Padding(
        padding: const EdgeInsets.only(top: 40),
        child: Center(
          child: Text(
            'No reviews yet.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: TripwiseColors.onSurfaceVariant,
                ),
          ),
        ),
      );
    }
    return const SizedBox.shrink();
  }
}
