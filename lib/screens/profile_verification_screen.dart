import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';

import '../constants/colors.dart';
import '../models/profile_data.dart';
import '../services/profile_api.dart';
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

    final messenger = ScaffoldMessenger.of(context);
    try {
      final file = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
        maxWidth: 1400,
      );
      if (file == null) return;

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
          backgroundColor: TripwiseColors.primary,
        ),
      );
    } catch (error) {
      if (!mounted) return;
      final message = error is MissingPluginException
          ? 'Image picker is not ready yet. Please fully restart the app.'
          : error.toString();
      messenger.showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: TripwiseColors.error,
        ),
      );
    } finally {
      if (mounted) setState(() => _uploadingType = null);
    }
  }

  Future<CroppedFile?> _cropDocumentImage(String sourcePath) {
    return ImageCropper().cropImage(
      sourcePath: sourcePath,
      maxWidth: 1400,
      maxHeight: 1400,
      compressFormat: ImageCompressFormat.jpg,
      compressQuality: 80,
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: 'Crop document',
          toolbarColor: TripwiseColors.primary,
          toolbarWidgetColor: TripwiseColors.onPrimary,
          initAspectRatio: CropAspectRatioPreset.original,
          lockAspectRatio: false,
          aspectRatioPresets: const [
            CropAspectRatioPreset.original,
            CropAspectRatioPreset.ratio4x3,
            CropAspectRatioPreset.square,
          ],
        ),
        IOSUiSettings(
          title: 'Crop document',
          doneButtonTitle: 'Done',
          cancelButtonTitle: 'Cancel',
          aspectRatioPresets: const [
            CropAspectRatioPreset.original,
            CropAspectRatioPreset.ratio4x3,
            CropAspectRatioPreset.square,
          ],
        ),
        WebUiSettings(
          context: context,
          presentStyle: WebPresentStyle.dialog,
          size: const CropperSize(width: 520, height: 520),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final verification = _verification;

    return Scaffold(
      backgroundColor: TripwiseColors.surface,
      appBar: const PlannerAppBar(backRoute: '/profile_registration'),
      body: RefreshIndicator(
        onRefresh: _loadVerification,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(24, 18, 24, 28),
          child: _isLoading && verification == null
              ? const Padding(
                  padding: EdgeInsets.only(top: 140),
                  child: Center(child: CircularProgressIndicator()),
                )
              : _error != null && verification == null
              ? _buildErrorState()
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSummaryCard(verification!),
                    const SizedBox(height: 18),
                    if (_error != null) ...[
                      _InlineVerificationError(
                        message: _error!,
                        onRetry: _loadVerification,
                      ),
                      const SizedBox(height: 18),
                    ],
                    _buildDocumentCard(
                      type: ProfileVerificationDocumentType.passport,
                      title: 'Passport or ID',
                      subtitle: 'Government document',
                      note: verification.passportNote,
                      uploaded: verification.passportUploaded,
                      imageUrl: verification.passportImageUrl,
                    ),
                    const SizedBox(height: 14),
                    _buildDocumentCard(
                      type: ProfileVerificationDocumentType.address,
                      title: 'Proof of Address',
                      subtitle: 'Residence confirmation',
                      note: verification.addressNote,
                      uploaded: verification.addressUploaded,
                      imageUrl: verification.addressImageUrl,
                    ),
                  ],
                ),
        ),
      ),
      bottomNavigationBar: const PlannerTaskbar(
        currentTab: PlannerTaskbarTab.profile,
      ),
    );
  }

  Widget _buildSummaryCard(ProfileVerification verification) {
    final complete = verification.isComplete;
    final progress = verification.uploadedCount / 2;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: TripwiseColors.primaryContainer,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: TripwiseColors.primaryContainer.withOpacity(0.24),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.14),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.verified_user_rounded,
                  color: TripwiseColors.onPrimaryContainer,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Identity Verification',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        color: TripwiseColors.onPrimaryContainer,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      complete
                          ? 'Ready for review'
                          : '${verification.uploadedCount} of 2 documents submitted',
                      style: TextStyle(
                        fontSize: 13,
                        color: TripwiseColors.onPrimaryContainer.withOpacity(
                          0.82,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: Colors.white.withOpacity(0.22),
              color: complete
                  ? TripwiseColors.secondaryContainer
                  : TripwiseColors.primaryFixedDim,
            ),
          ),
          if (verification.updatedAt != null) ...[
            const SizedBox(height: 12),
            Text(
              'Updated: ${verification.updatedAt}',
              style: TextStyle(
                fontSize: 11,
                color: TripwiseColors.onPrimaryContainer.withOpacity(0.78),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDocumentCard({
    required ProfileVerificationDocumentType type,
    required String title,
    required String subtitle,
    required String note,
    required bool uploaded,
    required String? imageUrl,
  }) {
    final isUploading = _uploadingType == type;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: TripwiseColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: TripwiseColors.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: uploaded
                      ? TripwiseColors.primaryFixed
                      : TripwiseColors.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  uploaded
                      ? Icons.check_circle_rounded
                      : Icons.upload_file_rounded,
                  color: uploaded
                      ? TripwiseColors.onPrimaryFixedVariant
                      : TripwiseColors.outline,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: TripwiseColors.onSurface,
                      ),
                    ),
                    const SizedBox(height: 2),
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
              _StatusChip(uploaded: uploaded),
            ],
          ),
          const SizedBox(height: 14),
          _buildImagePreview(imageUrl),
          const SizedBox(height: 12),
          Text(
            note,
            style: const TextStyle(
              fontSize: 12,
              color: TripwiseColors.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _uploadingType == null
                  ? () => _uploadDocument(type)
                  : null,
              style: TripwiseButtonStyles.primaryElevated(
                radius: 12,
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 13),
              ),
              icon: isUploading
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: TripwiseColors.onPrimary,
                      ),
                    )
                  : Icon(uploaded ? Icons.refresh_rounded : Icons.add_a_photo),
              label: Text(
                isUploading
                    ? 'Uploading...'
                    : uploaded
                    ? 'Replace image'
                    : 'Upload image',
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImagePreview(String? imageUrl) {
    if (imageUrl == null || imageUrl.trim().isEmpty) {
      return Container(
        height: 116,
        width: double.infinity,
        decoration: BoxDecoration(
          color: TripwiseColors.surfaceContainerLow,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: TripwiseColors.outlineVariant),
        ),
        child: const Center(
          child: Icon(
            Icons.image_outlined,
            size: 34,
            color: TripwiseColors.outline,
          ),
        ),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Image.network(
        imageUrl,
        height: 156,
        width: double.infinity,
        fit: BoxFit.cover,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Container(
            height: 156,
            color: TripwiseColors.surfaceContainerLow,
            child: const Center(child: CircularProgressIndicator()),
          );
        },
        errorBuilder: (context, error, stackTrace) {
          return Container(
            height: 156,
            color: TripwiseColors.surfaceContainerLow,
            child: const Center(
              child: Icon(
                Icons.broken_image_outlined,
                size: 34,
                color: TripwiseColors.outline,
              ),
            ),
          );
        },
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
