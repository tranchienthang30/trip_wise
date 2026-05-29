import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../constants/colors.dart';
import '../models/checkout_data.dart';
import '../services/checkout_api.dart';

class BookingCheckoutScreen extends StatefulWidget {
  const BookingCheckoutScreen({
    super.key,
    this.type,
    this.hotelId,
    this.roomId,
    this.flightId,
    this.activityId,
    this.startDate,
    this.endDate,
    this.guests,
  });

  final String? type;
  final String? hotelId;
  final String? roomId;
  final String? flightId;
  final String? activityId;
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
  String _selectedCabinClass = 'economy';
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
        type: _bookingType,
        hotelId: _toInt(widget.hotelId),
        roomId: _toInt(widget.roomId),
        flightId: _toInt(widget.flightId),
        activityId: _toInt(widget.activityId),
        startDate: _selectedStartDate,
        endDate: _selectedEndDate,
        guests: _selectedGuests,
        cabinClass: _selectedCabinClass,
      );
      if (!mounted) return;

      setState(() {
        _summary = summary;
        _selectedStartDate = summary.listing.startDate;
        _selectedEndDate = summary.listing.endDate;
        _selectedGuests = summary.listing.guests;
        _selectedCabinClass = summary.listing.cabinClass;
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

    final guestValidationMessage = _guestValidationMessage();
    if (guestValidationMessage != null) {
      _showFeedback(guestValidationMessage, isError: true);
      return;
    }

    setState(() => _isSubmitting = true);
    try {
      final result = await _api.complete(
        type: summary.listing.serviceType,
        hotelId: summary.listing.hotelId,
        roomId: summary.listing.roomId,
        flightId: summary.listing.flightId,
        activityId: summary.listing.activityId,
        startDate: summary.listing.startDate,
        endDate: summary.listing.endDate,
        guests: summary.listing.guests,
        paymentMethod: _selectedPaymentMethod,
        usePoints: _usePoints,
        agreeToTerms: true,
        cabinClass: _selectedCabinClass,
      );
      if (!mounted) return;
      final payosUrl = result.payos?.checkoutUrl.trim() ?? '';
      if (payosUrl.isNotEmpty) {
        await launchUrl(
          Uri.parse(payosUrl),
          mode: LaunchMode.externalApplication,
        );
        return;
      }
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
    if (summary.listing.dateLocked) {
      _showFeedback('This schedule is fixed for the selected flight.');
      return;
    }
    if (summary.listing.serviceType == 'activity') {
      await _pickTourDate(summary);
      return;
    }
    final currentRange = _currentDateRange(summary);
    final today = _dateOnly(DateTime.now());
    final picked = await showDateRangePicker(
      context: context,
      firstDate: today,
      lastDate: DateTime(today.year + 2, 12, 31),
      initialDateRange: currentRange,
      helpText: 'Select booking dates',
      saveText: 'Apply',
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: TripwiseColors.primary,
              onPrimary: TripwiseColors.onPrimary,
              secondary: TripwiseColors.primaryFixedDim,
              onSecondary: TripwiseColors.onPrimaryFixed,
              surface: TripwiseColors.surfaceContainerLowest,
            ),
            datePickerTheme: const DatePickerThemeData(
              rangeSelectionBackgroundColor: TripwiseColors.primaryFixedDim,
              rangeSelectionOverlayColor: WidgetStatePropertyAll(
                Colors.transparent,
              ),
            ),
          ),
          child: child!,
        );
      },
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

  Future<void> _pickTourDate(CheckoutSummary summary) async {
    final today = _dateOnly(DateTime.now());
    final current =
        DateTime.tryParse(_selectedStartDate ?? summary.listing.startDate) ??
        today.add(const Duration(days: 1));
    final initialDate = current.isBefore(today) ? today : current;
    final picked = await showDatePicker(
      context: context,
      firstDate: today,
      lastDate: DateTime(today.year + 2, 12, 31),
      initialDate: initialDate,
      helpText: 'Select tour date',
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: TripwiseColors.primary,
              onPrimary: TripwiseColors.onPrimary,
              surface: TripwiseColors.surfaceContainerLowest,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked == null) return;

    final date = _isoDate(picked);
    final validationMessage = _bookingValidationMessage(
      startDate: date,
      endDate: date,
      guests: _selectedGuests ?? summary.listing.guests,
    );
    if (validationMessage != null) {
      _showFeedback(validationMessage, isError: true);
      return;
    }

    setState(() {
      _selectedStartDate = date;
      _selectedEndDate = date;
    });
    await _loadSummary();
  }

  Future<void> _pickGuests(CheckoutSummary summary) async {
    final maxGuests = summary.listing.serviceType == 'flight'
        ? summary.listing.availableSeats
        : null;
    final picked = await showModalBottomSheet<int>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        var draftGuests = _selectedGuests ?? summary.listing.guests;
        if (maxGuests != null && draftGuests > maxGuests) {
          draftGuests = maxGuests;
        }
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
                      summary.listing.quantityTitle,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w900,
                          ),
                    ),
                    const SizedBox(height: 14),
                    _GuestStepper(
                      label: summary.listing.quantityTitle,
                      value: draftGuests,
                      min: 1,
                      max: maxGuests,
                      onChanged: (value) {
                        setSheetState(() => draftGuests = value);
                      },
                    ),
                    if (maxGuests != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        '$maxGuests seat${maxGuests == 1 ? '' : 's'} available for this flight.',
                        style: const TextStyle(
                          color: TripwiseColors.onSurfaceVariant,
                          fontSize: 12,
                        ),
                      ),
                    ],
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
                  serviceType: summary.listing.serviceType,
                  dateLabel: _dateSummary(summary.listing),
                  nightsLabel: _unitSummary(summary.listing),
                  guestsLabel:
                      '${summary.listing.guests} ${_plural(summary.listing.guests, _quantitySingular(summary.listing.serviceType))}',
                  quantityTitle: summary.listing.quantityTitle,
                  dateLocked: summary.listing.dateLocked,
                  onEditDates: () => _pickDates(summary),
                  onEditGuests: () => _pickGuests(summary),
                ),
                if (summary.listing.serviceType == 'flight') ...[
                  const SizedBox(height: 14),
                  _FlightBookingOptionsCard(
                    listing: summary.listing,
                    selectedCabinClass: _selectedCabinClass,
                    scheduleLabel: _dateSummary(summary.listing),
                    onCabinChanged: (value) async {
                      if (value == _selectedCabinClass) return;
                      setState(() => _selectedCabinClass = value);
                      await _loadSummary();
                    },
                  ),
                ],
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
                  _travelerInfoTitle(summary.listing.serviceType),
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
                onPressed: (_isSubmitting || !_canSubmitCheckout)
                    ? null
                    : _completeBooking,
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
          const SizedBox(height: 12),
          _buildPointsRedeemCard(pricing, canUsePoints: canUsePoints),
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

  Widget _buildPointsRedeemCard(
    CheckoutPricing pricing, {
    required bool canUsePoints,
  }) {
    final subtitle = canUsePoints
        ? 'Available: ${pricing.pointsAvailableLabel}. Save up to ${pricing.pointsMaxRedeemLabel}.'
        : pricing.pointsAvailable > 0
            ? 'Available: ${pricing.pointsAvailableLabel}. Points cannot reduce this booking.'
            : 'No points available yet. Complete bookings to earn points.';

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: canUsePoints
            ? TripwiseColors.primaryFixed.withOpacity(0.55)
            : TripwiseColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: canUsePoints
              ? TripwiseColors.primaryFixedDim
              : TripwiseColors.outlineVariant,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: canUsePoints
                  ? TripwiseColors.primary
                  : TripwiseColors.surfaceContainerHigh,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.stars_rounded,
              color: canUsePoints
                  ? TripwiseColors.onPrimary
                  : TripwiseColors.outline,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Tripwise Points',
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        fontWeight: FontWeight.w900,
                        color: canUsePoints
                            ? TripwiseColors.onSurface
                            : TripwiseColors.onSurfaceVariant,
                      ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: TripwiseColors.onSurfaceVariant,
                    fontSize: 12,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: _usePoints && canUsePoints,
            onChanged: canUsePoints
                ? (value) => setState(() => _usePoints = value)
                : null,
            activeColor: TripwiseColors.primary,
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
          onChanged: (_) => setState(() {}),
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
        (!summary.listing.dateLocked && !normalizedEnd.isAfter(normalizedStart))) {
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
    if (_bookingType != 'flight' && startOnly.isBefore(today)) {
      return 'Start date cannot be in the past.';
    }
    final maxGuests = _summary?.listing.serviceType == 'flight'
        ? _summary?.listing.availableSeats
        : null;
    if (maxGuests != null && guests > maxGuests) {
      return 'Only $maxGuests seat${maxGuests == 1 ? '' : 's'} available.';
    }
    if (_bookingType == 'hotel' && !endOnly.isAfter(startOnly)) {
      return 'End date must be after start date.';
    }
    if (guests < 1) {
      return 'At least 1 guest is required.';
    }
    return null;
  }

  bool get _canSubmitCheckout {
    if (_summary == null || _isSubmitting) return false;
    if (!_agreeToTerms) return false;
    return _guestValidationMessage() == null;
  }

  String? _guestValidationMessage() {
    final fullName = _fullNameController.text.trim();
    final email = _emailController.text.trim();
    final phone = _phoneController.text.trim();

    if (fullName.isEmpty) {
      return 'Please enter your full name.';
    }
    if (email.isEmpty) {
      return 'Please enter your email address.';
    }
    if (!_isValidEmail(email)) {
      return 'Please enter a valid email address.';
    }
    if (phone.isEmpty) {
      return 'Please enter your phone number.';
    }
    if (!_isValidPhone(phone)) {
      return 'Please enter a valid phone number.';
    }
    return null;
  }

  bool _isValidEmail(String value) {
    final emailRegex = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');
    return emailRegex.hasMatch(value);
  }

  bool _isValidPhone(String value) {
    final digitsOnly = value.replaceAll(RegExp(r'[^0-9]'), '');
    return digitsOnly.length >= 9 && digitsOnly.length <= 15;
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

  String _formatDateTime(String value) {
    final parsed = DateTime.tryParse(value);
    if (parsed == null) return value;
    final local = parsed.toLocal();
    final dateLabel = MaterialLocalizations.of(context).formatShortMonthDay(local);
    final timeLabel = TimeOfDay.fromDateTime(local).format(context);
    return '$dateLabel, $timeLabel';
  }

  String _plural(int value, String singular) {
    return value == 1 ? singular : '${singular}s';
  }

  String get _bookingType {
    final raw = widget.type?.trim().toLowerCase();
    if (raw == 'flight' || raw == 'flights') return 'flight';
    if (raw == 'tour' || raw == 'tours' || raw == 'activity') return 'activity';
    return 'hotel';
  }

  String _quantitySingular(String serviceType) {
    if (serviceType == 'flight') return 'traveler';
    if (serviceType == 'activity') return 'person';
    return 'guest';
  }

  String _unitSummary(CheckoutListing listing) {
    if (listing.serviceType == 'flight') return 'Ticket';
    if (listing.serviceType == 'activity') return 'Tour';
    return '${listing.nights} ${_plural(listing.nights, 'night')}';
  }

  String _dateSummary(CheckoutListing listing) {
    if (listing.serviceType == 'flight') {
      return '${_formatDateTime(listing.startDate)} - ${_formatDateTime(listing.endDate)}';
    }
    if (listing.serviceType == 'activity') {
      return _formatDate(listing.startDate);
    }
    return '${_formatDate(listing.startDate)} - ${_formatDate(listing.endDate)}';
  }

  String _travelerInfoTitle(String serviceType) {
    if (serviceType == 'flight') return 'Traveler Information';
    if (serviceType == 'activity') return 'Participant Information';
    return 'Guest Information';
  }
}

