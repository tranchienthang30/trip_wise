import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../constants/colors.dart';
import '../models/home_content.dart';
import '../services/home_api.dart';
import '../widgets/shared_taskbars.dart';
import '../widgets/shared_top_bars.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final HomeApi _api = HomeApi();
  late Future<HomeContent> _future;

  @override
  void initState() {
    super.initState();
    _future = _api.fetchHome();
  }

  void _retry() {
    setState(() {
      _future = _api.fetchHome();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TripwiseColors.surface,
      appBar: const PlannerAppBar(),
      body: SafeArea(
        top: false,
        child: FutureBuilder<HomeContent>(
          future: _future,
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return _HomeErrorView(
                error: snapshot.error,
                onRetry: _retry,
              );
            }

            final data = snapshot.data!;
            return _HomeBody(data: data);
          },
        ),
      ),
      bottomNavigationBar: const PlannerTaskbar(
        currentTab: PlannerTaskbarTab.home,
      ),
    );
  }
}

class _HomeBody extends StatefulWidget {
  const _HomeBody({required this.data});

  final HomeContent data;

  @override
  State<_HomeBody> createState() => _HomeBodyState();
}

class _HomeBodyState extends State<_HomeBody> {
  DateTimeRange _selectedDates = _defaultDateRange();
  _GuestSelection _guests = const _GuestSelection(adults: 2);

  HomeContent get data => widget.data;

  void _openRoute(BuildContext context, String? route) {
    if (route == null || route.isEmpty) {
      return;
    }
    context.push(_routeWithTripParams(route));
  }

  String _routeWithTripParams(String route) {
    final uri = Uri.parse(route);
    final queryParameters = <String, String>{
      ...uri.queryParameters,
      'startDate': _dateOnly(_selectedDates.start),
      'endDate': _dateOnly(_selectedDates.end),
      'guests': '${_guests.totalGuests}',
      'adults': '${_guests.adults}',
      'children': '${_guests.children}',
      'rooms': '${_guests.rooms}',
    };

    return uri.replace(queryParameters: queryParameters).toString();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: TripwiseInsets.screen,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SearchCard(
            searchCard: data.searchCard,
            initialDates: _selectedDates,
            initialGuests: _guests,
            onDatesChanged: (dates) => setState(() => _selectedDates = dates),
            onGuestsChanged: (guests) => setState(() => _guests = guests),
            onOpenRoute: (route) => _openRoute(context, route),
          ),
          const SizedBox(height: 28),
          _CategoryRow(
            categories: data.categories,
            onOpenRoute: (route) => _openRoute(context, route),
          ),
          if (data.featuredOffers.isNotEmpty) ...[
            const SizedBox(height: 28),
            _OfferScroller(
              offers: data.featuredOffers,
              onOpenRoute: (route) => _openRoute(context, route),
            ),
          ],
          if (data.recommendedDestinations.isNotEmpty) ...[
            const SizedBox(height: 34),
            _SectionHeader(
              title: data.sections.recommended.title,
              subtitle: data.sections.recommended.subtitle,
              actionLabel: data.sections.recommended.actionLabel,
              onActionTap: () =>
                  _openRoute(context, data.sections.recommended.actionRoute),
            ),
            const SizedBox(height: 18),
            _RecommendedGrid(
              items: data.recommendedDestinations,
              onOpenRoute: (route) => _openRoute(context, route),
            ),
          ],
          if (data.trendingHotels.isNotEmpty) ...[
            const SizedBox(height: 36),
            _SectionHeader(
              title: data.sections.trending.title,
              actionLabel: data.sections.trending.actionLabel,
              onActionTap: data.sections.trending.actionRoute == null
                  ? null
                  : () => _openRoute(context, data.sections.trending.actionRoute),
            ),
            const SizedBox(height: 18),
            ...data.trendingHotels.map(
              (hotel) => Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: _HotelTile(
                  hotel: hotel,
                  onOpenRoute: () => _openRoute(context, hotel.route),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _HomeErrorView extends StatelessWidget {
  const _HomeErrorView({
    required this.error,
    required this.onRetry,
  });

  final Object? error;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
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
              "Couldn't load home data",
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              error?.toString() ?? 'Unknown error',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: TripwiseColors.onSurfaceVariant,
                  ),
            ),
            const SizedBox(height: 18),
            ElevatedButton(
              onPressed: onRetry,
              style: TripwiseButtonStyles.primaryElevated(),
              child: const Text('Try again'),
            ),
          ],
        ),
      ),
    );
  }
}

