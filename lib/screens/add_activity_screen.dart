import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../constants/colors.dart';
import '../models/my_trips.dart';
import '../services/my_trips_api.dart';
import '../services/trips_api.dart';

const List<String> _chipLabels = ['All', 'Activity', 'Flight', 'Hotel'];
const List<String?> _chipServiceType = [null, 'activity', 'flight', 'hotel'];

class AddActivityScreen extends StatefulWidget {
  const AddActivityScreen({super.key, this.tripId, this.dayIndex});

  final String? tripId;
  final int? dayIndex;

  @override
  State<AddActivityScreen> createState() => _AddActivityScreenState();
}

class _AddActivityScreenState extends State<AddActivityScreen> {
  final MyTripsApi _myTripsApi = MyTripsApi();
  final TripsApi _tripsApi = TripsApi();
  final TextEditingController _searchController = TextEditingController();

  List<MyTripCard>? _items;
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
      _items = null;
    });
    try {
      final response = await _myTripsApi.fetchTrips(status: 'upcoming');
      if (!mounted) return;
      final list = response.items.toList()
        ..sort((a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()));
      setState(() => _items = list);
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = e);
    }
  }

  List<MyTripCard> get _filtered {
    final data = _items;
    if (data == null) return const [];

    final serviceType = _chipServiceType[_selectedChipIndex];
    final q = _query.trim().toLowerCase();
    return data.where((item) {
      if (serviceType != null && item.serviceType != serviceType) return false;
      if (q.isEmpty) return true;
      return item.title.toLowerCase().contains(q) ||
          item.subtitle.toLowerCase().contains(q) ||
          item.dateLabel.toLowerCase().contains(q) ||
          item.ticketCode.toLowerCase().contains(q);
    }).toList();
  }

  void _snack(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          duration: const Duration(milliseconds: 1800),
          behavior: SnackBarBehavior.floating,
        ),
      );
  }

  String _formatItemTime(TimeOfDay value) {
    final hour = value.hour.toString().padLeft(2, '0');
    final minute = value.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  Future<String?> _pickPlanTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 9, minute: 0),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: TripwiseColors.primary,
              onPrimary: TripwiseColors.onPrimary,
              secondary: TripwiseColors.secondaryContainer,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked == null) return null;
    return _formatItemTime(picked);
  }

  Future<void> _onAddTap(MyTripCard item) async {
    if (_submitting) return;
    final tripId = widget.tripId;
    final dayIndex = widget.dayIndex;

    if (tripId == null || dayIndex == null) {
      _snack('Please open this from a trip timeline.');
      return;
    }

    final pickedTime = await _pickPlanTime();
    if (pickedTime == null) return;

    setState(() => _submitting = true);
    try {
      await _tripsApi.addItem(
        tripId: tripId,
        dayIndex: dayIndex,
        bookingItemId: item.id,
        activityId: item.activityId,
        time: pickedTime,
      );
      if (!mounted) return;
      _snack('Added "${item.title}" to your plan');
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
          onPressed: () {
            if (context.canPop()) {
              context.pop();
              return;
            }
            final tripId = widget.tripId;
            if (tripId != null && tripId.isNotEmpty) {
              context.go(
                '/trip_planner_timeline?id=${Uri.encodeQueryComponent(tripId)}',
              );
              return;
            }
            context.go('/trip_planner_dashboard');
          },
        ),
        title: Text(
          'Add From Bookings',
          style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
        ),
      ),
      body: SafeArea(top: false, child: _buildBody()),
    );
  }

  Widget _buildBody() {
    if (_items == null && _error == null) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_items == null) {
      return _ErrorView(error: _error, onRetry: _load);
    }

    final textTheme = Theme.of(context).textTheme;
    final filtered = _filtered;
    final hero = filtered.isNotEmpty ? filtered.first : null;
    final rest = filtered.length > 1 ? filtered.sublist(1) : const <MyTripCard>[];

    return RefreshIndicator(
      onRefresh: _load,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: TripwiseInsets.screen,
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
                    'No booked items match your search.',
                    style: textTheme.bodyMedium?.copyWith(
                      color: TripwiseColors.onSurfaceVariant,
                    ),
                  ),
                ),
              )
            else ...[
              Text(
                'BOOKED TICKETS & SERVICES',
                style: textTheme.labelMedium?.copyWith(
                  color: TripwiseColors.primary.withOpacity(0.70),
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(height: 12),
              _HeroBookingCard(item: hero, onAdd: _onAddTap),
              if (rest.isNotEmpty) ...[
                const SizedBox(height: 32),
                Text(
                  'More Bookings',
                  style: textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 16),
                _PopularBookingsGrid(items: rest, onAdd: _onAddTap),
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
              "Couldn't load booked items",
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
        hintText: 'Find booked tickets or services...',
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
              color: selected ? Colors.white : TripwiseColors.onSurfaceVariant,
              fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}

String _serviceTypeLabel(String value) {
  switch (value) {
    case 'activity':
      return 'Activity';
    case 'flight':
      return 'Flight';
    case 'hotel':
      return 'Hotel';
    default:
      return 'Service';
  }
}

class _HeroBookingCard extends StatelessWidget {
  const _HeroBookingCard({required this.item, required this.onAdd});

  final MyTripCard item;
  final ValueChanged<MyTripCard> onAdd;

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
          _NetImage(url: item.imageUrl),
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                colors: [Colors.black.withOpacity(0.82), Colors.transparent],
                stops: const [0.0, 0.58],
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
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _HeroPill(label: _serviceTypeLabel(item.serviceType)),
                    _HeroPill(label: item.statusLabel),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  item.title,
                  style: textTheme.displaySmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    height: 1.05,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '${item.subtitle}\n${item.dateLabel}',
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: textTheme.bodyMedium?.copyWith(
                    color: Colors.white.withOpacity(0.85),
                    fontWeight: FontWeight.w500,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton.icon(
                    onPressed: () => onAdd(item),
                    icon: const Icon(Icons.add_rounded, size: 22),
                    label: const Text('Add to Plan'),
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

class _HeroPill extends StatelessWidget {
  const _HeroPill({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.22),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w800,
            ),
      ),
    );
  }
}

class _PopularBookingsGrid extends StatelessWidget {
  const _PopularBookingsGrid({required this.items, required this.onAdd});

  final List<MyTripCard> items;
  final ValueChanged<MyTripCard> onAdd;

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
            Expanded(child: _SmallBookingCard(data: pair[0], onAdd: onAdd)),
            const SizedBox(width: 16),
            if (pair.length > 1)
              Expanded(child: _SmallBookingCard(data: pair[1], onAdd: onAdd))
            else
              const Expanded(child: SizedBox.shrink()),
          ],
        ),
      );
      if (i < items.length) {
        blocks
          ..add(const SizedBox(height: 16))
          ..add(_WideBookingCard(data: items[i], onAdd: onAdd));
        i += 1;
        if (i < items.length) blocks.add(const SizedBox(height: 16));
      }
    }
    return Column(children: blocks);
  }
}

class _SmallBookingCard extends StatelessWidget {
  const _SmallBookingCard({required this.data, required this.onAdd});

  final MyTripCard data;
  final ValueChanged<MyTripCard> onAdd;

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
                Positioned.fill(child: _NetImage(url: data.imageUrl)),
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
                _MetaRow(label: _serviceTypeLabel(data.serviceType)),
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
                  data.dateLabel,
                  maxLines: 1,
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

class _WideBookingCard extends StatelessWidget {
  const _WideBookingCard({required this.data, required this.onAdd});

  final MyTripCard data;
  final ValueChanged<MyTripCard> onAdd;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Container(
      height: 170,
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
            child: SizedBox.expand(child: _NetImage(url: data.imageUrl)),
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
                            _MetaRow(label: _serviceTypeLabel(data.serviceType)),
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
                    '${data.subtitle}\n${data.dateLabel}',
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

class _MetaRow extends StatelessWidget {
  const _MetaRow({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(
          Icons.confirmation_number_rounded,
          size: 14,
          color: TripwiseColors.secondary,
        ),
        const SizedBox(width: 4),
        Text(
          label,
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
