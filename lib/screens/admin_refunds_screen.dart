import 'package:flutter/material.dart';

import '../constants/colors.dart';
import '../models/admin_cancellation.dart';
import '../services/admin_api.dart';
import '../widgets/shared_taskbars.dart';

class AdminRefundsScreen extends StatefulWidget {
  const AdminRefundsScreen({super.key});

  @override
  State<AdminRefundsScreen> createState() => _AdminRefundsScreenState();
}

class _AdminRefundsScreenState extends State<AdminRefundsScreen> {
  final AdminApi _api = AdminApi();
  final TextEditingController _ticketCodeController = TextEditingController();
  final Set<String> _reviewingIds = {};

  AdminCancellationRequestsResponse? _data;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _ticketCodeController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final data = await _api.fetchCancellationRequests();
      if (!mounted) return;
      setState(() {
        _data = data;
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

  Future<void> _review(
    AdminCancellationRequest request,
    bool approve,
  ) async {
    if (_reviewingIds.contains(request.id)) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(approve ? 'Confirm refund?' : 'Reject request?'),
        content: Text(
          approve
              ? 'Refund ${request.displayAmount} to ${request.userName}. This will move money from the admin held wallet back to the user wallet.'
              : 'Reject this cancellation request and keep the booking active.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: approve
                ? TripwiseButtonStyles.primaryElevated(radius: 8)
                : TripwiseButtonStyles.accentElevated(radius: 8, elevation: 0),
            child: Text(approve ? 'Refund now' : 'Reject'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    setState(() => _reviewingIds.add(request.id));
    try {
      await _api.reviewCancellation(
        bookingItemId: request.id,
        approve: approve,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            approve
                ? 'Refunded ${request.displayAmount} to ${request.userName}.'
                : 'Rejected cancellation for ${request.userName}.',
          ),
          backgroundColor:
              approve ? TripwiseColors.primary : TripwiseColors.error,
        ),
      );
      await _load();
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error.toString()),
          backgroundColor: TripwiseColors.error,
        ),
      );
    } finally {
      if (mounted) setState(() => _reviewingIds.remove(request.id));
    }
  }

  Future<void> _lookupTicket() async {
    final code = _ticketCodeController.text.trim();
    if (code.isEmpty) return;

    try {
      final order = await _api.lookupTicket(code);
      if (!mounted) return;
      showDialog<void>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(order.ticketCode.isEmpty ? 'Ticket found' : order.ticketCode),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(order.title, style: const TextStyle(fontWeight: FontWeight.w900)),
              const SizedBox(height: 8),
              Text('${order.serviceType.toUpperCase()} - ${order.statusLabel}'),
              const SizedBox(height: 6),
              Text(order.dates),
              const SizedBox(height: 6),
              Text('Guest: ${order.guestName}'),
              const SizedBox(height: 6),
              Text('Booking: ${order.bookingId}'),
              const SizedBox(height: 6),
              Text('Total: ${order.displayPrice}'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
          ],
        ),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error.toString()),
          backgroundColor: TripwiseColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final data = _data;
    final requests = data?.requests ?? const <AdminCancellationRequest>[];

    return Scaffold(
      backgroundColor: TripwiseColors.surface,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        automaticallyImplyLeading: false,
        titleSpacing: 20,
        title: Text(
          'TRIP WISE ADMIN',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: TripwiseColors.primary,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _load,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: TripwiseInsets.screen,
          children: [
            _TicketLookupField(
              controller: _ticketCodeController,
              onSubmit: _lookupTicket,
            ),
            const SizedBox(height: 16),
            if (_isLoading && data == null)
              const Padding(
                padding: EdgeInsets.only(top: 120),
                child: Center(child: CircularProgressIndicator()),
              )
            else if (_error != null && data == null)
              _ErrorState(message: _error!, onRetry: _load)
            else ...[
              _RefundSummary(data: data),
              const SizedBox(height: 14),
              if (requests.isEmpty)
                const _EmptyRefunds()
              else
                ...requests.map(
                  (request) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: _RefundRequestTile(
                      request: request,
                      isReviewing: _reviewingIds.contains(request.id),
                      onApprove: () => _review(request, true),
                      onReject: () => _review(request, false),
                    ),
                  ),
                ),
              if (_error != null) ...[
                const SizedBox(height: 4),
                _InlineError(message: _error!, onRetry: _load),
              ],
            ],
          ],
        ),
      ),
      bottomNavigationBar: const AdminTaskbar(
        currentTab: AdminTaskbarTab.refunds,
      ),
    );
  }
}

class _RefundSummary extends StatelessWidget {
  const _RefundSummary({required this.data});