class _BookingTripDetailsCard extends StatelessWidget {
  const _BookingTripDetailsCard({
    required this.serviceType,
    required this.dateLabel,
    required this.nightsLabel,
    required this.guestsLabel,
    required this.quantityTitle,
    required this.dateLocked,
    required this.onEditDates,
    required this.onEditGuests,
  });

  final String serviceType;
  final String dateLabel;
  final String nightsLabel;
  final String guestsLabel;
  final String quantityTitle;
  final bool dateLocked;
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
            eyebrow: serviceType == 'flight' ? 'SCHEDULE' : 'DATES',
            value: dateLabel,
            onTap: dateLocked ? null : onEditDates,
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
                  eyebrow: serviceType == 'hotel' ? 'STAY' : 'TYPE',
                  value: nightsLabel,
                  onTap: dateLocked ? null : onEditDates,
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
                  eyebrow: quantityTitle.toUpperCase(),
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

class _FlightBookingOptionsCard extends StatelessWidget {
  const _FlightBookingOptionsCard({
    required this.listing,
    required this.selectedCabinClass,
    required this.scheduleLabel,
    required this.onCabinChanged,
  });

  final CheckoutListing listing;
  final String selectedCabinClass;
  final String scheduleLabel;
  final ValueChanged<String> onCabinChanged;

