import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../constants/colors.dart';
import '../models/payment_success.dart';
import '../services/payments_api.dart';

class PaymentSuccessScreen extends StatefulWidget {
  const PaymentSuccessScreen({
    super.key,
    this.bookingId,
    this.paymentId,
  });

  final String? bookingId;
  final String? paymentId;

  @override
  State<PaymentSuccessScreen> createState() => _PaymentSuccessScreenState();
}

class _PaymentSuccessScreenState extends State<PaymentSuccessScreen> {
  final PaymentsApi _api = PaymentsApi();
  late Future<PaymentSuccess> _future;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  @override
  void didUpdateWidget(covariant PaymentSuccessScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.bookingId != widget.bookingId ||
        oldWidget.paymentId != widget.paymentId) {
      _future = _load();
    }
  }

  Future<PaymentSuccess> _load() {
    return _api.fetchPaymentSuccess(
      bookingId: widget.bookingId,
      paymentId: widget.paymentId,
    );
  }

  void _retry() {
    setState(() {
      _future = _load();
    });
  }

  Future<void> _downloadTicket(PaymentSuccess data) async {
    if (data.ticket.downloadUrl.isEmpty) {
      _showSnackBar('E-ticket is not available yet.');
      return;
    }

    final opened = await launchUrl(
      _api.ticketUri(data.ticket.downloadUrl),
      mode: LaunchMode.externalApplication,
    );

    if (!opened) {
      _showSnackBar('Could not open e-ticket.');
    }
  }

  void _showSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TripwiseColors.surface,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close),
          color: TripwiseColors.onSurface,
          onPressed: () {
            final bookingId = widget.bookingId;
            if (bookingId == null || bookingId.isEmpty) {
              context.go('/my_trips');
              return;
            }
            context.go('/my_trips?bookingId=${Uri.encodeQueryComponent(bookingId)}');
          },
        ),
        title: Text(
          'Tripwise',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w900,
              ),
        ),
        centerTitle: true,
      ),
      body: FutureBuilder<PaymentSuccess>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError || !snapshot.hasData) {
            return _PaymentErrorView(
              error: snapshot.error,
              onRetry: _retry,
            );
          }

          return _PaymentSuccessContent(
            data: snapshot.data!,
            onDownloadTicket: () => _downloadTicket(snapshot.data!),
          );
        },
      ),
    );
  }
}

class _PaymentSuccessContent extends StatelessWidget {
  const _PaymentSuccessContent({
    required this.data,
    required this.onDownloadTicket,
  });

  final PaymentSuccess data;
  final VoidCallback onDownloadTicket;

  bool get _isConfirmed {
    final status = data.statusLabel.toUpperCase();
    return status == 'CONFIRMED' || status == 'COMPLETED';
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                decoration: BoxDecoration(
                  color: TripwiseColors.primaryFixed.withOpacity(0.12),
                  shape: BoxShape.circle,
                ),
                padding: const EdgeInsets.all(20),
                child: Icon(
                  _isConfirmed ? Icons.check_circle : Icons.schedule_rounded,
                  size: 56,
                  color: TripwiseColors.primary,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                _isConfirmed ? 'Booking Successful!' : 'Booking Received',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                data.message,
                textAlign: TextAlign.center,
                style: TextStyle(color: TripwiseColors.onSurfaceVariant),
              ),
              const SizedBox(height: 20),
              _InfoTile(
                label: 'BOOKING ID',
                value: data.bookingCode,
              ),
              const SizedBox(height: 12),
              _InfoTile(
                label: 'DESTINATION',
                value: data.destination,
                subtitle: data.destinationSubtitle,
              ),
              const SizedBox(height: 16),
              _ArrivalImage(
                imageUrl: data.imageUrl,
                arrivalDateLabel: data.arrivalDateLabel,
              ),
              if (data.ticket.code.isNotEmpty) ...[
                const SizedBox(height: 12),
                _InfoTile(
                  label: 'E-TICKET',
                  value: data.ticket.code,
                ),
              ],
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  style: TripwiseButtonStyles.primaryElevated(radius: 28),
                  onPressed: () => context.go(
                    '/my_trips?bookingId=${Uri.encodeQueryComponent(data.bookingId)}',
                  ),
                  child: const Text(
                    'View My Trips',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: onDownloadTicket,
                child: Text(
                  'Download E-Ticket',
                  style: TextStyle(
                    color: TripwiseColors.primary,
                    decoration: TextDecoration.underline,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.shield_rounded,
                    size: 14,
                    color: TripwiseColors.onSurfaceVariant,
                  ),
                  const SizedBox(width: 6),
                  Flexible(
                    child: Text(
                      'Payment secured by Tripwise Protection',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: TripwiseColors.onSurfaceVariant,
                          ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  const _InfoTile({
    required this.label,
    required this.value,
    this.subtitle,
  });

  final String label;
  final String value;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: TripwiseColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              color: TripwiseColors.onSurfaceVariant,
              fontSize: 12,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
          ),
          if (subtitle != null && subtitle!.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              subtitle!,
              style: TextStyle(
                color: TripwiseColors.onSurfaceVariant,
                fontSize: 12,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _ArrivalImage extends StatelessWidget {
  const _ArrivalImage({
    required this.imageUrl,
    required this.arrivalDateLabel,
  });

  final String imageUrl;
  final String arrivalDateLabel;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: SizedBox(
        height: 150,
        width: double.infinity,
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (imageUrl.isEmpty)
              _ImageFallback()
            else
              Image.network(
                imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => _ImageFallback(),
                loadingBuilder: (context, child, progress) {
                  if (progress == null) return child;
                  return const Center(
                    child: CircularProgressIndicator(strokeWidth: 2),
                  );
                },
              ),
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Color(0x99000000)],
                ),
              ),
            ),
            Positioned(
              left: 14,
              right: 14,
              bottom: 12,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'ARRIVAL DATE',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: Colors.white70,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.8,
                        ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    arrivalDateLabel,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                        ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ImageFallback extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: TripwiseColors.surfaceContainer,
      child: const Center(
        child: Icon(Icons.landscape, size: 48, color: Colors.white30),
      ),
    );
  }
}

class _PaymentErrorView extends StatelessWidget {
  const _PaymentErrorView({
    required this.error,
    required this.onRetry,
  });

  final Object? error;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.receipt_long_outlined,
                color: TripwiseColors.primary,
                size: 48,
              ),
              const SizedBox(height: 16),
              Text(
                'Could not load booking',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                error?.toString() ?? 'Unknown error',
                textAlign: TextAlign.center,
                style: TextStyle(color: TripwiseColors.onSurfaceVariant),
              ),
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: onRetry,
                  style: TripwiseButtonStyles.primaryElevated(radius: 14),
                  child: const Text('Try Again'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
