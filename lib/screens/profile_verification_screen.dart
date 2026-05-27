import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';

import '../constants/colors.dart';
import '../models/profile_data.dart';
import '../services/auth_session_store.dart';
import '../services/profile_api.dart';
import '../utils/tripwise_image_provider.dart';
import '../widgets/shared_taskbars.dart';
import '../widgets/shared_top_bars.dart';

class ProfileVerificationScreen extends StatefulWidget {
  const ProfileVerificationScreen({super.key});

  @override
  State<ProfileVerificationScreen> createState() =>
      _ProfileVerificationScreenState();
}

class _ProfileVerificationScreenState extends State<ProfileVerificationScreen> {
  final ProfileApi _api = ProfileApi();
  final ImagePicker _imagePicker = ImagePicker();

  ProfileVerification? _verification;
  bool _isLoading = true;
  String? _error;
  ProfileVerificationDocumentType? _uploadingType;
  ProfileVerificationDocumentType? _deletingType;

  @override
  void initState() {
    super.initState();
    _loadVerification();
  }

  Future<void> _loadVerification() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final data = await _api.fetchProfile();
      if (!mounted) return;
      setState(() {
        _verification = data.verification;
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

  Future<void> _uploadDocument(ProfileVerificationDocumentType type) async {
    if (_uploadingType != null) return;

    // Show dialog to choose between camera and gallery
    final selectedSource = await showDialog<ImageSource>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Choose Image Source'),
        content: const Text('Would you like to take a photo or select from gallery?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, ImageSource.camera),
            child: const Text('Camera'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, ImageSource.gallery),
            child: const Text('Gallery'),
          ),
        ],
      ),
    );

    if (selectedSource == null) return;

