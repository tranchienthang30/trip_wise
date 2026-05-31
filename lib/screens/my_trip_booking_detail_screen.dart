import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:printing/printing.dart';

import '../constants/colors.dart';
import '../models/my_trip_detail.dart';
import '../services/my_trips_api.dart';
import '../utils/eticket_pdf.dart';
import '../widgets/review_card.dart';
import '../widgets/shared_taskbars.dart';
import '../widgets/shared_top_bars.dart';
import '../widgets/tripwise_network_image.dart';

class MyTripBookingDetailScreen extends StatefulWidget {
  const MyTripBookingDetailScreen({
    super.key,
    required this.bookingItemId,
  });

  final String bookingItemId;

  @override
  State<MyTripBookingDetailScreen> createState() =>
      _MyTripBookingDetailScreenState();
}

String _myTripDetailImageSeed(MyTripDetail detail) {
  if (detail.serviceType == 'hotel' && detail.hotelId != null && detail.hotelId! > 0) {
    return 'hotel-${detail.hotelId}';
  }
  final image = detail.imageUrl.trim();
  if (image.isNotEmpty) return '${detail.serviceType}-image-$image';
  return '${detail.serviceType}-${detail.id}';
}

class _MyTripBookingDetailScreenState
    extends State<MyTripBookingDetailScreen> {
  final MyTripsApi _api = MyTripsApi();

  late Future<MyTripDetail> _future;
  MyTripDetail? _detail;
  bool _isCancelling = false;
  bool _isSubmittingReview = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() {
    _future = _api.fetchTripDetail(widget.bookingItemId);
    _future.then((detail) {
      if (!mounted) return;
      setState(() => _detail = detail);
    }).catchError((_) {});
  }

  void _retry() {
    setState(() {
      _detail = null;
      _load();
    });
  }

  Future<void> _refreshDetail() async {
    _retry();
    try {
      await _future;
    } catch (_) {}
  }

  Future<void> _requestCancel() async {
    final detail = _detail;
    if (detail == null ||
        !detail.canCancel ||
        detail.isCancellationPending ||
        _isCancelling) {
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Request cancellation?'),
        content: Text(
          detail.cancelDeadlineLabel == null
              ? 'Admin will review this cancellation before refunding your wallet.'
              : 'Admin will review this cancellation before refunding your wallet. Deadline: ${detail.cancelDeadlineLabel}.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Keep booking'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TripwiseButtonStyles.primaryElevated(radius: 8),
            child: const Text('Request cancel'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    setState(() => _isCancelling = true);
    try {
      final message = await _api.cancelTrip(detail.id);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: TripwiseColors.primary,
        ),
      );
      _retry();
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error.toString()),
          backgroundColor: TripwiseColors.error,
        ),
      );
    } finally {
      if (mounted) setState(() => _isCancelling = false);
    }
  }

  Future<void> _openProviderChat() async {
    final detail = _detail;
    final orderId = detail?.id.trim() ?? '';
    final query = orderId.isEmpty
        ? 'mode=user'
        : 'mode=user&orderId=${Uri.encodeQueryComponent(orderId)}';
    await context.push('/direct_messaging?$query');
  }

  Future<void> _downloadTicket() async {
    final detail = _detail;
    if (detail == null) return;
    if (!detail.hasTicketCode && detail.bookingId.trim().isEmpty) {
      _showSnackBar('E-ticket is not available yet.', isError: true);
      return;
    }

    try {
      final bytes = await buildMyTripETicketPdfBytes(detail);
      final identifier = detail.hasTicketCode ? detail.ticketCode : detail.bookingId;
      await Printing.sharePdf(
        bytes: bytes,
        filename: 'tripwise-eticket-$identifier.pdf',
      );
    } catch (error) {
      _showSnackBar('Could not generate e-ticket: $error', isError: true);
    }
  }

  Future<void> _submitReview(int rating, String comment) async {
    final detail = _detail;
    if (detail == null || !detail.canReview || _isSubmittingReview) return;

    setState(() => _isSubmittingReview = true);
    try {
      await _api.submitReview(
        bookingItemId: detail.id,
        rating: rating,
        comment: comment,
      );
      if (!mounted) return;
      _showSnackBar('Review submitted. Thank you for the feedback.');
      _retry();
    } catch (error) {
      if (!mounted) return;
      _showSnackBar(error.toString(), isError: true);
    } finally {
      if (mounted) setState(() => _isSubmittingReview = false);
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    if (!mounted) return;
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TripwiseColors.surface,
      appBar: PlannerAppBar(
        backRoute: '/my_trips',
        titleText: 'Booking Details',
        onBack: () {
          if (context.canPop()) {
            context.pop();
          } else {
            context.go('/my_trips');
          }
        },
      ),
      body: FutureBuilder<MyTripDetail>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return _DetailErrorView(error: snapshot.error, onRetry: _retry);
          }
          final detail = snapshot.data!;
          return _BookingDetailBody(
            detail: detail,
            isCancelling: _isCancelling,
            onRefresh: _refreshDetail,
            onRequestCancel: _requestCancel,
            onMessageProvider: _openProviderChat,
            onDownloadTicket: _downloadTicket,
            onSubmitReview: _submitReview,
            isSubmittingReview: _isSubmittingReview,
          );
        },
      ),
      bottomNavigationBar: const PlannerTaskbar(
        currentTab: PlannerTaskbarTab.myTrips,
      ),
    );
  }
}

