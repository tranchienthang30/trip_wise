import 'package:flutter/material.dart';

import '../constants/colors.dart';
import '../models/activity_catalog.dart';
import '../services/activities_api.dart';
import '../services/trips_api.dart';

// UI chip labels -> server category. Index 0 ("All") means no filter.
const List<String> _chipLabels = [
  'All',
  'Food',
  'Sightseeing',
  'Transport',
  'Outdoors',
];
const List<String?> _chipCategory = [
  null,
  'FOOD',
  'SIGHTSEEING',
  'TRANSPORT',
  'OUTDOORS',
];

class AddActivityScreen extends StatefulWidget {
  const AddActivityScreen({super.key, this.tripId, this.dayIndex});

  /// When both are provided, "Add to Trip" persists the activity onto this
  /// trip/day; otherwise it falls back to a confirm-and-pop (no trip context).
  final String? tripId;
  final int? dayIndex;

  @override
  State<AddActivityScreen> createState() => _AddActivityScreenState();
}

class _AddActivityScreenState extends State<AddActivityScreen> {
  final ActivitiesApi _api = ActivitiesApi();
  final TripsApi _tripsApi = TripsApi();
  final TextEditingController _searchController = TextEditingController();

  ActivityCatalog? _data;
  Object? _error;
  int _selectedChipIndex = 0;
  String _query = '';
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _error = null;
      _data = null;
    });
    try {
      final data = await _api.fetchCatalog();
      if (!mounted) return;
      setState(() => _data = data);
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = e);
    }
  }

  /// Client-side filter over the loaded catalog (category chip + search).
  List<CatalogActivity> get _filtered {
    final data = _data;
    if (data == null) return const [];
    final seen = <int>{};
    final pool = <CatalogActivity>[
      if (data.recommended != null) data.recommended!,
      ...data.popular,
    ].where((a) => seen.add(a.id)).toList();

    final cat = _chipCategory[_selectedChipIndex];
    final q = _query.trim().toLowerCase();
    return pool.where((a) {
      if (cat != null && a.category.toUpperCase() != cat) return false;
      if (q.isEmpty) return true;
      return a.title.toLowerCase().contains(q) ||
          a.location.toLowerCase().contains(q);
    }).toList();
  }

  void _snack(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          duration: const Duration(milliseconds: 1600),
          behavior: SnackBarBehavior.floating,
        ),
      );
  }

  Future<void> _onAddTap(CatalogActivity activity) async {
    if (_submitting) return;
    final tripId = widget.tripId;
    final dayIndex = widget.dayIndex;

    // Opened without trip context — legacy confirm-and-pop.
    if (tripId == null || dayIndex == null) {
      _snack('Added to your trip');
      Navigator.of(context).pop();
      return;
    }

    setState(() => _submitting = true);
    try {
      await _tripsApi.addItem(
        tripId: tripId,
        dayIndex: dayIndex,
        activityId: activity.id,
      );
      if (!mounted) return;
      _snack('Added “${activity.title}” to your trip');
      Navigator.of(context).pop(true);
    } on TripsApiException catch (e) {
      if (!mounted) return;
      setState(() => _submitting = false);
      _snack(e.message);
    } catch (_) {
      if (!mounted) return;
      setState(() => _submitting = false);
      _snack('Something went wrong. Please try again.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Scaffold(
      backgroundColor: TripwiseColors.surface,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        toolbarHeight: 64,
        titleSpacing: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_rounded,
            color: TripwiseColors.primary,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Add Activity',
          style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
        ),
      ),
      body: SafeArea(top: false, child: _buildBody()),
    );
  }

  Widget _buildBody() {
    if (_data == null && _error == null) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_data == null) {
      return _ErrorView(error: _error, onRetry: _load);
    }

    final textTheme = Theme.of(context).textTheme;
    final filtered = _filtered;
    final hero = filtered.isNotEmpty ? filtered.first : null;
    final rest = filtered.length > 1
        ? filtered.sublist(1)
        : const <CatalogActivity>[];

    return RefreshIndicator(
      onRefresh: _load,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _SearchField(
              controller: _searchController,
              onChanged: (v) => setState(() => _query = v),
            ),
            const SizedBox(height: 16),
            _CategoryChips(
              labels: _chipLabels,
              selectedIndex: _selectedChipIndex,
              onSelect: (i) => setState(() => _selectedChipIndex = i),
            ),
            const SizedBox(height: 28),
            if (hero == null)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 40),
                child: Center(
                  child: Text(
                    'No activities match your search.',
                    style: textTheme.bodyMedium?.copyWith(
                      color: TripwiseColors.onSurfaceVariant,
                    ),
                  ),
                ),
              )
            else ...[
              Text(
                'RECOMMENDED FOR YOU',
                style: textTheme.labelMedium?.copyWith(
                  color: TripwiseColors.primary.withOpacity(0.70),
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(height: 12),
              _HeroActivityCard(activity: hero, onAdd: _onAddTap),
              if (rest.isNotEmpty) ...[
                const SizedBox(height: 32),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Popular Activities',
                      style: textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.5,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _PopularActivitiesGrid(items: rest, onAdd: _onAddTap),
              ],
            ],
          ],
        ),
      ),
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
              "Couldn't load activities",
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
            FilledButton(onPressed: onRetry, child: const Text('Try again')),
          ],
        ),
      ),
    );
  }
}

