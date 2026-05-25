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
  String? _selectedStartDate;
  String? _selectedEndDate;
  int? _selectedGuests;
  String _selectedPaymentMethod = 'card';
  bool _usePoints = false;
  bool _agreeToTerms = false;
  bool _isLoading = true;
  bool _isSubmitting = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _selectedStartDate = _cleanString(widget.startDate);
    _selectedEndDate = _cleanString(widget.endDate);
    _selectedGuests = _toInt(widget.guests);
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
        startDate: _selectedStartDate,
        endDate: _selectedEndDate,
        guests: _selectedGuests,
      );
      if (!mounted) return;

      setState(() {
        _summary = summary;
        _selectedStartDate = summary.listing.startDate;
        _selectedEndDate = summary.listing.endDate;
        _selectedGuests = summary.listing.guests;
        _selectedPaymentMethod = summary.paymentOptions.isEmpty
            ? 'card'
            : summary.paymentOptions.first.key;
        if (summary.pricing.pointsMaxRedeem <= 0) {
          _usePoints = false;
        }
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

    final validationMessage = _bookingValidationMessage(
      startDate: summary.listing.startDate,
      endDate: summary.listing.endDate,
      guests: summary.listing.guests,
    );
    if (validationMessage != null) {
      _showFeedback(validationMessage, isError: true);
      return;
    }

    if (!_agreeToTerms) {
      _showFeedback('Please agree to booking terms to continue.');
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
        usePoints: _usePoints,
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

  Future<void> _pickDates(CheckoutSummary summary) async {
    final currentRange = _currentDateRange(summary);
    final today = _dateOnly(DateTime.now());
    final picked = await showDateRangePicker(
      context: context,
      firstDate: today,
      lastDate: DateTime(today.year + 2, 12, 31),
      initialDateRange: currentRange,
      helpText: 'Select booking dates',
      saveText: 'Apply',
    );
    if (picked == null) return;

    final startDate = _isoDate(picked.start);
    final endDate = _isoDate(picked.end);
    final validationMessage = _bookingValidationMessage(
      startDate: startDate,
      endDate: endDate,
      guests: _selectedGuests ?? summary.listing.guests,
    );
    if (validationMessage != null) {
      _showFeedback(validationMessage, isError: true);
      return;
    }

    setState(() {
      _selectedStartDate = startDate;
      _selectedEndDate = endDate;
    });
    await _loadSummary();
  }

  Future<void> _pickGuests(CheckoutSummary summary) async {
    final picked = await showModalBottomSheet<int>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        var draftGuests = _selectedGuests ?? summary.listing.guests;
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return SafeArea(
              child: Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: TripwiseColors.surfaceContainerLowest,
                  borderRadius: BorderRadius.circular(22),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Guests',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w900,
                          ),
                    ),
                    const SizedBox(height: 14),
                    _GuestStepper(
                      label: 'Guests',
                      value: draftGuests,
                      min: 1,
                      onChanged: (value) {
                        setSheetState(() => draftGuests = value);
                      },
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () =>
                            Navigator.of(sheetContext).pop(draftGuests),
                        style: TripwiseButtonStyles.primaryElevated(radius: 18),
                        child: const Text('Apply'),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
    if (picked == null) return;

    final validationMessage = _bookingValidationMessage(
      startDate: _selectedStartDate ?? summary.listing.startDate,
      endDate: _selectedEndDate ?? summary.listing.endDate,
      guests: picked,
    );
    if (validationMessage != null) {
      _showFeedback(validationMessage, isError: true);
      return;
    }

    setState(() => _selectedGuests = picked);
    await _loadSummary();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TripwiseColors.surface,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
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
              margin: const EdgeInsets.fromLTRB(
                TripwiseSpacing.xl,
                0,
                TripwiseSpacing.xl,
                TripwiseSpacing.lg,
              ),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: TripwiseColors.errorContainer,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.info_rounded,
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
            padding: TripwiseInsets.section,
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
                const SizedBox(height: 16),
                _BookingTripDetailsCard(
                  dateLabel:
                      '${_formatDate(summary.listing.startDate)} - ${_formatDate(summary.listing.endDate)}',
                  nightsLabel:
                      '${summary.listing.nights} ${_plural(summary.listing.nights, 'night')}',
                  guestsLabel:
                      '${summary.listing.guests} ${_plural(summary.listing.guests, 'guest')}',
                  onEditDates: () => _pickDates(summary),
                  onEditGuests: () => _pickGuests(summary),
                ),
              ],
            ),
          ),
          Padding(
            padding: TripwiseInsets.horizontal,
            child: _buildPricing(summary.pricing),
          ),
          const SizedBox(height: 24),
          Container(
            color: TripwiseColors.surfaceContainerLow,
            padding: TripwiseInsets.section,
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
            padding: TripwiseInsets.section,
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
            padding: TripwiseInsets.horizontal,
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
            padding: TripwiseInsets.horizontal,
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
    final canUsePoints = pricing.pointsMaxRedeem > 0;
    final pointsDiscount = _usePoints && canUsePoints
        ? pricing.pointsMaxRedeem
        : 0.0;
    final amountDue = (pricing.total - pointsDiscount).clamp(
      0.0,
      double.infinity,
    ).toDouble();

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
          if (canUsePoints) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: TripwiseColors.surfaceContainerLow,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  Checkbox(
                    value: _usePoints,
                    onChanged: (value) =>
                        setState(() => _usePoints = value ?? false),
                    activeColor: TripwiseColors.primary,
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Use points',
                          style: TextStyle(fontWeight: FontWeight.w900),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Available: ${pricing.pointsAvailableLabel}. Max: ${pricing.pointsMaxRedeemLabel} (20% of this booking).',
                          style: const TextStyle(
                            color: TripwiseColors.onSurfaceVariant,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
          if (pointsDiscount > 0) ...[
            const SizedBox(height: 8),
            _buildSummaryItem(
              'Points discount',
              '-${pricing.pointsMaxRedeemLabel}',
            ),
          ],
          const SizedBox(height: 10),
          const Divider(height: 1),
          const SizedBox(height: 10),
          _buildSummaryItem(
            pointsDiscount > 0 ? 'Amount Due' : 'Total Amount',
            pointsDiscount > 0 ? _moneyLabel(pricing, amountDue) : pricing.totalLabel,
            isBold: true,
          ),
        ],
      ),
    );
  }

  String _moneyLabel(CheckoutPricing pricing, double value) {
    final rounded = value.round();
    final digits = rounded.toString();
    final buffer = StringBuffer();
    for (var i = 0; i < digits.length; i++) {
      if (i > 0 && (digits.length - i) % 3 == 0) buffer.write(',');
      buffer.write(digits[i]);
    }
    if (pricing.currency.toUpperCase() == 'USD') return '\$${buffer.toString()}';
    return '${buffer.toString()} ${pricing.currency}';
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
        icon = Icons.account_balance_wallet_rounded;
        break;
      case 'paypal':
        icon = Icons.payment_rounded;
        break;
      case 'card':
      default:
        icon = Icons.credit_card_rounded;
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

  String? _cleanString(String? value) {
    final trimmed = value?.trim() ?? '';
    return trimmed.isEmpty ? null : trimmed;
  }

  DateTime _dateOnly(DateTime value) {
    return DateTime(value.year, value.month, value.day);
  }

  String _isoDate(DateTime value) {
    final year = value.year.toString().padLeft(4, '0');
    final month = value.month.toString().padLeft(2, '0');
    final day = value.day.toString().padLeft(2, '0');
    return '$year-$month-$day';
  }

  DateTimeRange _currentDateRange(CheckoutSummary summary) {
    final today = _dateOnly(DateTime.now());
    final start =
        DateTime.tryParse(_selectedStartDate ?? summary.listing.startDate) ??
        today.add(const Duration(days: 1));
    final end =
        DateTime.tryParse(_selectedEndDate ?? summary.listing.endDate) ??
        start.add(const Duration(days: 1));

    final normalizedStart = _dateOnly(start);
    final normalizedEnd = _dateOnly(end);
    if (normalizedStart.isBefore(today) ||
        !normalizedEnd.isAfter(normalizedStart)) {
      return DateTimeRange(
        start: today.add(const Duration(days: 1)),
        end: today.add(const Duration(days: 2)),
      );
    }

    return DateTimeRange(start: normalizedStart, end: normalizedEnd);
  }

  String? _bookingValidationMessage({
    required String startDate,
    required String endDate,
    required int guests,
  }) {
    final start = DateTime.tryParse(startDate);
    final end = DateTime.tryParse(endDate);
    if (start == null || end == null) {
      return 'Please choose valid booking dates.';
    }

    final today = _dateOnly(DateTime.now());
    final startOnly = _dateOnly(start);
    final endOnly = _dateOnly(end);
    if (startOnly.isBefore(today)) {
      return 'Start date cannot be in the past.';
    }
    if (!endOnly.isAfter(startOnly)) {
      return 'End date must be after start date.';
    }
    if (guests < 1) {
      return 'At least 1 guest is required.';
    }
    return null;
  }

  void _showFeedback(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor:
              isError ? TripwiseColors.error : TripwiseColors.primary,
        ),
      );
  }

  String _formatDate(String value) {
    final parsed = DateTime.tryParse(value);
    if (parsed == null) return value;
    return MaterialLocalizations.of(context).formatShortMonthDay(parsed);
  }

  String _plural(int value, String singular) {
    return value == 1 ? singular : '${singular}s';
  }
}

