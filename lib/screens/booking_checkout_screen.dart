import 'package:flutter/material.dart';
import '../constants/colors.dart';
import 'payment_success_screen.dart';

class BookingCheckoutScreen extends StatefulWidget {
  const BookingCheckoutScreen({super.key});

  @override
  State<BookingCheckoutScreen> createState() => _BookingCheckoutScreenState();
}

class _BookingCheckoutScreenState extends State<BookingCheckoutScreen> {
  String _selectedPaymentMethod = 'card';
  bool _agreeToTerms = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TripwiseColors.surface,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          color: TripwiseColors.onSurface,
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Checkout',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w900,
              ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Booking Summary Section
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Booking Summary',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w900,
                        ),
                  ),
                  const SizedBox(height: 16),
                  _buildSummaryItem(
                    label: 'Veligandu Island Resort',
                    value: '\$1,200',
                  ),
                  const SizedBox(height: 12),
                  _buildSummaryItem(
                    label: 'Taxes & Fees',
                    value: '\$120',
                  ),
                  const SizedBox(height: 12),
                  Divider(
                    color: TripwiseColors.outlineVariant,
                    thickness: 1,
                  ),
                  const SizedBox(height: 12),
                  _buildSummaryItem(
                    label: 'Total Amount',
                    value: '\$1,320',
                    isBold: true,
                  ),
                ],
              ),
            ),

            // Guest Information Section
            Container(
              color: TripwiseColors.surfaceContainerLow,
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Guest Information',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w900,
                        ),
                  ),
                  const SizedBox(height: 20),
                  _buildTextField(
                    label: 'Full Name',
                    placeholder: 'Enter your full name',
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    label: 'Email Address',
                    placeholder: 'Enter your email',
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    label: 'Phone Number',
                    placeholder: '+1 (555) 123-4567',
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    label: 'Special Requests',
                    placeholder: 'Any special requests?',
                    maxLines: 3,
                  ),
                ],
              ),
            ),

            // Payment Method Section
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Payment Method',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w900,
                        ),
                  ),
                  const SizedBox(height: 16),

                  // Card Option
                  _buildPaymentOption(
                    title: 'Credit/Debit Card',
                    subtitle: 'Visa, Mastercard, American Express',
                    value: 'card',
                    icon: Icons.credit_card,
                  ),
                  const SizedBox(height: 12),

                  // Wallet Option
                  _buildPaymentOption(
                    title: 'Tripwise Wallet',
                    subtitle: 'Balance: \$500.00',
                    value: 'wallet',
                    icon: Icons.account_balance_wallet,
                  ),
                  const SizedBox(height: 12),

                  // PayPal Option
                  _buildPaymentOption(
                    title: 'PayPal',
                    subtitle: 'Quick and secure',
                    value: 'paypal',
                    icon: Icons.payment,
                  ),
                ],
              ),
            ),

            // Terms Agreement
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                children: [
                  Checkbox(
                    value: _agreeToTerms,
                    onChanged: (value) {
                      setState(() {
                        _agreeToTerms = value ?? false;
                      });
                    },
                    activeColor: TripwiseColors.primary,
                  ),
                  Expanded(
                    child: Text(
                      'I agree to the booking terms and conditions',
                      style: TextStyle(
                        fontSize: 13,
                        color: TripwiseColors.onSurface,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Book Now Button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _agreeToTerms
                      ? () {
                          _showBookingConfirmation(context);
                        }
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: TripwiseColors.primary,
                    foregroundColor: TripwiseColors.onPrimary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    disabledBackgroundColor: TripwiseColors.outline.withOpacity(0.3),
                  ),
                  child: const Text(
                    'Complete Booking',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryItem({
    required String label,
    required String value,
    bool isBold = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isBold ? 15 : 14,
            fontWeight: isBold ? FontWeight.w700 : FontWeight.w500,
            color: TripwiseColors.onSurface,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: isBold ? 15 : 14,
            fontWeight: isBold ? FontWeight.w700 : FontWeight.w500,
            color: isBold ? TripwiseColors.primary : TripwiseColors.onSurface,
          ),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required String label,
    required String placeholder,
    int maxLines = 1,
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
        const SizedBox(height: 8),
        TextField(
          maxLines: maxLines,
          decoration: InputDecoration(
            hintText: placeholder,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: TripwiseColors.outline),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: TripwiseColors.outlineVariant,
              ),
            ),
            filled: true,
            fillColor: TripwiseColors.surfaceContainerLowest,
            contentPadding: const EdgeInsets.all(16),
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentOption({
    required String title,
    required String subtitle,
    required String value,
    required IconData icon,
  }) {
    bool isSelected = _selectedPaymentMethod == value;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedPaymentMethod = value;
        });
      },
      child: Container(
        decoration: BoxDecoration(
          color: isSelected
              ? TripwiseColors.primaryFixed
              : TripwiseColors.surfaceContainerLowest,
          border: Border.all(
            color: isSelected
                ? TripwiseColors.primary
                : TripwiseColors.outlineVariant,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              decoration: BoxDecoration(
                color: isSelected
                    ? TripwiseColors.primary.withOpacity(0.1)
                    : TripwiseColors.surfaceContainer,
                shape: BoxShape.circle,
              ),
              padding: const EdgeInsets.all(12),
              child: Icon(
                icon,
                size: 24,
                color: isSelected ? TripwiseColors.primary : TripwiseColors.onSurfaceVariant,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: TripwiseColors.onSurface,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: TripwiseColors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            Radio<String>(
              value: value,
              groupValue: _selectedPaymentMethod,
              onChanged: (newValue) {
                setState(() {
                  _selectedPaymentMethod = newValue ?? 'card';
                });
              },
              activeColor: TripwiseColors.primary,
            ),
          ],
        ),
      ),
    );
  }

  void _showBookingConfirmation(BuildContext context) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => const PaymentSuccessScreen(),
      ),
    );
  }
}
