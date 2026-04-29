import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../constants/colors.dart';

class ProviderRegistrationFormScreen extends StatefulWidget {
  const ProviderRegistrationFormScreen({super.key});

  @override
  State<ProviderRegistrationFormScreen> createState() =>
      _ProviderRegistrationFormScreenState();
}

class _ProviderRegistrationFormScreenState
    extends State<ProviderRegistrationFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _bioController = TextEditingController();
  final _experienceController = TextEditingController();
  final _phoneController = TextEditingController();

  String? _selectedSpecialty;
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
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: TripwiseColors.primary),
          onPressed: () => context.pop(),
        ),
        centerTitle: true,
        title: Text(
          'Provider Registration',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: TripwiseColors.primary,
                fontWeight: FontWeight.w900,
              ),
        ),
      ),
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

                // Action Buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => context.pop(),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          side: BorderSide(color: TripwiseColors.outline),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
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
                        onPressed: () {
                          if (_formKey.currentState?.validate() ?? false) {
                            _submitRegistration();
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: TripwiseColors.primary,
                          foregroundColor: TripwiseColors.onPrimary,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
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

  void _submitRegistration() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Registration submitted successfully!'),
        backgroundColor: TripwiseColors.primary,
        duration: const Duration(seconds: 2),
      ),
    );
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        context.pop();
      }
    });
  }
}
