import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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
  final TextEditingController _priceController = TextEditingController();

  InventoryOverview? _data;
  Object? _error;
  bool _loading = false;
  bool _submitting = false;

  // null = let the server pick the current month; otherwise "YYYY-MM".
  String? _month;
  int? _selectedDay;
  bool _pendingAvailable = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _priceController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final data = await _api.fetchInventory(month: _month);
      if (!mounted) return;
      setState(() {
        _data = data;
        _selectedDay = _firstSelectableDay(data);
        _loading = false;
      });
      _syncEditors();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e;
        _loading = false;
      });
    }
  }

  int? _firstSelectableDay(InventoryOverview data) {
    for (final d in data.days) {
      if (d.status != 'closed') return d.day;
    }
    return data.days.isNotEmpty ? data.days.first.day : null;
  }

  InventoryDay? _selectedFor(InventoryOverview data) {
    final day = _selectedDay ?? _firstSelectableDay(data);
    for (final d in data.days) {
      if (d.day == day) return d;
    }
    return data.days.isNotEmpty ? data.days.first : null;
  }

  /// Push the selected day's persisted values into the editable controls.
  void _syncEditors() {
    final data = _data;
    if (data == null) return;
    final sel = _selectedFor(data);
    _priceController.text = sel == null ? '' : sel.price.round().toString();
    _pendingAvailable = sel != null && sel.status != 'closed';
  }

  void _selectDay(int day) {
    setState(() => _selectedDay = day);
    _syncEditors();
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
      _selectedDay = null;
    });
    _load();
  }

  void _snack(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(msg)));
  }

  Future<void> _submitDay() async {
    final data = _data;
    final sel = data == null ? null : _selectedFor(data);
    if (sel == null) return;
    final price = double.tryParse(_priceController.text.trim());
    if (price == null || price <= 0) {
      _snack('Enter a valid price');
      return;
    }
    setState(() => _submitting = true);
    try {
      final res = await _api.updateDay(
        date: sel.date,
        available: _pendingAvailable,
        price: price,
      );
      if (!mounted) return;
      setState(() {
        _data = res;
        _submitting = false;
      });
      _syncEditors();
      _snack('Day ${sel.day} updated');
    } on InventoryApiException catch (e) {
      if (!mounted) return;
      setState(() => _submitting = false);
      _snack(e.message);
    } catch (_) {
      if (!mounted) return;
      setState(() => _submitting = false);
      _snack('Something went wrong. Please try again.');
    }
  }

  Future<void> _saveRules({
    required double weekendSurgePct,
    required double holidayPeakPct,
    required double lastMinuteDiscPct,
    required bool weekendEnabled,
    required bool holidayEnabled,
    required bool lastMinuteEnabled,
  }) async {
    final res = await _api.updateRules(
      weekendSurgePct: weekendSurgePct,
      holidayPeakPct: holidayPeakPct,
      lastMinuteDiscPct: lastMinuteDiscPct,
      weekendEnabled: weekendEnabled,
      holidayEnabled: holidayEnabled,
      lastMinuteEnabled: lastMinuteEnabled,
      month: _data?.month ?? _month,
    );
    if (!mounted) return;
    setState(() => _data = res);
    _syncEditors();
    _snack('Pricing rules updated');
  }

  void _openRulesSheet() {
    final data = _data;
    if (data == null) return;
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _RulesSheet(
        rules: data.pricingRules,
        onSubmit: _saveRules,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TripwiseColors.surface,
      appBar: const ProviderAppBar(),
      body: SafeArea(top: false, child: _buildBody()),
      bottomNavigationBar: const ProviderTaskbar(
        currentTab: ProviderTaskbarTab.listings,
      ),
    );
  }

  Widget _buildBody() {
    final data = _data;
    if (data == null && _loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (data == null) {
      return _ErrorView(error: _error, onRetry: _load);
    }
    final selected = _selectedFor(data);
    return RefreshIndicator(
      onRefresh: _load,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
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
              priceController: _priceController,
              available: _pendingAvailable,
              submitting: _submitting,
              onAvailabilityChanged: (v) =>
                  setState(() => _pendingAvailable = v),
              onSubmit: _submitDay,
            ),
            const SizedBox(height: 24),
            _DynamicPricingCard(
              rules: data.pricingRules,
              onAdjust: _openRulesSheet,
            ),
            const SizedBox(height: 24),
            _AnalyticsCard(analytics: data.analytics),
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
                // Closed days are selectable too, so a provider can re-open one.
                onTap: () => onDayTap(cell.day),
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
    required this.priceController,
    required this.available,
    required this.submitting,
    required this.onAvailabilityChanged,
    required this.onSubmit,
  });

  final String monthLabel;
  final InventoryDay? selected;
  final TextEditingController priceController;
  final bool available;
  final bool submitting;
  final ValueChanged<bool> onAvailabilityChanged;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final sel = selected;
    final dayLabel = sel == null ? '' : '${sel.day} $monthLabel';
    final availabilitySub = sel == null
        ? 'Open for bookings'
        : (available
            ? '${sel.availableQty > 0 ? sel.availableQty : ''} open for bookings'
                .trim()
            : 'Closed for bookings');

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
                value: available,
                onChanged: sel == null ? null : onAvailabilityChanged,
                activeThumbColor: TripwiseColors.primary,
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'PRICE (₫)',
            style: textTheme.labelSmall?.copyWith(
              color: TripwiseColors.onSurfaceVariant,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.0,
            ),
          ),
          const SizedBox(height: 6),
          TextField(
            controller: priceController,
            enabled: sel != null,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            style: textTheme.titleMedium?.copyWith(
              color: TripwiseColors.primary,
              fontWeight: FontWeight.w900,
              fontSize: 18,
            ),
            decoration: InputDecoration(
              prefixText: '₫ ',
              prefixStyle: const TextStyle(
                color: TripwiseColors.primary,
                fontWeight: FontWeight.w900,
                fontSize: 18,
              ),
              filled: true,
              fillColor: TripwiseColors.surfaceContainerLow,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(
                  color: TripwiseColors.primary,
                  width: 2,
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: (sel == null || submitting) ? null : onSubmit,
              style: TripwiseButtonStyles.primaryElevated(
                radius: 14,
                padding: const EdgeInsets.symmetric(vertical: 16),
                textStyle: const TextStyle(
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.5,
                ),
              ),
              child: submitting
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Text('Update Listing'),
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
    required this.onAdjust,
  });

  final List<PricingRule> rules;
  final VoidCallback onAdjust;

  Color _toneColor(String tone) =>
      tone == 'primary' ? TripwiseColors.primary : TripwiseColors.secondary;

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
                  Row(
                    children: [
                      Text(
                        rule.label,
                        style: textTheme.bodyMedium?.copyWith(
                          color: TripwiseColors.onSurfaceVariant,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      if (!rule.enabled) ...[
                        const SizedBox(width: 6),
                        Text(
                          '(off)',
                          style: textTheme.labelSmall?.copyWith(
                            color: TripwiseColors.onSurfaceVariant,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ],
                  ),
                  Text(
                    rule.value,
                    style: textTheme.bodyMedium?.copyWith(
                      color: rule.enabled
                          ? _toneColor(rule.tone)
                          : TripwiseColors.onSurfaceVariant,
                      fontWeight: FontWeight.w800,
                      decoration:
                          rule.enabled ? null : TextDecoration.lineThrough,
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 12),
          Center(
            child: TextButton(
              onPressed: onAdjust,
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

class _RulesSheet extends StatefulWidget {
  const _RulesSheet({required this.rules, required this.onSubmit});

  final List<PricingRule> rules;
  final Future<void> Function({
    required double weekendSurgePct,
    required double holidayPeakPct,
    required double lastMinuteDiscPct,
    required bool weekendEnabled,
    required bool holidayEnabled,
    required bool lastMinuteEnabled,
  }) onSubmit;

  @override
  State<_RulesSheet> createState() => _RulesSheetState();
}

class _RulesSheetState extends State<_RulesSheet> {
  late final Map<String, TextEditingController> _ctrl;
  late final Map<String, bool> _enabled;
  bool _saving = false;

  PricingRule _rule(String key) => widget.rules.firstWhere(
        (r) => r.key == key,
        orElse: () => PricingRule(
          key: key,
          label: key,
          value: '',
          tone: 'secondary',
          percent: 0,
          enabled: true,
        ),
      );

  @override
  void initState() {
    super.initState();
    _ctrl = {
      for (final k in ['weekend', 'holiday', 'lastMinute'])
        k: TextEditingController(text: _rule(k).percent.round().toString()),
    };
    _enabled = {
      for (final k in ['weekend', 'holiday', 'lastMinute'])
        k: _rule(k).enabled,
    };
  }

  @override
  void dispose() {
    for (final c in _ctrl.values) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _save() async {
    final w = double.tryParse(_ctrl['weekend']!.text.trim());
    final h = double.tryParse(_ctrl['holiday']!.text.trim());
    final l = double.tryParse(_ctrl['lastMinute']!.text.trim());
    if (w == null || h == null || l == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter valid percentages')),
      );
      return;
    }
    setState(() => _saving = true);
    try {
      await widget.onSubmit(
        weekendSurgePct: w,
        holidayPeakPct: h,
        lastMinuteDiscPct: l,
        weekendEnabled: _enabled['weekend']!,
        holidayEnabled: _enabled['holiday']!,
        lastMinuteEnabled: _enabled['lastMinute']!,
      );
      if (mounted) Navigator.of(context).pop();
    } on InventoryApiException catch (e) {
      if (!mounted) return;
      setState(() => _saving = false);
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.message)));
    } catch (_) {
      if (!mounted) return;
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not save rules')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: Container(
        decoration: const BoxDecoration(
          color: TripwiseColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: TripwiseColors.outlineVariant,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Dynamic Pricing Rules',
              style: textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Surges add %, discounts use a negative %. Applied to days '
              'without a manually-set price.',
              style: textTheme.bodySmall?.copyWith(
                color: TripwiseColors.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 16),
            _ruleRow('weekend', 'Weekend Surge'),
            _ruleRow('holiday', 'Holiday Peak'),
            _ruleRow('lastMinute', 'Last Minute Disc.'),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _saving ? null : _save,
                style: TripwiseButtonStyles.primaryElevated(
                  radius: 14,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  textStyle: const TextStyle(
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.5,
                  ),
                ),
                child: _saving
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text('Save Rules'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _ruleRow(String key, String label) {
    final textTheme = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          SizedBox(
            width: 90,
            child: TextField(
              controller: _ctrl[key],
              enabled: _enabled[key],
              textAlign: TextAlign.center,
              keyboardType: const TextInputType.numberWithOptions(signed: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'-?\d*')),
              ],
              style: textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w800,
              ),
              decoration: InputDecoration(
                suffixText: '%',
                isDense: true,
                filled: true,
                fillColor: TripwiseColors.surfaceContainerLow,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          Switch(
            value: _enabled[key]!,
            onChanged: (v) => setState(() => _enabled[key] = v),
            activeThumbColor: TripwiseColors.primary,
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
