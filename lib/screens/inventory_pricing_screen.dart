import 'package:flutter/material.dart';

import '../constants/colors.dart';

// Brand palette has no green; matches HTML mock for available-day indicator.
const Color _availableGreen = Color(0xFF22C55E);

enum _DayStatus { available, highPrice, closed }

class InventoryPricingScreen extends StatefulWidget {
  const InventoryPricingScreen({super.key});

  @override
  State<InventoryPricingScreen> createState() => _InventoryPricingScreenState();
}

class _InventoryPricingScreenState extends State<InventoryPricingScreen> {
  static const String _avatarUrl =
      'https://lh3.googleusercontent.com/aida-public/AB6AXuA5SxqLMpzcg5dMTl7osEQlvMV9-cKgQs2Bh80DeXJ_kW1Ol08gECvbA7xryT4XCE5Pn7HK__TA-BWF9U14lw8eGNHC9pK654Wpq4ThAg6MOFsD32SNrfnphe-_x6z4i62jmkJN2YCw6usrVZDfaF1zq-fnqr5HFux1LThKwDaFg5o-EPEuSpdsTzDaX5QtWOx1-4_OppL4knrYFolBKvoZ6aMyWCzKJGgqEn_oIjB3d4vSBjs05APNIWxH_ss-ZqfdL9IRO0gMneo';

  static const List<String> _weekdayLabels = [
    'MON',
    'TUE',
    'WED',
    'THU',
    'FRI',
    'SAT',
    'SUN',
  ];

  static final List<_CalendarCellData?> _dayCells = [
    null,
    null,
    null,
    const _CalendarCellData(day: 1, price: '\$120', status: _DayStatus.available),
    const _CalendarCellData(day: 2, price: '\$120', status: _DayStatus.available),
    const _CalendarCellData(day: 3, price: '\$145', status: _DayStatus.highPrice),
    const _CalendarCellData(day: 4, price: '\$145', status: _DayStatus.highPrice),
    const _CalendarCellData(day: 5, price: '\$120', status: _DayStatus.available),
    const _CalendarCellData(day: 6, price: 'Closed', status: _DayStatus.closed),
    const _CalendarCellData(day: 7, price: '\$120', status: _DayStatus.available),
    const _CalendarCellData(day: 8, price: '\$120', status: _DayStatus.available),
    const _CalendarCellData(day: 9, price: '\$120', status: _DayStatus.available),
    const _CalendarCellData(day: 10, price: '\$120', status: _DayStatus.available),
    const _CalendarCellData(day: 11, price: '\$120', status: _DayStatus.available),
  ];

  static final List<_PricingRule> _pricingRules = [
    const _PricingRule(
      label: 'Weekend Surge',
      value: '+20%',
      valueColor: TripwiseColors.secondary,
    ),
    const _PricingRule(
      label: 'Holiday Peak',
      value: '+35%',
      valueColor: TripwiseColors.secondary,
    ),
    const _PricingRule(
      label: 'Last Minute Disc.',
      value: '-10%',
      valueColor: TripwiseColors.primary,
    ),
  ];

  int _selectedDay = 5;
  bool _isAvailable = true;
  int _currentNavIndex = 1;
  late final TextEditingController _priceController;

  @override
  void initState() {
    super.initState();
    _priceController = TextEditingController(text: '120.00');
  }

  @override
  void dispose() {
    _priceController.dispose();
    super.dispose();
  }

