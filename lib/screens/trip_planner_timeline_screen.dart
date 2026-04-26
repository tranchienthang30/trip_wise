import 'package:flutter/material.dart';

import '../constants/colors.dart';

class TripPlannerTimelineScreen extends StatefulWidget {
  const TripPlannerTimelineScreen({super.key});

  @override
  State<TripPlannerTimelineScreen> createState() =>
      _TripPlannerTimelineScreenState();
}

class _TripPlannerTimelineScreenState extends State<TripPlannerTimelineScreen> {
  static const String _avatarUrl =
      'https://lh3.googleusercontent.com/aida-public/AB6AXuBNDHz7WLrX5DaA4b_SLMoT874Y_7U3noQ5JcF1ZKyT_mA-rZnH9GGkHPUoe_o0Qhz-aIVXO3AIaMZIQbsivnPUgtws8papEoSNflDt1kO41kZq6noxaJFVmGEAVHceFRrCjPAyPkCaAaJcvx-SEdIHDIHv3WeiGcrpqFTH6qxd2Bos8Kct713_kKmRrmXCIcnZC6eFE5AMobVLYdnXu9m2VO55JMKqEQJZ7qNiq49uDEMH7-m79n3aPxnF-TdZafZm4J0B1j1pChI';

  static const String _heroImageUrl =
      'https://lh3.googleusercontent.com/aida-public/AB6AXuBHif9Rk6f4Hl0adoXhSpdKyfkhBI7WOpTENtNkXaJRiMNVEombs9e75e1e2MtRlVqo79JUew7Td40_i-7BFV-ui2-JwZBhvKls7m0A2nUVBxzJcOtgcxq4Vi2Wop7-KtGzabv3snhtQjVT29sK2ZG9h7zUTtXbOe1bUsXTeiCl0S82AwljwQ-mUGVon3ZepPkZXQuZn8Y9dpIhOHKDuu5nuICkCBiRUN4ODqcJpLZ8iAgyTlbYlRAqhAeZ6lnDBqRnrlVkiefIKeU';

  static const String _mapUrl =
      'https://lh3.googleusercontent.com/aida-public/AB6AXuDHnWJd78wFdBGgN9uLgYM0We3Y-gsoWuf_Evdus3JlIVxTmom1e4ejRvcdHTZj5fFEdANPNCWznwyMbhpXfKFxXmsS0DHofvIzqGMKzukEg3MqisQfRkXYgLWTZBDpCWtD3MPdB8zJgJiHM_kGgZGFPP4ekTWfVlGvRbud_lW8VK29QhVTqK7RtCT74Gq1HOaqk5J0enbRJ6FMrU9oOxp0iMuc_3HBKebJmVoRBk8KsrLmKxWiaARNz8BlyLoF_DxzZAHEQ1E7-e0';

  static const String _friend1Url =
      'https://lh3.googleusercontent.com/aida-public/AB6AXuBQWRg69kvKw8u2Me3cxcW-4ffx0lF5a1FlRJh_8Zcsju55YsLEY3VL8PhhBRRpl1Ia7lUbSRrzhZy_x2AOK3v7o1-KGsgKfYQR31pPzh9E8s4pKFuF39EDFVSWxyRBydiebHPG2WFi9KwPPIi55PzIR_84nBFISLsUQnrd8yVqPd0878VmbJ0WD8SfHVBX9SS0bOYcZcI939Ft2x1MJsNHHkn1OMH1_ecOiAk8nk8x7BDt90hZ38r2JAQB8KCKwVtEOh3KokoZZfU';

  static const String _friend2Url =
      'https://lh3.googleusercontent.com/aida-public/AB6AXuD6WpjW1yQs2fEbqkfFKHh4CphqMt36F-gNau9uGxMJLHMB916RS_jkLv0kAW4qT0lJSNIpyPfeEybinYD_FNtEmFcYyFYdcCdA_Vc6sqWQyANa7S_TJAwzUAkDAyKSmWdFfx48xxN2lN4UhoQm-FvCvV4pJ2iXR9o-EjpyKODJW09XYs1gohRJNVVQQxHSfIaUOwIw8ryCefLLTpedUJb2aaR9Mrc_3m5LgAxGJtTbai8wYSqMwkrvxhMCqGPN02dBylEFf5jcLVc';

  static const List<String> _dayLabels = [
    'Day 1',
    'Day 2',
    'Day 3',
    'Day 4',
    'Day 5',
  ];

