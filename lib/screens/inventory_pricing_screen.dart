import 'package:flutter/material.dart';

import '../constants/colors.dart';
import '../models/inventory_overview.dart';
import '../services/inventory_api.dart';
import '../utils/currency.dart';
import '../widgets/shared_taskbars.dart';
import '../widgets/shared_top_bars.dart';

// Brand palette has no green; matches HTML mock for available-day indicator.
const Color _availableGreen = Color(0xFF22C55E);

enum _DayStatus { available, highPrice, closed }

_DayStatus _statusFromString(String s) {
  switch (s) {
    case 'highPrice':
      return _DayStatus.highPrice;
    case 'closed':
      return _DayStatus.closed;
    default:
      return _DayStatus.available;
  }
}

class InventoryPricingScreen extends StatefulWidget {
  const InventoryPricingScreen({super.key});

  @override
  State<InventoryPricingScreen> createState() => _InventoryPricingScreenState();
}

class _InventoryPricingScreenState extends State<InventoryPricingScreen> {
  static const List<String> _weekdayLabels = [
    'MON',
    'TUE',
    'WED',
    'THU',
    'FRI',
    'SAT',
    'SUN',
  ];

  final InventoryApi _api = InventoryApi();
  late Future<InventoryOverview> _future;
  InventoryOverview? _data;

  // null = let the server pick the current month; otherwise "YYYY-MM".
  String? _month;
  int? _selectedDay;

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() {
    _future = _api.fetchInventory(month: _month);
    _future.then((data) {
      if (!mounted) return;
      setState(() {
        _data = data;
        _selectedDay = _firstSelectableDay(data);
      });
    }).catchError((_) {});
  }

  int? _firstSelectableDay(InventoryOverview data) {
    for (final d in data.days) {
      if (d.status != 'closed') return d.day;
    }
    return data.days.isNotEmpty ? data.days.first.day : null;
  }

  void _retry() {
    setState(() {
      _data = null;
      _load();
    });
  }

  void _changeMonth(int delta) {
    final base = _data?.month ?? _month;
    if (base == null || !base.contains('-')) return;
    final parts = base.split('-');
    int y = int.parse(parts[0]);
    int m = int.parse(parts[1]) + delta;
    if (m == 0) {
      m = 12;
      y--;
    } else if (m == 13) {
      m = 1;
      y++;
    }
    setState(() {
      _month = '$y-${m.toString().padLeft(2, '0')}';
      _data = null;
      _selectedDay = null;
      _load();
    });
  }

  void _selectDay(int day) => setState(() => _selectedDay = day);