class _SearchCard extends StatefulWidget {
  const _SearchCard({
    required this.searchCard,
    required this.initialDates,
    required this.initialGuests,
    required this.onDatesChanged,
    required this.onGuestsChanged,
    required this.onOpenRoute,
  });

  final HomeSearchCard searchCard;
  final DateTimeRange initialDates;
  final _GuestSelection initialGuests;
  final ValueChanged<DateTimeRange> onDatesChanged;
  final ValueChanged<_GuestSelection> onGuestsChanged;
  final ValueChanged<String> onOpenRoute;

  @override
  State<_SearchCard> createState() => _SearchCardState();
}

class _SearchCardState extends State<_SearchCard> {
  late DateTimeRange _selectedDates;
  late _GuestSelection _guests;

  HomeSearchCard get searchCard => widget.searchCard;

  @override
  void initState() {
    super.initState();
    _selectedDates = widget.initialDates;
    _guests = widget.initialGuests;
  }

  Future<void> _pickDates() async {
    final now = DateTime.now();
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(now.year, now.month, now.day),
      lastDate: DateTime(now.year + 2, 12, 31),
      initialDateRange: _selectedDates,
      helpText: 'Select travel dates',
      saveText: 'Apply',
    );
    if (picked == null) return;

    setState(() => _selectedDates = picked);
    widget.onDatesChanged(picked);
  }

  Future<void> _pickGuests() async {
    final picked = await showModalBottomSheet<_GuestSelection>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        var draft = _guests;
        return StatefulBuilder(
          builder: (context, setSheetState) {
            void update(_GuestSelection next) {
              setSheetState(() => draft = next);
            }

            return SafeArea(
              child: Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: TripwiseColors.surfaceContainerLowest,
                  borderRadius: BorderRadius.circular(22),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Guests',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w900,
                          ),
                    ),
                    const SizedBox(height: 14),
                    _GuestStepper(
                      label: 'Adults',
                      value: draft.adults,
                      min: 1,
                      onChanged: (value) => update(draft.copyWith(adults: value)),
                    ),
                    _GuestStepper(
                      label: 'Children',
                      value: draft.children,
                      min: 0,
                      onChanged: (value) =>
                          update(draft.copyWith(children: value)),
                    ),
                    _GuestStepper(
                      label: 'Rooms',
                      value: draft.rooms,
                      min: 1,
                      onChanged: (value) => update(draft.copyWith(rooms: value)),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => Navigator.of(sheetContext).pop(draft),
                        style: TripwiseButtonStyles.primaryElevated(radius: 18),
                        child: const Text('Apply'),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
    if (picked == null) return;

    setState(() => _guests = picked);
    widget.onGuestsChanged(picked);
  }

  String _routeWithFilters(String route) {
    final uri = Uri.parse(route);
    final queryParameters = <String, String>{
      ...uri.queryParameters,
      'guests': '${_guests.totalGuests}',
      'adults': '${_guests.adults}',
      'children': '${_guests.children}',
      'rooms': '${_guests.rooms}',
    };

    queryParameters['startDate'] = _dateOnly(_selectedDates.start);
    queryParameters['endDate'] = _dateOnly(_selectedDates.end);

    return uri.replace(queryParameters: queryParameters).toString();
  }

  bool _isDatesItem(HomeSearchDetailItem item) {
    return item.label.toLowerCase().contains('date') ||
        item.icon == 'calendar_today_rounded';
  }

  bool _isGuestsItem(HomeSearchDetailItem item) {
    return item.label.toLowerCase().contains('guest') ||
        item.icon == 'group_rounded';
  }

  String _valueForItem(BuildContext context, HomeSearchDetailItem item) {
    if (_isDatesItem(item)) {
      return _formatDateRange(context, _selectedDates);
    }
    if (_isGuestsItem(item)) {
      return _guests.label;
    }
    return item.value;
  }

  VoidCallback? _actionForItem(HomeSearchDetailItem item) {
    if (_isDatesItem(item)) return _pickDates;
    if (_isGuestsItem(item)) return _pickGuests;
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final details = searchCard.detailItems;

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
            searchCard.headline,
            style: Theme.of(context).textTheme.displaySmall?.copyWith(
                  fontWeight: FontWeight.w900,
                  letterSpacing: -1,
                ),
          ),
          const SizedBox(height: 22),
          InkWell(
            onTap: () =>
                widget.onOpenRoute(_routeWithFilters(searchCard.destinationRoute)),
            borderRadius: BorderRadius.circular(18),
            child: Container(
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
                    searchCard.destinationPlaceholder,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          color:
                              TripwiseColors.onSurfaceVariant.withOpacity(0.65),
                        ),
                  ),
                ],
              ),
            ),
          ),
          if (details.isNotEmpty) ...[
            const SizedBox(height: 12),
            LayoutBuilder(
              builder: (context, constraints) {
                const spacing = 12.0;
                final itemWidth = (constraints.maxWidth - spacing) / 2;

                return Wrap(
                  spacing: spacing,
                  runSpacing: spacing,
                  children: details
                      .map(
                        (item) => SizedBox(
                          width: itemWidth,
                          child: _SearchDetailCard(
                            item: item,
                            value: _valueForItem(context, item),
                            onTap: _actionForItem(item),
                          ),
                        ),
                      )
                      .toList(),
                );
              },
            ),
          ],
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () =>
                  widget.onOpenRoute(_routeWithFilters(searchCard.searchButtonRoute)),
              style: TripwiseButtonStyles.primaryElevated(
                radius: 24,
                padding: const EdgeInsets.symmetric(vertical: 18),
                textStyle: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
              ),
              child: Text(searchCard.searchButtonLabel),
            ),
          ),
        ],
      ),
    );
  }
}

