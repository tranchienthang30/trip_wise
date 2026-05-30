import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../constants/colors.dart';
import '../models/notification_feed.dart';
import '../services/notifications_api.dart';
import '../services/push_messaging_service.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final NotificationApi _api = NotificationApi();

  NotificationPreferences? _prefs;
  Object? _error;
  bool _loading = true;
  bool _saving = false;
  bool _pushBlocked = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final results = await Future.wait([
        _api.fetchPreferences(),
        PushMessagingService.isPushBlocked(),
      ]);
      if (!mounted) return;
      setState(() {
        _prefs = results[0] as NotificationPreferences;
        _pushBlocked = results[1] as bool;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e;
        _loading = false;
      });
    }
  }

  Future<void> _save() async {
    final prefs = _prefs;
    if (prefs == null || _saving) return;
    setState(() => _saving = true);
    try {
      final saved = await _api.savePreferences(prefs);
      if (!mounted) return;
      setState(() {
        _prefs = saved;
        _saving = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Preferences saved successfully'),
          backgroundColor: TripwiseColors.primary,
          duration: const Duration(seconds: 2),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
          backgroundColor: TripwiseColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TripwiseColors.surface,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
              return;
            }
            context.go('/home');
          },
        ),
        title: Text(
          'Notifications',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w900,
              ),
        ),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null || _prefs == null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "Couldn't load notification settings",
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: TripwiseColors.onSurfaceVariant,
                  ),
            ),
            const SizedBox(height: 12),
            FilledButton(
              onPressed: _load,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    final prefs = _prefs!;
    return RefreshIndicator(
      onRefresh: _load,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: TripwiseInsets.screen,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader(
              'Notification Channels',
              Icons.notifications_active_rounded,
            ),
            const SizedBox(height: 16),
            if (_pushBlocked) ...[
              _buildBlockedBanner(),
              const SizedBox(height: 12),
            ],
            _buildSimpleToggle(
              title: 'Push Notifications',
              subtitle: _pushBlocked
                  ? 'Blocked at the system level — see banner above'
                  : 'Receive notifications on your device',
              value: prefs.push,
              // Disable the toggle when the OS has revoked permission: flipping
              // it on in-app does nothing while the system says no.
              onChanged: _pushBlocked
                  ? null
                  : (v) => setState(() => _prefs = prefs.copyWith(push: v)),
            ),
            const SizedBox(height: 32),

            _buildSectionHeader('Trip & Travel', Icons.travel_explore_rounded),
            const SizedBox(height: 16),
            _buildSimpleToggle(
              title: 'Trip Reminders',
              subtitle: 'Reminders for upcoming trips',
              value: prefs.tripReminders,
              onChanged: (v) =>
                  setState(() => _prefs = prefs.copyWith(tripReminders: v)),
            ),
            const SizedBox(height: 12),
            _buildSimpleToggle(
              title: 'Booking Updates',
              subtitle: 'Updates about your bookings',
              value: prefs.bookingUpdates,
              onChanged: (v) =>
                  setState(() => _prefs = prefs.copyWith(bookingUpdates: v)),
            ),
            const SizedBox(height: 32),

            _buildSectionHeader('Social & Messages', Icons.message_rounded),
            const SizedBox(height: 16),
            _buildSimpleToggle(
              title: 'Messages',
              subtitle: 'Notifications for new messages',
              value: prefs.messages,
              onChanged: (v) =>
                  setState(() => _prefs = prefs.copyWith(messages: v)),
            ),
            const SizedBox(height: 12),
            _buildSimpleToggle(
              title: 'Promotions & Offers',
              subtitle: 'Special deals and promotions',
              value: prefs.promotions,
              onChanged: (v) =>
                  setState(() => _prefs = prefs.copyWith(promotions: v)),
            ),
            const SizedBox(height: 48),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _saving ? null : _save,
                style: TripwiseButtonStyles.primaryElevated(
                  radius: 12,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                icon: _saving
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: TripwiseColors.onPrimary,
                        ),
                      )
                    : const Icon(Icons.save_rounded),
                label: Text(
                  _saving ? 'Saving...' : 'Save Preferences',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Container(
          decoration: BoxDecoration(
            color: TripwiseColors.primary.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          padding: const EdgeInsets.all(8),
          child: Icon(
            icon,
            color: TripwiseColors.primary,
            size: 20,
          ),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
        ),
      ],
    );
  }

  Widget _buildSimpleToggle({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool>? onChanged,
  }) {
    final disabled = onChanged == null;
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: TripwiseColors.outlineVariant),
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: disabled
                        ? TripwiseColors.onSurfaceVariant
                        : TripwiseColors.onSurface,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 12,
                    color: TripwiseColors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  Widget _buildBlockedBanner() {
    return Container(
      decoration: BoxDecoration(
        color: TripwiseColors.errorContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.notifications_off_rounded,
            color: TripwiseColors.error,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Notifications blocked',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: TripwiseColors.onErrorContainer,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Your device has blocked Tripwise notifications. '
                  'Open system settings to allow them — the in-app toggles '
                  'won\'t take effect until you do.',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: TripwiseColors.onErrorContainer,
                        height: 1.35,
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
