import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../constants/colors.dart';
import '../widgets/shared_top_bars.dart';

class ProviderRegistrationScreen extends StatefulWidget {
  const ProviderRegistrationScreen({super.key});

  @override
  State<ProviderRegistrationScreen> createState() =>
      _ProviderRegistrationScreenState();
}

class _ProviderRegistrationScreenState
    extends State<ProviderRegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController(text: 'Alex Thompson');
  final _emailController = TextEditingController(text: 'alex@tripwise.app');
  final _cityController = TextEditingController();
  final _bioController = TextEditingController();

  String _selectedProviderType = 'Trip Planner';
  bool _acceptedTerms = false;

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _cityController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  void _submitRegistration() {
    final isValid = _formKey.currentState?.validate() ?? false;
    if (!isValid) {
      return;
    }

    if (!_acceptedTerms) {
      _showNotice('Please accept the provider terms to continue.');
      return;
    }

    context.go('/provider_dashboard');
  }

  void _showNotice(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          behavior: SnackBarBehavior.floating,
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: TripwiseColors.surface,
      appBar: const ProviderAppBar(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      TripwiseColors.primaryContainer,
                      TripwiseColors.primary,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Apply to become a provider',
                      style: textTheme.headlineSmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Complete your profile so Tripwise can review and activate your provider account.',
                      style: textTheme.bodyMedium?.copyWith(
                        color: Colors.white.withOpacity(0.9),
                        height: 1.45,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              _buildSectionTitle(context, 'Profile Details'),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _fullNameController,
                label: 'Full name',
                hint: 'Enter your full name',
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _emailController,
                label: 'Email address',
                hint: 'Enter your email',
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),
              _buildDropdownField(),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _cityController,
                label: 'Base city',
                hint: 'Where do you operate?',
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _bioController,
                label: 'Short bio',
                hint: 'Tell travelers about your expertise',
                maxLines: 4,
              ),
              const SizedBox(height: 24),
              _buildSectionTitle(context, 'Verification Documents'),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _UploadCard(
                      icon: Icons.badge_outlined,
                      title: 'Government ID',
                      subtitle: 'Passport, ID card, or driver license',
                      onTap: () => _showNotice(
                        'Document upload is not available yet.',
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _UploadCard(
                      icon: Icons.description_outlined,
                      title: 'Business proof',
                      subtitle: 'License, certificate, or tax document',
                      onTap: () => _showNotice(
                        'Document upload is not available yet.',
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Container(
                decoration: BoxDecoration(
                  color: TripwiseColors.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(16),
                ),
                padding: const EdgeInsets.all(16),
                child: CheckboxListTile(
                  value: _acceptedTerms,
                  onChanged: (value) {
                    setState(() {
                      _acceptedTerms = value ?? false;
                    });
                  },
                  activeColor: TripwiseColors.primary,
                  contentPadding: EdgeInsets.zero,
                  controlAffinity: ListTileControlAffinity.leading,
                  title: Text(
                    'I confirm that the information above is accurate and I agree to the provider review process.',
                    style: textTheme.bodyMedium?.copyWith(
                      color: TripwiseColors.onSurface,
                      height: 1.45,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _submitRegistration,
                  style: TripwiseButtonStyles.primaryElevated(
                    radius: 14,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text(
                    'Submit Registration',
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: TripwiseColors.onSurface,
            fontWeight: FontWeight.w800,
          ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        filled: true,
        fillColor: TripwiseColors.surfaceContainerLowest,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: TripwiseColors.outlineVariant),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: TripwiseColors.outlineVariant),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: TripwiseColors.primary, width: 1.5),
        ),
      ),
      validator: (value) {
        final trimmed = value?.trim() ?? '';
        if (trimmed.isEmpty) {
          return 'This field is required.';
        }

        if (keyboardType == TextInputType.emailAddress &&
            !trimmed.contains('@')) {
          return 'Enter a valid email address.';
        }

        return null;
      },
    );
  }

  Widget _buildDropdownField() {
    const providerTypes = [
      'Trip Planner',
      'Experience Host',
      'Accommodation Partner',
      'Transport Partner',
    ];

    return DropdownButtonFormField<String>(
      value: _selectedProviderType,
      decoration: InputDecoration(
        labelText: 'Provider type',
        filled: true,
        fillColor: TripwiseColors.surfaceContainerLowest,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: TripwiseColors.outlineVariant),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: TripwiseColors.outlineVariant),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: TripwiseColors.primary, width: 1.5),
        ),
      ),
      items: providerTypes
          .map(
            (type) => DropdownMenuItem<String>(
              value: type,
              child: Text(type),
            ),
          )
          .toList(),
      onChanged: (value) {
        if (value == null) {
          return;
        }

        setState(() {
          _selectedProviderType = value;
        });
      },
    );
  }
}

class _UploadCard extends StatelessWidget {
  const _UploadCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: TripwiseColors.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: TripwiseColors.outlineVariant),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: TripwiseColors.primaryFixed,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: TripwiseColors.primary),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: textTheme.bodySmall?.copyWith(
                  color: TripwiseColors.onSurfaceVariant,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