  void _comingSoon() {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        const SnackBar(content: Text('Editing inventory is coming soon')),
      );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TripwiseColors.surface,
      appBar: const ProviderAppBar(),
      body: SafeArea(
        top: false,
        child: FutureBuilder<InventoryOverview>(
          future: _future,
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return _ErrorView(error: snapshot.error, onRetry: _retry);
            }
            final data = snapshot.data!;
            final selected = _selectedFor(data);
            return SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const _EditorialHeader(),
                  const SizedBox(height: 24),
                  _CalendarCard(
                    data: data,
                    weekdayLabels: _weekdayLabels,
                    selectedDay: _selectedDay,
                    onDayTap: _selectDay,
                    onPrevMonth: () => _changeMonth(-1),
                    onNextMonth: () => _changeMonth(1),
                  ),
                  const SizedBox(height: 24),
                  _DaySettingsCard(
                    monthLabel: data.monthLabel,
                    selected: selected,
                    onComingSoon: _comingSoon,
                  ),
                  const SizedBox(height: 24),
                  _DynamicPricingCard(
                    rules: data.pricingRules,
                    onComingSoon: _comingSoon,
                  ),
                  const SizedBox(height: 24),
                  _AnalyticsCard(analytics: data.analytics),
                ],
              ),
            );
          },
        ),
      ),
      bottomNavigationBar: const ProviderTaskbar(
        currentTab: ProviderTaskbarTab.listings,
      ),
    );
  }

  InventoryDay? _selectedFor(InventoryOverview data) {
    final day = _selectedDay ?? _firstSelectableDay(data);
    for (final d in data.days) {
      if (d.day == day) return d;
    }
    return data.days.isNotEmpty ? data.days.first : null;
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
              "Couldn't load inventory",
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

class _EditorialHeader extends StatelessWidget {
  const _EditorialHeader();

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Inventory',
          style: textTheme.displayLarge?.copyWith(
            color: TripwiseColors.primary,
            fontWeight: FontWeight.w900,
            fontSize: 44,
            height: 1.0,
            letterSpacing: -1.5,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Manage your availability and dynamic pricing.',
          style: textTheme.bodyMedium?.copyWith(
            color: TripwiseColors.onSurfaceVariant,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class _CalendarCard extends StatelessWidget {
  const _CalendarCard({
    required this.data,
    required this.weekdayLabels,
    required this.selectedDay,
    required this.onDayTap,
    required this.onPrevMonth,
    required this.onNextMonth,
  });

  final InventoryOverview data;
  final List<String> weekdayLabels;
  final int? selectedDay;
  final ValueChanged<int> onDayTap;
  final VoidCallback onPrevMonth;
  final VoidCallback onNextMonth;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final cellCount = data.leadingBlanks + data.days.length;
    return Container(
      decoration: BoxDecoration(
        color: TripwiseColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: TripwiseColors.primary.withValues(alpha: 0.06),
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
                data.monthLabel,
                style: textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    onPressed: onPrevMonth,
                    icon: const Icon(
                      Icons.chevron_left_rounded,
                      color: TripwiseColors.primary,
                    ),
                  ),
                  IconButton(
                    onPressed: onNextMonth,
                    icon: const Icon(
                      Icons.chevron_right_rounded,
                      color: TripwiseColors.primary,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              for (final label in weekdayLabels)
                Expanded(
                  child: Center(
                    child: Text(
                      label,
                      style: textTheme.labelSmall?.copyWith(
                        color: TripwiseColors.onSurfaceVariant,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              mainAxisSpacing: 6,
              crossAxisSpacing: 6,
              childAspectRatio: 0.85,
            ),
            itemCount: cellCount,
            itemBuilder: (context, i) {
              if (i < data.leadingBlanks) return const SizedBox.shrink();
              final cell = data.days[i - data.leadingBlanks];
              final status = _statusFromString(cell.status);
              return _CalendarCell(
                day: cell.day,
                priceLabel: status == _DayStatus.closed
                    ? 'Closed'
                    : formatVndCompact(cell.price),
                status: status,
                isSelected: cell.day == selectedDay,
                onTap: status == _DayStatus.closed
                    ? null
                    : () => onDayTap(cell.day),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _CalendarCell extends StatelessWidget {
  const _CalendarCell({
    required this.day,
    required this.priceLabel,
    required this.status,
    required this.isSelected,
    required this.onTap,
  });

  final int day;
  final String priceLabel;
  final _DayStatus status;
  final bool isSelected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final Color bgColor;
    final Color dateColor;
    final Color priceColor;
    final Color dotColor;
    final double dateOpacity;
    final List<BoxShadow>? shadow;

    if (isSelected) {
      bgColor = TripwiseColors.primaryContainer;
      dateColor = Colors.white;
      priceColor = Colors.white;
      dotColor = Colors.white;
      dateOpacity = 1.0;
      shadow = [
        BoxShadow(
          color: TripwiseColors.primary.withValues(alpha: 0.20),
          blurRadius: 12,
          offset: const Offset(0, 6),
        ),
      ];
    } else {
      switch (status) {
        case _DayStatus.highPrice:
          bgColor = TripwiseColors.secondaryFixed;
          dateColor = TripwiseColors.secondary;
          priceColor = TripwiseColors.secondary;
          dotColor = TripwiseColors.secondary;
          dateOpacity = 1.0;
          shadow = null;
          break;
        case _DayStatus.closed:
          bgColor = TripwiseColors.surfaceContainer;
          dateColor = TripwiseColors.onSurface;
          priceColor = TripwiseColors.onSurface;
          dotColor = TripwiseColors.error;
          dateOpacity = 1.0;
          shadow = null;
          break;
        case _DayStatus.available:
          bgColor = TripwiseColors.surfaceContainerLow;
          dateColor = TripwiseColors.onSurface;
          priceColor = TripwiseColors.primary;
          dotColor = _availableGreen;
          dateOpacity = 0.6;
          shadow = null;
          break;
      }
    }

    final cell = Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: shadow,
      ),
      child: Stack(
        children: [
          Positioned(
            top: 0,
            left: 0,
            child: Opacity(
              opacity: dateOpacity,
              child: Text(
                '$day',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: dateColor,
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  priceLabel,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: priceColor,
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: dotColor,
                    shape: BoxShape.circle,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );

    final tappable = GestureDetector(onTap: onTap, child: cell);

    if (status == _DayStatus.closed && !isSelected) {
      return Opacity(opacity: 0.5, child: tappable);
    }
    return tappable;
  }
}

class _DaySettingsCard extends StatelessWidget {
  const _DaySettingsCard({
    required this.monthLabel,
    required this.selected,
    required this.onComingSoon,
  });

  final String monthLabel;
  final InventoryDay? selected;
  final VoidCallback onComingSoon;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final sel = selected;
    final isOpen = sel != null && sel.status != 'closed';
    final dayLabel = sel == null ? '' : '${sel.day} $monthLabel';
    final availabilitySub = sel == null
        ? 'Open for bookings'
        : (isOpen ? '${sel.availableQty} rooms open' : 'Closed for bookings');

    return Container(
      decoration: BoxDecoration(
        color: TripwiseColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: TripwiseColors.primary.withValues(alpha: 0.06),
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
                'DAY SETTINGS',
                style: textTheme.labelMedium?.copyWith(
                  color: TripwiseColors.onSurfaceVariant,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.5,
                ),
              ),
              if (dayLabel.isNotEmpty)
                Text(
                  dayLabel,
                  style: textTheme.labelMedium?.copyWith(
                    color: TripwiseColors.primary,
                    fontWeight: FontWeight.w800,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Availability',
                    style: textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    availabilitySub,
                    style: textTheme.bodySmall?.copyWith(
                      color: TripwiseColors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
              Switch(
                value: isOpen,
                onChanged: (_) => onComingSoon(),
                activeThumbColor: TripwiseColors.primary,
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'PRICE',
            style: textTheme.labelSmall?.copyWith(
              color: TripwiseColors.onSurfaceVariant,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.0,
            ),
          ),
          const SizedBox(height: 6),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: TripwiseColors.surfaceContainerLow,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Text(
              sel == null ? '—' : formatVnd(sel.price),
              style: textTheme.titleMedium?.copyWith(
                color: TripwiseColors.primary,
                fontWeight: FontWeight.w900,
                fontSize: 18,
              ),
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onComingSoon,
              style: TripwiseButtonStyles.primaryElevated(
                radius: 14,
                padding: const EdgeInsets.symmetric(vertical: 16),
                textStyle: const TextStyle(
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.5,
                ),
              ),
              child: const Text('Update Listing'),
            ),
          ),
        ],
      ),
    );
  }
}

class _DynamicPricingCard extends StatelessWidget {
  const _DynamicPricingCard({
    required this.rules,
    required this.onComingSoon,
  });

  final List<PricingRule> rules;
  final VoidCallback onComingSoon;

  Color _toneColor(String tone) => tone == 'primary'
      ? TripwiseColors.primary
      : TripwiseColors.secondary;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Container(
      decoration: BoxDecoration(
        color: TripwiseColors.primary.withValues(alpha: 0.05),
        borderRadius: const BorderRadius.only(
          topRight: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
        border: const Border(
          left: BorderSide(color: TripwiseColors.primary, width: 4),
        ),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.auto_awesome_rounded,
                color: TripwiseColors.primary,
                size: 22,
              ),
              const SizedBox(width: 8),
              Text(
                'Dynamic Pricing',
                style: textTheme.titleMedium?.copyWith(
                  color: TripwiseColors.primary,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          for (final rule in rules)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    rule.label,
                    style: textTheme.bodyMedium?.copyWith(
                      color: TripwiseColors.onSurfaceVariant,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    rule.value,
                    style: textTheme.bodyMedium?.copyWith(
                      color: _toneColor(rule.tone),
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 12),
          Center(
            child: TextButton(
              onPressed: onComingSoon,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Adjust Rules',
                    style: textTheme.labelLarge?.copyWith(
                      color: TripwiseColors.primary,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Icon(
                    Icons.settings_rounded,
                    size: 16,
                    color: TripwiseColors.primary,
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

class _AnalyticsCard extends StatelessWidget {
  const _AnalyticsCard({required this.analytics});

  final InventoryAnalytics analytics;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final occ = analytics.occupancyPct.clamp(0, 100);
    return Container(
      decoration: BoxDecoration(
        color: TripwiseColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(24),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _StatBlock(
            label: 'OCCUPANCY',
            value: '$occ%',
            valueColor: TripwiseColors.primary,
            extra: ClipRRect(
              borderRadius: BorderRadius.circular(999),
              child: SizedBox(
                height: 6,
                child: Row(
                  children: [
                    Expanded(
                      flex: occ == 0 ? 1 : occ,
                      child: Container(color: TripwiseColors.primary),
                    ),
                    Expanded(
                      flex: (100 - occ) == 0 ? 1 : (100 - occ),
                      child:
                          Container(color: TripwiseColors.surfaceContainerHigh),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Divider(
            color: TripwiseColors.outlineVariant.withValues(alpha: 0.5),
            height: 28,
          ),
          _StatBlock(
            label: 'REVENUE FORECAST',
            value: formatVnd(analytics.revenueForecast),
            valueColor: TripwiseColors.primary,
            extra: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.trending_up_rounded,
                  size: 14,
                  color: TripwiseColors.secondary,
                ),
                const SizedBox(width: 4),
                Text(
                  analytics.revenueDeltaLabel,
                  style: textTheme.labelSmall?.copyWith(
                    color: TripwiseColors.secondary,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
          Divider(
            color: TripwiseColors.outlineVariant.withValues(alpha: 0.5),
            height: 28,
          ),
          _StatBlock(
            label: 'MARKET DEMAND',
            value: analytics.demandLevel,
            valueColor: TripwiseColors.secondary,
            extra: Text(
              analytics.demandNote,
              style: textTheme.bodySmall?.copyWith(
                color: TripwiseColors.onSurfaceVariant,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatBlock extends StatelessWidget {
  const _StatBlock({
    required this.label,
    required this.value,
    required this.valueColor,
    required this.extra,
  });

  final String label;
  final String value;
  final Color valueColor;
  final Widget extra;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: textTheme.labelMedium?.copyWith(
            color: TripwiseColors.onSurfaceVariant,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.5,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: textTheme.headlineMedium?.copyWith(
            color: valueColor,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 8),
        extra,
      ],
    );
  }
}