class _BookingDetailBody extends StatelessWidget {
  const _BookingDetailBody({
    required this.detail,
    required this.isCancelling,
    required this.onRefresh,
    required this.onRequestCancel,
    required this.onMessageProvider,
    required this.onDownloadTicket,
    required this.onSubmitReview,
    required this.isSubmittingReview,
  });

  final MyTripDetail detail;
  final bool isCancelling;
  final Future<void> Function() onRefresh;
  final VoidCallback onRequestCancel;
  final VoidCallback onMessageProvider;
  final VoidCallback onDownloadTicket;
  final Future<void> Function(int rating, String comment) onSubmitReview;
  final bool isSubmittingReview;

  @override
  Widget build(BuildContext context) {
    final detailTiles = [
      _DetailTileData(
        icon: Icons.login_rounded,
        label: detail.startDateTitle,
        value: detail.startDateLabel,
      ),
      _DetailTileData(
        icon: Icons.logout_rounded,
        label: detail.endDateTitle,
        value: detail.endDateLabel,
      ),
      _DetailTileData(
        icon: Icons.group_rounded,
        label: detail.quantityTitle,
        value: detail.quantityLabel,
      ),
      if (detail.serviceType == 'hotel')
        _DetailTileData(
          icon: Icons.nights_stay_rounded,
          label: 'Nights',
          value: detail.nightsLabel,
        ),
      if (detail.hasTicketCode)
        _DetailTileData(
          icon: Icons.confirmation_number_rounded,
          label: 'Ticket code',
          value: detail.ticketCode,
        ),
      if (detail.serviceType == 'flight' &&
          (detail.airlineName ?? '').trim().isNotEmpty)
        _DetailTileData(
          icon: Icons.flight_rounded,
          label: 'Airline',
          value: detail.airlineName!,
        ),
      if (detail.serviceType == 'flight' &&
          (detail.cabinClass ?? '').trim().isNotEmpty)
        _DetailTileData(
          icon: Icons.airline_seat_recline_extra_rounded,
          label: 'Cabin',
          value: detail.cabinClass!,
        ),
      if (detail.serviceType == 'flight' && detail.seatNumbers.isNotEmpty)
        _DetailTileData(
          icon: Icons.event_seat_rounded,
          label: 'Seat${detail.seatNumbers.length == 1 ? '' : 's'}',
          value: detail.seatNumbers.join(', '),
        ),
      _DetailTileData(
        icon: Icons.receipt_long_rounded,
        label: 'Booking ID',
        value: detail.bookingId.length > 4
            ? detail.bookingId.substring(0, 4)
            : detail.bookingId,
      ),
    ];

    return RefreshIndicator(
      onRefresh: onRefresh,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: TripwiseInsets.screen,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _HeroImage(
              url: detail.imageUrl,
              fallbackSeed: _myTripDetailImageSeed(detail),
            ),
            const SizedBox(height: 18),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        detail.title,
                        style: Theme.of(context)
                            .textTheme
                            .headlineSmall
                            ?.copyWith(fontWeight: FontWeight.w900),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        detail.subtitle,
                        style: const TextStyle(
                          color: TripwiseColors.onSurfaceVariant,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                _StatusChip(label: detail.statusLabel, status: detail.status),
              ],
            ),
            if (detail.locationLabel.trim().isNotEmpty) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  const Icon(
                    Icons.place_rounded,
                    color: TripwiseColors.primary,
                    size: 18,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      detail.locationLabel,
                      style: const TextStyle(
                        color: TripwiseColors.onSurfaceVariant,
                      ),
                    ),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 18),
            _SummaryStrip(detail: detail),
            const SizedBox(height: 24),
            const _SectionTitle('Trip details'),
            const SizedBox(height: 10),
            _DetailTileWrap(items: detailTiles),
            const SizedBox(height: 24),
            const _SectionTitle('Payment'),
            const SizedBox(height: 10),
            _PaymentCard(detail: detail),
            if (detail.serviceType == 'hotel' &&
                detail.status == 'completed') ...[
              const SizedBox(height: 24),
              const _SectionTitle('Your review'),
              const SizedBox(height: 10),
              _ReviewActionCard(
                detail: detail,
                isSubmitting: isSubmittingReview,
                onSubmitReview: onSubmitReview,
              ),
            ],
            if (detail.hasTicketCode) ...[
              const SizedBox(height: 14),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: onDownloadTicket,
                  style: TripwiseButtonStyles.primaryElevated(
                    radius: 8,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  icon: const Icon(Icons.download_rounded, size: 18),
                  label: const Text(
                    'Download e-ticket',
                    style: TextStyle(fontWeight: FontWeight.w800),
                  ),
                ),
              ),
            ],
            if (detail.status != 'completed') ...[
              const SizedBox(height: 24),
              const _SectionTitle('Cancellation'),
              const SizedBox(height: 10),
              _CancellationCard(
                detail: detail,
                isCancelling: isCancelling,
                onRequestCancel: onRequestCancel,
              ),
            ],
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: onMessageProvider,
                style: TripwiseButtonStyles.outlined(
                  radius: 8,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  foregroundColor: TripwiseColors.primary,
                  borderColor: TripwiseColors.primary,
                ),
                icon: const Icon(Icons.chat_bubble_rounded, size: 18),
                label: const Text(
                  'Message provider',
                  style: TextStyle(fontWeight: FontWeight.w800),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryStrip extends StatelessWidget {
  const _SummaryStrip({required this.detail});

  final MyTripDetail detail;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final stacked = constraints.maxWidth < 360;
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: TripwiseColors.primary,
            borderRadius: BorderRadius.circular(8),
          ),
          child: stacked
              ? Column(
                  children: [
                    _SummaryItem(
                      label: 'Dates',
                      value: detail.dateLabel,
                      icon: Icons.calendar_month_rounded,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: Container(
                        width: double.infinity,
                        height: 1,
                        color: TripwiseColors.onPrimary.withValues(alpha: 0.24),
                      ),
                    ),
                    _SummaryItem(
                      label: 'Total',
                      value: detail.totalAmountLabel,
                      icon: Icons.payments_rounded,
                    ),
                  ],
                )
              : Row(
                  children: [
                    Expanded(
                      flex: 6,
                      child: _SummaryItem(
                        label: 'Dates',
                        value: detail.dateLabel,
                        icon: Icons.calendar_month_rounded,
                      ),
                    ),
                    Container(
                      width: 1,
                      height: 40,
                      color: TripwiseColors.onPrimary.withValues(alpha: 0.24),
                    ),
                    Expanded(
                      flex: 4,
                      child: _SummaryItem(
                        label: 'Total',
                        value: detail.totalAmountLabel,
                        icon: Icons.payments_rounded,
                      ),
                    ),
                  ],
                ),
        );
      },
    );
  }
}

