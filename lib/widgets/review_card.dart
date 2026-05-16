import 'package:flutter/material.dart';

import '../constants/colors.dart';
import '../models/review.dart';

/// A small filled/outline star row used by review widgets.
class ReviewStars extends StatelessWidget {
  const ReviewStars({super.key, required this.rating, this.size = 14});

  final int rating;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (int i = 0; i < 5; i++)
          Icon(
            i < rating ? Icons.star_rounded : Icons.star_outline_rounded,
            size: size,
            color: TripwiseColors.secondary,
          ),
      ],
    );
  }
}

class ReviewCard extends StatelessWidget {
  const ReviewCard({super.key, required this.review});

  final Review review;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final img = review.authorImage;
    final hasImg = img != null && img.isNotEmpty;
    final initial = review.authorName.isNotEmpty
        ? review.authorName.characters.first.toUpperCase()
        : '?';

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: TripwiseColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor: TripwiseColors.primaryContainer,
                backgroundImage: hasImg ? NetworkImage(img) : null,
                child: hasImg
                    ? null
                    : Text(
                        initial,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          fontSize: 16,
                        ),
                      ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      review.authorName,
                      style: textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      [
                        if (review.tripType != null) review.tripType!,
                        reviewDateLabel(review.createdAt),
                      ].where((s) => s.isNotEmpty).join(' · '),
                      style: textTheme.bodySmall?.copyWith(
                        color: TripwiseColors.onSurfaceVariant,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              ReviewStars(rating: review.rating),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            review.comment,
            style: textTheme.bodyMedium?.copyWith(
              color: TripwiseColors.onSurface,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
