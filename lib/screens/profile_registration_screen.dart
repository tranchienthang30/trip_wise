import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';

import '../constants/colors.dart';
import '../models/profile_data.dart';
import '../services/auth_session_store.dart';
import '../services/profile_api.dart';
import '../utils/tripwise_image_provider.dart';
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
  final ImagePicker _imagePicker = ImagePicker();

  ProfileData? _data;
  bool _isLoading = true;
  bool _isUploadingAvatar = false;
  String? _error;
  bool _isVerificationBlinkOn = false;
  Timer? _verificationBlinkTimer;
  Timer? _verificationBlinkStopTimer;

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

  Future<void> _onUploadAvatar() async {
    if (_isUploadingAvatar) return;
    final messenger = ScaffoldMessenger.of(context);
    try {
      final file = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
        maxWidth: 1200,
      );
      if (file == null) return;
      final croppedFile = await _cropAvatarImage(file);
      if (croppedFile == null) return;

      setState(() => _isUploadingAvatar = true);
      final imageUrl = await _api.uploadAvatar(
        XFile(
          croppedFile.path,
          name: 'tripwise_avatar.jpg',
          mimeType: 'image/jpeg',
        ),
      );
      await AuthSessionStore.instance.updateUserImage(imageUrl);
      if (!mounted) return;
      await _loadProfile();
      messenger.showSnackBar(
        const SnackBar(
          content: Text('Avatar updated successfully.'),
          backgroundColor: TripwiseColors.primary,
        ),
      );
    } catch (error) {
      if (!mounted) return;
      final message = error is MissingPluginException
          ? 'Image picker is not ready yet. Please fully restart the app.'
          : error.toString();
      messenger.showSnackBar(
        SnackBar(content: Text(message), backgroundColor: TripwiseColors.error),
      );
    } finally {
      if (mounted) setState(() => _isUploadingAvatar = false);
    }
  }

  Future<CroppedFile?> _cropAvatarImage(XFile file) {
    return ImageCropper().cropImage(
      sourcePath: file.path,
      maxWidth: 900,
      maxHeight: 900,
      aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
      compressFormat: ImageCompressFormat.jpg,
      compressQuality: 90,
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: 'Crop avatar',
          toolbarColor: TripwiseColors.primary,
          toolbarWidgetColor: TripwiseColors.onPrimary,
          activeControlsWidgetColor: TripwiseColors.primary,
          cropStyle: CropStyle.circle,
          initAspectRatio: CropAspectRatioPreset.square,
          lockAspectRatio: true,
          showCropGrid: false,
          hideBottomControls: false,
          aspectRatioPresets: const [CropAspectRatioPreset.square],
        ),
        IOSUiSettings(
          title: 'Crop avatar',
          doneButtonTitle: 'Save',
          cancelButtonTitle: 'Cancel',
          cropStyle: CropStyle.circle,
          aspectRatioLockEnabled: true,
          aspectRatioPickerButtonHidden: true,
          resetAspectRatioEnabled: false,
          aspectRatioPresets: const [CropAspectRatioPreset.square],
        ),
      ],
    );
  }

  @override
  void dispose() {
    _verificationBlinkTimer?.cancel();
    _verificationBlinkStopTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final data = _data;
    final isProvider = AuthSessionStore.instance.isProvider;

    return Scaffold(
      backgroundColor: TripwiseColors.surface,
      appBar: isProvider ? const ProviderAppBar() : const PlannerAppBar(),
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
                      const SizedBox(height: 10),
                      _buildHeader(data!),
                      const SizedBox(height: 12),
                      _buildProviderCard(data.provider, data.verification),
                      const SizedBox(height: 16),
                      if (_error != null)
                        Padding(
                          padding: TripwiseInsets.horizontal,
                          child: _InlineError(
                            message: _error!,
                            onRetry: _loadProfile,
                          ),
                        ),
                      if (_error != null) const SizedBox(height: 12),
                      _buildVerificationSection(data.verification),
                      const SizedBox(height: 16),
                      _buildMenuSection(),
                    ],
                  ),
          ),
        ),
      ),
      bottomNavigationBar: isProvider
          ? const ProviderTaskbar()
          : const PlannerTaskbar(currentTab: PlannerTaskbarTab.profile),
    );
  }

  Widget _buildHeader(ProfileData data) {
    final avatarProvider = tripwiseImageProvider(data.user.image);
    return Padding(
      padding: TripwiseInsets.horizontal,
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
                  radius: 46,
                  backgroundColor: TripwiseColors.surface,
                  backgroundImage: avatarProvider,
                  child: avatarProvider == null
                      ? const Icon(
                          Icons.person_rounded,
                          size: 42,
                          color: TripwiseColors.onSurfaceVariant,
                        )
                      : null,
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: InkWell(
                  onTap: _isUploadingAvatar ? null : _onUploadAvatar,
                  borderRadius: BorderRadius.circular(99),
                  child: Container(
                    decoration: const BoxDecoration(
                      color: TripwiseColors.secondaryContainer,
                      shape: BoxShape.circle,
                    ),
                    padding: const EdgeInsets.all(7),
                    child: _isUploadingAvatar
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: TripwiseColors.onSecondary,
                            ),
                          )
                        : const Icon(
                            Icons.edit_rounded,
                            color: TripwiseColors.onSecondary,
                            size: 16,
                          ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            data.user.name,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w900,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            data.user.email ?? data.user.phone ?? '',
            style: const TextStyle(
              fontSize: 11,
              color: TripwiseColors.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  void _startVerificationAttentionBlink() {
    _verificationBlinkTimer?.cancel();
    _verificationBlinkStopTimer?.cancel();

    setState(() {
      _isVerificationBlinkOn = true;
    });

    _verificationBlinkTimer = Timer.periodic(
      const Duration(milliseconds: 320),
      (timer) {
        if (!mounted) return;
        setState(() {
          _isVerificationBlinkOn = !_isVerificationBlinkOn;
        });
      },
    );

    _verificationBlinkStopTimer = Timer(const Duration(seconds: 3), () {
      _verificationBlinkTimer?.cancel();
      if (!mounted) return;
      setState(() {
        _isVerificationBlinkOn = false;
      });
    });
  }

  Widget _buildProviderCard(
    ProfileProvider provider,
    ProfileVerification verification,
  ) {
    final isApplicationPending =
        !provider.isRegistered &&
        provider.ctaLabel.trim().toLowerCase() == 'application pending';
    final isStartRegistrationRoute =
        !provider.isRegistered &&
        provider.ctaRoute.trim() == '/provider_registration_form';

    return Padding(
      padding: TripwiseInsets.horizontal,
      child: Container(
        decoration: BoxDecoration(
          color: TripwiseColors.primaryContainer,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: TripwiseColors.primaryContainer.withValues(alpha: 0.16),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              provider.isRegistered ? 'Provider Access' : 'Become a Provider',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w900,
                color: TripwiseColors.onPrimaryContainer,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              provider.isRegistered
                  ? 'Your provider account is active. Manage your listings and performance from the dashboard.'
                  : 'Share your local expertise and earn while you travel. Join our global network of trip planners.',
              style: TextStyle(
                fontSize: 10.5,
                color: TripwiseColors.onPrimaryContainer.withValues(
                  alpha: 0.85,
                ),
                height: 1.2,
              ),
            ),
            const SizedBox(height: 8),
            ElevatedButton.icon(
              onPressed: isApplicationPending
                  ? null
                  : () {
                      if (isStartRegistrationRoute &&
                          !verification.isComplete) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Please complete Identity Verification before provider registration.',
                            ),
                            backgroundColor: TripwiseColors.primary,
                          ),
                        );
                        _startVerificationAttentionBlink();
                        return;
                      }
                      context.go(
                        provider.isRegistered
                            ? provider.dashboardRoute
                            : provider.ctaRoute,
                      );
                    },
              style: TripwiseButtonStyles.primaryElevated(
                radius: 10,
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 7,
                ),
                disabledBackgroundColor: TripwiseColors.primary.withValues(
                  alpha: 0.7,
                ),
                disabledForegroundColor: TripwiseColors.onPrimary,
              ),
              icon: Icon(
                provider.isRegistered
                    ? Icons.dashboard_rounded
                    : Icons.arrow_forward_rounded,
                size: 16,
              ),
              label: Text(
                provider.isRegistered
                    ? 'Open Provider Dashboard'
                    : provider.ctaLabel,
                style: const TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVerificationSection(ProfileVerification verification) {
    final uploadedCount = verification.uploadedCount.clamp(0, 2).toInt();
    final complete = uploadedCount == 2;
    final progressValue = uploadedCount / 2.0;
    final progressColor = complete
        ? TripwiseColors.primaryContainer
        : TripwiseColors.primary;

    return Padding(
      padding: TripwiseInsets.horizontal,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeInOut,
        decoration: BoxDecoration(
          color: _isVerificationBlinkOn
              ? TripwiseColors.primaryFixed.withValues(alpha: 0.65)
              : TripwiseColors.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: _isVerificationBlinkOn
                ? TripwiseColors.primary
                : Colors.transparent,
            width: 1.2,
          ),
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          child: InkWell(
            onTap: () async {
              await context.push('/profile_verification');
              if (!mounted) return;
              await _loadProfile();
            },
            borderRadius: BorderRadius.circular(10),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(7),
                        decoration: BoxDecoration(
                          color: TripwiseColors.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.description_rounded,
                          color: TripwiseColors.primary,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Identity Verification',
                              style: Theme.of(context).textTheme.titleMedium
                                  ?.copyWith(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w800,
                                  ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '$uploadedCount/2 documents submitted',
                              style: const TextStyle(
                                fontSize: 11,
                                color: TripwiseColors.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (complete) ...[
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: TripwiseColors.primaryFixed,
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            'Done',
                            style: TextStyle(
                              fontSize: 10.5,
                              fontWeight: FontWeight.w800,
                              color: TripwiseColors.onPrimaryFixedVariant,
                            ),
                          ),
                        ),
                        const SizedBox(width: 4),
                      ],
                      const Icon(
                        Icons.chevron_right_rounded,
                        color: TripwiseColors.primary,
                        size: 20,
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(999),
                    child: LinearProgressIndicator(
                      value: progressValue,
                      minHeight: 5,
                      backgroundColor: TripwiseColors.surfaceContainerHigh,
                      color: progressColor,
                    ),
                  ),
                ],
              ),
            ),
          ),
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
      margin: TripwiseInsets.horizontal,
      child: Column(
        children: [
          _buildMenuItemButton(
            icon: Icons.notifications_active_rounded,
            label: 'Notifications',
            onTap: () => context.push('/notifications'),
          ),
          Divider(height: 1, color: TripwiseColors.surfaceContainer),
          _buildMenuItemButton(
            icon: Icons.help_rounded,
            label: 'Help Center',
            onTap: () => context.push('/help_center'),
          ),
          Divider(height: 1, color: TripwiseColors.surfaceContainer),
          _buildMenuItemButton(
            icon: Icons.logout_rounded,
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
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          child: Row(
            children: [
              Container(
                decoration: BoxDecoration(
                  color: isDestructive
                      ? TripwiseColors.error.withValues(alpha: 0.1)
                      : TripwiseColors.primary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                padding: const EdgeInsets.all(7),
                child: Icon(
                  icon,
                  size: 18,
                  color: isDestructive
                      ? TripwiseColors.error
                      : TripwiseColors.primary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: isDestructive
                        ? TripwiseColors.error
                        : TripwiseColors.onSurface,
                  ),
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                size: 20,
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

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(TripwiseSpacing.xl, 140, TripwiseSpacing.xl, 0),
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