class _SearchDetailCard extends StatelessWidget {
  const _SearchDetailCard({
    required this.item,
    required this.value,
    this.onTap,
  });

  final HomeSearchDetailItem item;
  final String value;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Ink(
          height: 98,
          decoration: BoxDecoration(
            color: TripwiseColors.surfaceContainer,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: TripwiseColors.outlineVariant),
            boxShadow: [
              BoxShadow(
                color: TripwiseColors.primary.withOpacity(0.05),
                blurRadius: 14,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                      color: TripwiseColors.primaryFixed,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      _iconFromName(item.icon),
                      size: 17,
                      color: TripwiseColors.primary,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      item.label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            letterSpacing: 1.1,
                            color: TripwiseColors.onSurfaceVariant,
                            fontWeight: FontWeight.w900,
                          ),
                    ),
                  ),
                  const Icon(
                    Icons.keyboard_arrow_down_rounded,
                    size: 18,
                    color: TripwiseColors.onSurfaceVariant,
                  ),
                ],
              ),
              const Spacer(),
              Text(
                value,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w900,
                      color: TripwiseColors.onSurface,
                      height: 1.05,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GuestSelection {
  const _GuestSelection({
    required this.adults,
    this.children = 0,
    this.rooms = 1,
  });

  final int adults;
  final int children;
  final int rooms;

  int get totalGuests => adults + children;

  String get label {
    final parts = <String>[
      '$adults ${adults == 1 ? 'Adult' : 'Adults'}',
      if (children > 0) '$children ${children == 1 ? 'Child' : 'Children'}',
    ];
    return parts.join(', ');
  }

  _GuestSelection copyWith({
    int? adults,
    int? children,
    int? rooms,
  }) {
    return _GuestSelection(
      adults: adults ?? this.adults,
      children: children ?? this.children,
      rooms: rooms ?? this.rooms,
    );
  }
}

class _GuestStepper extends StatelessWidget {
  const _GuestStepper({
    required this.label,
    required this.value,
    required this.min,
    required this.onChanged,
  });

  final String label;
  final int value;
  final int min;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
            ),
          ),
          IconButton.filledTonal(
            onPressed: value <= min ? null : () => onChanged(value - 1),
            icon: const Icon(Icons.remove_rounded),
          ),
          SizedBox(
            width: 42,
            child: Text(
              '$value',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
            ),
          ),
          IconButton.filledTonal(
            onPressed: () => onChanged(value + 1),
            icon: const Icon(Icons.add_rounded),
          ),
        ],
      ),
    );
  }
}

