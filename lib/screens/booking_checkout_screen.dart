import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../constants/colors.dart';
import '../models/checkout_data.dart';
import '../services/checkout_api.dart';

class BookingCheckoutScreen extends StatefulWidget {
  const BookingCheckoutScreen({
    super.key,
    this.hotelId,
    this.roomId,
    this.startDate,
    this.endDate,
    this.guests,
  });

  final String? hotelId;
  final String? roomId;
  final String? startDate;
  final String? endDate;
  final String? guests;

  @override
  State<BookingCheckoutScreen> createState() => _BookingCheckoutScreenState();
}

class _BookingCheckoutScreenState extends State<BookingCheckoutScreen> {
  final CheckoutApi _api = CheckoutApi();
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _requestsController = TextEditingController();

  CheckoutSummary? _summary;
  String _selectedPaymentMethod = 'card';
  bool _agreeToTerms = false;
  bool _isLoading = true;
  bool _isSubmitting = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadSummary();
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _requestsController.dispose();
    super.dispose();
  }

  Future<void> _loadSummary() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final summary = await _api.fetchSummary(
        hotelId: _toInt(widget.hotelId),
        roomId: _toInt(widget.roomId),
        startDate: widget.startDate,
        endDate: widget.endDate,
        guests: _toInt(widget.guests),
      );
      if (!mounted) return;

      setState(() {
        _summary = summary;
        _selectedPaymentMethod = summary.paymentOptions.isEmpty
            ? 'card'
            : summary.paymentOptions.first.key;
        _fullNameController.text = summary.guestPrefill.fullName;
        _emailController.text = summary.guestPrefill.email ?? '';
        _phoneController.text = summary.guestPrefill.phone ?? '';
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

  Future<void> _completeBooking() async {
    final summary = _summary;
    if (summary == null || _isSubmitting) return;

    if (!_agreeToTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please agree to booking terms to continue.'),
          backgroundColor: TripwiseColors.primary,
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);
    try {
      final result = await _api.complete(
        hotelId: summary.listing.hotelId,
        roomId: summary.listing.roomId,
        startDate: summary.listing.startDate,
        endDate: summary.listing.endDate,
        guests: summary.listing.guests,
        paymentMethod: _selectedPaymentMethod,
        agreeToTerms: true,
      );
      if (!mounted) return;
      context.go(result.nextRoute);
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error.toString()),
          backgroundColor: TripwiseColors.error,
        ),
      );
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

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
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Checkout',
          style: Theme.of(
            context,
          ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900),
        ),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading && _summary == null) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null && _summary == null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.cloud_off_rounded, size: 48),
              const SizedBox(height: 12),
              const Text(
                "Couldn't load checkout",
                style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18),
              ),
              const SizedBox(height: 8),
              Text(
                _error!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: TripwiseColors.onSurfaceVariant),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _loadSummary,
                style: TripwiseButtonStyles.primaryElevated(radius: 12),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    final summary = _summary!;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_error != null)
            Container(
              margin: const EdgeInsets.fromLTRB(24, 0, 24, 16),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: TripwiseColors.errorContainer,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.info_outline,
                    color: TripwiseColors.onErrorContainer,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _error!,
                      style: const TextStyle(
                        color: TripwiseColors.onErrorContainer,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          if (summary.listing.imageUrl != null &&
              summary.listing.imageUrl!.isNotEmpty)
            Image.network(
              summary.listing.imageUrl!,
              height: 180,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => const SizedBox.shrink(),
            ),
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  summary.listing.title,
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 6),
                Text(
                  summary.listing.subtitle,
                  style: const TextStyle(
                    color: TripwiseColors.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${summary.listing.startDate} → ${summary.listing.endDate} • ${summary.listing.nights} night(s) • ${summary.listing.guests} guest(s)',
                  style: const TextStyle(
                    color: TripwiseColors.onSurfaceVariant,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: _buildPricing(summary.pricing),
          ),
          const SizedBox(height: 24),
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
                const SizedBox(height: 16),
                _buildTextField(
                  label: 'Full Name',
                  controller: _fullNameController,
                  placeholder: 'Enter your full name',
                ),
                const SizedBox(height: 12),
                _buildTextField(
                  label: 'Email Address',
                  controller: _emailController,
                  placeholder: 'Enter your email',
                ),
                const SizedBox(height: 12),
                _buildTextField(
                  label: 'Phone Number',
                  controller: _phoneController,
                  placeholder: 'Enter your phone',
                ),
                const SizedBox(height: 12),
                _buildTextField(
                  label: 'Special Requests',
                  controller: _requestsController,
                  placeholder: 'Any special requests?',
                  maxLines: 3,
                ),
              ],
            ),
          ),
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
                const SizedBox(height: 14),
                ...summary.paymentOptions.map(_buildPaymentOption),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              children: [
                Checkbox(
                  value: _agreeToTerms,
                  onChanged: (value) =>
                      setState(() => _agreeToTerms = value ?? false),
                  activeColor: TripwiseColors.primary,
                ),
                const Expanded(
                  child: Text(
                    'I agree to the booking terms and conditions',
                    style: TextStyle(fontSize: 13),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : _completeBooking,
                style: TripwiseButtonStyles.primaryElevated(
                  radius: 12,
                  disabledBackgroundColor: TripwiseColors.outline.withOpacity(
                    0.2,
                  ),
                ),
                child: _isSubmitting
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: TripwiseColors.onPrimary,
                        ),
                      )
                    : const Text(
                        'Complete Booking',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
              ),
            ),
          ),
          const SizedBox(height: 28),
        ],
      ),
    );
  }

  Widget _buildPricing(CheckoutPricing pricing) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: TripwiseColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Booking Summary',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 14),
          _buildSummaryItem('Subtotal', pricing.subtotalLabel),
          const SizedBox(height: 8),
          _buildSummaryItem('Taxes', pricing.taxesLabel),
          const SizedBox(height: 8),
          _buildSummaryItem('Fees', pricing.feesLabel),
          const SizedBox(height: 10),
          const Divider(height: 1),
          const SizedBox(height: 10),
          _buildSummaryItem('Total Amount', pricing.totalLabel, isBold: true),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(String label, String value, {bool isBold = false}) {
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
    required TextEditingController controller,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: TripwiseColors.onSurface,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
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
            contentPadding: const EdgeInsets.all(14),
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentOption(CheckoutPaymentOption option) {
    final isSelected = _selectedPaymentMethod == option.key;
    IconData icon;
    switch (option.key) {
      case 'wallet':
        icon = Icons.account_balance_wallet_outlined;
        break;
      case 'paypal':
        icon = Icons.payment_outlined;
        break;
      case 'card':
      default:
        icon = Icons.credit_card;
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: GestureDetector(
        onTap: () => setState(() => _selectedPaymentMethod = option.key),
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
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Icon(
                icon,
                size: 22,
                color: isSelected
                    ? TripwiseColors.primary
                    : TripwiseColors.onSurfaceVariant,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      option.title,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      option.subtitle,
                      style: const TextStyle(
                        fontSize: 12,
                        color: TripwiseColors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              Radio<String>(
                value: option.key,
                groupValue: _selectedPaymentMethod,
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _selectedPaymentMethod = value);
                  }
                },
                activeColor: TripwiseColors.primary,
              ),
            ],
          ),
        ),
      ),
    );
  }

  int? _toInt(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    return int.tryParse(value);
  }
}