  static final List<_TimelineItemData> _timelineItems = [
    const _TimelineItemData(
      time: '9:00 AM',
      title: 'Breakfast at Sea Circus',
      location: 'Seminyak, Bali',
      icon: Icons.restaurant_rounded,
      accentColor: TripwiseColors.primary,
    ),
    const _TimelineItemData(
      time: '11:00 AM',
      title: 'Surfing at Canggu',
      location: 'Batu Bolong Beach',
      icon: Icons.surfing_rounded,
      accentColor: TripwiseColors.secondary,
      friends: [_friend1Url, _friend2Url],
      extraFriends: 2,
    ),
    const _TimelineItemData(
      time: '2:00 PM',
      title: 'Spa Session',
      location: 'Bodyworks Spa',
      icon: Icons.spa_rounded,
      accentColor: TripwiseColors.tertiaryContainer,
    ),
  ];

  int _selectedDayIndex = 0;
  int _currentNavIndex = 2;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TripwiseColors.surface,
      appBar: AppBar(
        toolbarHeight: 68,
        titleSpacing: 20,
        title: Row(
          children: [
            const Icon(
              Icons.menu_rounded,
              color: TripwiseColors.onSurfaceVariant,
            ),
            const SizedBox(width: 12),
            Text(
              'Tripwise',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: TripwiseColors.primary,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.5,
                  ),
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 20),
            child: Container(
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: TripwiseColors.primaryContainer,
                  width: 2,
                ),
              ),
              child: const CircleAvatar(
                radius: 18,
                backgroundImage: NetworkImage(_avatarUrl),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 96),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _TripHero(
                heroImageUrl: _heroImageUrl,
                mapUrl: _mapUrl,
                label: 'ONGOING TRIP',
                title: 'Summer in Bali',
              ),
              const SizedBox(height: 28),
              _DayTabs(
                labels: _dayLabels,
                selectedIndex: _selectedDayIndex,
                onSelect: (i) => setState(() => _selectedDayIndex = i),
              ),
              const SizedBox(height: 28),
              _Timeline(items: _timelineItems),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: TripwiseColors.secondaryContainer,
        foregroundColor: Colors.white,
        elevation: 6,
        child: const Icon(Icons.add_rounded, size: 28),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _currentNavIndex,
        selectedItemColor: TripwiseColors.secondaryContainer,
        unselectedItemColor: TripwiseColors.outline,
        onTap: (index) => setState(() => _currentNavIndex = index),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_rounded),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.flight_rounded),
            label: 'My Trips',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.event_note_rounded),
            label: 'Planner',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_balance_wallet_rounded),
            label: 'Wallet',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_rounded),
            label: 'Profile',
          ),
        ],
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

  final String heroImageUrl;
  final String mapUrl;
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
          Image.network(heroImageUrl, fit: BoxFit.cover),
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                colors: [
                  Colors.black.withOpacity(0.55),
                  Colors.transparent,
                ],
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
              child: Image.network(mapUrl, fit: BoxFit.cover),
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
  const _Timeline({required this.items});

  final List<_TimelineItemData> items;

  @override
  Widget build(BuildContext context) {
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
            const _AddActivityButton(),
          ],
        ),
      ],
    );
  }
}

class _TimelineItem extends StatelessWidget {
  const _TimelineItem({required this.item});

  final _TimelineItemData item;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
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
                border: Border.all(color: item.accentColor, width: 4),
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
                        color: item.accentColor,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.5,
                      ),
                    ),
                    Icon(item.icon, color: item.accentColor, size: 22),
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
                    Text(
                      item.location,
                      style: textTheme.bodyMedium?.copyWith(
                        color: TripwiseColors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
                if (item.friends.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  _FriendsStack(
                    friends: item.friends,
                    extraFriends: item.extraFriends,
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
  const _AddActivityButton();

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.only(left: 56),
      child: InkWell(
        onTap: () => Navigator.pushNamed(context, '/add_activity'),
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

class _TimelineItemData {
  const _TimelineItemData({
    required this.time,
    required this.title,
    required this.location,
    required this.icon,
    required this.accentColor,
    this.friends = const [],
    this.extraFriends = 0,
  });

  final String time;
  final String title;
  final String location;
  final IconData icon;
  final Color accentColor;
  final List<String> friends;
  final int extraFriends;
}