String _dateOnly(DateTime value) {
  final year = value.year.toString().padLeft(4, '0');
  final month = value.month.toString().padLeft(2, '0');
  final day = value.day.toString().padLeft(2, '0');
  return '$year-$month-$day';
}

DateTimeRange _defaultDateRange() {
  final now = DateTime.now();
  final start = DateTime(now.year, now.month, now.day + 1);
  final end = start.add(const Duration(days: 2));
  return DateTimeRange(start: start, end: end);
}

String _formatDateRange(BuildContext context, DateTimeRange range) {
  final localizations = MaterialLocalizations.of(context);
  final start = localizations.formatShortMonthDay(range.start);
  final end = range.start.month == range.end.month &&
          range.start.year == range.end.year
      ? range.end.day.toString()
      : localizations.formatShortMonthDay(range.end);
  return range.start.month == range.end.month && range.start.year == range.end.year
      ? '$start-$end'
      : '$start - $end';
}

class _CategoryRow extends StatelessWidget {
  const _CategoryRow({
    required this.categories,
    required this.onOpenRoute,
  });

  final List<HomeCategoryItem> categories;
  final ValueChanged<String> onOpenRoute;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (int index = 0; index < categories.length; index++) ...[
          Expanded(
            child: _CategoryChip(
              category: categories[index],
              onTap: () => onOpenRoute(categories[index].route),
            ),
          ),
          if (index != categories.length - 1) const SizedBox(width: 10),
        ],
      ],
    );
  }
}

class _CategoryChip extends StatelessWidget {
  const _CategoryChip({
    required this.category,
    required this.onTap,
  });

  final HomeCategoryItem category;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final backgroundTone =
        category.key == 'flights' ? 'primary_soft' : category.backgroundTone;
    final iconTone = category.key == 'flights' ? 'primary' : category.iconTone;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(32),
      child: Column(
        children: [
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              color: _backgroundToneColor(backgroundTone),
              shape: BoxShape.circle,
            ),
            child: Icon(
              _iconFromName(category.icon),
              color: _toneColor(iconTone),
              size: 28,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            category.label,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  letterSpacing: 1.1,
                  fontWeight: FontWeight.w800,
                ),
          ),
        ],
      ),
    );
  }
}

class _OfferScroller extends StatelessWidget {
  const _OfferScroller({
    required this.offers,
    required this.onOpenRoute,
  });

  final List<HomeOfferItem> offers;
  final ValueChanged<String> onOpenRoute;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: offers
            .map(
              (offer) => Padding(
                padding: const EdgeInsets.only(right: 14),
                child: _OfferCard(
                  offer: offer,
                  onOpenRoute: () => onOpenRoute(offer.route),
                ),
              ),
            )
            .toList(),
      ),
    );
  }
}

class _OfferCard extends StatelessWidget {
  const _OfferCard({
    required this.offer,
    required this.onOpenRoute,
  });

  final HomeOfferItem offer;
  final VoidCallback onOpenRoute;

