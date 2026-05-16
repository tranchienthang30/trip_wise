import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../constants/colors.dart';
import '../services/wallet_api.dart';

class AddPaymentScreen extends StatefulWidget {
  const AddPaymentScreen({super.key});

  @override
  State<AddPaymentScreen> createState() => _AddPaymentScreenState();
}

class _AddPaymentScreenState extends State<AddPaymentScreen> {
  // Brand PayPal blue — no Tripwise palette equivalent.
  static const Color _paypalBlue = Color(0xFF003087);

  final WalletApi _walletApi = WalletApi();

  bool _saveCard = true;
  bool _submitting = false;

  // Mock card creation: every new card is minted server-side with a fixed
  // ₫30,000,000 balance (the form fields are cosmetic for this slice).
  Future<void> _onAddCardTap() async {
    if (_submitting) return;
    setState(() => _submitting = true);
    try {
      await _walletApi.addCard();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Card added · ₫30,000,000 available'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      context.pop();
    } catch (e) {
      if (!mounted) return;
      setState(() => _submitting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Could not add card: $e'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _onMethodTap(String label) =>
      _showAddedSnackBarAndPop('$label selected');

  void _showAddedSnackBarAndPop(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(milliseconds: 1500),
        behavior: SnackBarBehavior.floating,
      ),
    );
    Navigator.of(context).pop();
  }

  InputDecoration _inputDecoration({String? hint, Widget? suffix}) {
    final textTheme = Theme.of(context).textTheme;
    return InputDecoration(
      filled: true,
      fillColor: TripwiseColors.surfaceContainerHighest,
      hintText: hint,
      hintStyle: textTheme.bodyMedium?.copyWith(color: TripwiseColors.outline),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 16,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(
          color: TripwiseColors.primary,
          width: 2,
        ),
      ),
      suffixIcon: suffix,
    );
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: TripwiseColors.surface,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        toolbarHeight: 64,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_rounded,
            color: TripwiseColors.primary,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Payment Method',
          style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
        ),
        centerTitle: true,
        actions: const [SizedBox(width: 48)],
      ),
      body: SafeArea(
        top: false,
        bottom: false,
        child: Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 120),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const _CardPreview(),
                  const SizedBox(height: 24),
                  _PaymentForm(inputDecorationBuilder: _inputDecoration),
                  const SizedBox(height: 24),
                  _SaveCardToggle(
                    value: _saveCard,
                    onChanged: (v) => setState(() => _saveCard = v),
                  ),
                  const SizedBox(height: 32),
                  Padding(
                    padding: const EdgeInsets.only(left: 4),
                    child: Text(
                      'OTHER PAYMENT METHODS',
                      style: textTheme.labelMedium?.copyWith(
                        color: TripwiseColors.onSurfaceVariant,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  _OtherMethods(
                    onTap: _onMethodTap,
                    paypalBlue: _paypalBlue,
                  ),
                ],
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: _AddCardCta(onTap: _onAddCardTap),
            ),
          ],
        ),
      ),
    );
  }
}

