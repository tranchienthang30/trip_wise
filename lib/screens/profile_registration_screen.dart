import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../constants/colors.dart';
import '../models/profile_data.dart';
import '../services/auth_session_store.dart';
import '../services/profile_api.dart';
import '../widgets/shared_taskbars.dart';
import '../widgets/shared_top_bars.dart';

class ProfileRegistrationScreen extends StatefulWidget {
  const ProfileRegistrationScreen({super.key});

  @override
  State<ProfileRegistrationScreen> createState() =>
      _ProfileRegistrationScreenState();
}

class _ProfileRegistrationScreenState extends State<ProfileRegistrationScreen> {
  final ProfileApi _api = ProfileApi();

  ProfileData? _data;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final data = await _api.fetchProfile();
      if (!mounted) return;
      setState(() {
        _data = data;
        _isLoading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _error = error.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final data = _data;

    return Scaffold(
      backgroundColor: TripwiseColors.surface,
      appBar: const PlannerAppBar(),
      body: RefreshIndicator(
        onRefresh: _loadProfile,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.only(bottom: 28),
            child: _isLoading && data == null
                ? const Padding(
                    padding: EdgeInsets.only(top: 140),
                    child: Center(child: CircularProgressIndicator()),
                  )
                : _error != null && data == null
                ? _buildErrorState()
                : Column(
                    children: [
                      const SizedBox(height: 20),
                      _buildHeader(data!),
                      const SizedBox(height: 24),
                      _buildProviderCard(data.provider),
                      const SizedBox(height: 24),
                      if (_error != null)
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          child: _InlineError(
                            message: _error!,
                            onRetry: _loadProfile,
                          ),
                        ),
                      if (_error != null) const SizedBox(height: 16),
                      _buildVerificationSection(data.verification),
                      const SizedBox(height: 24),
                      _buildMenuSection(),
                    ],
                  ),
          ),
        ),
      ),
      bottomNavigationBar: const PlannerTaskbar(
        currentTab: PlannerTaskbarTab.profile,
      ),
    );
  }

  Widget _buildHeader(ProfileData data) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          Stack(
            children: [
              Container(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      TripwiseColors.primary,
                      TripwiseColors.secondaryContainer,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                ),
                padding: const EdgeInsets.all(3),
                child: CircleAvatar(
                  radius: 60,
                  backgroundColor: TripwiseColors.surface,
                  backgroundImage:
                      data.user.image != null &&
                          data.user.image!.trim().isNotEmpty
                      ? NetworkImage(data.user.image!)
                      : null,
                  child:
                      data.user.image == null || data.user.image!.trim().isEmpty
                      ? const Icon(
                          Icons.person,
                          size: 54,
                          color: TripwiseColors.onSurfaceVariant,
                        )
                      : null,
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  decoration: const BoxDecoration(
                    color: TripwiseColors.secondaryContainer,
                    shape: BoxShape.circle,
                  ),
                  padding: const EdgeInsets.all(8),
                  child: const Icon(
                    Icons.edit,
                    color: TripwiseColors.onSecondary,
                    size: 18,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            data.user.name,
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 4),
          Text(
            '${data.user.tierLabel} • ${data.user.countriesVisited} countries',
            style: const TextStyle(
              fontSize: 14,
              color: TripwiseColors.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            data.user.email ?? data.user.phone ?? '',
            style: const TextStyle(
              fontSize: 12,
              color: TripwiseColors.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProviderCard(ProfileProvider provider) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        decoration: BoxDecoration(
          color: TripwiseColors.primaryContainer,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: TripwiseColors.primaryContainer.withOpacity(0.3),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        padding: const EdgeInsets.all(22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              provider.isRegistered ? 'Provider Access' : 'Become a Provider',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w900,
                color: TripwiseColors.onPrimaryContainer,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              provider.isRegistered
                  ? 'Your provider account is active. Manage your listings and performance from the dashboard.'
                  : 'Share your local expertise and earn while you travel. Join our global network of trip planners.',
              style: TextStyle(
                fontSize: 13,
                color: TripwiseColors.onPrimaryContainer.withOpacity(0.85),
                height: 1.4,
              ),
            ),
            const SizedBox(height: 14),
            ElevatedButton.icon(
              onPressed: () => context.push(provider.ctaRoute),
              style: TripwiseButtonStyles.primaryElevated(
                radius: 12,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
              icon: const Icon(Icons.arrow_forward),
              label: Text(provider.ctaLabel),
            ),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: () => context.go(provider.dashboardRoute),
              style: TripwiseButtonStyles.outlined(
                radius: 12,
                foregroundColor: TripwiseColors.onPrimaryContainer,
                borderColor: TripwiseColors.onPrimaryContainer.withOpacity(
                  0.25,
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
              icon: const Icon(Icons.storefront_rounded),
              label: const Text('Open Dashboard'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVerificationSection(ProfileVerification verification) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: TripwiseColors.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.description, color: TripwiseColors.primary),
                const SizedBox(width: 10),
                Text(
                  'Identity Verification',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
            const SizedBox(height: 14),
            _buildVerificationRow(
              title: 'Passport or ID',
              uploaded: verification.passportUploaded,
              note: verification.passportNote,
              onTap: () => _showUploadUnavailableMessage(context),
            ),
            const SizedBox(height: 10),
            _buildVerificationRow(
              title: 'Proof of Address',
              uploaded: verification.addressUploaded,
              note: verification.addressNote,
              onTap: () => _showUploadUnavailableMessage(context),
            ),
            if (verification.updatedAt != null) ...[
              const SizedBox(height: 10),
              Text(
                'Updated: ${verification.updatedAt}',
                style: const TextStyle(
                  fontSize: 11,
                  color: TripwiseColors.onSurfaceVariant,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildVerificationRow({
    required String title,
    required bool uploaded,
    required String note,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: TripwiseColors.surfaceContainerLow,
        ),
        child: Row(
          children: [
            Icon(
              uploaded ? Icons.verified : Icons.upload_file,
              color: uploaded ? TripwiseColors.primary : TripwiseColors.outline,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    note,
                    style: const TextStyle(
                      fontSize: 12,
                      color: TripwiseColors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: uploaded
                    ? TripwiseColors.primaryFixed
                    : TripwiseColors.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                uploaded ? 'Submitted' : 'Pending',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: uploaded
                      ? TripwiseColors.onPrimaryFixedVariant
                      : TripwiseColors.onSurfaceVariant,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuSection() {
    return Container(
      decoration: BoxDecoration(
        color: TripwiseColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(12),
      ),
      margin: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          _buildMenuItemButton(
            icon: Icons.security,
            label: 'Security & Privacy',
            onTap: () => context.push('/security_privacy'),
          ),
          Divider(height: 1, color: TripwiseColors.surfaceContainer),
          _buildMenuItemButton(
            icon: Icons.notifications_active,
            label: 'Notifications',
            onTap: () => context.push('/notifications'),
          ),
          Divider(height: 1, color: TripwiseColors.surfaceContainer),
          _buildMenuItemButton(
            icon: Icons.help,
            label: 'Help Center',
            onTap: () => context.push('/help_center'),
          ),
          Divider(height: 1, color: TripwiseColors.surfaceContainer),
          _buildMenuItemButton(
            icon: Icons.logout,
            label: 'Sign Out',
            isDestructive: true,
            onTap: _handleSignOut,
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItemButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Container(
                decoration: BoxDecoration(
                  color: isDestructive
                      ? TripwiseColors.error.withOpacity(0.1)
                      : TripwiseColors.primary.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                padding: const EdgeInsets.all(8),
                child: Icon(
                  icon,
                  size: 20,
                  color: isDestructive
                      ? TripwiseColors.error
                      : TripwiseColors.primary,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: isDestructive
                        ? TripwiseColors.error
                        : TripwiseColors.onSurface,
                  ),
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: isDestructive
                    ? TripwiseColors.error
                    : TripwiseColors.primary,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showUploadUnavailableMessage(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Document upload is not available yet.'),
        backgroundColor: TripwiseColors.primary,
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.only(top: 140, left: 24, right: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.cloud_off_rounded,
              size: 44,
              color: TripwiseColors.onSurfaceVariant,
            ),
            const SizedBox(height: 12),
            const Text(
              "Couldn't load profile",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 8),
            Text(
              _error!,
              textAlign: TextAlign.center,
              style: const TextStyle(color: TripwiseColors.onSurfaceVariant),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadProfile,
              style: TripwiseButtonStyles.primaryElevated(radius: 12),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleSignOut() async {
    final shouldSignOut = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Sign out'),
          content: const Text(
            'You will need to sign in again to access your trips and wallet.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: TripwiseButtonStyles.primaryElevated(radius: 12),
              child: const Text('Sign Out'),
            ),
          ],
        );
      },
    );

    if (shouldSignOut != true || !mounted) return;

    await AuthSessionStore.instance.logout();
    if (!mounted) return;
    context.go('/register');
  }
}

class _InlineError extends StatelessWidget {
  const _InlineError({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: TripwiseColors.errorContainer,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.warning_amber_rounded,
            color: TripwiseColors.onErrorContainer,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                color: TripwiseColors.onErrorContainer,
                fontSize: 12,
              ),
            ),
          ),
          TextButton(
            onPressed: onRetry,
            style: TripwiseButtonStyles.text(
              foregroundColor: TripwiseColors.onErrorContainer,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            ),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}
