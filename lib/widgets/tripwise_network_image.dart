import 'package:flutter/material.dart';

import '../utils/tripwise_image_provider.dart';

class TripwiseNetworkImage extends StatelessWidget {
  const TripwiseNetworkImage({
    super.key,
    required this.imageUrl,
    required this.fallbackSeed,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.placeholderColor,
  });

  final String? imageUrl;
  final String fallbackSeed;
  final double? width;
  final double? height;
  final BoxFit fit;
  final Color? placeholderColor;

  @override
  Widget build(BuildContext context) {
    final imageProvider = tripwiseImageProvider(imageUrl);
    if (imageProvider == null) {
      return _FallbackImage(seed: fallbackSeed, width: width, height: height, fit: fit);
    }

    return Image(
      image: imageProvider,
      width: width,
      height: height,
      fit: fit,
      errorBuilder: (_, __, ___) =>
          _FallbackImage(seed: fallbackSeed, width: width, height: height, fit: fit),
      loadingBuilder: (context, child, progress) {
        if (progress == null) return child;
        return Container(
          width: width,
          height: height,
          color: placeholderColor ?? const Color(0xFFE9EEF6),
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

class _FallbackImage extends StatelessWidget {
  const _FallbackImage({
    required this.seed,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
  });

  final String seed;
  final double? width;
  final double? height;
  final BoxFit fit;

  @override
  Widget build(BuildContext context) {
    return Image.network(
      tripwiseFallbackImageUrl(seed),
      width: width,
      height: height,
      fit: fit,
      errorBuilder: (_, __, ___) => _SoftImageFallback(width: width, height: height),
    );
  }
}

class _SoftImageFallback extends StatelessWidget {
  const _SoftImageFallback({this.width, this.height});

  final double? width;
  final double? height;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFE4EEF8),
            Color(0xFFAEB8C4),
          ],
        ),
      ),
    );
  }
}

String tripwiseFallbackImageUrl(String seed) {
  const images = [
    'https://images.unsplash.com/photo-1507525428034-b723cf961d3e?auto=format&fit=crop&w=900&q=80',
    'https://images.unsplash.com/photo-1566073771259-6a8506099945?auto=format&fit=crop&w=900&q=80',
    'https://images.unsplash.com/photo-1528127269322-539801943592?auto=format&fit=crop&w=900&q=80',
    'https://images.unsplash.com/photo-1500530855697-b586d89ba3ee?auto=format&fit=crop&w=900&q=80',
  ];

  final hash = seed.codeUnits.fold<int>(0, (value, unit) => value + unit);
  return images[hash.abs() % images.length];
}
