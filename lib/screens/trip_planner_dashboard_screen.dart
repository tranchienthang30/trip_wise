import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../constants/colors.dart';
import '../models/trip_timeline.dart';
import '../services/trips_api.dart';
import '../widgets/shared_taskbars.dart';
import '../widgets/shared_top_bars.dart';

const List<String> _months = [
  'Jan',
  'Feb',
  'Mar',
  'Apr',
  'May',
  'Jun',
  'Jul',
  'Aug',
  'Sep',
  'Oct',
  'Nov',
  'Dec',
];

String _fmtDate(String? iso) {
  if (iso == null || iso.length < 10) return '';
  final y = int.tryParse(iso.substring(0, 4));
  final m = int.tryParse(iso.substring(5, 7));
  final d = int.tryParse(iso.substring(8, 10));
  if (y == null || m == null || d == null || m < 1 || m > 12) return '';
  return '${_months[m - 1]} $d, $y';
}

String _dateRange(String? start, String? end) {
  final s = _fmtDate(start);
  final e = _fmtDate(end);
  if (s.isEmpty && e.isEmpty) return 'Dates to be planned';
  if (s.isEmpty) return e;
  if (e.isEmpty) return s;
  return '$s  →  $e';
}

({String label, Color color, Color bg}) _statusChrome(String status) {
  switch (status.toUpperCase()) {
    case 'ONGOING':
      return (
        label: 'ONGOING',
        color: const Color(0xFF005F9F),
        bg: Colors.white.withOpacity(0.9),
      );
    case 'COMPLETED':
      return (
        label: 'COMPLETED',
        color: const Color(0xFF64748B),
        bg: const Color(0xFFF1F5F9).withOpacity(0.9),
      );
    default:
      return (
        label: 'UPCOMING',
        color: const Color(0xFF005F9F),
        bg: Colors.white.withOpacity(0.9),
      );
  }
}

/// Up to 3 unique companion avatars across the whole trip, + overflow count.
({List<String> avatars, int extra}) _tripCompanions(Trip trip) {
  final seen = <String>{};
  final urls = <String>[];
  for (final day in trip.days) {
    for (final item in day.items) {
      for (final c in item.companions) {
        final img = c.image;
        if (img != null && img.isNotEmpty && seen.add(img)) urls.add(img);
      }
    }
  }
  if (urls.length <= 3) return (avatars: urls, extra: 0);
  return (avatars: urls.sublist(0, 3), extra: urls.length - 3);
}

class TripPlannerDashboardScreen extends StatefulWidget {
  const TripPlannerDashboardScreen({super.key});

  @override
  State<TripPlannerDashboardScreen> createState() =>
      _TripPlannerDashboardScreenState();
}