  @override
  Widget build(BuildContext context) {
    final departureCode = listing.departureAirportCode ?? 'DEP';
    final arrivalCode = listing.arrivalAirportCode ?? 'ARR';
    final availableSeats = listing.availableSeats;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: TripwiseColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: TripwiseColors.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: TripwiseColors.primary,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.flight_takeoff_rounded,
                  color: TripwiseColors.onPrimary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      listing.airlineName ?? 'Selected airline',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w900,
                          ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${listing.flightNumber ?? 'Flight'} - $scheduleLabel',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
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
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _FlightAirportBlock(
                  code: departureCode,
                  label: listing.departureAirportName ?? departureCode,
                  alignEnd: false,
                ),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 10),
                child: Icon(
                  Icons.arrow_forward_rounded,
                  color: TripwiseColors.primary,
                ),
              ),
              Expanded(
                child: _FlightAirportBlock(
                  code: arrivalCode,
                  label: listing.arrivalAirportName ?? arrivalCode,
                  alignEnd: true,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          if (availableSeats != null)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: TripwiseColors.primaryFixed.withOpacity(0.45),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '$availableSeats seat${availableSeats == 1 ? '' : 's'} available',
                style: const TextStyle(
                  color: TripwiseColors.primary,
                  fontWeight: FontWeight.w800,
                  fontSize: 12,
                ),
              ),
            ),
          const SizedBox(height: 14),
          Text(
            'Cabin class',
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w900,
                ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _CabinChoice(
                  title: 'Economy',
                  subtitle: 'Standard fare',
                  value: 'economy',
                  groupValue: selectedCabinClass,
                  onChanged: onCabinChanged,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _CabinChoice(
                  title: 'Business',
                  subtitle: 'Higher fare',
                  value: 'business',
                  groupValue: selectedCabinClass,
                  onChanged: onCabinChanged,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _FlightAirportBlock extends StatelessWidget {
  const _FlightAirportBlock({
    required this.code,
    required this.label,
    required this.alignEnd,
  });

  final String code;
  final String label;
  final bool alignEnd;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment:
          alignEnd ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        Text(
          code,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w900,
                color: TripwiseColors.onSurface,
              ),
        ),
        const SizedBox(height: 3),
        Text(
          label,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          textAlign: alignEnd ? TextAlign.right : TextAlign.left,
          style: const TextStyle(
            color: TripwiseColors.onSurfaceVariant,
            fontSize: 12,
            height: 1.25,
          ),
        ),
      ],
    );
  }
}

