import 'package:flutter/material.dart';
import '../constants/colors.dart';

class SecurityPrivacyScreen extends StatefulWidget {
  const SecurityPrivacyScreen({super.key});

  @override
  State<SecurityPrivacyScreen> createState() => _SecurityPrivacyScreenState();
}

class _SecurityPrivacyScreenState extends State<SecurityPrivacyScreen> {
  bool twoFactorEnabled = true;
  bool shareActivity = true;
  bool profileVisible = true;
  bool allowMessages = true;
  bool allowRecommendations = false;

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
          'Security & Privacy',
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
            // Security Section
            _buildSectionHeader('Security', Icons.lock),
            const SizedBox(height: 16),
            _buildSimpleToggle(
              title: 'Two-Factor Authentication',
              subtitle: 'Add an extra layer of security to your account',
              value: twoFactorEnabled,
              onChanged: (value) {
                setState(() => twoFactorEnabled = value);
              },
            ),
            const SizedBox(height: 32),

            // Privacy Section
            _buildSectionHeader('Privacy', Icons.privacy_tip),
            const SizedBox(height: 16),
            _buildSimpleToggle(
              title: 'Share Activity Status',
              subtitle: 'Let others see when you\'re active',
              value: shareActivity,
              onChanged: (value) {
                setState(() => shareActivity = value);
              },
            ),
            const SizedBox(height: 12),
            _buildSimpleToggle(
              title: 'Profile Visibility',
              subtitle: 'Make your profile visible to others',
              value: profileVisible,
              onChanged: (value) {
                setState(() => profileVisible = value);
              },
            ),
            const SizedBox(height: 12),
            _buildSimpleToggle(
              title: 'Allow Direct Messages',
              subtitle: 'Allow other users to send you messages',
              value: allowMessages,
              onChanged: (value) {
                setState(() => allowMessages = value);
              },
            ),
            const SizedBox(height: 32),

            // Preferences Section
            _buildSectionHeader('Preferences', Icons.tune),
            const SizedBox(height: 16),
            _buildSimpleToggle(
              title: 'Trip Recommendations',
              subtitle: 'Receive personalized travel recommendations',
              value: allowRecommendations,
              onChanged: (value) {
                setState(() => allowRecommendations = value);
              },
            ),
            const SizedBox(height: 48),

            // Save Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  _saveSecurityPreferences();
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

  void _saveSecurityPreferences() {
    // TODO: Implement API call to save preferences
    // Example API structure:
    // POST /api/security/preferences
    // {
    //   "twoFactorEnabled": twoFactorEnabled,
    //   "shareActivity": shareActivity,
    //   "profileVisible": profileVisible,
    //   "allowMessages": allowMessages,
    //   "allowRecommendations": allowRecommendations,
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