class _BookingTripDetailsCard extends StatelessWidget {
  const _BookingTripDetailsCard({
    required this.dateLabel,
    required this.nightsLabel,
    required this.guestsLabel,
    required this.onEditDates,
    required this.onEditGuests,
  });

  final String dateLabel;
  final String nightsLabel;
  final String guestsLabel;
  final VoidCallback onEditDates;
  final VoidCallback onEditGuests;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: TripwiseColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: TripwiseColors.outlineVariant),
      ),
      child: Column(
        children: [
          _TripDetailRow(
            icon: Icons.calendar_today_rounded,
            eyebrow: 'DATES',
            value: dateLabel,
            onTap: onEditDates,
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Divider(height: 1, color: TripwiseColors.outlineVariant),
          ),
          Row(
            children: [
              Expanded(
                child: _TripDetailMetric(
                  icon: Icons.bedtime_rounded,
                  eyebrow: 'STAY',
                  value: nightsLabel,
                  onTap: onEditDates,
                ),
              ),
              Container(
                width: 1,
                height: 42,
                color: TripwiseColors.outlineVariant,
              ),
              Expanded(
                child: _TripDetailMetric(
                  icon: Icons.group_rounded,
                  eyebrow: 'GUESTS',
                  value: guestsLabel,
                  onTap: onEditGuests,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _TripDetailRow extends StatelessWidget {
  const _TripDetailRow({
    required this.icon,
    required this.eyebrow,
    required this.value,
    required this.onTap,
  });

  final IconData icon;
  final String eyebrow;
  final String value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 2),
        child: Row(
          children: [
            _TripDetailIcon(icon: icon),
            const SizedBox(width: 12),
            Expanded(
              child: _TripDetailText(eyebrow: eyebrow, value: value),
            ),
            const Icon(
              Icons.edit_calendar_rounded,
              size: 20,
              color: TripwiseColors.primary,
            ),
          ],
        ),
      ),
    );
  }
}

class _TripDetailMetric extends StatelessWidget {
  const _TripDetailMetric({
    required this.icon,
    required this.eyebrow,
    required this.value,
    required this.onTap,
  });

  final IconData icon;
  final String eyebrow;
  final String value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        child: Row(
          children: [
            _TripDetailIcon(icon: icon, compact: true),
            const SizedBox(width: 10),
            Expanded(
              child: _TripDetailText(eyebrow: eyebrow, value: value),
            ),
          ],
        ),
      ),
    );
  }
}