  @override
  Widget build(BuildContext context) {
    final ctaColor = offer.ctaLabel.toUpperCase().contains('VIEW')
        ? TripwiseColors.primary
        : _toneColor(offer.accentTone);
    return InkWell(
      onTap: onOpenRoute,
      borderRadius: BorderRadius.circular(26),
      child: SizedBox(
        width: 290,
        height: 168,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(26),
          child: Stack(
            fit: StackFit.expand,
            children: [
              _NetworkFillImage(imageUrl: offer.imageUrl),
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.black.withOpacity(0.42),
                      Colors.black.withOpacity(0.08),
                    ],
                    begin: Alignment.bottomLeft,
                    end: Alignment.topRight,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      offer.badgeLabel,
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
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.white.withOpacity(0.9),
                          ),
                    ),
                    const Spacer(),
                    FilledButton(
                      onPressed: onOpenRoute,
                      style: TripwiseButtonStyles.overlayFilled(
                        foregroundColor: ctaColor,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 18,
                          vertical: 10,
                        ),
                        minimumSize: const Size(0, 38),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        textStyle: Theme.of(context).textTheme.labelLarge?.copyWith(
                              fontWeight: FontWeight.w800,
                            ),
                      ),
                      child: Text(offer.ctaLabel),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.title,
    this.subtitle,
    this.actionLabel,
    this.onActionTap,
  });

  final String title;
  final String? subtitle;
  final String? actionLabel;
  final VoidCallback? onActionTap;

  @override
  Widget build(BuildContext context) {
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
              if (subtitle != null && subtitle!.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  subtitle!,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: TripwiseColors.onSurfaceVariant.withOpacity(0.75),
                      ),
                ),
              ],
            ],
          ),
        ),
        if (actionLabel != null && actionLabel!.isNotEmpty)
          TextButton(
            onPressed: onActionTap,
            style: TripwiseButtonStyles.text(
              foregroundColor: TripwiseColors.primary,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            ),
            child: Text(
              actionLabel!,
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
      ],
    );
  }
}

class _RecommendedGrid extends StatelessWidget {
  const _RecommendedGrid({
    required this.items,
    required this.onOpenRoute,
  });

  final List<HomeRecommendedItem> items;
  final ValueChanged<String> onOpenRoute;

  @override
  Widget build(BuildContext context) {
    final leftColumn = <HomeRecommendedItem>[];
    final rightColumn = <HomeRecommendedItem>[];

    for (int index = 0; index < items.length; index++) {
      if (index.isEven) {
        leftColumn.add(items[index]);
      } else {
        rightColumn.add(items[index]);
      }
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            children: leftColumn
                .map(
                  (item) => Padding(
                    padding: const EdgeInsets.only(bottom: 14),
                    child: _RecommendedCard(
                      item: item,
                      onOpenRoute: () => onOpenRoute(item.route),
                    ),
                  ),
                )
                .toList(),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            children: rightColumn
                .map(
                  (item) => Padding(
                    padding: const EdgeInsets.only(bottom: 14),
                    child: _RecommendedCard(
                      item: item,
                      onOpenRoute: () => onOpenRoute(item.route),
                    ),
                  ),
                )
                .toList(),
          ),
        ),
      ],
    );
  }
}

class _RecommendedCard extends StatelessWidget {
  const _RecommendedCard({
    required this.item,
    required this.onOpenRoute,
  });