class _SummaryItem extends StatelessWidget {
  const _SummaryItem({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6),
      child: Row(
        children: [
          Icon(icon, color: TripwiseColors.onPrimary, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    color: TripwiseColors.onPrimary,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                SizedBox(
                  width: double.infinity,
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Text(
                      value,
                      maxLines: 1,
                      softWrap: false,
                      style: const TextStyle(
                        color: TripwiseColors.onPrimary,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PaymentCard extends StatelessWidget {
  const _PaymentCard({required this.detail});

  final MyTripDetail detail;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: TripwiseColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: TripwiseColors.outlineVariant),
      ),
      child: Column(
        children: [
          _MoneyRow(
            label: detail.pricePerUnitTitle,
            value: detail.pricePerUnitLabel,
          ),
          const SizedBox(height: 10),
          _MoneyRow(label: detail.quantityTitle, value: detail.quantityLabel),
          const SizedBox(height: 12),
          const Divider(height: 1),
          const SizedBox(height: 12),
          _MoneyRow(
            label: 'Total paid',
            value: detail.totalAmountLabel,
            isTotal: true,
          ),
          const SizedBox(height: 10),
          _MoneyRow(label: 'Booked on', value: detail.bookingCreatedAtLabel),
        ],
      ),
    );
  }
}

class _ReviewActionCard extends StatelessWidget {
  const _ReviewActionCard({
    required this.detail,
    required this.isSubmitting,
    required this.onSubmitReview,
  });

  final MyTripDetail detail;
  final bool isSubmitting;
  final Future<void> Function(int rating, String comment) onSubmitReview;

  Future<void> _openComposer(BuildContext context) async {
    final result = await showModalBottomSheet<({int rating, String comment})>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _ReviewComposerSheet(hotelName: detail.title),
    );
    if (result == null) return;
    await onSubmitReview(result.rating, result.comment);
  }

  @override
  Widget build(BuildContext context) {
    final review = detail.myReview;
    if (review != null) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: TripwiseColors.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: TripwiseColors.outlineVariant),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                ReviewStars(rating: review.rating, size: 18),
                const Spacer(),
                const Text(
                  'Submitted',
                  style: TextStyle(
                    color: TripwiseColors.primary,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              review.comment,
              style: const TextStyle(
                color: TripwiseColors.onSurface,
                height: 1.4,
              ),
            ),
          ],
        ),
      );
    }

