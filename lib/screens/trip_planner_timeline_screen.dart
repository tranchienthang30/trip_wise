import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../constants/colors.dart';
import '../models/trip_timeline.dart';
import '../services/trips_api.dart';
import '../widgets/shared_taskbars.dart';
import '../widgets/shared_top_bars.dart';

/// Maps a server activity category to the timeline accent + icon.
({IconData icon, Color color}) _categoryStyle(String category) {
  switch (category.toUpperCase()) {
    case 'FOOD':
      return (icon: Icons.restaurant_rounded, color: TripwiseColors.primary);
    case 'SIGHTSEEING':
      return (icon: Icons.museum_rounded, color: TripwiseColors.secondary);
    case 'OUTDOORS':
      return (
        icon: Icons.hiking_rounded,
        color: TripwiseColors.tertiaryContainer,
      );
    case 'TRANSPORT':
      return (
        icon: Icons.directions_bus_rounded,
        color: TripwiseColors.primaryFixed,
      );
    default:
      return (icon: Icons.place_rounded, color: TripwiseColors.primary);
  }
}

class TripPlannerTimelineScreen extends StatefulWidget {
  const TripPlannerTimelineScreen({super.key, this.tripId});

  /// Which trip to show. When null the screen falls back to the user's
  /// ONGOING trip (else the first).
  final String? tripId;

  @override
  State<TripPlannerTimelineScreen> createState() =>
      _TripPlannerTimelineScreenState();
}

class _TripPlannerTimelineScreenState extends State<TripPlannerTimelineScreen> {
  final TripsApi _api = TripsApi();

  TripsResponse? _data;
  Object? _error;
  String? _selectedTripId;
  int _selectedDayIndex = 0;

  @override
  void initState() {
    super.initState();
    _selectedTripId = widget.tripId;
    _load();
  }

  /// The resolved trip: the explicitly-requested id when present & found,
  /// otherwise the ONGOING/first trip.
  Trip? get _trip {
    final d = _data;
    if (d == null) return null;
    final id = _selectedTripId;
    if (id != null) {
      for (final t in d.trips) {
        if (t.id == id) return t;
      }
    }
    return d.current;
  }

  Future<void> _load() async {
    setState(() {
      _error = null;
      _data = null;
    });
    try {
      final data = await _api.fetchTrips();
      if (!mounted) return;
      setState(() {
        _data = data;
        // Pin the resolved id so later reloads stay on the same trip.
        _selectedTripId ??= data.current?.id;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = e);
    }
  }

  Future<void> _openAddActivity() async {
    final trip = _trip;
    if (trip == null || trip.days.isEmpty) return;
    final di = _selectedDayIndex.clamp(0, trip.days.length - 1);
    final dayIndex = trip.days[di].dayIndex;
    await context.push(
      '/add_activity?tripId=${Uri.encodeQueryComponent(trip.id)}'
      '&dayIndex=$dayIndex',
    );
    if (!mounted) return;
    await _load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TripwiseColors.surface,
      appBar: const PlannerAppBar(),
      body: SafeArea(top: false, child: _buildBody()),
      floatingActionButton: FloatingActionButton(
        onPressed: _openAddActivity,
        elevation: 6,
        child: const Icon(Icons.add_rounded, size: 28),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      bottomNavigationBar: const PlannerTaskbar(
        currentTab: PlannerTaskbarTab.planner,
      ),
    );
  }

  Widget _buildBody() {
    if (_data == null && _error == null) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_data == null) {
      return _ErrorView(error: _error, onRetry: _load);
    }
    final trip = _trip;
    if (trip == null) {
      return const _EmptyTripsView();
    }

    final days = trip.days;
    final dayIndex = _selectedDayIndex.clamp(
      0,
      days.isEmpty ? 0 : days.length - 1,
    );
    final items = days.isEmpty ? const <TripItem>[] : days[dayIndex].items;

    return RefreshIndicator(
      onRefresh: _load,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 96),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _TripHero(
              heroImageUrl: trip.coverImage,
              mapUrl: trip.mapImage,
              label: trip.statusLabel,
              title: trip.title,
            ),
            const SizedBox(height: 28),
            if (days.isNotEmpty)
              _DayTabs(
                labels: [for (final d in days) 'Day ${d.dayIndex}'],
                selectedIndex: dayIndex,
                onSelect: (i) => setState(() => _selectedDayIndex = i),
              ),
            const SizedBox(height: 28),
            _Timeline(items: items, onAddActivity: _openAddActivity),
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

class _EmptyTripsView extends StatelessWidget {
  const _EmptyTripsView();

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
              Icons.luggage_rounded,
              size: 48,
              color: TripwiseColors.onSurfaceVariant,
            ),
            const SizedBox(height: 16),
            Text(
              'No trips yet',
              style: textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Plan a trip and your day-by-day timeline shows up here.',
              textAlign: TextAlign.center,
              style: textTheme.bodySmall?.copyWith(
                color: TripwiseColors.onSurfaceVariant,
              ),
            ),
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
              "Couldn't load your trip",
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

class _TripHero extends StatelessWidget {
  const _TripHero({
    required this.heroImageUrl,
    required this.mapUrl,
    required this.label,
    required this.title,
  });

  final String? heroImageUrl;
  final String? mapUrl;
  final String label;
  final String title;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Container(
      height: 260,
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
          _NetImage(url: heroImageUrl),
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                colors: [Colors.black.withOpacity(0.55), Colors.transparent],
              ),
            ),
          ),
          Positioned(
            left: 20,
            right: 20,
            bottom: 20,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: textTheme.labelMedium?.copyWith(
                    color: Colors.white.withOpacity(0.85),
                    fontWeight: FontWeight.w800,
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  title,
                  style: textTheme.displaySmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    height: 1.05,
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            top: 16,
            right: 16,
            child: Container(
              width: 88,
              height: 88,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: Colors.white.withOpacity(0.30),
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.25),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              clipBehavior: Clip.hardEdge,
              child: _NetImage(url: mapUrl),
            ),
          ),
        ],
      ),
    );
  }
}