class _NetImage extends StatelessWidget {
  const _NetImage({required this.url});

  final String? url;

  @override
  Widget build(BuildContext context) {
    final src = url;
    if (src == null || src.isEmpty) {
      return const ColoredBox(
        color: TripwiseColors.surfaceContainerLow,
        child: Center(
          child: Icon(
            Icons.image_not_supported_rounded,
            color: TripwiseColors.onSurfaceVariant,
          ),
        ),
      );
    }
    return Image.network(
      src,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => const ColoredBox(
        color: TripwiseColors.surfaceContainerLow,
        child: Center(
          child: Icon(
            Icons.broken_image_rounded,
            color: TripwiseColors.onSurfaceVariant,
          ),
        ),
      ),
      loadingBuilder: (context, child, progress) {
        if (progress == null) return child;
        return const ColoredBox(
          color: TripwiseColors.surfaceContainerLow,
          child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
        );
      },
    );
  }
}

class _SearchField extends StatelessWidget {
  const _SearchField({required this.controller, required this.onChanged});

  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return TextField(
      controller: controller,
      onChanged: onChanged,
      style: textTheme.bodyLarge,
      decoration: InputDecoration(
        prefixIcon: const Padding(
          padding: EdgeInsets.only(left: 16, right: 8),
          child: Icon(Icons.search_rounded, color: TripwiseColors.outline),
        ),
        prefixIconConstraints: const BoxConstraints(
          minWidth: 0,
          minHeight: 0,
        ),
        hintText: 'Find locations or activities...',
        hintStyle: textTheme.bodyMedium?.copyWith(
          color: TripwiseColors.onSurfaceVariant.withOpacity(0.6),
        ),
        filled: true,
        fillColor: TripwiseColors.surfaceContainerLow,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(999),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(999),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(999),
          borderSide: BorderSide(
            color: TripwiseColors.primary.withOpacity(0.4),
            width: 2,
          ),
        ),
      ),
    );
  }
}

class _CategoryChips extends StatelessWidget {
  const _CategoryChips({
    required this.labels,
    required this.selectedIndex,
    required this.onSelect,
  });