    final messenger = ScaffoldMessenger.of(context);
    try {
      final file = await _imagePicker.pickImage(
        source: selectedSource,
        imageQuality: 80,
        maxWidth: 1400,
      );
      if (file == null) {
        return;
      }

      // Verify file exists before cropping
      final fileExists = await File(file.path).exists();
      if (!fileExists) {
        if (mounted) {
          messenger.showSnackBar(
            const SnackBar(
              content: Text('Image file not found. Please try again.'),
              backgroundColor: TripwiseColors.error,
            ),
          );
        }
        return;
      }

      final croppedFile = await _cropDocumentImage(file.path);
      if (croppedFile == null) return;

      final bytes = await croppedFile.readAsBytes();
      setState(() => _uploadingType = type);
      final verification = await _api.uploadVerificationDocument(
        documentType: type,
        fileName: '${type.pathSegment}_verification.jpg',
        mimeType: 'image/jpeg',
        bytes: bytes,
      );
      if (!mounted) return;
      setState(() => _verification = verification);
      messenger.showSnackBar(
        SnackBar(
          content: Text('${type.label} uploaded successfully.'),
          backgroundColor: TripwiseColors.primaryContainer,
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
      if (mounted) setState(() => _uploadingType = null);
    }
  }

  Future<CroppedFile?> _cropDocumentImage(String sourcePath) {
    return ImageCropper().cropImage(
      sourcePath: sourcePath,
      maxWidth: 1400,
      maxHeight: 1050,
      compressFormat: ImageCompressFormat.jpg,
      compressQuality: 80,
      uiSettings: [
        AndroidUiSettings(
          toolbarColor: Colors.transparent,
          toolbarWidgetColor: TripwiseColors.primary,
          statusBarLight: true,
          navBarLight: true,
          initAspectRatio: CropAspectRatioPreset.ratio4x3,
          lockAspectRatio: true,
          hideBottomControls: true,
          showCropGrid: true,
          cropGridColumnCount: 2,
          cropGridRowCount: 2,
          cropGridColor: TripwiseColors.primary,
          aspectRatioPresets: const [
            CropAspectRatioPreset.ratio4x3,
          ],
        ),
        IOSUiSettings(
          minimumAspectRatio: 4 / 3,
          aspectRatioPresets: const [
            CropAspectRatioPreset.ratio4x3,
          ],
          hidesNavigationBar: true,
        ),
        WebUiSettings(
          context: context,
          presentStyle: WebPresentStyle.dialog,
          size: const CropperSize(width: 520, height: 390),
        ),
      ],
    );
  }

  Future<void> _deleteDocument(ProfileVerificationDocumentType type) async {
    if (_uploadingType != null || _deletingType != null) return;
    final messenger = ScaffoldMessenger.of(context);
    try {
      setState(() => _deletingType = type);
      final verification = await _api.deleteVerificationDocument(
        documentType: type,
      );
      if (!mounted) return;
      setState(() => _verification = verification);
      messenger.showSnackBar(
        SnackBar(
          content: Text('${type.label} deleted.'),
          backgroundColor: TripwiseColors.primary,
        ),
      );
    } catch (error) {
      if (!mounted) return;
      messenger.showSnackBar(
        SnackBar(
          content: Text(error.toString()),
          backgroundColor: TripwiseColors.error,
        ),
      );
    } finally {
      if (mounted) setState(() => _deletingType = null);
    }
  }

  Future<void> _viewDocumentImage(String imageValue) async {
    final imageProvider = tripwiseImageProvider(imageValue);
    if (imageProvider == null) return;

    await showDialog<void>(
      context: context,
      builder: (context) {
        final maxDialogHeight = MediaQuery.of(context).size.height * 0.72;
        return Dialog(
          insetPadding: const EdgeInsets.all(16),
          child: ConstrainedBox(
            constraints: BoxConstraints(maxHeight: maxDialogHeight),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Expanded(
                  child: InteractiveViewer(
                    minScale: 0.8,
                    maxScale: 3.5,
                    child: Image(
                      image: imageProvider,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) =>
                          const Center(
                            child: Icon(
                              Icons.broken_image_rounded,
                              size: 36,
                              color: TripwiseColors.outline,
                            ),
                          ),
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Close'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final verification = _verification;
    final isProvider = AuthSessionStore.instance.isProvider;

    return Scaffold(
      backgroundColor: TripwiseColors.surface,
      appBar: isProvider
          ? ProviderAppBar(
              backRoute: '/profile_registration',
              titleText: 'IDV',
              onBack: () => Navigator.of(context).pop(),
            )
          : PlannerAppBar(
              backRoute: '/profile_registration',
              titleText: 'IDV',
              onBack: () => Navigator.of(context).pop(),
            ),
      body: RefreshIndicator(
        onRefresh: _loadVerification,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: TripwiseInsets.screen,
          child: _isLoading && verification == null
              ? const Padding(
                  padding: EdgeInsets.only(top: 140),
                  child: Center(child: CircularProgressIndicator()),
                )
              : _error != null && verification == null
              ? _buildErrorState()
              : LayoutBuilder(
                  builder: (context, constraints) {
                    final isCompact = constraints.maxWidth < 760;
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (_error != null) ...[
                          _InlineVerificationError(
                            message: _error!,
                            onRetry: _loadVerification,
                          ),
                          const SizedBox(height: 12),
                        ],
                        _buildDocumentTile(
                          type: ProfileVerificationDocumentType.passport,
                          title: 'Passport or ID',
                          subtitle: 'Government document',
                          note: verification!.passportNote,
                          uploaded: verification.passportUploaded,
                          imageUrl: verification.passportImageUrl,
                          compact: isCompact,
                        ),
                        const SizedBox(height: 10),
                        _buildDocumentTile(
                          type: ProfileVerificationDocumentType.address,
                          title: 'Proof of Address',
                          subtitle: 'Residence confirmation',
                          note: verification.addressNote,
                          uploaded: verification.addressUploaded,
                          imageUrl: verification.addressImageUrl,
                          compact: isCompact,
                        ),
                      ],
                    );
                  },
                ),
        ),
      ),
      bottomNavigationBar: isProvider
          ? const ProviderTaskbar()
          : const PlannerTaskbar(currentTab: PlannerTaskbarTab.profile),
    );
  }

  Widget _buildDocumentTile({
    required ProfileVerificationDocumentType type,
    required String title,
    required String subtitle,
    required String note,
    required bool uploaded,
    required String? imageUrl,
    required bool compact,
  }) {
    final isUploading = _uploadingType == type;
    final isDeleting = _deletingType == type;
    final canEdit = _uploadingType == null && _deletingType == null;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(compact ? 8 : 10),
      decoration: BoxDecoration(
        color: TripwiseColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: TripwiseColors.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: TripwiseColors.onSurface,
                      ),
                    ),
                    const SizedBox(height: 1),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: compact ? 10 : 10.5,
                        color: TripwiseColors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              _StatusChip(uploaded: uploaded),
            ],
          ),
          SizedBox(height: compact ? 6 : 8),
          _buildInteractiveImageArea(
            type: type,
            imageUrl: imageUrl,
            uploaded: uploaded,
            compact: compact,
            canEdit: canEdit,
            isUploading: isUploading,
            isDeleting: isDeleting,
          ),
          SizedBox(height: compact ? 5 : 6),
          Text(
            note,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: compact ? 10 : 10.5,
              color: TripwiseColors.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInteractiveImageArea({
    required ProfileVerificationDocumentType type,
    required String? imageUrl,
    required bool uploaded,
    required bool compact,
    required bool canEdit,
    required bool isUploading,
    required bool isDeleting,
  }) {
    final normalizedImageUrl = imageUrl?.trim();
    final hasImage = normalizedImageUrl != null && normalizedImageUrl.isNotEmpty;
    return Stack(
      children: [
        InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: !canEdit
              ? null
              : hasImage
              ? () => _viewDocumentImage(normalizedImageUrl)
              : () => _uploadDocument(type),
          child: _buildImagePreview(imageUrl, compact: compact),
        ),
        if (hasImage)
          Positioned(
            top: 6,
            right: 6,
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(999),
                onTap: uploaded && canEdit ? () => _deleteDocument(type) : null,
                child: Container(
                  width: compact ? 24 : 26,
                  height: compact ? 24 : 26,
                  decoration: const BoxDecoration(
                    color: TripwiseColors.error,
                    shape: BoxShape.circle,
                  ),
                  child: isDeleting
                      ? const Padding(
                          padding: EdgeInsets.all(5),
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: TripwiseColors.onError,
                          ),
                        )
                      : const Icon(
                          Icons.close_rounded,
                          size: 16,
                          color: TripwiseColors.onError,
                        ),
                ),
              ),
            ),
          ),
        if (isUploading)
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Center(
                child: CircularProgressIndicator(
                  color: TripwiseColors.onPrimary,
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildImagePreview(String? imageUrl, {required bool compact}) {
    if (imageUrl == null || imageUrl.trim().isEmpty) {
      return AspectRatio(
        aspectRatio: compact ? 1.7 : 1.9,
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: TripwiseColors.surfaceContainerLow,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: TripwiseColors.outlineVariant),
          ),
          child: const Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.add_a_photo_rounded,
                  size: 30,
                  color: TripwiseColors.outline,
                ),
                SizedBox(height: 6),
                Text(
                  'Tap to upload',
                  style: TextStyle(
                    fontSize: 11,
                    color: TripwiseColors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final imageProvider = tripwiseImageProvider(imageUrl);
    if (imageProvider == null) {
      return AspectRatio(
        aspectRatio: compact ? 1.7 : 1.9,
        child: Container(
          color: TripwiseColors.surfaceContainerLow,
          child: const Center(
            child: Icon(
              Icons.broken_image_rounded,
              size: 34,
              color: TripwiseColors.outline,
            ),
          ),
        ),
      );
    }

    return AspectRatio(
      aspectRatio: compact ? 1.7 : 1.9,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Image(
          image: imageProvider,
          fit: BoxFit.cover,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return Container(
              color: TripwiseColors.surfaceContainerLow,
              child: const Center(child: CircularProgressIndicator()),
            );
          },
          errorBuilder: (context, error, stackTrace) {
            return Container(
              color: TripwiseColors.surfaceContainerLow,
              child: const Center(
                child: Icon(
                  Icons.broken_image_rounded,
                  size: 34,
                  color: TripwiseColors.outline,
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildErrorState() {
    return Padding(
      padding: const EdgeInsets.only(top: 130),
      child: Center(
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
              "Couldn't load verification",
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
              onPressed: _loadVerification,
              style: TripwiseButtonStyles.primaryElevated(radius: 12),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.uploaded});

  final bool uploaded;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: uploaded
            ? TripwiseColors.primaryFixed
            : TripwiseColors.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        uploaded ? 'Submitted' : 'Pending',
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w800,
          color: uploaded
              ? TripwiseColors.onPrimaryFixedVariant
              : TripwiseColors.onSurfaceVariant,
        ),
      ),
    );
  }
}

class _InlineVerificationError extends StatelessWidget {
  const _InlineVerificationError({
    required this.message,
    required this.onRetry,
  });

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