class _CabinChoice extends StatelessWidget {
  const _CabinChoice({
    required this.title,
    required this.subtitle,
    required this.value,
    required this.groupValue,
    required this.onChanged,
  });

  final String title;
  final String subtitle;
  final String value;
  final String groupValue;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final selected = value == groupValue;
    return InkWell(
      onTap: () => onChanged(value),
      borderRadius: BorderRadius.circular(14),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: selected
              ? TripwiseColors.primaryFixed
              : TripwiseColors.surfaceContainerLow,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected
                ? TripwiseColors.primary
                : TripwiseColors.outlineVariant,
            width: selected ? 2 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  selected
                      ? Icons.radio_button_checked_rounded
                      : Icons.radio_button_unchecked_rounded,
                  size: 18,
                  color: selected
                      ? TripwiseColors.primary
                      : TripwiseColors.onSurfaceVariant,
                ),
                const SizedBox(width: 7),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(fontWeight: FontWeight.w900),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 5),
            Text(
              subtitle,
              style: const TextStyle(
                color: TripwiseColors.onSurfaceVariant,
                fontSize: 12,
              ),
            ),
          ],
        ),
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
  final VoidCallback? onTap;

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
            if (onTap != null)
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
  final VoidCallback? onTap;

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
    this.max,
    required this.onChanged,
  });

  final String label;
  final int value;
  final int min;
  final int? max;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    final canAdd = max == null || value < max!;
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
          style: IconButton.styleFrom(
            backgroundColor: TripwiseColors.primaryFixedDim,
            foregroundColor: TripwiseColors.primary,
            disabledBackgroundColor: TripwiseColors.surfaceContainerHigh,
            disabledForegroundColor: TripwiseColors.outline,
          ),
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
          onPressed: canAdd ? () => onChanged(value + 1) : null,
          style: IconButton.styleFrom(
            backgroundColor: TripwiseColors.primary,
            foregroundColor: TripwiseColors.onPrimary,
            disabledBackgroundColor: TripwiseColors.surfaceContainerHigh,
            disabledForegroundColor: TripwiseColors.outline,
          ),
          icon: const Icon(Icons.add_rounded),
        ),
      ],
    );
  }
}
