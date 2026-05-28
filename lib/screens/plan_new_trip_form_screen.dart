import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../constants/colors.dart';
import '../models/search_data.dart';
import '../services/search_api.dart';
import '../services/trips_api.dart';

class PlanNewTripFormScreen extends StatefulWidget {
  const PlanNewTripFormScreen({super.key});

  @override
  State<PlanNewTripFormScreen> createState() => _PlanNewTripFormScreenState();
}

class _PlanNewTripFormScreenState extends State<PlanNewTripFormScreen> {
  final TripsApi _api = TripsApi();
  final SearchApi _searchApi = SearchApi();
  final _tripNameController = TextEditingController();
  final _destinationController = TextEditingController();
  final _startDateController = TextEditingController();
  final _endDateController = TextEditingController();

  bool _inviteFriends = false;
  bool _isSubmitting = false;

  DateTime? _parseDate(String value) {
    final trimmed = value.trim();
    if (!RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(trimmed)) return null;
    final parsed = DateTime.tryParse(trimmed);
    if (parsed == null) return null;
    return DateTime(parsed.year, parsed.month, parsed.day);
  }

  String _formatDate(DateTime date) {
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '${date.year}-$month-$day';
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
      );
  }

  @override
  void dispose() {
    _tripNameController.dispose();
    _destinationController.dispose();
    _startDateController.dispose();
    _endDateController.dispose();
    super.dispose();
  }

  Future<void> _createTrip() async {
    if (_isSubmitting) return;
    final startDate = _parseDate(_startDateController.text);
    final endDate = _parseDate(_endDateController.text);
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    if (startDate == null || endDate == null) {
      _showError('Please choose travel dates.');
      return;
    }
    if (_destinationController.text.trim().isEmpty) {
      _showError('Please choose a destination.');
      return;
    }
    if (startDate.isBefore(today) || endDate.isBefore(today)) {
      _showError('Trip dates cannot be before today.');
      return;
    }
    if (endDate.isBefore(startDate)) {
      _showError('End date must be after start date.');
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final trip = await _api.createTrip(
        title: _tripNameController.text.trim(),
        destination: _destinationController.text.trim(),
        startDate: _startDateController.text.trim(),
        endDate: _endDateController.text.trim(),
      );
      if (!mounted) return;
      context.go(
        '/trip_planner_timeline?id=${Uri.encodeQueryComponent(trip.id)}',
      );
    } catch (error) {
      if (!mounted) return;
      _showError(error.toString());
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  Future<void> _chooseDates() async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final startDate = _parseDate(_startDateController.text);
    final endDate = _parseDate(_endDateController.text);

    final picked = await showDateRangePicker(
      context: context,
      firstDate: today,
      lastDate: DateTime(today.year + 3, 12, 31),
      initialDateRange: startDate != null && endDate != null
          ? DateTimeRange(start: startDate, end: endDate)
          : null,
      helpText: 'Select travel dates',
      saveText: 'Apply',
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: TripwiseColors.primary,
              secondary: TripwiseColors.secondaryContainer,
              onPrimary: TripwiseColors.onPrimary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked == null) return;
    setState(() {
      _startDateController.text = _formatDate(picked.start);
      _endDateController.text = _formatDate(picked.end);
    });
  }

  Future<void> _chooseDestination() async {
    final selected = await showModalBottomSheet<SearchDestinationItem>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => _DestinationPickerSheet(api: _searchApi),
    );

    if (selected == null) return;
    setState(() {
      _destinationController.text = selected.queryValue.isNotEmpty
          ? selected.queryValue
          : selected.name;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FF),
      appBar: _buildAppBar(context),
      body: SingleChildScrollView(
        padding: TripwiseInsets.screenWithBottomAction,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 768),
            child: Padding(
              padding: EdgeInsets.zero,
              child: Container(
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: const Color(0xFFBFC7D4).withOpacity(0.15),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF005F9F).withOpacity(0.03),
                      blurRadius: 40,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Trip Details',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF005F9F),
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 24),
                    _buildTextField(
                      label: 'Trip Name',
                      hint: 'e.g., Adventure in Tokyo',
                      icon: Icons.edit_note_rounded,
                      controller: _tripNameController,
                    ),
                    const SizedBox(height: 24),
                    _buildTextField(
                      label: 'Destination',
                      hint: 'Search a city, country...',
                      icon: Icons.location_on_rounded,
                      controller: _destinationController,
                      readOnly: true,
                      onTap: _chooseDestination,
                      suffixIcon: Icons.keyboard_arrow_down_rounded,
                    ),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Expanded(
                          child: _buildTextField(
                            label: 'Start Date',
                            hint: 'YYYY-MM-DD',
                            icon: Icons.calendar_today_rounded,
                            controller: _startDateController,
                            readOnly: true,
                            onTap: _chooseDates,
                          ),
                        ),
                        const SizedBox(width: 24),
                        Expanded(
                          child: _buildTextField(
                            label: 'End Date',
                            hint: 'YYYY-MM-DD',
                            icon: Icons.event_rounded,
                            controller: _endDateController,
                            readOnly: true,
                            onTap: _chooseDates,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),
                    _buildInviteFriendsToggle(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: _buildStickyBottomCTA(),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: const Color(0xFFF0F4FC),
      elevation: 0,
      scrolledUnderElevation: 10,
      shadowColor: const Color(0xFF005F9F).withOpacity(0.06),
      centerTitle: true,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_rounded, color: Color(0xFF005F9F)),
        onPressed: () => context.go('/trip_planner_dashboard'),
      ),
      title: const Text(
        'Plan Trip',
        style: TextStyle(
          color: Color(0xFF005F9F),
          fontSize: 20,
          fontWeight: FontWeight.w900,
        ),
      ),
      actions: [
        Container(
          margin: const EdgeInsets.only(right: 24),
          width: 40,
          height: 40,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: Color(0xFFE5E8F0),
            image: DecorationImage(
              image: NetworkImage(
                'https://lh3.googleusercontent.com/aida-public/AB6AXuBpZ1nmipSL8DAqMkExIj56K-RKYJFzmPYXVkJP_dXtAnrbFfy_-qD1kibK5hBEDawc95DuqXOFP5jGXm561076rNIvhnvtFGQ4ozqPBRuZB1jhSvgYpl5AZLkzeaCUAmeTO91O0_VcgsGUa7QH80QJT2iDwWD9oCOI07Q-IttToCER48Hxqw9_F78Tl2sWopN7n5sJiPt2C9Yblti5TMI-ZEhizdTMR9Ce61Nw8gkP9WtAivvPjwfprLy27mRStWIp68XlIWJSgbvl',
              ),
              fit: BoxFit.cover,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required String label,
    required String hint,
    required IconData icon,
    required TextEditingController controller,
    bool readOnly = false,
    VoidCallback? onTap,
    IconData? suffixIcon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Color(0xFF3F4752),
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFFF0F4FC),
            borderRadius: BorderRadius.circular(16),
          ),
          child: TextField(
            controller: controller,
            readOnly: readOnly,
            onTap: onTap,
            showCursor: !readOnly,
            style: const TextStyle(fontSize: 18, color: Color(0xFF181C22)),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(
                color: const Color(0xFF707884).withOpacity(0.6),
                fontSize: 18,
              ),
              prefixIcon: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Icon(
                  icon,
                  color: const Color(0xFF005F9F).withOpacity(0.6),
                ),
              ),
              suffixIcon: suffixIcon == null
                  ? null
                  : Icon(
                      suffixIcon,
                      color: const Color(0xFF005F9F).withOpacity(0.65),
                    ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                vertical: 16,
                horizontal: 16,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInviteFriendsToggle() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F4FC),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: const BoxDecoration(
                  color: Color(0xFFD1E4FF),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.group_add_rounded,
                  color: Color(0xFF005F9F),
                ),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'Invite Friends',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF181C22),
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Collaborate on this itinerary',
                    style: TextStyle(fontSize: 14, color: Color(0xFF3F4752)),
                  ),
                ],
              ),
            ],
          ),
          Switch(
            value: _inviteFriends,
            onChanged: (value) {
              setState(() {
                _inviteFriends = value;
              });
            },
            activeColor: Colors.white,
            activeTrackColor: const Color(0xFF005F9F),
            inactiveThumbColor: Colors.white,
            inactiveTrackColor: const Color(0xFFDFE2EB),
          ),
        ],
      ),
    );
  }

  Widget _buildStickyBottomCTA() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FF).withOpacity(0.9),
        border: Border(
          top: BorderSide(color: const Color(0xFFBFC7D4).withOpacity(0.1)),
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF005F9F).withOpacity(0.06),
            blurRadius: 40,
            offset: const Offset(0, -10),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 768),
                child: Row(
                  children: [
                    // Cancel button is hidden on mobile in HTML but let's show it on wider screens.
                    // To keep it simple, we'll just show it.
                    Expanded(
                      flex: 1,
                      child: TextButton(
                        onPressed: () => context.go('/trip_planner_dashboard'),
                        style: TripwiseButtonStyles.text(
                          radius: 12,
                          backgroundColor: TripwiseColors.surfaceContainerLow,
                          foregroundColor: TripwiseColors.primary,
                          padding: const EdgeInsets.symmetric(vertical: 20),
                        ),
                        child: const Text(
                          'Cancel',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      flex: 2,
                      child: ElevatedButton(
                        onPressed: _isSubmitting ? null : _createTrip,
                        style: TripwiseButtonStyles.primaryElevated(
                          radius: 12,
                          padding: const EdgeInsets.symmetric(vertical: 20),
                        ),
                        child: _isSubmitting
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: const [
                                  Text(
                                    'Create Trip',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(width: 8),
                                  Icon(Icons.arrow_forward_rounded),
                                ],
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DestinationPickerSheet extends StatefulWidget {
  const _DestinationPickerSheet({required this.api});

  final SearchApi api;

  @override
  State<_DestinationPickerSheet> createState() =>
      _DestinationPickerSheetState();
}

class _DestinationPickerSheetState extends State<_DestinationPickerSheet> {
  late Future<SearchData> _future;
  final _queryController = TextEditingController();
  Timer? _debounce;
  String _activeQuery = '';

  static final List<SearchDestinationItem> _fallbackDestinations = [
    SearchDestinationItem(
      id: 1,
      name: 'Tokyo',
      subtitle: 'Japan',
      queryValue: 'Tokyo, Japan',
    ),
    SearchDestinationItem(
      id: 2,
      name: 'Da Nang',
      subtitle: 'Vietnam',
      queryValue: 'Da Nang, Vietnam',
    ),
    SearchDestinationItem(
      id: 3,
      name: 'Ho Chi Minh City',
      subtitle: 'Vietnam',
      queryValue: 'Ho Chi Minh City, Vietnam',
    ),
    SearchDestinationItem(
      id: 4,
      name: 'Bali',
      subtitle: 'Indonesia',
      queryValue: 'Bali, Indonesia',
    ),
    SearchDestinationItem(
      id: 5,
      name: 'Singapore',
      subtitle: 'Singapore',
      queryValue: 'Singapore',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _future = _load(_activeQuery);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _queryController.dispose();
    super.dispose();
  }

  Future<SearchData> _load(String query) {
    return widget.api.fetchSearch(query: query, category: 'all');
  }

  void _search() {
    final query = _queryController.text.trim();
    setState(() {
      _activeQuery = query;
      _future = _load(query);
    });
  }

  void _onQueryChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 250), () {
      if (mounted) _search();
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          24,
          0,
          24,
          24 + MediaQuery.of(context).viewInsets.bottom,
        ),
        child: SizedBox(
          height: MediaQuery.of(context).size.height * 0.72,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Choose destination',
                style: TextStyle(
                  color: TripwiseColors.primary,
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _queryController,
                onChanged: _onQueryChanged,
                textInputAction: TextInputAction.search,
                onSubmitted: (_) => _search(),
                decoration: InputDecoration(
                  hintText: 'Search destinations...',
                  prefixIcon: const Icon(Icons.search_rounded),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.arrow_forward_rounded),
                    onPressed: _search,
                  ),
                  filled: true,
                  fillColor: TripwiseColors.surfaceContainerLow,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: FutureBuilder<SearchData>(
                  future: _future,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    final responseQuery = snapshot.data?.query.trim() ?? '';
                    if (responseQuery != _activeQuery) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    final destinations =
                        snapshot.data?.destinations ?? const [];
                    final isSearching = _activeQuery.isNotEmpty;
                    final items = destinations.isEmpty && !isSearching
                        ? _fallbackDestinations
                        : destinations;

                    if (items.isEmpty) {
                      return const Center(
                        child: Text(
                          'No matching destinations',
                          style: TextStyle(
                            color: TripwiseColors.onSurfaceVariant,
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      );
                    }

                    return ListView.separated(
                      itemCount: items.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 8),
                      itemBuilder: (context, index) {
                        final item = items[index];
                        return _DestinationChoiceTile(
                          item: item,
                          onTap: () => Navigator.of(context).pop(item),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DestinationChoiceTile extends StatelessWidget {
  const _DestinationChoiceTile({required this.item, required this.onTap});

  final SearchDestinationItem item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: TripwiseColors.surfaceContainerLow,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: const BoxDecoration(
                  color: TripwiseColors.primaryFixed,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.location_on_rounded,
                  color: TripwiseColors.primary,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: TripwiseColors.onSurface,
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    if (item.subtitle.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        item.subtitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: TripwiseColors.onSurfaceVariant,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right_rounded,
                color: TripwiseColors.primary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