  final List<String> labels;
  final int selectedIndex;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.zero,
        itemCount: labels.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, i) => _CategoryChip(
          label: labels[i],
          selected: i == selectedIndex,
          onTap: () => onSelect(i),
        ),
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  const _CategoryChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        decoration: BoxDecoration(
          color: selected
              ? TripwiseColors.secondaryContainer
              : TripwiseColors.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(999),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: TripwiseColors.secondary.withOpacity(0.20),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ]
              : null,
        ),
        child: Center(
          child: Text(
            label,
            style: textTheme.labelLarge?.copyWith(
              color: selected
                  ? Colors.white
                  : TripwiseColors.onSurfaceVariant,
              fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}

String _ratingText(double r) => r.toStringAsFixed(1);

class _HeroActivityCard extends StatelessWidget {
  const _HeroActivityCard({required this.activity, required this.onAdd});

  final CatalogActivity activity;
  final ValueChanged<CatalogActivity> onAdd;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Container(
      height: 420,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: TripwiseColors.primary.withOpacity(0.10),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      clipBehavior: Clip.hardEdge,
      child: Stack(
        fit: StackFit.expand,
        children: [
          _NetImage(url: activity.image),
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                colors: [Colors.black.withOpacity(0.80), Colors.transparent],
                stops: const [0.0, 0.55],
              ),
            ),
          ),
          Positioned(
            left: 24,
            right: 24,
            bottom: 24,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.20),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.star_rounded,
                            size: 14,
                            color: Colors.white,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            _ratingText(activity.rating),
                            style: textTheme.labelSmall?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      activity.category,
                      style: textTheme.labelSmall?.copyWith(
                        color: Colors.white.withOpacity(0.80),
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  activity.title,
                  style: textTheme.displaySmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    height: 1.05,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  activity.description ?? activity.location,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: textTheme.bodyMedium?.copyWith(
                    color: Colors.white.withOpacity(0.80),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton.icon(
                    onPressed: () => onAdd(activity),
                    icon: const Icon(Icons.add_rounded, size: 22),
                    label: const Text('Add to Trip'),
                    style: TripwiseButtonStyles.primaryElevated(
                      radius: 999,
                      textStyle: const TextStyle(fontWeight: FontWeight.w800),
                      elevation: 8,
                      shadowColor: TripwiseColors.primary.withOpacity(0.30),
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

/// Lays the remaining activities into the original cadence: a row of two
/// small cards, then a wide card, repeating — defensive to any length.
class _PopularActivitiesGrid extends StatelessWidget {
  const _PopularActivitiesGrid({required this.items, required this.onAdd});

  final List<CatalogActivity> items;
  final ValueChanged<CatalogActivity> onAdd;

  @override
  Widget build(BuildContext context) {
    final blocks = <Widget>[];
    int i = 0;
    while (i < items.length) {
      final pair = items.skip(i).take(2).toList();
      i += pair.length;
      blocks.add(
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: _SmallActivityCard(data: pair[0], onAdd: onAdd)),
            const SizedBox(width: 16),
            if (pair.length > 1)
              Expanded(child: _SmallActivityCard(data: pair[1], onAdd: onAdd))
            else
              const Expanded(child: SizedBox.shrink()),
          ],
        ),
      );
      if (i < items.length) {
        blocks
          ..add(const SizedBox(height: 16))
          ..add(_WideActivityCard(data: items[i], onAdd: onAdd));
        i += 1;
        if (i < items.length) blocks.add(const SizedBox(height: 16));
      }
    }
    return Column(children: blocks);
  }
}

class _SmallActivityCard extends StatelessWidget {
  const _SmallActivityCard({required this.data, required this.onAdd});

  final CatalogActivity data;
  final ValueChanged<CatalogActivity> onAdd;

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
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      clipBehavior: Clip.hardEdge,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 140,
            child: Stack(
              children: [
                Positioned.fill(child: _NetImage(url: data.image)),
                Positioned(
                  top: 12,
                  right: 12,
                  child: _AddIconButton(onTap: () => onAdd(data)),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _RatingRow(rating: _ratingText(data.rating)),
                const SizedBox(height: 4),
                Text(
                  data.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  data.description ?? data.location,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: textTheme.bodySmall?.copyWith(
                    color: TripwiseColors.onSurfaceVariant,
                    height: 1.4,
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

class _WideActivityCard extends StatelessWidget {
  const _WideActivityCard({required this.data, required this.onAdd});

  final CatalogActivity data;
  final ValueChanged<CatalogActivity> onAdd;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Container(
      height: 160,
      decoration: BoxDecoration(
        color: TripwiseColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: TripwiseColors.primary.withOpacity(0.06),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      clipBehavior: Clip.hardEdge,
      child: Row(
        children: [
          Expanded(
            flex: 1,
            child: SizedBox.expand(child: _NetImage(url: data.image)),
          ),
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _RatingRow(rating: _ratingText(data.rating)),
                            const SizedBox(height: 4),
                            Text(
                              data.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      _WidePrimaryAddButton(onTap: () => onAdd(data)),
                    ],
                  ),
                  Text(
                    data.description ?? data.location,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: textTheme.bodySmall?.copyWith(
                      color: TripwiseColors.onSurfaceVariant,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RatingRow extends StatelessWidget {
  const _RatingRow({required this.rating});

  final String rating;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(
          Icons.star_rounded,
          size: 14,
          color: TripwiseColors.secondary,
        ),
        const SizedBox(width: 4),
        Text(
          rating,
          style: textTheme.labelSmall?.copyWith(
            color: TripwiseColors.onSurfaceVariant,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }
}

class _AddIconButton extends StatelessWidget {
  const _AddIconButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white.withOpacity(0.95),
      shape: const CircleBorder(),
      elevation: 4,
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: const SizedBox(
          width: 32,
          height: 32,
          child: Icon(
            Icons.add_rounded,
            size: 18,
            color: TripwiseColors.primary,
          ),
        ),
      ),
    );
  }
}

class _WidePrimaryAddButton extends StatelessWidget {
  const _WidePrimaryAddButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: TripwiseColors.primary,
      shape: const CircleBorder(),
      elevation: 3,
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: const SizedBox(
          width: 40,
          height: 40,
          child: Icon(Icons.add_rounded, color: Colors.white, size: 22),
        ),
      ),
    );
  }
}