  final HomeRecommendedItem item;
  final VoidCallback onOpenRoute;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onOpenRoute,
      borderRadius: BorderRadius.circular(28),
      child: SizedBox(
        height: item.cardHeight,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(28),
          child: Stack(
            fit: StackFit.expand,
            children: [
              _NetworkFillImage(imageUrl: item.imageUrl),
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.black.withOpacity(0.55),
                      Colors.black.withOpacity(0.02),
                    ],
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                  ),
                ),
              ),
              Padding(
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
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        if (item.priceLabel != null && item.priceLabel!.isNotEmpty)
                          Container(
                            decoration: BoxDecoration(
                              color: TripwiseColors.secondary,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            child: Text(
                              item.priceLabel!,
                              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w800,
                                  ),
                            ),
                          ),
                        if (item.priceLabel != null && item.priceLabel!.isNotEmpty)
                          const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            item.caption,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: Colors.white.withOpacity(0.82),
                                ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HotelTile extends StatelessWidget {
  const _HotelTile({
    required this.hotel,
    required this.onOpenRoute,
  });

  final HomeTrendingHotelItem hotel;
  final VoidCallback onOpenRoute;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: _ThumbnailImage(imageUrl: hotel.imageUrl),
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
                  Expanded(
                    child: Text(
                      hotel.location,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: TripwiseColors.onSurfaceVariant,
                          ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  RichText(
                    text: TextSpan(
                      text: hotel.priceLabel ?? 'Price unavailable',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: TripwiseColors.primary,
                            fontWeight: FontWeight.w900,
                          ),
                      children: [
                        if (hotel.priceLabel != null)
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
                    onPressed: onOpenRoute,
                    style: TripwiseButtonStyles.text(
                      foregroundColor: TripwiseColors.primary,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 8,
                      ),
                    ),
                    child: Text(
                      hotel.detailsLabel,
                      style: const TextStyle(fontWeight: FontWeight.w800),
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

class _NetworkFillImage extends StatelessWidget {
  const _NetworkFillImage({required this.imageUrl});

  final String? imageUrl;

  @override
  Widget build(BuildContext context) {
    if (imageUrl == null || imageUrl!.isEmpty) {
      return Container(
        color: TripwiseColors.surfaceContainerLow,
        alignment: Alignment.center,
        child: const Icon(
          Icons.image_rounded,
          size: 36,
          color: TripwiseColors.onSurfaceVariant,
        ),
      );
    }

    return Image.network(
      imageUrl!,
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
        if (progress == null) {
          return child;
        }
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

class _ThumbnailImage extends StatelessWidget {
  const _ThumbnailImage({required this.imageUrl});

  final String? imageUrl;

  @override
  Widget build(BuildContext context) {
    if (imageUrl == null || imageUrl!.isEmpty) {
      return Container(
        width: 82,
        height: 82,
        color: TripwiseColors.surfaceContainerLow,
        alignment: Alignment.center,
        child: const Icon(
          Icons.image_rounded,
          color: TripwiseColors.onSurfaceVariant,
        ),
      );
    }

    return Image.network(
      imageUrl!,
      width: 82,
      height: 82,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => Container(
        width: 82,
        height: 82,
        color: TripwiseColors.surfaceContainerLow,
        alignment: Alignment.center,
        child: const Icon(
          Icons.broken_image_rounded,
          color: TripwiseColors.onSurfaceVariant,
        ),
      ),
    );
  }
}

Color _toneColor(String tone) {
  switch (tone) {
    case 'secondary':
      return TripwiseColors.secondary;
    case 'secondary_container':
      return TripwiseColors.secondaryContainer;
    case 'on_primary':
      return TripwiseColors.onPrimary;
    case 'outline':
      return TripwiseColors.outline;
    case 'primary':
    default:
      return TripwiseColors.primary;
  }
}

Color _backgroundToneColor(String tone) {
  switch (tone) {
    case 'secondary_soft':
      return const Color(0xFFFBE6DF);
    case 'surface':
      return TripwiseColors.surfaceContainerLow;
    case 'primary_soft':
    default:
      return const Color(0xFFE4F1FF);
  }
}

IconData _iconFromName(String iconName) {
  switch (iconName) {
    case 'bed_rounded':
      return Icons.bed_rounded;
    case 'flight_rounded':
      return Icons.flight_rounded;
    case 'explore_rounded':
      return Icons.explore_rounded;
    case 'train_rounded':
      return Icons.train_rounded;
    case 'calendar_today_rounded':
      return Icons.calendar_today_rounded;
    case 'group_rounded':
      return Icons.group_rounded;
    case 'location_on_rounded':
      return Icons.location_on_rounded;
    default:
      return Icons.circle_rounded;
  }
}
