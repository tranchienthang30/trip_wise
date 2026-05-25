import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';

import '../constants/colors.dart';
import '../services/auth_session_store.dart';
import '../services/provider_application_api.dart';
import '../widgets/shared_top_bars.dart';

class ProviderRegistrationFormScreen extends StatefulWidget {
  const ProviderRegistrationFormScreen({super.key});

  @override
  State<ProviderRegistrationFormScreen> createState() =>
      _ProviderRegistrationFormScreenState();
}

class _ProviderRegistrationFormScreenState
    extends State<ProviderRegistrationFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final ProviderApplicationApi _api = ProviderApplicationApi();
  final ImagePicker _imagePicker = ImagePicker();
  final _fullNameController = TextEditingController();
  final _bioController = TextEditingController();
  final _experienceController = TextEditingController();
  final _phoneController = TextEditingController();

  String? _selectedSpecialty;
  int _currentStep = 1;
  Uint8List? _licenseBytes;
  String? _licenseMimeType;
  String? _licenseFileName;
  bool _isSubmitting = false;
  bool _isUploadingLicense = false;
  String? _submitError;
  final List<String> _specialties = [
    'Adventure Tours',
    'Cultural Experiences',
    'Food & Wine',
    'Beach Resorts',
    'Mountain Hiking',
    'City Tours',
    'Photography',
    'Wellness & Spa',
  ];

  @override
  void initState() {
    super.initState();
    final user = AuthSessionStore.instance.session?.user;
    _fullNameController.text = user?.fullName ?? '';
    _phoneController.text = user?.phone ?? '';
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _bioController.dispose();
    _experienceController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TripwiseColors.surface,
      appBar: const PlannerAppBar(backRoute: '/profile_registration'),
      body: SingleChildScrollView(
        child: Padding(
          padding: TripwiseInsets.screen,
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildProgressIndicator(step: _currentStep, totalSteps: 2),
                const SizedBox(height: 18),
                if (_currentStep == 1) ...[
                  Text(
                    'Complete Your Profile',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 14),
                  _buildFormField(
                    label: 'Full Name',
                    controller: _fullNameController,
                    validator: (value) {
                      if (value?.isEmpty ?? true) {
                        return 'Full name is required';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 14),
                  _buildFormField(
                    label: 'Phone Number',
                    controller: _phoneController,
                    hint: '0123456789',
                    keyboardType: TextInputType.phone,
                    validator: (value) {
                      if (value?.isEmpty ?? true) {
                        return 'Phone number is required';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 14),
                  Text(
                    'Primary Specialty',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: TripwiseColors.onSurface,
                    ),
                  ),
                  const SizedBox(height: 6),
                  DropdownButtonFormField<String>(
                    value: _selectedSpecialty,
                    hint: const Text('Adventure Tours'),
                    items: _specialties.map((specialty) {
                      return DropdownMenuItem(
                        value: specialty,
                        child: Text(specialty),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedSpecialty = value;
                      });
                    },
                    validator: (value) {
                      if (value == null) {
                        return 'Please select a specialty';
                      }
                      return null;
                    },
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 10,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: TripwiseColors.outline),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: TripwiseColors.outline),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: TripwiseColors.primary,
                          width: 2,
                        ),
                      ),
                      errorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: TripwiseColors.error),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  _buildFormField(
                    label: 'Years of Experience',
                    controller: _experienceController,
                    hint: '5',
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value?.isEmpty ?? true) {
                        return 'Years of experience is required';
                      }
                      if (int.tryParse(value!) == null) {
                        return 'Please enter a valid number';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 14),
                  _buildFormField(
                    label: 'Bio',
                    controller: _bioController,
                    hint: 'Nguyen Thanh Phuoc ...',
                    maxLines: 3,
                    validator: (value) {
                      if (value?.isEmpty ?? true) {
                        return 'Bio is required';
                      }
                      if (value!.length < 20) {
                        return 'Bio must be at least 20 characters';
                      }
                      return null;
                    },
                  ),
                ] else ...[
                  Text(
                    'Upload Business License',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Tap to upload, tap image again to view, and use X to remove.',
                    style: TextStyle(
                      fontSize: 12,
                      color: TripwiseColors.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildLicenseCard(),
                ],
                const SizedBox(height: 18),
                Container(
                  decoration: BoxDecoration(
                    color: TripwiseColors.primaryFixed,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: TripwiseColors.primary.withOpacity(0.2),
                    ),
                  ),
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.info_rounded,
                        color: TripwiseColors.primary,
                        size: 18,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Your application will be reviewed by admin before provider access is granted.',
                          style: TextStyle(
                            fontSize: 12,
                            color: TripwiseColors.onSurface,
                            height: 1.35,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                if (_submitError != null) ...[
                  _InlineError(message: _submitError!),
                  const SizedBox(height: 12),
                ],
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _isSubmitting
                            ? null
                            : () {
                                if (_currentStep == 1) {
                                  context.go('/profile_registration');
                                  return;
                                }
                                setState(() => _currentStep = 1);
                              },
                        style: TripwiseButtonStyles.outlined(
                          radius: 12,
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          foregroundColor: TripwiseColors.onSurface,
                          borderColor: TripwiseColors.outline,
                        ),
                        child: Text(
                          _currentStep == 1 ? 'Cancel' : 'Back',
                          style: TextStyle(
                            color: TripwiseColors.onSurface,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _isSubmitting
                            ? null
                            : () {
                                if (_currentStep == 1) {
                                  if (_formKey.currentState?.validate() ??
                                      false) {
                                    setState(() {
                                      _currentStep = 2;
                                      _submitError = null;
                                    });
                                  }
                                  return;
                                }
                                _submitRegistration();
                              },
                        style: TripwiseButtonStyles.primaryElevated(
                          radius: 12,
                          padding: const EdgeInsets.symmetric(vertical: 10),
                        ),
                        child: _isSubmitting
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: TripwiseColors.onPrimary,
                                ),
                              )
                            : Text(
                                _currentStep == 1 ? 'Next' : 'Submit',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProgressIndicator({required int step, required int totalSteps}) {
    final progress = step / totalSteps;
    final percent = (progress * 100).round();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Step $step of $totalSteps',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: TripwiseColors.primary,
              ),
            ),
            Text(
              '$percent%',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: TripwiseColors.primary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 5,
            backgroundColor: TripwiseColors.surfaceContainer,
            valueColor: AlwaysStoppedAnimation<Color>(TripwiseColors.primary),
          ),
        ),
      ],
    );
  }

  Widget _buildLicenseCard() {
    final hasImage = _licenseBytes != null && _licenseBytes!.isNotEmpty;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(10),
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
              const Expanded(
                child: Text(
                  'Business License',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: TripwiseColors.onSurface,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                decoration: BoxDecoration(
                  color: hasImage
                      ? TripwiseColors.primaryFixed
                      : TripwiseColors.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  hasImage ? 'Submitted' : 'Pending',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: hasImage
                        ? TripwiseColors.onPrimaryFixedVariant
                        : TripwiseColors.onSurfaceVariant,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Stack(
            children: [
              InkWell(
                borderRadius: BorderRadius.circular(10),
                onTap: _isUploadingLicense
                    ? null
                    : hasImage
                    ? _viewLicenseImage
                    : _uploadLicenseImage,
                child: AspectRatio(
                  aspectRatio: 1.8,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: hasImage
                        ? Image.memory(_licenseBytes!, fit: BoxFit.cover)
                        : Container(
                            color: TripwiseColors.surfaceContainerLow,
                            child: const Column(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.center,
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
                ),
              ),
              if (hasImage)
                Positioned(
                  top: 6,
                  right: 6,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(999),
                    onTap: _isUploadingLicense
                        ? null
                        : () {
                            setState(() {
                              _licenseBytes = null;
                              _licenseMimeType = null;
                              _licenseFileName = null;
                            });
                          },
                    child: Container(
                      width: 26,
                      height: 26,
                      decoration: const BoxDecoration(
                        color: TripwiseColors.error,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.close_rounded,
                        color: TripwiseColors.onError,
                        size: 16,
                      ),
                    ),
                  ),
                ),
              if (_isUploadingLicense)
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
          ),
          const SizedBox(height: 6),
          Text(
            hasImage ? 'Submitted for review' : 'Not submitted',
            style: const TextStyle(
              fontSize: 10.5,
              color: TripwiseColors.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormField({
    required String label,
    required TextEditingController controller,
    String? hint,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: TripwiseColors.onSurface,
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines,
          validator: validator,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: TripwiseColors.onSurfaceVariant),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: TripwiseColors.outline),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: TripwiseColors.outline),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: TripwiseColors.primary, width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: TripwiseColors.error),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 10,
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _uploadLicenseImage() async {
    if (_isUploadingLicense) return;
    try {
      final file = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
        maxWidth: 1400,
      );
      if (file == null) return;
      final cropped = await ImageCropper().cropImage(
        sourcePath: file.path,
        maxWidth: 1400,
        maxHeight: 1400,
        compressFormat: ImageCompressFormat.jpg,
        compressQuality: 80,
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: 'Crop license',
            toolbarColor: TripwiseColors.primary,
            toolbarWidgetColor: TripwiseColors.onPrimary,
            initAspectRatio: CropAspectRatioPreset.original,
            lockAspectRatio: false,
          ),
          IOSUiSettings(
            title: 'Crop license',
            doneButtonTitle: 'Done',
            cancelButtonTitle: 'Cancel',
          ),
          WebUiSettings(
            context: context,
            presentStyle: WebPresentStyle.dialog,
            size: const CropperSize(width: 520, height: 520),
          ),
        ],
      );
      if (cropped == null) return;
      setState(() => _isUploadingLicense = true);
      final bytes = await cropped.readAsBytes();
      if (!mounted) return;
      setState(() {
        _licenseBytes = bytes;
        _licenseMimeType = 'image/jpeg';
        _licenseFileName = 'business_license.jpg';
      });
    } finally {
      if (mounted) setState(() => _isUploadingLicense = false);
    }
  }

  Future<void> _viewLicenseImage() async {
    if (_licenseBytes == null) return;
    final bytes = _licenseBytes!;
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
                    child: Image.memory(bytes, fit: BoxFit.contain),
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

  Future<void> _submitRegistration() async {
    if (_licenseBytes == null ||
        _licenseMimeType == null ||
        _licenseFileName == null) {
      setState(() {
        _submitError = 'Business license image is required';
      });
      return;
    }

    if (_isSubmitting) return;
    setState(() {
      _isSubmitting = true;
      _submitError = null;
    });

    try {
      await _api.submitApplication(
        fullName: _fullNameController.text.trim(),
        phone: _phoneController.text.trim(),
        specialty: _selectedSpecialty!,
        yearsExperience: int.parse(_experienceController.text.trim()),
        bio: _bioController.text.trim(),
        licenseFileName: _licenseFileName!,
        licenseMimeType: _licenseMimeType!,
        licenseDataBase64: base64Encode(_licenseBytes!),
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Provider application submitted for admin review.'),
          backgroundColor: TripwiseColors.primary,
        ),
      );
      context.go('/profile_registration');
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _submitError = error.toString();
      });
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }
}

class _InlineError extends StatelessWidget {
  const _InlineError({required this.message});

  final String message;

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
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