class _TripPlannerDashboardScreenState
    extends State<TripPlannerDashboardScreen> {
  final TripsApi _api = TripsApi();

  TripsResponse? _data;
  Object? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _error = null;
      _data = null;
    });
    try {
      final data = await _api.fetchTrips();
      if (!mounted) return;
      setState(() => _data = data);
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = e);
    }
  }

  Future<void> _openTimeline(String tripId) async {
    await context.push(
      '/trip_planner_timeline?id=${Uri.encodeQueryComponent(tripId)}',
    );
    if (!mounted) return;
    await _load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FF),
      appBar: const PlannerAppBar(),
      body: RefreshIndicator(
        onRefresh: _load,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'My Plans',
                style: TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF181C22),
                  letterSpacing: -1.0,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Your upcoming journeys and past adventures curated in one place.',
                style: TextStyle(fontSize: 18, color: Color(0xFF3F4752)),
              ),
              const SizedBox(height: 24),
              _buildSearchBar(context),
              const SizedBox(height: 32),
              _buildContent(context),
              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'create_trip_fab',
        onPressed: () => context.push('/plan_new_trip_form'),
        icon: const Icon(Icons.add, size: 28),
        label: const Text(
          'Create New Trip',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      bottomNavigationBar: const PlannerTaskbar(
        currentTab: PlannerTaskbarTab.planner,
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFE5E8F0),
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: TextField(
        readOnly: true,
        onTap: () => context.push('/add_location_search'),
        decoration: const InputDecoration(
          icon: Icon(Icons.search, color: Color(0xFF3F4752)),
          hintText: 'Search hotels, flights, or attractions',
          hintStyle: TextStyle(color: Color(0xFFBFC7D4)),
          border: InputBorder.none,
          suffixIcon: Icon(Icons.mic, color: Color(0xFF3F4752)),
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    if (_data == null && _error == null) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 80),
        child: Center(child: CircularProgressIndicator()),
      );
    }
    if (_data == null) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 60),
        child: Column(
          children: [
            const Icon(
              Icons.cloud_off_rounded,
              size: 48,
              color: Color(0xFF64748B),
            ),
            const SizedBox(height: 12),
            const Text(
              "Couldn't load your plans",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF181C22),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              _error?.toString() ?? 'Unknown error',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Color(0xFF3F4752)),
            ),
            const SizedBox(height: 16),
            FilledButton(onPressed: _load, child: const Text('Try again')),
          ],
        ),
      );
    }

    final trips = _data!.trips;
    return Column(
      children: [
        for (final t in trips) ...[
          _buildTripCard(context, t),
          const SizedBox(height: 24),
        ],
        _buildPlanNewCard(context),
      ],
    );
  }

  Widget _buildTripCard(BuildContext context, Trip trip) {
    final chrome = _statusChrome(trip.status);
    final comp = _tripCompanions(trip);

    return InkWell(
      onTap: () => _openTimeline(trip.id),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                _coverImage(trip.coverImage),
                Positioned(
                  top: 16,
                  left: 16,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: chrome.bg,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      chrome.label,
                      style: TextStyle(
                        color: chrome.color,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    trip.title,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF181C22),
                    ),
                  ),
                  if (trip.destination != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      trip.destination!,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF3F4752),
                      ),
                    ),
                  ],
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(
                        Icons.calendar_today,
                        size: 16,
                        color: Color(0xFF3F4752),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _dateRange(trip.startDate, trip.endDate),
                        style: const TextStyle(
                          fontSize: 14,
                          color: Color(0xFF3F4752),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          for (final url in comp.avatars)
                            Align(
                              widthFactor: 0.7,
                              child: CircleAvatar(
                                radius: 16,
                                backgroundColor: Colors.white,
                                child: CircleAvatar(
                                  radius: 14,
                                  backgroundImage: NetworkImage(url),
                                ),
                              ),
                            ),
                          if (comp.extra > 0)
                            Align(
                              widthFactor: 0.7,
                              child: CircleAvatar(
                                radius: 16,
                                backgroundColor: Colors.white,
                                child: CircleAvatar(
                                  radius: 14,
                                  backgroundColor: const Color(0xFF9DCAFF),
                                  child: Text(
                                    '+${comp.extra}',
                                    style: const TextStyle(
                                      color: Color(0xFF00497C),
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                      ElevatedButton(
                        style: TripwiseButtonStyles.primaryElevated(
                          radius: 12,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                        ),
                        onPressed: () => _openTimeline(trip.id),
                        child: const Text(
                          'View Timeline',
                          style: TextStyle(fontWeight: FontWeight.bold),
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
    );
  }

  Widget _coverImage(String? url) {
    const h = 200.0;
    if (url == null || url.isEmpty) {
      return Container(height: h, color: Colors.grey[200]);
    }
    return Image.network(
      url,
      height: h,
      width: double.infinity,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) =>
          Container(height: h, color: Colors.grey[200]),
      loadingBuilder: (context, child, progress) {
        if (progress == null) return child;
        return Container(
          height: h,
          color: Colors.grey[200],
          child: const Center(
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        );
      },
    );
  }

  Widget _buildPlanNewCard(BuildContext context) {
    return InkWell(
      onTap: () => context.push('/plan_new_trip_form'),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(48),
        decoration: BoxDecoration(
          color: const Color(0xFFF0F4FC).withOpacity(0.3),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFBFC7D4), width: 2),
        ),
        child: Column(
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: const BoxDecoration(
                color: Color(0xFFD1E4FF),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.add_location_alt,
                color: Color(0xFF005F9F),
                size: 32,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Plan a New Adventure',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF181C22),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Ready for your next getaway? Start mapping out your journey.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Color(0xFF3F4752)),
            ),
          ],
        ),
      ),
    );
  }
}