class _TripDetailText extends StatelessWidget {
  const _TripDetailText({
    required this.eyebrow,
    required this.value,
  });

  final String eyebrow;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          eyebrow,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: TripwiseColors.onSurfaceVariant,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.1,
              ),
        ),
        const SizedBox(height: 3),
        Text(
          value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w900,
                color: TripwiseColors.onSurface,
              ),
        ),
      ],
    );
  }
}

class _TripDetailIcon extends StatelessWidget {
  const _TripDetailIcon({
    required this.icon,
    this.compact = false,
  });

  final IconData icon;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final size = compact ? 34.0 : 38.0;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: TripwiseColors.primaryFixed,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(
        icon,
        size: compact ? 18 : 20,
        color: TripwiseColors.primary,
      ),
    );
  }
}

class _GuestStepper extends StatelessWidget {
  const _GuestStepper({
    required this.label,
    required this.value,
    required this.min,
    required this.onChanged,
  });

  final String label;
  final int value;
  final int min;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
          ),
        ),
        IconButton.filledTonal(
          onPressed: value <= min ? null : () => onChanged(value - 1),
          icon: const Icon(Icons.remove_rounded),
        ),
        SizedBox(
          width: 44,
          child: Text(
            '$value',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w900,
                ),
          ),
        ),
        IconButton.filledTonal(
          onPressed: () => onChanged(value + 1),
          icon: const Icon(Icons.add_rounded),
        ),
      ],
    );
  }
}