class _DayTabs extends StatelessWidget {
  const _DayTabs({
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
      height: 48,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.zero,
        itemCount: labels.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, i) => _DayPill(
          label: labels[i],
          selected: i == selectedIndex,
          onTap: () => onSelect(i),
        ),
      ),
    );
  }
}

class _DayPill extends StatelessWidget {
  const _DayPill({
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
              ? TripwiseColors.primary
              : TripwiseColors.surfaceContainerLow,
          borderRadius: BorderRadius.circular(999),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: TripwiseColors.primary.withOpacity(0.20),
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

class _Timeline extends StatelessWidget {
  const _Timeline({required this.items, required this.onAddActivity});

  final List<TripItem> items;
  final VoidCallback onAddActivity;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    if (items.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Nothing planned for this day yet.',
              style: textTheme.bodyMedium?.copyWith(
                color: TripwiseColors.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 20),
            _AddActivityButton(onTap: onAddActivity),
          ],
        ),
      );
    }
    return Stack(
      children: [
        Positioned(
          left: 23,
          top: 8,
          bottom: 0,
          child: Container(width: 2, color: TripwiseColors.primaryFixed),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (int i = 0; i < items.length; i++) ...[
              if (i > 0) const SizedBox(height: 20),
              _TimelineItem(item: items[i]),
            ],
            const SizedBox(height: 20),
            _AddActivityButton(onTap: onAddActivity),
          ],
        ),
      ],
    );
  }
}

class _TimelineItem extends StatelessWidget {
  const _TimelineItem({required this.item});

  final TripItem item;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final style = _categoryStyle(item.category);
    final companionImages = [
      for (final c in item.companions)
        if (c.image != null && c.image!.isNotEmpty) c.image!,
    ];
    final shown = companionImages.take(3).toList();
    final extra = item.companions.length - shown.length;

    return Padding(
      padding: const EdgeInsets.only(left: 56),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            left: -40,
            top: 8,
            child: Container(
              width: 16,
              height: 16,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                border: Border.all(color: style.color, width: 4),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
            ),
          ),
          Container(
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      item.time,
                      style: textTheme.labelMedium?.copyWith(
                        color: style.color,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.5,
                      ),
                    ),
                    Icon(style.icon, color: style.color, size: 22),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  item.title,
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.location_on_rounded,
                      size: 16,
                      color: TripwiseColors.onSurfaceVariant,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        item.location,
                        style: textTheme.bodyMedium?.copyWith(
                          color: TripwiseColors.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ],
                ),
                if (shown.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  _FriendsStack(
                    friends: shown,
                    extraFriends: extra > 0 ? extra : 0,
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

class _FriendsStack extends StatelessWidget {
  const _FriendsStack({required this.friends, required this.extraFriends});

  final List<String> friends;
  final int extraFriends;

  static const double _avatarSize = 32;
  static const double _overlap = 8;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final int slotCount = friends.length + (extraFriends > 0 ? 1 : 0);
    final double width =
        _avatarSize + (slotCount - 1) * (_avatarSize - _overlap);

    return SizedBox(
      height: _avatarSize,
      width: width,
      child: Stack(
        children: [
          for (int i = 0; i < friends.length; i++)
            Positioned(
              left: i * (_avatarSize - _overlap),
              child: Container(
                width: _avatarSize,
                height: _avatarSize,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                padding: const EdgeInsets.all(2),
                child: CircleAvatar(
                  backgroundImage: NetworkImage(friends[i]),
                ),
              ),
            ),
          if (extraFriends > 0)
            Positioned(
              left: friends.length * (_avatarSize - _overlap),
              child: Container(
                width: _avatarSize,
                height: _avatarSize,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                padding: const EdgeInsets.all(2),
                child: Container(
                  decoration: const BoxDecoration(
                    color: TripwiseColors.primaryFixed,
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    '+$extraFriends',
                    style: textTheme.labelSmall?.copyWith(
                      color: TripwiseColors.primary,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _AddActivityButton extends StatelessWidget {
  const _AddActivityButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.only(left: 56),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: TripwiseColors.outlineVariant,
              width: 2,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.add_circle_rounded,
                size: 28,
                color: TripwiseColors.onSurfaceVariant,
              ),
              const SizedBox(height: 6),
              Text(
                'Add Activity',
                style: textTheme.labelLarge?.copyWith(
                  color: TripwiseColors.onSurfaceVariant,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