  void _onDayTap(int day) {
    setState(() => _selectedDay = day);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TripwiseColors.surface,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: const Padding(
          padding: EdgeInsets.all(8),
          child: CircleAvatar(
            backgroundColor: TripwiseColors.primaryFixed,
            backgroundImage: NetworkImage(_avatarUrl),
          ),
        ),
        title: Text(
          'Tripwise Business',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: TripwiseColors.primary,
                fontWeight: FontWeight.w900,
              ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: IconButton(
              icon: const Icon(
                Icons.notifications_rounded,
                color: TripwiseColors.primary,
              ),
              onPressed: () {},
            ),
          ),
        ],
      ),
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _EditorialHeader(),
              const SizedBox(height: 24),
              _CalendarCard(
                dayCells: _dayCells,
                weekdayLabels: _weekdayLabels,
                selectedDay: _selectedDay,
                onDayTap: _onDayTap,
              ),
              const SizedBox(height: 24),
              _DaySettingsCard(
                isAvailable: _isAvailable,
                onAvailabilityChanged: (v) =>
                    setState(() => _isAvailable = v),
                priceController: _priceController,
              ),
              const SizedBox(height: 24),
              _DynamicPricingCard(rules: _pricingRules),
              const SizedBox(height: 24),
              const _AnalyticsCard(),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _currentNavIndex,
        selectedItemColor: TripwiseColors.secondaryContainer,
        unselectedItemColor: TripwiseColors.outline,
        onTap: (index) => setState(() => _currentNavIndex = index),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard_rounded),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.inventory_2_rounded),
            label: 'Listings',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.receipt_long_rounded),
            label: 'Orders',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.payments_rounded),
            label: 'Finance',
          ),
        ],
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
    required this.dayCells,
    required this.weekdayLabels,
    required this.selectedDay,
    required this.onDayTap,
  });

  final List<_CalendarCellData?> dayCells;
  final List<String> weekdayLabels;
  final int selectedDay;
  final ValueChanged<int> onDayTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Container(
      decoration: BoxDecoration(
        color: TripwiseColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(24),
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
                'September 2024',
                style: textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(
                      Icons.chevron_left_rounded,
                      color: TripwiseColors.primary,
                    ),
                  ),
                  IconButton(
                    onPressed: () {},
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
            itemCount: dayCells.length,
            itemBuilder: (context, i) {
              final cell = dayCells[i];
              if (cell == null) return const SizedBox.shrink();
              return _CalendarCell(
                data: cell,
                isSelected: cell.day == selectedDay,
                onTap: cell.status == _DayStatus.closed
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
    required this.data,
    required this.isSelected,
    required this.onTap,
  });

  final _CalendarCellData data;
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
          color: TripwiseColors.primary.withOpacity(0.20),
          blurRadius: 12,
          offset: const Offset(0, 6),
        ),
      ];
    } else {
      switch (data.status) {
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
                '${data.day}',
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
                  data.price,
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

    if (data.status == _DayStatus.closed && !isSelected) {
      return Opacity(opacity: 0.5, child: tappable);
    }
    return tappable;
  }
}

class _DaySettingsCard extends StatelessWidget {
  const _DaySettingsCard({
    required this.isAvailable,
    required this.onAvailabilityChanged,
    required this.priceController,
  });

  final bool isAvailable;
  final ValueChanged<bool> onAvailabilityChanged;
  final TextEditingController priceController;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Container(
      decoration: BoxDecoration(
        color: TripwiseColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(24),
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
          Text(
            'DAY SETTINGS',
            style: textTheme.labelMedium?.copyWith(
              color: TripwiseColors.onSurfaceVariant,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.5,
            ),
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
                    'Open for bookings',
                    style: textTheme.bodySmall?.copyWith(
                      color: TripwiseColors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
              Switch(
                value: isAvailable,
                onChanged: onAvailabilityChanged,
                activeThumbColor: TripwiseColors.primary,
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'BASE PRICE',
            style: textTheme.labelSmall?.copyWith(
              color: TripwiseColors.onSurfaceVariant,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.0,
            ),
          ),
          const SizedBox(height: 6),
          TextField(
            controller: priceController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            style: textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w800,
            ),
            decoration: InputDecoration(
              prefixText: '\$ ',
              prefixStyle: const TextStyle(
                color: TripwiseColors.primary,
                fontWeight: FontWeight.w900,
                fontSize: 18,
              ),
              filled: true,
              fillColor: TripwiseColors.surfaceContainerLow,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
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
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: TripwiseColors.secondaryContainer,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
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
  const _DynamicPricingCard({required this.rules});

  final List<_PricingRule> rules;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Container(
      decoration: BoxDecoration(
        color: TripwiseColors.primary.withOpacity(0.05),
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
                      color: rule.valueColor,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 12),
          Center(
            child: TextButton(
              onPressed: () {},
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
  const _AnalyticsCard();

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
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
            value: '84%',
            valueColor: TripwiseColors.primary,
            extra: ClipRRect(
              borderRadius: BorderRadius.circular(999),
              child: SizedBox(
                height: 6,
                child: Row(
                  children: [
                    Expanded(
                      flex: 84,
                      child: Container(color: TripwiseColors.primary),
                    ),
                    Expanded(
                      flex: 16,
                      child:
                          Container(color: TripwiseColors.surfaceContainerHigh),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Divider(
            color: TripwiseColors.outlineVariant.withOpacity(0.5),
            height: 28,
          ),
          _StatBlock(
            label: 'REVENUE FORECAST',
            value: '\$12,450',
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
                  '12% from last month',
                  style: textTheme.labelSmall?.copyWith(
                    color: TripwiseColors.secondary,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
          Divider(
            color: TripwiseColors.outlineVariant.withOpacity(0.5),
            height: 28,
          ),
          _StatBlock(
            label: 'MARKET DEMAND',
            value: 'High',
            valueColor: TripwiseColors.secondary,
            extra: Text(
              'Demand for rentals in your area is trending high for the upcoming holiday season.',
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

class _CalendarCellData {
  const _CalendarCellData({
    required this.day,
    required this.price,
    required this.status,
  });

  final int day;
  final String price;
  final _DayStatus status;
}

class _PricingRule {
  const _PricingRule({
    required this.label,
    required this.value,
    required this.valueColor,
  });

  final String label;
  final String value;
  final Color valueColor;
}
