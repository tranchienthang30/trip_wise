import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import '../constants/colors.dart';
import '../services/auth_session_store.dart';

enum _AuthMode { signIn, signUp }

class InitialRegistrationScreen extends StatefulWidget {
  const InitialRegistrationScreen({super.key});

  @override
  State<InitialRegistrationScreen> createState() =>
      _InitialRegistrationScreenState();
}

class _InitialRegistrationScreenState extends State<InitialRegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  _AuthMode _mode = _AuthMode.signIn;
  bool _acceptTerms = true;
  bool _isSubmitting = false;
  String? _submitError;

  bool get _isSignUp => _mode == _AuthMode.signUp;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final isValid = _formKey.currentState?.validate() ?? false;
    if (!isValid || _isSubmitting) {
      return;
    }

    if (_isSignUp && !_acceptTerms) {
      setState(() {
        _submitError = 'Please accept the terms before creating your account.';
      });
      return;
    }

    setState(() {
      _isSubmitting = true;
      _submitError = null;
    });

    try {
      if (_isSignUp) {
        await AuthSessionStore.instance.register(
          fullName: _nameController.text.trim(),
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );
      } else {
        await AuthSessionStore.instance.login(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _isSignUp
                ? 'Account created. Welcome to Tripwise.'
                : 'Signed in successfully.',
          ),
          backgroundColor: TripwiseColors.primary,
        ),
      );
      context.go('/home');
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _submitError = _errorMessage(error);
      });
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  Future<void> _submitGoogle() async {
    if (_isSubmitting) return;

    setState(() {
      _isSubmitting = true;
      _submitError = null;
    });

    try {
      await AuthSessionStore.instance.signInWithGoogle();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Google sign-in completed successfully.'),
          backgroundColor: TripwiseColors.primary,
        ),
      );
      context.go('/home');
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _submitError = _errorMessage(error);
      });
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  String _errorMessage(Object error) {
    final message = error.toString().trim();
    if (message.startsWith('Exception:')) {
      return message.replaceFirst('Exception:', '').trim();
    }
    return message;
  }

  void _switchMode(_AuthMode mode) {
    if (_mode == mode || _isSubmitting) return;
    setState(() {
      _mode = mode;
      _submitError = null;
    });
  }

  InputDecoration _inputDecoration({
    required String label,
    required String hint,
    required IconData icon,
  }) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      prefixIcon: Icon(icon, color: TripwiseColors.primary),
      filled: true,
      fillColor: TripwiseColors.surfaceContainerLowest,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: const BorderSide(
          color: TripwiseColors.primary,
          width: 2,
        ),
      ),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 18,
        vertical: 18,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final title = _isSignUp ? 'Create your account' : 'Welcome back';
    final subtitle = _isSignUp
        ? 'Register once, then stay signed in for up to 14 days.'
        : 'Sign in to continue your trips, bookings, and saved plans.';

    return Scaffold(
      backgroundColor: TripwiseColors.surface,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHero(textTheme),
              const SizedBox(height: 24),
              _buildModeToggle(),
              const SizedBox(height: 24),
              Text(
                title,
                style: textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                subtitle,
                style: textTheme.bodyMedium?.copyWith(
                  color: TripwiseColors.onSurfaceVariant,
                  height: 1.45,
                ),
              ),
              const SizedBox(height: 24),
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    if (_isSignUp) ...[
                      TextFormField(
                        controller: _nameController,
                        textInputAction: TextInputAction.next,
                        decoration: _inputDecoration(
                          label: 'Full Name',
                          hint: 'Enter your full name',
                          icon: Icons.person_rounded,
                        ),
                        validator: (value) {
                          if (_isSignUp && (value == null || value.trim().isEmpty)) {
                            return 'Please enter your full name.';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                    ],
                    TextFormField(
                      controller: _emailController,
                      textInputAction: TextInputAction.next,
                      keyboardType: TextInputType.emailAddress,
                      decoration: _inputDecoration(
                        label: 'Email',
                        hint: 'name@email.com',
                        icon: Icons.mail_rounded,
                      ),
                      validator: (value) {
                        final email = value?.trim() ?? '';
                        if (email.isEmpty || !email.contains('@')) {
                          return 'Please enter a valid email.';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _passwordController,
                      obscureText: true,
                      textInputAction: _isSignUp
                          ? TextInputAction.next
                          : TextInputAction.done,
                      onFieldSubmitted: (_) {
                        if (!_isSignUp) {
                          _submit();
                        }
                      },
                      decoration: _inputDecoration(
                        label: 'Password',
                        hint: 'At least 8 characters',
                        icon: Icons.lock_rounded,
                      ),
                      validator: (value) {
                        if ((value ?? '').length < 8) {
                          return 'Password must be at least 8 characters.';
                        }
                        return null;
                      },
                    ),
                    if (_isSignUp) ...[
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _confirmPasswordController,
                        obscureText: true,
                        textInputAction: TextInputAction.done,
                        onFieldSubmitted: (_) => _submit(),
                        decoration: _inputDecoration(
                          label: 'Confirm Password',
                          hint: 'Re-enter your password',
                          icon: Icons.verified_user_rounded,
                        ),
                        validator: (value) {
                          if (value != _passwordController.text) {
                            return 'Passwords do not match.';
                          }
                          return null;
                        },
                      ),
                    ],
                  ],
                ),
              ),
              if (_isSignUp) ...[
                const SizedBox(height: 18),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: TripwiseColors.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Checkbox(
                        value: _acceptTerms,
                        activeColor: TripwiseColors.primary,
                        onChanged: _isSubmitting
                            ? null
                            : (value) {
                                setState(() {
                                  _acceptTerms = value ?? false;
                                });
                              },
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(top: 12),
                          child: Text(
                            'I agree to the terms and understand Tripwise will keep me signed in for a limited time on this device.',
                            style: textTheme.bodyMedium?.copyWith(
                              color: TripwiseColors.onSurfaceVariant,
                              height: 1.4,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              if (_submitError != null) ...[
                const SizedBox(height: 16),
                _AuthErrorBanner(message: _submitError!),
              ],
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _submit,
                  style: TripwiseButtonStyles.primaryElevated(
                    radius: 20,
                    textStyle: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  child: _isSubmitting
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.4,
                            color: Colors.white,
                          ),
                        )
                      : Text(_isSignUp ? 'Create Account' : 'Sign In'),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                height: 54,
                child: OutlinedButton(
                  onPressed: _isSubmitting ? null : _submitGoogle,
                  style: TripwiseButtonStyles.outlined(
                    radius: 18,
                    backgroundColor: TripwiseColors.surfaceContainerLowest,
                    borderColor: TripwiseColors.outlineVariant,
                    foregroundColor: TripwiseColors.onSurface,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const _GoogleBadge(),
                      const SizedBox(width: 12),
                      const Text(
                        'Continue with Google',
                        style: TextStyle(fontWeight: FontWeight.w800),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Center(
                child: TextButton(
                  onPressed: _isSubmitting
                      ? null
                      : () => _switchMode(
                          _isSignUp ? _AuthMode.signIn : _AuthMode.signUp,
                        ),
                  style: TripwiseButtonStyles.text(
                    foregroundColor: TripwiseColors.primary,
                  ),
                  child: Text(
                    _isSignUp
                        ? 'Already have an account? Sign in'
                        : 'Need an account? Create one',
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHero(TextTheme textTheme) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            TripwiseColors.primaryContainer,
            TripwiseColors.primary,
          ],
        ),
        borderRadius: BorderRadius.circular(28),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.18),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.travel_explore_rounded,
              color: Colors.white,
              size: 28,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Tripwise Account',
            style: textTheme.headlineMedium?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w900,
              height: 1.05,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'One account to keep your bookings, wallet, itineraries, and notifications together across sessions.',
            style: textTheme.bodyLarge?.copyWith(
              color: Colors.white.withOpacity(0.9),
              height: 1.5,
            ),
          ),
          const SizedBox(height: 18),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 8,
            ),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.16),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              'SECURE SESSION',
              style: textTheme.labelMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.2,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModeToggle() {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: TripwiseColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Expanded(
            child: _ModeButton(
              label: 'Sign In',
              isActive: _mode == _AuthMode.signIn,
              onTap: () => _switchMode(_AuthMode.signIn),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _ModeButton(
              label: 'Create Account',
              isActive: _mode == _AuthMode.signUp,
              onTap: () => _switchMode(_AuthMode.signUp),
            ),
          ),
        ],
      ),
    );
  }
}

class _ModeButton extends StatelessWidget {
  const _ModeButton({
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  final String label;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onTap,
      style: isActive
          ? TripwiseButtonStyles.primaryElevated(
              radius: 14,
              padding: const EdgeInsets.symmetric(vertical: 14),
            )
          : TripwiseButtonStyles.outlined(
              radius: 14,
              foregroundColor: TripwiseColors.primary,
              borderColor: Colors.transparent,
              backgroundColor: Colors.transparent,
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
      child: Text(
        label,
        textAlign: TextAlign.center,
        style: const TextStyle(fontWeight: FontWeight.w800),
      ),
    );
  }
}

class _GoogleBadge extends StatelessWidget {
  const _GoogleBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: TripwiseColors.surfaceContainerHighest,
        ),
      ),
      padding: const EdgeInsets.all(4.5),
      child: SvgPicture.asset(
        'assets/images/google_logo.svg',
        fit: BoxFit.contain,
      ),
    );
  }
}

class _AuthErrorBanner extends StatelessWidget {
  const _AuthErrorBanner({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: TripwiseColors.errorContainer,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.warning_amber_rounded,
            color: TripwiseColors.onErrorContainer,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                color: TripwiseColors.onErrorContainer,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
