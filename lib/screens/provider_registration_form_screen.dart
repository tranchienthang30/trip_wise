import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
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
  final _fullNameController = TextEditingController();
  final _bioController = TextEditingController();
  final _experienceController = TextEditingController();
  final _phoneController = TextEditingController();

  String? _selectedSpecialty;
  bool _isSubmitting = false;
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
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Progress Indicator
                _buildProgressIndicator(),
                const SizedBox(height: 32),

                // Section Title
                Text(
                  'Complete Your Profile',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Help travelers learn more about you and your services',
                  style: TextStyle(
                    fontSize: 14,
                    color: TripwiseColors.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 24),

                // Full Name Field
                _buildFormField(
                  label: 'Full Name',
                  controller: _fullNameController,
                  hint: 'Enter your full name',
                  validator: (value) {
                    if (value?.isEmpty ?? true) {
                      return 'Full name is required';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                // Phone Field
                _buildFormField(
                  label: 'Phone Number',
                  controller: _phoneController,
                  hint: '+1 (555) 123-4567',
                  keyboardType: TextInputType.phone,
                  validator: (value) {
                    if (value?.isEmpty ?? true) {
                      return 'Phone number is required';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                // Specialty Dropdown
                Text(
                  'Primary Specialty',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: TripwiseColors.onSurface,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: TripwiseColors.outline),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: DropdownButtonFormField<String>(
                    value: _selectedSpecialty,
                    hint: const Text('Select your specialty'),
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
                        horizontal: 16,
                        vertical: 12,
                      ),
                      border: InputBorder.none,
                      focusedBorder: InputBorder.none,
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Years of Experience
                _buildFormField(
                  label: 'Years of Experience',
                  controller: _experienceController,
                  hint: 'e.g., 5',
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
                const SizedBox(height: 20),

                // Bio Field
                _buildFormField(
                  label: 'Bio',
                  controller: _bioController,
                  hint: 'Tell travelers about yourself and your expertise',
                  maxLines: 4,
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
                const SizedBox(height: 32),

                // Information Card
                Container(
                  decoration: BoxDecoration(
                    color: TripwiseColors.primaryFixed,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: TripwiseColors.primary.withOpacity(0.2),
                    ),
                  ),
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: TripwiseColors.primary,
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Your profile information will be verified before you can accept bookings.',
                          style: TextStyle(
                            fontSize: 13,
                            color: TripwiseColors.onSurface,
                            height: 1.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                if (_submitError != null) ...[
                  _InlineError(message: _submitError!),
                  const SizedBox(height: 20),
                ],

                // Action Buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _isSubmitting ? null : () => context.pop(),
                        style: TripwiseButtonStyles.outlined(
                          radius: 12,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          foregroundColor: TripwiseColors.onSurface,
                          borderColor: TripwiseColors.outline,
                        ),
                        child: Text(
                          'Cancel',
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
                          if (_formKey.currentState?.validate() ?? false) {
                            _submitRegistration();
                          }
                        },
                        style: TripwiseButtonStyles.primaryElevated(
                          radius: 12,
                          padding: const EdgeInsets.symmetric(vertical: 12),
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
                            : const Text(
                                'Submit',
                                style: TextStyle(fontWeight: FontWeight.w600),
                              ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProgressIndicator() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Step 1 of 3',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: TripwiseColors.primary,
              ),
            ),
            Text(
              '33%',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: TripwiseColors.primary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: 0.33,
            minHeight: 6,
            backgroundColor: TripwiseColors.surfaceContainer,
            valueColor: AlwaysStoppedAnimation<Color>(
              TripwiseColors.primary,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFormField({
    required String label,
    required TextEditingController controller,
    required String hint,
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
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: TripwiseColors.onSurface,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines,
          validator: validator,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              color: TripwiseColors.onSurfaceVariant,
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
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _submitRegistration() async {
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
