import 'package:flutter/material.dart';
import '../constants/colors.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  bool pushNotifications = true;
  bool emailNotifications = true;
  bool tripReminders = true;
  bool messages = true;
  bool promotions = false;
  bool bookingUpdates = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TripwiseColors.surface,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Notifications',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w900,
              ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Notification Channels
            _buildSectionHeader('Notification Channels', Icons.notifications_active),
            const SizedBox(height: 16),
            _buildSimpleToggle(
              title: 'Push Notifications',
              subtitle: 'Receive notifications on your device',
              value: pushNotifications,
              onChanged: (value) {
                setState(() => pushNotifications = value);
              },
            ),
            const SizedBox(height: 12),
            _buildSimpleToggle(
              title: 'Email Notifications',
              subtitle: 'Receive updates via email',
              value: emailNotifications,
              onChanged: (value) {
                setState(() => emailNotifications = value);
              },
            ),
            const SizedBox(height: 32),

            // Trip & Travel
            _buildSectionHeader('Trip & Travel', Icons.travel_explore),
            const SizedBox(height: 16),
            _buildSimpleToggle(
              title: 'Trip Reminders',
              subtitle: 'Reminders for upcoming trips',
              value: tripReminders,
              onChanged: (value) {
                setState(() => tripReminders = value);
              },
            ),
            const SizedBox(height: 12),
            _buildSimpleToggle(
              title: 'Booking Updates',
              subtitle: 'Updates about your bookings',
              value: bookingUpdates,
              onChanged: (value) {
                setState(() => bookingUpdates = value);
              },
            ),
            const SizedBox(height: 32),

            // Social & Messages
            _buildSectionHeader('Social & Messages', Icons.message),
            const SizedBox(height: 16),
            _buildSimpleToggle(
              title: 'Messages',
              subtitle: 'Notifications for new messages',
              value: messages,
              onChanged: (value) {
                setState(() => messages = value);
              },
            ),
            const SizedBox(height: 12),
            _buildSimpleToggle(
              title: 'Promotions & Offers',
              subtitle: 'Special deals and promotions',
              value: promotions,
              onChanged: (value) {
                setState(() => promotions = value);
              },
            ),
            const SizedBox(height: 48),

            // Save Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  _saveNotificationPreferences();
                },
                style: TripwiseButtonStyles.primaryElevated(
                  radius: 12,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                icon: const Icon(Icons.save),
                label: const Text(
                  'Save Preferences',
                  style: TextStyle(
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
    required Function(bool) onChanged,
  }) {
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
                    color: TripwiseColors.onSurface,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
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

  void _saveNotificationPreferences() {
    // TODO: Implement API call to save preferences
    // Example API structure:
    // POST /api/notifications/preferences
    // {
    //   "pushNotifications": pushNotifications,
    //   "emailNotifications": emailNotifications,
    //   "tripReminders": tripReminders,
    //   "messages": messages,
    //   "promotions": promotions,
    //   "bookingUpdates": bookingUpdates,
    // }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Preferences saved successfully'),
        backgroundColor: TripwiseColors.primary,
        duration: const Duration(seconds: 2),
      ),
    );
  }
}