    if (!detail.canReview) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: TripwiseColors.surfaceContainerLow,
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Text(
          'This completed hotel booking is not eligible for another review.',
          style: TextStyle(color: TripwiseColors.onSurfaceVariant),
        ),
      );
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: TripwiseColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: TripwiseColors.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Rate this completed stay so other travelers can decide with real feedback.',
            style: TextStyle(
              color: TripwiseColors.onSurfaceVariant,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: isSubmitting ? null : () => _openComposer(context),
              style: TripwiseButtonStyles.primaryElevated(
                radius: 8,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              icon: isSubmitting
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: TripwiseColors.onPrimary,
                      ),
                    )
                  : const Icon(Icons.rate_review_rounded, size: 18),
              label: Text(isSubmitting ? 'Submitting' : 'Write a review'),
            ),
          ),
        ],
      ),
    );
  }
}

class _ReviewComposerSheet extends StatefulWidget {
  const _ReviewComposerSheet({required this.hotelName});

  final String hotelName;

  @override
  State<_ReviewComposerSheet> createState() => _ReviewComposerSheetState();
}

class _ReviewComposerSheetState extends State<_ReviewComposerSheet> {
  final TextEditingController _commentController = TextEditingController();
  int _rating = 5;

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  void _submit() {
    final comment = _commentController.text.trim();
    if (comment.length < 3) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please write a short review comment.')),
      );
      return;
    }
    Navigator.of(context).pop((rating: _rating, comment: comment));
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: Container(
        margin: const EdgeInsets.all(12),
        padding: const EdgeInsets.fromLTRB(18, 12, 18, 18),
        decoration: BoxDecoration(
          color: TripwiseColors.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(20),
        ),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: TripwiseColors.outlineVariant,
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Review ${widget.hotelName}',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  for (int i = 1; i <= 5; i++)
                    IconButton(
                      onPressed: () => setState(() => _rating = i),
                      icon: Icon(
                        i <= _rating
                            ? Icons.star_rounded
                            : Icons.star_outline_rounded,
                        color: TripwiseColors.secondary,
                        size: 30,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _commentController,
                minLines: 3,
                maxLines: 5,
                maxLength: 1000,
                textInputAction: TextInputAction.newline,
                decoration: InputDecoration(
                  hintText: 'Share what went well or what could be better',
                  filled: true,
                  fillColor: TripwiseColors.surfaceContainerLow,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(
                      color: TripwiseColors.outlineVariant,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(
                      color: TripwiseColors.outlineVariant,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _submit,
                  style: TripwiseButtonStyles.primaryElevated(
                    radius: 8,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: const Text('Submit review'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CancellationCard extends StatelessWidget {
  const _CancellationCard({
    required this.detail,
    required this.isCancelling,
    required this.onRequestCancel,
  });

  final MyTripDetail detail;
  final bool isCancelling;
  final VoidCallback onRequestCancel;

  @override
  Widget build(BuildContext context) {
    final bool showCancelButton =
        detail.canCancel && !detail.isCancellationPending;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: detail.isCancellationPending
            ? TripwiseColors.primaryFixed
            : TripwiseColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: detail.isCancellationPending
              ? TripwiseColors.primaryFixedDim
              : TripwiseColors.outlineVariant,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                detail.isCancellationPending
                    ? Icons.hourglass_top_rounded
                    : Icons.assignment_return_rounded,
                color: detail.isCancellationPending
                    ? TripwiseColors.onPrimaryFixedVariant
                    : TripwiseColors.error,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  detail.cancellationPolicyLabel,
                  style: TextStyle(
                    color: detail.isCancellationPending
                        ? TripwiseColors.onPrimaryFixedVariant
                        : TripwiseColors.onSurfaceVariant,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          if (showCancelButton) ...[
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: isCancelling ? null : onRequestCancel,
                style: TripwiseButtonStyles.destructiveOutlined(
                  radius: 8,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                icon: isCancelling
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.cancel_schedule_send_rounded, size: 18),
                label: Text(
                  isCancelling ? 'Sending request' : 'Request cancellation',
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _DetailTileWrap extends StatelessWidget {
  const _DetailTileWrap({required this.items});

  final List<_DetailTileData> items;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        const spacing = 10.0;
        final tileWidth = (constraints.maxWidth - spacing) / 2;
        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: [
            for (final item in items)
              SizedBox(
                width: tileWidth < 156 ? constraints.maxWidth : tileWidth,
                child: _DetailTile(data: item),
              ),
          ],
        );
      },
    );
  }
}

class _DetailTile extends StatelessWidget {
  const _DetailTile({required this.data});

  final _DetailTileData data;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 104),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: TripwiseColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: TripwiseColors.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(data.icon, color: TripwiseColors.primary, size: 20),
          const SizedBox(height: 10),
          Text(
            data.label,
            style: const TextStyle(
              color: TripwiseColors.onSurfaceVariant,
              fontSize: 11,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            data.value,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: TripwiseColors.onSurface,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailTileData {
  const _DetailTileData({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;
}

class _MoneyRow extends StatelessWidget {
  const _MoneyRow({
    required this.label,
    required this.value,
    this.isTotal = false,
  });

  final String label;
  final String value;
  final bool isTotal;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              color: isTotal
                  ? TripwiseColors.onSurface
                  : TripwiseColors.onSurfaceVariant,
              fontWeight: isTotal ? FontWeight.w900 : FontWeight.w600,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: TextStyle(
              color: isTotal
                  ? TripwiseColors.primary
                  : TripwiseColors.onSurface,
              fontSize: isTotal ? 18 : 14,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
      ],
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.title);

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w900,
          ),
    );
  }
}

class _HeroImage extends StatelessWidget {
  const _HeroImage({required this.url, required this.fallbackSeed});

  final String url;
  final String fallbackSeed;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: AspectRatio(
        aspectRatio: 16 / 9,
        child: TripwiseNetworkImage(
          imageUrl: url,
          fallbackSeed: fallbackSeed,
          fit: BoxFit.cover,
          placeholderColor: TripwiseColors.surfaceContainerLow,
        ),
      ),
    );
  }
}

class _ImageFallback extends StatelessWidget {
  const _ImageFallback({
    required this.icon,
    this.showSpinner = false,
  });

  final IconData icon;
  final bool showSpinner;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: TripwiseColors.surfaceContainer,
      alignment: Alignment.center,
      child: showSpinner
          ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : Icon(icon, color: TripwiseColors.onSurfaceVariant, size: 34),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.label, required this.status});

  final String label;
  final String status;

  @override
  Widget build(BuildContext context) {
    final Color background;
    final Color foreground;
    if (status == 'cancelled') {
      background = TripwiseColors.error.withValues(alpha: 0.1);
      foreground = TripwiseColors.error;
    } else {
      background = TripwiseColors.primaryFixed;
      foreground = TripwiseColors.onPrimaryFixedVariant;
    }

    return Container(
      constraints: const BoxConstraints(maxWidth: 132),
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          color: foreground,
          fontSize: 11,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _DetailErrorView extends StatelessWidget {
  const _DetailErrorView({required this.error, required this.onRetry});

  final Object? error;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.cloud_off_rounded,
              size: 44,
              color: TripwiseColors.onSurfaceVariant,
            ),
            const SizedBox(height: 12),
            const Text(
              "Couldn't load booking",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 6),
            Text(
              error?.toString() ?? 'Unknown error',
              textAlign: TextAlign.center,
              style: const TextStyle(color: TripwiseColors.onSurfaceVariant),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: onRetry,
              style: TripwiseButtonStyles.primaryElevated(radius: 8),
              child: const Text('Try again'),
            ),
          ],
        ),
      ),
    );
  }
}