class _CardPreview extends StatelessWidget {
  const _CardPreview();

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Container(
      height: 208,
      padding: const EdgeInsets.all(28),
      clipBehavior: Clip.hardEdge,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            TripwiseColors.primaryContainer,
            TripwiseColors.primary,
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: TripwiseColors.primary.withOpacity(0.20),
            blurRadius: 40,
            offset: const Offset(0, 20),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'TRIPWISE PREMIUM',
                    style: textTheme.labelSmall?.copyWith(
                      color: Colors.white.withOpacity(0.80),
                      fontWeight: FontWeight.w500,
                      letterSpacing: 2.0,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    width: 40,
                    height: 28,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.20),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.10),
                      ),
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.contactless_rounded,
                        color: Colors.white,
                        size: 14,
                      ),
                    ),
                  ),
                ],
              ),
              const Icon(
                Icons.credit_card_rounded,
                color: Colors.white,
                size: 36,
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '••••  ••••  ••••  4242',
                style: textTheme.titleLarge?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 4,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'CARD HOLDER',
                        style: textTheme.labelSmall?.copyWith(
                          color: Colors.white.withOpacity(0.60),
                          letterSpacing: 1.5,
                          fontSize: 10,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'ADAM VOYAGER',
                        style: textTheme.bodyMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'EXPIRES',
                        style: textTheme.labelSmall?.copyWith(
                          color: Colors.white.withOpacity(0.60),
                          letterSpacing: 1.5,
                          fontSize: 10,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '12 / 26',
                        style: textTheme.bodyMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PaymentForm extends StatelessWidget {
  const _PaymentForm({required this.inputDecorationBuilder});

  final InputDecoration Function({String? hint, Widget? suffix})
  inputDecorationBuilder;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _LabeledField(
          label: 'Card Number',
          child: TextField(
            keyboardType: TextInputType.number,
            decoration: inputDecorationBuilder(
              hint: '0000 0000 0000 0000',
              suffix: const Padding(
                padding: EdgeInsets.only(right: 16),
                child: Icon(
                  Icons.verified_user_rounded,
                  color: TripwiseColors.primaryContainer,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 20),
        _LabeledField(
          label: 'Cardholder Name',
          child: TextField(
            decoration: inputDecorationBuilder(hint: 'Enter full name'),
          ),
        ),
        const SizedBox(height: 20),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _LabeledField(
                label: 'Expiry Date (MM/YY)',
                child: TextField(
                  keyboardType: TextInputType.datetime,
                  decoration: inputDecorationBuilder(hint: 'MM/YY'),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _LabeledField(
                label: 'CVV',
                child: TextField(
                  obscureText: true,
                  keyboardType: TextInputType.number,
                  decoration: inputDecorationBuilder(
                    hint: '•••',
                    suffix: const Padding(
                      padding: EdgeInsets.only(right: 16),
                      child: Icon(
                        Icons.help_outline_rounded,
                        color: TripwiseColors.outline,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _LabeledField extends StatelessWidget {
  const _LabeledField({required this.label, required this.child});

  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4),
          child: Text(
            label,
            style: textTheme.labelMedium?.copyWith(
              color: TripwiseColors.onSurfaceVariant,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const SizedBox(height: 8),
        child,
      ],
    );
  }
}

class _SaveCardToggle extends StatelessWidget {
  const _SaveCardToggle({required this.value, required this.onChanged});

  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: TripwiseColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: TripwiseColors.primaryContainer.withOpacity(0.10),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.security_rounded,
              color: TripwiseColors.primaryContainer,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Save card for future use',
                  style: textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Your data is encrypted and secure',
                  style: textTheme.bodySmall?.copyWith(
                    color: TripwiseColors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: TripwiseColors.secondaryContainer,
          ),
        ],
      ),
    );
  }
}

class _OtherMethods extends StatelessWidget {
  const _OtherMethods({required this.onTap, required this.paypalBlue});

  final void Function(String label) onTap;
  final Color paypalBlue;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _MethodTile(
            icon: Icons.account_balance_wallet_rounded,
            iconColor: paypalBlue,
            label: 'PAYPAL',
            onTap: () => onTap('PAYPAL'),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _MethodTile(
            icon: Icons.apple_rounded,
            iconColor: TripwiseColors.onSurface,
            label: 'APPLE PAY',
            onTap: () => onTap('APPLE PAY'),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _MethodTile(
            icon: Icons.g_mobiledata_rounded,
            iconColor: TripwiseColors.primary,
            label: 'GOOGLE PAY',
            onTap: () => onTap('GOOGLE PAY'),
          ),
        ),
      ],
    );
  }
}

class _MethodTile extends StatelessWidget {
  const _MethodTile({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final Color iconColor;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        decoration: BoxDecoration(
          color: TripwiseColors.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 28, color: iconColor),
            const SizedBox(height: 8),
            Text(
              label,
              style: textTheme.labelSmall?.copyWith(
                color: TripwiseColors.onSurfaceVariant,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.8,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AddCardCta extends StatelessWidget {
  const _AddCardCta({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: TripwiseColors.surface.withOpacity(0.95),
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      child: SizedBox(
        height: 56,
        width: double.infinity,
        child: ElevatedButton(
          onPressed: onTap,
          style: TripwiseButtonStyles.primaryElevated(
            radius: 20,
            elevation: 8,
            shadowColor: TripwiseColors.primary.withOpacity(0.30),
            textStyle: const TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 16,
            ),
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Add Card'),
              SizedBox(width: 8),
              Icon(Icons.arrow_forward_rounded, size: 22),
            ],
          ),
        ),
      ),
    );
  }
}