  final AdminCancellationRequestsResponse? data;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: TripwiseColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: TripwiseColors.outlineVariant),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: TripwiseColors.primaryFixed,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.assignment_return_rounded,
              color: TripwiseColors.primary,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${data?.pendingCount ?? 0} pending refund(s)',
                  style: const TextStyle(fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 3),
                Text(
                  data?.displayTotalRefundAmount ?? '\$0',
                  style: const TextStyle(
                    color: TripwiseColors.onSurfaceVariant,
                    fontWeight: FontWeight.w700,
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

class _TicketLookupField extends StatelessWidget {
  const _TicketLookupField({
    required this.controller,
    required this.onSubmit,
  });

  final TextEditingController controller;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      textInputAction: TextInputAction.search,
      onSubmitted: (_) => onSubmit(),
      decoration: InputDecoration(
        hintText: 'Check any booking by e-ticket code',
        prefixIcon: const Icon(Icons.confirmation_number_rounded),
        suffixIcon: IconButton(
          onPressed: onSubmit,
          icon: const Icon(Icons.search_rounded),
        ),
        filled: true,
        fillColor: TripwiseColors.surfaceContainerLowest,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: TripwiseColors.outlineVariant),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: TripwiseColors.outlineVariant),
        ),
      ),
    );
  }
}

class _RefundRequestTile extends StatelessWidget {
  const _RefundRequestTile({
    required this.request,
    required this.isReviewing,
    required this.onApprove,
    required this.onReject,
  });

  final AdminCancellationRequest request;
  final bool isReviewing;
  final VoidCallback onApprove;
  final VoidCallback onReject;

  @override
  Widget build(BuildContext context) {
    return Container(
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      request.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      request.subtitle.isEmpty
                          ? request.dateLabel
                          : request.subtitle,
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
              const SizedBox(width: 10),
              Text(
                request.displayAmount,
                style: const TextStyle(
                  color: TripwiseColors.primary,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _InfoLine(
            icon: Icons.person_rounded,
            label: 'User',
            value: request.userEmail == null
                ? request.userName
                : '${request.userName} - ${request.userEmail}',
          ),
          _InfoLine(
            icon: Icons.storefront_rounded,
            label: 'Provider',
            value: request.providerName,
          ),
          _InfoLine(
            icon: Icons.date_range_rounded,
            label: 'Stay',
            value: request.dateLabel,
          ),
          if (request.cancelDeadline != null)
            _InfoLine(
              icon: Icons.timer_rounded,
              label: 'Deadline',
              value: _shortDate(request.cancelDeadline!),
            ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: isReviewing ? null : onReject,
                  style: TripwiseButtonStyles.destructiveOutlined(
                    radius: 8,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  icon: const Icon(Icons.close_rounded, size: 18),
                  label: const Text('Reject'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: isReviewing ? null : onApprove,
                  style: TripwiseButtonStyles.primaryElevated(
                    radius: 8,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  icon: isReviewing
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: TripwiseColors.onPrimary,
                          ),
                        )
                      : const Icon(Icons.payments_rounded, size: 18),
                  label: const Text('Refund'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  static String _shortDate(String raw) {
    final parsed = DateTime.tryParse(raw);
    if (parsed == null) return raw;
    return '${parsed.year}-${parsed.month.toString().padLeft(2, '0')}-${parsed.day.toString().padLeft(2, '0')}';
  }
}

class _InfoLine extends StatelessWidget {
  const _InfoLine({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 7),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 17, color: TripwiseColors.primary),
          const SizedBox(width: 8),
          Text('$label: ', style: const TextStyle(fontWeight: FontWeight.w900)),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(color: TripwiseColors.onSurfaceVariant),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyRefunds extends StatelessWidget {
  const _EmptyRefunds();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.only(top: 90),
      child: Center(
        child: Text(
          'No pending refund confirmations.',
          style: TextStyle(
            color: TripwiseColors.onSurfaceVariant,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 96),
      child: Column(
        children: [
          const Icon(
            Icons.cloud_off_rounded,
            size: 44,
            color: TripwiseColors.onSurfaceVariant,
          ),
          const SizedBox(height: 12),
          const Text(
            "Couldn't load refunds",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 8),
          Text(message, textAlign: TextAlign.center),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: onRetry,
            style: TripwiseButtonStyles.primaryElevated(radius: 8),
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}

class _InlineError extends StatelessWidget {
  const _InlineError({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: TripwiseColors.errorContainer,
        borderRadius: BorderRadius.circular(8),
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
              ),
            ),
          ),
          TextButton(
            onPressed: onRetry,
            style: TripwiseButtonStyles.text(
              foregroundColor: TripwiseColors.onErrorContainer,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            ),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}
